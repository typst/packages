#import "@preview/bluenote-ist:0.1.0": *
#import "ppt-config.typ": *

#show: ist-theme.with(
  aspect-ratio: "16-9",
  footer: self => self.info.institution,
  config-info(
    title: ppt-config.title,
    subtitle: ppt-config.subtitle,
    author: ppt-config.author,
    date: ppt-config.date,
    contact: ppt-config.contact,
    institution: ppt-config.institution,
  ),
)

#set heading(numbering: numbly("{1}.", default: "1.1"))

#title-slide(
  bg-img: background-image
)

#outline-slide(title: none, level: 2, indent: 1em)

#include "sections.typ"

#end-slide("Thank you")
