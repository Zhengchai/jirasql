select to_char(changegroup.created, 'YYYY-MM-DD'),concat(project.pkey,'-',j.issuenum),priority.pname,concat(changeitem.oldstring,'->',changeitem.newstring)
from  jiraissue j,project,changeitem,changegroup,priority
where date(changegroup.created) between :'STARTDATE' and :'ENDDATE'  
and j.project=project.id and project.pkey in (:PROJECTS)
and j.priority=priority.id and priority.pname in (:PRIORITY)
and changeitem.field = 'Teams' 
and position((:TEAM) in changeitem.newstring) != 0
and position((:TEAM) in changeitem.oldstring) =0
and changegroup.id=changeitem.groupid 
and changegroup.issueid=j.id 

and j.id in (select SOURCE_NODE_ID from nodeassociation nain,projectversion pvin 
	where nain.ASSOCIATION_TYPE='IssueVersion' 
	and pvin.id=nain.SINK_NODE_ID 
	and pvin.vname=:'RELIN')
and j.id not in (select SOURCE_NODE_ID  from nodeassociation naout,projectversion pvout
	where naout.ASSOCIATION_TYPE='IssueFixVersion' 
	and pvout.id=naout.SINK_NODE_ID and pvout.vname=:'RELEXCL')

order by changegroup.created ASC;

