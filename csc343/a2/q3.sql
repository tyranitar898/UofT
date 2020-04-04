-- Q3. North and South Connections

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO air_travel, public;
DROP TABLE IF EXISTS q3 CASCADE;

CREATE TABLE q3 (
    outbound VARCHAR(30),
    inbound VARCHAR(30),
    direct INT,
    one_con INT,
    two_con INT,
    earliest timestamp
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS all_airports CASCADE;
DROP VIEW IF EXISTS direct_flight CASCADE;
DROP VIEW IF EXISTS one_con CASCADE;
DROP VIEW IF EXISTS two_con CASCADE;
DROP VIEW IF EXISTS all_con CASCADE;


-- Define views for your intermediate steps here:
CREATE VIEW all_airports AS
SELECT a1.code    as a1_code,
       a1.city    as a1_city,
       a1.country as a1_country,
       a2.code    as a2_code,
       a2.city    as a2_city,
       a2.country as a2_country
FROM airport a1,
     airport a2
WHERE (a1.country = 'Canada' AND a2.country = 'USA')
   OR (a1.country = 'USA' AND a2.country = 'Canada');


CREATE VIEW direct_flight AS
SELECT a1_city, a2_city, s_arv
FROM all_airports
         JOIN flight ON outbound = a1_code AND inbound = a2_code
WHERE s_dep::date = '2020-04-30'
  AND s_arv::date = '2020-04-30';


CREATE VIEW one_con AS
SELECT a1_city, a2_city, f2.s_arv
FROM flight f1
         JOIN flight f2 ON f1.inbound = f2.outbound
         JOIN all_airports a
              ON f1.outbound = a.a1_code AND f2.inbound = a.a2_code
WHERE f2.s_dep - f1.s_arv > '00:30:00'
  AND f2.s_dep::date = '2020-04-30'
  AND f1.s_dep::date = '2020-04-30';


CREATE VIEW two_con AS
SELECT a1_city, a2_city, f3.s_arv
FROM flight f1
         JOIN flight f2 ON f1.inbound = f2.outbound
         JOIN flight f3 ON f2.inbound = f3.outbound
         JOIN all_airports ON f1.outbound = all_airports.a1_code AND
                              f3.inbound = all_airports.a2_code
WHERE f2.s_dep - f1.s_arv > '00:30:00'
  AND f3.s_dep - f2.s_arv > '00:30:00'
  AND f1.s_dep::date = '2020-04-30'
  AND f3.s_dep::date = '2020-04-30';


CREATE VIEW all_con AS
    (SELECT * FROM direct_flight)
    UNION ALL
    (SELECT * FROM one_con)
    UNION ALL
    (SELECT * FROM two_con);


-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q3
SELECT a1_city                     AS outbound,
       a2_city                     AS inbound,
       (SELECT count(*)
        FROM direct_flight
        WHERE a1_city = a.a1_city
          AND a2_city = a.a2_city) AS direct,
       (SELECT count(*)
        FROM one_con
        WHERE a1_city = a.a1_city
          AND a2_city = a.a2_city) AS one_con,
       (SELECT count(*)
        FROM two_con
        WHERE a1_city = a.a1_city
          AND a2_city = a.a2_city) AS two_con,
       (SELECT to_timestamp(min(extract(EPOCH FROM s_arv)))
        FROM all_con
        WHERE all_con.a1_city = a.a1_city
          AND all_con.a2_city = a.a2_city)
FROM all_airports a
GROUP BY a1_city, a2_city;
