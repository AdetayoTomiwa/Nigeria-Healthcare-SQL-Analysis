--What is the public vs private ownership split per state, and which states are at the highest equity risk based on private facility dominance?
SELECT 
    state_name,
    COUNT(CASE WHEN ownership = 'Public' THEN 1 END) AS Total_Public_Facilities,
    COUNT(CASE WHEN ownership = 'Private' THEN 1 END) AS Total_Private_Facilities,
    -- Calculating the percentage
    ROUND(COUNT(CASE WHEN ownership = 'Private' THEN 1 END) * 100.0 / COUNT(*),0) AS Private_Percentage,
	CASE WHEN ROUND(COUNT(CASE WHEN ownership = 'Private' THEN 1 END) * 100.0 / COUNT(*),0) >= 60 THEN 'high_equity_risk'
		 WHEN ROUND(COUNT(CASE WHEN ownership = 'Private' THEN 1 END) * 100.0 / COUNT(*),0) >= 40 THEN 'moderate_equity_risk'
	ELSE 'low_equity_risk' END AS "Equity_Risk"
FROM facilities
GROUP BY state_name
ORDER BY Private_Percentage DESC;
/*Lagos State has a disproportionate amount of private-public health facilities ratio placing it at high risk. 
Oyo state is at moderate risk while other states appear to be at low risk.*/