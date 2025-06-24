-- URBAN BREW HAVEN ANALYSIS

SELECT * FROM CITY;
SELECT * FROM PRODUCTS;
SELECT * FROM CUSTOMERS;
SELECT * FROM SALES;

-- Coffee Consumers Count
-- Q1. How many people in each city are estimated to consume coffee, given that 25% of the population does?
select city_name, ROUND((population*0.25)/1000000,2) as coffer_consumer_in_millions ,city_rank
from city order by coffer_consumer_in_millions desc;


-- Total Revenue from Coffee Sales
-- Q2. What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?
select city_name,SUM(total) as total_revenue 
from sales as s join customers as c on s.customer_id=c.customer_id 
join city as ct on c.city_id=ct.city_id 
where extract(year from sale_date)='2023' and extract(quarter from sale_date)=4
group by city_name order by total_revenue desc;


-- Sales Count for Each Product
-- Q3. How many units of each coffee product have been sold?
select product_name,count(s.sale_id) as total_units 
from products as p left join sales as s on s.product_id=p.product_id 
group by product_name order by total_units desc;


-- Average Sales Amount per City
-- Q4. What is the average sales amount per customer in each city?
select ct.city_name,SUM(s.total) as total_revenue,Count(distinct c.customer_id) as total_customer,
ROUND(SUM(s.total)/Count(distinct c.customer_id),2) as avg_sales_per_customer 
from sales as s join customers as c on s.customer_id=c.customer_id 
join city as ct on c.city_id=ct.city_id 
group by city_name order by total_revenue desc;


-- Customer Segmentation by City
-- Q5. How many unique customers are there in each city who have purchased coffee products?
select ct.city_name,Count(distinct c.customer_id) as total_customer
from sales as s join customers as c on s.customer_id=c.customer_id 
join city as ct on c.city_id=ct.city_id 
group by city_name order by total_customer desc;
    

-- City Population and Coffee Consumers
-- Q6.Provide a list of cities along with their populations and estimated coffee consumers.
WITH city_table as
(
	select city_name, ROUND((population*0.25)/1000000,2) as coffer_consumer_in_millions ,city_rank
		from city
),
customers_table as (
	select ct.city_name,Count(distinct c.customer_id) as total_customer
	from sales as s join customers as c on s.customer_id=c.customer_id 
	join city as ct on c.city_id=ct.city_id 
	group by city_name
)
select customers_table.city_name, city_table.coffer_consumer_in_millions,customers_table.total_customer 
from city_table join customers_table on city_table.city_name=customers_table.city_name;


-- Top Selling Products by City
-- Q7. What are the top 3 selling products in each city based on sales volume?
select q.city_name,q.product_name,q.total_orders from (
	select ct.city_name,p.product_name,count(s.sale_id) as total_orders,
	dense_rank() over(partition by city_name order by count(s.sale_id) desc) as rnk
	from sales as s
		join products as p
		on s.product_id = p.product_id
		join customers as c
		on c.customer_id = s.customer_id
		join city as ct
		on ct.city_id = c.city_id
		group by ct.city_name,p.product_name
	) as q where rnk<=3;


-- Average Sale vs Rent
-- Q8. Find each city and their average sale per customer and avg rent per customer
WITH city_table as (
	select ct.city_name,SUM(s.total) as total_revenue,Count(distinct c.customer_id) as total_customer,
	ROUND(SUM(s.total)/Count(distinct c.customer_id),2) as avg_sales_per_customer 
	from sales as s join customers as c on s.customer_id=c.customer_id 
	join city as ct on c.city_id=ct.city_id 
	group by city_name
), 
city_rent as (
	select city_name,estimated_rent from city
)
select ct.city_name,ct.total_revenue,ct.total_customer,
ct.avg_sales_per_customer,ROUND((cr.estimated_rent)/ct.total_customer,2) as avg_rent
from city_table as ct join city_rent as cr on ct.city_name=cr.city_name order by avg_sales_per_customer desc;


-- Monthly Sales Growth
-- Q9. Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly).
WITH monthly_sales as (
	select ct.city_name,extract(month from sale_date) as month,extract(year from sale_date) as year,
    SUM(s.total) as total_sale
    from sales as s join customers as c on s.customer_id=c.customer_id join city as ct on c.city_id=ct.city_id
    group by ct.city_name,month,year
),
growth_rate as (
	select city_name,month,year,total_sale as month_sale,
			LAG(total_sale, 1) over(partition by city_name order by year, month) as last_month_sale
		from monthly_sales
)
select city_name,month,year,month_sale,last_month_sale,
ROUND((month_sale-last_month_sale)/last_month_sale*100,2) as growth_ratio
from growth_rate;


-- Market Potential Analysis
-- Q10. Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer
WITH city_table as (
	select ct.city_name,SUM(s.total) as total_revenue,Count(distinct c.customer_id) as total_customer,
	ROUND(SUM(s.total)/Count(distinct c.customer_id),2) as avg_sales_per_customer 
	from sales as s join customers as c on s.customer_id=c.customer_id 
	join city as ct on c.city_id=ct.city_id 
	group by city_name
), 
city_rent as (
	select city_name,estimated_rent,ROUND((population*0.25)/1000000,2) as coffer_consumer_in_millions from city
)
select ct.city_name,ROUND((ct.total_revenue)/1000000,2) as total_revenue_in_millions,ct.total_customer,cr.coffer_consumer_in_millions,
ct.avg_sales_per_customer,ROUND((cr.estimated_rent)/ct.total_customer,2) as avg_rent
from city_table as ct join city_rent as cr on ct.city_name=cr.city_name 
order by avg_sales_per_customer desc,avg_rent;

/*Recommendations

City 1: Pune

1. Average rent per customer is very low (₹294.23).
2. Highest total revenue (1.26M).
3. Average sales per customer is also highest (₹24197.88).

City 2: Chennai

1. Highest estimated coffee consumers at 2.78 million.
2. Average sales per customer is also high (₹22479.05).
3. Average rent per customer is ₹407.14 (still under ₹500).

City 3: Jaipur

1. Highest number of customers, which is 69.
2. Average rent per customer is very low at ₹156.52.
3. Average sales per customer is better at ₹11644.2.
*/