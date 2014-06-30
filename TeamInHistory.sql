select to_char(changegroup.created, 'YYYY-MM-DD'),to_char(j.created, 'YY"wk"WW'),:'LOG',concat(project.pkey,'-',j.issuenum),priority.pname,j.assignee,concat(changeitem.oldstring,'->',changeitem.newstring)
from  jiraissue j,project,changeitem,changegroup,priority,issuetype
where j.project=project.id and project.pkey in (:PROJECTS)
and j.priority=priority.id and priority.pname in (:PRIORITY)
and j.issuetype=issuetype.id and issuetype.pname='Bug'
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

order by changegroup.created DESC;

