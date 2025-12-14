// #import "../dependency.typ": *
// #import "../template.typ": *
#import "@preview/sdu-common-lab-report-template:0.1.0": *

#show: report.with(
    partner: "                           ",
    student-name: "                              ",
    student-grade: "                           ",
    student-group: "                                ",
    course: "                              ",
    lab-title: "                                                                       ",
    lab-date: datetime.today(),
    tool-group: "                       ",
    logo: image("sdu.png"),
)
