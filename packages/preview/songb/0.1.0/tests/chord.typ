// SPDX-FileCopyrightText: 2024 Olivier Charvin <git@olivier.pfad.fr>
//
// SPDX-License-Identifier: CC0-1.0

#import "../chord.typ": chord, chord-display;

= First song

Alph#chord[Asus4]a#chord[Bb]bet#chord[C\#][ ]space\

#text(weight: "bold")[
Alph#chord[Asus4]a#chord[Bb]bet #chord[C\#][sbace]\
]

Trailing chords#chord[A]#chord[Bm7]#chord[C\#]\
Space #chord[A Bm7 C\#][within] chord#chord[A Bm7 C\#][] #chord[Other]

#v(30pt)

A#chord[C]mazing #chord[C7]grace How #chord[F]sweet the#chord[C][ ]sound

That #chord[C]saved a wretch like #chord[G]me!#chord[G7]

I #chord[C]once was #chord[C7]lost, but #chord[F]now am#chord[C] found

Was #chord[C]blind, but #chord[G]now I #chord[C]se#chord[F]e#chord[C]\
Was #chord[C]blind, but #chord[G]now I #chord[Cb]se#chord[F]e#chord[C]\
Was #chord[C]blind, but #chord[G]now I #chord[Cb]sei#chord[F]e#chord[C]\
Was #chord[C]blind, but #chord[G]now I #chord[Cb]sii#chord[F]e#chord[C]\

Was #chord[C\#m][b]lind, but #chord[G]now I #chord[Cb]sii#chord[F]e#chord[C]\

#chord-display.update("hide")
Was #chord[C\#m][b]lind, but #chord[G]now I #chord[Cb]sii#chord[F]e#chord[C]\
#chord-display.update("")

== Line height

Dynamic line height:\
More space #chord[G]with a chord\
Less space without

#lorem(13) At the en#chord[E]nddddd it may wrap BUG: the word should not split. See below:\
#lorem(13) At the ennddddd it may wrap (without \#chord, the word did not split)\
#lorem(13) At the en#chord[E][nddddd] it may wrap. Partial workaround using additional \[...\]\

#chord[Em]#chord[Am]#chord[Em]\
#chord[Em][]#chord[Am][]#chord[Em][]