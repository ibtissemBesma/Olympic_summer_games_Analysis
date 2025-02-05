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