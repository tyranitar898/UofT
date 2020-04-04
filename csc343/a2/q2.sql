-- Q2. Refunds!

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO air_travel, public;
DROP TABLE IF EXISTS q2 CASCADE;

CREATE TABLE q2
(
    airline    CHAR(2),
    name       VARCHAR(50),
    year       CHAR(4),
    seat_class seat_class,
    refund     REAL
);

-- Do this for each of the views that define your intermediate steps.
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS domestic_flight CASCADE;
DROP VIEW IF EXISTS international_flight CASCADE;
DROP VIEW IF EXISTS domestic_refund CASCADE;
DROP VIEW IF EXISTS international_refund CASCADE;
DROP VIEW IF EXISTS all_refunds CASCADE;


-- Define views for your intermediate steps here:
CREATE VIEW domestic_flight AS
SELECT id,
       code,
       name,
       extract(YEAR FROM s_dep) AS year,
       a.datetime - s_arv       AS a_delay,
       d.datetime - s_dep       AS d_delay
FROM flight
         JOIN airline ON flight.airline = code
         JOIN departure d ON flight.id = d.flight_id
         JOIN arrival a ON flight.id = a.flight_id
         NATURAL JOIN
     (SELECT *
      FROM (
               SELECT id, country
               FROM flight
                        JOIN airport a ON flight.inbound = a.code
           ) AS foo
      INTERSECT
      (
          SELECT id, country
          FROM flight
                   JOIN airport a ON flight.outbound = a.code
      )
     ) AS domestic;


CREATE VIEW international_flight AS
SELECT id,
       code,
       name,
       extract(YEAR FROM s_dep) AS year,
       a.datetime - s_arv       AS a_delay,
       d.datetime - s_dep       AS d_delay
FROM flight
         JOIN airline ON flight.airline = code
         JOIN departure d ON flight.id = d.flight_id
         JOIN arrival a ON flight.id = a.flight_id
         natural JOIN
     (SELECT *
      FROM (
               SELECT id, country
               FROM flight
                        JOIN airport a ON flight.inbound = a.code
           ) AS foo
          except (
               SELECT id, country
               FROM flight
                        JOIN airport a ON flight.outbound = a.code
           )
     ) AS international;


CREATE VIEW domestic_refund AS
SELECT f.id,
       code,
       name,
       seat_class,
       CASE
           WHEN '10:00:00' > d_delay AND d_delay >= '04:00:00' THEN price * 0.35
           WHEN d_delay >= '10:00:00' THEN price * 0.5
       END AS refund,
       year
FROM domestic_flight f
         JOIN booking b on f.id = b.flight_id;


CREATE VIEW international_refund AS
SELECT f.id,
       code,
       name,
       seat_class,
       CASE
           WHEN '12:00:00' > d_delay AND d_delay >= '07:00:00' THEN price * 0.35
           WHEN d_delay >= '12:00:00' THEN price * 0.5
       END AS refund,
       year
FROM international_flight f
         JOIN booking b on f.id = b.flight_id;


CREATE VIEW all_refunds AS
SELECT *
FROM (SELECT * FROM domestic_refund) as df4
UNION ALL
(SELECT * FROM international_refund);


-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q2
SELECT code AS airline, name, year, seat_class, sum(refund)
FROM all_refunds
group by year, code, name, seat_class;
