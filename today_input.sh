#!/usr/bin/env bash

today=$(date +%Y:%-d)

year=$(echo "${today}" | cut -f1 -d:)
day=$(echo "${today}" | cut -f2 -d:)

#echo "year:${year} day:${day}"

curl -s -H "Cookie: $(cat ~/.aoc)" https://adventofcode.com/${year}/day/${day}/input | tee input
