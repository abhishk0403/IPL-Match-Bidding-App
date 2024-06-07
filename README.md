# IPL Data Analysis Project
This project involves analyzing Indian Premier League (IPL) data using SQL queries to extract meaningful insights from the data.

## Introduction
This project is focused on analyzing IPL data to gain insights into various aspects such as player performances, team statistics, and bidding details. 
The analysis is performed using MySQL queries, with the data stored in a MySQL database.

## Data
The data used in this project includes several tables such as:

ipl_player: Contains details about the players.
ipl_team: Contains details about the teams.
ipl_bidding_details: Contains details about the bidding.
ipl_bidder_details: Contains details about the bidders.
ipl_bidder_points: Contains the points awarded to bidders.
IPL_User: Contains details of the user
IPL_Stadium: Contains details of the stadium
IPL_Team_players: Contains details about the players in IPL.
IPL_Match: Contains details about matches
IPL_Match_Schedule: Contains details about IPL_Match_Schedule
IPL_Team_Standings: Contains details about IPL_teams statistics

## Queries
Here are some of the key queries used in this project:

 Display the number of matches conducted at each stadium with the stadium name and city.

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

 How many all-rounders are there in each team, Display the teams with more than 4 all-rounders 
 in descending order.

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

## Contributing
Contributions are welcome! Please open an issue or submit a pull request for any improvements or new features.



  
