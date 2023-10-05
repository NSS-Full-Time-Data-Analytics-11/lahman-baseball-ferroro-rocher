SELECT * FROM teams;

--1. What range of years for baseball games played does the provided database cover? 
SELECT MIN(t.yearid) AS start_year, MAX(t.yearid) AS end_year, MAX(t.yearid) - MIN(t.yearid) AS total_played
FROM teams AS t;

SELECT * FROM allstarfull;
SELECT * FROM people;

--2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?

SELECT p.namegiven,p.height, p.debut, p.finalgame,t.name  
FROM people AS p
INNER JOIN appearances AS a
ON p.playerid = a.playerid
INNER JOIN teams AS t 
ON a.teamid =t.teamid
WHERE p.height =(SELECT MIN(height)
				FROM people)
				LIMIT 1;

--Answer: "Edward Carl"	43	"1951-08-19"	"1951-08-19"	"St. Louis Browns"

--3. Find all players in the database who played at Vanderbilt University.
--Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
	
SELECT DISTINCT
    p.playerid,
    p.namefirst,
    p.namelast,
    SUM(salary)::int::money AS total_salary_earned
FROM collegeplaying AS cp
INNER JOIN schools AS s
ON cp.schoolid = s.schoolid
INNER JOIN people AS p
ON cp.playerid = p.playerid
INNER JOIN salaries AS sal
ON p.playerid = sal.playerid
WHERE s.schoolname ILIKE '%vanderbilt%'
GROUP BY
    p.playerid,
    p.namefirst,
    p.namelast
ORDER BY
    total_salary_earned DESC;
	
--	4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.
WITH Playerct AS (
SELECT CASE
WHEN pos = 'OF' THEN 'Outfield'
	 WHEN pos IN ('SS','1B','2B','3B') THEN 'Infield'
	 WHEN pos IN ('P','C') THEN 'Battery'
	 END AS player,
	 PO AS putouts
	 FROM fielding
	 WHERE yearid = '2016'
	
)
SELECT player,
SUM(putouts) AS total_putouts
FROM playerct
GROUP BY player;


--5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
--SELECT * FROM teams;

SELECT
    CASE
        WHEN yearID BETWEEN 1920 AND 1929 THEN '1920s'
        WHEN yearID BETWEEN 1930 AND 1939 THEN '1930s'
        WHEN yearID BETWEEN 1940 AND 1949 THEN '1940s'
        WHEN yearID BETWEEN 1950 AND 1959 THEN '1950s'
        WHEN yearID BETWEEN 1960 AND 1969 THEN '1960s'
        WHEN yearID BETWEEN 1970 AND 1979 THEN '1970s'
        WHEN yearID BETWEEN 1980 AND 1989 THEN '1980s'
        WHEN yearID BETWEEN 1990 AND 1999 THEN '1990s'
        WHEN yearID BETWEEN 2000 AND 2009 THEN '2000s'
        WHEN yearID BETWEEN 2010 AND 2019 THEN '2010s'
    END AS decade,
    ROUND(AVG(SO * 1.0 / G) FILTER (WHERE yearID >= 1920), 2) AS avg_so_per_game,
    ROUND(AVG(HR * 1.0 / G) FILTER (WHERE yearID >= 1920), 2) AS avg_hr_per_game
FROM pitching
GROUP BY decade
ORDER BY decade;

--6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.

SELECT
    p.namegiven AS player_name,
    SUM(b.SB) AS stolen_bases,
    SUM(b.CS) AS caught_stealing,
    ROUND((SUM(b.SB::numeric) / NULLIF(SUM(b.SB::numeric) + SUM(b.CS::numeric), 0)) * 100, 2) AS stolen_percentage
FROM batting AS b
INNER JOIN people AS p ON b.playerid = p.playerid
WHERE b.yearid = 2016
GROUP BY p.namegiven
HAVING SUM(b.SB + b.CS) >= 20
ORDER BY stolen_percentage DESC, stolen_bases DESC
LIMIT 1;

--7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? 
--What is the smallest number of wins for a team that did win the world series? 
--Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. 
--Then redo your query, excluding the problem year. 
--How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? 
--What percentage of the time?

----PART A:
SELECT MAX(w) AS maxwins_not_ws
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
    AND WSWin = 'N';
--PART B
SELECT MIN(w) AS smallest_wins
FROM teams
WHERE WSWin ='Y'

--PART C:


--8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). 
--Only consider parks where there were at least 10 games played. 
--Report the park name, team name, and average attendance. 
--Repeat for the lowest 5 average attendance.

--Highest 5 average attendence

SELECT hg.team, hg.park, (SUM(hg.attendance) / hg.games) AS avg_attendance
FROM homegames AS hg
WHERE year = 2016 
AND park IN(
       SELECT DISTINCT(park)
       FROM homegames AS hg
       WHERE year = 2016 AND games >= 10)
GROUP BY hg.team, hg.park, hg.games
--HAVING COUNT(*) >= 10
ORDER BY avg_attendance DESC
LIMIT 5;

--lowest 5 average attendance

SELECT hg.team, hg.park, (SUM(hg.attendance) / hg.games) AS avg_attendance
FROM homegames AS hg
WHERE year = 2016 
AND park IN(
       SELECT DISTINCT(park)
       FROM homegames AS hg
       WHERE year = 2016 AND games >= 10)
GROUP BY hg.team, hg.park, hg.games
--HAVING COUNT(*) >= 10
ORDER BY avg_attendance ASC
LIMIT 5;

--9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)?
--Give their full name and the teams that they were managing when they won the award.
--SELECT * FROM managers;
--SELECT * FROM awardsmanagers;
--SELECT * FROM teams;
SELECT p.namefirst, p.namelast, a.playerid, a.awardid, a.yearid, a.lgid AS league
FROM people AS p
INNER JOIN awardsmanagers AS a USING(playerid)
--ON p.playerid = a.playerid
WHERE (a.awardid = 'TSN Manager of the Year' AND lgid = 'NL') OR (a.awardid = 'TSN Manager of the Year' AND lgid = 'AL')
ORDER BY p.namefirst, p.namelast


--10. Find all players who hit their career highest number of home runs in 2016. 
--Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. 
--Report the players' first and last names and the number of home runs they hit in 2016.

WITH cte AS (SELECT playerid, MIN(yearid) AS min_year, MAX(yearid) AS max_year, MAX(hr) AS max_hr FROM batting
			 GROUP BY playerid
			 HAVING (MAX(yearid) - MIN(yearid) >=10))
SELECT playerid, namefirst, namelast, hr AS homeruns_in_2016 FROM batting
RIGHT JOIN cte USING(playerid)
INNER JOIN people USING(playerid)
WHERE yearid = 2016 AND hr = max_hr AND hr >=1;