#import "../swaralipi.typ": render_composition

#show raw: it => if "note" in it.lang { render_composition(it.text, it.lang) } else { it }

= Yaman
 Yaman is a popular raga in Hindustani classical music, typically performed in the evening. It belongs to the Kalyan thaat and is characterized by its serene and romantic mood. The raga uses all seven notes in both ascending and descending scales, with a distinctive use of the tivra (sharp) Ma note.

/ Vadi: ```note G```
/ Samvadi: ```note N```
/ Time: Evening
/ Thaat: Kalyan
/ Pakad: ```note N. R G M , P M , R G R S```

== Vilambit 

```note[taal: tintal]
                      |                           |           >   GG  | R    SS    N.D.D.    NR
G      G    G    RR   | G     MM    P      MM     | G    R    S       |
                      |                           |           >   RR  | S    N.N.  G.        P.
D.     N.   S    RR   | G     MM    P      M      | G    R    S       |


                     |                            |           >  MM   | G   MM  D         N
S'    S'    S'   S'S'|  D     NN     R'     S'    | N    D    P       |
                     |                            |           >  G'G' | R'  S'S"  N       S'
N     D     P    RR  |  G    MM    P      M       | G    R    S       |
```
