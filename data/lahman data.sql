-- 1. What range of years for baseball games played does the provided database cover? 
SELECT MIN(year) AS start_year, MAX(year) AS last_year, MAX(year)-MIN(year) AS total_years_played from homegames;


-- 2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name 
-- of the team for which he played?
SELECT namegiven,height, debut, finalgame,teams.name  FROM people
INNER JOIN appearances USING(playerid)
INNER JOIN teams USING(teamid)
ORDER BY height
LIMIT 1;


-- 3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and 
-- last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total 
-- salary earned. Which Vanderbilt player earned the most money in the majors?
WITH vandy AS (SELECT DISTINCT(playerid) FROM collegeplaying
				INNER JOIN schools USING(schoolid)
				WHERE schoolname ILIKE '%vanderbilt%')
SELECT playerid, namefirst, namelast, SUM(salary)::int::money AS total_salary_earned
FROM vandy 
INNER JOIN people USING(playerid)
INNER JOIN salaries USING(playerid)
GROUP BY playerid, namefirst, namelast
ORDER BY total_salary_earned DESC;


-- 4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield",
-- those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of 
-- putouts made by each of these three groups in 2016.
SELECT CASE WHEN pos = 'OF' THEN 'Outfield'
	   WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
	   WHEN pos IN ('P', 'C') THEN 'Battery' END AS position_played,
	   SUM(po) AS putouts
FROM fielding
WHERE yearid = '2016'
GROUP BY position_played;


-- 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. 
-- Do the same for home runs per game. Do you see any trends?
SELECT  CASE WHEN yearid BETWEEN '1920' AND '1929' THEN '1920s'
      		 WHEN yearid BETWEEN '1930' AND '1939' THEN '1930s'
   			 WHEN yearid BETWEEN '1940' AND '1949' THEN '1940s'
   			 WHEN yearid BETWEEN '1950' AND '1959' THEN '1950s'
  			 WHEN yearid BETWEEN '1960' AND '1969' THEN '1960s'
   			 WHEN yearid BETWEEN '1970' AND '1979' THEN '1970s'
  			 WHEN yearid BETWEEN '1980' AND '1989' THEN '1980s'
   			 WHEN yearid BETWEEN '1990' AND '1999' THEN '1990s'
   			 WHEN yearid BETWEEN '2000' AND '2009' THEN '2000s'
   			 WHEN yearid BETWEEN '2010' AND '2019' THEN '2010s'
			 ELSE 'na' END AS decade, ROUND(AVG(SO)/AVG(G), 2) AS strikeouts, ROUND(AVG(HR)/AVG(G), 2) AS homeruns
FROM teams
WHERE yearid IS NOT NULL
GROUP BY decade
ORDER BY decade
LIMIT 10;


-- 6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base 
-- attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.)
-- Consider only players who attempted _at least_ 20 stolen bases.		
SELECT MAX(namegiven), SUM(sb) AS stolen_bases, SUM(cs) AS caught_stealing, 
		ROUND((SUM(sb::numeric) / (SUM(sb::numeric)+SUM(cs::numeric)))*100,2) AS stolen_base_perc 
FROM batting
INNER JOIN people USING(playerid)
WHERE yearid = 2016
GROUP BY playerid
HAVING (SUM(sb) + SUM(CS)) >=20
ORDER BY stolen_base_perc DESC, stolen_bases DESC
LIMIT 1;

-- 7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? 
-- What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually 
-- small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. 
-- How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

-- PART A
SELECT yearid, name, w AS wins, WSWIN FROM teams
WHERE (yearid BETWEEN 1970 AND 2016) AND (WSWIN = 'N')
ORDER BY w DESC
LIMIT 1;

--PART B
SELECT yearid, name, w AS wins, WSWIN FROM teams
WHERE (yearid BETWEEN 1970 AND 2016) AND (WSWIN = 'Y')
ORDER BY w
LIMIT 1;

--PART C
SELECT yearid, name, w AS wins, WSWIN FROM teams
WHERE (yearid BETWEEN 1970 AND 2016) AND (WSWIN = 'Y') AND (g > 120)
ORDER BY w
LIMIT 1;
 
--PART D 

yearid, teamid, w, WSWIN

-- sb stolen bases
-- cs caught stealing
SELECT * FROM pitching
SELECT * FROM teams

