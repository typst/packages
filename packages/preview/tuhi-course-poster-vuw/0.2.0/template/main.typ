#import "@preview/tuhi-course-poster-vuw:0.2.0": tuhi-course-poster-vuw

// choice of fonts
#set text(font: "Source Sans Pro")
#show raw: set text(font: "Source Code Pro", size: 1.1em, tracking: -0.1pt)

// dummy details
#let logo = image("logo.svg")
#let url = "https://paekakariki.nz/"

#let contact = (school: "Ko Haumia Whakatere Taniwha te tangata • Ko Miriona te kuia",
          faculty: "Nau mai haere mai ki te papa kainga o Ngāti Haumia ki Paekākāriki",
          university: "Miriona Gardens, North end of Tilley Rd, Paekākāriki",
          phone: "+64·1·111·1111",
          email: "email@paekakariki.nz",
          website: "paekakariki.fm"
         )

#let courses = (
  Y1T1: "esca101 · esca145 · trek101 · swim141",
  Y1T2: "esca142 · esca131 · trek102 · swim142",
  Y2T1: "esca243 · esca245 · trek245",
  Y2T2: "esca241 · esca242 · trek201",
  Y3T1: "esca305 · esca307 · trek301",
  Y3T2: "esca304 · esca345 · trek360",
  Y4T1: "esca411 · esca413 · trek415 · swim490",
  Y4T2: "esca412 · esca414 · trek416 · swim417",
)

// use the template

#show: tuhi-course-poster-vuw.with(
  coursetitle : text[escarpment track],
  courseid : "esca101",
  coursemajor: "hiking",
  courseimage: image("images/esca101.jpg"),
  imagecredit : text[sunset],
  coursepoints : text[*1205*],
  coursetrimester : text[*0.005*],
  courselecturers : ("Bridges", "Stairway",),
  courseformat : text[*2* bridges/hangouts],
  coursedescription : text[Stairway to Heaven _that won't let you down_],
  courseprereqs: text[*1* achievement backpack \
                      in *LEVEL 3 NCEA* Tramping\
                      or equivalent, or *murph101*],
                      courses: courses,
  contact: contact,
  logo: logo,
  qrcodeurl: url,
)

== Paekākāriki to Pukerua Bay

Popular • unique trail • average-to-high fitness • legendary • \ 
sense of exhilaration! • Part of New Zealand’s Te Araroa Trail

== Take water, snacks and lunch with you

Allow at least 3.5 to 4 hours (half a day) for the 10km walk, \ plus extra for the train travel and rest stops

== Kāpiti Coastline

Follow the signs for approximately 600m until you reach the railway bridge underpass. Not recommended for the faint-hearted.



