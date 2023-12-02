#!/usr/bin/env bash

today=$(date +%Y:%-d)

todayYear=$(echo "${today}" | cut -f1 -d:)
todayDay=$(echo "${today}" | cut -f2 -d:)

year="${year:-$todayYear}"
day="${day:-$todayDay}"

#echo "year:${year} day:${day}"

curl -s -H "Cookie: $(cat ~/.aoc)" https://adventofcode.com/${year}/day/${day}/input | tee input
