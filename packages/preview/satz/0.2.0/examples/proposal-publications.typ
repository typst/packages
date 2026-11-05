#import "../lib.typ": dfg-proposal, dfg-publications, proposal-citations

// Keep the citation rule after the document-layout rule.
#show: dfg-proposal.with(
  applicant: [Example Applicant, Example University],
  project: [Selected publications from an unchanged BibTeX file],
)
#show: proposal-citations.with(
  read("../dfg-proposal/lit.bib"),
  highlight: ("duncan2010",),
)

= Starting Point
Both works are cited normally: @duncan2010 and @miller2001.
The selected work will be bold in the bibliography; the other stays regular.

= Objectives and work programme
Citations continue to link to their corresponding bibliography entries.

= Project- and subject-related list of publications
#dfg-publications()
