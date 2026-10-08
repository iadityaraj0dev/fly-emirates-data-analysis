DROP TABLE IF EXISTS airlines;
CREATE TABLE airlines(
IATA_CODE TEXT,
AIRLINE TEXT
);
COPY flights
FROM 'D:/Aviation DA/fl.csv'
DELIMITER ','
CSV HEADER;
select * from airlines;
