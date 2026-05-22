# Nigeria Healthcare Infrastructure & Disease Burden Analysis
### A SQL-based investment prioritisation framework

---

## Project Overview

This project applies structured SQL analysis to evaluate the state of healthcare infrastructure across Nigeria's 36 states and the FCT, cross-referenced against national disease burden trends for Malaria and Tuberculosis. By moving beyond surface-level facility counts and integrating population-adjusted metrics, ownership equity analysis, and specialist capacity mapping, this analysis produces a composite **Healthcare Investment Priority Score (HIPS)** — a data-driven tool designed to support strategic resource allocation decisions at the state level.

The intended audience includes public health programme officers, government health agencies, NGOs, and donor organisations seeking an evidence-based framework for prioritising healthcare investment in Nigeria.

---

## Problem Statement

Nigeria's healthcare crisis is frequently reduced to a single narrative: there are not enough facilities. While this is partially true, it obscures a more complex reality. Raw facility counts create a misleading picture; a state may register hundreds of facilities while the majority are inaccessible to low-income populations due to private ownership, geographic concentration, or the near-total absence of specialist (tertiary) care.

This analysis interrogates that complexity. It asks not just *how many* facilities exist, but *who can access them*, *what level of care they provide*, and *which states face the most acute convergence of infrastructural gaps*. The output generates a prioritisation instrument.

---

## Data Sources

| Dataset | Source | Description |
|---|---|---|
| Nigeria Health Facility Registry (GRID3) | [Humanitarian Data Exchange](https://data.humdata.org/dataset/nigeria-health-facilities) | 51,022 registered health facilities with state, LGA, ownership, facility level, and geocoordinates. Validated and updated November 2024. |
| Malaria Indicators — Nigeria | [WHO Global Health Observatory](https://data.humdata.org/dataset/who-data-for-nga) | National-level malaria indicators including confirmed cases, estimated incidence per 1,000, and mortality rate (2000–2024). |
| Tuberculosis Indicators — Nigeria | [WHO Global Health Observatory](https://data.humdata.org/dataset/who-data-for-nga) | National-level TB indicators including incidence per 100,000, treatment coverage, and HIV-positive TB burden (1995–2024). |
| Population Forecasts by State | [National Bureau of Statistics (NBS)](https://nigerianstat.gov.ng) | State-level population projections (2006–2016) based on the 2006 National Population Commission census. |

> **Data Limitation Note:** Population figures are projections derived from the 2006 census and extend only to 2016. All population-adjusted metrics in this analysis use 2016 as the baseline year. This is a known limitation and is acknowledged where relevant in the interpretation of results. Disease data is available at the national level only; state-level disease disaggregation was not available from public WHO sources at the time of analysis.

---

## Tools & Technologies

- **PostgreSQL** — Relational database management and all analytical querying
- **pgAdmin 4** — Query execution and database administration interface
- **Python** (pandas, psycopg2, openpyxl) — Data ingestion and loading pipeline
- **Power BI** — Dashboard visualisation of final outputs *(in development)*

---

## Database Schema

```
states (state_id, state_name, geopolitical_zone)
    │
    ├──< population (state_name, year, total_population)
    │
    └──< facilities (facility_id, state_name, lga_name, ward,
                     ownership, ownership_type, facility_level,
                     latitude, longitude)

disease_indicators (indicator_id, disease, indicator_code,
                    indicator_name, year, numeric_value)
```

The `states` table serves as the master reference ensuring naming consistency across joins. The `disease_indicators` table is standalone — operating at national level and not joined to state-level tables.

---

## Analysis Structure

The analysis is organised into four progressive layers, each building on the last, moving from descriptive inventory through diagnostic equity analysis to trend examination and, finally, composite scoring.

### Layer 1 — Facility Inventory & Baseline

**Q1. How many health facilities does each state have?**
Lagos records the highest facility count; Bayelsa the lowest. However, raw counts alone are analytically insufficient without population context.

**Q2. How many facilities exist per 100,000 people — and which states are critically underserved?**
When adjusted for population, the access picture changes substantially. Critically, when the analysis is restricted to secondary and tertiary facilities only, a majority of states fall into the *Critical* or *Highly Critical* service tiers — exposing the degree to which primary health posts inflate surface-level coverage statistics.

### Layer 2 — Access & Equity Analysis

**Q3. What is the public-versus-private ownership split per state?**
Lagos is the only state classified as *High Equity Risk*, driven by a disproportionate concentration of private facilities — infrastructure that exists but remains financially inaccessible to the majority of its 15+ million residents.

**Q4. Which states have zero or only one tertiary facility?**
Only two states fall at or below one tertiary facility: the FCT (zero) and Gombe (one). The FCT result warrants data quality scrutiny as it is unlikely that Nigeria's capital has no registered tertiary facility, suggesting possible misclassification or registration under an alternate ownership category.

### Layer 3 — Disease Trend Analysis

**Q5. How have confirmed malaria cases and estimated incidence changed year-over-year?**
Absolute confirmed cases rose from approximately 8 million in 2015 to over 24 million at peak yet estimated incidence per 1,000 population declined steadily over the same period. This divergence reveals that Nigeria's population growth rate outpaces the spread of malaria; the disease is becoming relatively less prevalent even as absolute case numbers rise. A notable 7% drop in confirmed cases in 2020 reflects COVID-19-driven disruptions to health facility attendance and reporting, not an epidemiological improvement.

**Q6. How does TB incidence track against treatment coverage over time?**
TB incidence has remained essentially flat across the entire observation period despite treatment coverage rising from approximately 23% in the early 2010s to 79% by 2024. This stagnation, in the face of improving coverage, indicates that treatment is reaching those already diagnosed but community transmission remains uninterrupted. The underlying structural drivers of TB in Nigeria (overcrowding, poverty, HIV co-infection) are not addressed by treatment coverage alone.

### Layer 4 — Healthcare Investment Priority Score (HIPS)

**Q7. Which states require the most urgent healthcare investment?**
The HIPS composite score ranks all 37 states by infrastructure need. Kano ranks first; Anambra is the only state classified as *Stable*.

---

## The HIPS Scoring Framework

The Healthcare Investment Priority Score (HIPS) is a composite index constructed to move beyond single-metric rankings and capture the multi-dimensional nature of healthcare access failure. A state does not score Critical simply because it has few facilities, it scores Critical because multiple dimensions of access are simultaneously compromised.

**Three components feed the score:**

| Component | Weight | Rationale |
|---|---|---|
| Facilities per 100,000 (secondary & tertiary only) | 50% | The primary determinant of physical access to meaningful care |
| Private facility percentage | 30% | A proxy for affordability barriers; high private concentration excludes low-income populations |
| Tertiary facility count | 20% | Reflects specialist and surgical capacity — absent in many states |

Each component is normalised to a 0–100 scale where **100 represents the greatest need**. The normalisation inverts access and tertiary metrics (more facilities = lower need score) while preserving the direction of the equity metric (more private = higher risk score). The three normalised scores are then combined using the weights above.

**Priority Tiers:**

| Tier | HIPS Score | Interpretation |
|---|---|---|
| 🔴 Critical | ≥ 75 | Severe, multi-dimensional infrastructure deficit. Emergency investment warranted. |
| 🟠 High | 55 – 74 | Significant gaps across multiple dimensions. Targeted programme intervention required. |
| 🟡 Moderate | 35 – 54 | Partial gaps. Condition-specific investment recommended. |
| 🟢 Stable | < 35 | Relatively better positioned. Maintenance and monitoring appropriate. |

---

## Key Findings

- **Over 64% of Nigerian states (24 of 37) fall within the Critical investment tier**, indicating that the healthcare infrastructure deficit is not isolated to specific regions; it is a systemic national challenge.
- **Kano State ranks first** in investment priority, reflecting its combination of high population burden, limited secondary/tertiary capacity, and high public facility dependence that nevertheless remains inadequate relative to population size.
- **Lagos, Nigeria's most economically developed state, scores Critical.** This reflects the private facility dominance penalty. Lagos has the most facilities of any state in absolute terms, yet over 60% are privately owned, creating a structural affordability barrier for the majority of its population.
- **Anambra is the only state classified as Stable**, a finding consistent with the South East's history of strong community-driven healthcare investment and a relatively manageable population-to-facility ratio.
- **Stripping primary health facilities from the access analysis dramatically changes the service tier picture.** When only secondary and tertiary facilities are counted, states that appeared adequately served fall sharply into critical and highly critical categories, demonstrating that primary health posts cannot substitute for specialist care capacity.
- **TB treatment coverage has improved significantly (23% → 79% between 2010 and 2024), yet TB incidence has not declined.** This signals that Nigeria's TB response is successfully managing diagnosed cases but failing to interrupt community transmission — a structural problem requiring upstream intervention beyond treatment alone.
- **The 2020 malaria case dip reflects COVID-19 disruption, not epidemiological progress** — a critical distinction for programme officers interpreting trend data for resource allocation decisions.

---

## Limitations & Next Steps

**Known Limitations:**
- Population data is based on 2006 census projections capped at 2016. Results would be meaningfully refined using 2023 census data, which is now available from the NBS.
- Disease indicators are available at the national level only. State-level disease disaggregation essential for a true burden-versus-capacity analysis was not available from public WHO sources at the time of this analysis.
- The FCT tertiary facility count (zero) is inconsistent with ground-level reality and likely reflects a data registration issue in the GRID3 dataset rather than an actual absence of tertiary care.s

---

## Repository Structure

```
nigeria-healthcare-sql-analysis/
│
├── data/
│   └── raw/ 
|        └──  original dataset                              
|        # Original source datasets
│
├── queries/
│   ├── 01_facility_count_by_state.sql
│   ├── 02_facilities_per_100k_access_tiers.sql
│   ├── 03_public_vs_private_equity_risk.sql
│   ├── 04_tertiary_facility_gap.sql
│   ├── 05_malaria_trend_analysis.sql
│   ├──06_tb_incidence_vs_treatment_coverage.sql
├──07_hips_healthcare_investment_priority_score.sql
│
├── outputs/                        # CSV exports of all query results
│
└── README.md
```

---

*Analysis conducted using PostgreSQL. Data sourced from GRID3, WHO Global Health Observatory, and the Nigeria National Bureau of Statistics. All population metrics use 2016 as the baseline year.*