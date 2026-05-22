-- The HIPS Score.
WITH facility_stats AS (
		SELECT f.state_name,
				COUNT(facility_id) AS Total_facilities,
				p.total_population,
				ROUND(COUNT(f.facility_id) * 100000.0 / p.total_population,0) AS facilities_per_100k,
				COUNT(CASE WHEN f.facility_level = 'Tertiary' THEN 1 END) AS Tertiary_Count,
				ROUND(COUNT(CASE WHEN ownership = 'Private' THEN 1 END) * 100.0 / COUNT(*),0) AS Private_Percentage
		FROM facilities f
		JOIN population p
		ON f.state_name = p.state_name
		WHERE p.year = 2016 AND f.facility_level <> 'Primary'
		GROUP BY f.state_name, p.total_population
		),
normalised AS (
    SELECT *,
        ROUND((private_percentage - MIN(private_percentage) OVER()) * 100.0 /
        NULLIF(MAX(private_percentage) OVER() - MIN(private_percentage) OVER(), 0), 1) 
        AS equity_score,
		ROUND((1 - (facilities_per_100k - MIN(facilities_per_100k) OVER()) /
		NULLIF(MAX(facilities_per_100k) OVER() - MIN(facilities_per_100k) OVER(), 0)) * 100, 1)
		AS access_score,
		ROUND((1 - (Tertiary_Count - MIN(Tertiary_Count) OVER()) /
		NULLIF(MAX(Tertiary_Count) OVER() - MIN(Tertiary_Count) OVER(), 0)) * 100, 1)
		AS tertiary_score
    FROM facility_stats
),
scored AS (
	SELECT *,
	(access_score * 0.5) + (equity_score * 0.3) + (tertiary_score * 0.2) AS hips_score
	FROM normalised)
SELECT state_name, 
		hips_score,
		RANK() OVER (ORDER BY hips_score DESC) AS priority_rank,
		CASE WHEN hips_score > 74 THEN 'Critical'
			WHEN hips_score > 54 THEN 'High'
			WHEN hips_score > 34 THEN 'Moderate'
			ELSE 'Stable'
		END AS investment_priority
FROM scored
/*Over 64% of the states fall within the critical zone with Kano and Plateau topping the list. 
27% fall within the high priority zone. Only Anambra State appears to be "Stable" with Ogun and Enugu 
falling within the moderate priority zone.
Lagos is Nigeria's most developed state yet it scores Critical. This reflects the private facility dominance penalty. 
Lagos has enormous healthcare infrastructure but much of it is private and unaffordable to the majority of its 15+ million residents.
South East states generally have strong community-driven healthcare investment and relatively smaller populations relative to their 
facility count so it will come as no surprise that Anambra fell into the 'Stable' zone*/