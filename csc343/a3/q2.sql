-- 2. Find monitors whose average rating is higher than that of all dives sites
-- that the monitor uses. Report each of these monitor's 
-- average booking fee and email.

DROP VIEW IF EXISTS monitorSiteRating CASCADE;
DROP VIEW IF EXISTS monitorsWithGoodRatings CASCADE;
DROP VIEW IF EXISTS avgCostPerMon CASCADE;

CREATE VIEW monitorSiteRating AS
SELECT MonitorSite.monitor, MonitorSite.dive_site, rating
FROM MonitorSite JOIN SiteRating ON MonitorSite.dive_site = SiteRating.dive_site;

-- finds all monitors whose average rating 
-- is higher than all dive sites that monitor has privileges in
CREATE VIEW monitorsWithGoodRatings AS
SELECT MonitorRating.monitor as monId
FROM MonitorRating
GROUP BY monitor
HAVING avg(rating) > ALL
    (SELECT rating FROM monitorSiteRating WHERE monitorSiteRating.monitor = MonitorRating.monitor);

-- finds average booking costs of each monitor.
CREATE VIEW avgCostPerMon AS
SELECT avg(Listing.cost) as avg, Listing.monitor as monId
FROM Listing
WHERE EXISTS(SELECT booking.id FROM BOOKING WHERE booking.listing = Listing.id)
GROUP BY Listing.monitor;

-- Final answer
SELECT Monitor.name, avg
FROM monitorsWithGoodRatings,
     avgCostPerMon,
     Monitor
WHERE Monitor.id = monitorsWithGoodRatings.monId
  AND Monitor.id = avgCostPerMon.monId;
