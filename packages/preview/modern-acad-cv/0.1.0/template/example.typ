// #import "modern-acad-cv.typ": *
#import "@preview/modern-acad-cv:0.1.0": *

// loading meta data and databases (needs to be ad this directory)
#let metadata = yaml("metadata.yaml") 
#let multilingual = yaml("dbs/i18n.yaml")
#let work = yaml("dbs/work.yaml")
#let education = yaml("dbs/education.yaml")
#let grants = yaml("dbs/grants.yaml")
#let refs = yaml("dbs/refs.yaml")
#let conferences = yaml("dbs/conferences.yaml")
#let talks = yaml("dbs/talks.yaml")
#let committee = yaml("dbs/committee.yaml")
#let teaching = yaml("dbs/teaching.yaml")
#let training = yaml("dbs/training.yaml")
#let skills = yaml("dbs/skills.yaml")

// set the language of the document
#let language = "en"      

// defining variables
#let headerLabs = create-headers(multilingual, lang: language)

#show: modern-acad-cv.with(
  metadata, 
  multilingual,
  lang: language,   
  font: "Fira Sans",
  show-date: true
)    

= #headerLabs.at("work")

#cv-auto-stc(work, multilingual, lang: language)

= #headerLabs.at("education")

#cv-auto-stp(education, multilingual, lang: language) 

= #headerLabs.at("grants")
 
#cv-auto-stp(grants, multilingual, lang: language)  
 
= #headerLabs.at("pubs")

#cv-cols(
  "",
  for lang in multilingual.lang.keys() {
    if language == lang [
      #multilingual.lang.at(lang).pubs-note
    ] 
  }
)  

== #headerLabs.at("pubs-peer")
#cv-refs(refs, multilingual, tag: "peer", me: [Mustermensch, M.], lang: language)

== #headerLabs.at("pubs-edited")
#cv-refs(refs, multilingual, tag: "edited", me: [Mustermensch, M.], lang: language)

== #headerLabs.at("pubs-book")
#cv-refs(refs, multilingual, tag: "book", me: [Mustermensch, M.], lang: language)

== #headerLabs.at("pubs-reports")
#cv-refs(refs, multilingual, tag: "other", me: [Mustermensch, M.], lang: language)

== #headerLabs.at("pubs-upcoming")
#cv-refs(refs, multilingual, tag: "planned", me: [Mustermensch, M.], lang: language) 

= #headerLabs.at("confs") 
== #headerLabs.at("confs-conf")
#cv-cols(
  "", 
  headerLabs.at("exp-confs")
)

#cv-auto-list(conferences, multilingual, lang: language)

== #headerLabs.at("confs-talks")
#cv-auto(talks, multilingual, lang: language)

= #headerLabs.at("committee")

#cv-auto(committee, multilingual, lang: language)

= #headerLabs.at("teaching")

== #headerLabs.at("teaching-thesis")
#if language == "de" [
  #cv-two-items[Bachelor][9][Master][2]
] else if language == "en" [
  #cv-two-items[Bachelor][9][Master][2]
] else if language == "pt" [
  #cv-two-items[Graduação][9][Pós-Graduação][2]
] else [
  #cv-two-items[Bachelor][9][Master][2]
]

== #headerLabs.at("teaching-courses")

#cv-table-teaching(teaching, multilingual, lang: language)

= #headerLabs.at("training")

#cv-auto-cats(training, multilingual, headerLabs, lang: language)

= #headerLabs.at("others")

#cv-auto-skills(skills, multilingual, metadata, lang: language)
