-- How has TB incidence trended year over year, and how does treatment coverage track alongside it?
SELECT disease,
		indicator_code,
		indicator_name,
		year,
		ROUND(numeric_value,0) Current_Value, 
		ROUND(LAG(numeric_value) OVER (PARTITION BY indicator_code ORDER BY year),0) AS Previous_Year_Value,
		ROUND(numeric_value,0) - ROUND(LAG(numeric_value) OVER (PARTITION BY indicator_code ORDER BY year)) AS Value_Change,
		ROUND((ROUND(numeric_value,0) - ROUND(LAG(numeric_value) OVER (PARTITION BY indicator_code ORDER BY year)))*100/NULLIF(ROUND(LAG(numeric_value) OVER (PARTITION BY indicator_code ORDER BY year),0),0),0) AS Percentage_Change
FROM disease_indicators
WHERE indicator_code IN ('TB_1', 'MDG_0000000020') 
/*TB incidence in Nigeria has remained essentially flat over the entire period, barely moving despite years of intervention.
However, treatment coverage has climbed significantly over the years. 
This highlights a significant gap in care; the fact that incidence hasn't responded to improving coverage shows that the disease is being managed in those who are caught, but transmission in the community is not being interrupted. 
New cases keep emerging at the same rate because the underlying drivers remain unaddressed.*/