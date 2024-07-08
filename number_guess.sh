#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\n~~~~~ Number Guessing Game ~~~~~\n"

  echo "Enter your username:" 
  read USERNAME

  USERNAME_CHECK=$($PSQL "select username from users where username='$USERNAME'")
  if [[ -z $USERNAME_CHECK ]]
  then
    USERNAME_INSERT=$($PSQL "insert into users(username) values('$USERNAME')")
    echo "Welcome, $USERNAME! It looks like this is your first time here."
  else
    OLD_BEST=$(echo $($PSQL "select best_game from users where username='$USERNAME'")| sed -r 's/^ *| *$//g')
    OLD_PLAYED=$(echo $($PSQL "select games_played from users where username='$USERNAME'")| sed -r 's/^ *| *$//g')

    echo "Welcome back, $USERNAME! You have played $OLD_PLAYED games, and your best game took $OLD_BEST guesses."
  fi
  
  SECRET=$(( RANDOM % 1000 + 1 ))

  echo "Guess the secret number between 1 and 1000:"
  read GUESS

  GUESSES=1

  while [[ $GUESS != $SECRET ]]
  do
    (( GUESSES+=1 ))
    if [[ ! $GUESS =~ ^[0-9]+$ ]] 
    then
      echo "That is not an integer, guess again:"
      read GUESS
    elif [[ $GUESS < $SECRET ]]
    then
      echo "It's higher than that, guess again:"
      read GUESS
    else
      echo "It's lower than that, guess again:"
      read GUESS
    fi
  done

  echo "You guessed it in $GUESSES tries. The secret number was $SECRET. Nice job!"
  
UPDATE_PLAYED=$($PSQL "update users set games_played=$OLD_PLAYED+1 where username='$USERNAME'")

if [[ -z $OLD_BEST ]] || [[ $OLD_BEST > $GUESSES ]]
then
  UPDATE_BEST=$($PSQL "update users set best_game=$GUESSES where username='$USERNAME'")
fi
