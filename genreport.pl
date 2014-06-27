#!/usr/bin/perl
#
# Generates reports for all teams
@wk = ('17','18','19','20','21','22','23','24','25','26');
@wkStart=('2014-04-21','2014-04-28','2014-05-05','2014-05-12','2014-05-19','2014-05-26','2014-06-02','2014-06-09','2014-06-16','2014-06-23');
@wkEnd=  ('2014-04-27','2014-05-04','2014-05-11','2014-05-18','2014-05-25','2014-06-01','2014-06-08','2014-06-15','2014-06-22','2014-06-26');
@teams = ('xs-ring3','xs-ring0','xs-storage','xs-gui','xs-perf','xs-windows');
@start{@wk} = @wkStart;
@end{@wk} = @wkEnd;
foreach (@wk){
	$wk=$_;
	foreach(@teams){
		$team=$_;
			`make wk=$wk team=$team priority='Blocker,Critical' priorityDemote='Major,Minor,Trivial' startdate=$start{$wk} enddate=$end{$wk}`;
			`make wk=$wk team=$team priority='Major' priorityDemote='Minor,Trivial' startdate=$start{$wk} enddate=$end{$wk}`;
}}
exit 0;

