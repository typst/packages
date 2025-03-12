#import "@preview/min-resume:0.1.0": resume, letter, xp, skills, edu, linkedin-qrcode

#show: resume.with(  
	name: "John B. Good Worker",
	title: "Work Specialist",
	photo: image("assets/photo.png"),
	personal: "Relevant personal info",
	birth: (1997, 05, 19),
	address: "Address (no street nor house number)",
	email: "worker@email.com",
	phone: "+1 (000) 000-0000",
	letter: "Amazing Enterprise LLC",
)


= Objective

My objective is to be hired and my goal is to work hard and earn some money.


= Professional Experience

#xp(  
	role: "Chief Work Officer",
	place: "A Way More Cooler Corp.",
	time: (2024, 2), 
	skills: [
	  - Applied the things I learned
	  - Did more stuff
	  - Accomplished so much more goals
	  - Learned even more things
	],
)  

#xp(  
	role: "Proactive Manager", 
	place: "Some Really Cool Inc.",
	time: (2023, 3, 2024, 1), 
	skills: [
	  - Did some stuff
	  - Learned some things
	  - Accomplished some goals
	]
)  


= Education

#edu(
  course: "Doctorate in Grinding",
  place: "Respected University",
  time: (2020, 1, 2024, 11),
  skills: [
    - Learned stuff
    - Studied more stuff
    - Wrote about the stuff I learned
    - Wrote a thesis on interesting things
  ]
)


= Qualification

- A Really Useful Course. Educational Institution. Year or Validity.  
- A Very Professional Qualification. Educational Institution. Year or Validity.  
- A Less Useful Certification. Educational Institution. Year or Validity.  


= Skills  

#skills[
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
- Awarded as _Best Employee Ever 2025_


#linkedin-qrcode("linkedin-username")


#letter[  
  Dear Hiring Manager, or who it may concern,
  
  Please hire me, please! I'm good at working, and learning, and I will earn a lot
  of money to your company. And would like pretty much to earn some money for
  myself too.
  
  Best Regards,\  
  John B. Good Worker.  
] 