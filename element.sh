#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
  exit 0
fi

# Escape single quotes in user input for SQL string literals
INPUT_ESC="${1//\'/\'\'}"

if [[ $1 =~ ^[0-9]+$ ]]; then
  RESULT=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass::text, melting_point_celsius, boiling_point_celsius FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE atomic_number = $1")
else
  RESULT=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass::text, melting_point_celsius, boiling_point_celsius FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE symbol ILIKE '$INPUT_ESC' OR name ILIKE '$INPUT_ESC'")
fi

RESULT=$(echo "$RESULT" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

if [[ -z $RESULT ]]; then
  echo "I could not find that element in the database."
  exit 0
fi

IFS='|' read -r ATOMIC_NUMBER NAME SYMBOL TYPE ATOMIC_MASS MP BP <<< "$RESULT"

# Normalize numeric text so values like 1.008000 print as 1.008 (matches course examples)
ATOMIC_MASS=$(awk -v n="$ATOMIC_MASS" 'BEGIN { printf "%g", n+0 }')

echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MP celsius and a boiling point of $BP celsius."
