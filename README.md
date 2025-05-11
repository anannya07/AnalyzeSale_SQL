# 🛒 *Top Customers Analysis Procedure* 💸

This PL/SQL procedure analyzes the *top customers* by total spending within a specified period. It calculates essential metrics like the *total spent, **order count, and **average order value*, and logs the results for auditing and analysis purposes. The procedure also generates overall statistics like total revenue, total orders, and active customers.

## 📝 *Procedure Overview*

The procedure analyze_top_customers performs the following actions:
- Identifies the *top customers* based on total spending.
- Computes the *average order value, **total spent, and **order count* for each customer.
- Logs the execution details and results into *procedure_logs* for future reference.
- Handles errors and logs them into *error_logs* for troubleshooting.

## 🔧 *Features*
- 📊 *Top Customers Identification*: Selects customers with the highest total spend in a given period.
- 📅 *Customizable Date Range*: Users can define the start and end dates for the analysis.
- 💵 *Comprehensive Metrics*: Provides total spending, order count, average order value, and percentage of total revenue for each top customer.
- 📈 *Overall Statistics*: Displays total revenue, order count, active customers, and average order value for the entire period.
- 📜 *Execution Logging*: Logs procedure execution details and results for auditing purposes.
- ⚠ *Error Logging*: Catches and logs any errors during procedure execution for easy debugging.

## 📋 *Parameters*
- *p_start_date (DATE)*: The start date of the period to analyze.
- *p_end_date (DATE)*: The end date of the period to analyze.
- *p_top_n (NUMBER)*: The number of top customers to retrieve (defaults to 10).

## 🖥 *How to Use*
1. *Execute the procedure* by providing a date range and, optionally, the number of top customers you want to analyze.
   
   Example 1: Execute for the last quarter (Top 10 customers by default):
   ```sql
   EXEC analyze_top_customers(ADD_MONTHS(SYSDATE, -3), SYSDATE);
