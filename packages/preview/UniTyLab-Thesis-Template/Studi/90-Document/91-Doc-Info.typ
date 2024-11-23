// Document Information
// =================================================================
// Document Version
#let doc-version = version(1, 0)


// Document Date
// -------------------------------------------------
//  Options: datetime.today() or a specific date
// -------------------------------------------------
#let doc-date = datetime.today().display("[day]. [month repr:long] [year]")
//#let date = datetime(year: 2020, month: 10, day: 4)


// Document Type and Title
// -------------------------------------------------
//  Put the official Title here
// -------------------------------------------------
#let doc-type = "Master Thesis"
#let doc-title = "My Title"


// Supervisors
// -------------------------------------------------
//  
// -------------------------------------------------
#let name-supervisor1 = "supervisor1"
#let name-supervisor2 = "supervisor2"


// Document Language - Not Supportet yet
// -------------------------------------------------
//  Options: "en" or "de"
// -------------------------------------------------
//#let document_language = "en" 


// Authors
// ====================================================================================
//  There can at max. be six authors!
//  Required: Family Name, Given Name, Matrikel Number, Student Mail, 
// ====================================================================================

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

#let author5 = (
  fam-name: "Family Name 5",
  giv-name: "Given Name 5",
  mtr-no: "555555",
  course: "Software Engineering",
  uni: "Heilbronn University",
  e-mail: ""
)

#let author6 = (
  fam-name: "Family Name 6",
  giv-name: "Given Name 6",
  mtr-no: "666666",
  course: "Software Engineering",
  uni: "Heilbronn University",
  e-mail: ""
)

// Max. 6 Authors!
#let authors = (
  author1,
  author2,
  //author3,
  //author4,
  //author5,
  //author6,
)