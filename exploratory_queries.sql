USE aid_staging;

SELECT 'stg_maddison' AS source_table, COUNT(*) AS n_rows, MIN(year) as min_year, MAX(year) as max_year FROM stg_maddison
UNION ALL
SELECT 'stg_wdi', COUNT(*), MIN(year), MAX(year) FROM stg_wdi
UNION ALL
SELECT 'stg_events', COUNT(*), MIN(year), MAX(year) FROM stg_events;

SELECT country_iso3, country_name, COUNT(*) AS n_rows
FROM stg_maddison
GROUP BY country_iso3, country_name
ORDER BY country_iso3;

SELECT country_iso3, country_name, COUNT(*) AS n_rows
FROM stg_wdi
GROUP BY country_iso3, country_name
ORDER BY country_iso3;

SELECT country_iso3, country_name, COUNT(*) AS n_rows
FROM stg_events
GROUP BY country_iso3, country_name
ORDER BY country_iso3;

SELECT country_iso3, country_name,
       COUNT(*) AS n_events,
       ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM stg_events), 1) AS pct_of_events
FROM stg_events
GROUP BY country_iso3, country_name
ORDER BY n_events DESC;

SELECT indicator_code, indicator_name, COUNT(*) AS n_rows,
       COUNT(DISTINCT country_iso3) AS n_countries,
       MIN(year) AS first_year, MAX(year) AS last_year,
       MIN(value) AS min_value, MAX(value) AS max_value
FROM stg_maddison
GROUP BY indicator_code, indicator_name;

SELECT indicator_code, indicator_name, COUNT(*) AS n_rows,
       COUNT(DISTINCT country_iso3) AS n_countries,
       MIN(year) AS first_year, MAX(year) AS last_year,
       MIN(value) AS min_value, MAX(value) AS max_value
FROM stg_wdi
GROUP BY indicator_code, indicator_name
ORDER BY indicator_code;

SELECT country_iso3, indicator_code,
       MIN(year) AS first_year, MAX(year) AS last_year, COUNT(*) AS n_years,
       MAX(year) - MIN(year) + 1 - COUNT(*) AS missing_years
FROM stg_maddison
GROUP BY country_iso3, indicator_code
ORDER BY country_iso3, indicator_code;

SELECT country_iso3, indicator_code,
       MIN(year) AS first_year, MAX(year) AS last_year, COUNT(*) AS n_years,
       MAX(year) - MIN(year) + 1 - COUNT(*) AS missing_years
FROM stg_maddison
GROUP BY country_iso3, indicator_code
HAVING missing_years > 0
ORDER BY country_iso3, indicator_code;

SELECT country_iso3, indicator_code,
       year + 1           AS gap_from,
       next_year - 1      AS gap_to,
       next_year - year - 1 AS missing_years
FROM (
    SELECT country_iso3, indicator_code, year,
           LEAD(year) OVER (PARTITION BY country_iso3, indicator_code
                            ORDER BY year) AS next_year
    FROM stg_maddison
) AS t
WHERE next_year - year > 1
ORDER BY country_iso3, indicator_code, gap_from;

SELECT DISTINCT country_iso3, country_name
FROM stg_wdi
WHERE country_iso3 NOT IN (SELECT country_iso3 FROM stg_maddison);

SELECT 'stg_maddison' AS source_table, COUNT(*) AS n_rows, SUM(value IS NULL) AS missing_values FROM stg_maddison
UNION ALL
SELECT 'stg_wdi', COUNT(*), SUM(value IS NULL) FROM stg_wdi
UNION ALL
SELECT 'stg_events', COUNT(*), SUM(event = '' OR category = '' OR economic_impact = '') FROM stg_events;

SELECT indicator_code, COUNT(*) AS n_rows, MIN(value) AS min_value, MAX(value) AS max_value
FROM stg_wdi
WHERE value < 0 OR (indicator_code LIKE '%.ZS' AND value > 100)
GROUP BY indicator_code;

SELECT category, COUNT(*) AS n_events
FROM stg_events
GROUP BY category
ORDER BY n_events DESC;

SELECT FLOOR(year / 10) * 10 AS decade, COUNT(*) AS n_events
FROM stg_events
GROUP BY decade
ORDER BY decade;

SELECT COUNT(DISTINCT economic_impact) AS n_distinct_labels
FROM stg_events;

SELECT economic_impact, COUNT(*) AS n_events
FROM stg_events
GROUP BY economic_impact
ORDER BY n_events DESC;

SELECT DISTINCT indicator_code, indicator_name
FROM stg_wdi
ORDER BY indicator_code;

SELECT DISTINCT indicator_code, indicator_name
FROM stg_wdi
WHERE indicator_code LIKE '%MANF%';

SELECT year, indicator_code, indicator_name, ROUND(value, 1) AS value
FROM stg_wdi
WHERE country_iso3 = 'PRT'
AND indicator_code IN ('NV.IND.TOTL.ZS', 'NV.IND.MANF.ZS')
ORDER BY year;

SELECT country_iso3, year,
       GROUP_CONCAT(indicator_code) AS available_indicators
FROM stg_maddison
GROUP BY country_iso3, year
HAVING COUNT(*) < 3
ORDER BY country_iso3, year;