DROP TABLE IF EXISTS flights;
CREATE TABLE flights (
YEAR INT,
MONTH INT,
DAY	INT,
DAY_OF_WEEK INT,
AIRLINE	TEXT,
FLIGHT_NUMBER	INT,
TAIL_NUMBER	TEXT,
ORIGIN_AIRPORT	TEXT,
DESTINATION_AIRPORT TEXT,	
SCHEDULED_DEPARTURE	INT,
DEPARTURE_TIME	INT,
DEPARTURE_DELAY INT,
TAXI_OUT	INT,
WHEELS_OFF	INT,
SCHEDULED_TIME INT,
ELAPSED_TIME INT,	
AIR_TIME	INT,
DISTANCE	INT,
WHEELS_ON	INT,
TAXI_IN	INT ,
SCHEDULED_ARRIVAL	INT,
ARRIVAL_TIME INT,
ARRIVAL_DELAY INT,
DIVERTED	INT,
CANCELLED	INT,
CANCELLATION_REASON	TEXT,
AIR_SYSTEM_DELAY INT,
SECURITY_DELAY	INT,
AIRLINE_DELAY	INT,
LATE_AIRCRAFT_DELAY INT,
WEATHER_DELAY INT
);
SELECT COUNT(*)
FROM information_schema.columns
WHERE table_name = 'flights';
COPY flights
FROM 'D:/Aviation DA/flights.csv'
DELIMITER ','
CSV HEADER;
SELECT * from flights;
SELECT count(*) from flights where cancelled =1;
select count(*) from flights where arrival_delay is NULL ;

--Time/Date Handling

ALTER TABLE flights ADD COLUMN flight_date DATE ;
UPDATE flights 
SET flight_date = MAKE_DATE(year,month,day);

--Schedule_Dep_Timestamp

ALTER TABLE flights ADD COLUMN Scheduled_dep_timestamp TIMESTAMP;
UPDATE flights
SET scheduled_dep_timestamp =
    MAKE_TIMESTAMP(
        year,
        month,
        day,
        scheduled_departure / 100,
        scheduled_departure % 100,
        0
    );
	
--Cancellation Reason

ALTER TABLE flights ADD COLUMN cancellation_reason_desc VARCHAR(50);
UPDATE flights
SET cancellation_reason_desc =
    CASE
        WHEN cancellation_reason = 'A' THEN 'Airline/Carrier'
        WHEN cancellation_reason = 'B' THEN 'Weather'
        WHEN cancellation_reason = 'C' THEN 'NAS'
        WHEN cancellation_reason = 'D' THEN 'Security'
        ELSE NULL
    END;
	
