-- Which states have no tertiary facilities at all, or only one — and which geopolitical zones are most exposed to this gap?
WITH Tertiary_Analysis AS
(SELECT S.state_name, S.geopolitical_zone,
		COUNT(CASE WHEN F.facility_level = 'Tertiary' THEN 1 END) AS Tertiary_Count
FROM facilities F
RIGHT JOIN states S ON F.state_name = S.state_name
GROUP BY  S.state_name, S.geopolitical_zone) 
SELECT state_name, geopolitical_zone, Tertiary_Count
FROM Tertiary_Analysis
WHERE Tertiary_Count <= 1
/* Only two states fall at or below 1 tertiary facility: FCT with zero and Gombe with one. 
The fact that the Federal Capital Territory of the country(Nigeria) appears to have zero registered Tertiary Facility raises a brow and warrants data quality scrunity. 
There is also a plausible case where the Tertiary Institutions are registered under a different name or ownership classification.
Gombe State requires more specialist care*/