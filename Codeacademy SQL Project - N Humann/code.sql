CODEFLIX CHURN ANALYSIS
SQL FROM SCRATCH CAPSTONE
BY: NICK HUMANN

---

1) Take a look at the first 100 rows of data in the subscriptions table. How many different segments do you see?

-- CODE:
 SELECT *
 FROM subscriptions 
 LIMIT 100;

-- ANSWERS/COMMENTS:
There are 2 segments - 87 and 30. There are four columns - id, subscription_start, subscription_end, and segment. 


2) Determine the range of months of data provided. Which months will you be able to calculate churn for?

-- CODE:
 SELECT MIN(subscription_start),
 	MAX(subscription_start)
 FROM subscriptions;


-- ANSWERS/COMMENTS:
MIN(subscription_start) is 2016-12-01 and MAX(subscription_start) is 2017-03-30; therefore, will be calculating the churn for January, February, and March.

3) Create a temporary table of months.

-- CODE:
 WITH months AS 
 (SELECT
	'2017-01-01' AS first_day,
 	'2017-01-31' AS last_day
 UNION
 SELECT
 	'2017-02-01' AS first_day,
 	'2017-02-28' AS last_day
 UNION
 SELECT
 	'2017-03-01' AS first_day,
 	'2017-03-31' AS last_day),

4) Create a temporary table, cross_join, from subscriptions and your months. Be sure to SELECT every column.

-- CODE:
cross_join AS
(SELECT *
FROM subscriptions
CROSS JOIN months),

5 and 6) Create a temporary table, status, from the cross_join table you created. Table should contain: id, month (as an alias of first_day), is_active_87 and is_active_30. 6) Add an is_canceled_87 and an is_canceled_30 column to the status temporary table.


-- CODE:
status AS
(SELECT id,
	first_day AS month,
	CASE
	   WHEN (subscription_start < first_day)
 	      AND (
        	subscription_end > first_day
        	OR subscription_end IS NULL)
              AND (segment = 87)
           THEN 1
ELSE 0
END as is_active_87,
 	CASE
 	   WHEN(subscription_start < first_day)
 			AND (
        subscription_end > first_day
        OR subscription_end IS NULL)
      AND segment = 30
 			THEN 1
ELSE 0
END as is_active_30,
 	CASE
 	   WHEN (subscription_end BETWEEN first_day AND last_day)
 	      AND segment = 87
 	   THEN 1
ELSE 0
END as is_canceled_87,
 	CASE
 	   WHEN (subscription_end BETWEEN first_day AND last_day) 
 	      AND segment = 30
 	   THEN 1
ELSE 0
END as is_canceled_30
FROM cross_join),

7) Create a status_aggregate temporary table that is a SUM of the active and canceled subscriptions for each segment, for each month. Resulting columns should be: sum_active_87, sum_active_30, sum_canceled_87, and sum_canceled_30

-- CODE:
status_aggregate AS
(SELECT month,
 	SUM(is_active_87) AS sum_active_87,
 	SUM(is_active_30) AS sum_active_30,
 	SUM(is_canceled_87) AS sum_canceled_87,
 	SUM(is_canceled_30) AS sum_canceled_30
FROM status
GROUP BY month)

8) Calculate the churn rates for the two segments over the three month period. Which segment has a lower churn rate?

-- CODE:
SELECT month,
	1.0 * sum_canceled_87 / sum_active_87 AS churn_rate_87,
        1.0 * sum_canceled_30 / sum_active_30 AS churn_rate_30
FROM status_aggregate;

-- ANSWER:
Segment 30 has a lower churn rate (7.6% for January, 7.3% for February, and 11.7% for March; compared to Segment 87's 25.2% for January, 32.0% for February, and 48.6% for March).


BONUS: How would  you modify this code to support a large number of segments?
I would create a segments temporary table, similar to the months temporary table, that can be combined with the subscriptions table and then grouped by segments as well 


----------------------
ALL CODE IN ONE PLACE:
----------------------
WITH months AS 
 (SELECT
	'2017-01-01' AS first_day,
 	'2017-01-31' AS last_day
 UNION
 SELECT
 	'2017-02-01' AS first_day,
 	'2017-02-28' AS last_day
 UNION
 SELECT
 	'2017-03-01' AS first_day,
 	'2017-03-31' AS last_day),

cross_join AS
(SELECT *
FROM subscriptions
CROSS JOIN months),

status AS
(SELECT id,
	first_day AS month,
	CASE
	   WHEN (subscription_start < first_day)
 	      AND (
        	subscription_end > first_day
        	OR subscription_end IS NULL)
              AND (segment = 87)
           THEN 1
ELSE 0
END as is_active_87,
 	CASE
 	   WHEN(subscription_start < first_day)
 	      AND (
        	subscription_end > first_day
        	OR subscription_end IS NULL)
      	      AND segment = 30
 	   THEN 1
ELSE 0
END as is_active_30,
 	CASE
 	   WHEN (subscription_end BETWEEN first_day AND last_day)
 	      AND segment = 87
 	   THEN 1
ELSE 0
END as is_canceled_87,
 	CASE
 	   WHEN (subscription_end BETWEEN first_day AND last_day) 
 	      AND segment = 30
 	   THEN 1
ELSE 0
END as is_canceled_30
FROM cross_join),

status_aggregate AS
(SELECT month,
 	SUM(is_active_87) AS sum_active_87,
 	SUM(is_active_30) AS sum_active_30,
 	SUM(is_canceled_87) AS sum_canceled_87,
 	SUM(is_canceled_30) AS sum_canceled_30
FROM status
GROUP BY month)

SELECT month,
	1.0 * sum_canceled_87 / sum_active_87 AS churn_rate_87,
        1.0 * sum_canceled_30 / sum_active_30 AS churn_rate_30
FROM status_aggregate;
