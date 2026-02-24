#import "preamble.typ": *

= Inleiding
Some text

== A subtitle
More text

We refereren naar een zéér interessante onderzoeksproject rond netwerken
(TCP/IP gerelateerd) @OuroborosModel2020 en @LocIdSplit2022.
Maar volgens #cite(<LibrecastDecentralisationPrivacy>, form: "prose") is multicast zo mogelijk nóg interessanter. @IoTUpdatesIPv6
Daar valt iets voor te zeggen. @HowDoesOuroboros2021 @staessensDesignOuroborosPacket2020

=== A subsubtitle

#todo-add(pos: "block")[We need to fill this paragraph]
#todo-change[This sentence][help] is really not yet constructed...
And #todo-unsure(pos: "inline")[another inline] note.

==== Heading
A paragraph

#box[==== Heading]
within the paragraph, depending on your preference (this does not reset the
paragraph counter! See comment in `src/styling/elements.typ`, #code-inline[```typc ugent-heading-rules```]).

/* TODO: show the usage @preview/physica in this example dissertation
 * Do this after https://github.com/Leedehai/typst-physics/pull/46 is merged.
 */

== Figure usage
#let functionG-python = code-block[
  ```python
  def G(nu, gamma, omega, t):
      # Bemerk dat we de tangens maar éénmaal
      # berekenen en dan hergebruiken!
      v = np.tan(omega * t)
      y1 = (2+nu) * v/(gamma-v)
      y2 = gamma*y1
      return y1, y2
  ```
]
#figure(
  functionG-python,
  caption: flex-caption(
    [Under the figure, we want to give quite a few comments to correctly interpret everything.],
    [The short version for the outline.],
  ),
)
