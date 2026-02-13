// -----------------------------------------------------------------------------
// ---[ Template created by M. Horauer ]----------------------------------------
//
#import "@preview/uas-technikum-wien:0.1.0": *

// ---[ ToDo ]------------------------------------------------------------------
// Adjust the variables below ...

//#let lan = "de"
#let lan = "en"
//#let deg = "Bachelor"
#let deg = "Master"
#let std = "Embedded Systems"
//#let std = "Information- and Communication Systems"

#let title = "Title of your Thesis"
#let subTitle = "This is a longer sub-title"

#let authorName = "Ing. Max Mustermann, BSc"
#let authorID = "0123456789"

#let adv = "Prof(FH) Dipl.-Ing. Dr. Knowitall"
#let loc = "Wien"

// -----------------------------------------------------------------------------
// ---[ DO NOT TOUCH ]----------------------------------------------------------
#let thesisType = ""
#{
  if lan == "de" {
	if deg == "Bachelor" {
		thesisType = "BACHELORARBEIT"
	} else {
		thesisType = "MASTERARBEIT"
	}
 } else {
	if deg == "Bachelor" {
		thesisType = "BACHELOR PAPER"
	} else {
		thesisType = "MASTER THESIS"
	}
 }
}
#show: uastwthesissetup
#show "latex": LaTeX
#show "bibtex": BibTeX
#show "rust": Rust

#set page(numbering: none)
#show: uastwthesistitlepagefunc.with(language: lan, 
    thesis-type: thesisType, degree: deg, study-program: std, 
    thesis-title: title, thesis-subtitle: subTitle, 
    author: authorName, authorid: authorID, advisor: adv, 
    location: loc)

#show: declaration.with(language: lan)
#set page(footer: context [
	#set text(twgray, size: 10pt) 
	#align(right, counter(page).display("1"))
	]
)
#set page(numbering: "1")
#include "sections/01_kurzfassung.typ"
#include "sections/02_abstract.typ"
#include "sections/03_acknowledgement.typ"
#outline(
	title: if lan == "en" [Table of Contents] else [Inhaltsverzeichnis]
)
#counter(heading).update(0)
// -----------------------------------------------------------------------------
// --[ ADJUST YOUR CONTENT FILES BY ADDING/MODIFYING SECTIONS ]-----------------
#include "sections/10_section1.typ"
#include "sections/11_section2.typ"

// -----------------------------------------------------------------------------
// ---[ DO NOT TOUCH BIBLIOGRAPHY ]---------------------------------------------
#bibliography(
	title: if lan == "en" [Bibliography] else [Literaturverzeichnis],
	"sections/90_works.bib"
)
// -----------------------------------------------------------------------------
// --[ DO NOT TOUCH INDEX ]-----------------------------------------------------
#include "sections/99_index.typ" 


