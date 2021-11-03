DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  "runner_id" INTEGER,
  "registration_date" DATE
);
INSERT INTO runners
  ("runner_id", "registration_date")
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" DATETIME
);

INSERT INTO customer_orders
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" VARCHAR(19),
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);

INSERT INTO runner_orders
  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  "pizza_id" INTEGER,
  "pizza_name" TEXT
);
INSERT INTO pizza_names
  ("pizza_id", "pizza_name")
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  "pizza_id" INTEGER,
  "toppings" TEXT
);
INSERT INTO pizza_recipes
  ("pizza_id", "toppings")
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  "topping_id" INTEGER,
  "topping_name" TEXT
);
INSERT INTO pizza_toppings
  ("topping_id", "topping_name")
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');


--How many pizzas were ordered?

SELECT COUNT(*) AS TOTAL_ORDERS
FROM CUSTOMER_ORDERS

--How many unique customer orders were made?

WITH CTE_1 AS
(SELECT 
	CUSTOMER_ID, 
	COUNT(ORDER_ID) OVER (PARTITION BY CUSTOMER_ID ORDER BY CUSTOMER_ID) AS TOTAL_ORDERS
FROM CUSTOMER_ORDERS)
SELECT
	CUSTOMER_ID,
	TOTAL_ORDERS
FROM CTE_1
GROUP BY CUSTOMER_ID, TOTAL_ORDERS

-- How many successful orders were delivered by each runner?

WITH CTE_1 AS
(SELECT
	RUNNER_ID,
	COUNT(ORDER_ID) OVER (PARTITION BY RUNNER_ID ORDER BY RUNNER_ID) AS ORDERS_PER_RUNNER
FROM RUNNER_ORDERS
WHERE CANCELLATION = ' '
)
SELECT 
	RUNNER_ID,
	ORDERS_PER_RUNNER
FROM CTE_1
GROUP BY RUNNER_ID, ORDERS_PER_RUNNER


-- How many Vegetarian and Meatlovers were ordered by each customer?

SELECT
	A.CUSTOMER_ID,
	A.PIZZA_ID,
	B.PIZZA_NAME,
	COUNT(B.PIZZA_NAME) AS TOTAL_ORDERED
FROM CUSTOMER_ORDERS A
JOIN PIZZA_NAMES B
ON A.PIZZA_ID = B.PIZZA_ID
GROUP BY A.CUSTOMER_ID, A.PIZZA_ID, B.PIZZA_NAME
ORDER BY A.CUSTOMER_ID


--What was the maximum number of pizzas delivered in a single order?

SELECT TOP 1
	CUSTOMER_ID,
	COUNT(*) AS PIZZAS_ORDERED,
	ORDER_TIME
FROM CUSTOMER_ORDERS
GROUP BY CUSTOMER_ID, ORDER_TIME
ORDER BY PIZZAS_ORDERED DESC


--For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT
	CUSTOMER_ID,
	CHANGES, 
	COUNT(*) AS COUNT_CHANGES
FROM
	(SELECT 
		A.CUSTOMER_ID,
		CASE
			WHEN A.EXCLUSIONS != ' ' OR A.EXTRAS != ' ' THEN 'YES'
			ELSE 'NO'
		END CHANGES
	FROM CUSTOMER_ORDERS A
	JOIN RUNNER_ORDERS B
	ON A.ORDER_ID = B.ORDER_ID
	WHERE B.CANCELLATION = ' ') AS SUBQUERY
GROUP BY CUSTOMER_ID, CHANGES


-- How many pizzas were delivered that had both exclusions and extras?

SELECT 
	ORDER_ID, 
	CHANGES, 
	COUNT(*) AS EXCLUSION_AND_EXTRAS_COUNT
FROM
		(
		SELECT
			A.ORDER_ID,
			CASE 
				WHEN A.EXCLUSIONS <>  ' ' AND A.EXTRAS <> ' ' THEN 'YES'
				ELSE 'NO'
			END CHANGES
		FROM CUSTOMER_ORDERS A
		JOIN RUNNER_ORDERS B
		ON A.ORDER_ID = B.ORDER_ID
		WHERE CANCELLATION = ' ') AS SUBQUERY
WHERE CHANGES = 'YES'
GROUP BY ORDER_ID, CHANGES


--What was the total volume of pizzas ordered for each hour of the day?

SELECT
	COUNT(*) AS VOLUME_SALES,
	DATEPART(DAY, ORDER_TIME) AS DAY_NUMBER,
	DATEPART(HOUR, ORDER_TIME) AS TIMEFRAME_HOUR
	FROM CUSTOMER_ORDERS
GROUP BY DATEPART(DAY, ORDER_TIME), DATEPART(HOUR, ORDER_TIME)
ORDER BY DAY_NUMBER


--What was the volume of orders for each day of the week?

SELECT
	COUNT(*) AS VOLUME_SALES,
	DATEPART(WEEK, ORDER_TIME) AS WEEK_NUMBER,
	DATEPART(WEEKDAY, ORDER_TIME) AS WEEK_DAY_NUMBER
	FROM CUSTOMER_ORDERS
GROUP BY DATEPART(WEEK, ORDER_TIME), DATEPART(WEEKDAY, ORDER_TIME)
ORDER BY WEEK_NUMBER

--How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

SELECT
	WEEK_NUMBER,
	COUNT(*) AS RUNNERS_COUNT
FROM
(SELECT
	RUNNER_ID,
	REGISTRATION_DATE,
CASE
	WHEN REGISTRATION_DATE BETWEEN REGISTRATION_DATE AND DATEADD(DAY, 6, '2021-01-01') THEN 'WEEK_1'
	WHEN REGISTRATION_DATE BETWEEN REGISTRATION_DATE AND DATEADD(DAY, 13, '2021-01-01') THEN 'WEEK_2'
	WHEN REGISTRATION_DATE BETWEEN REGISTRATION_DATE AND DATEADD(DAY, 20, '2021-01-01') THEN 'WEEK_3'
	WHEN REGISTRATION_DATE BETWEEN REGISTRATION_DATE AND DATEADD(DAY, 28, '2021-01-01') THEN  'WEEK_4'
	WHEN REGISTRATION_DATE BETWEEN REGISTRATION_DATE AND DATEADD(DAY, 30, '2021-01-01') THEN 'WEEK_5'
	END AS WEEK_NUMBER
FROM RUNNERS) AS SUBQUERY
GROUP BY WEEK_NUMBER


-- What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

WITH CTE_1 AS
(SELECT
	A.ORDER_ID,
	B.RUNNER_ID,
	A.ORDER_TIME,
	B.PICKUP_TIME,
	DATEDIFF(MINUTE, A.ORDER_TIME, B.PICKUP_TIME) AS MINUTES_DIFFERENCE
	FROM CUSTOMER_ORDERS A
JOIN RUNNER_ORDERS B
ON A.ORDER_ID = B.ORDER_ID
WHERE B.CANCELLATION = ' '
),
CTE_2 AS
(SELECT
	RUNNER_ID,
	AVG(MINUTES_DIFFERENCE) OVER (PARTITION BY RUNNER_ID) AS AVG_MINUTES
FROM CTE_1)
SELECT *
FROM CTE_2
GROUP BY RUNNER_ID, AVG_MINUTES
