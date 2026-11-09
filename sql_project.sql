select * from IPLPlayers;

--Q1 Find the total spending on players for each team
select Team ,sum(Price_in_cr)as Total_Price
from IPLPlayers
group by Team
order by Total_Price desc;


--Q2 Find the top 3 highest paid 'all arounder across all team

select top 3 player,team,Price_in_cr
from IPLPlayers
where role='all-rounder'
order by Price_in_cr desc


--Q3 Find the highest-priced player in each team

with CTE_MP as(
	select Team,max(price_in_cr) as max_price
	from IPLPlayers 
	group by Team
)
select i.team,i.player,i.price_in_cr
from IPLPlayers i 
join CTE_MP c on i.Team=c.Team
where i.Price_in_cr=c.max_price;

--Q4 Rank players by their price within each team and list the top 2 for every team

with rankedplayers as(
select player,team,price_in_cr ,
row_number() over(partition by team order by price_in_cr DESC) as win
from IPLPlayers
)
select player,team,price_in_cr ,win
from rankedplayers
where win in(1,2)

--Q5 Find the most expensive player from each team,along with second-most expensive player's name
--and price

WITH rankedplayer AS (
    SELECT 
        player,
        team,
        price_in_cr,
        ROW_NUMBER() OVER (
            PARTITION BY team 
            ORDER BY price_in_cr DESC
        ) AS rankwithinteam
    FROM iplplayers
)
SELECT 
    team,
    MAX(CASE WHEN rankwithinteam = 1 THEN player END) AS mostexpensiveplayer,
    MAX(CASE WHEN rankwithinteam = 1 THEN price_in_cr END) AS highestprice,

    MAX(CASE WHEN rankwithinteam = 2 THEN player END) AS secondmostexpensiveplayer,
    MAX(CASE WHEN rankwithinteam = 2 THEN price_in_cr END) AS secondhighestprice

FROM rankedplayer
GROUP BY team;

--Q6 Calculate the percentage contribution of each player's price to their team's total spending
select player,team,price_in_cr,
    cast(price_in_cr/(sum(price_in_cr) over (partition by team))* 100 as decimal(10,2)) as contributionpercentage
from iplplayers


--Q7 Classify the player as 'high','medium','low' price based on the following rules
--high price > 15 crores
--medium price between 5 crores and 15 crores
--low price<5 crores
--and find out the numbers of players in backet

with cte_br as(
    select team,player,price_in_cr,
        case
            when price_in_cr >15 then 'high'
            when price_in_cr between 5 and 15 then 'medium'
            else 'low'
        end as pricecategory
    from iplplayers
)
select team,pricecategory ,count(*) as noofplayers
from cte_br
group by team,pricecategory
order by team,pricecategory


--Q8 Find the average price of indian players and compare it with overseas players using a subquery

SELECT
    'Indian' AS playertype,
    (SELECT AVG(price_in_cr)
     FROM iplplayers
     WHERE type LIKE 'indian%') AS avg_price

UNION ALL

SELECT
    'Overseas' AS playertype,
    (SELECT AVG(price_in_cr)
     FROM iplplayers
     WHERE type LIKE 'overseas%') AS avg_price;

--Q9 Identify the players who earn more than average price of their team

SELECT player, team, price_in_cr
FROM iplplayers p
WHERE price_in_cr > (
    SELECT AVG(price_in_cr)
    FROM iplplayers p2
    WHERE p2.team = p.team
);

--Q10 for each role, find the most expensive player and their price using correlated subquery

SELECT 
    p.role,
    p.player,
    p.price_in_cr
FROM IPLPlayers p
WHERE p.price_in_cr = (
    SELECT MAX(p2.price_in_cr)
    FROM IPLPlayers p2
    WHERE p2.role = p.role
);