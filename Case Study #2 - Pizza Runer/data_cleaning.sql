--DATA CLEANING, REMOVING AND UPDATED NULL OR EMPTY DATA FROM CUSTOMER_ORDERS_TABLE
SELECT *
FROM CUSTOMER_ORDERS
WHERE EXCLUSIONS = 'NULL'

SELECT *
FROM CUSTOMER_ORDERS
WHERE EXCLUSIONS = ' '

SELECT *
FROM CUSTOMER_ORDERS
WHERE EXTRAS = 'NULL'

SELECT *
FROM CUSTOMER_ORDERS
WHERE EXTRAS IS NULL

SELECT *
FROM CUSTOMER_ORDERS
WHERE EXTRAS = ' '

UPDATE CUSTOMER_ORDERS
SET EXCLUSIONS = 0
WHERE EXCLUSIONS = 'NULL'

UPDATE CUSTOMER_ORDERS
SET EXCLUSIONS = 0
WHERE EXCLUSIONS = ' '

UPDATE CUSTOMER_ORDERS
SET EXTRAS = 0
WHERE EXTRAS = 'NULL'


UPDATE CUSTOMER_ORDERS
SET EXTRAS = 0
WHERE EXTRAS IS NULL

UPDATE CUSTOMER_ORDERS
SET EXTRAS = 0
WHERE EXTRAS = ' '

--NOW, I VERIFY THERE'S NO EMPTY, NULL OR NAN VALUE. AS THIS IS SMALL DATASET, I DON'T NEET TO INCLUDE A WHERE CLAUSE.
SELECT *
FROM CUSTOMER_ORDERS;


--FOR TABLE RUNNERS_ORDERS I WILL CHANGE MY APPROACH AND EXECUTE ALL CHANGES AT ONCE USING AN UPDATE + CASE STATEMENT.
SELECT *
FROM RUNNER_ORDERS

UPDATE RUNNER_ORDERS
SET PICKUP_TIME = 
CASE
	WHEN PICKUP_TIME LIKE 'null' THEN ' '
	WHEN PICKUP_TIME IS NULL THEN ' '
	ELSE PICKUP_TIME
	END,
DISTANCE =
CASE
	WHEN DISTANCE LIKE 'null' THEN ' '
	WHEN DISTANCE IS NULL THEN ' '
	WHEN DISTANCE LIKE '%km' THEN TRIM('km' FROM DISTANCE)
	ELSE DISTANCE
	END,
DURATION =
CASE
	WHEN DURATION LIKE 'null' THEN ' '
	WHEN DURATION IS NULL THEN ' '
	WHEN DURATION LIKE '%mins' THEN TRIM('mins' FROM DURATION)
	WHEN DURATION LIKE '%minute' THEN TRIM('minute' FROM DURATION)
	WHEN DURATION LIKE '%minutes' THEN TRIM('minutes' FROM DURATION)
	ELSE DURATION
	END,
CANCELLATION =
CASE
	WHEN CANCELLATION LIKE 'null' THEN ' '
	WHEN CANCELLATION IS NULL THEN ' '
	ELSE CANCELLATION
	END;
	
--I USE THE FOLLOWING COMMAND TO FIND OUT THE COLUMNS TYPE (LET'S ASSUME I DIDN'T CREATE THE TABLE ON THE FIRST PLACE)

exec sp_help RUNNER_ORDERS

--UPDATING COLUMN TYPES IN ORDER TO HAVE PROPER DATA TYPE

ALTER TABLE RUNNER_ORDERS
ALTER COLUMN pickup_time DATETIME
ALTER COLUMN distance FLOAT
ALTER COLUMN duration INT