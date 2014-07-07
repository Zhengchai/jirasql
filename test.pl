#!/usr/bin/perl
# Input 
# STDIN
#	a csv file in YYYYmm,Issue,... format
# STDOUT
# 	STDIN, with duplicate Issues and Issues not appearing in the Inflow removed
#
$file=shift  @ARGV;
#grep the CAs
@inflow= `grep -Eo CA-[0-9]+ $file`;
chomp @inflow;
print 'inflow.csv:',join(',',@inflow),"\n";


exit 0;

