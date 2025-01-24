# **Spotify Data Quality and Clean-Up Analysis**

## **Introduction**
This project focuses on the data cleaning and quality assurance process for the Spotify Tracks dataset using SQL queries. The primary objective is to identify and remove data inconsistencies, handle duplicates, fix invalid or missing values, and standardize the data for further analysis. The dataset includes crucial details about tracks, artists, albums, and various audio features.

This repository contains SQL scripts aimed at improving the integrity of the dataset through data cleaning tasks.

---

## **Dataset Overview**
The dataset contains information about Spotify tracks, including:
- 🎵 **Track Name**
- 🎤 **Artist Name**
- 💿 **Album Name**
- 🌐 **Language**
- ⭐ **Popularity**
- ⏳ **Duration (ms)**
- 📅 **Year**
- 🎼 **Audio Features** (e.g., tempo, loudness, instrumentalness)
- 🎶 **URLs** (e.g., track_url, artwork_url)
- 🔑 **Key and Mode Values**

---

## **Queries and Insights**

### **1. NULL Values and Critical Column Checks**
```sql
--Identify rows with NULL values in essential columns
SELECT *
FROM dbo.spotify_tracks
WHERE track_name IS NULL OR artist_name IS NULL OR duration_ms IS NULL;
```
-- Remove rows where critical columns are NULL
DELETE FROM dbo.spotify_tracks
WHERE track_name IS NULL OR artist_name IS NULL OR duration_ms IS NULL;
**Objective:** Identify and remove rows where essential columns like `track_name`, `artist_name`, or `duration_ms` contain NULL values, ensuring that only complete records are retained.

### **2. Duplicate Detection and Removal**
```sql
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
```
**Objective:** Identify and remove duplicate records, keeping only the first occurrence of each duplicate track. This step ensures that the dataset does not contain multiple entries for the same song.



### **3. Handling Invalid Data**
```sql
-- Check for invalid numeric values in columns like duration_ms or loudness
SELECT *
FROM dbo.spotify_tracks
WHERE ISNUMERIC(duration_ms) = 0 OR ISNUMERIC(loudness) = 0;

-- Update or convert invalid data
UPDATE dbo.spotify_tracks
SET duration_ms = NULL
WHERE ISNUMERIC(duration_ms) = 0;

```
**Objective:** Identify rows with invalid numeric values (e.g., non-numeric entries in duration_ms or loudness), and set invalid values to NULL for correction.
### **4. Standardizing Text Values**
```sql
-- Update track and artist names to proper case
UPDATE dbo.spotify_tracks
SET track_name = UPPER(LEFT(track_name, 1)) + LOWER(SUBSTRING(track_name, 2, LEN(track_name))),
    artist_name = UPPER(LEFT(artist_name, 1)) + LOWER(SUBSTRING(artist_name, 2, LEN(artist_name)));

```
**Objective:** Standardize the text format of track_name and artist_name by capitalizing the first letter and converting the rest to lowercase, ensuring consistency.

### **5. Handling Unexpected Language Codes**
```sql
-- Replace invalid or unknown language codes
UPDATE dbo.spotify_tracks
SET language = 'Unknown'
WHERE language IS NULL OR language = '' OR language NOT IN ('English', 'Tamil', 'Korean', 'Hindi', 'Telugu');

```
**Objective:** Replace missing or invalid language codes with 'Unknown', ensuring the dataset contains recognized languages only.


### **6. Duration Outliers and Validations**

```sql
-- Identify unusually short or long tracks
SELECT *
FROM dbo.spotify_tracks
WHERE duration_ms < 30000 OR duration_ms > 600000;

-- Remove or update outliers
DELETE FROM dbo.spotify_tracks
WHERE duration_ms < 30000 OR duration_ms > 600000;
```
**Objective:** Identify and remove tracks that are too short (less than 30 seconds) or too long (greater than 10 minutes), as they may represent incorrect or incomplete records.

### **7. Popularity Range Validation**

```sql
-- Identify invalid popularity values
SELECT *
FROM dbo.spotify_tracks
WHERE popularity < 0 OR popularity > 100;

-- Update or delete invalid popularity values
DELETE FROM dbo.spotify_tracks
WHERE popularity < 0 OR popularity > 100;
```
**Objective:** Remove or correct tracks with invalid popularity values.

### 8. Removing Leading and Trailing Spaces

```sql
-- Remove leading and trailing spaces in text columns
UPDATE dbo.spotify_tracks
SET track_name = LTRIM(RTRIM(track_name)),
    artist_name = LTRIM(RTRIM(artist_name)),
    album_name = LTRIM(RTRIM(album_name));
### Objective: 
Remove any leading or trailing spaces in the text fields (e.g., track_name, artist_name, album_name) to improve consistency.

### 9. Key and Mode Validation

```sql
-- Find invalid key or mode values
SELECT *
FROM dbo.spotify_tracks
WHERE [key] NOT BETWEEN 0 AND 11 OR mode NOT IN (0, 1);
```
-- Correct or remove invalid values
UPDATE dbo.spotify_tracks
SET [key] = NULL
WHERE [key] NOT BETWEEN 0 AND 11;

UPDATE dbo.spotify_tracks
SET mode = NULL
WHERE mode NOT IN (0, 1);
### Objective: 
Identify and correct invalid key and mode values, ensuring they fall within the acceptable range.
### 10. Handling Missing and Out-of-Range Data

#### Objective:
Handle missing essential data by removing incomplete rows or replacing missing values with defaults (e.g., replacing missing popularity with 0 and missing duration_ms with the average duration).

```sql
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
```
### 11. URL Validation

#### Objective:
Identify and flag rows where URLs are not properly formatted (i.e., they do not start with 'http').

```sql
-- Identify rows with invalid URLs in track_url or artwork_url columns
SELECT *
FROM dbo.spotify_tracks
WHERE track_url NOT LIKE 'http%' OR artwork_url NOT LIKE 'http%';
```
### Key Highlights

- **Data Cleanliness:** Ensures there are no NULL values in critical columns, duplicates are removed, and invalid entries are cleaned up.
- **Consistency:** Standardizes text fields and resolves discrepancies in numerical and categorical values.
- **Outlier Detection:** Identifies and removes tracks that have invalid durations or popularity scores.
- **Data Integrity:** Fixes any issues with language codes, URLs, key, and mode values, ensuring the dataset remains valid and usable.
### Future Work

- Further explore outlier detection for other columns (e.g., tempo, instrumentalness).
- Conduct data validation checks based on additional audio features.
- Extend the cleaning process to handle data inconsistencies at scale, especially for larger datasets.
- Implement a system to automatically flag and clean new data entries upon insertion.



