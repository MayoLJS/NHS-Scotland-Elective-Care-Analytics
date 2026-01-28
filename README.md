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

## 📈 Analytical Framework
I designed KPI queries around **System Pressure**, moving beyond raw counts to calculate the **Breach Density Metric**:

$$Breach\ Density = \left( \frac{Waits\ Over\ 52\ Weeks}{Total\ Waits} \right) \times 100$$

### Regional Pressure Findings
| Health Board | Raw Volume | Breach Density | Status |
| :--- | :--- | :--- | :--- |
| **NHS Tayside** | 1,072,264 | 9.19% | High Load / Controlled |
| **NHS Lothian** | 617,831 | 17.06% | **High Systemic Pressure** |
| **NHS Grampian** | 668,522 | 16.97% | **High Systemic Pressure** |



### Clinical Outliers (90th Percentile "Gravity")
The 90th percentile signals severe bottlenecks for the most delayed 10% of patients:
* **ENT (Greater Glasgow & Clyde)**: 983 days (2.7 years).
* **Rheumatology (Fife)**: 930 days.
* **Dermatology (Grampian)**: 874 days.
* **National Urology Average**: 497.9 days (Critical failure of the 12-week Guarantee).

---

## ⏱ Time-Series Trend (Nov 2023 – Nov 2025)
Longitudinal tracking identified a clear "Crisis and Recovery" arc:
* **Crisis Peak**: May 2025 reached a record 203,655 long-term breaches.
* **Inflection Point**: June 2025 marked the beginning of a sustained downward trend.
* **Recovery Status**: By Nov 2025, breaches fell to 140,415—a **31% reduction** in six months.



---

## 🚩 Data Quality Flag: Operational Latency
The analysis exposed that the largest breach group was **"Not Specified / Other"** (e.g., 18,831 in Glasgow). This highlights **Administrative Latency**: patients sit in a "Data Limbo" during triage, meaning real specialty wait times may be higher than reported once backlogs are processed.

## 🏁 Conclusion
This project converted raw public health data into a high-fidelity analytical model. It exposed that **volume does not equal risk** and that while national recovery is measurable (31% improvement), specific specialties like ENT and Dermatology remain in critical failure.
