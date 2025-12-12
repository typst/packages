#import "dependency.typ": *
#import "template.typ": *

#show: report.with(
    partner: lorem(2),
    student-name: lorem(2),
    grade: lorem(2),
    group: lorem(2),
    course: lorem(2),
    lab-title: lorem(5),
    date: datetime.today(),
    tool-group: lorem(1),
)
