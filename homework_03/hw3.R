# -----------------------------------------------------------------------------
# --------------- Information & Data Systems - HW3 Sample Code ----------------
# -----------------------------------------------------------------------------

# access csv file
NHL_Data <- read.csv("game_plays.csv")
head(NHL_Data)

# use sql in R scripts (don't need to update every time)
#install.packages("sqldf")
#update.packages("sqldf")
library(sqldf)

# create table of all teams in dataset (no dupes)
TeamsTable <- sqldf("SELECT DISTINCT team_id_for FROM NHL_Data")
length(TeamsTable$team_id_for)

# counts distinct teams
TeamsTable <- sqldf("SELECT DISTINCT team_id_for FROM NHL_Data WHERE team_id_for <> 'NA'")
length(TeamsTable$team_id_for)

# counts them in a better way
Teams_Number <- sqldf("SELECT COUNT (DISTINCT team_id_against) AS TNum FROM NHL_Data")
print(Teams_Number$TNum)

# makes a table with game period team shots
ShotsTable <- sqldf("SELECT game_id, period, team_id_for, count(event) as Shots 
                     FROM NHL_Data WHERE event = 'Shot' AND periodType = 'REGULAR'
                     Group by game_id, period, team_id_for")

# finds average shots per period using SQL
Shots_Avg <- sqldf("SELECT AVG (shots) AS SNum FROM ShotsTable")
print(Shots_Avg$SNum)

# same for every team
Shots_Avg_by_Team <- sqldf("SELECT team_id_for, AVG(shots) ShotAvg 
                            FROM ShotsTable GROUP BY team_id_for")

# game period team shots_against
ShotsTableAgainst <- sqldf("SELECT game_id, period, team_id_against, count(event) as Shots 
                            FROM NHL_Data WHERE event = 'Shot' AND periodType = 'REGULAR'
                            Group by game_id, period, team_id_against")

# average shots against each team
Shots_Avg_by_Team_Against <- sqldf("SELECT team_id_against, AVG(shots) ShotAvg 
                                    FROM ShotsTableAgainst GROUP BY team_id_against")

# find the ratio of shots against/shots for per team per period
Shots_Ratio <- ShotsTableAgainst$Shots/ShotsTable$Shots

# average ratio
AvgShots_Ratio <- mean(Shots_Ratio)


# -----------------------------------------------------------------------------
# --------------- Information & Data Systems - HW3 Question 1 -----------------
# -----------------------------------------------------------------------------

# Part a: Find shots against/shots for ratio per team (totals, not by period)

# total shots FOR each team (across all games and periods)
Total_Shots_For <- sqldf("SELECT team_id_for, SUM(Shots) AS Total_Shots_For 
                          FROM ShotsTable 
                          GROUP BY team_id_for")

# total shots AGAINST each team (across all games and periods)
Total_Shots_Against <- sqldf("SELECT team_id_against, SUM(Shots) AS Total_Shots_Against 
                              FROM ShotsTableAgainst 
                              GROUP BY team_id_against")

# calculate ratio per team (shots against / shots for)
Shots_Ratio_Per_Team <- sqldf("SELECT 
                               a.team_id_against AS team_id,
                               a.Total_Shots_Against,
                               f.Total_Shots_For,
                               CAST(a.Total_Shots_Against AS FLOAT) / f.Total_Shots_For AS Ratio
                               FROM Total_Shots_Against AS a
                               JOIN Total_Shots_For AS f
                               ON a.team_id_against = f.team_id_for")

# Part b: Report the average ratio for all teams
Avg_Ratio_All_Teams <- mean(Shots_Ratio_Per_Team$Ratio)
print(Avg_Ratio_All_Teams)


# -----------------------------------------------------------------------------
# --------------- Information & Data Systems - HW3 Question 2 -----------------
# -----------------------------------------------------------------------------

# Part a: Construct tables with average missed shots per team per period

# missed shots FOR each team per period
MissedShotsTableFor <- sqldf("SELECT game_id, period, team_id_for, COUNT(event) AS MissedShots 
                           FROM NHL_Data 
                           WHERE event = 'Missed Shot' AND periodType = 'REGULAR'
                           GROUP BY game_id, period, team_id_for")

# average missed shots FOR each team per period
MissedShots_Avg_by_Team_For <- sqldf("SELECT team_id_for, AVG(MissedShots) AS MissedShotAvg 
                                  FROM MissedShotsTable 
                                  GROUP BY team_id_for")

# missed shots AGAINST each team per period
MissedShotsTableAgainst <- sqldf("SELECT game_id, period, team_id_against, COUNT(event) AS MissedShots 
                                  FROM NHL_Data 
                                  WHERE event = 'Missed Shot' AND periodType = 'REGULAR'
                                  GROUP BY game_id, period, team_id_against")

# average missed shots AGAINST each team per period
MissedShots_Avg_by_Team_Against <- sqldf("SELECT team_id_against, AVG(MissedShots) AS MissedShotAvg 
                                          FROM MissedShotsTableAgainst 
                                          GROUP BY team_id_against")

# Part b: Construct table with average ratio of missed/on target for each team per period

# using the existing ShotsTable (on target shots) and new MissedShotsTable
Missed_OnTarget_Ratio <- sqldf("SELECT 
                                m.team_id_for AS team_id,
                                AVG(CAST(m.MissedShots AS FLOAT) / s.Shots) AS Avg_Ratio
                                FROM MissedShotsTable AS m
                                JOIN ShotsTable AS s
                                ON m.game_id = s.game_id 
                                AND m.period = s.period 
                                AND m.team_id_for = s.team_id_for
                                GROUP BY m.team_id_for")

# report the average ratio (average of the resulting table)
Overall_Avg_Ratio <- mean(Missed_OnTarget_Ratio$Avg_Ratio)
print(Overall_Avg_Ratio)


# -----------------------------------------------------------------------------
# --------------- Information & Data Systems - HW3 Question 3 -----------------
# -----------------------------------------------------------------------------

# Part a: Construct tables containing total goals for and against each team

# total goals FOR each team (across all periods)
Goals_For_Table <- sqldf("SELECT team_id_for, COUNT(event) AS Total_Goals_For 
                          FROM NHL_Data 
                          WHERE event = 'Goal'
                          GROUP BY team_id_for")

# total goals AGAINST each team (across all periods)
Goals_Against_Table <- sqldf("SELECT team_id_against, COUNT(event) AS Total_Goals_Against 
                              FROM NHL_Data 
                              WHERE event = 'Goal'
                              GROUP BY team_id_against")

# Part b: Find goal differences for each team (for - against)

# join the two tables and calculate goal difference
Goal_Differences <- sqldf("SELECT 
                           f.team_id_for AS team_id,
                           f.Total_Goals_For,
                           a.Total_Goals_Against,
                           (f.Total_Goals_For - a.Total_Goals_Against) AS Goal_Difference
                           FROM Goals_For_Table AS f
                           JOIN Goals_Against_Table AS a
                           ON f.team_id_for = a.team_id_against")

# total number of goals for each team using R function sum(vector)
Total_Goals <- Goals_For_Table$Total_Goals_For
print(Total_Goals)

# calculate average goal difference
Avg_Goal_Difference <- mean(Goal_Differences$Goal_Difference)
print(Avg_Goal_Difference)

# make a smaller file for game_plays.csv
NHL_Sample <- read.csv('game_plays.csv', nrows = 10000)
write.csv(NHL_Sample, "game_plays_sample.csv", row.names = FALSE)

