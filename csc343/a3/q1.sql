-- 1. For each dive category from open water, cave, or beyond 30 meters,
-- list the number of dive sites that provide that dive type and have 
-- at least one monitor with booking privileges with them who will supervise
-- groups for that type of dive.

DROP VIEW IF EXISTS open_water_count CASCADE;
DROP VIEW IF EXISTS cave_dive_count CASCADE;
DROP VIEW IF EXISTS deep_dive_count CASCADE;

-- Intermediate steps
CREATE VIEW open_water_count AS
SELECT count(DiveSite.name) AS num_open_water
FROM DiveSite
WHERE DiveSite.open_limit > 0
  AND EXISTS
    (SELECT MonitorSite.monitor FROM MonitorSite WHERE MonitorSite.dive_site = DiveSite.name);

CREATE VIEW cave_dive_count AS
SELECT count(DiveSite.name) AS num_cave_dive
FROM DiveSite
WHERE DiveSite.cave_limit > 0
  AND EXISTS
    (SELECT MonitorSite.monitor FROM MonitorSite WHERE MonitorSite.dive_site = DiveSite.name);

CREATE VIEW deep_dive_count AS
SELECT count(DiveSite.name) AS num_deep_dive
FROM DiveSite
WHERE DiveSite.deep_limit > 0
  AND EXISTS
    (SELECT MonitorSite.monitor FROM MonitorSite WHERE MonitorSite.dive_site = DiveSite.name);

-- Final query
SELECT *
FROM open_water_count,
     cave_dive_count,
     deep_dive_count;
