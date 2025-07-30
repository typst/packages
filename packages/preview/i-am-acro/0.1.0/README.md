# i-am-acro
Acronym package for typst, aiming for multilanguage support and feature richness.

This package manages acronyms with multiple defined languages and supports advanced features like displaying an acronym with suffix or a custom form.

For a full guide how to use this package see the documentation: [docs.pdf](https://github.com/etwasmitbaum/i-am-acro/blob/main/docs.pdf)

A quick overview of the features:
- Declare acronyms in multiple langauages
- Manage acronyms with their short, short-plural, long and long-plural form
- Automatically show a second language (if defined)
- Print acronyms in a table
- Link acronyms to acronym table

# Quick start
```typ
#import "acronym.typ": * // import everything
#let acronyms = (
  LED: ( // key
    en: ( // language key
      short: [LED], //requiered
      short-pl: [LEDs], // requiered
      long: [Light Emitting Diode], //optional
    ),
    de: (
      short: "LED",
      long: "Leuchtdiode",
      long-pl: "Leuchtdioden", // optional
    ),
  ),
)

#init-acronyms(acronyms, "en", always-link: false)
`#ac("LED")` -> Light Emitting Diode (LED)
`#ac("LED")` -> LED
`#acl("LED")` -> Light Emitting Diode
`#acl("LED", lang: "de")` -> Leuchtdiode
`#ac-suffix("LED", "Case")` -> LED-Case or (if shown first time) Light Emitting Diode(LED)-Case
```

# Overview of all functions
For detailed explanation see: [docs.pdf](https://github.com/etwasmitbaum/i-am-acro/blob/main/docs.pdf)
| **Function**                           | **Description**                                                                                                     |
|----------------------------------------|---------------------------------------------------------------------------------------------------------------------|
| **#init-acronyms(...)**                | Initialize acronyms and set default settings (like language) |
| **#ac(...)**                           | Display Acronym. This will show the long form when the acronym is displayed for the first time. |
| **#acp(...)**                          | Display plural version of the acronym. If no plural was defined "s" will be appended. |
| **#acl(...)**                          | Display the long form of the acronym. |
| **#aclp(...)**                         | Display the long plural form of the acronym. |
| **#acs(...)**                          | Display the short form of the acronym. |
| **#acsp(...)**                         | Display the short plural form of the acronym. |
| **#ac-suffix(...)**                    | Display Acronym with an hyphenated suffix. |
| **#ac-custom(...)**                    | Display Acronym as custom defined Text but treat it as in #ac() |
| **#update-acro-lang(...)**             | Change used default language. |
| **#update-acro-second-lang(...)**      | Change used default second language. |
| **#update-acronym-used(...)**          | Change the state, if an acronym was used before. |
| **#update-acronym-long-shown(...)**    | Change the state, if an the long form of an acronym was shown before. |
