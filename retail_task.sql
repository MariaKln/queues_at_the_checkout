-- определить периоды, когда на кассах есть очередь.

WITH store_table_1 AS (
	SELECT
	store_id,
	checkout_id,
	to_char(start_operation_dt, 'Day') AS day_operation, 
	extract(HOUR FROM start_operation_dt) AS hour_operation,
	start_operation_dt,
	end_operation_dt,
	EXTRACT(EPOCH FROM (start_operation_dt::timestamp - (LAG(end_operation_dt) OVER(PARTITION BY checkout_id ORDER BY start_operation_dt))::timestamp )) AS time_diff,
	ROW_NUMBER() OVER(PARTITION BY checkout_id ORDER BY start_operation_dt) AS number_op
	FROM
		(SELECT 
		scq.checks_number,
		ss.store_id,
		scq.employees_id,
		scq.quantity,
		scq.selling_price,
		scq.checkout_id1 AS checkout_id,
		scq.start_operation_dt::timestamp AS start_operation_dt,
		scq.end_operation_dt::timestamp AS end_operation_dt
		FROM store_checkout_queues AS scq LEFT JOIN store_stores AS ss ON scq.store_uuid = ss.store_uuid
		WHERE ss.store_id = 98451680
		) AS t1
	ORDER BY store_id, checkout_id, start_operation_dt
)

,store_table_2 AS (
	SELECT
	store_id,
	checkout_id,
	to_char(start_operation_dt, 'Day') AS day_operation, 
	extract(HOUR FROM start_operation_dt) AS hour_operation,
	start_operation_dt,
	end_operation_dt,
	EXTRACT(EPOCH FROM (start_operation_dt::timestamp - (LAG(end_operation_dt) OVER(PARTITION BY checkout_id ORDER BY start_operation_dt))::timestamp )) AS time_diff,
	ROW_NUMBER() OVER(PARTITION BY checkout_id ORDER BY start_operation_dt) AS number_op
	FROM
		(SELECT 
		scq.checks_number,
		ss.store_id,
		scq.employees_id,
		scq.quantity,
		scq.selling_price,
		scq.checkout_id1 AS checkout_id,
		scq.start_operation_dt::timestamp AS start_operation_dt,
		scq.end_operation_dt::timestamp AS end_operation_dt
		FROM store_checkout_queues AS scq LEFT JOIN store_stores AS ss ON scq.store_uuid = ss.store_uuid
		WHERE ss.store_id = 12864064
		) AS t2
	ORDER BY store_id, checkout_id, start_operation_dt
)

,groups_queue_1_store AS (
	SELECT *,
	CASE
		WHEN time_diff < 300 THEN 1
		ELSE 0
	END AS flag,
	SUM(CASE 
	    	WHEN COALESCE(time_diff, 300) >= 300 THEN 1 
	        ELSE 0 
	    END) OVER(PARTITION BY checkout_id ORDER BY start_operation_dt) AS flag_group_id
	FROM store_table_1
	ORDER BY store_id, checkout_id, start_operation_dt
)

,groups_queue_2_store AS (
	SELECT *,
	CASE
		WHEN time_diff < 300 THEN 1
		ELSE 0
	END AS flag,
	SUM(CASE 
	    	WHEN COALESCE(time_diff, 300) >= 300 THEN 1 
	        ELSE 0 
	    END) OVER(PARTITION BY checkout_id ORDER BY start_operation_dt) AS flag_group_id
	FROM store_table_2
	ORDER BY store_id, checkout_id, start_operation_dt
)

, full_info_1_store AS (
	SELECT
	store_id,
	checkout_id,
	day_operation,
	hour_operation,
	flag_group_id,
	COUNT(*) AS cnt_customers,
	MIN(start_operation_dt) AS start_time,
	MAX(end_operation_dt) AS end_time
	FROM groups_queue_1_store
	WHERE flag = 1
	GROUP BY store_id, checkout_id, flag_group_id, day_operation, hour_operation
	HAVING COUNT(*) > 4
)

, full_info_2_store AS (
	SELECT
	store_id,
	checkout_id,
	day_operation,
	hour_operation,
	flag_group_id,
	COUNT(*) AS cnt_customers,
	MIN(start_operation_dt) AS start_time,
	MAX(end_operation_dt) AS end_time
	FROM groups_queue_2_store
	WHERE flag = 1
	GROUP BY store_id, checkout_id, flag_group_id, day_operation, hour_operation
	HAVING COUNT(*) > 4
)

SELECT 
store_id,
day_operation,
hour_operation,
cnt_customers,
start_time,
end_time
FROM full_info_1_store
UNION
SELECT 
store_id,
day_operation,
hour_operation,
cnt_customers,
start_time,
end_time
FROM full_info_2_store