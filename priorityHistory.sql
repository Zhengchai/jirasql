select to_char(changegroup.created, 'YYYY-MM-DD'),concat(project.pkey,'-',j.issuenum),j.assignee,concat(pold.pname,'->',pnew.pname)
from  jiraissue j,project,changeitem,changegroup,label l,priority pold,issuetype,priority pnew
where date(changegroup.created) between :'STARTDATE' and :'ENDDATE'  
and j.project=project.id and project.pkey in (:PROJECTS)
and l.issue=j.id and l.label in (:TEAM) 
and j.issuetype=issuetype.id and issuetype.pname='Bug'
and changeitem.field = 'priority' 
and changeitem.newvalue=pnew.id and pnew.pname in (:PRIORITY)
and changeitem.oldvalue=pold.id and pold.pname not in (:PRIORITY)
and changegroup.id=changeitem.groupid  and changegroup.issueid=j.id 

and j.id in (select SOURCE_NODE_ID from nodeassociation nain,projectversion pvin 
	where nain.ASSOCIATION_TYPE='IssueVersion' 
	and pvin.id=nain.SINK_NODE_ID 
	and pvin.vname=:'RELIN')
and j.id not in (select SOURCE_NODE_ID  from nodeassociation naout,projectversion pvout
	where naout.ASSOCIATION_TYPE='IssueFixVersion' 
	and pvout.id=naout.SINK_NODE_ID and pvout.vname=:'RELEXCL')

order by changegroup.created DESC;

