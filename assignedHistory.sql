select to_char(changegroup.created, 'YYYY-MM-DD'),concat(project.pkey,'-',jiraissue.issuenum),priority.pname,concat(changeitem.oldvalue,'->',changeitem.newvalue)
from  jiraissue,project,changeitem,changegroup,priority
where date(changegroup.created) between :'STARTDATE' and :'ENDDATE'  
and changeitem.field = 'assignee' 
and changeitem.newvalue in (:NAMES)
and changeitem.oldvalue not in (:NAMES)
and changegroup.id=changeitem.groupid 
and changegroup.issueid=jiraissue.id 
and jiraissue.project=project.id 
and project.pkey in (:PROJECTS)
and jiraissue.priority=priority.id
and priority.pname in (:PRIORITY)
order by changegroup.created ASC;

