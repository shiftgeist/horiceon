#!/usr/bin/env bash

# click action for bar-check-timetrack

DATE_TODAY=$(date +"%F")
TT_DIR="$HOME/zeiterfassung"
TT_FILE="$TT_DIR/$DATE_TODAY.csv"

# create file if not exist
if [ ! -f "$TT_FILE" ]; then
  echo "Datum;Kunde;Projekt;Bemerkungen;Arbeitsstunden" >>"$TT_FILE"
  echo "$DATE_TODAY;;Zeiterfassung;;0.25" >>"$TT_FILE"
fi

# insert new line
echo "$DATE_TODAY;;;;1" >>"$TT_FILE"

LINES=$(wc -l "$TT_FILE" | awk '{ print $1 }')

# open file
code --goto "$TT_FILE:$LINES:13"
