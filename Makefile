#!/usr/bin/make -f
# philippeg jun2014
# Generate csv files
# with persons who were assigned or commented on jira tickets, between a set of dates
# using the jira SQL interface, see: https://developer.atlassian.com/display/JIRADEV/Database+Schema 
#
.PHONY: login clean reallyclean test dotar test

##########################customise this section###############################################
#jira projects, e.g. CA, CP, SCTX... 
projects=CA
team=xs-ring0,xs-ring3,xs-storage,xs-gui,xs-perf,xs-windows
IssueVersion=Creedence
FixVersion=Creedence Outgoing
#priority=Blocker,Critical
#priorityDemote=Major,Minor,Trivial
priority=Major
priorityDemote=Minor,Trivial
########################end of custom section##################################################
#jira server params, read from .config file
host=$(lastword $(shell grep 'host' .config))
dbname=$(lastword $(shell grep 'dbname' .config))
username=$(lastword $(shell grep 'username' .config))
password=$(lastword $(shell grep 'password' .config))
#autogenerated name
suffix=$(team).$(priority)
qw=$(shell echo $(1) | sed "s/\([^,]*\)/'\1'/g")
priorityPsqlFormat=$(call qw,$(priority))
priorityDemotePsqlFormat=$(call qw,$(priorityDemote))
projectsPsqlFormat=$(call qw,$(projects))
teamsPsqlFormat=$(call qw,$(team))
#csv targets
inflowCSV=createdHistory.$(suffix).csv IssueAffectVersionHistory.$(suffix).csv promotePriorityHistory.$(suffix).csv reopenedHistory.$(suffix).csv
outflowCSV=resolvedHistory.$(suffix).csv IssueFixVersionHistory.$(suffix).csv demotePriorityHistory.$(suffix).csv 
inflowreport=inflow.$(suffix).csv
outflowreport=outflow.$(suffix).csv
report=report.$(suffix).csv
#psql query
setJiraPass=export PGPASSWORD=$(password)
ConnectToJira=psql --host=$(host) --dbname=$(dbname) --username=$(username)
params=--field-separator="," --no-align --tuples-only 
params+= --variable=TEAM="$(teamsPsqlFormat)" --variable=PROJECTS="$(projectsPsqlFormat)"
params+= --variable=RELIN="$(IssueVersion)" --variable=RELEXCL="$(FixVersion)"
###############################################################################################
all: $(inflowCSV) $(outflowCSV) $(inflowreport) $(outflowreport) $(report)
#all: test
$(inflowreport): $(inflowCSV)
	cat $(inflowCSV)	> /tmp/tmpinflow.csv
	sort -r /tmp/tmpinflow.csv | ./rmdupIn.pl	>  $@
$(outflowreport): $(outflowCSV) $(inflowreport)
	cat $(outflowCSV)	> /tmp/tmpoutflow.csv
	sort -r /tmp/tmpoutflow.csv | ./rmdupOut.pl $(inflowreport) >  $@
$(report): $(inflowreport) $(outflowreport)
	@echo 'Generating report...'
	@echo 'Team: $(team)'							| tee -a  $@
	@echo 'Release: $(IssueVersion)'				| tee -a  $@
	@echo 'Priority: $(priority)'					| tee -a  $@
	@echo 											| tee -a  $@
	@echo 'C+ Created                    R- Issue Resolved'			| tee -a  $@
	@echo 'V+ Version set to project     V- Issue set to outgoing'	| tee -a  $@
	@echo 'P+ Priority promoted          P- Priority demoted'		| tee -a  $@
	@echo 'T+ Team affected              T- Team not affected'		| tee -a  $@
	@echo 'O+ Issue Reopened'						| tee -a  $@
	@echo 											| tee -a  $@
	@cat $(inflowreport) $(outflowreport) | sort -r | tee -a  $@
	
login:
	$(setJiraPass) ; $(ConnectToJira)
clean: 
	rm -f report.*.csv inflow.*.csv outflow.*.csv
reallyclean:
	rm -f *.csv
createdHistory.$(suffix).csv: createdHistory.sql
	$(setJiraPass) ; $(ConnectToJira) $(params) \
	--variable=PRIORITY="$(priorityPsqlFormat)" \
	--variable=LOG="C+" \
	-f $< | uniq | tee   $@
resolvedHistory.$(suffix).csv: resolvedHistory.sql
	$(setJiraPass) ; $(ConnectToJira) $(params) \
	--variable=PRIORITY="$(priorityPsqlFormat)" \
	--variable=LOG="R-" \
	-f $< | uniq | tee   $@
IssueFixVersionHistory.$(suffix).csv: IssueFixVersionHistory.sql
	$(setJiraPass) ; $(ConnectToJira) $(params) \
	--variable=PRIORITY="$(priorityPsqlFormat)" \
	--variable=LOG="V-" \
	-f $< | uniq | tee   $@
IssueAffectVersionHistory.$(suffix).csv: IssueAffectVersionHistory.sql
	$(setJiraPass) ; $(ConnectToJira) $(params) \
	--variable=PRIORITY="$(priorityPsqlFormat)" \
	--variable=LOG="V+" \
	-f $< | uniq | tee   $@
promotePriorityHistory.$(suffix).csv: priorityHistory.sql
	$(setJiraPass) ; $(ConnectToJira) $(params) \
	--variable=PRIORITY="$(priorityPsqlFormat)" \
	--variable=LOG="P+" \
	-f $< | uniq | tee   $@
demotePriorityHistory.$(suffix).csv: priorityHistory.sql
	$(setJiraPass) ; $(ConnectToJira) $(params) \
	--variable=PRIORITY="$(priorityDemotePsqlFormat)" \
	--variable=LOG="P-" \
	-f $< | uniq | tee   $@
reopenedHistory.$(suffix).csv: statusHistory.sql
	$(setJiraPass) ; $(ConnectToJira) $(params) \
	--variable=PRIORITY="$(priorityPsqlFormat)" \
	--variable=STATUS="'Resolved','Closed'" \
	--variable=LOG="O+" \
	-f $< | uniq | tee   $@
test:
	@echo $(params)

