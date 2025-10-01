#import "@preview/sheen-id:0.1.0": *

#show: doc => conf(
  color: green,
  doc
)

#set-chapter-image("./media1/image1.png")

// #set-cover("media/cover-colored.png")
// #make-cover()
// #make-gray-cover()

#make-title(
  title: [MODUL OPEN-SOURCE EDA & FPGA],
  author: [Fitra fep],
  gap: 4.5in //optional
)

// #include "./module/copyright.typ"


#show: doc => make-header-footer(
  // img-path: "./media1/image2.jpeg", //optional
  doc
)

// #include "module/prakata.typ"

#make-toc()

#make-toi()
// #make-toe()

#show: doc => make-paragraph(doc)

#include "module/chapter1.typ"
#include "module/chapter2.typ"
#include "module/chapter3.typ"
#include "module/chapter4.typ"
#include "module/chapter5.typ"
#include "module/chapter6.typ"
#include "module/chapter7.typ"
#include "module/chapter8.typ"
#include "module/chapter9.typ"
#include "module/dafpus.typ"
