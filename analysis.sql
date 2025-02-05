select * from athlete;

select year,
	   count(*)
from athlete
group by 1
order by year desc;
------------------

select * from athelete_DC 
select year,
	   count(*)
from athelete_DC
group by 1
order by year desc;
select distinct medal,count(*) from athelete_DC
group by 1;
------------
select athlete,
	   count(*) as nb_medal,
	   ROW_NUMBER() over(order by count(*) desc) as rank_  
from athelete_DC
group by 1;
select athlete,
	   count(*) as nb_medal,
	   RANK() over(order by count(*) desc) as rank_  
from athelete_DC
group by 1;
select athlete,
	   count(*) as nb_medal,
	   RANK() over(order by count(*) desc) as rank_  
from athelete_DC
group by 1;
-----------------------
select *
from	
	athelete_DC;
--------------
select *
from	
	noc_region;
------------------
WITH Year_City as (select distinct year, city 
from  athelete_DC)
select year,
	   city,
	   LEAD(city,1) over (order by year) next_city,
	   LEAD(city,2) over (order by year) after_next_city
from
	   Year_City;
------------------
WITH Year_City as (select distinct year, city 
from  athelete_DC)
select year,
	   city,
	   FIRST_VALUE(city) over (order by year) FISRT_city,
	   LAST_VALUE(city) over (order by year asc
	   						  ROWS BETWEEN UNBOUNDED PRECEDING
							  AND UNBOUNDED FOLLOWING) LAST_city 
							  ''' By default, a window starts at the
beginning of the table or partition and ends
at the current row'''
from
	   Year_City;
-----------------------------
'''
For each year, fetch the current 
gold medalist and the gold medalist 3 competitions ahead of the current row.'''
WITH Discus_Medalists AS (
  SELECT DISTINCT
    Year,
    Athlete
  FROM athelete_DC
  WHERE Medal = 'Gold'
    AND Event = 'Discus Throw'
    AND Gender = 'Women'
    AND Year >= 2000)
select year,
	   Athlete,
	   LEAD(Athlete,3) over(order by year )
from Discus_Medalists;
----------------
''' Return all athletes and the first athlete ordered by alphabetical order. '''
select distinct athlete,
	   FIRST_VALUE(athlete) over (order by athlete asc)
from 
	   athelete_DC;
---------------------
''' Return the year and the city in which each Olympic games were held.
Fetch the last city in which the Olympic games were held '''
WITH Year_City as (select distinct year, city 
from  athelete_DC)
select 
		year,
		city,
		LAST_VALUE(city) over(order by year
							  ROWS BETWEEN UNBOUNDED PRECEDING
							  AND UNBOUNDED FOLLOWING) as last_city
from 
		Year_City;
--------------------
select  country,
		count(distinct year) as nb,
		RANK() over(order by count(distinct year) desc) as rank_,
		DENSE_RANK() over(order by count(distinct year) desc) as rank_D
from	
		athelete_DC
group by 1
order by 2 desc;
--------------------
select  country,
		count(distinct year) as nb,
		ROW_NUMBER() over(order by count(distinct year) desc) ROW_Num,
		RANK() over(order by count(distinct year) desc) as rank_,
		DENSE_RANK() over(order by count(distinct year) desc) as rank_D
from	
		athelete_DC
group by 1
order by 2 desc;
------------------------
''' Rank each athlete by the number of medals they ve earned -- the higher the count, 
the higher the rank -- with identical numbers in case of identical values.'''
select  athlete,
		count(*) as medals,
		RANK() over(order by count(*) asc) as rank_,
		ROW_NUMBER() over(order by count(*) asc) as ROW_Num
from athelete_DC
group by 1
order by rank_ desc;
-----------------------------------
''' Rank each country s athletes by the count of medals they ve earned -- the higher the count, 
the higher the rank -- without skipping numbers in case of identical values.'''
with Athlete_Medals AS(
select  Country, 
		Athlete, 
		COUNT(*) AS Medals
  FROM athelete_DC
  WHERE
    Country IN ('JPN', 'KOR')
    AND Year >= 2000
  GROUP BY Country, Athlete
  HAVING COUNT(*) > 1)
select 
		country,
		Athlete,
		medals,
		DENSE_RANK() over(  partition by country
							order by medals desc) as Rank_D
from 
		Athlete_Medals
ORDER BY Country ASC, RANK_D ASC;
--------------------------------------------------------
--- Paging
select distinct Year, 
		Country,
		NTILE(13) over(partition by country,year
						order by country asc) as page
from athelete_DC
order by page asc;
---------------------------------------------------------
WITH Country_Medals AS (
  SELECT
    Year, Country, COUNT(*) AS Medals
  FROM athelete_DC
  WHERE
    Country IN ('CHN', 'KOR', 'JPN')
    AND Medal = 'Gold' AND Year >= 2000
  GROUP BY Year, Country)

SELECT
  -- Return the max medals earned so far per country
  year,
  country,
  medals,
  max(medals) OVER (PARTITION BY country
                ORDER BY year ASC) AS Max_Medals
FROM Country_Medals
ORDER BY Country ASC, Year ASC;
---------------------------------------------
with RUSSIA_MEDALS AS(SELECT YEAR,
		count(*) as medals
from  athelete_DC
where
		country='RUS'
		and lower(medal)='gold'
group by YEAR
Order by year)
select 
		YEAR,
		medals,
		max(medals) over(order by year desc) as max_medals,
		max(medals) over(order by year desc
						 ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) as max_medals_
from
		RUSSIA_MEDALS
order by year desc;
------------------------------------
''' Return the year, medals earned, 
and the maximum medals earned, comparing only the current year and the next year.
 '''
WITH Scandinavian_Medals AS (
SELECT
    Year, 
	COUNT(*) AS Medals
FROM athelete_DC
WHERE
	 Country IN ('DEN', 'NOR', 'FIN', 'SWE', 'ISL')
     AND Medal = 'Gold'
GROUP BY Year)
select 
		year,
		medals,
		max(medals) over(order by year ASC 
						 ROWS BETWEEN CURRENT ROW AND 1 FOLLOWING) Max_Medals
from Scandinavian_Medals
order by year ASC;
---------------------------------
''' Return the athletes, medals earned, and the maximum medals earned, comparing only 
the last two and current athletes, ordering by athletes names in alphabetical order. '''
WITH Chinese_Medals AS (
SELECT
    athlete, 
	COUNT(*) AS Medals
FROM athelete_DC
WHERE
	 Country = 'CHN' AND 
	 Medal = 'Gold' AND 
	 Year >= 2000
GROUP BY Athlete)
select 
		athlete,
		medals,
		max(medals) over(order by athlete ASC 
						 ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) Max_Medals
from Chinese_Medals
order by athlete ASC ;
-----------------------------------
-- RANGE BETWEEN :: treate duplication id over(order by) as single entity
----------------------------------
''' Calculate the 3-year moving average of medals earned. '''
WITH Russian_Medals AS (
SELECT
    Year, COUNT(*) AS Medals
FROM athelete_DC
WHERE
    Country = 'RUS' AND 
	Medal = 'Gold'  AND 
	Year >= 1980
GROUP BY Year)
select 
		year,
		medals,
		avg(medals) over(order by year asc
						ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS Medals_MA
from Russian_Medals
order by year asc;
---------------------------------------
''' Calculate the 3-year moving sum of medals earned per country. '''
WITH Country_Medals AS (
SELECT Year, 
	   Country, 
	   COUNT(*) AS Medals
FROM athelete_DC
GROUP BY Year, Country)
select year,
	   country,
	   medals,
	   sum(medals) over(partition by country
	   					ORDER BY Year ASC
						ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS Medals_MA
FROM Country_Medals
ORDER BY  Country ASC, Year ASC
--------------------------------------------------------
-- PIVOTING TABLE

-- Create the correct extension to enable CROSSTAB
CREATE EXTENSION IF NOT EXISTS tablefunc;

SELECT * FROM CROSSTAB($$
  SELECT
    Gender, Year, Country
  FROM athelete_DC
  WHERE
    Year IN (2008, 2012)
    AND Medal = 'Gold'
    AND Event = 'Pole Vault'
  ORDER By Gender ASC, Year ASC;
-- Fill in the correct column names for the pivoted table
$$) AS ct (Gender VARCHAR,
           "2008" VARCHAR,
           "2012" VARCHAR)

ORDER BY Gender ASC;
-----------------------------
''' Count the gold medals that France (FRA),
the UK (GBR), and Germany (GER) have earned per country and year. '''
select country,
		year,
		count(*) as awards
from athelete_DC
where country in ('FRA','GBR','GER') AND 
	  Year IN (2004, 2008, 2012) AND 
	  Medal = 'Gold'
group by country,year
order by country asc,year asc;
-------------------------
''' Select the country and year columns, 
then rank the three countries by how many gold medals they earned per year.'''
WITH Country_Awards AS (
SELECT
    Country,
    Year,
    COUNT(*) AS Awards
FROM athelete_DC
WHERE    Country IN ('FRA', 'GBR', 'GER')AND 
		 Year IN (2004, 2008, 2012) AND 
		 Medal = 'Gold'
GROUP BY Country, Year)
select country,
		year,
		Awards,
		rank() over(partition by year
					order by Awards desc)::integer as rank_
from Country_Awards
ORDER BY Country ASC, Year ASC;
-----------------------------
CREATE EXTENSION IF NOT EXISTS tablefunc;

SELECT * FROM CROSSTAB($$
  WITH Country_Awards AS (
    SELECT
      Country,
      Year,
      COUNT(*) AS Awards
    FROM athelete_DC
    WHERE
      Country IN ('FRA', 'GBR', 'GER')
      AND Year IN (2004, 2008, 2012)
      AND Medal = 'Gold'
    GROUP BY Country, Year)

  SELECT
    Country,
    Year,
    RANK() OVER
      (PARTITION BY Year
       ORDER BY Awards DESC) :: INTEGER AS rank
  FROM Country_Awards
  ORDER BY Country ASC, Year ASC;
-- Fill in the correct column names for the pivoted table
$$) AS ct (Country VARCHAR,
           "2004" INTEGER,
           "2008" INTEGER,
           "2012" INTEGER)

Order by Country ASC;
---------------------------------
'''Count the gold medals awarded per country and gender.
Generate Country-level gold award counts. '''
SELECT COUNTRY,
		GENDER,
		count(*) as awards
from athelete_DC
WHERE
  Year = 2004
  AND Medal = 'Gold'
  AND Country IN ('DEN', 'NOR', 'SWE')
group by COUNTRY,GENDER
ORDER BY Country ASC, Gender ASC;
--------------
SELECT COUNTRY,
		GENDER,
		count(*) as awards
from athelete_DC
WHERE
  Year = 2004
  AND Medal = 'Gold'
  AND Country IN ('DEN', 'NOR', 'SWE')
group by COUNTRY,ROLLUP(GENDER) -- Country-level gold award counts.
ORDER BY Country ASC, Gender ASC;
-------------------------------
SELECT COUNTRY,
		GENDER,
		count(*) as awards
from athelete_DC
WHERE
  Year = 2004
  AND Medal = 'Gold'
  AND Country IN ('DEN', 'NOR', 'SWE')
group by ROLLUP(COUNTRY,GENDER) -- Country-level gold award counts.
ORDER BY Country ASC, Gender ASC;
----------------------------------------
''' Count the medals awarded per gender and medal type.
Generate all possible group-level counts 
(per gender and medal type subtotals and the grand total).'''
SELECT 
		GENDER,
		medal,
		count(*) as awards
from athelete_DC
WHERE
   Year = 2012
  AND Country = 'RUS'
group by ROLLUP(GENDER,medal) -- AS ROLLUP(medal)
ORDER BY gender ASC, medal ASC;
----------------
SELECT 
		GENDER,
		medal,
		count(*) as awards
from athelete_DC
WHERE
   Year = 2012
  AND Country = 'RUS'
group by CUBE(GENDER,medal) -- 
ORDER BY gender ASC, medal ASC;
----------------
SELECT 
		coalesce(GENDER,'ALL GENDERS') as GENDER,
		coalesce(medal,'ALL MEDALS') as medal,
		count(*) as awards
from athelete_DC
WHERE
   Year = 2012
  AND Country = 'RUS'
group by CUBE(GENDER,medal) -- 
ORDER BY gender ASC, medal ASC;
-----------------------
-- STRING_AGG function
select STRING_AGG(gender,'-')
from athelete_DC;
-- Clean and compress query result
-----------------------------
WITH Country_Medals AS (
  SELECT
    Country,
    COUNT(*) AS Medals
  FROM Summer_Medals
  WHERE Year = 2000
    AND Medal = 'Gold'
  GROUP BY Country),

  Country_Ranks AS (
  SELECT
    Country,
    RANK() OVER (ORDER BY Medals DESC) AS Rank
  FROM Country_Medals
  ORDER BY Rank ASC)

-- Compress the countries column
SELECT STRING_AGG(Country,', ')
FROM Country_Ranks
-- Select only the top three ranks
WHERE rank <=3;
