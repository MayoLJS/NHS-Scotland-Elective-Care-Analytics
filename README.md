# NHS Scotland Elective Care & Breach Trend Analysis

## 📊 Project Overview
[cite_start]This project focused on end-to-end data engineering and analysis of NHS Scotland elective care waiting times[cite: 6]. [cite_start]I transformed raw clinical data into a structured, analysis-ready model to identify system pressure, normalize fragmented legacy codes, and track national recovery trends for KPI reporting[cite: 7, 8, 9, 11].

[cite_start]**Author:** Olumayowa Osimosu [cite: 2]  
[cite_start]**Environment:** Microsoft SQL Server 2022 (SSMS), SQL Server Integration Services (SSIS) [cite: 3]  
[cite_start]**Dataset:** Public Health Scotland Open Data (~41,000+ records) [cite: 4]

---

## 🛠 Data Engineering & Architecture

### Schema Optimization
[cite_start]Initial ETL phases exposed schema weaknesses where string truncation stopped the load[cite: 14]. [cite_start]I rebuilt the staging design to protect data quality[cite: 15]:
* [cite_start]**Specialty to `VARCHAR(255)`**: Prevented loss of complex clinical descriptions[cite: 16].
* [cite_start]**Wait Metrics to `FLOAT`**: Preserved decimal precision for 90th Percentile metrics, essential for statistical accuracy[cite: 17].

### Defensive Deployment
[cite_start]To ensure idempotent runs and reduce failed refresh cycles, I enforced a clean deployment pattern[cite: 19]:
* [cite_start]**Logic**: Used `ALTER DATABASE ... SET SINGLE_USER WITH ROLLBACK IMMEDIATE` to handle database locks during re-deployment[cite: 20].

---

## ⚙️ Normalization Engine
[cite_start]The raw dataset contained legacy identifiers that would have fragmented the report[cite: 22]. [cite_start]I developed a reusable abstraction layer: `CREATE OR ALTER VIEW vw_Clean_Treatment_Waits`[cite: 23].

* [cite_start]**Geographic Consolidation**: Merged legacy codes for **NHS Lanarkshire** (`S08000022` & `S08000032`) and **NHS Fife** into single reporting entities[cite: 24].
* [cite_start]**Clinical Grouping**: Standardized specialty codes (e.g., merging `AH` and `C11` into **Trauma & Orthopaedics**) to prevent under-reporting of surgical volumes[cite: 25].

---

## 📈 Analytical Framework
[cite_start]I designed KPI queries around **System Pressure**, moving beyond raw counts to calculate the **Breach Density Metric**[cite: 27]:

$$Breach\ Density = \left( \frac{Waits\ Over\ 52\ Weeks}{Total\ Waits} \right) \times 100$$
[cite_start][cite: 28]

### Regional Pressure Findings
| Health Board | Raw Volume | Breach Density | Status |
| :--- | :--- | :--- | :--- |
| **NHS Tayside** | 1,072,264 | 9.19% | High Load / Controlled |
| **NHS Lothian** | 617,831 | 17.06% | **High Systemic Pressure** |
| **NHS Grampian** | 668,522 | 16.97% | **High Systemic Pressure** |
[cite_start][cite: 30]



### Clinical Outliers (90th Percentile "Gravity")
[cite_start]The 90th percentile signals severe bottlenecks for the most delayed 10% of patients[cite: 32]:
* [cite_start]**ENT (Greater Glasgow & Clyde)**: 983 days (2.7 years)[cite: 33].
* [cite_start]**Rheumatology (Fife)**: 930 days[cite: 34].
* [cite_start]**Dermatology (Grampian)**: 874 days[cite: 35].
* [cite_start]**National Urology Average**: 497.9 days (Critical failure of the 12-week Guarantee)[cite: 36].

---

## ⏱ Time-Series Trend (Nov 2023 – Nov 2025)
[cite_start]Longitudinal tracking identified a clear "Crisis and Recovery" arc[cite: 38]:
* [cite_start]**Crisis Peak**: May 2025 reached a record 203,655 long-term breaches[cite: 39].
* [cite_start]**Inflection Point**: June 2025 marked the beginning of a sustained downward trend[cite: 40].
* [cite_start]**Recovery Status**: By Nov 2025, breaches fell to 140,415—a **31% reduction** in six months[cite: 41].



---

## 🚩 Data Quality Flag: Operational Latency
[cite_start]The analysis exposed that the largest breach group was **"Not Specified / Other"** (e.g., 18,831 in Glasgow)[cite: 43]. [cite_start]This highlights **Administrative Latency**: patients sit in a "Data Limbo" during triage, meaning real specialty wait times may be higher than reported once backlogs are processed[cite: 44].

## 🏁 Conclusion
[cite_start]This project converted raw public health data into a high-fidelity analytical model[cite: 46]. [cite_start]It exposed that **volume does not equal risk** and that while national recovery is measurable (31% improvement), specific specialties like ENT and Dermatology remain in critical failure[cite: 47].
