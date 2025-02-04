CREATE TABLE Athlete_STG (
  id INTEGER,
Name TEXT, 
Sex TEXT, 
Age TEXT, 
Height TEXT, 
Weight TEXT, 
Team TEXT, 
NOC TEXT, 
Games TEXT, 
Year TEXT, 
Season TEXT, 
City TEXT, 
Sport TEXT, 
Event TEXT, 
Medal TEXT
);
copy Athlete_STG from 'C:\Projects\Olympic_summer_games_Analysis\athlete_events.csv' 
delimiter ',' csv HEADER;
-------------------------------
--data cleaning :
update Athlete_stg
set height=NULL
where height='NA';
update Athlete_stg
set weight=NULL
where weight='NA';
update Athlete_stg
set age=NULL
where age='NA';
---------------------------------

CREATE TABLE Athlete (
  id INTEGER,
Name TEXT, 
Sex character, 
Age INTEGER, 
Height numeric, 
Weight numeric, 
Team TEXT, 
NOC TEXT, 
Games TEXT, 
Year integer, 
Season TEXT, 
City TEXT, 
Sport TEXT, 
Event TEXT, 
Medal TEXT
);
insert into Athlete
select 
id,
Name, 
cast(Sex as character(1)), 
cast(Age as INTEGER), 
cast(Height as numeric), 
cast(Weight as numeric), 
Team, 
NOC, 
Games, 
CAST(Year as integer), 
Season , 
City , 
Sport, 
Event, 
Medal
 from Athlete_stg;
 
create table NOC_region(
NOC character(3),
region varchar,
notes varchar);
copy NOC_region from 'C:\Projects\Olympic_summer_games_Analysis\noc_regions.csv' 
delimiter ',' csv HEADER;