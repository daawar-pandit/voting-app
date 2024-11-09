-- init-db.sql

-- Table to store individual votes cast by users
CREATE TABLE IF NOT EXISTS Votes (
    vote_id SERIAL PRIMARY KEY,          -- Unique identifier for each vote
    voter_id VARCHAR(64) NOT NULL,       -- Unique identifier for each voter (from cookie)
    vote_option VARCHAR(50) NOT NULL,    -- Voted option, e.g., "Cats" or "Dogs"
    vote_timestamp TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP -- Time of the vote
);

-- Table to store options, in case they need to be customizable in the database
CREATE TABLE IF NOT EXISTS Options (
    option_id SERIAL PRIMARY KEY,        -- Unique ID for each option
    option_name VARCHAR(50) UNIQUE NOT NULL, -- Option name, e.g., "Cats" or "Dogs"
    vote_count INT DEFAULT 0             -- Total votes for this option, if needed for aggregation
);

-- Insert default voting options (these could be updated if OPTIONS_A or OPTIONS_B change)
INSERT INTO Options (option_name) VALUES 
    ('Cats'), 
    ('Dogs')
ON CONFLICT (option_name) DO NOTHING; -- Avoid duplicates on re-run

-- Function to update vote count in the Options table whenever a new vote is added
CREATE OR REPLACE FUNCTION update_option_count() 
RETURNS TRIGGER AS $$
BEGIN
    -- Increment the vote count in the Options table for the selected option
    UPDATE Options SET vote_count = vote_count + 1 WHERE option_name = NEW.vote_option;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to call the function after each insert into Votes table
CREATE TRIGGER increment_vote_count
AFTER INSERT ON Votes
FOR EACH ROW
EXECUTE FUNCTION update_option_count();
