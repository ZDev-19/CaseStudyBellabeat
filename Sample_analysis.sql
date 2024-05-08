/*Select DB*/
USE DMT_BB

SELECT	
  COLUMN_NAME,
  COUNT(TABLE_NAME) as #
FROM INFORMATION_SCHEMA.COLUMNS
GROUP BY COLUMN_NAME;

SELECT
 TABLE_NAME,
 SUM(CASE
	 WHEN COLUMN_NAME = 'Id' THEN 1
	 ELSE
	 0
	 END ) AS has_id_column
FROM INFORMATION_SCHEMA.COLUMNS
GROUP BY TABLE_NAME
ORDER BY TABLE_NAME ASC;

SELECT
 TABLE_NAME,
 SUM(CASE
	 WHEN data_type IN ('TIMESTAMP','DATETIME','DATETIME2','TIME','DATE') THEN 1
	 ELSE
	 0
	 END) AS has_time_info
FROM INFORMATION_SCHEMA.COLUMNS
GROUP BY TABLE_NAME
HAVING SUM(CASE
	 WHEN data_type IN ('TIMESTAMP','DATETIME','DATETIME2','TIME','DATE') THEN 1
	 ELSE
	 0
	 END) = 0;

SELECT
 CONCAT(TABLE_CATALOG,'.', TABLE_SCHEMA ,'.', TABLE_NAME) AS table_path,
 TABLE_NAME,
 COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE
	DATA_TYPE IN ('TIMESTAMP','DATETIME','DATETIME2','DATE');

SELECT
 TABLE_NAME,
 COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE
	LOWER(COLUMN_NAME) LIKE '%date%' OR
    LOWER(COLUMN_NAME) LIKE '%minute%' OR
    LOWER(COLUMN_NAME) LIKE '%daily%' OR
    LOWER(COLUMN_NAME) LIKE '%hourly%' OR
    LOWER(COLUMN_NAME) LIKE '%day%' OR
    LOWER(COLUMN_NAME) LIKE '%seconds%' OR
	LOWER(COLUMN_NAME) LIKE '%record%';


SELECT
	Id,
	sleep_start AS sleep_date,
	COUNT(LogId) AS number_naps,
	SUM(DATEPART(HOUR , time_sleeping)) as total_time_sleeping
FROM (
	SELECT
	 Id,
	 LogId,
	 MIN(CAST(Record AS DATE)) AS sleep_start,
	 MAX(CAST(Record AS DATE)) AS sleep_end,
	 CONVERT(TIME,DATEADD(SECOND,DATEDIFF(SECOND,MIN(Record),MAX(Record)),0)) as time_sleeping
	FROM
		 MinuteSleep
	WHERE
		Value = 1
	GROUP BY Id, LogId) sleep_table
WHERE
	sleep_start = sleep_end 
GROUP BY
	Id , sleep_start
ORDER BY
	 number_naps DESC;

/*Crear variables para regular hora*/
DECLARE 
	@MORNING_START NVARCHAR(12),
	@MORNING_END NVARCHAR(12),
	@AFTERNOON_END NVARCHAR(12),
	@EVENING_END NVARCHAR(12);

SET @MORNING_START = '06:00:00:000000';
SET @MORNING_END = '12:00:00:000000';
SET @AFTERNOON_END = '18:00:00:000000';
SET @EVENING_END = '21:00:00:000000';

WITH
user_dow_summary AS (
    SELECT
        Id,
        DATEPART(WEEKDAY, Record) AS dow_number,
        DATENAME(WEEKDAY, Record) AS day_of_week,
        CASE
            WHEN DATENAME(WEEKDAY, Record) IN ('Sunday', 'Saturday') THEN 'Weekend'
            WHEN DATENAME(WEEKDAY, Record) NOT IN ('Sunday', 'Saturday') THEN 'Weekday'
            ELSE 'ERROR'
        END AS part_of_week,
        CASE
            WHEN CAST(Record AS TIME) BETWEEN CAST(STUFF(@MORNING_START,9,1,'.') AS TIME) AND CAST(STUFF(@MORNING_END,9,1,'.') AS TIME) THEN 'Morning'
            WHEN CAST(Record AS TIME) BETWEEN CAST(STUFF(@MORNING_END,9,1,'.') AS TIME) AND CAST(STUFF(@AFTERNOON_END,9,1,'.') AS TIME) THEN 'Afternoon'
            WHEN CAST(Record AS TIME) BETWEEN CAST(STUFF(@AFTERNOON_END,9,1,'.') AS TIME) AND CAST(STUFF(@EVENING_END,9,1,'.') AS TIME) THEN 'Evening'
            WHEN CAST(Record AS TIME) >= CAST(STUFF(@EVENING_END,9,1,'.') AS TIME)
                 OR CAST(CAST(Record AS TIME) AS DATETIME) <= CAST(CAST(STUFF(@MORNING_START,9,1,'.') AS TIME) AS DATETIME) THEN 'Night'
            ELSE 'ERROR'
        END AS time_of_day,
        SUM(Total_Intensity) AS total_intensity,
        SUM(Avg_Intensity) AS total_average_intensity,
        AVG(Avg_Intensity) AS average_intensity,
        MAX(Avg_Intensity) AS max_intensity,
        MIN(Avg_Intensity) AS min_intensity
    FROM
        HourlyIntensities
    GROUP BY
        Id,
        DATEPART(WEEKDAY, Record),
        DATENAME(WEEKDAY, Record),
        CASE
            WHEN DATENAME(WEEKDAY, Record) IN ('Sunday', 'Saturday') THEN 'Weekend'
            WHEN DATENAME(WEEKDAY, Record) NOT IN ('Sunday', 'Saturday') THEN 'Weekday'
            ELSE 'ERROR'
        END,
        CASE
            WHEN CAST(Record AS TIME) BETWEEN CAST(STUFF(@MORNING_START,9,1,'.') AS TIME) AND CAST(STUFF(@MORNING_END,9,1,'.') AS TIME) THEN 'Morning'
            WHEN CAST(Record AS TIME) BETWEEN CAST(STUFF(@MORNING_END,9,1,'.') AS TIME) AND CAST(STUFF(@AFTERNOON_END,9,1,'.') AS TIME) THEN 'Afternoon'
            WHEN CAST(Record AS TIME) BETWEEN CAST(STUFF(@AFTERNOON_END,9,1,'.') AS TIME) AND CAST(STUFF(@EVENING_END,9,1,'.') AS TIME) THEN 'Evening'
            WHEN CAST(Record AS TIME) >= CAST(STUFF(@EVENING_END,9,1,'.') AS TIME)
                 OR CAST(CAST(Record AS TIME) AS DATETIME) <= CAST(CAST(STUFF(@MORNING_START,9,1,'.') AS TIME) AS DATETIME) THEN 'Night'
            ELSE 'ERROR'
        END
),

intensity_deciles AS (
    SELECT
        DISTINCT dow_number,
        part_of_week,
        day_of_week,
        time_of_day,
        ROUND(PERCENTILE_CONT(0.1) WITHIN GROUP (ORDER BY total_intensity) OVER (PARTITION BY dow_number, part_of_week, day_of_week, time_of_day), 4) AS total_intensity_first_decile,
        ROUND(PERCENTILE_CONT(0.2) WITHIN GROUP (ORDER BY total_intensity) OVER (PARTITION BY dow_number, part_of_week, day_of_week, time_of_day), 4) AS total_intensity_second_decile,
        ROUND(PERCENTILE_CONT(0.3) WITHIN GROUP (ORDER BY total_intensity) OVER (PARTITION BY dow_number, part_of_week, day_of_week, time_of_day), 4) AS total_intensity_third_decile,
        ROUND(PERCENTILE_CONT(0.4) WITHIN GROUP (ORDER BY total_intensity) OVER (PARTITION BY dow_number, part_of_week, day_of_week, time_of_day), 4) AS total_intensity_fourth_decile,
        ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_intensity) OVER (PARTITION BY dow_number, part_of_week, day_of_week, time_of_day), 4) AS total_intensity_fifth_decile,
		ROUND(PERCENTILE_CONT(0.6) WITHIN GROUP (ORDER BY total_intensity) OVER (PARTITION BY dow_number, part_of_week, day_of_week, time_of_day), 4) AS total_intensity_sixth_decile,
        ROUND(PERCENTILE_CONT(0.7) WITHIN GROUP (ORDER BY total_intensity) OVER (PARTITION BY dow_number, part_of_week, day_of_week, time_of_day), 4) AS total_intensity_seventh_decile,
        ROUND(PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY total_intensity) OVER (PARTITION BY dow_number, part_of_week, day_of_week, time_of_day), 4) AS total_intensity_eighth_decile,
        ROUND(PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY total_intensity) OVER (PARTITION BY dow_number, part_of_week, day_of_week, time_of_day), 4) AS total_intensity_ninth_decile
    FROM
        user_dow_summary
),

basic_summary AS (
    SELECT
        part_of_week,
        day_of_week,
        time_of_day,
        SUM(total_intensity) AS total_total_intensity,
        AVG(total_intensity) AS average_total_intensity,
        SUM(total_average_intensity) AS total_total_average_intensity,
        AVG(total_average_intensity) AS average_total_average_intensity,
        SUM(average_intensity) AS total_average_intensity,
        AVG(average_intensity) AS average_average_intensity,
        AVG(max_intensity) AS average_max_intensity,
        AVG(min_intensity) AS average_min_intensity
    FROM
        user_dow_summary
    GROUP BY
        part_of_week,
        day_of_week,
        time_of_day
)


SELECT
	*
FROM
    basic_summary
LEFT JOIN
    intensity_deciles
ON
    basic_summary.part_of_week = intensity_deciles.part_of_week
    AND basic_summary.day_of_week = intensity_deciles.day_of_week
    AND basic_summary.time_of_day = intensity_deciles.time_of_day

	
	