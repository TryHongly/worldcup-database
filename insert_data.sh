#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
# start from a clean slate so the script can be rerun
echo $($PSQL "TRUNCATE TABLE games, teams RESTART IDENTITY")

# read each line of the CSV, splitting on commas
tail -n +2 games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # insert both teams; ON CONFLICT skips any name that already exists
  $PSQL "INSERT INTO teams(name) VALUES('$WINNER') ON CONFLICT(name) DO NOTHING" > /dev/null
  $PSQL "INSERT INTO teams(name) VALUES('$OPPONENT') ON CONFLICT(name) DO NOTHING" > /dev/null

  # insert the game, looking up both team IDs inside the query
  $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals)
         VALUES($YEAR, '$ROUND',
                (SELECT team_id FROM teams WHERE name='$WINNER'),
                (SELECT team_id FROM teams WHERE name='$OPPONENT'),
                $WINNER_GOALS, $OPPONENT_GOALS)" > /dev/null
done
