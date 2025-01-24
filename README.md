# Data Quality and Cleaning Scripts for Spotify Tracks Dataset

This repository contains SQL scripts to clean and preprocess data in the `dbo.spotify_tracks` table. These scripts are designed to handle common data quality issues such as missing values, duplicates, invalid data, and inconsistencies across various columns.

## Overview

The main tasks covered by the scripts are:

1. **Identify and Remove Rows with NULL Values**:  
   Identify and remove rows where critical columns like `track_name`, `artist_name`, or `duration_ms` are `NULL`.

2. **Handle Duplicates**:  
   Detect duplicate records based on a combination of essential columns (`track_name`, `artist_name`, `duration_ms`) and remove all but the first occurrence.

3. **Check and Handle Invalid Numeric Data**:  
   Find rows where numeric columns like `duration_ms` or `loudness` contain invalid values (non-numeric) and correct or remove them.

4. **Update and Standardize Text Data**:  
   Convert text fields (like `track_name` and `artist_name`) to proper case or uppercase for consistency.

5. **Validate and Correct Language Codes**:  
   Identify unexpected or invalid language codes in the `language` column and replace them with a default value (`'Unknown'`), or correct them based on a predefined list of valid languages.

6. **Handle Unusual Track Durations**:  
   Identify tracks with unusually short or long durations (less than 30 seconds or greater than 10 minutes) and remove or update these outliers.

7. **Validate Popularity Values**:  
   Check for invalid popularity values (outside the range of 0 to 100) and remove or update them.

8. **Trim Leading/Trailing Spaces**:  
   Remove leading and trailing spaces from text columns like `track_name`, `artist_name`, and `album_name`.

9. **Validate Key and Mode Values**:  
   Ensure the `key` and `mode` columns contain valid values and correct or remove any invalid entries.

10. **Replace Missing Popularity and Duration Values**:  
    Replace missing popularity values with 0 and missing `duration_ms` values with the average duration of all tracks in the dataset.

11. **Handle Invalid URLs**:  
    Identify rows where the `track_url` or `artwork_url` columns contain invalid URLs and remove or correct them.

## SQL Scripts

### 1. Identify and Remove Rows with NULL Values

```sql
SELECT * 
FROM dbo.spotify_tracks 
WHERE track_name IS NULL OR artist_name IS NULL OR duration_ms IS NULL;
