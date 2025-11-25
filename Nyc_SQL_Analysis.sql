create database test_db_ny;
use test_db_ny;
select * from inspection;
select count(*) from inspection;
select count(distinct dba) from inspection;
select boro, count(distinct dba) from inspection group by boro;
select boro, dba from inspection where boro = '0';
select count(distinct boro) from inspection;
select distinct boro from inspection;
select boro, count(boro) from inspection group by boro;
select count(distinct zipcode) from inspection;
select boro, count(distinct zipcode) from inspection group by boro;
select count(distinct cuisine_description) from inspection;
select boro, count(distinct cuisine_description) from inspection group by boro;
select count(distinct inspection_date) from inspection;
select boro, count(distinct inspection_date) from inspection group by boro;
select count(distinct inspection_date) from inspection;
select count(distinct action) from inspection;
select distinct action from inspection;
select count(distinct violation_code) from inspection;
select count(distinct violation_description) from inspection;
select count(distinct critical_flag) from inspection;
select distinct critical_flag from inspection;
select count(distinct score) from inspection;
select count(distinct grade) from inspection;
select distinct grade from inspection;
select count(distinct grade_date) from inspection;
select count(distinct record_date) from inspection;
select distinct(record_date) from inspection;
select count(distinct inspection_type) from inspection;
select count(distinct latitude) from inspection;
select count(distinct longitude) from inspection;
select count(distinct inspection_year) from inspection;
select count(distinct inspection_month) from inspection;
select count(distinct inspection_day) from inspection;
select count(distinct inspection_weekday) from inspection;
select count(distinct inspection_quarter) from inspection;
select count(distinct grade_delay_days) from inspection;
select count(distinct record_delay_days) from inspection;
select count(distinct violation_description) from inspection;


-- Analyze trends in violations, grades, and hygiene performance across boroughs and cuisines.
-- Identify factors associated with poor inspection results.
-- Provide insights for restaurants, consumers, and city officials.

-- 1. What is the distribution of grades (A, B, C) across NYC?
-- 1. Grade Distribution Citywide
select grade, count(grade) from inspection group by grade;

SELECT boro, COUNT(grade) AS total
FROM inspection
WHERE grade IN ('A', 'B', 'C') and boro <> '0'
GROUP BY boro
ORDER BY total DESC;

SELECT 
    boro,
    COUNT(CASE WHEN grade = 'A' THEN 1 END) AS A_grades,
    COUNT(CASE WHEN grade = 'B' THEN 1 END) AS B_grades,
    COUNT(CASE WHEN grade = 'C' THEN 1 END) AS C_grades,
    COUNT(CASE WHEN grade = 'P' THEN 1 END) AS P_grades,
    COUNT(CASE WHEN grade = 'N' THEN 1 END) AS N_grades,
    COUNT(CASE WHEN grade = 'Z' THEN 1 END) AS Z_grades,
    COUNT(*) AS total_grades
FROM inspection
WHERE boro != '0'
GROUP BY boro
ORDER BY total_grades DESC;

select boro, grade from inspection
where boro = '0';

SELECT 
    boro,
    COUNT(CASE WHEN grade = 'A' THEN 1 END) AS A_grades,
    ROUND(COUNT(CASE WHEN grade = 'A' THEN 1 END) * 100.0 / COUNT(*), 2) AS A_percent,
    
    COUNT(CASE WHEN grade = 'B' THEN 1 END) AS B_grades,
    ROUND(COUNT(CASE WHEN grade = 'B' THEN 1 END) * 100.0 / COUNT(*), 2) AS B_percent,
    
    COUNT(CASE WHEN grade = 'C' THEN 1 END) AS C_grades,
    ROUND(COUNT(CASE WHEN grade = 'C' THEN 1 END) * 100.0 / COUNT(*), 2) AS C_percent,
    
    COUNT(CASE WHEN grade = 'P' THEN 1 END) AS P_grades,
    ROUND(COUNT(CASE WHEN grade = 'P' THEN 1 END) * 100.0 / COUNT(*), 2) AS P_percent,

    COUNT(CASE WHEN grade = 'N' THEN 1 END) AS N_grades,
    ROUND(COUNT(CASE WHEN grade = 'N' THEN 1 END) * 100.0 / COUNT(*), 2) AS N_percent,

    COUNT(CASE WHEN grade = 'Z' THEN 1 END) AS Z_grades,
    ROUND(COUNT(CASE WHEN grade = 'Z' THEN 1 END) * 100.0 / COUNT(*), 2) AS Z_percent,

    COUNT(CASE WHEN grade = 'NAN' THEN 1 END) AS NAN_grades,
    ROUND(COUNT(CASE WHEN grade = 'NAN' THEN 1 END) * 100.0 / COUNT(*), 2) AS NAN_percent,

    COUNT(*) AS total_grades,
    -- Sum of all percentages (should equal 100% for each borough)
    ROUND((
        (COUNT(CASE WHEN grade = 'A' THEN 1 END) * 100.0 / COUNT(*)) +
        (COUNT(CASE WHEN grade = 'B' THEN 1 END) * 100.0 / COUNT(*)) +
        (COUNT(CASE WHEN grade = 'C' THEN 1 END) * 100.0 / COUNT(*)) +
        (COUNT(CASE WHEN grade = 'P' THEN 1 END) * 100.0 / COUNT(*)) +
        (COUNT(CASE WHEN grade = 'N' THEN 1 END) * 100.0 / COUNT(*)) +
        (COUNT(CASE WHEN grade = 'Z' THEN 1 END) * 100.0 / COUNT(*)) +
        (COUNT(CASE WHEN grade = 'NAN' THEN 1 END) * 100.0 / COUNT(*))
    ), 2) AS total_percent_sum
FROM inspection
WHERE boro != '0'
GROUP BY boro
ORDER BY total_grades DESC;

-- 2. Which borough has the highest and lowest average grades?
-- → Borough hygiene comparison.
-- 2. Average Grade by Borough
SELECT 
    boro,
    AVG(
        CASE grade
            WHEN 'A' THEN 1
            WHEN 'B' THEN 2
            WHEN 'C' THEN 3
            -- ignore N, Z and anything else by returning NULL
            ELSE NULL
        END
    ) AS avg_grade_score
FROM inspection
WHERE grade IN ('A','B','C')      -- only real grades
  AND boro IS NOT NULL
  AND boro <> '0'
GROUP BY boro
ORDER BY avg_grade_score;

-- 3. Which cuisine types perform best or worst based on grades?
-- → Cuisine hygiene insights.
-- 3. Grade Performance by Cuisine
SELECT cuisine_description, AVG(
        CASE grade
            WHEN 'A' THEN 1
            WHEN 'B' THEN 2
            WHEN 'C' THEN 3
            -- ignore N, Z and anything else by returning NULL
            ELSE NULL
        END
    ) AS avg_grade_score
FROM inspection
WHERE grade IS NOT NULL
GROUP BY cuisine_description
ORDER BY avg_grade_score;
-- (average grade < 1.40 → mostly A grades)
-- Medium-Risk Cuisines (1.40–1.60)
-- High-Risk Cuisines (> 1.60 → many B and C grades)

-- 4. How have average inspection scores changed over time (yearly)?
-- → Long-term sanitation trend.
SELECT 
  YEAR(inspection_date) AS year,
  AVG(score) AS avg_score
FROM inspection
WHERE score IS NOT NULL
GROUP BY YEAR(inspection_date)
ORDER BY year;

-- 5. What percentage of restaurants improve or worsen their grade over time?
-- → Performance tracking.
WITH grade_history AS (
  SELECT 
    camis,
    inspection_date,
    CASE grade 
      WHEN 'A' THEN 1 
      WHEN 'B' THEN 2 
      WHEN 'C' THEN 3 
    END AS grade_num
  FROM inspection
  WHERE grade IN ('A','B','C')
),
grade_change AS (
  SELECT 
    camis,
    grade_num,
    LAG(grade_num) OVER (PARTITION BY camis ORDER BY inspection_date) AS prev_grade
  FROM grade_history
)
SELECT
  SUM(CASE WHEN grade_num < prev_grade THEN 1 ELSE 0 END) AS improved,
  SUM(CASE WHEN grade_num > prev_grade THEN 1 ELSE 0 END) AS worsened,
  COUNT(*) AS total_changes
FROM grade_change
WHERE prev_grade IS NOT NULL;

-- 🟥 B. Violations Analysis
-- 6. What are the top 10 most common violations citywide?
-- → Most frequent issues.
SELECT 
  violation_description,
  COUNT(*) AS count_violations
FROM inspection
WHERE violation_description <> 'No violation listed'
GROUP BY violation_description
ORDER BY count_violations DESC
LIMIT 10;

-- 7. Which cuisines have the highest number of critical violations?
-- → High-risk cuisines.
SELECT 
  cuisine_description,
  COUNT(*) AS critical_count
FROM inspection
WHERE critical_flag = 'CRITICAL'
GROUP BY cuisine_description
ORDER BY critical_count DESC;

-- 8. Which borough has the most severe violations?
-- → Public health hotspots.
SELECT 
  boro,
  COUNT(*) AS critical_count
FROM inspection
WHERE critical_flag = 'CRITICAL'
GROUP BY boro
ORDER BY critical_count DESC;

-- 9. For each restaurant, what is the average number of violations per inspection?
-- → Restaurant-level hygiene evaluation.
SELECT 
  camis,
  dba,
  AVG(violation_count) AS avg_violations
FROM (
  SELECT 
    camis,
    dba,
    inspection_date,
    COUNT(violation_code) AS violation_count
  FROM inspection
  GROUP BY camis, dba, inspection_date
) t
GROUP BY camis, dba
ORDER BY avg_violations DESC;

-- 10. What violation codes are most strongly associated with poor grades (B, C)?
-- → Factors driving bad hygiene outcomes.
SELECT 
  violation_code,
  violation_description,
  COUNT(*) AS bad_grade_count
FROM inspection
WHERE grade IN ('B','C')
GROUP BY violation_code, violation_description
ORDER BY bad_grade_count DESC
LIMIT 20;

-- 🟩 C. Inspection Trends
-- 11. Which year/month has the highest inspection count?
-- → Workload + seasonal analysis.
SELECT 
  YEAR(inspection_date) AS year,
  MONTH(inspection_date) AS month,
  COUNT(*) AS total_inspections
FROM inspection
GROUP BY YEAR(inspection_date), MONTH(inspection_date)
ORDER BY total_inspections DESC;

-- 12. Do certain weekdays have more severe inspections?
-- → Operational scheduling insights.
SELECT 
  DAYNAME(inspection_date) AS weekday,
  AVG(score) AS avg_score
FROM inspection
WHERE score IS NOT NULL
GROUP BY DAYNAME(inspection_date)
ORDER BY avg_score DESC;

-- 🟧 D. Restaurant Performance
-- 13. Which restaurants consistently score poorly? (repeat offenders)
-- → Important for city officials & consumers.
SELECT 
  camis,
  dba,
  COUNT(*) AS bad_inspections
FROM inspection
WHERE grade IN ('B','C')
GROUP BY camis, dba
HAVING bad_inspections >= 3
ORDER BY bad_inspections DESC;

-- 14. Which restaurants have the best hygiene (consistently A & low score)?
SELECT 
  camis,
  dba,
  COUNT(*) AS a_grades
FROM inspection
WHERE grade = 'A'
GROUP BY camis, dba
HAVING COUNT(*) >= 3
ORDER BY a_grades DESC;

-- 15. Identify new restaurants (first 6 months) and compare their performance.
-- 🟨 E. Geographic Hygiene Insights
WITH first_inspection AS (
  SELECT camis, MIN(inspection_date) AS first_date
  FROM inspection
  GROUP BY camis
),
early_inspections AS (
  SELECT i.*
  FROM inspection i
  JOIN first_inspection f ON i.camis = f.camis
  WHERE i.inspection_date <= DATE_ADD(f.first_date, INTERVAL 6 MONTH)
)
SELECT 
  AVG(score) AS avg_new_restaurant_score,
  AVG(CASE grade WHEN 'A' THEN 1 WHEN 'B' THEN 2 WHEN 'C' THEN 3 END) AS avg_new_grade
FROM early_inspections
WHERE score IS NOT NULL OR grade IN ('A','B','C');

-- 16. What are the average scores by borough?
-- → Brooklyn vs Manhattan vs Queens, etc.
SELECT 
  boro,
  AVG(score) AS avg_score
FROM inspection
WHERE score IS NOT NULL
GROUP BY boro
ORDER BY avg_score DESC;