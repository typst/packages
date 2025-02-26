#import "@preview/hhn-unitylab-thesis-template:0.0.1": *
#import "../90-Document/91-Doc-Info.typ": show-tutorial
#show: format-doc-main.with()

#counter(page).update(1)      // Reset Counter Pages
#counter(heading).update(0)   // Reset Counter Headings

#include "../20-Intro/20-Main-Doc-Intro.typ"
#if show-tutorial == true { include "../90-Document/92-Tutorial.typ"}
#include "../30-Chapters/30-Main-Doc-Personal.typ"
#include "../40-Outro/40-Main-Doc-Outro.typ"



/*
// Main Document Chapters
// --------------------------------------------------------



#include "../20-Intro/21-Introduction.typ"
#include "../20-Intro/22-Research Question.typ"
#include "../20-Intro/23-State of the Art.typ"

*/