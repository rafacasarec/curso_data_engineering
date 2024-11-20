WITH date_spine AS (
    {{ dbt_utils.date_spine(
        datepart="hour",
        start_date="'2015-01-01 00:00:00'::timestamp",
        end_date="'2025-12-31 23:00:00'::timestamp"
    ) }}
)

SELECT
    date_hour AS datetime,
    DATE(date_hour) AS date,
    EXTRACT(YEAR FROM date_hour) AS year,
    EXTRACT(MONTH FROM date_hour) AS month,
    EXTRACT(DAY FROM date_hour) AS day,
    EXTRACT(HOUR FROM date_hour) AS hour,
    EXTRACT(DOW FROM date_hour) AS day_of_week,
    TRIM(TO_CHAR(date_hour, 'Day')) AS day_name, 
    TO_CHAR(date_hour, 'Month') AS month_name,
    CASE
        WHEN EXTRACT(DOW FROM date_hour) IN (6, 7) THEN TRUE
        ELSE FALSE
    END AS is_weekend
FROM date_spine


