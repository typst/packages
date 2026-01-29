// Imports
#import "@preview/brilliant-cv:3.1.2": cv-section, cv-skill, cv-skill-with-level, cv-skill-tag, h-bar


#cv-section("Skills")

#cv-skill-with-level(
  type: [Languages],
  level: 4,
  info: [English (Native) #h-bar() French (Fluent) #h-bar() Chinese (Conversational)],
)

#cv-skill-with-level(
  type: [Programming],
  level: 5,
  info: [Python #h-bar() SQL #h-bar() R],
)

#cv-skill(
  type: [Tech Stack],
  info: [Tableau #h-bar() Snowflake #h-bar() AWS #h-bar() Docker #h-bar() Git],
)

#cv-skill(
  type: [Frameworks & Libraries],
  info: [Pandas #h-bar() NumPy #h-bar() Scikit-learn #h-bar() TensorFlow #h-bar() FastAPI],
)

// Skill tags example
#cv-skill(
  type: [Certifications],
  info: [
    #cv-skill-tag([AWS Certified])
    #cv-skill-tag([Google Analytics])
    #cv-skill-tag([Tableau Desktop])
    #cv-skill-tag([Scrum Master])
  ],
)

#cv-skill(
  type: [Personal Interests],
  info: [Swimming #h-bar() Cooking #h-bar() Reading #h-bar() Photography],
)
