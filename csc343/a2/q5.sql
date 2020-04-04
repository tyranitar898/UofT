-- Q5. Flight Hopping

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO air_travel, public;
DROP TABLE IF EXISTS q5 CASCADE;

CREATE TABLE q5 (
	destination CHAR(3),
	num_flights INT
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS intermediate_step CASCADE;
DROP VIEW IF EXISTS day CASCADE;
DROP VIEW IF EXISTS n CASCADE;

CREATE VIEW day AS
SELECT day::date as day FROM q5_parameters;
-- can get the given date using: (SELECT day from day)

CREATE VIEW n AS
SELECT n FROM q5_parameters;
-- can get the given number of flights using: (SELECT n from n)

-- HINT: You can answer the question by writing one recursive query below, without any more views.
-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q5

WITH RECURSIVE hops AS (
    (SELECT inbound, s_arv, 1 AS n, outbound
     FROM flight JOIN (SELECT day from day) AS d ON flight.s_dep::date = day
     WHERE outbound = 'YYZ'
    )
    UNION ALL
    (SELECT flight.inbound, flight.s_arv, hops.n + 1, flight.outbound
     FROM flight JOIN hops ON hops.inbound = flight.outbound,
          (SELECT n FROM n) AS n
     WHERE flight.s_dep - hops.s_arv < '24:00:00' AND flight.s_dep > hops.s_arv
            AND hops.n <= n.n
           -- AND flight.inbound <> hops.outbound
    )
)

SELECT inbound AS destination, n AS num_flights
FROM hops;
