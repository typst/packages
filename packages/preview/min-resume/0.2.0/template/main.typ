#import "@preview/min-resume:0.2.0": resume, entry, list, linkedin, letter

#show: resume.with( 
	name: "John B. Goode Workmann",
	title: "Work Specialist",
	photo: image("assets/photo.png"),
	info: "Relevant personal info",
	birth: (1997, 05, 19),
	address: "Public address",
	email: "workmann@email.com",
	phone: "+1 (000) 000-0000",
)


= Objective

To be hired and work hard to (hopefully) earn some money.


= Professional Experience

#entry(
	title: "Chief Work Officer",
	organization: "Macrosoft Corp",
	location: "Bluemond (WA)",
	time: (2024, 2),
	skills: [
	  - Did more stuff
	  - Applied the things I learned
	  - Learned even more
	  - Accomplished so much more
	],
)  
#entry(
	title: "Proactivity Manager",
	organization: "Amazônia LLC",
	location: "Earttle (WA)",
	time: (from: (2023, 4, 1), to: (2023, 8, 2)),
	skills: [
	  - Did some stuff
	  - Learned some things
	  - Accomplished some goals
	]
)  


= Education

#entry(
  title: "PhD in Grinding",
  organization: "Hardvar University",
  time: (from: (2022, 3, 13), to: (2025, 1, 11)),
  skills: [
    - Learned stuff
    - Studied things
    - Researched some learned stuff
    - Thesis on interesting things
  ]
)


= Qualification

- #underline[Really Useful Qualification]. MI Tech. Valid until #{datetime.today().year() + 3}
- #underline[Very Professional Course]. Ucademy, #{datetime.today().year()}
- Cool Certification. Genghis Academy, #{datetime.today().year() - 1}


= Skills  

#list[
  - Knows things
  - Smile often
  - Talks to a lot of people
  - Get things done
  - Fast coffee and bathroom breaks
]


= Additional Information  

- Available to work 24/7
- Available to do some tiresome business travels
- Know some extra things
- Did some extra work
- Awarded as _Best Employee Ever #datetime.today().year()_


#linkedin("username")


#letter(to: "Googol LLC\nMount View (CA)")[
  Dear Hiring Manager, or to whom it may concern,

  Please hire me. I work. A lot. Some say too much, but I think they are the
  ones who peripherally don’t like working... I mean, you can’t call yourself a hard
  worker and refuse to work on Sundays if your boss asks you to work on Saturdays.
  If they ask of you much, make sure you give them too much --- that’s my life
  philosophy.
  
  I’m also very attentive to details: I once set an out-of-office reply saying I
  would not be checking emails while on holiday. Then I spent most of the holiday
  checking whether it was working properly. I like to ensure everything runs like
  clockwork --- except for my sleep cycle, which is a long-lost battle, but
  nothing two cups of coffee in the morning can’t fix.
  
  I thrive under pressure, survive on caffeine, and only need to rest
  occasionally. If you need someone who will work weekends, holidays, and
  possibly in their dreams --- I am your person.
  
  I promise to bring unstoppable energy, a questionable work-life balance, and a
  genuine passion for making your company even greater and wealthier. Please,
  let me prove that exhaustion is just another word for "commitment."
  
  Eagerly,\
  John B. Goode Workmann.
] 