#!/usr/bin/perl
# Input 
# STDIN
#	a csv file in YYYYmm,Issue,... format
# STDOUT
# 	STDIN, with duplicate Issues removed
#
while(<>){
	$line=$_;
	($date,$issue)=split(/,/);
#ignore comment lines and skip duplicates
	if($issue eq '' or not $seen{$issue})
		{print $line;}
	$seen{$issue}=1;
}

