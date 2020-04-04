INSERT INTO DiveSite VALUES
('Bloody Bay Marine Park', 'Little Caymen', FALSE, TRUE, FALSE, FALSE, 0, 10, 0),
('Widow Maker’s Cave', 'Montego Bay', FALSE, TRUE, FALSE, FALSE, 15, 10, 0),
('Crystal Bay', 'Crystal Bay', TRUE, FALSE, FALSE, TRUE, 10, 5, 0),
('Batu Bolong', 'Batu Bolong', FALSE, FALSE, FALSE, TRUE, 10, 5, 5);


INSERT INTO DiveSiteCost VALUES
('Bloody Bay Marine Park', 'cave'::dive_type, 10),
('Widow Maker’s Cave', 'open'::dive_type, 15),
('Widow Maker’s Cave', 'cave'::dive_type, 20),
('Crystal Bay', 'open'::dive_type, 10),
('Crystal Bay', 'cave'::dive_type, 15),
('Batu Bolong', 'open'::dive_type, 10),
('Batu Bolong', 'cave'::dive_type, 15),
('Batu Bolong', 'deep'::dive_type, 15);


INSERT INTO EquipmentCost VALUES
('mask'::equipment, 'Bloody Bay Marine Park', 5),
('fin'::equipment, 'Bloody Bay Marine Park', 10),
('mask'::equipment, 'Widow Maker’s Cave', 3),
('fin'::equipment, 'Widow Maker’s Cave', 5),
('fin'::equipment, 'Crystal Bay', 5),
('dive_computer'::equipment, 'Crystal Bay', 20),
('mask'::equipment, 'Batu Bolong', 10),
('dive_computer'::equipment, 'Batu Bolong', 30);


INSERT INTO Diver(name, email, birthdate, certificate) VALUES
('Michael', 'michael@dm.org', '1967-03-15'::timestamp, 'PADI'::certificate),
('Dwight Schrute', 'dwight@dm.org', '1970-01-27'::timestamp, 'NAUI'::certificate),
('Jim Halpert', 'jim@dm.org', '1972-02-21'::timestamp, 'CMAS'::certificate),
('Pam Beesly', 'pam@dm.org', '1983-04-20'::timestamp, 'CMAS'::certificate),
('Andy Bernard', 'andy@dm.org', '1973-10-10'::timestamp, 'PADI'::certificate),
('Oscar', 'oscar@dm.org', '1977-05-14'::timestamp, 'PADI'::certificate),
('Phyllis', 'phyllis@dm.org', '1985-03-07'::timestamp, 'NAUI'::certificate);


INSERT INTO SiteRating VALUES
('Bloody Bay Marine Park', 3, 3),
('Widow Maker’s Cave', 2, 0),
('Widow Maker’s Cave', 4, 1),
('Widow Maker’s Cave', 3, 2),
('Crystal Bay', 5, 4),
('Crystal Bay', 4, 5),
('Crystal Bay', 1, 2),
('Crystal Bay', 6, 3);


INSERT INTO Monitor(name, open_limit, cave_limit, deep_limit) VALUES
('Maria', 10, 5, 5),
('John', 15, 10, 10),
('Ben', 15, 5, 5);


INSERT INTO Listing(dive_site, monitor, type, time, cost) VALUES
('Bloody Bay Marine Park', 1, 'cave'::dive_type, 'night'::dive_time, 25),
('Widow Maker’s Cave', 1, 'open'::dive_type, 'morning'::dive_time, 10),
('Widow Maker’s Cave', 1, 'cave'::dive_type, 'morning'::dive_time, 20),
('Crystal Bay', 1, 'open'::dive_type, 'afternoon'::dive_time, 30),
('Bloody Bay Marine Park', 2, 'cave'::dive_type, 'morning'::dive_time, 15),
('Widow Maker’s Cave', 3, 'cave'::dive_type, 'morning'::dive_time, 20);


INSERT INTO Booking(dive_date, listing, lead_diver, card_number) VALUES
('2020-07-20'::timestamp, 2, 1, '1234567111112'),
('2020-07-21'::timestamp, 3, 1, '1234567111112'),
('2020-07-22'::timestamp, 5, 1, '1234567111112'),
('2020-07-22'::timestamp, 1, 1, '1324567111112'),
('2020-07-22'::timestamp, 4, 5, '1357911111112'),
('2020-07-23'::timestamp, 6, 5, '1357911111112'),
('2020-07-24'::timestamp, 6, 5, '1357911111112');


INSERT INTO MonitorRating VALUES
(1, 1, 2),
(1, 2, 0),
(2, 3, 5),
(1, 5, 1),
(3, 6, 0),
(3, 7, 2);


INSERT INTO MonitorSite VALUES
(1, 'Bloody Bay Marine Park'),
(1, 'Widow Maker’s Cave'),
(1, 'Crystal Bay'),
(1, 'Batu Bolong'),
(2, 'Bloody Bay Marine Park'),
(2, 'Crystal Bay'),
(3, 'Widow Maker’s Cave');


INSERT INTO OtherDiver VALUES
(2, 1), (3, 1), (4, 1), (5, 1),
(2, 2), (3, 2),
(3, 3),
(1, 5), (2, 5), (3, 5), (4, 5), (6, 5), (7, 5);
