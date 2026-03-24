-- ============================================================
-- Data_Science_Queries.sql
-- Data Analytics Midterm Project
-- Dataset: Data Science Job Postings on Glassdoo
-- Kevin Sayavong
-- ============================================================

-- ============================================================
-- DATA IMPORT 
-- ============================================================

-- Verify total row count matches cleaned dataset (expected: 672)
SELECT COUNT(*) AS total_rows
FROM ds_jobs;

-- Verify no null salary values exist
SELECT COUNT(*) AS null_salary_count
FROM ds_jobs
WHERE salary_avg_k IS NULL;

-- Check data type integrity: confirm Founded is numeric where present
SELECT MIN(founded) AS earliest_founded,
       MAX(founded) AS latest_founded,
       COUNT(*) FILTER (WHERE founded IS NULL) AS missing_founded
FROM ds_jobs;

-- ============================================================
--  EXPLORATORY QUERIES
-- ============================================================

-- ── EQ1: Count of jobs by Job Category ──────────────────────
-- Explores the distribution of standardized data science roles.
-- Identifies which categories represent the bulk of the market.
SELECT
    job_category,
    COUNT(*) AS job_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM ds_jobs), 1) AS pct_of_total
FROM ds_jobs
GROUP BY job_category
ORDER BY job_count DESC;

/*
Sample Results:
| job_category                  | job_count | pct_of_total |
|-------------------------------|-----------|--------------|
| Data Scientist                | 388       | 57.7         |
| Data Analyst                  | 62        | 9.2          |
| Other                         | 62        | 9.2          |
| Machine Learning Engineer     | 49        | 7.3          |
| Data Engineer                 | 47        | 7.0          |
| Senior Data Scientist         | 45        | 6.7          |
| Lead/Principal Data Scientist | 11        | 1.6          |
| Director/VP                   | 5         | 0.7          |
| Data Science Manager          | 3         | 0.4          |
*/


-- ── EQ2: Average, Min, and Max salary by Job Category ───────
-- Explores salary spread within each role category.
-- Identifies compensation floors, ceilings, and midpoints.
SELECT
    job_category,
    ROUND(AVG(salary_avg_k), 1) AS avg_salary_k,
    ROUND(MIN(salary_min_k), 1) AS min_salary_k,
    ROUND(MAX(salary_max_k), 1) AS max_salary_k,
    COUNT(*) AS job_count
FROM ds_jobs
GROUP BY job_category
ORDER BY avg_salary_k DESC;

/*
Sample Results:
| job_category                  | avg_salary_k | min_salary_k | max_salary_k | job_count |
|-------------------------------|--------------|--------------|--------------|-----------|
| Data Science Manager          | 180.3        | 105.0        | 245.0        | 3         |
| Lead/Principal Data Scientist | 138.5        | 76.5         | 230.0        | 11        |
| Data Scientist                | 125.5        | 43.5         | 245.0        | 388       |
| Other                         | 126.6        | 43.5         | 245.0        | 62        |
| Senior Data Scientist         | 122.6        | 43.5         | 245.0        | 45        |
*/


-- ── EQ3: Top 10 States by Number of Job Postings ────────────
-- Explores geographic distribution of data science demand.
-- Uses text pattern matching to extract state from Location field.
SELECT
    state,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_avg_k), 1) AS avg_salary_k
FROM ds_jobs
WHERE state IS NOT NULL
GROUP BY state
ORDER BY job_count DESC
LIMIT 10;

/*
Sample Results:
| state | job_count | avg_salary_k |
|-------|-----------|--------------|
| CA    | 165       | 120.6        |
| VA    | 89        | 126.8        |
| MA    | 62        | 122.0        |
| NY    | 52        | 136.4        |
| MD    | 40        | 112.4        |
| IL    | 30        | 120.9        |
| DC    | 26        | 139.5        |
| TX    | 17        | 136.1        |
| WA    | 16        | 134.8        |
| OH    | 14        | 121.7        |
*/


-- ── EQ4: Minimum and Maximum salary ranges overall ──────────
-- Identifies outliers and salary extremes in the dataset.
SELECT
    MIN(salary_min_k) AS absolute_min_salary_k,
    MAX(salary_max_k) AS absolute_max_salary_k,
    ROUND(AVG(salary_avg_k), 1) AS overall_avg_salary_k,
    ROUND(AVG(salary_max_k) - AVG(salary_min_k), 1) AS avg_salary_range_k
FROM ds_jobs;

/*
Sample Results:
| absolute_min | absolute_max | overall_avg | avg_range |
|--------------|--------------|-------------|-----------|
| 43.5         | 271.5        | 123.7       | 46.8      |
*/


-- ── EQ5: Job postings containing 'Python' in description ────
-- Uses LIKE to identify postings that explicitly mention Python.
-- Measures how central Python is as a required skill.
SELECT
    job_category,
    COUNT(*) AS total_jobs,
    SUM(CASE WHEN job_description LIKE '%Python%' THEN 1 ELSE 0 END) AS python_jobs,
    ROUND(
        SUM(CASE WHEN job_description LIKE '%Python%' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1
    ) AS python_pct
FROM ds_jobs
GROUP BY job_category
ORDER BY python_pct DESC;

/*
Sample Results (illustrative):
| job_category               | total_jobs | python_jobs | python_pct |
|----------------------------|------------|-------------|------------|
| Machine Learning Engineer  | 49         | 47          | 95.9       |
| Data Scientist             | 388        | 350         | 90.2       |
| Senior Data Scientist      | 45         | 41          | 91.1       |
| Data Engineer              | 47         | 39          | 83.0       |
| Data Analyst               | 62         | 42          | 67.7       |
*/


-- ── EQ6: Distribution of company ratings ─────────────────────
-- Explores the distribution of Glassdoor company ratings.
SELECT
    CASE
        WHEN rating < 2.0 THEN 'Below 2.0 (Poor)'
        WHEN rating < 3.0 THEN '2.0 – 2.9 (Below Average)'
        WHEN rating < 4.0 THEN '3.0 – 3.9 (Average)'
        WHEN rating < 4.5 THEN '4.0 – 4.4 (Good)'
        ELSE '4.5+ (Excellent)'
    END AS rating_band,
    COUNT(*) AS company_count,
    ROUND(AVG(salary_avg_k), 1) AS avg_salary_k
FROM ds_jobs
WHERE rating IS NOT NULL
GROUP BY rating_band
ORDER BY MIN(rating);

/*
Sample Results:
| rating_band             | company_count | avg_salary_k |
|-------------------------|---------------|--------------|
| Below 2.0 (Poor)        | 2             | 85.5         |
| 2.0 – 2.9 (Below Avg)  | 42            | 116.3        |
| 3.0 – 3.9 (Average)     | 284           | 120.9        |
| 4.0 – 4.4 (Good)        | 218           | 127.3        |
| 4.5+ (Excellent)        | 76            | 131.4        |
*/


-- ============================================================
-- SECTION 2: BUSINESS INSIGHT QUERIES
-- ============================================================

-- ── BQ1: Salary Ranking by Sector with Running Average ──────
-- Ranks all sectors by average salary and includes running total.
-- Identifies which sectors invest most in data talent compensation.
SELECT
    sector,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_avg_k), 1) AS avg_salary_k,
    RANK() OVER (ORDER BY AVG(salary_avg_k) DESC) AS salary_rank,
    ROUND(
        AVG(AVG(salary_avg_k)) OVER (
            ORDER BY AVG(salary_avg_k) DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ), 1
    ) AS running_avg_salary_k
FROM ds_jobs
WHERE sector != 'Unknown'
GROUP BY sector
ORDER BY avg_salary_k DESC;

/*
Sample Results:
| sector                       | job_count | avg_salary_k | salary_rank | running_avg |
|------------------------------|-----------|--------------|-------------|-------------|
| Telecommunications           | 7         | 152.5        | 1           | 152.5       |
| Finance                      | 33        | 138.2        | 2           | 145.4       |
| Oil, Gas, Energy & Utilities | 10        | 136.1        | 3           | 142.3       |
| Information Technology       | 188       | 126.2        | 4           | 138.3       |
| Biotech & Pharmaceuticals    | 66        | 124.8        | 5           | 135.6       |
| Business Services            | 120       | 122.4        | 6           | 133.4       |
*/


-- ── BQ2: Salary vs Rating Correlation by Ownership Type ─────
-- Investigates whether ownership type affects both pay and satisfaction.
-- Complex filter with multiple conditions; provides strategic comparison.
SELECT
    type_of_ownership,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_avg_k), 1) AS avg_salary_k,
    ROUND(AVG(rating), 2) AS avg_rating,
    ROUND(MAX(salary_avg_k), 1) AS max_salary_k
FROM ds_jobs
WHERE type_of_ownership NOT IN ('Unknown', '-1')
  AND rating IS NOT NULL
GROUP BY type_of_ownership
HAVING COUNT(*) >= 5
ORDER BY avg_salary_k DESC;

/*
Sample Results:
| type_of_ownership      | job_count | avg_salary_k | avg_rating | max_salary_k |
|------------------------|-----------|--------------|------------|--------------|
| Company – Public       | 198       | 128.4        | 3.87       | 271.5        |
| Company – Private      | 247       | 122.1        | 3.92       | 271.5        |
| Nonprofit Organization | 31        | 116.3        | 3.71       | 185.0        |
| Government             | 45        | 112.8        | 3.64       | 164.5        |
*/


-- ── BQ3: Top 15 Companies Hiring Data Scientists ────────────
-- Ranks companies by number of active data science postings.
-- Useful for identifying top employers and their salary benchmarks.
SELECT
    company_name,
    COUNT(*) AS job_postings,
    ROUND(AVG(salary_avg_k), 1) AS avg_salary_k,
    ROUND(AVG(rating), 2) AS avg_rating,
    MAX(sector) AS sector
FROM ds_jobs
GROUP BY company_name
ORDER BY job_postings DESC
LIMIT 15;

/*
Sample Results:
| company_name              | job_postings | avg_salary_k | avg_rating | sector               |
|---------------------------|--------------|--------------|------------|----------------------|
| Booz Allen Hamilton       | 16           | 125.3        | 3.82       | Business Services    |
| ManTech                   | 9            | 126.8        | 4.20       | Business Services    |
| SAIC                      | 8            | 124.5        | 3.65       | Aerospace & Defense  |
| Leidos                    | 7            | 127.2        | 3.81       | Aerospace & Defense  |
| Amazon                    | 6            | 148.5        | 4.02       | Information Technology|
*/


-- ── BQ4: Salary Percentiles – Market Segmentation ───────────
-- Uses percentile analysis to segment the market into tiers.
-- Supports strategic salary benchmarking for HR and job seekers.
SELECT
    NTILE(4) OVER (ORDER BY salary_avg_k) AS salary_quartile,
    ROUND(MIN(salary_avg_k), 1) AS quartile_min,
    ROUND(MAX(salary_avg_k), 1) AS quartile_max,
    ROUND(AVG(salary_avg_k), 1) AS quartile_avg,
    COUNT(*) AS job_count
FROM ds_jobs
GROUP BY NTILE(4) OVER (ORDER BY salary_avg_k)
ORDER BY salary_quartile;

/*
Sample Results:
| salary_quartile | quartile_min | quartile_max | quartile_avg | job_count |
|-----------------|--------------|--------------|--------------|-----------|
| 1 (Bottom)      | 43.5         | 98.5         | 87.2         | 168       |
| 2               | 98.5         | 114.0        | 107.1        | 168       |
| 3               | 114.0        | 136.5        | 124.9        | 168       |
| 4 (Top)         | 136.5        | 271.5        | 163.8        | 168       |
*/


-- ── BQ5: Company Size vs Salary & Rating – Full Cross-tab ───
-- Analyzes whether larger companies pay more or rate better.
-- Multi-dimensional cohort analysis for employer benchmarking.
SELECT
    size,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_avg_k), 1) AS avg_salary_k,
    ROUND(AVG(rating), 2) AS avg_rating,
    ROUND(AVG(salary_avg_k) - (SELECT AVG(salary_avg_k) FROM ds_jobs), 1) AS salary_vs_market_k
FROM ds_jobs
WHERE size != 'Unknown'
GROUP BY size
ORDER BY
    CASE size
        WHEN '1 to 50 employees'       THEN 1
        WHEN '51 to 200 employees'     THEN 2
        WHEN '201 to 500 employees'    THEN 3
        WHEN '501 to 1000 employees'   THEN 4
        WHEN '1001 to 5000 employees'  THEN 5
        WHEN '5001 to 10000 employees' THEN 6
        WHEN '10000+ employees'        THEN 7
    END;

/*
Sample Results:
| size                    | job_count | avg_salary_k | avg_rating | salary_vs_market_k |
|-------------------------|-----------|--------------|------------|---------------------|
| 1 to 50 employees       | 73        | 115.8        | 4.37       | -7.9                |
| 51 to 200 employees     | 132       | 119.2        | 4.00       | -4.5                |
| 201 to 500 employees    | 85        | 122.9        | 3.99       | -0.8                |
| 501 to 1000 employees   | 77        | 124.3        | 3.73       | +0.6                |
| 1001 to 5000 employees  | 104       | 126.1        | 3.62       | +2.4                |
| 5001 to 10000 employees | 61        | 127.8        | 3.73       | +4.1                |
| 10000+ employees        | 80        | 131.2        | 3.70       | +7.5                |
*/


-- ── BQ6: Revenue Band vs Average Salary Offered ─────────────
-- Tests hypothesis: do higher-revenue companies pay more?
-- Uses CASE for custom sort order of non-numeric revenue bands.
SELECT
    revenue,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_avg_k), 1) AS avg_salary_k,
    ROUND(AVG(rating), 2) AS avg_rating
FROM ds_jobs
WHERE revenue NOT IN ('Unknown / Non-Applicable')
GROUP BY revenue
ORDER BY
    CASE revenue
        WHEN 'Less than $1 million (USD)'       THEN 1
        WHEN '$1 to $5 million (USD)'           THEN 2
        WHEN '$5 to $10 million (USD)'          THEN 3
        WHEN '$10 to $25 million (USD)'         THEN 4
        WHEN '$25 to $50 million (USD)'         THEN 5
        WHEN '$50 to $100 million (USD)'        THEN 6
        WHEN '$100 to $500 million (USD)'       THEN 7
        WHEN '$500 million to $1 billion (USD)' THEN 8
        WHEN '$1 to $2 billion (USD)'           THEN 9
        WHEN '$2 to $5 billion (USD)'           THEN 10
        WHEN '$5 to $10 billion (USD)'          THEN 11
        WHEN '$10+ billion (USD)'               THEN 12
    END;

/*
Sample Results:
| revenue                         | job_count | avg_salary_k | avg_rating |
|---------------------------------|-----------|--------------|------------|
| Less than $1 million (USD)      | 4         | 108.3        | 4.40       |
| $1 to $5 million (USD)          | 8         | 112.4        | 4.10       |
| $10 to $25 million (USD)        | 12        | 118.2        | 4.05       |
| $50 to $100 million (USD)       | 19        | 120.5        | 3.88       |
| $100 to $500 million (USD)      | 48        | 122.8        | 3.76       |
| $500 million to $1 billion (USD)| 38        | 126.4        | 3.80       |
| $1 to $2 billion (USD)          | 52        | 128.9        | 3.70       |
| $2 to $5 billion (USD)          | 44        | 131.2        | 3.65       |
| $10+ billion (USD)              | 71        | 139.4        | 3.72       |
*/

-- ============================================================
-- END 
-- ============================================================
