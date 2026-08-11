// Search for the word 'EDIT' in the files in this template. These should certainly be modified
#import "parts-dissertation/preamble.typ": *
#show: preamble-apply


// Here we include your preface, go and edit it!
#show: ugent.section.with("preface")
#include "parts-dissertation/0_preface.typ"

// Here we now enter the *real* document
#show: ugent.section.with("body")
#include "parts-dissertation/1_introduction.typ"
#include "parts-dissertation/5_conclusion.typ"
#include "parts-dissertation/6_sustainability.typ"

// Automatically styled by the template
#bibliography("assets/references.bib")

// The appendix (after bibliography!)
#show: ugent.section.with("annex")
#include "parts-dissertation/A_annex1.typ"

#todo-outline()
(Remove this once the dissertation is ready to be submitted)
