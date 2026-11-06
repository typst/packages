
// Document Version
// --------------------------------------------------------
#let doc-version = version(1, 0)


// Document Date
// --------------------------------------------------------
#let doc-date = datetime.today().display("[day]. [month repr:long] [year]")
//#let date = datetime(year: 2020, month: 10, day: 4)


// Document Type and Title
// --------------------------------------------------------
#let doc-type = "Master Thesis"
#let doc-title = "My Title"


// Supervisors
// --------------------------------------------------------
#let name-supervisor1 = "supervisor1"
#let name-supervisor2 = "supervisor2"


// Tutorial
// --------------------------------------------------------
#let show-tutorial = true


// Document Language - Not supportet yet
// --------------------------------------------------------
//#let document_language = "en" 


// Authors
// ====================================================================================
//  There can at max. be six authors!
//  Required: Family Name, Given Name, Matrikel Number, Student Mail, 
// ====================================================================================

// Max. 6 Authors!
#let authors = ()

#authors.push(
  (
    fam-name: "Family Name 1",
    giv-name: "Given Name 1",
    mtr-no: "111111",
    course: "Software Engineering",
    uni: "Heilbronn University",
    e-mail: ""  
  )
)



/*
#let author1 = (
  fam-name: "Family Name 1",
  giv-name: "Given Name 1",
  mtr-no: "111111",
  course: "Software Engineering",
  uni: "Heilbronn University",
  e-mail: ""
)

#let author2 = (
  fam-name: "Family Name 2",
  giv-name: "Given Name 2",
  mtr-no: "222222",
  course: "Software Engineering",
  uni: "Heilbronn University",
  e-mail: ""
)

#let author3 = (
  fam-name: "Family Name 3",
  giv-name: "Given Name 3",
  mtr-no: "333333",
  course: "Software Engineering",
  uni: "Heilbronn University",
  e-mail: ""
)

#let author4 = (
  fam-name: "Family Name 4",
  giv-name: "Given Name 4",
  mtr-no: "444444",
  course: "Software Engineering",
  uni: "Heilbronn University",
  e-mail: ""
)
*/


