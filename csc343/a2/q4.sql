-- Q4. Plane Capacity Histogram

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO air_travel, public;
DROP TABLE IF EXISTS q4 CASCADE;

CREATE TABLE q4 (
	airline CHAR(2),
	tail_number CHAR(5),
	very_low INT,
	low INT,
	fair INT,
	normal INT,
	high INT
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS total_capacity CASCADE;
DROP VIEW IF EXISTS curr_capacity CASCADE;
DROP VIEW IF EXISTS capacity_category CASCADE;


-- Define views for your intermediate steps here:
CREATE VIEW total_capacity AS
SELECT id,
       p.airline,
       capacity_first + capacity_economy + capacity_business as capacity,
       tail_number
FROM plane p
         JOIN flight on flight.plane = p.tail_number;

CREATE VIEW curr_capacity AS
SELECT d.flight_id, count(*) as curr_count
FROM booking
         JOIN flight ON flight.id = booking.flight_id
         JOIN departure d ON d.flight_id = flight.id
GROUP BY flight.plane, d.flight_id;

CREATE VIEW capacity_category AS
SELECT id as flight_id,
       airline,
       tail_number,
       CASE
           WHEN 0 <= curr_count::DECIMAL / capacity and
                curr_count::DECIMAL / capacity < 0.20 THEN 'very_low'
           WHEN 0.20 <= curr_count::DECIMAL / capacity and
                curr_count::DECIMAL / capacity < 0.40 THEN 'low'
           WHEN 0.40 <= curr_count::DECIMAL / capacity and
                curr_count::DECIMAL / capacity < 0.60 THEN 'fair'
           WHEN 0.60 <= curr_count::DECIMAL / capacity and
                curr_count::DECIMAL / capacity < 0.80 THEN 'normal'
           WHEN 0.80 <= curr_count::DECIMAL / capacity THEN 'high'
       END as category
FROM total_capacity
         FULL OUTER JOIN curr_capacity ON flight_id = id;


-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q4
SELECT d.airline,
       d.tail_number,

       sum(CASE
               WHEN category = 'very_low' THEN 1
               ELSE 0
           END
           ) as very_low,

       sum(CASE
               WHEN category = 'low' THEN 1
               ELSE 0
           END
           ) as low,

       sum(CASE
               WHEN category = 'fair' THEN 1
               ELSE 0
           END
           ) as fair,

       sum(CASE
               WHEN category = 'normal' THEN 1
               ELSE 0
           END
           ) as normal,
       sum(CASE
               WHEN category = 'high' THEN 1
               ELSE 0
           END
           ) as high
FROM capacity_category d
GROUP BY airline, tail_number;
