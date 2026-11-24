#import "@preview/pandect-apa7:0.2.0": *

#show: apa7.with(
  paper-type: "student",
  title: "Title of Your Research Paper",
  authors: (
    (
      name: "Your Name",
      affiliation: "Department of Your Field, University Name",
    ),
  ),
  course: "Course Code: Course Name",
  instructor: "Instructor Name",
  due-date: datetime.today(),
  abstract: [
    This is the abstract for your paper. In APA 7th edition, the abstract is a single
    unindented paragraph (150–250 words) placed on Page 2, summarizing the purpose,
    methodology, primary results, and conclusions of your work.
  ],
  keywords: ("Academic writing", "APA style", "Typst"),
  lang: "en",
)

= Introduction

Type or paste your introduction here. In APA 7, standard paragraphs are indented by 0.5 inches (1.27 cm) and double-spaced throughout.

== Literature Review

You can cite academic literature using parenthetical citations @baddeley1974 or narrative citations like #cite-narrative(<baddeley1974>, page: 48).

== Methodology

Describe your participants, experimental design, and analytical procedures.

=== Statistical Model

You can report statistical outcomes using our built-in APA 7 helpers:
#apa-stat(t: 2.45, df: 48, p: .018, d: .71).

#bibliography("sample.bib")
