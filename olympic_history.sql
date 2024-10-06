select * from athletes;
select * from athlete_events;

--1.which team has won the maximum gold medals over the years
select top 1 team,count(distinct event) as cnt from athlete_events ae
inner join athletes a on ae.athlete_id=a.id
where medal='Gold'
group by team 
order by cnt desc;

--2.for each team print total silver medals and year in which they won maximum silver medal
--output 3 columns
-- team,total_silver_medals, year_of_max_silver
with total_silver_medals as (
select a.team,ae.year , count(distinct event) as silver_medals
,rank() over(partition by team order by count(distinct event) desc) as rn
from athlete_events ae
inner join athletes a on ae.athlete_id=a.id
where medal='Silver'
group by a.team,ae.year)
select team,sum(silver_medals) as total_silver_medals, 
max(case when rn=1 then year end) as  year_of_max_silver
from total_silver_medals
group by team;

--3.which player has won maximum gold medals  amongst the players 
--which have won only gold medal (never won silver or bronze) over the years
with players as (
select a.name,ae.medal
from athlete_events ae 
inner join athletes a on ae.athlete_id=a.id)
select top 1 name,count(1) as no_of_gold_medals from players
where name not in (select distinct name from players where medal in ('Silver','Bronze')) and medal ='Gold'
group by name
order by no_of_gold_medals desc;

--4.in each year which player has won maximum gold medal . Write a query to print year,player name 
--and no of golds won in that year . In case of a tie print comma separated player names.
with gold_medal_player as (
select a.name,ae.medal,ae.year,count(1) as no_of_gold_medals from athlete_events ae
inner join athletes a on ae.athlete_id=a.id
where medal = 'Gold'
group by a.name,ae.medal,ae.year)
select  year,no_of_gold_medals,STRING_AGG(name,',') as players from 
(select *, rank() over(partition by year order by no_of_gold_medals desc) rn from gold_medal_player) a
where rn=1
group by year,no_of_gold_medals;

--5.in which event and year India has won its first gold medal,first silver medal and first bronze medal
--print 3 columns medal,year,sport
select distinct * from(
select event,year,medal,rank() over(partition by medal order by year) rn
from athlete_events ae
inner join athletes a on ae.athlete_id=a.id
where team = 'India' and medal != 'NA') A
where rn=1

--6.find players who won gold medal in summer and winter olympics both.
select a.name from athlete_events ae
inner join athletes a on ae.athlete_id=a.id
where ae.medal='Gold'
group by a.name having count(distinct season)=2

--7.find players who won gold, silver and bronze medal in a single olympics. print player name along with year.
select name,year from athlete_events ae
inner join athletes a on ae.athlete_id=a.id
where medal !='NA'
group by name,year having count(distinct medal)=3

--8.find players who have won gold medals in consecutive 3 summer olympics in the same event.
--Consider only olympics 2000 onwards. 
--Assume summer olympics happens every 4 year starting 2000. print player name and event name.
with players as(
select name,year,event from athlete_events ae
inner join athletes a on ae.athlete_id=a.id
where year>=2000 and medal = 'Gold' and season ='Summer'
group by name,year,event)
select * from (select *, lag(year,1) over(partition by name,event order by year) prev_year,
lead(year,1) over(partition by name,event order by year) next_year from players) A
where year=prev_year+4 and year=next_year-4;
