--How many facilities does each state have per 100,000 people — and based on that, which states are critically underserved?
SELECT f.state_name,
		COUNT(facility_id) AS Total_facilities,
		p.total_population,
		ROUND(COUNT(f.facility_id) * 100000.0 / p.total_population,0) AS facilities_per_100k,
		CASE WHEN COUNT(facility_id)*100000/p.total_population >=10 THEN 'Good'
			 WHEN COUNT(facility_id)*100000/p.total_population >=5 THEN 'Average'
			 WHEN COUNT(facility_id)*100000/p.total_population >=2 THEN 'Critical'
		Else 'Highly Critical'
		END AS Service_Tier
FROM facilities f
JOIN population p
ON f.state_name = p.state_name
WHERE p.year = 2016
GROUP BY f.state_name, p.total_population
ORDER BY facilities_per_100k DESC
-- What if we strip of primary healthcare facilities?
SELECT f.state_name,
		COUNT(facility_id) AS Total_facilities,
		p.total_population,
		ROUND(COUNT(f.facility_id) * 100000.0 / p.total_population,0) AS facilities_per_100k,
		CASE WHEN COUNT(facility_id)*100000/p.total_population >=10 THEN 'Good'
			 WHEN COUNT(facility_id)*100000/p.total_population >=5 THEN 'Average'
			 WHEN COUNT(facility_id)*100000/p.total_population >=2 THEN 'Critical'
		Else 'Highly Critical'
		END AS Service_Tier
FROM facilities f
JOIN population p
ON f.state_name = p.state_name
WHERE p.year = 2016 AND f.facility_level <> 'Primary'
GROUP BY f.state_name, p.total_population
ORDER BY facilities_per_100k DESC
/*On a surface level, it may appear as if every state is doing "good" based on the total facilities 
to total population ratio. However, when a deeper look is taken, and the data is stripped of primary 
healthcare, there is a noticeable change in the "service tier" with many states falling within 
"critical and highly critical" and others, at best, falling under "Average".*/ 