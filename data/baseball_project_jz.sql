/*1. What range of years for baseball games played does the provided database cover?*/ 

SELECT MIN(year), MAX(year)
FROM homegames;


/*2. Find the name and height of the shortest player in the database. 
How many games did he play in? What is the name of the team for which he played?*/

SELECT playerid, namefirst, namelast, namegiven, height, debut, finalgame, teams.name
FROM people
	 LEFT JOIN appearances
	 USING (playerid)
	 LEFT JOIN teams
	 USING (teamid)
ORDER BY height
LIMIT 1;


/*3. Find all players in the database who played at Vanderbilt University. 
Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. 
Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?*/

--This is just to check the answer
SELECT SUM(salary)::int::money
FROM salaries
WHERE playerid = 'priceda01';

SELECT playerid,
	   namefirst,
	   namelast,
	   SUM(salary)::int::money AS salary
FROM people
     LEFT JOIN salaries
	 USING (playerid)
WHERE playerid IN
	(SELECT DISTINCT(playerid)
	 FROM people
	 	LEFT JOIN collegeplaying
	 	USING (playerid)
	 WHERE schoolid = 'vandy')
GROUP BY playerid
ORDER BY salary DESC NULLS LAST;


/*4. Using the fielding table, group players into three groups based on their position: 
label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", 
and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.*/

SELECT CASE WHEN pos = 'OF' THEN 'Outfield'
	   WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
	   WHEN pos IN ('P', 'C') THEN 'Battery' END AS position_played,
	   SUM(po) AS putouts
FROM fielding
WHERE yearid = '2016'
GROUP BY position_played;

--Code to check
SELECT SUM(po)
FROM fielding
WHERE yearid = '2016';


/*5. Find the average number of strikeouts per game by decade since 1920. 
Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?*/

SELECT SUM(hr) AS home_runs,
	   SUM(g) AS games,
	   yearid,
	   ROUND(SUM(hr::numeric) / SUM(g::numeric),2) AS average
FROM teams
GROUP BY yearid;

SELECT SUM(g) AS games,
	   SUM(hr) AS home_runs,
	   ROUND(SUM(hr::numeric) / SUM(g::numeric),2) AS hr_per_game,
	   SUM(so) AS strike_outs,
	   ROUND(SUM(so::numeric) / SUM(g::numeric),2) AS so_per_game,
       CASE WHEN yearid BETWEEN '1871' AND '1879' THEN '1870s'
	   WHEN yearid BETWEEN '1880' AND '1889' THEN '1880s'
	   WHEN yearid BETWEEN '1890' AND '1899' THEN '1890s'
	   WHEN yearid BETWEEN '1900' AND '1909' THEN '1900s'
	   WHEN yearid BETWEEN '1910' AND '1919' THEN '1910s'
	   WHEN yearid BETWEEN '1920' AND '1929' THEN '1920s'
	   WHEN yearid BETWEEN '1930' AND '1939' THEN '1930s'
	   WHEN yearid BETWEEN '1940' AND '1949' THEN '1940s'
	   WHEN yearid BETWEEN '1950' AND '1959' THEN '1950s'
	   WHEN yearid BETWEEN '1960' AND '1969' THEN '1960s'
	   WHEN yearid BETWEEN '1970' AND '1979' THEN '1970s'
	   WHEN yearid BETWEEN '1980' AND '1989' THEN '1980s'
	   WHEN yearid BETWEEN '1990' AND '1999' THEN '1990s'
	   WHEN yearid BETWEEN '2000' AND '2009' THEN '2000s'
	   WHEN yearid BETWEEN '2010' AND '2019' THEN '2010s'
	   ELSE 'later' END AS decade
FROM teams
GROUP BY decade
ORDER BY decade;


/*6. Find the player who had the most success stealing bases in 2016, 
where __success__ is measured as the percentage of stolen base attempts which are successful. 
(A stolen base attempt results either in a stolen base or being caught stealing.) 
Consider only players who attempted _at least_ 20 stolen bases.*/

WITH cte AS (SELECT playerid,
			 	    sb,
	   		        sb + cs AS steal_attempts
			 FROM batting
			 WHERE yearid = 2016)
SELECT namefirst,
 	   namelast,
 	   sb, 
	   steal_attempts,
	   ROUND(sb::numeric / steal_attempts::numeric * 100, 2) AS percentage_stolen
FROM cte
	 INNER JOIN people
	 USING (playerid)
WHERE steal_attempts >= '20'
GROUP BY namefirst, namelast, sb, steal_attempts
ORDER BY percentage_stolen DESC;


/*7. From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? 
What is the smallest number of wins for a team that did win the world series? 
Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. 
Then redo your query, excluding the problem year. 
How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?*/

--most wins who won
SELECT yearid,
	   teamid,
	   MAX(g) AS games_played,
	   MAX(w) AS games_won,
	   wswin
FROM teams
WHERE wswin = 'N' AND yearid >= '1970'
GROUP BY yearid, teamid, wswin
ORDER BY games_won DESC;

--least wins who won
SELECT yearid,
	   teamid,
	   MAX(g) AS games_played,
	   MAX(w) AS games_won,
	   wswin
FROM teams
WHERE wswin = 'Y' AND yearid >= '1970'
GROUP BY yearid, teamid, wswin
ORDER BY games_won;



