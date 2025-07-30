#import "@preview/tuhi-booklet-vuw:0.2.0": course-info, tuhi-booklet-vuw, sentence-case, fmt-email, fmt-person 


#let info = json("teas.json")
#let info_school = yaml("info.yaml")

#show: tuhi-booklet-vuw.with(
  author: "SPIRIT",
  title: "Undergraduate courses",
  date: datetime(year: 2024,month: 7, day: 3),
  school: "School of Brewing and Steeping",
  alternate: "千と千尋の神隠し",
  address: "The Tea house",
  phone: info_school.spirit_tea_school.phone,
  web: info_school.spirit_tea_school.website,
  email: info_school.spirit_tea_school.email,
  illustration: image("figures/illustration.jpg",width: 100%))

  
= Teaware & gong fu cha

#lorem(100)

== Major requirements for Tea
<major-requirements>

+ (TEAS 142, 151) or (GAIW 121 and B+ or better in GAIW 122), COFF 142, 145

+ HEAT 241, 242; one of (FIRE 243, 245); 15 further points from (FIRE 201–204, FIRE 201–259, LEAF 205 - 206); 15 further points from (LEAF 200-299, STEM 241, FORK 292, CUPS 261)

+ HEAT 304, 305, 307, 345.


== Entry to 100-level tea courses
<entry-to-100-level-courses>

- #lorem(50)

- #lorem(50)


== Who to contact
<who-to-contact>

#let pc_gf = info_school.at(info_school.cha_gong_fu.ug_coordinator)
#let pc_tw = info_school.at(info_school.teapot_care.ug_coordinator)

All enquiries about undergraduate courses should be directed to the Programme Director:

- For gong fu: #fmt-person(pc_gf) (#fmt-email(pc_gf))

- For teaware: #fmt-person(pc_tw)  (#fmt-email(pc_tw))

#pagebreak(weak: true)


// #info
// #info.keys()

== 100-level courses

#course-info(info.teas101)
#course-info(info.teas102)
#course-info(info.teas103)

== 200-level courses

#course-info(info.teas202)
#course-info(info.teas204)

== 300-level courses

#course-info(info.teas301)
#course-info(info.teas302)
#course-info(info.teas305)

== 400-level courses

#course-info(info.teas401)
#course-info(info.teas402)
#course-info(info.teas403)

== 500-level courses

#course-info(info.teas502)


#pagebreak()

#set text(11pt, number-type: "lining",weight: 400,font: "Fira Sans")


= Who to contact

#let info-row(x) = ([#fmt-person(x)], [#x.office], [#x.phone])

== Student Success Team

#grid(columns: (2cm,1fr),
rows: auto,
row-gutter: 9pt,
// [],[],
[Address:],	[#info_school.address],
[Phone:] 	,		[#info_school.phone],
[Email: ]		,	[#info_school.email],
[Website:]	,	[#info_school.website],
[Hours:]		,	[#info_school.hours],
 )

 #lorem(50)

== School Staff contacts

#grid(columns: (1fr,0.5fr, 0.8fr,0.4fr),
column-gutter: 10pt,
rows: auto,
row-gutter: 9pt,
// [Contact],[Name],[Room],[Phone],
 [Head of School] , ..info-row(info_school.haku),
 [Deputy Head of School (tea)],..info-row(info_school.kamaji),
 [Deputy Head of School (pots)],..info-row(info_school.no_face),
 [School Manager	], ..info-row(info_school.lin),
 [General Enquiries], ..info-row(info_school.yubaaba),
)

== Brewing Enquiries			

#grid(columns: (1fr,0.5fr, 0.8fr,0.4fr),
column-gutter: 10pt,
rows: auto,
row-gutter: 9pt,
// [Contact],[Name],[Room],[Phone],
 [Undergraduate teaspoon-level], ..info-row(info_school.zeniba),
 [Undergraduate teacup-level], ..info-row(info_school.kamaji)
)
	 		
			