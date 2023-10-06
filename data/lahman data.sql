-- 1. What range of years for baseball games played does the provided database cover? 
SELECT MIN(year) AS start_year, MAX(year) AS last_year, MAX(year)-MIN(year) AS total_years_played 
FROM homegames;


-- 2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name 
-- of the team for which he played?
SELECT namegiven,height, debut, finalgame,teams.name  
FROM people
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
SELECT yearid, name, w AS wins, WSWIN 
FROM teams
WHERE (yearid BETWEEN 1970 AND 2016) AND (WSWIN = 'N')
ORDER BY w DESC
LIMIT 1;

--PART B
SELECT yearid, name, w AS wins, WSWIN 
FROM teams
WHERE (yearid BETWEEN 1970 AND 2016) AND (WSWIN = 'Y')
ORDER BY w
LIMIT 1;

--PART C
SELECT yearid, name, w AS wins, WSWIN 
FROM teams
WHERE (yearid BETWEEN 1970 AND 2016) AND (WSWIN = 'Y') AND (g > 120)
ORDER BY w
LIMIT 1;
 
--PART D 
WITH cte3 AS(WITH cte1 AS (SELECT yearid, name, w AS wins, WSWIN FROM teams
						   WHERE (yearid BETWEEN 1970 AND 2016) AND (WSWIN = 'Y') AND (g > 120)
						   ORDER BY yearid),
						 --^ cte that finds all teams that has a 'Y' for WSWIN between 1970 and 2016 excluding riot year
				  cte2 AS (SELECT yearid, MAX(w) AS highest_w_count_that_season FROM teams
						   WHERE (yearid BETWEEN 1970 AND 2016) AND (g > 120)
						   GROUP BY yearid
						   ORDER BY yearid)
			 --^ cte that finds the highest win count per year 1970 and 2016 excluding riot year
			 SELECT cte1.yearid, name, wins,highest_w_count_that_season, wswin, 
			 CASE WHEN wins >=highest_w_count_that_season THEN 1 WHEN wins < highest_w_count_that_season THEN 0 END AS WS_and_highest_wincount
			 FROM cte1
			 INNER JOIN cte2 USING(yearid))
			 --merging cte1 and cte1 so that if the season with their highest win count was also the season with a WSWIN the it would report as a 1, otherwise 0
			 
SELECT COUNT(wswin) AS total_wswins, SUM(WS_and_highest_wincount) AS total_WS_and_highest_wincount, 
ROUND(((SUM(WS_and_highest_wincount)::numeric)/(COUNT(wswin)::numeric))*100,2) AS Percent_that_highest_w_also_ws_winner
FROM cte3;
--^creating cte3 out of the first 2 ctes that converts wins into numeric then devides to allow for a percent
			  

-- 8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 
-- (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. 
-- Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.		  
-- PART A
SELECT park_name, name team_name, (SUM(hg.attendance) / SUM(hg.games)) AS avg_attendance
FROM homegames AS hg
INNER JOIN teams ON hg.team = teams.teamid AND hg.year = teams.yearid
INNER JOIN parks ON hg.park = parks.park
WHERE year = 2016 AND games >= 10
--HAVING COUNT(*) >= 10
GROUP BY parks.park_name, teams.name
ORDER BY avg_attendance DESC
LIMIT 5;

-- PART B
SELECT park_name, name team_name, (SUM(hg.attendance) / SUM(hg.games)) AS avg_attendance
FROM homegames AS hg
INNER JOIN teams ON hg.team = teams.teamid AND hg.year = teams.yearid
INNER JOIN parks ON hg.park = parks.park
WHERE year = 2016 AND games >= 10
--HAVING COUNT(*) >= 10
GROUP BY parks.park_name, teams.name
ORDER BY avg_attendance
LIMIT 5;


-- 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and 
-- the teams that they were managing when they won the award.			  
WITH cte AS		(SELECT namefirst, namelast,playerid
				 --MIN(awardsmanagers.lgid) AS al_winner, MAX(awardsmanagers.lgid)AS NL_winner
				 FROM awardsmanagers
				 INNER JOIN people USING(playerid)
				 WHERE awardid ILIKE '%TSN%' 
				 GROUP BY playerid,namefirst, namelast
				 HAVING (MIN(awardsmanagers.lgid) = 'AL' AND MAX(awardsmanagers.lgid) = 'NL'))
				 --USED (MIN(awardsmanagers.lgid) = 'AL' and MAX(awardsmanagers.lgid) = 'NL')) as a way to filter out managers that have won both. logic case using alphebetic order 
SELECT playerid, namefirst, namelast, name, yearid,awardsmanagers.lgid AS league_award FROM cte
INNER JOIN awardsmanagers USING(playerid)
INNER JOIN managers USING(yearid,playerid)
INNER JOIN teams USING(yearid,teamid)
WHERE awardid ILIKE '%TSN%'; 


-- 10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years,
-- and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.
WITH cte AS (SELECT playerid, MIN(yearid) AS min_year, MAX(yearid) AS max_year, MAX(hr) AS max_hr 
			 FROM batting
			 GROUP BY playerid
			 HAVING (MAX(yearid) - MIN(yearid) >=10))
SELECT playerid, namefirst, namelast, hr AS homeruns_in_2016 FROM batting
RIGHT JOIN cte USING(playerid)
INNER JOIN people USING(playerid)
WHERE yearid = 2016 AND hr = max_hr AND hr >=1;


-- 11. Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question.
-- As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.
WITH cte AS		(SELECT s.teamid, s.yearid, t.w AS wins, SUM(salary::integer::money) AS salary
				FROM salaries AS s
				FULL JOIN teams AS t USING(teamid, yearid) 
				WHERE s.yearid >= 2000
				GROUP BY s.teamid, s.yearid, t.w
				ORDER BY s.teamid, s.yearid)
SELECT teamid, yearid, wins, salary, CORR(wins::numeric,salary::numeric) OVER(PARTITION BY teamid ORDER BY yearid) AS correlation_coefficient
FROM cte



