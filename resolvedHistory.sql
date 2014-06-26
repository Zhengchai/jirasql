select to_char(j.resolutiondate, 'YYYY-MM-DD'),concat(project.pkey,'-',j.issuenum),priority.pname,j.assignee,resolution.pname
from  jiraissue j,project,priority,label l,resolution
where date(j.resolutiondate) between :'STARTDATE' and :'ENDDATE'  
and j.project=project.id and project.pkey in (:PROJECTS)
and j.priority=priority.id and priority.pname in (:PRIORITY)
and l.issue=j.id and l.label in (:TEAM) 
and j.resolution=resolution.id

and j.id in (select SOURCE_NODE_ID from nodeassociation nain,projectversion pvin 
	where nain.ASSOCIATION_TYPE='IssueVersion' 
	and pvin.id=nain.SINK_NODE_ID 
	and pvin.vname=:'RELIN')
and j.id not in (select SOURCE_NODE_ID  from nodeassociation naout,projectversion pvout
	where naout.ASSOCIATION_TYPE='IssueFixVersion' 
	and pvout.id=naout.SINK_NODE_ID and pvout.vname=:'RELEXCL')

order by j.created DESC;
