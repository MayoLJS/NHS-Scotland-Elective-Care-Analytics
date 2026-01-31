# NHS Scotland Elective Care & Breach Trend Analysis

## Project Overview
This project involved building an end-to-end SQL pipeline to analyze NHS Scotland’s elective care backlog. Using 41,000+ records from Public Health Scotland, I engineered a structured data model to identify systemic regional pressure, calculate clinical wait-time inequality, and track the velocity of national recovery.

**Author:** Olumayowa Osimosu  
**Tech Stack:** SQL Server (T-SQL), SSIS, Excel  

---

## Data Engineering & Pipeline Logic
The raw clinical data presented significant challenges with legacy identifiers and inconsistent schemas. I implemented a defensive engineering approach to ensure data integrity through the following workflow:

1. **Schema Hardening:** Rebuilt staging tables using `VARCHAR(255)` for specialties to prevent truncation and `FLOAT` for wait metrics to maintain decimal precision for statistical modeling.
2. **Idempotent Deployment:** Enforced a clean environment reset pattern using `ALTER DATABASE ... SET SINGLE_USER` to handle active connection locks during the refresh cycle.
3. **Normalization Layer:** Created a master view (`vw_Clean_Treatment_Waits`) to consolidate fragmented Health Board codes (e.g., merging NHS Lanarkshire identifiers) and standardize surgical specialty classifications.

---

## Key Analytical Findings

### 1. Regional Breach Density
Rather than focusing on raw volume, I modeled **Breach Density**—the percentage of the current "Ongoing" waitlist exceeding 52 weeks. This revealed that while urban boards have the largest lists, **NHS Grampian (18.2%)** and **NHS Lothian (17.85%)** face the highest proportional risk.

### 2. Clinical Inequality (The Disparity Metric)
To identify where complex cases are being left behind, I calculated the ratio between the 90th percentile and the median wait times. 
* **Outliers:** Plastic Surgery (3.3x) and Haematology (3.2x) show the highest disparity, indicating that long-term patients in these fields wait over three times longer than the average patient on the same list.



### 3. Recovery Velocity
Using SQL window functions (`LAG`), I quantified the month-over-month momentum of the national recovery effort.
* **Momentum:** After a May 2025 peak of 203,655 breaches, the system reached a recovery velocity of **-9.87%** by November 2025, signaling an accelerating reduction in the total backlog.



---

## The Project in Plain English (Layman's Interpretation)
Essentially, I built a digital "lens" to clean up messy, old healthcare data. This allows us to see exactly who is struggling most and how fast the system is healing. It proves that recovery isn't just about clearing the easy cases; it's about identifying the specific bottlenecks in regions like Grampian or specialties like Plastic Surgery that raw numbers usually hide.

## Data Quality & Operational Latency
The analysis flagged a significant volume of "Not Specified" classifications. This points to **administrative latency**, where patients sit in triage limbo, likely masking the true wait times of specific surgical specialties. 

## Conclusion
By engineering a robust normalization layer, this project moved beyond simple reporting to provide diagnostic intelligence. The data shows that while the national recovery is gaining speed (31% total reduction), specific surgical pathways require targeted intervention to resolve extreme "long-tail" wait times.
