
CREATE OR REPLACE PROCEDURE analyze_top_customers(
    p_start_date IN DATE,
    p_end_date IN DATE,
    p_top_n IN NUMBER DEFAULT 10
) IS
    -- Declare cursor for top customers
    CURSOR c_top_customers IS
        SELECT 
            c.customer_id,
            c.first_name,
            c.last_name,
            c.email,
            SUM(o.order_total) as total_spent,
            COUNT(o.order_id) as order_count,
            ROUND(SUM(o.order_total)/COUNT(o.order_id), 2) as avg_order_value
        FROM 
            customers c
            JOIN orders o ON c.customer_id = o.customer_id
        WHERE 
            o.order_date BETWEEN p_start_date AND p_end_date
        GROUP BY 
            c.customer_id, c.first_name, c.last_name, c.email
        ORDER BY 
            total_spent DESC
        FETCH FIRST p_top_n ROWS ONLY;
    
    -- Variables for customer record
    v_customer_id customers.customer_id%TYPE;
    v_first_name customers.first_name%TYPE;
    v_last_name customers.last_name%TYPE;
    v_email customers.email%TYPE;
    v_total_spent NUMBER;
    v_order_count NUMBER;
    v_avg_order_value NUMBER;
    
    -- Variables for overall stats
    v_total_revenue NUMBER := 0;
    v_total_orders NUMBER := 0;
    v_customer_count NUMBER := 0;
    
BEGIN
    -- Print header
    DBMS_OUTPUT.PUT_LINE('========== TOP CUSTOMER ANALYSIS ==========');
    DBMS_OUTPUT.PUT_LINE('Period: ' || TO_CHAR(p_start_date, 'DD-MON-YYYY') || ' to ' || TO_CHAR(p_end_date, 'DD-MON-YYYY'));
    DBMS_OUTPUT.PUT_LINE('==========================================');
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Calculate overall stats for the period
    SELECT 
        SUM(order_total),
        COUNT(order_id),
        COUNT(DISTINCT customer_id)
    INTO 
        v_total_revenue,
        v_total_orders,
        v_customer_count
    FROM 
        orders
    WHERE 
        order_date BETWEEN p_start_date AND p_end_date;
    
    -- Print overall stats
    DBMS_OUTPUT.PUT_LINE('Overall Statistics:');
    DBMS_OUTPUT.PUT_LINE('Total Revenue: $' || TO_CHAR(v_total_revenue, '999,999,999.99'));
    DBMS_OUTPUT.PUT_LINE('Total Orders: ' || v_total_orders);
    DBMS_OUTPUT.PUT_LINE('Active Customers: ' || v_customer_count);
    DBMS_OUTPUT.PUT_LINE('Average Order Value: $' || TO_CHAR(v_total_revenue / v_total_orders, '999,999.99'));
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Print top customers header
    DBMS_OUTPUT.PUT_LINE('Top ' || p_top_n || ' Customers:');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------');
    
    -- Loop through top customers
    OPEN c_top_customers;
    LOOP
        FETCH c_top_customers INTO 
            v_customer_id, v_first_name, v_last_name, v_email, 
            v_total_spent, v_order_count, v_avg_order_value;
        
        EXIT WHEN c_top_customers%NOTFOUND;
        
        -- Print customer details
        DBMS_OUTPUT.PUT_LINE('Customer: ' || v_first_name || ' ' || v_last_name || ' (ID: ' || v_customer_id || ')');
        DBMS_OUTPUT.PUT_LINE('Email: ' || v_email);
        DBMS_OUTPUT.PUT_LINE('Total Spent: $' || TO_CHAR(v_total_spent, '999,999.99'));
        DBMS_OUTPUT.PUT_LINE('Orders: ' || v_order_count);
        DBMS_OUTPUT.PUT_LINE('Average Order: $' || TO_CHAR(v_avg_order_value, '999,999.99'));
        DBMS_OUTPUT.PUT_LINE('% of Total Revenue: ' || 
                            TO_CHAR(ROUND(v_total_spent / v_total_revenue * 100, 2), '990.99') || '%');
        DBMS_OUTPUT.PUT_LINE('------------------------------------------');
    END LOOP;
    CLOSE c_top_customers;
    
    -- Log execution of the procedure
    INSERT INTO procedure_logs (
        procedure_name,
        execution_date,
        parameters,
        results
    ) VALUES (
        'ANALYZE_TOP_CUSTOMERS',
        SYSDATE,
        'Start: ' || TO_CHAR(p_start_date, 'DD-MON-YYYY') || ', End: ' || TO_CHAR(p_end_date, 'DD-MON-YYYY') || ', Top N: ' || p_top_n,
        'Total Revenue: $' || TO_CHAR(v_total_revenue, '999,999,999.99') || ', Total Orders: ' || v_total_orders
    );
    COMMIT;
    
    -- Print footer
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Analysis complete. Results logged.');
    DBMS_OUTPUT.PUT_LINE('==========================================');

EXCEPTION
    WHEN OTHERS THEN
        -- Log error
        INSERT INTO error_logs (
            procedure_name,
            error_date,
            error_code,
            error_message,
            parameters
        ) VALUES (
            'ANALYZE_TOP_CUSTOMERS',
            SYSDATE,
            SQLCODE,
            SQLERRM,
            'Start: ' || TO_CHAR(p_start_date, 'DD-MON-YYYY') || ', End: ' || TO_CHAR(p_end_date, 'DD-MON-YYYY') || ', Top N: ' || p_top_n
        );
        COMMIT;
        
        -- Raise the error again
        RAISE;
END analyze_top_customers;
/

-- Example usage:
-- Execute the procedure for the last quarter
EXEC analyze_top_customers(ADD_MONTHS(SYSDATE, -3), SYSDATE);

-- Execute the procedure for the last year, showing top 5 customers
EXEC analyze_top_customers(ADD_MONTHS(SYSDATE, -12), SYSDATE, 5);
