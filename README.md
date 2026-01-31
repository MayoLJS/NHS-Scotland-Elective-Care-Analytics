# NHS Scotland Elective Care & Breach Trend Analysis

## 📊 Project Overview
This project focused on end-to-end data engineering and analysis of NHS Scotland elective care waiting times. I transformed raw clinical data into a structured, analysis-ready model to identify system pressure, normalize fragmented legacy codes, and track national recovery trends for KPI reporting.

**Author:** Olumayowa Osimosu  
**Environment:** Microsoft SQL Server 2022 (SSMS), SQL Server Integration Services (SSIS)  
**Dataset:** Public Health Scotland Open Data (~41,000+ records)

---

## 🛠 Data Engineering & Architecture

### Schema Optimization
Initial ETL phases exposed schema weaknesses where string truncation stopped the load. I rebuilt the staging design to protect data quality:
* **Specialty to `VARCHAR(255)`**: Prevented loss of complex clinical descriptions.
* **Wait Metrics to `FLOAT`**: Preserved decimal precision for 90th Percentile metrics, essential for statistical accuracy.

### Defensive Deployment
To ensure idempotent runs and reduce failed refresh cycles, I enforced a clean deployment pattern:
* **Logic**: Used `ALTER DATABASE ... SET SINGLE_USER WITH ROLLBACK IMMEDIATE` to handle database locks during re-deployment.

---

## ⚙️ Normalization Engine
The raw dataset contained legacy identifiers that would have fragmented the report. I developed a reusable abstraction layer: `CREATE OR ALTER VIEW vw_Clean_Treatment_Waits`.

* **Geographic Consolidation**: Merged legacy codes for **NHS Lanarkshire** (S08000022 & S08000032) and **NHS Fife** into single reporting entities.
* **Clinical Grouping**: Standardized specialty codes (e.g., merging AH and C11 into **Trauma & Orthopaedics**) to prevent under-reporting of surgical volumes.

---

## 📈 Advanced Analytical Framework
I transitioned from basic descriptive counts to **Diagnostic KPIs** to better understand the "Experience of Delay" and operational risk.

### 1. Breach Density (Identifying Systemic Risk)
By isolating "Ongoing" waitlists, I calculated the percentage of the list exceeding the 52-week mark. This revealed that while volume is high in cities, **NHS Grampian (18.2%)** and **NHS Lothian (17.85%)** face the highest proportional pressure.



### 2. The Inequality Ratio (Median vs. 90th Percentile)
I engineered an **Inequality Ratio** ($90^{th}\ Pctl\ /\ Median$) to identify specialties where the "long-tail" of patients is stagnant compared to the average.
* **Plastic Surgery (3.3x)** and **Haematology (3.2x)** exhibit the highest inequality, signaling that complex cases are being disproportionately delayed compared to routine triage.



---

## ⏱ Recovery Velocity: Time-Series Analysis
Using SQL Window Functions (`LAG`), I quantified the **Month-over-Month (MoM) Recovery Velocity** of the national backlog.

* **Crisis Peak**: May 2025 reached a record 203,655 breaches.
* **Accelerating Momentum**: Recovery efficiency peaked in November 2025 with a **9.87% MoM reduction**, proving that the velocity of clearing the backlog is increasing significantly as recovery plans mature.



---

## 🚩 Data Quality Flag: Operational Latency
The analysis exposed that the largest breach group was **"Not Specified / Other"** (e.g., 18,831 in Glasgow). This highlights **Administrative Latency**: patients sitting in "Data Limbo" during triage, which likely masks higher true wait times in specific surgical specialties once processed.

## 🏁 Conclusion
The improved analysis proves that **volume does not equal risk**. While the national recovery is accelerating (31% total reduction), the high **Inequality Ratios** in specialties like Plastic Surgery and Urology suggest that the "tail-end" of the waitlist requires targeted resource allocation rather than broad administrative processing.
