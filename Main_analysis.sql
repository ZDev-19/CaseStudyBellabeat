/*Use DB*/
USE DMT_BB

/* Execute just the first time
UPDATE HourlyIntensities SET Record = CONVERT(datetime2,REPLACE(Record,'"',''))
UPDATE MinuteCalories SET Record = CONVERT(datetime2,REPLACE(Record,'"',''))
UPDATE WeightInfo SET Record = CONVERT(datetime2,REPLACE(Record,'"',''))
UPDATE DailyActivity SET ActivityDate = CONVERT(date,REPLACE(ActivityDate,'"',''))

ALTER TABLE HourlyIntensities ALTER COLUMN Record datetime2;
ALTER TABLE MinuteCalories ALTER COLUMN Record datetime2;
ALTER TABLE WeightInfo ALTER COLUMN Record datetime2;
ALTER TABLE DailyActivity ALTER COLUMN ActivityDate date;
*/

/*Tables preview*/
SELECT 
 *
FROM
 DailyActivity

SELECT 
 *
FROM
 HeartrateSeconds

SELECT
 *
FROM
 HourlyCalories

SELECT
 *
FROM
 HourlyIntensities

SELECT
 * 
FROM
 HourlySteps

SELECT
 * 
FROM
 MinuteCalories

SELECT
 * 
FROM
 MinuteIntensities

SELECT
 *
FROM
 MinuteMET

SELECT
 * 
FROM
 MinuteSteps

SELECT
 * 
FROM
 MinuteSleep

SELECT
 * 
FROM
 WeightInfo

/*Heartrate analysis*/

/*Avg Heartrate per user , seems most of them are healthy*/
SELECT
	Id,
	AVG(Heartrate) as Avg_Heartrate
FROM HeartrateSeconds
GROUP BY Id

/*Classification*/

SELECT
	Id,
	AVG(Heartrate) as AVG_Heartrate,
	CASE
		WHEN AVG(Heartrate) < 60 THEN 'Low Heartrate'
		WHEN AVG(Heartrate) BETWEEN 60 AND 100 THEN 'Normal Heartrate'
		WHEN AVG(Heartrate) > 100 THEN 'High Heartrate'
		ELSE 'ERROR'
	END AS Class_by_Heartrate
FROM HeartrateSeconds
GROUP BY Id
ORDER BY AVG(Heartrate)
/*Seems according to Health standarts all fit_watch users present normal adult conditions for heartrate*/

/*We would like to see the tendency over days*/

SELECT
    Id,
    CAST(Record AS DATE) AS heartrate_day,
    AVG(Heartrate) AS avg_heartrate_per_day
FROM
    HeartrateSeconds
GROUP BY
    Id,
    CAST(Record AS DATE)
ORDER BY Id , CAST(Record AS DATE)

/*Summary of heartrate over different time periods*/

/*Declare some time variables for all day periods*/
DECLARE 
	@MORNING_START NVARCHAR(12),
	@MORNING_END NVARCHAR(12),
	@AFTERNOON_END NVARCHAR(12),
	@EVENING_END NVARCHAR(12);

SET @MORNING_START = '06:00:00:000000';
SET @MORNING_END = '12:00:00:000000';
SET @AFTERNOON_END = '18:00:00:000000';
SET @EVENING_END = '21:00:00:000000';

/*CTE for summary creation*/
WITH
dow_heartrate_summary AS (
	SELECT
		Id,
		DATEPART(WEEKDAY,Record) as dow_number,
		DATENAME(WEEKDAY,Record) as day_of_week,
		CASE
            WHEN DATENAME(WEEKDAY, Record) IN ('Domingo', 'Sábado') THEN 'Weekend'
            WHEN DATENAME(WEEKDAY, Record) NOT IN ('Domingo', 'Sábado') THEN 'Weekday'
            ELSE 'ERROR'
        END AS part_of_week,
		CASE
            WHEN CAST(Record AS TIME) BETWEEN CAST(STUFF(@MORNING_START,9,1,'.') AS TIME) AND CAST(STUFF(@MORNING_END,9,1,'.') AS TIME) THEN 'Morning'
            WHEN CAST(Record AS TIME) BETWEEN CAST(STUFF(@MORNING_END,9,1,'.') AS TIME) AND CAST(STUFF(@AFTERNOON_END,9,1,'.') AS TIME) THEN 'Afternoon'
            WHEN CAST(Record AS TIME) BETWEEN CAST(STUFF(@AFTERNOON_END,9,1,'.') AS TIME) AND CAST(STUFF(@EVENING_END,9,1,'.') AS TIME) THEN 'Evening'
            WHEN CAST(Record AS TIME) >= CAST(STUFF(@EVENING_END,9,1,'.') AS TIME)
                 OR CAST(CAST(Record AS TIME) AS DATETIME) <= CAST(CAST(STUFF(@MORNING_START,9,1,'.') AS TIME) AS DATETIME) THEN 'Night'
            ELSE 'ERROR'
        END AS time_of_day , 
		AVG(Heartrate) as AVG_Heartrate_per_period
	FROM HeartrateSeconds
	GROUP BY 
	Id,
	DATEPART(WEEKDAY,Record),
		DATENAME(WEEKDAY,Record),
		CASE
            WHEN DATENAME(WEEKDAY, Record) IN ('Domingo', 'Sábado') THEN 'Weekend'
            WHEN DATENAME(WEEKDAY, Record) NOT IN ('Domingo', 'Sábado') THEN 'Weekday'
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
)
/*Insert into temp Table*/
SELECT *
INTO #dow_summary_for_heartrate
FROM dow_heartrate_summary

SELECT * FROM #dow_summary_for_heartrate

/*Look into heartrate in periods*/
SELECT
	part_of_week,
	day_of_week,
	time_of_day,
	AVG(AVG_Heartrate_per_period) AS avg_in_period
FROM #dow_summary_for_heartrate
GROUP BY
	part_of_week,
	day_of_week,
	time_of_day
ORDER BY day_of_week

/*Looking AVG in all days*/
SELECT
	day_of_week,
	AVG(AVG_Heartrate_per_period) AS avg_in_day
FROM 
	#dow_summary_for_heartrate
GROUP BY
	day_of_week
/*ORDER BY
	avg_in_day DESC
OFFSET 0 ROWS FETCH FIRST 1 ROW ONLY For max avg_retrieve = Sunday*/

/*Looking to Average in day periods*/
SELECT
	time_of_day,
	AVG(AVG_Heartrate_per_period) AS avg_per_time
FROM 
	#dow_summary_for_heartrate
GROUP BY
	time_of_day

/*Looking to Average in weekday/end*/
SELECT
	part_of_week,
	AVG(AVG_Heartrate_per_period) AS avg_per_week_part
FROM 
	#dow_summary_for_heartrate
GROUP BY
	part_of_week

/*HourlyCalories analysis*/

SELECT 
DISTINCT
	Id
FROM
	HourlyCalories

SELECT * FROM HourlyCalories

/*Total per user in all period*/
 

/*User class by calories consume per day*/
SELECT
	Id,
	CAST(RECORD AS Date) as fecha_cal,
	SUM(Calories) as calorias_por_dia,
	CASE
		WHEN SUM(Calories) < 2000 THEN 'Quema baja de calorias'
		WHEN SUM(Calories) BETWEEN 2000 AND 3000 THEN 'Quema moderada de calorias'
		WHEN SUM(Calories) > 3000 THEN 'Quema alta de calorias'
	END AS clasificacion
FROM
	HourlyCalories
GROUP  BY Id, CAST(Record as DATE)
ORDER BY Id , CAST(Record as DATE)

/*
CREATE TABLE Clasificaciones(
	Id INT IDENTITY(1,1) PRIMARY KEY  NOT NULL,
	Clasificacion NVARCHAR(50)
)

INSERT INTO Clasificaciones VALUES ('Bajo en calorias')
INSERT INTO Clasificaciones VALUES ('Moderado en calorias')
INSERT INTO Clasificaciones VALUES ('Alto en calorias')

SELECT
	daily_cal_table.Id,
	COUNT(*) as number_class,
	c.Clasificacion as clasificacion
FROM (
	SELECT
		Id,
		CAST(RECORD AS Date) as fecha_cal,
		SUM(Calories) as calorias_por_dia,
		CASE
			WHEN SUM(Calories) < 1200 THEN 'Bajo en calorias'
			WHEN SUM(Calories) BETWEEN 1200 AND 2400 THEN 'Moderado en calorias'
			WHEN SUM(Calories) > 2400 THEN 'Alto en calorias'
		END AS clasificacion
	FROM
		HourlyCalories
	GROUP  BY Id, CAST(Record as DATE)
) daily_cal_table
JOIN Clasificaciones c ON daily_cal_table.clasificacion = c.Clasificacion
GROUP BY daily_cal_table.Id,c.Clasificacion
ORDER BY daily_cal_table.Id

Este es otro metodo de solucion*/

/*Class number by user*/
SELECT
	Id,	
	clasificacion,
	COUNT(*) as number_class
INTO #user_cal_classification
FROM (
	SELECT
		Id,
		CAST(RECORD AS Date) as fecha_cal,
		SUM(Calories) as calorias_por_dia,
		CASE
			WHEN SUM(Calories) < 2000 THEN 'Quema baja de calorias'
			WHEN SUM(Calories) BETWEEN 2000 AND 3000 THEN 'Quema moderada de calorias'
			WHEN SUM(Calories) > 3000 THEN 'Quema alta de calorias'
		END AS clasificacion
	FROM
		HourlyCalories
	GROUP  BY Id, CAST(Record as DATE)
) daily_cal_table
GROUP BY Id, clasificacion

SELECT
 *
FROM 
#user_cal_classification
ORDER BY Id

/*Retrieve max class frequency*/
SELECT 
	Id,
	clasificacion,
	number_class
FROM (
	SELECT
		Id,
		clasificacion,
		number_class,
		ROW_NUMBER() OVER (PARTITION BY Id ORDER BY number_class DESC) AS max_class
	FROM
		#user_cal_classification
) freq_table
WHERE max_class = 1
ORDER BY Id

/*Retrieve the number of max frequencies per class*/
SELECT 
	clasificacion,
	COUNT(*) as class_freq
FROM (
	SELECT
		Id,
		clasificacion,
		number_class,
		ROW_NUMBER() OVER (PARTITION BY Id ORDER BY number_class DESC) AS max_class
	FROM
		#user_cal_classification
) freq_table
WHERE max_class = 1
GROUP BY clasificacion

/* This is an individual analysis per class
SELECT 
	Id,
	number_class
FROM
	#user_cal_classification
WHERE clasificacion = 'Alto en calorias'
ORDER BY Id , number_class DESC

SELECT 
	Id,
	number_class
FROM
	#user_cal_classification
WHERE clasificacion = 'Bajo en calorias'
ORDER BY Id , number_class DESC
	
SELECT 
	Id,
	number_class
FROM
	#user_cal_classification
WHERE clasificacion = 'Moderado en calorias'
ORDER BY Id , number_class DESC
*/

/*MinuteSleep analysis*/
SELECT DISTINCT 
 Id
FROM 
MinuteSleep

SELECT 
 *
FROM
MinuteSleep

/*Number of naps per user and date*/
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
	 Id , sleep_date , number_naps DESC;

/*HourlyIntensities analysis*/
SELECT
 *
FROM
HourlyIntensities

/*Create a basic summary for intensity*/
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
            WHEN DATENAME(WEEKDAY, Record) IN ('Domingo', 'Sábado') THEN 'Weekend'
            WHEN DATENAME(WEEKDAY, Record) NOT IN ('Domingo', 'Sábado') THEN 'Weekday'
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
            WHEN DATENAME(WEEKDAY, Record) IN ('Domingo', 'Sábado') THEN 'Weekend'
            WHEN DATENAME(WEEKDAY, Record) NOT IN ('Domingo', 'Sábado') THEN 'Weekday'
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

basic_summary AS (
    SELECT
        part_of_week,
        day_of_week,
        time_of_day,
        SUM(total_intensity) AS total_total_intensity,
        AVG(total_intensity) AS average_total_intensity,
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

/*Basic summary creation*/
SELECT *
INTO #intensity_summary
FROM basic_summary
 
SELECT
 *
FROM
 #intensity_summary



