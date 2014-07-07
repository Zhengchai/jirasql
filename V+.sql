select to_char(changegroup.created, 'YYYY-MM-DD","YY"wk"IW'),:'LOG',concat(project.pkey,'-',j.issuenum),priority.pname,j.assignee,changeitem.newstring
from  jiraissue j,project,changeitem,changegroup,priority,issuetype,label l
where j.project=project.id and project.pkey in (:PROJECTS)
and j.priority=priority.id
and j.issuetype=issuetype.id and issuetype.pname='Bug'
and l.issue=j.id and l.label in (:TEAM) 
and changeitem.field = 'Version' and changeitem.newstring=:'RELIN'
and changegroup.id=changeitem.groupid and changegroup.issueid=j.id 
order by changegroup.created DESC;

