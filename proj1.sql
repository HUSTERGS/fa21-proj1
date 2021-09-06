-- Before running drop any existing views
DROP VIEW IF EXISTS q0;
DROP VIEW IF EXISTS q1i;
DROP VIEW IF EXISTS q1ii;
DROP VIEW IF EXISTS q1iii;
DROP VIEW IF EXISTS q1iv;
DROP VIEW IF EXISTS q2i;
DROP VIEW IF EXISTS q2ii;
DROP VIEW IF EXISTS q2iii;
DROP VIEW IF EXISTS q3i;
DROP VIEW IF EXISTS q3ii;
DROP VIEW IF EXISTS q3iii;
DROP VIEW IF EXISTS q4i;
DROP VIEW IF EXISTS q4ii;
DROP VIEW IF EXISTS q4iii;
DROP VIEW IF EXISTS q4iv;
DROP VIEW IF EXISTS q4v;

-- Question 0
CREATE VIEW q0(era)
AS
--   SELECT 1 -- replace this line
    select max(era)
    from pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
--   SELECT 1, 1, 1 -- replace this line
    select namefirst, namelast, birthyear
    from people
    where weight > 300
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
--   SELECT 1, 1, 1 -- replace this line
    select namefirst, namelast, birthyear
    from people
    where namefirst like '% %'
    order by namefirst, namelast asc
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
--   SELECT 1, 1, 1 -- replace this line
    select birthyear, avg(height), count(*)
    from people
    group by birthyear
    order by birthyear asc
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
--   SELECT 1, 1, 1 -- replace this line
    select birthyear, avg(height), count(*)
    from people
    group by birthyear
    having avg(height) > 70
    order by birthyear asc
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
--   SELECT 1, 1, 1, 1 -- replace this line
    select namefirst, namelast, halloffame.playerid, yearid
    from people, halloffame
    where halloffame.playerID = people.playerID and inducted = 'Y'
    order by yearid desc, halloffame.playerid asc
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
--   SELECT 1, 1, 1, 1, 1 -- replace this line
    select people.namefirst, people.namelast, people.playerid, schools.schoolid, halloffame.yearid
    from collegeplaying, halloffame, schools, people
    where collegeplaying.playerid = halloffame.playerID and
          collegeplaying.playerid = people.playerID and
          schools.schoolID = collegeplaying.schoolID and
          halloffame.inducted = 'Y' and
          schools.schoolState = 'CA'
    order by halloffame.yearid desc, collegeplaying.schoolID, collegeplaying.playerid asc
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
--   SELECT 1, 1, 1, 1 -- replace this line
    select halloffame.playerid, namefirst, namelast, schoolid
    from halloffame, people left outer join collegeplaying on people.playerid = collegeplaying.playerid
    where people.playerID = halloffame.playerID and
          halloffame.inducted = 'Y'
    order by halloffame.playerid desc, schoolid asc
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
--   SELECT 1, 1, 1, 1, 1 -- replace this line
    select people.playerID, nameFirst, nameLast, A.yearID, A.slg
    from people, (
        select playerID, yearid,  (H + H2B + 2 * H3B + 3 * HR) * 1.0 / AB as slg from batting
        where AB > 50
        order by slg desc
        limit 10
        ) as A
    where A.playerID = people.playerID;
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
--   SELECT 1, 1, 1, 1 -- replace this line
    select people.playerID, nameFirst, nameLast, lslg
    from people, (
        select playerID, (H + H2B + 2 * H3B + 3 * HR) * 1.0 / AB as lslg
        from (
            select playerID, sum(AB) as AB, sum(H) as H, sum(H2B) as H2B, sum(H3B) as H3B, sum(HR) as HR
            from batting
            group by playerID
            having sum(AB) > 50
        )
        order by lslg desc
        limit 10
        ) as A
        where people.playerID = A.playerID;
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
--   SELECT 1, 1, 1 -- replace this line
    select nameFirst, nameLast, lslg
    from people, (
        select playerID, (H + H2B + 2 * H3B + 3 * HR) * 1.0 / AB as lslg
        from (
            select playerID, sum(AB) as AB, sum(H) as H, sum(H2B) as H2B, sum(H3B) as H3B, sum(HR) as HR
            from batting
            group by playerID
            having sum(AB) > 50
        )
    ) as A
    where people.playerID = A.playerID and
        lslg > (
            select (sum(H) + sum(H2B) + 2 * sum(H3B) + 3 * sum(HR)) * 1.0 / sum(AB)
            from batting
            where playerID = 'mayswi01'
            group by playerID
            )
    order by nameFirst;
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
--   SELECT 1, 1, 1, 1 -- replace this line
    select yearID, min(salary), max(salary), avg(salary) from salaries
    group by yearID
    order by yearID;
;

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS
--   SELECT 1, 1, 1, 1 -- replace this line
-- TODO: actually wrong way
select bin, bin * step + m, (bin + 1) * step + m, count(*) from  (select salary, (
(select max(salary) from salaries where yearID = 2016) -
(select min(salary) from salaries where yearID = 2016)) / 10 as step, (select min(salary) from salaries where yearID = 2016) as m,
       CAST ((salary - (select min(salary) from salaries where yearID = 2016)) * 10 /
((select max(salary) from salaries where yearID = 2016) + 1 -
(select min(salary) from salaries where yearID = 2016)) as INT) as bin
from salaries
where yearID = 2016) as A
group by bin;
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
--   SELECT 1, 1, 1, 1 -- replace this line
    select B.yearID + 1, Bmin - Amin, Bmax - Amax, Bavg - Aavg from
        (select yearID, max(salary) as Amax, min(salary) as Amin, avg(salary) Aavg from salaries
        group by yearID)
        as A,
        (select yearID - 1 as yearID, max(salary) as Bmax, min(salary) Bmin, avg(salary) Bavg from salaries
        group by yearID) as B
    where A.yearID = B.yearID;
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
--   SELECT 1, 1, 1, 1, 1 -- replace this line
    select A.playerID, nameFirst, nameLast, salary, A.y from
    (select *, max(salary), 2001 as y from salaries where yearID = 2001
    UNION
    select *, max(salary), 2000 as y from salaries where yearID = 2000) as A join people on A.playerID = people.playerID;
;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
--   SELECT 1, 1 -- replace this line
    select allstarfull.teamID, max(salary) - min(salary) from allstarfull, salaries
    where allstarfull.yearID = 2016 and
          allstarfull.playerID = salaries.playerID and
          salaries.yearID = 2016
    group by allstarfull.teamID;
;

