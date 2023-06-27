CREATE TABLE details(
	UNIQUE_ID VARCHAR(50) PRIMARY KEY,
	GUNSHOT_INJURY_I BOOLEAN,
	AGE VARCHAR(10),
	SEX VARCHAR(10),
	RACE VARCHAR(10),
	VICTIMIZATION_FBI_DESCR TEXT,
	INCIDENT_FBI_DESCR TEXT
)

CREATE TABLE loc(
	CASE_NUMBER VARCHAR(50) PRIMARY KEY,
	BLOCK VARCHAR(100),
	COMMUNITY_AREA VARCHAR(100),
	LOCATION_DESCRIPTION TEXT
)

CREATE TABLE time(
	TIME_ID SERIAL PRIMARY KEY,
	UNIQUE_ID VARCHAR(50) REFERENCES details(UNIQUE_ID),
	CASE_NUMBER VARCHAR(50) REFERENCES loc(CASE_NUMBER),
	DATE DATE,
	MONTH INTEGER,
	DAY_OF_WEEK INTEGER,
	HOUR INTEGER
)

-----

-- 1. How many FBI victimization types are there and what are they?
SELECT COUNT(DISTINCT victimization_fbi_descr) FROM details;
SELECT DISTINCT victimization_fbi_descr FROM details;

-- 2. What was the most frequently commited crime based on the FBI vicitimization description?
SELECT victimization_fbi_descr,COUNT(victimization_fbi_descr) AS cnt FROM details
GROUP BY victimization_fbi_descr
ORDER BY cnt DESC;

-- 3. What is the percentage of crimes involving a gunshot injury?
SELECT ROUND
((SELECT COUNT(gunshot_injury_i) FROM details
WHERE gunshot_injury_i=true)::NUMERIC/
(SELECT COUNT(gunshot_injury_i) FROM details)*100,2);

-- 4. Creating a view of a full table
CREATE VIEW full_ AS
SELECT loc.case_number,details.unique_id,block,community_area,location_description,time_id,
date,month,day_of_week,hour,gunshot_injury_i,age,sex,race,victimization_fbi_descr,incident_fbi_descr
FROM loc
INNER JOIN time 
ON loc.case_number=time.case_number
INNER JOIN details 
ON time.unique_id=details.unique_id;

-- 5. How many community areas are there?
SELECT COUNT(DISTINCT community_area) FROM loc;

-- 6. What is the most dangerous community_area?
SELECT community_area,COUNT(community_area) AS cnt FROM loc
GROUP BY community_area
ORDER BY cnt DESC
LIMIT(1);

-- 7. What is the percentage of crimes happening in Austin community area then?
SELECT ROUND
((SELECT COUNT(community_area) FROM loc
WHERE community_area='AUSTIN')::NUMERIC/
(SELECT COUNT(community_area) FROM loc)*100,2);

-- 8. How many blocks are there?
SELECT COUNT(DISTINCT block) FROM loc;

-- 9. What is the most dangerous block in the area?
SELECT block,COUNT(block) AS cnt FROM loc
GROUP BY block
ORDER BY cnt DESC
LIMIT(1);

-- 10. What are the locations where the crimes were committed?
SELECT DISTINCT location_description FROM loc;

-- 11. Which 10 locations are the most dangerous?
SELECT location_description,COUNT(location_description) AS cnt FROM loc
GROUP BY location_description
ORDER BY cnt DESC
LIMIT(10);

-- 12. What are the locations of particular crime types?
SELECT incident_fbi_descr,COUNT(incident_fbi_descr) AS cnt, location_description FROM full_
GROUP BY incident_fbi_descr,location_description
ORDER BY incident_fbi_descr,cnt DESC;

-- 13. What are the ten days the most crimes were commited?
SELECT date, COUNT(date) AS cnt FROM time
GROUP BY date
ORDER BY cnt DESC
LIMIT(10);

-- 14. In which year were the most crimes commited?
SELECT COUNT(EXTRACT(YEAR FROM date)) AS cnt,EXTRACT(YEAR FROM date) AS years FROM time
GROUP BY EXTRACT(YEAR FROM date)
ORDER BY cnt DESC
LIMIT(1);

-- 15. And does it square with the number of robberies?
SELECT COUNT (EXTRACT(YEAR FROM date)) AS cnt,EXTRACT(YEAR FROM date) AS years,incident_fbi_descr FROM full_
GROUP BY EXTRACT(YEAR FROM date),incident_fbi_descr
HAVING incident_fbi_descr='ROBBERY (INDEX)'
ORDER BY cnt DESC
LIMIT(1);

-- 16. What are the 5 most dangerous months?
SELECT month, COUNT(month) AS cnt FROM time
GROUP BY month
ORDER BY cnt DESC
LIMIT(5);

-- 17. How about days of week?
SELECT day_of_week, COUNT(day_of_week) AS cnt FROM time
GROUP BY day_of_week
ORDER BY cnt DESC;

-- 18. And hours?
SELECT hour, COUNT(hour) AS cnt FROM time
GROUP BY hour
ORDER BY cnt DESC;

-- 19. Which age group commited the most crimes?
SELECT age,COUNT(age) AS cnt FROM details
GROUP BY age
ORDER BY cnt DESC;

-- 20. Which sex commited more crimes?
SELECT sex,COUNT(sex) AS cnt FROM details
GROUP BY sex
ORDER BY cnt DESC;

-- 21. In which months do men commit the most crimes?
SELECT gunshot_injury_i,sex,month,COUNT(month) AS month_count FROM full_
GROUP BY gunshot_injury_i,sex,age,race,month 
HAVING gunshot_injury_i=true AND sex='M'
ORDER BY month_count DESC
LIMIT(3);

-- 22. And what about women?
SELECT gunshot_injury_i,sex,month,COUNT(month) AS month_count FROM full_
GROUP BY gunshot_injury_i,sex,age,race,month 
HAVING gunshot_injury_i=true AND sex='F'
ORDER BY month_count DESC
LIMIT(3);

-- 23. Which race commited the most crimes?
SELECT race,COUNT(race) AS cnt FROM details
GROUP BY race
ORDER BY cnt DESC;

-- 24. When does each race commit the most crimes?
SELECT month,race,COUNT(*) AS cnt FROM full_
GROUP BY month,race
HAVING race!='UNKNOWN'
ORDER BY race,cnt DESC;

-- 25. What are the numbers of crimes commited by each race in different areas?
SELECT community_area,race,COUNT(community_area) AS cnt FROM full_
GROUP BY community_area,race
HAVING race!='UNKNOWN'
ORDER BY community_area,cnt DESC