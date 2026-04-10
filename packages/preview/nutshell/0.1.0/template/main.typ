#import "@preview/nutshell:0.1.0": nutshell-setup, colorize

#let (nutshell, fonts, palette, status, details) = nutshell-setup()

#let contact-details = (
  address: raw("Floating Pavilion, Hangzhou"),
  mobile: raw("+1 (555) 888-TEAS"),
  email: raw("rylee@nicetea.co"),
  line: raw("@chalvorson97"),
  web: raw("nicetea.co"),
)

#show: nutshell.with(
  title: "Tea Master • CEO of NIce Tea",
  author: "Rylee Halvorson",
  alsoknown: "Tea Whisperer, Westbound Infuser",
  nationality: "Born in Asia",
  age: "32 years old",
  date: "today",
  last-updated: "2025",
  resume-url: "nicetea.co",
  contact-details: contact-details,
  statement: emph[A dedicated practitioner and scholar of Gongfu Cha, my mission is to share the artistry, tranquility, and cultural richness of Chinese and Japanese tea traditions with the Western world. Currently blending ancient wisdom with modern aesthetics as CEO of NIce Tea.]
)

== Work experience
<work-experience>

/ 2024–Now: #status[ceo, tea ambassador] |> #details[nice tea, global]\
  Founded a cross-cultural tea lifestyle brand rooted in Gongfu Cha principles\
  Designed tea ceremonies and product lines merging tradition and modernity\
  Built partnerships with artisan growers in Fujian, Uji, and beyond\
  Hosted global tastings, livestreamed tea meditations, curated zen playlists

/ 2018–2024: #status[doctoral researcher] |> #details[university of yunnan + kyoto university]\
  Earned PhD in Gongfu Cha with research on its transmission to the West\
  Conducted fieldwork across China, Japan, and Taiwan\
  Published bilingual thesis: “_Infusing Culture: Gongfu Cha Beyond Borders_”\
  Served as guest master for temples, tea rooms, and cultural expos

/ 2014–2018: #status[tea apprentice] |> #details[various tea houses, asia]\
  Trained under renowned masters in Wuyishan and Uji\
  Practiced calligraphy, incense appreciation, and water-reading\
  Learned to interpret _cha qi_ (tea energy) in silent ceremonies\
  Documented oral histories of elderly tea artisans

== Core competencies
<core-competencies>

/ Gongfu Cha: #status[deep mastery of Chinese tea traditions]\
  Skilled in Yixing, Gaiwan, and wood-fired teaware handling\
  Expert in pu-erh, oolong, sencha, matcha preparation & philosophy\
  Developed signature “Five Breaths” serving sequence

/ Sensory mastery: #status[refined palate and aroma intuition]\
  Can distinguish over 200 aroma notes across tea varietals\
  Developed a sensory training kit used in international tea education\
  Consulted for perfumers and sommeliers on cross-sensory blending

/ Cultural fluency: #status[connector of East and West]\
  Conducted bilingual workshops across continents\
  Fluent in Mandarin, Japanese, and English — with tea vocabulary\
  Curated exhibitions on tea aesthetics for modern audiences

/ Entrepreneur: #status[visionary founder & operator]\
  Bootstrapped Nice Tea from pop-ups to retail & online success\
  Led creative direction for packaging, digital identity, and storytelling\
  Mentored emerging tea start-ups through Cha Collective
  
#pagebreak()

== Acquired skills
<acquired-skills>

/ Patience: #status[expert at waiting for water to cool]\
  Can detect 3°C temperature shifts by touch\
  Once steeped a dancong 21 times, each better than the last\
  Makes even impatient executives sit through a 2-hour ceremony

/ Teaching: #status[sought-after tea educator]\
  Designed workshops for corporate wellness and mindfulness retreats\
  Created the “_Tea leaf readings_” intro course for YouTube (13B views)\
  Trained hospitality staff in tea etiquette at five-star hotels

/ Aesthetics: #status[curator of stillness and simplicity]\
  Designed tea spaces blending wabi-sabi and Scandinavian minimalism\
  Regularly consulted on feng shui & interior flow for tea rooms\
  Captures ephemeral tea moments in photography and haiku

== Conferences
<conferences>

/ 2025: World Tea Expo • _Seattle_ |> #details[keynote: “The Future is Slow”]\
/ 2024: Tokyo Tea Symposium • _Shinjuku_ |> #details[panel: “Tradition in the Age of TikTok”]\
/ 2023: Cha Dao Retreat • _Hualien_ |> #details[facilitator: silence & ceremony]\
/ 2022: Kyoto International Tea Forum • _Kyoto_ |> #details[research presentation]

== Education
<education>

/ Until age 12: #status[traditional grounding] |> #details[suzhou, china]\
  Studied classical poetry, tea history, calligraphy\
  Learned basic tea preparation from local elders

/ High School: #status[immersion in japanese tea culture] |> #details[uji, japan]\
  Participated in school-led chadō (Way of Tea)\
  Apprenticed with a local matcha master during summers

/ University: #status[phd in gongfu cha] |> #details[wuyishan university, fujian]\
  Dissertation: “Infusing Culture: Gongfu Cha Beyond Borders”\
  Field studies in Taiwan, Japan, and Western tea communities

== Hobbies
<hobbies>

#let hiking = colorize(read(
    "noun-hiking-7853559.svg"
  ), palette.highlight.base.transparentize(80%))
#let kettle = colorize(read(
    "noun-kettle-7840362.svg"
  ), palette.highlight.base.transparentize(80%))

/ #move(dy: -8pt, image(bytes(hiking), height:2cm)): _I love hiking through misty tea mountains, listening to rain on bamboo, and capturing serene moments in photography. You’ll often find me sipping gyokuro at sunrise or writing tea-inspired haiku with friends._

/ #move(dy: -8pt, image(bytes(kettle), height:2cm)): _I keep a journal of boiled water I’ve tasted, including notes on region, pH, minerality, and the mood they evoke. Every spring, I return to the Himalayas to collect stream water from the source._

#v(1fr)
#align(center, text(size: 41pt, fill: palette.highlight.base.transparentize(
  90%,
))[❧])
#v(1fr)
