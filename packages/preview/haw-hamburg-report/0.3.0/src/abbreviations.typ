#import "dependencies.typ": print-glossary, register-glossary

#set heading(numbering: none)

= Abbreviations

#let entry-list = (
  (
    key: "cpu", 
    short: "CPU",
    long: "Central Processing Unit",
  ),
)

#register-glossary(entry-list)

#print-glossary(entry-list, disable-back-references: true)
