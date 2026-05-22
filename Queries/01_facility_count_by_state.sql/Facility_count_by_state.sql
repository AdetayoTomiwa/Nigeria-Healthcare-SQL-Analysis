--How many health facilities does each state have, and which states have the most and least?
SELECT state_name, COUNT(facility_id) as No_of_facilities
FROM facilities
GROUP BY state_name
ORDER BY No_of_facilities DESC
/*Lagos has the highest number of health facilities while Bayelsa has the lowest*/