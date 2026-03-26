create database company_db;
use company_db;

show tables;

select * from `company_db`.`customer data`;

#total customer
SELECT COUNT(*) AS total_customers
FROM `company_db`.`customer data`;

-- Customers by Country-- 
SELECT country, COUNT(*) AS customer_count
FROM `company_db`.`customer data`
GROUP BY country
ORDER BY customer_count DESC;

-- Top 10 Cities by Customers
SELECT city, COUNT(*) AS total
FROM `company_db`.`customer data`
GROUP BY city
ORDER BY total DESC
LIMIT 10;

-- Customer Type Distribution
SELECT customer_type, COUNT(*)
FROM `company_db`.`customer data`
GROUP BY customer_type;

-- Loyalty Tier Distribution
SELECT loyalty_status, COUNT(*)
FROM `company_db`.`customer data`
GROUP BY loyalty_status;

-- Average CLV by Country
SELECT country, AVG(customer_lifetime_value) AS avg_clv
FROM `company_db`.`customer data`
GROUP BY country;

-- Top CLV Customers
SELECT customer_id, customer_name, customer_lifetime_value
FROM `company_db`.`customer data`
ORDER BY customer_lifetime_value DESC
LIMIT 10;

-- Customer Signup Trend
SELECT YEAR(signup_date) AS year, COUNT(*)
FROM `company_db`.`customer data`
GROUP BY year;

-- Customer Segment Score Analysis
SELECT customer_segment_score, COUNT(*)
FROM `company_db`.`customer data`
GROUP BY customer_segment_score;



#orders
SELECT COUNT(*) FROM orders;

-- Orders Per Year
SELECT YEAR(order_date), COUNT(*)
FROM orders
GROUP BY YEAR(order_date);

-- Orders Per Customer
SELECT customer_id, COUNT(*) AS total_orders
FROM orders
GROUP BY customer_id
ORDER BY total_orders DESC;

-- Average Order Value
SELECT AVG(order_value_usd) FROM orders;

-- Revenue by Country
SELECT c.country, SUM(o.order_value_usd)
FROM orders o
JOIN `company_db`.`customer data` c ON o.customer_id = c.customer_id
GROUP BY c.country;

-- Revenue by Customer Type
SELECT c.customer_type, SUM(o.order_value_usd)
FROM orders o
JOIN `company_db`.`customer data` c ON o.customer_id = c.customer_id
GROUP BY c.customer_type;

-- Priority Distribution-- 
SELECT priority_level, COUNT(*)
FROM orders
GROUP BY priority_level;

-- Revenue by Priority
SELECT priority_level, SUM(order_value_usd)
FROM orders
GROUP BY priority_level;

-- Top Revenue Customers
SELECT customer_id, SUM(order_value_usd) AS revenue
FROM orders
GROUP BY customer_id
ORDER BY revenue DESC
LIMIT 10;

-- Orders by Route
SELECT origin_city, destination_city, COUNT(*)
FROM orders
GROUP BY origin_city, destination_city;



-- SHIPMENT ANALYSIS-- 
SELECT COUNT(*) FROM shipments;

-- Shipment Status Distribution
SELECT shipment_status, COUNT(*)
FROM shipments
GROUP BY shipment_status;

-- Shipments by Warehouse
SELECT warehouse_id, COUNT(*)
FROM shipments
GROUP BY warehouse_id;

-- Shipments by Partner
SELECT partner_id, COUNT(*)
FROM shipments
GROUP BY partner_id;

-- Average Delivery Time
SELECT AVG(DATEDIFF(delivery_date, dispatch_date))
FROM shipments;

-- Shipments Per Route
SELECT route_id, COUNT(*)
FROM shipments
GROUP BY route_id;


-- Delayed Shipments Count
SELECT COUNT(*)
FROM shipments s
JOIN delivery_performance d ON s.shipment_id = d.shipment_id
WHERE d.delay_flag = 1;


-- Delay Percentage
SELECT 
SUM(CASE WHEN delay_flag = 1 THEN 1 ELSE 0 END)*100.0/COUNT(*) AS delay_percentage
FROM delivery_performance;


-- DELIVERY PERFORMANCE-- 
-- On-Time Delivery Rate
SELECT 
SUM(CASE WHEN on_time_delivery = 1 THEN 1 ELSE 0 END)*100.0/COUNT(*)
FROM delivery_performance;

-- Average Cost Per Shipment
SELECT AVG(cost_per_shipment_usd)
FROM delivery_performance;

-- Delay Reason Distribution
SELECT delay_reason, COUNT(*)
FROM delivery_performance
GROUP BY delay_reason;

-- Partner Delay Rate
SELECT p.partner_name,
AVG(d.delay_flag) AS delay_rate
FROM shipments s
JOIN delivery_performance d ON s.shipment_id = d.shipment_id
JOIN delivery_partners p ON s.partner_id = p.partner_id
GROUP BY p.partner_name;

-- Warehouse Delay Rate
SELECT warehouse_id,
AVG(delay_flag)
FROM shipments s
JOIN delivery_performance d ON s.shipment_id = d.shipment_id
GROUP BY warehouse_id;

-- Route Delay Rate
SELECT route_id,
AVG(delay_flag)
FROM shipments s
JOIN delivery_performance d ON s.shipment_id = d.shipment_id
GROUP BY route_id;

-- Highest Cost Routes
SELECT route_id, AVG(cost_per_shipment_usd)
FROM shipments s
JOIN delivery_performance d ON s.shipment_id = d.shipment_id
GROUP BY route_id
ORDER BY AVG(cost_per_shipment_usd) DESC;

-- Delivery Time vs Distance
SELECT r.distance_km,
AVG(d.actual_delivery_time_hr)
FROM routes r
JOIN shipments s ON r.route_id = s.route_id
JOIN delivery_performance d ON s.shipment_id = d.shipment_id
GROUP BY r.distance_km;

-- Warehouse Efficiency vs Delay
SELECT w.efficiency_score,
AVG(d.delay_flag)
FROM warehouses_golden w
JOIN shipments s ON w.warehouse_id = s.warehouse_id
JOIN delivery_performance d ON s.shipment_id = d.shipment_id
GROUP BY w.efficiency_score;

-- Transport Mode Usage
SELECT transport_mode, COUNT(*)
FROM routes
GROUP BY transport_mode;


-- FEEDBACK & SUPPLY CHAIN
-- Average Satisfaction Score
SELECT AVG(rating)
FROM customer_feedback;

-- Satisfaction vs Delay
SELECT d.delay_flag, AVG(f.rating)
FROM delivery_performance d
JOIN customer_feedback f ON d.shipment_id = f.shipment_id
GROUP BY d.delay_flag;

-- Complaints Percentage
SELECT 
SUM(CASE WHEN complaint_flag=1 THEN 1 ELSE 0 END)*100.0/COUNT(*)
FROM customer_feedback;


-- Average Response Time
SELECT AVG(response_time_hr)
FROM customer_feedback;

-- Hub-to-Hub Movements Count
SELECT COUNT(*)
FROM supply_chain_movement;

-- Most Used Distribution Hub
SELECT from_hub, COUNT(*)
FROM supply_chain_movement
GROUP BY from_hub
ORDER BY COUNT(*) DESC;

-- Movement Mode Usage
SELECT movement_mode, COUNT(*)
FROM supply_chain_movement
GROUP BY movement_mode;

-- Transit Delay Analysis
SELECT movement_status, COUNT(*)
FROM supply_chain_movement
GROUP BY movement_status;

-- High Risk Delay Reasons
SELECT delay_reason, COUNT(*)
FROM delivery_performance
WHERE delay_flag = 1
GROUP BY delay_reason;

-- Revenue vs Delay Impact
SELECT d.delay_flag,
SUM(o.order_value_usd)
FROM delivery_performance d
JOIN shipments s ON d.shipment_id = s.shipment_id
JOIN orders o ON s.order_id = o.order_id
GROUP BY d.delay_flag;


-- Rank Customers by Revenue
SELECT 
customer_id,
SUM(order_value_usd) AS revenue,
RANK() OVER(ORDER BY SUM(order_value_usd) DESC) AS revenue_rank
FROM orders
GROUP BY customer_id;

-- Dense Rank Customers (Top Buyers)
SELECT 
customer_id,
SUM(order_value_usd) revenue,
DENSE_RANK() OVER(ORDER BY SUM(order_value_usd) DESC) rank_dense
FROM orders
GROUP BY customer_id;

select * from `customer data`;
select * from orders;


-- Top 3 Customers per Country
SELECT *
FROM (
SELECT 
c.country,
o.customer_id,
SUM(order_value_usd) revenue,
ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY SUM(order_value_usd) DESC) rn
FROM orders o
JOIN `customer data` c ON o.customer_id=c.customer_id
GROUP BY c.country,o.customer_id
) t
WHERE rn<=3;


-- Running Total Revenue Trend
SELECT 
order_date,
SUM(order_value_usd) daily_revenue,
SUM(SUM(order_value_usd)) OVER(ORDER BY order_date) running_revenue
FROM orders
GROUP BY order_date;


-- Moving Average Revenue (7 Days)
SELECT 
order_date,
AVG(order_value_usd) OVER(
ORDER BY order_date
ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
) moving_avg
FROM orders;


select * from shipments ;
-- Shipment Delay Rank per Route
SELECT 
route_id,
shipment_id,
delay_flag,
RANK() OVER(PARTITION BY route_id ORDER BY delay_flag DESC) delay_rank
FROM shipments s
JOIN delivery_performance d ON s.shipment_id=d.shipment_id;

-- Cost Distribution Quartiles
SELECT 
shipment_id,
cost_per_shipment_usd,
NTILE(4) OVER(ORDER BY cost_per_shipment_usd) cost_quartile
FROM delivery_performance;

-- Cost Distribution Quartiles
SELECT 
shipment_id,
cost_per_shipment_usd,
NTILE(4) OVER(ORDER BY cost_per_shipment_usd) cost_quartile
FROM delivery_performance;

-- Revenue Share of Each Customer
SELECT 
customer_id,
SUM(order_value_usd) revenue,
SUM(order_value_usd) *100/
SUM(SUM(order_value_usd)) OVER() revenue_share
FROM orders
GROUP BY customer_id;

-- Rank Warehouses by Shipment Volume
SELECT 
warehouse_id,
COUNT(*) shipments,
RANK() OVER(ORDER BY COUNT(*) DESC) warehouse_rank
FROM shipments

GROUP BY warehouse_id;



-- Partner Delay Performance Ranking
SELECT 
p.partner_name,
AVG(delay_flag) delay_rate,
DENSE_RANK() OVER(ORDER BY AVG(delay_flag)) partner_rank
FROM shipments s
JOIN delivery_performance d ON s.shipment_id=d.shipment_id
JOIN delivery_partners p ON s.partner_id=p.partner_id
GROUP BY p.partner_name;

-- Delivery Time Difference from Average
SELECT 
shipment_id,
actual_delivery_time_hr,
actual_delivery_time_hr -
AVG(actual_delivery_time_hr) OVER() diff_from_avg
FROM delivery_performance;

-- Cumulative Shipment Count by Date
SELECT 
dispatch_date,
COUNT(*) daily_shipments,
SUM(COUNT(*)) OVER(ORDER BY dispatch_date) cumulative_shipments
FROM shipments
GROUP BY dispatch_date;


-- Customer Order Gap (LAG)
SELECT 
customer_id,
order_date,
order_date - LAG(order_date) OVER(PARTITION BY customer_id ORDER BY order_date) gap_days
FROM orders;

-- Delivery Time Change (LEAD)-- 
SELECT 
shipment_id,
actual_delivery_time_hr,
LEAD(actual_delivery_time_hr) OVER(ORDER BY shipment_id) next_delivery_time
FROM delivery_performance;

-- Revenue Growth Comparison-- 
SELECT 
YEAR(order_date) year,
SUM(order_value_usd) revenue,
SUM(order_value_usd) -
LAG(SUM(order_value_usd)) OVER(ORDER BY YEAR(order_date)) growth
FROM orders
GROUP BY YEAR(order_date);


-- Delay Running Average
SELECT 
shipment_id,
AVG(delay_flag) OVER(
ORDER BY shipment_id
ROWS BETWEEN 10 PRECEDING AND CURRENT ROW
) running_delay_rate
FROM delivery_performance;



-- Customer Satisfaction Ranking
SELECT 
customer_id,
AVG(rating) avg_rating,
RANK() OVER(ORDER BY AVG(rating) DESC) satisfaction_rank
FROM customer_feedback
GROUP BY customer_id;

