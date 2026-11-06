#import "@preview/nutshell:0.1.0": nutshell-setup, colorize

#let custom-palette = (
  background: (
    base: luma(95%),
    light: luma(98%),
    dark: luma(90%),
  ),
  foreground: (
    base: luma(40%),
    light: luma(40%),
    dark: luma(0%),
  ),
  highlight: (
    base: rgb("#8a1313"),
    light: rgb("#672020"),
    dark: rgb("#8a1313"),
  ),
)

#let custom-fonts = (
  main: (
    font: "IM Fell English",
    size: 11pt,
    features: (
      onum: 1,
      calt: 1,
      hist: 0,
      cswh: 1,
      dlig: 1,
      hlig: 1,
      liga: 1,
      clig: 1,
    ),
    weight: 500,
  ),
  title: (
    size: 24pt,
    font: "Hobbiton Brushhand",
    weight: 800,
  ),
  section: (
    font: "IM Fell English sc",
    features: (smcp: 1, c2sc: 1, onum: 1),
  ),
  subsection: (font: "IM Fell English sc"),
  subsubsection: (font: "IM Fell English sc"),
  raw: (
    font: "Fira Mono",
    size: 9pt,
    fill: black,
    weight: 200,
  ),
  math: (
    font: "Fira Math",
    size: 10pt,
    fill: black,
    weight: 500,
  ),
)


#let (nutshell, fonts, palette, status, details) = nutshell-setup(
  fonts: custom-fonts,
  palette: custom-palette,
)

#show smallcaps: set text(font: "IM Fell English sc")

#let contact-details = (
  address: raw("Valinor, Arda"),
  mobile: raw("flying moths"),
  email: raw("mithrandir@istari.me"),
  skype: raw("gandalf"),
  web: raw("gandalf.tumblr.com"),
)

#show: nutshell.with(
  title: "Wizard • pointy-hatted • pipe smoker",
  author: "Gandalf the Grey",
  alsoknown: "Olórin, Gandalf",
  nationality: "Maia, bearer of Narya & Glamdring",
  age: "Born before Arda was created",
  date: "today",
  last-updated: "fourth age",
  resume-url: "gandalf.tumblr.com",
  contact-details: contact-details,
  statement: emph[Sent by the Valar to combat the threat of Sauron upon Middle-Earth. On eonnual leave since the Third Age.\ A true wizard when it comes to fireworks, dragons and Balrogs, I also enjoy a good smoke. When things get too hot even for me, I know to delegate.],
  separator: image("staff.svg"),
)

// workarounds as font does not follow opentype sc
#let status = it => lower(status(it))
#let details = it => lower(details(it))
#show heading.where(level: 2): it => lower(it)

== Work experience
<work-experience>

/ Fourth Age: #status[Retired wizard] |> #details[Manwë’s team, Valinor]\
  Smoking and reminiscing about the great battles of the past\
  Hanging out with Bilbo and Frodo, Lady Galadriel, Elrond, and many elves

/ Third Age: #status[grey, then white wizard] |> #details[policy adviser & guide, middle earth]\
  Sent by the Valar to help Men and Elves in the fight against Sauron\
  Advised the rulers of Middle-Earth, often against their bad judgment\
  Collaborated with Elrond, Lady Galadriel, and Aragorn\
  Communicated to a Balrog that it _cannot
  pass_ a bridge\
  Sent a Hobbit to steal a stone from a dragon and stir up 5 armies\
  Conferred the title of _Fellows of the Ring_ to 9 elves, hobbits, men and dwarves\
  Sent a Hobbit to melt a ring in a volcano\
  Flew at the back of eagles


/ 1st & 2nd Age: #status[maia, istari] |> #details[manwë’s assistant, valinor]\
  Participated in the shaping of Middle-Earth\
  Helped building lamps, growing trees, teaching elves\
  Fighter against Morgoth and a giant spider


/ Before Ëa: #status[spiritual, music enthusiast] |> #details[ilúvatar & co., out of this world]\
  Participated in the music that shaped the universe |> --- _with Ainur orchestra • duration: aeons_ \
  Co-created all the riches in the world \
  Countered dissonant views with more harmonious music\
  Admired what might come to be


== Core competencies
<core-competencies>

/ Wizardry: #status[expert in spells, fire and staff handling]\
  Organised fireworks for Bilbo’s anniversary in the Shire\
  Fought a Balrog through deep waters and tall mountain peaks\
  Broke Saruman’s staff from a distance\
  Saved the day riding a white horse downhill from the direction of sunrise


/ Comm’: #status[broad experience with all languages of middle-earth]\
  Offered advice to leaders — men and women, dwarves, elves, hobbits, bear\
  Liaised with the ents to water down Saruman’s evil plans\
  Deciphered a pass phrase challenge to enter Moria (with help from Frodo)\
  Interpreted invisible writings on a hot ring without touching it

#pagebreak()

== Acquired skills
<acquired-skills>
/ Decisiveness: #status[champion of good vs evil]\
  Sword-fighting with Glamdring\
  Staff-wielding — breaking stone bridges before my feet, deterring a rogue wizard, bringing light to dark places\
  Occasional stabbing of orcs and goblins, burning of werewolves

/ Rhetoric: #status[powerful orator]\
  Grew taller, darker, scarier when talking down a Hobbit inside his hole\
  Sneaked a weapon in Théoden’s reception room past the guards\
  Convinced Théoden to wake up from his torpor\
  Shut off a glass ball spy camera connected to a burning eye\
  Snapped at boss from ivory tower\
  Conversed with moths to call for eagles\
  Convinced Beorn to bear the company of dwarves for one night

/ Leadership: #status[trusted and wise team builder]\
  Talked everyone, including hobbits, into highly dangerous adventures\
  Summoned dwarves, men, hobbits and elves to group meetings\
  Led teams through forests, grasslands, avalanche-ridden mountain tops\
  Organised the replacement of a bitter steward by the rightful king\
  Sent a hobbit up a tower to lit a long-distance call for help\
  Had a 'nose' to choose the right path through the tunnels of Moria\
  Advised Frodo not to judge Smeagol hastily, indirectly saving the world\
  later on, on the day when the strength of a Hobbit failed

== Conferences
<conferences>

/ 3021: With Elrond, Galadriel, Frodo and Bilbo • _Grey Havens_ |> #details[parting thoughts]

/ 3019: With Aragorn & armies • _Black Gate_ |> #details([teethy negotiation]) \
  Encounter with a Balrog • _Moria_ |> #details([deep argument])\
  Assembly of a Fellowship (dwarves, elves, humans) • _Rivendell_ |>
  #details([convenor])\
  Venom-and-stick moves • _Rohan_ |> #details([wizardry])

/ 3017: Counsel-seeking from Saruman • _Orthanc tower_ |> #details([robust discussion])

/ 2949: Visit of Bilbo with Balin • _Shire_ |> #details([talk & smoke])


== Hobbies
<hobbies>
// #set image(width: 80%)

#let map = colorize(read(
    "map-svgrepo-com.svg"
  ), palette.highlight.base.transparentize(80%))
#let pipe = colorize(read(
    "pipe-4-svgrepo-com.svg"
  ), palette.highlight.base.transparentize(80%))


/ #move(dy: 0pt, image(bytes(map), height:1.2cm)): _I am passionately curious about most Middle-Earth cultures and life-forms, and keen to connect.\ I enjoy travelling, conversing in most foreign languages, catching up with old friends unannounced, plotting surprise parties and mischievous quests to save the world._

/ #move(dy: 0pt, image(bytes(pipe), height:1.2cm)): _I am an avid pipe smoker, a hobby I took up years ago with my hobbit friends in the Shire. Thanks to my wizardry, I am able to shape the smoke into any form conceivable, sailing boats for example. My favourite leaf is the Southern Star, grown around Bree._

#v(1fr)
#align(center, text(size: 41pt, fill: palette.highlight.base.transparentize(
  90%,
))[❧])
#v(1fr)
