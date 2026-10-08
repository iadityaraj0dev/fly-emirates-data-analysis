CREATE OR REPLACE VIEW flight_analysis AS
SELECT
    f.*,
    al.airline AS airline_name,
    ao.airport AS origin_airport_name,
    ad.airport AS destination_airport_name,
    ao.city AS origin_city,
    ad.city AS destination_city,
    ao.latitude AS origin_latitude,
    ao.longitude AS origin_longitude,
    ad.latitude AS dest_latitude,
    ad.longitude AS dest_longitude
FROM flights f
LEFT JOIN airlines al
    ON f.airline = al.iata_code
LEFT JOIN airport ao
    ON f.origin_airport = ao.iata_code
LEFT JOIN airport ad
    ON f.destination_airport = ad.iata_code;

select	count(*) from flight_analysis;

--Total Flights.
SELECT COUNT(*) AS total_flights
FROM flight_analysis;
--Total Cancellation.
SELECT COUNT (*) AS cancelled_flights FROM flight_analysis
WHERE cancelled = 1;
--Cancellation by reason.
SELECT
    cancellation_reason_desc,
    COUNT(*) AS total_cancellations
FROM flight_analysis
WHERE cancelled = 1
GROUP BY cancellation_reason_desc
ORDER BY total_cancellations ;
--Diverted flights.
SELECT COUNT(*) AS diverted_flights
FROM flight_analysis
WHERE diverted = 1;
--Basics Statistics for arrival delays.
SELECT
ROUND(AVG(arrival_delay),2) AS avg_arrival_delays ,
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY arrival_delay) AS median_arrival_delay,
    MIN(arrival_delay) AS min_arrival_delay,
    MAX(arrival_delay) AS max_arrival_delay FROM flight_analysis 
where cancelled = 0;
--Basics Statistics for departure delays.
SELECT
ROUND(AVG(departure_delay),2) AS avg_departure_delays,
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY departure_delay) AS median_departure_delay,
MIN(departure_delay) AS min_departure_delay,
MAX(departure_delay) AS max_departure_delay FROM flight_analysis
WHERE cancelled=0;
--Distribution of Delays.
SELECT
    SUM(airline_delay) AS airline_delay,
    SUM(weather_delay) AS weather_delay,
    SUM(air_system_delay) AS nas_delay,
    SUM(late_aircraft_delay) AS late_aircraft_delay,
    SUM(security_delay) AS security_delay
FROM flight_analysis
WHERE cancelled = 0;

--KPI

--On Time Performance (OTP).
SELECT
ROUND(
(
SUM(CASE
WHEN arrival_delay <= 15 AND cancelled = 0
THEN 1 ELSE 0
END)::decimal
/
SUM(CASE WHEN cancelled = 0 THEN 1 ELSE 0 END)
)*100,2) AS otp_rate
FROM flight_analysis ;

--Average Arrival/Departure Delay (in minutes).
SELECT
ROUND(AVG(arrival_delay),2) AS avg_arrival_delay_minutes,
ROUND(AVG(departure_delay),2) AS avg_departure_delay_minutes
FROM flight_analysis
WHERE cancelled = 0;
--Cancellation Rate.
SELECT 
ROUND((SUM(cancelled)::decimal / count(*))*100 ,2 ) 
AS cancellation_rate FROM flight_analysis;
--Percentage contribution of each delay type.
--Departure delay contribution 
SELECT
ROUND(SUM(airline_delay) * 100.0 / 
(SUM(airline_delay) + SUM(weather_delay) + SUM(air_system_delay) + SUM(late_aircraft_delay) + SUM(security_delay)),2)
AS airline_delay_percent,

ROUND(SUM(weather_delay) * 100.0 / 
(SUM(airline_delay) + SUM(weather_delay) + SUM(air_system_delay) + SUM(late_aircraft_delay) + SUM(security_delay)),2)
AS weather_delay_percent,

ROUND(SUM(air_system_delay) * 100.0 / 
(SUM(airline_delay) + SUM(weather_delay) + SUM(air_system_delay) + SUM(late_aircraft_delay) + SUM(security_delay)),2)
AS nas_delay_percent,

ROUND(SUM(late_aircraft_delay) * 100.0 / 
(SUM(airline_delay) + SUM(weather_delay) + SUM(air_system_delay) + SUM(late_aircraft_delay) + SUM(security_delay)),2)
AS late_aircraft_delay_percent,

ROUND(SUM(security_delay) * 100.0 / 
(SUM(airline_delay) + SUM(weather_delay) + SUM(air_system_delay) + SUM(late_aircraft_delay) + SUM(security_delay)),2)
AS security_delay_percent

FROM flight_analysis
WHERE cancelled = 0;

--KPI by Airline
SELECT
    airline_name,
    COUNT(*) AS total_flights,
    ROUND(AVG(arrival_delay),2) AS avg_arrival_delay,
    ROUND(AVG(departure_delay),2) AS avg_departure_delay,
    ROUND((SUM(cancelled)::decimal / COUNT(*)) * 100,2) AS cancellation_rate
FROM flight_analysis
GROUP BY airline_name
ORDER BY avg_arrival_delay DESC;

--KPI by Origin Airport
SELECT
    origin_airport_name,
    COUNT(*) AS total_flights,
    ROUND(AVG(departure_delay),2) AS avg_departure_delay
FROM flight_analysis
WHERE cancelled = 0
GROUP BY origin_airport_name
ORDER BY avg_departure_delay DESC
LIMIT 10;

--KPI by Destination Airport

SELECT 
destination_airport_name,
COUNT(*) AS total_flights,
ROUND(AVG(arrival_delay),2) AS avg_arrival_delay
FROM flight_analysis
where cancelled =0
GROUP BY destination_airport_name
ORDER BY avg_arrival_delay DESC
LIMIT 10;

--KPI by Month

SELECT 
EXTRACT(MONTH from flight_date) AS month,
COUNT(*) AS total_flights,
ROUND(AVG(arrival_delay),2) AS avg_arrival_delay
FROM flight_analysis
WHERE cancelled = 0
GROUP BY flight_date
ORDER BY month;

--KPI by DAY OF WEEK

SELECT day_of_week ,
COUNT(*) AS total_flights,
ROUND(AVG(arrival_delay),2) AS avg_arrival_delay
FROM flight_analysis
WHERE cancelled = 0
GROUP BY day_of_week
ORDER BY day_of_week;

--KPI by Time of Day 

SELECT dep_hour,
COUNT(*) AS total_flights,
ROUND(AVG(arrival_delay),2) AS avg_arrival_delay
FROM flight_analysis
WHERE cancelled = 0
GROUP BY dep_hour
ORDER BY dep_hour;

