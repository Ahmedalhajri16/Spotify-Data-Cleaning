-- Identify rows with NULL values in essential columns
SELECT *
FROM dbo.spotify_tracks
WHERE track_name IS NULL OR artist_name IS NULL OR duration_ms IS NULL
-- Remove rows where critical columns are NULL
DELETE FROM dbo.spotify_tracks
WHERE track_name IS NULL OR artist_name IS NULL OR duration_ms IS NULL;
-- Identify duplicate records
SELECT 
    track_name, 
    artist_name, 
    duration_ms, 
    COUNT(*) AS duplicate_count
FROM dbo.spotify_tracks
GROUP BY track_name, artist_name, duration_ms
HAVING COUNT(*) > 1;

-- Remove duplicates, keeping the first occurrence
WITH CTE AS (
    SELECT 
        *, 
        ROW_NUMBER() OVER (PARTITION BY track_name, artist_name, duration_ms ORDER BY track_id) AS row_num
    FROM dbo.spotify_tracks
)
DELETE FROM CTE
WHERE row_num > 1;
-- Check for invalid numeric values in columns like duration_ms or loudness
SELECT *
FROM dbo.spotify_tracks
WHERE ISNUMERIC(duration_ms) = 0 OR ISNUMERIC(loudness) = 0;

-- Update or convert invalid data
UPDATE dbo.spotify_tracks
SET duration_ms = NULL
WHERE ISNUMERIC(duration_ms) = 0;
-- Update track and artist names to proper case
UPDATE dbo.spotify_tracks
SET track_name = UPPER(LEFT(track_name, 1)) + LOWER(SUBSTRING(track_name, 2, LEN(track_name))),
    artist_name = UPPER(LEFT(artist_name, 1)) + LOWER(SUBSTRING(artist_name, 2, LEN(artist_name)));
-- Find unexpected language codes
SELECT DISTINCT language
FROM dbo.spotify_tracks;

-- Replace invalid or unknown language codes
UPDATE dbo.spotify_tracks
SET language = 'Unknown'
WHERE language IS NULL OR language = '' OR language NOT IN ('English', 'Tamil', 'Korean', 'Hindi', 'Telugu');
-- Identify unusually short or long tracks
SELECT *
FROM dbo.spotify_tracks
WHERE duration_ms < 30000 OR duration_ms > 600000;

-- Remove or update outliers
DELETE FROM dbo.spotify_tracks
WHERE duration_ms < 30000 OR duration_ms > 600000;
-- Identify invalid popularity values
SELECT *
FROM dbo.spotify_tracks
WHERE popularity < 0 OR popularity > 100;

-- Update or delete invalid popularity values
DELETE FROM dbo.spotify_tracks
WHERE popularity < 0 OR popularity > 100;
-- Remove leading and trailing spaces in text columns
UPDATE dbo.spotify_tracks
SET track_name = LTRIM(RTRIM(track_name)),
    artist_name = LTRIM(RTRIM(artist_name)),
    album_name = LTRIM(RTRIM(album_name));
-- Find invalid key or mode values
SELECT *
FROM dbo.spotify_tracks
WHERE [key] NOT BETWEEN 0 AND 11 OR mode NOT IN (0, 1);

-- Correct or remove invalid values
UPDATE dbo.spotify_tracks
SET [key] = NULL
WHERE [key] NOT BETWEEN 0 AND 11;

UPDATE dbo.spotify_tracks
SET mode = NULL
WHERE mode NOT IN (0, 1);
-- Remove duplicate records by keeping only the first occurrence of each duplicate group
DELETE FROM dbo.spotify_tracks
WHERE track_id IN (
    SELECT track_id
    FROM (
        SELECT track_id, ROW_NUMBER() OVER (PARTITION BY track_name, artist_name, album_name, duration_ms ORDER BY track_id) AS row_num
        FROM dbo.spotify_tracks
    ) AS duplicates
    WHERE row_num > 1
);

-- Identify rows with missing essential data (track_name or artist_name)
SELECT *
FROM dbo.spotify_tracks
WHERE track_name IS NULL OR artist_name IS NULL;

-- Remove rows with missing essential data
DELETE FROM dbo.spotify_tracks
WHERE track_name IS NULL OR artist_name IS NULL;

-- Replace missing popularity values with 0
UPDATE dbo.spotify_tracks
SET popularity = 0
WHERE popularity IS NULL;

-- Replace missing duration values with the average duration from the dataset
UPDATE dbo.spotify_tracks
SET duration_ms = (SELECT AVG(duration_ms) FROM dbo.spotify_tracks WHERE duration_ms IS NOT NULL)
WHERE duration_ms IS NULL;

-- Identify rows with out-of-range numerical data (e.g., tempo or loudness)
SELECT *
FROM dbo.spotify_tracks
WHERE tempo < 0 OR tempo > 250 OR loudness < -60 OR loudness > 0;

-- Standardize text fields to uppercase for consistency
UPDATE dbo.spotify_tracks
SET track_name = UPPER(track_name),
    artist_name = UPPER(artist_name);

-- Identify rows with invalid URLs in track_url or artwork_url columns
SELECT *
FROM dbo.spotify_tracks
WHERE track_url NOT LIKE 'http%' OR artwork_url NOT LIKE 'http%';

-- Identify songs with unusual durations (too short or too long)
SELECT *
FROM dbo.spotify_tracks
WHERE duration_ms < 30000 OR duration_ms > 600000;

-- Identify invalid or unrecognized language codes in the dataset
SELECT DISTINCT language
FROM dbo.spotify_tracks
WHERE language NOT IN ('en', 'ta', 'ko', 'hi', 'te');

-- Remove rows with invalid language codes that are not part of the recognized list
DELETE FROM dbo.spotify_tracks
WHERE language NOT IN ('en', 'ta', 'ko', 'hi', 'te') AND language IS NOT NULL;

