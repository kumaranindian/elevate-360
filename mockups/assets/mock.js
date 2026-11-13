// Renders sidebar + topbar around <main class="content"> based on <body data-role data-page data-title>
(function(){
var NAV={
employee:{t:'Employee',u:['Priya Sharma','Software Engineer'],i:[['Dashboard','dashboard'],['My Goals','goals'],['Self-Assessment','self-assessment'],['My Review','review-result'],['Feedback','feedback'],['Skills','skills'],['Notifications','notifications'],['Profile','profile'],['Payslips','payroll/payslip'],['Apply Leave','attendance_leave/leave-apply']]},
manager:{t:'Manager',u:['Rahul Mehta','Engineering Manager'],i:[['Dashboard','dashboard'],['My Team','team'],['Team Goals','goals'],['Reviews','review'],['Feedback','feedback'],['Reports','reports'],['Notifications','notifications'],['Leave Approvals','attendance_leave/leave-approvals'],['Bonus Proposals','payroll/bonus']]},
hr_admin:{t:'HR Admin',u:['Anita Rao','HR Administrator'],i:[['Dashboard','dashboard'],['Review Cycles','review-cycles'],['Employees','employees'],['Org & Master Data','org-master-data'],['Calibration','calibration'],['Reports','reports'],['Recruiting','recruiting/pipeline'],['Payroll','payroll/payroll-run'],['Attendance','attendance_leave/attendance']]},
super_admin:{t:'Super Admin',u:['Vikram Singh','Platform Owner'],i:[['Approvals','approvals'],['Users & Roles','users-roles'],['Audit Log','audit-log'],['System Settings','settings']]},
payroll:{t:'Payroll & Comp',u:['Neha Kapoor','Finance Lead'],i:[['Salary Structure','salary-structure'],['Comp Planning','comp-planning'],['Bonus Calculation','bonus'],['Payroll Run','payroll-run'],['Payslip (employee view)','payslip']]},
recruiting:{t:'Recruiting & Onboarding',u:['Anita Rao','HR Administrator'],i:[['Requisitions','requisitions'],['Candidate Pipeline','pipeline'],['Onboarding','onboarding'],['Offboarding','offboarding']]},
attendance_leave:{t:'Attendance & Leave',u:['Priya Sharma','Software Engineer'],i:[['Attendance','attendance'],['Apply Leave','leave-apply'],['Leave Approvals','leave-approvals'],['Team Calendar','team-calendar']]}
};
var b=document.body,role=b.dataset.role,page=b.dataset.page,title=b.dataset.title||document.title;
if(role==='auth'){return}
var n=NAV[role],path=location.pathname;
function href(p){return '../'+(p.indexOf('/')>-1?p:role+'/'+p)+'.html'}
var links=n.i.map(function(x){var h=href(x[1]);return '<a href="'+h+'"'+(path.slice(-h.length+2)===h.slice(2)?' class="on"':'')+'>'+x[0]+'</a>'}).join('');
var jump='<div class="jump"><a href="../index.html">All mockups</a></div>';
var main=document.querySelector('main');main.className='content';
var app=document.createElement('div');app.className='app';
app.innerHTML='<aside class="side"><div class="brand"><span class="logo"></span>Elevate-360</div><div class="role">'+n.t+'</div>'+links+jump+'</aside><div class="main"><div class="top"><strong>'+title+'</strong><div class="user"><span class="muted">Q2 2026 Cycle</span><div class="av">'+n.u[0][0]+'</div><div><div>'+n.u[0]+'</div><div class="small muted">'+n.u[1]+'</div></div></div></div></div>';
b.insertBefore(app,main);app.querySelector('.main').appendChild(main);
})();
