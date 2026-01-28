#import "@preview/neat-cv:0.6.0": letter

#set text(lang: "en")  // Change to display date in your language

#show: letter.with(
  author: (
    firstname: "Emmet",
    lastname: "Brown",
    email: "doc.brown@hillvalley.edu",
    address: [1640 Riverside Drive\ Hill Valley\ California, USA],
    phone: "(555) 121-1955",
    position: ("Inventor", "Theoretical Physicist"),
  ),
  profile-picture: image("profile.png"),
  accent-color: rgb("#4682b4"),
  // font-color: rgb("#333333"),
  header-text-color: rgb("#3b4f60"),
  // date: auto,
  // heading-font: "Fira Sans",
  // body-font: ("Noto Sans", "Roboto"),
  // body-font-size: 10.5pt,
  // paper-size: "us-letter",
  // profile-picture-size: 4cm,
  // footer: auto,
  recipient: [
    Scrooge McDuck\
    Business tycoon inc.\
    McDuck Manor\ Hill Valley\ California, USA
  ],
)

Dear Mr. McDuck,

Great Scott! I am writing to express my enthusiastic interest in joining your esteemed enterprise. As an inventor, scientist, and time travel aficionado, I believe my unique skill set would be a tremendous asset to your legendary pursuit of innovation and wealth accumulation.

Throughout my career, I have demonstrated an unwavering commitment to pushing the boundaries of possibility—most notably with the creation of the flux capacitor and the DeLorean time machine. My expertise spans physics, engineering, and creative problem-solving, all of which I am eager to apply to your ventures, whether they involve treasure hunts, financial strategies, or technological advancement.

I am particularly drawn to your adventurous spirit and relentless drive. I am confident that, together, we could revolutionize the way fortunes are made and managed—perhaps even across centuries!

Thank you for considering my application. I look forward to the possibility of collaborating with you on projects that are, dare I say, out of this world.

Your future employee,

#align(right)[ Dr. Emmett L. Brown ]
