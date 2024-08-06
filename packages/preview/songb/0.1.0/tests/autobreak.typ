// SPDX-FileCopyrightText: 2024 Olivier Charvin <git@olivier.pfad.fr>
//
// SPDX-License-Identifier: CC0-1.0

#import "../autobreak.typ": autobreak;

#autobreak[
  = Paragraph 1
]

#autobreak[
  = Paragraph 2
  should not break (enough space below Paragraph 1)
  #lorem(500)
]


#autobreak[
  = Paragraph 3
  Paragraph 3 should break (not enough space below Paragraph 1+2)
  #lorem(500)
]

#autobreak[
  = Paragraph 4
  Paragraph 4 should not break (can spread below paragraph 3 and next page)
  #lorem(700)
]

#autobreak[
  = Paragraph 5
  Paragraph 5 should break (to prevent page turning)
  #lorem(700)
]

#autobreak[
  = Paragraph 6
  Paragraph 6 should break (to prevent page turning)
  #lorem(600)
]

#autobreak[
  = Paragraph 7
  Paragraph 7 should break twice? (not implement yet) (to prevent page turning)
  #lorem(800)
]
