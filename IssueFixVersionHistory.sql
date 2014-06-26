select to_char(changegroup.created, 'YYYY-MM-DD'),concat(project.pkey,'-',j.issuenum),priority.pname,j.assignee,changeitem.newstring
from  jiraissue j,project,changeitem,changegroup,priority,label l
where date(changegroup.created) between :'STARTDATE' and :'ENDDATE'  
and j.project=project.id and project.pkey in (:PROJECTS)
and j.priority=priority.id and priority.pname in (:PRIORITY)
and l.issue=j.id and l.label in (:TEAM) 
and changeitem.field = 'Fix Version' and changeitem.newstring=:'FIXVERSION'
and changegroup.id=changeitem.groupid and changegroup.issueid=j.id 
order by changegroup.created ASC;
