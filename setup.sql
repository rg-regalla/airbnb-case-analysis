alter database airbnb_case set datestyle ='ISO,DMY';

CREATE TABLE airbnb.calendars (
    listing_id INT NOT NULL,
    date DATE NOT NULL,
    available BOOLEAN NOT NULL,
    price TEXT,
    minimum_nights INT NOT NULL,
    maximum_nights INT NOT NULL
);

CREATE TABLE airbnb.listings (
    id SERIAL,                -- Auto-incrementing unique identifier
    listing_url TEXT NOT NULL,            -- URL of the listing
    name TEXT NOT NULL,                   -- Name of the listing
    description TEXT,                     -- Description of the listing
    host_id INT NOT NULL,                 -- Host ID
    host_name TEXT,                       -- Host name
    host_since DATE,                      -- Date when the host joined
    host_location TEXT,                   -- Host's location
    host_response_time TEXT,              -- Host response time
    host_response_rate TEXT,              -- Host response rate as text
    host_acceptance_rate TEXT,            -- Host acceptance rate as text
    host_is_superhost BOOLEAN,            -- Whether the host is a superhost
    host_listings_count INT,              -- Number of listings the host has
    host_total_listings_count INT,        -- Total number of listings by the host
    host_verifications TEXT,              -- List of host verifications (e.g., email, phone)
    property_type TEXT,                   -- Type of property
    room_type TEXT NOT NULL,              -- Type of room
    accommodates INT,                     -- Number of people the listing accommodates
    bathrooms DECIMAL(3, 1),              -- Number of bathrooms (e.g., 1.5)
    bathrooms_text TEXT,                  -- Text describing bathrooms (e.g., "1 bath")
    bedrooms DECIMAL(3, 1),               -- Number of bedrooms
    beds DECIMAL(3, 1),                   -- Number of beds
    number_of_reviews INT,                -- Total number of reviews
    review_scores_rating DECIMAL(3, 2)   -- Average review score rating
);


CREATE TABLE IF NOT EXISTS airbnb.reviews
(
    id bigint NOT NULL,
    listing_id bigint NOT NULL,
    date timestamp without time zone NOT NULL,
    reviewer_id integer NOT NULL,
    reviewer_name text COLLATE pg_catalog."default",
    comments text COLLATE pg_catalog."default"
);