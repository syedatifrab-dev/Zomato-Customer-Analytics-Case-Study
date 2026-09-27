# Zomato-Customer-Analytics-Case-Study
Analyzed customer, order, restaurant, and revenue data using SQL to identify customer retention patterns, revenue trends, restaurant performance, and underperforming segments. Used advanced SQL techniques including CTEs, window functions, subqueries, aggregations, and date-based analysis to generate actionable business insights.


# 🍽️ Zomato Customer Analytics Case Study | SQL

## 📌 Project Overview

Zomato is one of India's largest food delivery platforms, connecting millions of customers with restaurants across multiple cities.

Despite continued growth in registered customers, the business has observed inconsistent revenue growth, declining customer retention, and underperforming restaurant partners.

This project analyzes Zomato's customer, restaurant, and order data using SQL to identify key business trends, customer behavior, restaurant performance, cancellation patterns, and customer churn.

The objective is to generate data-driven insights that can help improve:

- Revenue growth
- Customer retention
- Restaurant performance
- Operational efficiency
- Customer acquisition
- Cancellation and refund management

---

## 🎯 Business Problem

Management wants to understand:

- How revenue is performing over time
- Which cities and payment methods contribute the most revenue
- Who the highest-value customers are
- Which acquisition channels attract valuable customers
- Which restaurants and cuisines perform best
- How cancellations and refunds impact revenue
- How many customers have churned
- Which customers and cities are contributing to churn
- How much revenue is potentially lost due to customer churn

---

# 📊 Analysis Areas

The project is divided into five major analytical areas:

1. Revenue Analysis
2. Customer Analysis
3. Restaurant Performance
4. Cancellation & Refund Analysis
5. Customer Churn Analysis

---

# 💰 1. Revenue Analysis

### Business Questions

1. What is the total revenue?
2. What is the monthly revenue trend?
3. Which city contributes the highest revenue?
4. Which payment mode generates the most revenue?
5. What is the Average Order Value (AOV)?

### SQL Concepts Used

- `SUM()`
- `AVG()`
- `COUNT()`
- `DATE_TRUNC()`
- `GROUP BY`
- `ORDER BY`
- Filtering
- Aggregations

### Example

```sql
SELECT 
    DATE_TRUNC('MONTH', order_timestamp) AS order_month,
    SUM(order_amount) AS total_revenue
FROM zomato_orders

👥 2. Customer Analysis
Business Questions
1. Who are the top 20 customers by revenue?
2. What percentage of revenue comes from top customers?
3. Which acquisition channel brings the highest-value customers?
4. How many repeat customers do we have?
SQL Concepts Used
- CTEs
- Window Functions
- ROW_NUMBER()
- RANK()
- COUNT()
- SUM()
- Joins
- Subqueries
Example: Top 20 Customers
WITH customer_revenue AS (
    SELECT 
        customer_id,
        SUM(order_amount) AS total_revenue
    FROM zomato_orders
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
)

SELECT 
    customer_id,
    total_revenue
FROM customer_revenue
ORDER BY total_revenue DESC
LIMIT 20;

🍴 3. Restaurant Performance
Business Questions
1. Which restaurants generate the highest revenue?
2. Which restaurants receive the most orders?
3. Which cuisines are most popular?
4. Do highly-rated restaurants generate more revenue?
5. What are the last 5 restaurants based on performance?
SQL Concepts Used
- JOIN
- GROUP BY
- Aggregations
- COUNT()
- SUM()
- AVG()
- Ranking
- Sorting
Example: Highest Revenue Restaurants
SELECT 
    o.restaurant_id,
    r.restaurant_name,
    SUM(o.order_amount) AS total_revenue
FROM zomato_orders o
JOIN restaurants r
    ON o.restaurant_id = r.restaurant_id
WHERE o.order_status = 'Delivered'
GROUP BY 
    o.restaurant_id,
    r.restaurant_name
ORDER BY total_revenue DESC;

❌ 4. Cancellation & Refund Analysis

Business Questions
1. What is the cancellation rate?
2. What is the refund rate?
3. How much revenue is lost due to cancellations?
4. Which restaurants have the highest cancellation rate?
SQL Concepts Used
- COUNT_IF()
- Conditional aggregation
- CASE WHEN
- SUM()
- Percentage calculations
- ROUND()
Example: Cancellation Rate
SELECT 
    ROUND(
        COUNT_IF(order_status = 'Cancelled') * 100.0 
        / COUNT(*),
        2
    ) AS cancellation_rate
FROM zomato_orders;

Example: Revenue Lost Due to Cancellations
SELECT 
    SUM(order_amount) AS lost_revenue
FROM zomato_orders
WHERE order_status = 'Cancelled';

🔄 5. Customer Churn Analysis
Customer churn is defined in this project as:
A customer who has not placed an order for more than 90 days relative to the latest transaction date in the dataset.

Business Questions
1. How many customers have churned?
2. What is the churn rate?
3. Which city has the highest churn?
4. How much revenue is lost due to churn?
5. Who are the high-value churned customers?


SQL Concepts Used
- CTEs
- MAX()
- DATEDIFF()
- CASE WHEN
- CROSS JOIN
- Conditional aggregation
- Customer-level aggregation

Example: Churn Rate
WITH last_txn AS (
    SELECT 
        MAX(order_timestamp) AS last_txn_date
    FROM zomato_orders
),

cust_last AS (
    SELECT 
        customer_id,
        MAX(order_timestamp) AS max_txn_date
    FROM zomato_orders
    GROUP BY customer_id
),

churn AS (
    SELECT
        customer_id,
        CASE 
            WHEN DATEDIFF(
                day, 
                max_txn_date, 
                last_txn_date
            ) > 90 
            THEN 1
            ELSE 0
        END AS is_churn_tag
    FROM cust_last
    CROSS JOIN last_txn
)

SELECT 
    ROUND(
        SUM(is_churn_tag) * 100.0 / COUNT(*),
        2
    ) AS churn_rate
FROM churn;

🧠 Key SQL Skills Demonstrated
This project demonstrates practical SQL skills used in Data Analyst roles.
SQL Fundamentals
- SELECT
- WHERE
- GROUP BY
- ORDER BY
- HAVING
- DISTINCT
- LIMIT
Aggregations
- SUM()
- COUNT()
- COUNT_IF()
- AVG()
- MAX()
- MIN()
Advanced SQL
- Common Table Expressions (CTEs)
- Window Functions
- ROW_NUMBER()
- RANK()
- Conditional Aggregation
- Subqueries
- CASE WHEN
- Date Functions
- DATE_TRUNC()
- DATEDIFF()
Joins
- INNER JOIN
- CROSS JOIN

🗂️ Dataset Structure

The analysis uses multiple datasets representing different parts of the Zomato business.
zomato_orders
Contains order-level information.
Typical fields include:
- order_id
- customer_id
- restaurant_id
- order_timestamp
- order_amount
- order_status
- payment_mode
zomato_customer
Contains customer-level information.
Typical fields include:
- customer_id
- city
- acquisition_channel
- Customer attributes
restaurants
Contains restaurant information.
Typical fields include:
- restaurant_id
- restaurant_name
- cuisine
- city
- rating


🔍 Key Business Metrics

The project focuses on the following KPIs:
KPI	Description
Total Revenue	Revenue generated from orders
Monthly Revenue	Revenue trend by month
AOV	Average revenue per order
Top Customer Revenue	Revenue generated by high-value customers
Cancellation Rate	Percentage of cancelled orders
Refund Rate	Percentage of refunded orders
Lost Revenue	Revenue associated with cancelled orders
Churned Customers	Customers inactive for more than 90 days
Churn Rate	Percentage of customers classified as churned
Churn Revenue Loss	Revenue associated with churned customers


📈 Business Insights
The analysis is designed to identify:
- Revenue growth and decline patterns
- High-performing cities
- High-value customers
- Customer acquisition channel performance
- Restaurant revenue concentration
- Popular cuisines
- Relationship between restaurant ratings and revenue
- Cancellation hotspots
- Revenue lost through cancellations
- Customer churn patterns
- High-value customers at risk of churn


Final business insights and recommendations are based on the results generated from the SQL analysis.

💡 Business Recommendations
Based on the analytical findings, potential business actions include:
Customer Retention
- Develop targeted retention campaigns for high-value churned customers.
- Identify customers approaching the 90-day inactivity threshold.
- Create personalized offers based on customer order behavior.
Restaurant Performance
- Investigate restaurants with consistently high cancellation rates.
- Identify high-revenue restaurants and strengthen partner relationships.
- Analyze low-performing restaurants to understand operational issues.
Revenue Growth
- Focus acquisition efforts on channels generating high-value customers.
- Identify cities with strong revenue potential.
- Monitor monthly revenue trends to identify growth opportunities.
Cancellation Management
- Investigate restaurants with unusually high cancellation rates.
- Analyze cancellation reasons and operational patterns.
- Reduce preventable cancellations to minimize revenue leakage.

🛠️ Tools & Technologies
- SQL
- Snowflake
- Data Analysis
- Data Aggregation
- Window Functions
- CTEs
- Business Analytics


⭐ Project Highlights
This project demonstrates the ability to:
- Translate business questions into SQL queries
- Analyze large transactional datasets
- Build customer-level metrics
- Perform revenue and profitability analysis
- Use advanced SQL window functions
- Analyze customer churn
- Identify revenue leakage
- Evaluate restaurant performance
- Convert SQL analysis into actionable business insights


📌 Conclusion
The Zomato Customer Analytics Case Study demonstrates how SQL can be used to analyze customer behavior, revenue performance, restaurant operations, cancellations, and churn.
The analysis provides a structured approach for identifying business opportunities, improving customer retention, reducing revenue leakage, and supporting data-driven decision-making.




WHERE order_status = 'Delivered'
GROUP BY 1
ORDER BY 1;
