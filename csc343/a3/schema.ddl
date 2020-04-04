-- Constraint info are commented above each of their corresponding table
-- for clarity and better reference.

DROP SCHEMA IF EXISTS wetworldschema CASCADE;
CREATE SCHEMA wetworldschema;
SET search_path TO wetworldschema;


-- We assume that every Diver is registered in the table before booking any dives.
-- So every diver when registered in this table must be at least 16 years.
--
-- We also assume that the diving sites only accepts 3 types of diving certificates.
-- So defining certificate enum restrict the database to only register divers whose
-- certificate is one of the 3 in the enum.
CREATE TYPE certificate AS ENUM ('NAUI', 'CMAS', 'PADI');

-- A diver (including both lead divers and normal divers)
CREATE TABLE Diver (
  id SERIAL PRIMARY KEY,
  -- The name of the diver, can include both last and first.
  name VARCHAR(50) NOT NULL UNIQUE,
  -- The email address of the diver.
  email VARCHAR(50) NOT NULL UNIQUE,
  -- The birthdate of the diver
  birthdate TIMESTAMP NOT NULL CHECK (extract(year from age(birthdate)) >= 16),
  -- The diving certifacte the diver has.
  certificate certificate NOT NULL
);


-- We assume that both monitor and dive site always have smaller limit on number of divers of
-- cave dive and deep dive than open water dive, which is enforced by checks in both tables.
--
-- Also, since it doesn't make sense to have negative limit on number of divers.
-- So we put checks to ensure that the limit is greater or equal to 0, where 0 indicate that
-- the dive type isn't offered.
--
-- It also doesn't make sense to have negative costs, so check is placed on
-- that as well to ensure the cost is greater than 0.

CREATE TABLE Monitor (
  id SERIAL PRIMARY KEY,
  -- The name of the monitor
  name VARCHAR(50) NOT NULL UNIQUE,

  -- Monitor limit for number of divers for open water, cave dive, and deep dive.
  open_limit INT NOT NULL CHECK (open_limit >= 0),
  cave_limit INT NOT NULL CHECK ((open_limit > cave_limit AND cave_limit >= 0) OR open_limit = 0),
  deep_limit INT NOT NULL CHECK ((open_limit > deep_limit AND deep_limit >= 0) OR open_limit = 0)
);


CREATE TABLE DiveSite (
  -- The name of the dive site.
  name VARCHAR(50) PRIMARY KEY,
  -- The location of the dive site.
  location VARCHAR(100) NOT NULL,

  -- Dive site may offer the following free services, indicated using boolean field.
  video BOOLEAN NOT NULL,
  snacks BOOLEAN NOT NULL,
  shower BOOLEAN NOT NULL,
  towel BOOLEAN NOT NULL,

  -- Dive site limit for number of divers for open water, cave dive, and deep dive.
  open_limit INT NOT NULL CHECK (open_limit >= 0),
  cave_limit INT NOT NULL CHECK ((open_limit > cave_limit AND cave_limit >= 0) OR open_limit = 0),
  deep_limit INT NOT NULL CHECK ((open_limit > deep_limit AND deep_limit >= 0) OR open_limit = 0)
);

-- We assume that there are only 3 types of dives in 3 different time slots
-- So defining dive_type and dive_time enum constraints the type and time
-- field to only the 3 types of dives and time slots.
CREATE TYPE dive_type AS ENUM ('open', 'cave', 'deep');
CREATE TYPE dive_time AS ENUM ('morning', 'afternoon', 'night');

CREATE TABLE DiveSiteCost (
  -- The name of the dive site.
  dive_site VARCHAR(50) REFERENCES DiveSite,
  -- The type of the dive.
  type dive_type,
  -- The costs of dives the dive site charges per diver.
  cost DECIMAL NOT NULL CHECK (cost >= 0),

  PRIMARY KEY (dive_site, type)
);


-- Contains listings of dives that can be booked by divers.
CREATE TABLE Listing (
  id SERIAL PRIMARY KEY,
  -- The dive site of the dive listing.
  dive_site VARCHAR(50) NOT NULL REFERENCES DiveSite,
  -- The monitor for the dive listing
  monitor INT NOT NULL REFERENCES Monitor,
  -- The type of dive for the listing.
  type dive_type NOT NULL,
  -- The time of dive for the listing.
  time dive_time NOT NULL,
  -- The cost of the listing.
  cost DECIMAL NOT NULL CHECK (cost >= 0),

  UNIQUE (dive_site, monitor, type, time)
);


-- We assume that the booking is always made before or at the same time as the dive.
-- So every booking dive_date must be larger than or equal to current_timestamp, 
-- which resembles the time when the booking was made.
--
-- Also through research online, we learned that credit card numbers has max 19 and min 13 digits.
-- So every booking card_number must have at least 13 digits enforced by check, 
-- and less than 19 which is enforced by field type.
--
-- We also assume that no two listing can have the same monitor on the same dive_date.
-- Meaning each monitor cannot have more than 2 dives in a 24 hour period.
-- We decided not to enforce this in the schema since it cannot be enforced without
-- using triggers or assertions. Also, this constraint can be easily enforced by front-end
-- where the general-purpose programming language can easily keep track of the number of dives
-- each monitor is doing in a 24 hour period.

CREATE TABLE Booking (
  id SERIAL PRIMARY KEY,
  -- The date of the dive.
  dive_date TIMESTAMP NOT NULL CHECK (dive_date >= current_timestamp),
  -- The dive listing (read comment for Listing table).
  listing INT NOT NULL REFERENCES Listing,
  -- The id of the lead diver who booked the dive.
  lead_diver INT NOT NULL REFERENCES Diver,
  -- The credit card number of lead diver for this booking.
  card_number VARCHAR(19) NOT NULL CHECK (length(card_number) >= 13),

  UNIQUE (dive_date, listing)
);


-- Non-lead divers associated with a booking.
CREATE TABLE OtherDiver (
  -- The id of the non-lead diver.
  diver INT REFERENCES Diver,
  -- The booking id the diver is associated with.
  booking INT REFERENCES Booking,

  PRIMARY KEY (diver, booking)
);


-- Contains all monitor's affiliation with dive sites.
CREATE TABLE MonitorSite (
  -- The monitor id.
  monitor INT REFERENCES Monitor,
  -- The dive site that the monitor is affiliated with.
  dive_site VARCHAR(50) REFERENCES DiveSite,

  PRIMARY KEY (monitor, dive_site)
);


-- We assume both the site and monitor rating are between 0 and 5,
-- which is restricted using checks in both SiteRating and MonitorRating.

CREATE TABLE SiteRating (
  -- The site being rated.
  dive_site VARCHAR(50) REFERENCES DiveSite,
  -- The diver who rated the site.
  diver INT REFERENCES Diver,
  -- The rating out of 5 stars.
  rating INT NOT NULL CHECK (rating >= 0 AND rating <= 5),

  PRIMARY KEY (dive_site, diver)
);


CREATE TABLE MonitorRating (
  -- The monitor being rated.
  monitor INT REFERENCES monitor,
  -- The lead-diver from this booking rated the monitor.
  booking INT REFERENCES Booking,
  -- The rating out of 5 stars.
  rating INT NOT NULL CHECK (rating >= 0 AND rating <= 5),

  PRIMARY KEY (monitor, booking)
);


-- We assume there are only 4 types of equipments offered for additional cost
-- at each site. So defining equipment enum constraints the EquipmentCost table
-- to only store these 4 types of equipment with their cost and associated dive site.
CREATE TYPE equipment AS ENUM ('mask', 'regulator', 'fin', 'dive_computer');

-- Contains extra equipment and prices that dive sites offer.
CREATE TABLE EquipmentCost (
  -- The name of the equipment.
  name equipment,
  -- The dive site that provides the equipment.
  dive_site VARCHAR(50) REFERENCES DiveSite,
  -- The additional cost of renting the equipment.
  cost DECIMAL NOT NULL CHECK (cost >= 0),

  PRIMARY KEY (name, dive_site)
);
