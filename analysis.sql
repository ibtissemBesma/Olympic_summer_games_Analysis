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
