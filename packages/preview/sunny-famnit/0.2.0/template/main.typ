#import "@preview/sunny-famnit:0.2.0": project

#show: project.with(
	date: datetime(day: 1, month: 1, year: 2024), // you could also do `datetime.today()`
	text_lang: "en", // the language that the thesis is gonna be written in.
	
	author: "your name",
	studij: "your course",
	mentor: (
    name: "his name", 
    en: ("prepends","postpends"), // you can prepend or postpend any titles
    sl: ("predstavki","postavki"),// you can prepend or postpend any titles
    ),
	somentor: none, // if you have a co-mentor write him here the same way as mentor, else you can just remove the line.
	work_mentor: none, // if you have a work mentor, the same as above

	naslov: "your title in slovene",
	title: "your title",

	izvleček: [
		your abstract in slovene.
	],
	abstract: [
		your abstract
	],

	ključne_besede: ("Typst", "je", "super!"),
	key_words: ("Typst", "is", "Awesome!"),

	kratice: (
		"Famnit": "Fakulteta za matematiko naravoslovje in informacijske tehnologije",
		"PDF": "Portable document format",
	),

	priloge: (), // you can add attachments as a dict of a title and content like `"name": [content],`

	zahvala: [
		you can add an acknowlegment.
	],
	
  	bib_file: bibliography(
    	"my_references.bib",
    	style: "ieee",
    	title: [Bibliography],
  	),

	/* Additional content and their defaults
	kraj: "Koper",
	*/
)

= Uvod

your thesis goes here.
