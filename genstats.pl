#!/usr/bin/perl
$startwk='14wk16';
$endwk='14wk26';
@wk = qw(14wk16 14wk17 14wk18 14wk19 14wk20 14wk21 14wk22 14wk23 14wk24 14wk25 14wk26);
#By team
@teams = qw(xs-ring0 xs-ring3 xs-storage xs-gui xs-perf xs-windows);
#For all teams
push(@teams,'xs-ring0,xs-ring3,xs-storage,xs-gui,xs-perf,xs-windows');
@pri =('Blocker,Critical','Major');
@inflowCat=qw(C+ V+ P+ O+);
@outflowCat=qw(R- V- P-);
@cat=(@inflow,@outflow);

#parse the totals
foreach (@teams){
	$team=$_;
	foreach(@pri){
		$pri=$_;
			$file="report.$team.$pri.csv";
#grep the CAs
			-e $file or die "ABORT: $file NOT FOUND!\n";
			@CAs= `grep -E CA-[0-9]+ $file`;
#print "$file:",join(',',@CAs),"\n";
#Iterate through CAs
			foreach(@CAs){
			($date,$wk,$cat,$issue)=split(/,/);
#print "$date,$wk,$cat,$issue\n";
#Normalise wk number
#Anything that happened before $startwk is accounted to that $startweek
			if($wk lt $startwk)
				{$wk = $startwk;}
			$total{$team,$wk,$cat,$pri}+=1;
}}}
#print "$_->$total{$_}\n" for (keys %total);exit 0;
#generate the csv
foreach(@teams){
	$team = $_;
	$ppteam = $team;
	$ppteam =~ s/,/ & /g; # pretty print team(s)
	print '____'.$ppteam.'____'; print ',______' x scalar @wk; print "\n";
	foreach(@pri){
		$pri=$_;
#initialise arrays
		@outflow=();@inflow=();@cumul=();@unresEnd=();
		$cumul=0;$unres=0;
		foreach(@wk){
			$wk=$_;
#Compute the Outflow
			$outflow=0;
			map{$outflow+=$total{$team,$wk,$_,$pri}}@outflowCat;
			push(@outflow,$outflow);
#Compute the Inflow, cumulative inflow, Unresolved per week
			$inflow=0;
			map{$inflow+=$total{$team,$wk,$_,$pri}}@inflowCat;
			$cumul+=$inflow;
			$unres+=$inflow-$outflow;
			push(@inflow,$inflow);
			push(@cumul,$cumul);
			push(@unresEnd,$unres);
		}
#Compute the Unresolved at start of week
		@unresStart=@unresEnd;
		pop(@unresStart);
		unshift(@unresStart,0);
#Output the csv data
		$pri =~ s/,/ & /g; # pretty print priority
		print "Priority: $pri\n";
		print "wk number";
		map{print ",$_";}@wk;
		print "\n";
		print 'Unresolved (start of week),',join(',',@unresStart),"\n";
		print 'Inflow,',join(',',@inflow),"\n";
		print 'Outflow,',join(',',@outflow),"\n";
		print 'Unresolved (end of week),',join(',',@unresEnd),"\n";
		print 'Cumulative defects raised,',join(',',@cumul),"\n";
		print "\n";

	}
}
exit 0;

