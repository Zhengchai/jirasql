select to_char(j.created, 'YYYY-MM-DD'),concat(project.pkey,'-',j.issuenum),priority.pname,j.assignee
from  jiraissue j,project,priority
where date(j.created) between :'STARTDATE' and :'ENDDATE'  
and j.project=project.id and project.pkey in (:PROJECTS)
and j.priority=priority.id and priority.pname in (:PRIORITY)
and j.id in (select label.issue from label where label.label in (:TEAM))
and j.id in (select nain.SOURCE_NODE_ID from nodeassociation nain,projectversion pvin 
	where nain.ASSOCIATION_TYPE='IssueVersion'
	and pvin.id=nain.SINK_NODE_ID and pvin.vname=:'RELIN')
order by j.created DESC;

