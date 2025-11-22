#import "@preview/chuli-cv:0.1.0": *
#import "@preview/fontawesome:0.1.0": *

#show: cv

#let icons = (
  phone: fa-phone(),
  homepage: fa-home(fill: colors.accent),
  linkedin: fa-linkedin(fill: colors.accent),
  github: fa-github(fill: colors.accent),
  xing: fa-xing(),
  mail: fa-envelope(fill: colors.accent),
  book: fa-book(fill: colors.accent),
  cook: fa-utensils(fill: colors.accent),
  bike: fa-biking(fill: colors.accent),
  game: fa-gamepad(fill: colors.accent),
  robot: fa-robot(fill: colors.accent),
  bed: fa-bed(fill: colors.accent),
  write: fa-pen-to-square(fill: colors.accent),
  talk: fa-comments(fill: colors.accent),
  code: fa-code(fill: colors.accent),
  paint: fa-paintbrush(fill: colors.accent),
  music: fa-music(fill: colors.accent),
  friends: fa-users(fill: colors.accent),
  beer: fa-beer(fill: colors.accent),
)

#header(
  full-name: [Faye Valentine],
  job-title: [Bounty Hunter],
  socials: (
    (
      icon: icons.github,
      text: [username],
      link: "https://github.com/xxx"
    ),
    (
      icon: icons.mail,
      text: [username\@gmail.com],
      link: "mailto://username@gmail.com"
    ),
    (
      icon: icons.linkedin,
      text: [Faye Valentine],
      link: "https://linkedin.com/in/npujolm/"
    ),
    (
      icon: icons.homepage,
      text: [Earth],
      link: "#"
    ),
  ),
  profile-picture: image("media/avatar.jpg")
)

#show: body => columns(2, body)

#section("Experience")
#entry(
  title: "Bounty Hunter",  
  company-or-university: "Bebop", 
  date: "2068 - Today", 
  location: "Earth", 
  logo: image("media/experience.png"),
  description: list(
    [lorem ipsum dolor sit amet, consectetur adipiscing elit, ut labore et dolore magna aliqua.],   
    [ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.],
    [Excepteur sint occaecat cupidatat non proident, sunt in culpaia deserunt mollit anim id est laborum.],
    [Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.],
    [lorem ipsum dolor sit amet, consectetur adipiscing elit, ut labore et dolore magna aliqua.],   
    [lorem ipsum dolor sit amet, consectetur adipiscing elit, ut labore et dolore magna aliqua.], 
    [Excepteur sint occaecat cupidatat non proident, sunt in culpaia deserunt mollit anim id est laborum.],
  ),
)
#entry(
  title: "Bounty Hunter",  
  company-or-university: "Red Tail", 
  date: "2040 - 2068", 
  location: "Earth", 
  logo: image("media/experience.png"),
  description: list(
    [lorem ipsum dolor sit amet, consectetur adipiscing elit, ut labore et dolore magna aliqua.],   
    [ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.],
    [Excepteur sint occaecat cupidatat non proident, sunt in culpaia deserunt mollit anim id est laborum.],
    [Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.],
    [lorem ipsum dolor sit amet, consectetur adipiscing elit, ut labore et dolore magna aliqua.],   
    [ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.],
    [Excepteur sint occaecat cupidatat non proident, sunt in culpaia deserunt mollit anim id est laborum.],
    [Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.]
  ),
)

#section("Education")
#education-entry(
  title: "Bounty Hunter certified", 
  company-or-university: "Somewhere", 
  date: "2060 - 2068", 
  location: "Other somewhere", 
  logo: image("media/education.png", width: 10pt, height: 10pt),
  gpa: "50020",
  gpa-total: "50000"
)

#section("Personal Projects")
#entry(
  title: "lorem ipsum", 
  company-or-university: "Personal Project", 
  date: "2068", 
  location: "", 
  logo: image("media/avatar.jpg"), 
  description: list(
    [lorem ipsum dolor sit amet, consectetur adipiscing elit, ut labore et dolore magna aliqua.],   
    [ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.],
    [Excepteur sint occaecat cupidatat non proident, sunt in culpaia deserunt mollit anim id est laborum.],
  )
)
#entry(
  title: "Duis aute", 
  company-or-university: "Personal Project", 
  date: "2040", 
  location: "", 
  logo: image("media/avatar.jpg"), 
  description: list(
    [lorem ipsum dolor sit amet, consectetur adipiscing elit, ut labore et dolore magna aliqua.],   
    [ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.],
    [Excepteur sint occaecat cupidatat non proident, sunt in culpaia deserunt mollit anim id est laborum.],
  )
)

#section("Skills")
#skill(
  skills: ("Pistols", "Martial Arts", "Stealth", "Navigation"),
)

#section("Languages")
#language(
  name:"English",
  label:"Native",  
  nivel:3,
)

#section("My Time")
#piechart(
  activities: (
    (
      name: icons.friends,
      val: 0.2
    ),
    (
      name: icons.book,
      val: 0.1
    ),
    (
      name: icons.talk,
      val: 0.01
    ),
    (
      name: icons.robot,
      val: 0.09
    ),
    (
      name: icons.music,
      val: 0.09
    ), 
    (
      name: icons.game,
      val: 0.08
    ),
    (
      name: icons.beer,
      val: 0.8
    )
  )
)