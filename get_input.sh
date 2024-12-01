#!/bin/bash

printf -v lday "%02d" $2
sday=$((10#$lday))
uri="https://adventofcode.com/${1}/day/${sday}/input"
input_filename="inputs/${1}/${lday}.txt"
cookie="Cookie: ${AOC_SESSION}"

if [ ! -f "$input_filename" ]; then
  echo "fetching input for year${1}/day${lday}"
  curl "$uri" -X GET -H "${cookie}" > $input_filename
fi
