// This is the example document that is copied into your project when you run
// `typst init @preview/htl-saalfelden-thesis-requirements:0.1.4`.
//
// All of the styling lives in the package itself. This file only imports the
// `htl-doc` function and applies it to the document. Adjust `requirements.yaml`
// to your needs and write the body of your requirements specification below the
// show rule.

#import "@preview/htl-saalfelden-thesis-requirements:0.1.4": htl-doc

#show: htl-doc.with(yaml("requirements.yaml"))

= Introduction

This document specifies the requirements for the diploma thesis. Replace this
placeholder text with the content of your own requirements specification. The
cover page, the task description, and the statement of originality are generated
automatically from the data in `requirements.yaml`.
