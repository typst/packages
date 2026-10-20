#import "../utils/translate.typ": translate

#let detect-meeting-type(meeting, meeting-type) = if meeting-type == auto {
  let meeting = if type(meeting) == content { meeting.text } else { meeting }
  if meeting.starts-with(regex("S\d\d")) {
    translate("Styrelsemöte", "Board meeting")
  } else if meeting.starts-with(regex("SRD\d\d")) {
    translate("Studierådsmöte", "Student Council meeting")
  } else [] // guild assemblies are usually only called VTM / HTM in notices/minutes
} else {
  meeting-type
}
