-- 5. Find the average fee charged per dive (including extra charges)
-- for dive sites that are more than half full
-- on average, and for those that are half full or less on average.
-- Consider both weekdays and weekends
-- for which there is booking information. Capacity includes all divers,
-- including monitors, at a site at morning, afternoon, or night dive opportunity.

-- For the query, we decided to calculate the fullness based on the total number of
-- divers that dove at the dive site in the whole day rather than calculate fullness
-- based on the dive time. This means that we calculate the fullness using the following:
--     (cave_dive + open_dive + deep_dive) / ((cave_limit + open_limit + deep_limit) * 3)

DROP VIEW IF EXISTS all_booking CASCADE;
DROP VIEW IF EXISTS pplPerBooking CASCADE;
DROP VIEW IF EXISTS bookingSiteDate CASCADE;
DROP VIEW IF EXISTS fullnessPerDay CASCADE;
DROP VIEW IF EXISTS all_listing CASCADE;
DROP VIEW IF EXISTS equipment_costs CASCADE;

-- First find all dives that were booked.
CREATE VIEW all_booking AS
SELECT Booking.id as id
FROM Booking JOIN Listing ON booking.listing = Listing.id;

--find the amount of ppl that dove on a given booking
CREATE VIEW pplPerBooking AS
SELECT COUNT(OtherDiver.diver) + 2 as pplOnDive, all_booking.id
FROM OtherDiver JOIN all_booking ON OtherDiver.booking = all_booking.id
GROUP BY all_booking.id;

--join booking and listing to get the booking's date and dive site
CREATE VIEW bookingSiteDate AS
SELECT Booking.id, Booking.dive_date, Listing.dive_site
FROM Listing,
     Booking
WHERE Listing.id = Booking.listing;

-- add all the ppl per dive per day on that site and divided by total cap *3
-- for each site and date
CREATE VIEW fullnessPerDayAndSite AS
SELECT (SUM(pplOnDive)) / ((DiveSite.open_limit + cave_limit + deep_limit) * 3) as fullness,
       dive_date,
       dive_site
FROM OtherDiver,
     bookingSiteDate,
     DiveSite,
     pplPerBooking
WHERE pplPerBooking.id = OtherDiver.booking
  AND DiveSite.name = bookingSiteDate.dive_site
GROUP BY dive_date, dive_site, open_limit, cave_limit, deep_limit;

-- find the avgfullness over all days for each site
CREATE VIEW avgFullnessPerSite AS
SELECT avg(fullness) as fullness, dive_site
FROM fullnessPerDayAndSite
GROUP BY dive_site;

-- find the avg dive site cost
CREATE VIEW all_listing AS
SELECT dive_site, type, time, cost
FROM Booking JOIN Listing ON booking.listing = Listing.id;


CREATE VIEW equipment_costs AS
SELECT sum(cost) as equip_cost, dive_site
FROM equipmentcost
GROUP BY dive_site;


CREATE VIEW all_site_total_cost AS
SELECT all_listing.dive_site,
       avg(all_listing.cost + divesitecost.cost + equip_cost) as cost
FROM all_listing
         JOIN divesitecost ON
        all_listing.dive_site = divesitecost.dive_site AND
        all_listing.type = divesitecost.type
         JOIN equipment_costs ON equipment_costs.dive_site = all_listing.dive_site
GROUP BY all_listing.dive_site;

-- Final answer
-- Query for fullness > 50%
SELECT aFPS.dive_site as name, fullness, cost
FROM all_site_total_cost JOIN avgFullnessPerSite aFPS on all_site_total_cost.dive_site = aFPS.dive_site
WHERE fullness > 0.5;

-- Query for fullness <= 50%
SELECT aFPS.dive_site as name, fullness, cost
FROM all_site_total_cost JOIN avgFullnessPerSite aFPS on all_site_total_cost.dive_site = aFPS.dive_site
WHERE fullness <= 0.5;
