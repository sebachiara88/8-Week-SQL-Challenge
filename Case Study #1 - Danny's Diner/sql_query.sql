CREATE SCHEMA dannys_diner;
SET search_path = dannys_diner;

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  
  --1) What is the total amount each customer spent at the restaurant?
 SELECT
	S.CUSTOMER_ID as Customers, 
	SUM(M.PRICE) as TotalSpent 
 FROM SALES S 
 JOIN MENU M ON 
 S.PRODUCT_ID = M.PRODUCT_ID
 GROUP BY  S.CUSTOMER_ID;
 
 --2) How many days has each customer visited the restaurant?
SELECT
	CUSTOMER_ID AS Customers,
	COUNT(DISTINCT ORDER_DATE) AS Visitation_Number
FROM SALES
GROUP BY  CUSTOMER_ID;

--3) What was the first item from the menu purchased by each customer?

WITH CTE_TABLE AS
(SELECT 
	S.CUSTOMER_ID,
	S.ORDER_DATE,
	M.PRODUCT_NAME,
	ROW_NUMBER () OVER (PARTITION BY CUSTOMER_ID ORDER BY ORDER_DATE ASC) AS ROWNUM
FROM SALES S
JOIN MENU M
ON S.PRODUCT_ID = M.PRODUCT_ID)
SELECT 
	CUSTOMER_ID,
	ORDER_DATE,
	PRODUCT_NAME
FROM CTE_TABLE
WHERE ROWNUM = 1

-- 4) What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT
	M.PRODUCT_NAME,
	COUNT(S.PRODUCT_ID) AS TIME_PURCHASED
FROM MENU M
JOIN SALES S
ON S.PRODUCT_ID = M.PRODUCT_ID
GROUP BY PRODUCT_NAME
ORDER BY TIME_PURCHASED DESC

-- 5) Which item was the most popular for each customer?

SELECT *
FROM(
SELECT 
	S.CUSTOMER_ID,
	S.PRODUCT_ID,
	M.PRODUCT_NAME,
	COUNT(S.PRODUCT_ID) AS TOTAL_SALES,
	DENSE_RANK() OVER (PARTITION BY S.CUSTOMER_ID ORDER BY COUNT(S.PRODUCT_ID) DESC) AS RANKING
	FROM SALES S
JOIN MENU M
ON S.PRODUCT_ID = M.PRODUCT_ID
GROUP BY S.CUSTOMER_ID, S.PRODUCT_ID, M.PRODUCT_NAME
) AS SQ
WHERE RANKING = 1
ORDER BY CUSTOMER_ID

-- 6)Which item was purchased first by the customer after they became a member?

WITH FIRST_PURCHASE AS
(SELECT
	S.CUSTOMER_ID,
	S.ORDER_DATE,
	ME.JOIN_DATE,
	S.PRODUCT_ID,
	M.PRODUCT_NAME,
	DENSE_RANK() OVER(PARTITION BY S.CUSTOMER_ID ORDER BY S.ORDER_DATE) AS RANKING
FROM 
SALES S
JOIN MEMBERS ME
ON S.CUSTOMER_ID = ME.CUSTOMER_ID
JOIN MENU M
ON S.PRODUCT_ID = M.PRODUCT_ID
WHERE ORDER_DATE >= JOIN_DATE)
SELECT 
	CUSTOMER_ID,
	JOIN_DATE, 
	PRODUCT_NAME
FROM FIRST_PURCHASE
WHERE RANKING = 1

-- 7) Which item was purchased just before the customer became a member?

WITH FIRST_PURCHASE AS
(SELECT
	S.CUSTOMER_ID,
	S.ORDER_DATE,
	ME.JOIN_DATE,
	S.PRODUCT_ID,
	M.PRODUCT_NAME,
	DENSE_RANK() OVER(PARTITION BY S.CUSTOMER_ID ORDER BY S.ORDER_DATE) AS RANKING
FROM 
SALES S
JOIN MEMBERS ME
ON S.CUSTOMER_ID = ME.CUSTOMER_ID
JOIN MENU M
ON S.PRODUCT_ID = M.PRODUCT_ID
WHERE ORDER_DATE < JOIN_DATE)
SELECT 
	CUSTOMER_ID,
	JOIN_DATE,
	ORDER_DATE,
	PRODUCT_NAME
FROM FIRST_PURCHASE
WHERE RANKING = 1

-- 8) What is the total items and amount spent for each member before they became a member?

SELECT 
	S.CUSTOMER_ID,
	COUNT(DISTINCT S.PRODUCT_ID) TOTAL_ITEMS,
	SUM(M.PRICE) AS AMOUNT_SPENT
FROM
SALES S
JOIN MENU M
ON S.PRODUCT_ID = M.PRODUCT_ID
JOIN MEMBERS ME
ON S.CUSTOMER_ID = ME.CUSTOMER_ID
WHERE ORDER_DATE < JOIN_DATE
GROUP BY S.CUSTOMER_ID

-- 9)If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT CUSTOMER_ID, SUM(POINTS) AS TOTAL_POINTS 
FROM 
(SELECT 
	S.CUSTOMER_ID,
	CASE 
		WHEN M.PRODUCT_ID = 1 THEN (M.PRICE)*20
		ELSE (M.PRICE)*10 
		END AS POINTS
FROM SALES S 
JOIN MENU M 
ON S.PRODUCT_ID = M.PRODUCT_ID) SQ
GROUP BY CUSTOMER_ID;


-- 10) In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

SELECT SQ.CUSTOMER_ID, SUM(SQ.POINTS) AS TOTAL_SCORE
FROM
(SELECT
	S.CUSTOMER_ID,
	ME.PRICE * 20 AS POINTS
FROM SALES S
JOIN MENU ME
ON S.PRODUCT_ID = ME.PRODUCT_ID
JOIN MEMBERS MB
ON S.CUSTOMER_ID = MB.CUSTOMER_ID
WHERE ORDER_DATE BETWEEN '2021-01-01' AND '2021-01-31') SQ
GROUP BY CUSTOMER_ID;
