#!/bin/bash
#
# Exec SQL queries for each teams
#
teams="xs-ring0 xs-ring3 xs-storage xs-gui xs-perf xs-windows"
for team in $teams
do
	make team=$team
done
#
# Exec global SQL query
#
team='xs-ring0,xs-ring3,xs-storage,xs-gui,xs-perf,xs-windows'
	make team=$team priority='Blocker,Critical' priorityDemote='Major,Minor,Trivial'
	make team=$team priority='Major' priorityDemote='Minor,Trivial'
#
#Generate stats
#
./genstats.pl > report.csv
exit 0


