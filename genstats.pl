#!/usr/bin/perl
@wk = ('16','17','18','19','20','21','22','23','24','25','26');
@teams = ('xs-ring3');
#@teams = ('xs-ring3','xs-ring0','xs-storage','xs-gui','xs-perf','xs-windows');
@pri = ('Blocker,Critical','Major');
@dir = ('inflow','outflow');
#parse the totals
foreach (@dir){
	$dir=$_;
	foreach(@teams){
		$team=$_;
		foreach(@wk){
			$wk=$_;
			foreach(@pri){
				$pri=$_;
#grep the CAs
				$item="$dir.$team.wk$wk.$pri";
				@x= `grep -Eo CA-[0-9]+ $item.csv`;
#Check if we've seen already seen them to avoid double accounting
#Now turned off, as it introduces too much variations with actuals
				foreach(@x){
#					if($seen{$_.$dir.$team.$pri}){
#						#print "$item Seen: $_";
#						next;
#					} 
#					$seen{$_.$dir.$team.$pri}=1;
					$total{$item}+=1;
				}
}}}}
#generate the csv
foreach(@teams){
	$team=$_;
	print "#####################$_###########################\n";
	foreach(@pri){
		$pri=$_;
#Compute the Inflow and Outflow
		@inflow=();
		@outflow=();
		map{$item="inflow.$team.wk$_.$pri";push(@inflow,$total{$item});}@wk;
		map{$item="outflow.$team.wk$_.$pri";push(@outflow,$total{$item});}@wk;
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

