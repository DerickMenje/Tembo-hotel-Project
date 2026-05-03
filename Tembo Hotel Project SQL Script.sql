CREATE SCHEMA Tembo_hotel_project;

SET search_path TO Tembo_hotel_project;
SHOW SEARCH_path;

create table staging_bookings(
booking_id text,
guest_name text,
guest_phone TEXT,
guest_city TEXT,
guest_nationality TEXT,
room_no TEXT,
room_type TEXT,
room_rate_per_night TEXT,
check_in_date TEXT,
check_out_date TEXT,
nights_stayed TEXT,
staff_name TEXT,
staff_department TEXT,
staff_salary TEXT,
payment_method TEXT,
booking_status TEXT,
total_amount TEXT,
service_used TEXT,
service_price TEXT,
guest_rating TEXT
);

SELECT * FROM staging_bookings;

-- Duplicating staging_bookings
CREATE table cleaned_staging_booking
AS SELECT * FROM staging_bookings;

SELECT * FROM cleaned_staging_booking;

alter table cleaned_staging_booking
alter column room_rate_per_night type numeric using room_rate_per_night:: numeric;

SELECT SUM(room_rate_per_night) FROM cleaned_staging_booking;

SELECT * FROM cleaned_staging_booking;

SELECT count(DISTINCT(booking_id)) FROM cleaned_staging_booking;

-- Confirming if there are any duplicate records in the dataset
SELECT booking_id,count(booking_id) AS count_id
FROM cleaned_staging_booking
GROUP BY booking_id
having count(booking_id) >1;

-- duplicate identified as booking_id BK0006
SELECT * FROM cleaned_staging_booking
WHERE booking_id = 'BK0006';

-- Removing duplicate booking_ids; We opted for duplication of the data selecting only the distinct 
CREATE table cleaned_staging_booking1
AS SELECT DISTINCT * FROM cleaned_staging_booking;

SELECT count(DISTINCT(booking_id)) FROM cleaned_staging_booking1;
SELECT * FROM cleaned_staging_booking1;

-- Trimming the dataset (Numeric datatypes can't be trimmed)
UPDATE cleaned_staging_booking1
SET
guest_name = trim(guest_name),
guest_phone = trim(guest_phone),
guest_city = trim(guest_city),
guest_nationality = trim(guest_nationality),
room_no = trim(room_no),
room_type = trim(room_type),
check_in_date = trim(check_in_date),
check_out_date = trim(check_out_date),
staff_name = trim(staff_name),
staff_department = trim(staff_department),
staff_salary = trim(staff_salary),
payment_method = trim(payment_method),
booking_status = trim(booking_status),
total_amount = trim(total_amount),
service_used = trim(service_used),
service_price = trim(service_price),
guest_rating = trim(guest_rating);

SELECT * FROM CLEANED_STAGING_BOOKING1 CSB;

-- Applying initcap
UPDATE CLEANED_STAGING_BOOKING1 CSB
SET
guest_name = initcap(guest_name),
staff_name = initcap(staff_name),
guest_city = initcap(guest_city),
guest_nationality = initcap(guest_nationality),
room_type = initcap(room_type),
staff_department = initcap(staff_department),
payment_method = initcap(payment_method),
booking_status = initcap(booking_status),
service_used = initcap(service_used)
;

-- cleaning the guest_phone column
-- Replacing the hyphens(-) with blank('')
UPDATE CLEANED_STAGING_BOOKING1
SET guest_phone = replace(guest_phone,'-','');

-- Replacing the +254 with 0
UPDATE cleaned_staging_booking1
SET guest_phone = replace(guest_phone,'+254', '0');


-- Changing data type of the guest_phone to VARCHAR from TEXT
alter table cleaned_staging_booking1
alter column guest_phone type varchar(10) using guest_phone:: varchar(10);

SELECT  * FROM cleaned_staging_booking1;

-- Cleaning guest_city column
SELECT distinct(guest_city) FROM cleaned_staging_booking1
ORDER BY GUEST_CITY;

UPDATE CLEANED_STAGING_BOOKING1
SET guest_city = replace(guest_city, 'Thikax', 'Thika');

SELECT distinct(guest_nationality) FROM cleaned_staging_booking1
ORDER BY guest_nationality;

-- Changing room_no to VARCHAR
alter table cleaned_staging_booking1
alter column room_no type varchar(3) using room_no:: varchar(3);

-- Standardizing room_type
SELECT distinct(room_type) FROM cleaned_staging_booking1
ORDER BY room_type;

UPDATE CLEANED_STAGING_BOOKING1 CSB
SET 
room_type = REPLACE(room_type, 'Dlx', 'Deluxe');

UPDATE CLEANED_STAGING_BOOKING1 CSB 
SET 
room_type = replace(room_type, 'Std', 'Standard');

SELECT * FROM cleaned_staging_booking1;

-- Cleaning up the dates columns check_in_date
-- This query looks for dates that have the / separator and converts them to date and casts them to text
update cleaned_staging_booking1
set check_in_date = to_date(check_in_date, 'DD-MM-YYYY')::text
where check_in_date like '%/%';
 
-- This also follows the same concept as above but for the date values separated by - and are of length 8 i.e 01-02-23
update cleaned_staging_booking1
set check_in_date = to_date(check_in_date, 'DD-MM-YY')::text
where check_in_date like '%-%' and length (check_in_date) = 8;
 
-- For this, the separator is - but the count of the date characters is 10 i.e. 01-02-2023.
-- The split_part in this scenario splits the date values by '-' and focuses on the specified part of the split values, in this case, 1.
-- This corresponds to our month separate part from the date. It then casts it to an integer and checks if it is less than 12.
update cleaned_staging_booking1
set check_in_date = to_date(check_in_date, 'MM-DD-YYYY')::text
where check_in_date like '%-%' and length (check_in_date) = 10 and split_part (check_in_date,'-',1)::integer <=12;
 
update cleaned_staging_booking1
set check_in_date = to_date(check_in_date, 'DD-MM-YYYY')::text
WHERE check_in_date = '15-11-2024';
--where check_in_date like '%-%' and length (check_in_date) = 10 and split_part (check_in_date,'-',2)::integer <=12;

-- check_out_date
UPDATE cleaned_staging_booking1
SET check_out_date = to_date(check_out_date, 'DD-MM-YYYY') ::TEXT
WHERE check_out_date LIKE '%/%';

UPDATE cleaned_staging_booking1
SET check_out_date = to_date(check_out_date, 'DD-MM-YY') :: text
WHERE check_out_date LIKE '%-%' AND length(check_out_date) = 8 AND split_part(check_out_date, '-',2):: integer <=12;

UPDATE cleaned_staging_booking1
SET check_out_date = to_date(check_out_date, 'MM-DD-YYYY') ::TEXT
WHERE check_out_date LIKE '%-%' AND split_part(check_out_date, '-',1)::integer <=12;

UPDATE cleaned_staging_booking1
SET check_out_date = to_date(check_out_date, 'DD-MM-YYYY') :: text
WHERE check_out_date = '17-11-2024';
--WHERE check_out_date LIKE '%-%' AND split_part(check_out_date, '-',1):: integer >12;

-- Cleaning payment_method
UPDATE cleaned_staging_booking1 csb 
SET payment_method = replace(payment_method, 'Mpesa', 'M-Pesa');

-- Cleaning staff salary column, replacing 'KES ,' with a blank
UPDATE cleaned_staging_booking1 csb 
SET staff_salary = replace(staff_salary, 'KES ,', '');

-- Cleaning the Total_amount column
UPDATE cleaned_staging_booking1 csb 
SET total_amount = replace(total_amount, 'KES ,', '');

UPDATE cleaned_staging_booking1 csb 
SET total_amount = replace(total_amount, 'KES ', '');

UPDATE cleaned_staging_booking1 csb 
SET total_amount = replace(total_amount, ',', '');

UPDATE cleaned_staging_booking1 csb 
SET total_amount = trim(total_amount);


SELECT check_in_date, check_out_date FROM cleaned_staging_booking1 csb 
WHERE nights_stayed < 1;

-- Switching the erroneous date check-ins and and check-outs
UPDATE cleaned_staging_booking1 csb 
SET check_in_date = replace(check_in_date, '2024-10-05', '2024-10-02')
WHERE nights_stayed < 1;

UPDATE cleaned_staging_booking1 csb 
SET check_out_date = replace(check_out_date, '2024-10-02', '2024-10-05')
WHERE nights_stayed < 1;

-- Changing the negative values in the nights_stayed column to absolute
UPDATE cleaned_staging_booking1 csb 
SET nights_stayed = abs(nights_stayed)
WHERE booking_id = 'BK9003';


-- TOTAL AMOUNT CALCULATION
-- Replacing the zeros in the service price  with NULLs
update cleaned_staging
SET service_price = NULL
where service_price = 0;

-- Changing Data type of service type
ALTER TABLE cleaned_staging_booking1
ALTER COLUMN service_price TYPE NUMERIC USING service_price :: NUMERIC;

-- Duplicating the cleaned_staging_booking1 table
CREATE TABLE cleaned_staging1
AS SELECT * FROM cleaned_staging_booking1;

SELECT * FROM cleaned_staging1;

--Calculating Total amount values
UPDATE cleaned_staging1
SET total_amount = (room_rate_per_night*nights_stayed)+service_price;

SELECT sum(service_price) FROM cleaned_staging1;

ALTER TABLE cleaned_staging1
ALTER COLUMN total_amount TYPE NUMERIC USING total_amount :: NUMERIC;

-- Adding blank salary amounts
-- Security = 30000 since the other security salaries are that amount
UPDATE cleaned_staging1
SET staff_salary = 30000
WHERE staff_department = 'Security' AND trim(staff_salary) = '';

SELECT DISTINCT(staff_department), staff_salary, count(staff_salary) FROM cleaned_staging1
GROUP BY staff_department, staff_salary
ORDER BY staff_department;

-- Replaced the Housekeeping and Restaurant Salary values with NULL
UPDATE cleaned_staging1
SET staff_salary = NULL
WHERE staff_department = 'Housekeeping' AND trim(staff_salary) = '';

UPDATE cleaned_staging1
SET staff_salary = NULL
WHERE staff_department = 'Restaurant' AND trim(staff_salary) = '';

-- Converting the salary column to numeric
ALTER TABLE cleaned_staging1
ALTER COLUMN staff_salary TYPE NUMERIC USING staff_salary :: NUMERIC;

-- Replacing guest rating blanks to nulls
UPDATE cleaned_staging1
SET guest_rating = NULL
WHERE trim(guest_rating) = '';

ALTER TABLE cleaned_staging1
ALTER COLUMN guest_rating TYPE NUMERIC USING guest_rating :: NUMERIC;

UPDATE cleaned_staging1 
SET guest_phone = NULL
WHERE guest_phone = '';

UPDATE cleaned_staging1
SET
guest_city = nullif(guest_city, ''),
service_used = nullif(service_used, '');

-- Changing data type of the dates from text

ALTER TABLE cleaned_staging1 
ALTER COLUMN check_in_date TYPE date USING check_in_date :: date,
ALTER COLUMN check_out_date TYPE date USING check_out_date :: date;


UPDATE cleaned_staging1 
SET nights_stayed = (check_out_date - check_in_date);

SELECT * FROM cleaned_staging1

UPDATE cleaned_staging1 
SET 
check_in_date = ('2024-09-08'),
check_out_date = ('2024-09-10')
WHERE nights_stayed <0;

-- Duplicating the final cleaned dataset for analysis
CREATE TABLE v_clean_bookings as
SELECT * FROM cleaned_staging1;

SELECT * FROM v_clean_bookings;

-- Revenue analysis
	-- total revenue by month, by room, by payment method

CREATE VIEW revenue_by_room as
SELECT room_no, sum(total_amount) AS total_revenue FROM v_clean_bookings
GROUP BY room_no;

CREATE VIEW revenue_by_payment_method as
SELECT payment_method, sum(total_amount) AS total_revenue FROM v_clean_bookings
GROUP BY payment_method;

CREATE VIEW revenue_by_month as
SELECT extract(MONTH FROM check_out_date) AS month_number, sum(total_amount) AS total_revenue FROM v_clean_bookings
GROUP BY month_number
ORDER BY MONTH_NUMBER;

CREATE VIEW revenue_by_year as
SELECT extract(YEAR FROM check_out_date) AS year, sum(total_amount) AS total_revenue FROM v_clean_bookings
GROUP BY year
ORDER BY year;

 -- Occupancy - which room types are booked most? (avg nights stayed by room type)

CREATE VIEW Occupancy AS 
SELECT
	room_type,
	count(booking_id) AS number_of_bookings,
	Round(avg(nights_stayed)) AS average_nights_stayed
FROM
	cleaned_staging1 cs
GROUP BY
	room_type;
 
-- Staff performance - which staff handled the most bookings? (Kelvin Omondi)
CREATE VIEW Staff_performance as
 SELECT
	staff_name,
	count(booking_id) AS number_of_bookings
FROM
	v_clean_bookings vcb
GROUP BY
	staff_name
ORDER BY number_of_bookings desc;

-- Revenue per staff

CREATE VIEW revenue_per_staff as
SELECT
	staff_name,
	sum(total_amount) AS total_revenue
FROM
	v_clean_bookings vcb
GROUP BY
	staff_name
ORDER BY total_revenue desc;

-----------------------------------------------------------------------------------------------------------------------------------------
-- Cancellations - Cancellation count 
SELECT
	DISTINCT(room_type),
	count(booking_id) OVER(PARTITION BY room_type ) AS cancellation_count
FROM
	v_clean_bookings vcb
WHERE
	booking_status = 'Cancelled'
ORDER BY cancellation_count desc;

-- Using group by clause
SELECT
	room_type,
	count(booking_id) AS cancellations
FROM
	v_clean_bookings vcb
GROUP BY
	room_type, booking_status
HAVING
	booking_status = 'Cancelled'
ORDER BY cancellations desc;

----------------------------------------------------------------------------------------------------------------------------------------
-- Cancellation rate per room type. 
-- Using case when
SELECT
	room_type,
	round((COUNT(CASE WHEN booking_status = 'Cancelled' THEN 1 END)::NUMERIC
/ COUNT(booking_id)) * 100, 2) AS cancellationrate_
FROM
	v_clean_bookings
GROUP BY
	room_type
ORDER BY
	cancellationrate_;

-- Using FILTER and WHERE
CREATE VIEW Cancellation_rate as
SELECT
	room_type,
	ROUND(COUNT(*) FILTER (WHERE booking_status = 'Cancelled')* 100.0 / COUNT(*), 2) AS cancellation_rate
FROM
	v_clean_bookings
GROUP BY
	room_type
ORDER BY
	cancellation_rate;

-------------------------------------------------------------------------------------------------------------------

-- Revenue lost from cancellation or no-shows [1,175,300]
CREATE VIEW revenue_lost AS
SELECT
	sum(total_amount) AS revenue_lost
FROM
	v_clean_bookings
WHERE
	booking_status IN ('Cancelled', 'No Show');

CREATE VIEW staff_salary AS 
SELECT DISTINCT staff_name, sum(staff_salary) AS salary FROM v_clean_bookings vcb 
GROUP BY DISTINCT staff_name;

CREATE OR replace VIEW Individual_salary AS 
select distinct staff_name, staff_salary
from v_clean_bookings vcb ;