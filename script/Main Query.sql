/* WARNING: RUNNING THIS ENTIRE SCRIPT WILL RESET THE DATABASE AND WIPE ALL DATA.
To run individual analysis sections, highlight the specific Phase and press F5.
*/

-- If you accidentally hit 'Execute' without highlighting, 
-- this line prevents the rest of the script from running:
-- RAISERROR('Execution stopped. Please highlight a specific section to run.', 20, 1) WITH LOG;

/*
-----------------------------------------------------------------------------------------
PROJECT: NHS Scotland Elective Care Analysis
STAKEHOLDER GOAL: To analyze waiting list pressures and 'Breach' trends across Scotland.
DEVELOPER: Olumayowa Osimosu
DOCUMENTATION: Data mappings derived from Public Health Scotland (PHS) Open Data Dictionary.
Source: https://www.opendata.nhs.scot/dataset/specialty-codes
Note: These mappings ensure the technical dataset aligns with clinical 
departmental reporting standards.
-----------------------------------------------------------------------------------------
*/

-- =============================================
-- PHASE 1.0: Environment Setup
-- =============================================
USE master;
GO

IF EXISTS (SELECT * FROM sys.databases WHERE name = 'NHS_WaitingTimes_Project')
BEGIN
    ALTER DATABASE NHS_WaitingTimes_Project SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE NHS_WaitingTimes_Project;
END
GO

CREATE DATABASE NHS_WaitingTimes_Project;
GO

USE NHS_WaitingTimes_Project;
GO

CREATE TABLE [dbo].[Stg_Treatment_Waits](
    [MonthEnding] [int] NOT NULL,         
    [HBT] [varchar](50) NOT NULL,         -- Expanded for full Health Board names
    [PatientType] [varchar](100),         
    [WaitType] [varchar](50),             
    [Specialty] [varchar](255),           -- Expanded for long clinical descriptions
    [Waits] [int] DEFAULT 0,              
    [WaitsOver12Weeks] [int] DEFAULT 0,   
    [WaitsOver52Weeks] [int] DEFAULT 0,   
    [MedianWait] [float] NULL,            
    [90thPercentile] [float] NULL         
);
GO

-- =============================================
-- PHASE 2.0: Data Transformation (The Analysis View)
-- =============================================
-- We create one Master View to handle all Mapping/Cleaning logic
GO
CREATE OR ALTER VIEW vw_Clean_Treatment_Waits AS
SELECT 
    MonthEnding,
    CASE 
        WHEN HBT IN ('S08000022', 'S08000032') THEN 'NHS Lanarkshire'
        WHEN HBT IN ('S08000030', 'S27000001') THEN 'NHS Golden Jubilee'
        WHEN HBT IN ('S08000016', 'SB0801') THEN 'NHS Borders'
        WHEN HBT IN ('S08000028', 'S08000029') THEN 'NHS Fife'
        WHEN HBT = 'S08000015' THEN 'NHS Lothian'
        WHEN HBT = 'S08000017' THEN 'NHS Dumfries & Galloway'
        WHEN HBT = 'S08000019' THEN 'NHS Forth Valley'
        WHEN HBT = 'S08000020' THEN 'NHS Grampian'
        WHEN HBT = 'S08000021' THEN 'NHS Highland'
        WHEN HBT = 'S08000023' THEN 'NHS Orkney'
        WHEN HBT = 'S08000024' THEN 'NHS Greater Glasgow & Clyde'
        WHEN HBT = 'S08000025' THEN 'NHS Shetland'
        WHEN HBT = 'S08000026' THEN 'NHS Western Isles'
        WHEN HBT = 'S08000027' THEN 'NHS Ayrshire & Arran'
        WHEN HBT = 'S08000031' THEN 'NHS Tayside'
        WHEN HBT = 'S92000003' THEN 'Scotland (National Total)'
        ELSE HBT 
    END AS Health_Board_Name,
    CASE 
        WHEN Specialty IN ('C11', 'AH') THEN 'Trauma & Orthopaedics'
        WHEN Specialty = 'CB' THEN 'Urology'
        WHEN Specialty = 'C9' THEN 'Plastic Surgery'
        WHEN Specialty = 'D4' THEN 'ENT'
        WHEN Specialty = 'C5' THEN 'Oral & Maxillofacial Surgery'
        WHEN Specialty = 'F2' THEN 'Gynaecology'
        WHEN Specialty = 'C8' THEN 'General Surgery'
        WHEN Specialty = 'D3' THEN 'Ophthalmology'
        WHEN Specialty = 'AG' THEN 'Cardiology'
        WHEN Specialty = 'C4' THEN 'Haematology'
        WHEN Specialty = 'C6' THEN 'Infectious Diseases'
        WHEN Specialty = 'A7' THEN 'Dermatology'
        WHEN Specialty = 'C7' THEN 'Medical Oncology'
        WHEN Specialty = 'A9' THEN 'Occupational Medicine'
        WHEN Specialty = 'C13' THEN 'Nephrology'
        WHEN Specialty = 'CA' THEN 'Surgical Oncology'
        WHEN Specialty = 'C12' THEN 'Rheumatology'
        WHEN Specialty = 'Z9' THEN 'Not Specified / Other'
        ELSE Specialty 
    END AS Specialty_Name,
    PatientType,
    WaitType,
    Waits,
    WaitsOver12Weeks,
    WaitsOver52Weeks,
    MedianWait,
    [90thPercentile]
FROM [dbo].[Stg_Treatment_Waits];
GO

-- =============================================
-- PHASE 3.0: Data Validation (Data Quality Checks)
-- =============================================
-- Check 1: Row Count Check
SELECT COUNT(*) AS Total_Rows_Loaded FROM [dbo].[Stg_Treatment_Waits];

-- Check 2: NULL Value Scan
SELECT 
    SUM(CASE WHEN MonthEnding IS NULL THEN 1 ELSE 0 END) AS Missing_Dates,
    SUM(CASE WHEN HBT IS NULL THEN 1 ELSE 0 END) AS Missing_Boards,
    SUM(CASE WHEN Waits IS NULL THEN 1 ELSE 0 END) AS Missing_Values
FROM [dbo].[Stg_Treatment_Waits];

-- =============================================
-- PHASE 4.0: Business Intelligence Queries
-- =============================================

-- 4.1 Top 5 High-Pressure Boards (Longest 52-Week Lists)
SELECT TOP 5
    Health_Board_Name AS [Regional Health Board],
    FORMAT(SUM(WaitsOver52Weeks), 'N0') AS [Total 1-Year Breaches],
    CAST(ROUND(CAST(SUM(WaitsOver52Weeks) AS FLOAT) / NULLIF(SUM(Waits), 0) * 100, 2) AS VARCHAR) + '%' AS [List Pressure %]
FROM vw_Clean_Treatment_Waits
WHERE Health_Board_Name <> 'Scotland (National Total)'
GROUP BY Health_Board_Name
ORDER BY SUM(WaitsOver52Weeks) DESC;

-- 4.2 Specialty Bottle-necks (90th Percentile)
SELECT TOP 10
    Specialty_Name,
    ROUND(AVG([90thPercentile]), 1) AS Avg_90th_Pctl_Days
FROM vw_Clean_Treatment_Waits
WHERE WaitType = 'Ongoing'
GROUP BY Specialty_Name
ORDER BY Avg_90th_Pctl_Days DESC;

-- 4.3 National Trend (Tracking Recovery)
SELECT 
    MonthEnding,
    SUM(WaitsOver52Weeks) AS Total_Long_Waiters
FROM vw_Clean_Treatment_Waits
WHERE Health_Board_Name = 'Scotland (National Total)'
  AND WaitType = 'Ongoing'
GROUP BY MonthEnding
ORDER BY MonthEnding DESC;

-- 4.4 Final Master Export (For Visualization)
SELECT 
    Health_Board_Name,
    Specialty_Name,
    SUM(Waits) AS Current_Waitlist,
    SUM(WaitsOver12Weeks) AS Breaches_12Wk,
    SUM(WaitsOver52Weeks) AS Breaches_52Wk,
    ROUND(AVG([90thPercentile]), 0) AS Avg_Wait_Days
FROM vw_Clean_Treatment_Waits
WHERE MonthEnding = 20251130 
  AND WaitType = 'Ongoing'
  AND Health_Board_Name <> 'Scotland (National Total)'
GROUP BY Health_Board_Name, Specialty_Name
ORDER BY Breaches_52Wk DESC;