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
sql
Identify rows with NULL values in essential columns
SELECT *
FROM dbo.spotify_tracks
WHERE track_name IS NULL OR artist_name IS NULL OR duration_ms IS NULL;

-- Remove rows where critical columns are NULL
DELETE FROM dbo.spotify_tracks
WHERE track_name IS NULL OR artist_name IS NULL OR duration_ms IS NULL;
**Objective:** Identify and remove rows where essential columns like `track_name`, `artist_name`, or `duration_ms` contain NULL values, ensuring that only complete records are retained.
### 2. Duplicate Detection and Removal

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
**Objective:** Identify and remove duplicate records, keeping only the first occurrence of each duplicate track. This step ensures that the dataset does not contain multiple entries for the same song.

