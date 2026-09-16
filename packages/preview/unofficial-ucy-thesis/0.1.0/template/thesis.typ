#import "@preview/unofficial-ucy-thesis:0.1.0": bibliography-heading, guidelines, setup-appendices, ucy-thesis

// --- Abbreviations (optional) — entries in acronyms.typ; cite as @ucy, @ade, … ---
// No abbreviations: delete this block, set glossary: none, remove @key cites in chapters.
// In-text only (no list page): glossary: none and add
//   #print-glossary(acronyms, invisible: true)  // after register-glossary above
#import "@preview/glossarium:0.5.10": make-glossary, print-glossary, register-glossary
#import "acronyms.typ": acronyms
#show: make-glossary
#register-glossary(acronyms)

// Official ADE guidelines (same links as the LaTeX template):
// - #link(guidelines.ade)
// - Word template: #link(guidelines.word)

#show: ucy-thesis.with(
  // Change only this to switch the whole thesis (covers, TOC, chapters, bibliography, …)
  primary-lang: "en", // "el"
  localized-info: (
    en: (
      diploma-project: "Diploma Project",
      title: "Thesis title",
      faculty: "Faculty of Pure and Applied Sciences",
      department: "Department of Computer Science",
      // submission-statement: [
      //   The Thesis was submitted in partial fulfillment of the requirements for
      //   obtaining the Computer Science degree of the Department of Computer Science
      //   of the University of Cyprus.
      // ],
      abstract: include "content/abstract-en.typ",
      keywords: ("thesis", "computer science", "research", "ucy"),
      // show: true,  // default — include this language's abstract
    ),
    el: (
      diploma-project: "Ατομική Διπλωματική Εργασία",
      title: "Τίτλος εργασίας",
      faculty: "Σχολή Θετικών και Εφαρμοσμένων Επιστημών",
      department: "Τμήμα Πληροφορικής",
      // show: false,  // omit the Greek abstract page (entry may stay for other fields)
      // submission-statement: [
      //   Η Ατομική Διπλωματική Εργασία υποβλήθηκε προς μερική εκπλήρωση των απαιτήσεων
      //   απόκτησης του πτυχίου Πληροφορικής του Τμήματος Πληροφορικής του Πανεπιστημίου
      //   Κύπρου.
      // ],
      abstract: include "content/abstract-el.typ",
      keywords: ("διπλωματική", "πληροφορική", "έρευνα", "πανεπιστήμιο κύπρου"),
    ),
  ),
  // You only need entries for languages you use. At least one must have show != false.
  authors: (
    (
      first-name: "John",
      last-names: "Doe",
    ),
  ),
  advisors: (
    (
      first-name: "Dr Advisor",
      last-names: "Bob",
    ),
  ),
  // logo-image: image("ucy-logo.svg"),  // supply your own UCY logo (see README)
  // doc-date: datetime.today(),  // default in ucy-thesis
  acknowledgements: include "content/acknowledgements.typ",
  glossary: print-glossary(acronyms),
  // Typography (optional tuning; UCY margins unchanged)
  // style: (
  //   tracking: 0.04em,
  //   leading: 0.85em,
  //   par-spacing: 0.55em,
  //   list-spacing: 0.45em,
  // ),
)

#include "content/ch01-introduction.typ"
#include "content/ch02-background.typ"
#include "content/ch03-method.typ"
#include "content/ch04-results.typ"
#include "content/ch05-discussion.typ"
#include "content/ch06-conclusions.typ"

// Extra chapters: copy content/ch07-other-chapter.typ, edit it, then uncomment:
// #include "content/ch07-other-chapter.typ"

#bibliography(
  "references.yaml",
  style: "ieee",
  title: bibliography-heading(),
)

#show: setup-appendices
#include "content/appendix-a.typ"
