#!/usr/bin/perl
#@x= `grep -Eo CA-[0-9]+ report.xs-ring3.wk18.Blocker,Critical.csv`;
#print scalar @x,"\n";
#exit 0;

#!/usr/bin/perl
@wk = ('17','18','19','20','21','22','23','24','25','26');
@teams = ('xs-ring0');
#@teams = ('xs-ring3');
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
#Check if we've seen already seen them
				foreach(@x){
					if($seen{$_.$dir.$team.$pri})
						{print "$item Seen: $_";next;} 
					$seen{$_.$dir.$team.$pri}=1;
					$total{$item}+=1;
				}
}}}}


exit 0;
