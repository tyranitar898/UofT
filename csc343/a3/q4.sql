-- 4. For each dive site report the highest, lowest, and
-- average fee charged per dive.

DROP VIEW IF EXISTS all_booking CASCADE;
DROP VIEW IF EXISTS all_site_total_cost CASCADE;

-- First find all dives that were booked.
CREATE VIEW all_booking AS
SELECT dive_site, type, time, cost
FROM Booking JOIN Listing ON booking.listing = Listing.id;

CREATE VIEW all_site_total_cost AS
SELECT all_booking.dive_site, all_booking.type, all_booking.cost + divesitecost.cost as cost
FROM all_booking JOIN divesitecost ON
        all_booking.dive_site = divesitecost.dive_site AND
        all_booking.type = divesitecost.type;

-- Using all bookings and each divesite. find the max min and avg costs.
SELECT dive_site as name, max(cost), min(cost), avg(cost)
FROM all_site_total_cost
GROUP BY dive_site;
