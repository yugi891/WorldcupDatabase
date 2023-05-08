#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
# 删除数据库中两个表格的全部数据
echo $($PSQL "TRUNCATE games, teams")
WINNER_ID=null
OPPONENT_ID=null
# 读取games.csv的数据,并按逗号为分割符读取各个变量
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # 去除第一行的说明数据
  if [[ $YEAR != "year" ]]
  then
    # 查看数据库是否有获胜队的ID
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
    # 查找不到获胜队的ID
    if [[ -z $TEAM_ID ]]
    then
      # 插入新行
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
      then
        # 重新获取team_id并赋值给winner_id
        WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
      fi
    # 能查找到，则把队伍ID赋值给winner_id
    else
      WINNER_ID=$TEAM_ID
    fi
    # 查看数据库是否有落败队的ID
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
    # 查找不到落败队的ID
    if [[ -z $TEAM_ID ]]
    then
      #插入新行
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
      then
        # 获取落败队的ID
        OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
      fi
    #能查找到落败队伍的ID
    else
      OPPONENT_ID=$TEAM_ID
    fi
    # 插入games表格的新行
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
  fi
done