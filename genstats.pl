#!/usr/bin/perl
$startwk='14wk16';
$endwk='14wk26';
@wk = qw(14wk16 14wk17 14wk18 14wk19 14wk20 14wk21 14wk22 14wk23 14wk24 14wk25 14wk26);
#By team
@teams = qw(xs-ring0 xs-ring3 xs-storage xs-gui xs-perf xs-windows);
#For all teams
push(@teams,'xs-ring0,xs-ring3,xs-storage,xs-gui,xs-perf,xs-windows');
@pri = ('Blocker,Critical','Major');
@dir = ('inflow','outflow');
#parse the totals
foreach (@dir){
	$dir=$_;
	foreach(@teams){
		$team=$_;
			foreach(@pri){
				$pri=$_;
				$file="$dir.$team.$pri.csv";
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
				$item="$dir.$team.$wk.$pri";
					$total{$item}+=1;
				}
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
#Compute the Inflow and Outflow
		@inflow=();
		@outflow=();
		map{$item="inflow.$team.$_.$pri";push(@inflow,$total{$item});}@wk;
		map{$item="outflow.$team.$_.$pri";push(@outflow,$total{$item});}@wk;
#Compute the Cumulative total
		@cumul=();
		$cumul[0]=$inflow[0];
		for $i (1 .. scalar @inflow-1){
			$cumul[$i]=$cumul[$i-1]+$inflow[$i];
		}
#Compute the Unresolved at end of week
		@unresEnd=();
		$unresEnd[0]=$inflow[0]-$outflow[0];
		for $i (1 .. scalar @inflow-1){
			$unresEnd[$i]=$unresEnd[$i-1]+$inflow[$i]-$outflow[$i];
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

