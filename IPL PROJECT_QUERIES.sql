USE ipl;
-- *********************************************************************************************************************************************************
-- 1.	Show the percentage of wins of each bidder in the order of highest to lowest percentage.

SELECT 
    BIDDER_ID,
    ROUND((SUM(rnk) / COUNT(rnk)) * 100, 0) AS percentage
FROM
    (SELECT 
        *, IF(BID_STATUS = 'won', 1, 0) rnk
    FROM
        ipl_bidding_details) T
GROUP BY BIDDER_ID order by percentage DESC ;
------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 2.	Display the number of matches conducted at each stadium with the stadium name and city.

SELECT 
    I.stadium_id,
    s.STADIUM_NAME,
    s.city,
    COUNT(I.match_id) match_count
FROM
    ipl_match_schedule I
        JOIN
    ipl_stadium s ON s.stadium_id = i.stadium_id
GROUP BY I.stadium_id , s.STADIUM_NAME , s.city
ORDER BY match_count DESC;
------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 3.	In a given stadium, what is the percentage of wins by a team that has won the toss?

SELECT 
    stad.stadium_id,
    stad.stadium_name,
    (SELECT 
            COUNT(*)
        FROM
            ipl_match mat
                INNER JOIN
            ipl_match_schedule schd ON mat.match_id = schd.match_id
        WHERE
            schd.stadium_id = stad.stadium_id
                AND (toss_winner = match_winner)) / (SELECT 
            COUNT(*)
        FROM
            ipl_match_schedule schd
        WHERE
            schd.stadium_id = stad.stadium_id) * 100 AS 'Toss and Match Wins %'
FROM
    ipl_stadium stad;
------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 4.	Show the total bids along with the bid team and team name.
SELECT 
    bd.BID_TEAM,
    T.TEAM_NAME,
    COUNT(bd.BID_TEAM) `total bids`
FROM
    ipl_bidder_points dp
        JOIN
    ipl_bidding_details bd ON dp.BIDDER_ID = bd.BIDDER_ID
        JOIN
    ipl_team t ON t.TEAM_ID = bd.BID_TEAM
GROUP BY  bd.BID_TEAM;
------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 5.	Show the team ID who won the match as per the win details.
 
 SELECT 
    TEAM_ID,
    TEAM_NAME,
    TEAM_ID1,
    TEAM_ID2,
    MATCH_WINNER,
    IPL_MATCH.WIN_DETAILS
FROM
    IPL_TEAM
        INNER JOIN
    IPL_MATCH ON SUBSTR(IPL_TEAM.REMARKS, 1, 3) = SUBSTR(IPL_MATCH.WIN_DETAILS, 6, 3)
        OR SUBSTR(IPL_TEAM.REMARKS, 1, 2) = SUBSTR(IPL_MATCH.WIN_DETAILS, 6, 2);

------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 6.	Display the total matches played, total matches won and total matches lost by the team along with its team name.
SELECT 
    s.TEAM_ID,
    t.TEAM_NAME,
    sum(s.MATCHES_PLAYED) total_matches_played,
    sum(s.MATCHES_WON) total_matches_won,
    sum(s.MATCHES_LOST) total_matches_lost
FROM
    ipl_team_standings s
        JOIN
    ipl_team t ON s.TEAM_ID = t.team_id
GROUP BY
	s.TEAM_ID;
------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 7.	Display the bowlers for the Mumbai Indians team.
SELECT 
    tp.*, p.PLAYER_NAME, t.team_name
FROM
    ipl_team_players tp
        JOIN
    ipl_player p ON tp.PLAYER_ID = p.PLAYER_ID
        AND tp.PLAYER_ROLE = 'Bowler'
        INNER JOIN
    IPL_TEAM t ON t.TEAM_ID = tp.TEAM_ID
        AND TEAM_NAME LIKE '%Mumbai%';
------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 8.	How many all-rounders are there in each team, Display the teams with more than 4 all-rounders in descending order.
SELECT 
      t.team_name,tp.PLAYER_ROLE,count(tp.PLAYER_ID) total_allrounders
FROM
    ipl_team_players tp
        JOIN
    ipl_player p ON tp.PLAYER_ID = p.PLAYER_ID
        INNER JOIN
    IPL_TEAM t ON t.TEAM_ID = tp.TEAM_ID 
    WHERE 
		tp.PLAYER_ROLE='All-Rounder' 
	GROUP BY 
		tp.PLAYER_ROLE,t.team_name 
	HAVING 
		total_allrounders>4 ORDER BY total_allrounders DESC;
------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 9. Write a query to get the total bidders' points for each bidding status of those bidders who bid on CSK when they won the match in
--  M. Chinnaswamy Stadium bidding year-wise. Note the total bidders’ points in descending order and the year is the bidding year. 
-- Display columns: bidding status, bid date as year, total bidder’s points
SELECT 
    bd.bid_status,
    YEAR(bd.bid_date) AS year,
    (SELECT 
            SUM(bp.total_points)
        FROM
            ipl_bidder_points bp
        WHERE
            bd.bidder_id = bp.bidder_id
        GROUP BY bd.bidder_id) total_bidders_points
FROM
    ipl_team t
        JOIN
    ipl_bidding_details bd ON t.team_id = bd.bid_team
        JOIN
    ipl_match_schedule s ON s.SCHEDULE_ID = bd.SCHEDULE_ID
        JOIN
    ipl_stadium st ON st.STADIUM_ID = s.STADIUM_ID
WHERE
    t.team_name = 'Chennai Super Kings'
        AND st.stadium_name = 'M. Chinnaswamy Stadium'
        AND bid_status = 'Won';
------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 10.	Extract the Bowlers and All-Rounders that are in the 5 highest number of wickets.
-- Note 
-- 1.Use the performance_dtls column from ipl_player to get the total number of wickets
-- 2.Do not use the limit method because it might not give appropriate results when players have the same number of wickets
-- 3.Do not use joins in any cases.
-- 4.Display the following columns teamn_name, player_name, and player_role.
SELECT 
    *
FROM
    ipl.ipl_player;
SELECT 
	player_id,player_name,wickets,player_role 
FROM
	(SELECT *, DENSE_RANK()OVER(order by wickets DESC) RNK FROM
		(SELECT ip.PLAYER_ID,ip.PLAYER_NAME,CAST(substring_index(substring_index(ip.PERFORMANCE_DTLS,'Wkt-',-1),'Dot',1) AS UNSIGNED) wickets,
		(SELECT player_role FROM ipl_team_players WHERE ip.player_id=player_id) Player_role FROM ipl_player ip)TEMP)TEMP2 WHERE RNK<5;
------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 11.	show the percentage of toss wins of each bidder and display the results in descending order based on the percentage

SELECT 
    BIDDER_ID,
    (ROUND(SUM(CASE
                WHEN BID_TEAM = TOSS_WIN THEN 1
                ELSE 0
            END) * 100 / COUNT(BIDDER_ID),
            0)) percentage_of_toss_wins
FROM
    (SELECT 
        BD.BIDDER_ID,
            BD.BID_TEAM,
            MS.MATCH_ID,
            M.TEAM_ID1,
            M.TEAM_ID2,
            (CASE
                WHEN M.TOSS_WINNER = 1 THEN M.TEAM_ID1
                ELSE M.TEAM_ID2
            END) TOSS_WIN
    FROM
        ipl_bidding_details BD
    JOIN ipl_match_schedule MS ON MS.SCHEDULE_ID = BD.SCHEDULE_ID
    JOIN ipl_match M ON M.MATCH_ID = MS.MATCH_ID) T
GROUP BY BIDDER_ID;
------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 12.	find the IPL season which has a duration and max duration.-- Output columns should be like the below:
 -- Tournment_ID, Tourment_name, Duration column, Duration
SELECT 
	*,MAX(DURATION)OVER() max_duration 
FROM
	(SELECT 
		TOURNMT_ID,
        TOURNMT_NAME, 
        DATEDIFF(TO_DATE,FROM_DATE) Duration 
	FROM 
		ipl_tournament)T;
------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 13.	Write a query to display to calculate the total points month-wise for the 2017 bid year. sort the results based on total points in descending order and month-wise in ascending order.
-- Note: Display the following columns:
-- 1.	Bidder ID, 2. Bidder Name, 3. Bid date as Year, 4. Bid date as Month, 5. Total points
-- Only use joins for the above query queries.
SELECT DISTINCT
    b.BIDDER_ID,
    b.BIDDER_NAME,
    YEAR(bd.BID_DATE) AS Year,
    MONTH(bd.BID_DATE) AS Month,
    p.TOTAL_POINTS AS Total_Points
FROM
    ipl_bidder_details b
        INNER JOIN
    ipl_bidder_points p ON b.BIDDER_ID = p.BIDDER_ID
        INNER JOIN
    ipl_bidding_details bd ON p.BIDDER_ID = bd.BIDDER_ID
WHERE
    YEAR(bd.BID_DATE) = 2017
ORDER BY Total_Points DESC , Month ASC;
------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 14.	Write a query for the above question using sub-queries by having the same constraints as the above question.

SELECT 
    bd.bidder_id,
    (SELECT 
            b.bidder_name
        FROM
            ipl_bidder_details b
        WHERE
            b.bidder_id = bd.bidder_id) AS bidder_name,
    YEAR(bd.bid_date) AS `year`,
    MONTHNAME(bd.bid_date) AS `month`,
    (SELECT 
            p.total_points
        FROM
            ipl_bidder_points p
        WHERE
            p.bidder_id = bd.bidder_id) AS total_points
FROM
    ipl_bidding_details bd
WHERE
    YEAR(bid_date) = 2017
GROUP BY bidder_id , bidder_name , year , month , total_points
ORDER BY total_points DESC;

------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 15.	Write a query to get the top 3 and bottom 3 bidders based on the total bidding points for the 2018 bidding year.
-- Output columns should be: like Bidder Id, Ranks (optional), Total points, Highest_3_Bidders --> columns contains name of bidder, Lowest_3_Bidders  
-- --> columns contains name of bidder;
SELECT 
	* 
FROM 
	(SELECT BIDDER_ID,TOTAL_POINTS,
			(CASE WHEN RNK<4 THEN name END)Lowest_3_Bidders,
            (CASE WHEN RNK>15 THEN name END)Highest_3_Bidders 
	FROM 
		(SELECT *,
				dense_rank()OVER(ORDER BY TOTAL_POINTS DESC) RNK 
		FROM 
			(SELECT bd.BIDDER_ID,
					SUM(bd.TOTAL_POINTS)TOTAL_POINTS,
                    (SELECT BIDDER_NAME FROM ipl_bidder_details WHERE BIDDER_ID=bd.BIDDER_ID) name
			FROM 
				ipl_bidder_points bd 
			GROUP BY 
            bd.BIDDER_ID)T)T1)T2 
            WHERE 
            Lowest_3_Bidders IS NOT NULL 
            OR
            Highest_3_Bidders IS NOT NULL ;



