#!/usr/bin/perl
#
# Generates reports for all teams
@teams = ('xs-ring0','xs-ring3','xs-storage','xs-gui','xs-perf','xs-windows');
@start{@wk} = @wkStart;
@end{@wk} = @wkEnd;
foreach(@teams){
	$team=$_;
	`make wk=$wk team=$team priority='Blocker,Critical' priorityDemote='Major,Minor,Trivial'`;
	`make wk=$wk team=$team priority='Major' priorityDemote='Minor,Trivial'`;
}
exit 0;

