#!/usr/bin/perl
#Param:  file containing list of CAs as inflow
#Input 
# STDIN
#	a csv file in YYYYmm,Issue,... format, containing a list of CAs for a team
# STDOUT
# 	STDIN, with issues filtered as per the lifecycle definition (see doc)
#
# simplified life cycle for CA defects
# Modelled as a Mealey State Machine http://en.wikipedia.org/wiki/Mealy_machine
#
#	   \states
#events \ U(ndef)| BC	 | M(ajor)| C(losed)| 
#--------------------------------------------------------
#	C+	| BC/M, e| BC,nop| M, nop | BC/M,e|
#	V+	| BC/M, e| BC,nop| M, nop | BC/M,e|
#	T+	| BC/M, e| BC,nop| M, nop | BC/M,e|
#	P+	| BC/M, e| M,e	 | M, nop | BC/M,e|
#	O+	| BC/M, e| BC,nop| M, nop | BC/M,e|
#	R- 	| C, e   | BC,nop| M, nop | C, w  |
#	V- 	| C, e   | BC,nop| M, nop | C, w  |
#	T- 	| C, e   | BC,nop| M, nop | C, w  |
#	P- 	| C, e   | BC,nop| BC, e  | C, w  |
# BC/M= move to BC (Blocker/Critical) or Major state depending on priority
# id= stays in same state
# w(arn)= transition shouldn't happen, log on STDERR
# e(mit)= output the input line
# nop=do nothing
@statesTag=qw(U BC M C);
@transTag=qw(C+ V+ T+ P+ O+ R- V- T- P-);
@hash= map{$i=$_;map{$i.$_}@statesTag}@transTag;
#print join("\n",@hash);
my %states;
@states{@hash} = qw(
BC/M	BC	M	BC/M
BC/M	BC	M	BC/M
BC/M	BC	M	BC/M
BC/M	M 	M	BC/M
BC/M	BC	M	BC/M
C		BC	M	C
C		BC	M	C
C		BC	M	C
C		BC	BC	C
);
#foreach(@hash){print "$_ => $states{$_}\n";};
my %actions;
@actions{@hash} = qw(
e	nop	nop	e
e	nop	nop	e
e	nop	nop	e
e	e	nop	e
e	nop	nop	e
e	nop	nop	w
e	nop	nop	w
e	nop	nop	w
e	nop	e	w
);
#foreach(@hash){print "$_ => $actions{$_}\n";};exit 0;
my %CAs; # keeps state of each CAs, indexed id
my %history; # keeps transition history for CAs
my %output;
@priorities=qw(Blocker Critical Major);
@priorityMap{@priorities}=qw(BC BC M);
$debug=0;
#Read input
while(<>){
	$line=$_;
	($date,$wk,$trans,$id,$pri)=split(/,/);
#Assert some proprieties
	grep(/$trans/,@transTag) or die "ABORT: Incorrect categorie: $trans, at line\n",$line;
	grep(/$pri/,qw(Blocker Critical Major Minor Trivial)) or die "ABORT: Incorrect priority: $pri, at line\n",$line;
#Check current state
	$state='U';
	exists $CAs{$id} and $state=$CAs{$id};
#fetch next state & next action
	exists $states{$trans.$state} or die "ABORT: empty state:for $trans,$state, at line\n",$line;
	$nextState=$states{$trans.$state};
	exists $actions{$trans.$state} or die "ABORT: empty action:for $trans,$state, at line\n",$line;
	$nextAction=$actions{$trans.$state};
#debug
	$x="DEBUG: ($state,$trans)->$nextState, action:$nextAction at $line";
	$debug and warn $x;
	$history{$id}.=$x;
#Set new state (special case for 1st time
	if($nextState eq 'BC/M'){
		exists $priorityMap{$pri} or die "ABORT: Inconsistent priority: >$pri<, at line:\n$line";
		$nextState=$priorityMap{$pri};
	}
	if($nextState ne 'U')
		{$CAs{$id}=$nextState;}
#execute action
	if   ($nextAction eq 'e')
		{print $line;}
	elsif($nextAction eq 'w')
		{warn "WARNING:transition: ($state,$trans)->$nextState, action:$nextAction at line:$line"}
	elsif($nextAction eq 'nop')
		{}
	else
		{die "ABORT: Inconsistent State\n"}
}
exit 0;



	

