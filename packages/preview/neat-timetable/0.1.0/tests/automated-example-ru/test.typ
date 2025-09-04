#import "/template.typ": get-timetable-info, template, timetable
#show: template
#timetable(..get-timetable-info(json("ШУЦ1-31Б.json")))
