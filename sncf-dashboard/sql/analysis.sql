CREATE OR REPLACE VIEW sncf_tgv_clean AS
SELECT
  COALESCE(
    try_strptime("Date", '%Y-%m-%d'),
    try_strptime("Date", '%Y-%m'),
    try_strptime("Date", '%d/%m/%Y'),
    try_strptime("Date", '%m/%Y')
  ) AS mois,
  "Régularité composite" AS regularite_composite,
  "Ponctualité origine" AS ponctualite_origine
FROM sncf_tgv
WHERE COALESCE(
    try_strptime("Date", '%Y-%m-%d'),
    try_strptime("Date", '%Y-%m'),
    try_strptime("Date", '%d/%m/%Y'),
    try_strptime("Date", '%m/%Y')
) IS NOT NULL;

CREATE OR REPLACE TABLE kpi_mensuel AS
SELECT
  date_trunc('month', mois) AS mois,
  ROUND(AVG(regularite_composite), 2) AS regularite_moyenne,
  ROUND(AVG(ponctualite_origine), 2) AS ponctualite_origine_moyenne
FROM sncf_tgv_clean
GROUP BY 1
ORDER BY 1;

CREATE OR REPLACE TABLE kpi_global AS
SELECT
  ROUND(AVG(regularite_composite), 2) AS regularite_moyenne,
  ROUND(MIN(regularite_composite), 2) AS regularite_min,
  ROUND(MAX(regularite_composite), 2) AS regularite_max,
  ROUND(AVG(ponctualite_origine), 2) AS ponctualite_origine_moyenne
FROM sncf_tgv_clean;

CREATE OR REPLACE TABLE top_mois AS
SELECT * FROM (
  SELECT 'meilleurs' AS categorie,
         date_trunc('month', mois) AS mois,
         ROUND(regularite_composite, 2) AS regularite
  FROM sncf_tgv_clean
  ORDER BY regularite_composite DESC
  LIMIT 5
)
UNION ALL
SELECT * FROM (
  SELECT 'pires' AS categorie,
         date_trunc('month', mois) AS mois,
         ROUND(regularite_composite, 2) AS regularite
  FROM sncf_tgv_clean
  ORDER BY regularite_composite ASC
  LIMIT 5
);






