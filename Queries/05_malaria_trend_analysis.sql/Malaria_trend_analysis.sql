-- How have confirmed malaria cases and estimated malaria incidence changed year over year, and is the trend improving or worsening?
SELECT disease,
		indicator_code,
		indicator_name,
		year,
		ROUND(numeric_value,0) Current_Value, 
		ROUND(LAG(numeric_value) OVER (PARTITION BY indicator_code ORDER BY year),0) AS Previous_Year_Value,
		ROUND(numeric_value,0) - ROUND(LAG(numeric_value) OVER (PARTITION BY indicator_code ORDER BY year)) AS Value_Change,
		ROUND((ROUND(numeric_value,0) - ROUND(LAG(numeric_value) OVER (PARTITION BY indicator_code ORDER BY year)))*100/NULLIF(ROUND(LAG(numeric_value) OVER (PARTITION BY indicator_code ORDER BY year),0),0),0) AS Percentage_Change
FROM disease_indicators
WHERE indicator_code IN ('MALARIA_CONF_CASES', 'MALARIA_EST_INCIDENCE')
/* Overall trend on confirmed cases is upward with a signicant raise from about 8million in 2015 to more than 20million in 2024.
Incidence rate, on the other hand, took the other route with a gradual decline over the years despite increase in absolute case numbers.
In 2020, there was a notable 7% drop in Confirmed Cases. This almost certainly reflects COVID-19 disrupting healthcare reporting and facility attendance, not an actual improvement in malaria burden.*/