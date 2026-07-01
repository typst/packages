// Development entry point — for local testing, install the package locally:
//   mkdir -p ~/Library/Application\ Support/typst/packages/local/unofficial-icl-doc-thesis/0.1.0
//   cp -r . ~/Library/Application\ Support/typst/packages/local/unofficial-icl-doc-thesis/0.1.0/
// Then compile with: typst compile main.typ output.pdf
#import "@local/unofficial-icl-doc-thesis:0.1.0": project, back-matter
#import "@local/unofficial-icl-doc-thesis:0.1.0": *

#show: project.with(
  title: "Your Project Title",
  author: "Your Name",
  supervisor: "Supervisor Name",
  report-type: "MEng Individual Project",
  degree: "Master of Engineering (MEng)",
  abstract: [
    Write your abstract here.
  ],
)

= Introduction
= Background
= Contribution
= Experimental Results
= Conclusion

#back-matter()
#bibliography("references.bib", style: "elsevier-vancouver")
