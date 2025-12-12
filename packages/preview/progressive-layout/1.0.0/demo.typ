// Import the layout function from the local template
#import "@preview/progressive-layout:1.0.0": progressive-layout, progressive-outline
// #import "lib.typ": progressive-layout, progressive-outline

// Apply the layout to the entire document
#show: doc => progressive-layout(doc, show-numbering: true)

= First Section : General Introduction

== Project Context

#lorem(20)

== Objectives

#lorem(20)

= Second Section : Detailed Analysis

== Analysis of User's Need

#lorem(20)

== Proposed Solutions

=== Solution A

#lorem(20)

=== Solution B

#lorem(20)

= Third Section : Conclusion

== Appraisal

#lorem(20)

== Perspectives

#lorem(20)
