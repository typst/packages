// Imports
#import "@preview/brilliant-cv:3.1.2": cv-section, cv-skill, cv-skill-with-level, cv-skill-tag, h-bar
#let metadata = toml("../metadata.toml")
#let cv-section = cv-section.with(metadata: metadata)


#cv-section("Fähigkeiten")

#cv-skill-with-level(
  type: [Sprachen],
  level: 4,
  info: [Deutsch (Muttersprache) #h-bar() Englisch (Fließend) #h-bar() Französisch (Konversation)],
)

#cv-skill-with-level(
  type: [Programmierung],
  level: 5,
  info: [Python #h-bar() SQL #h-bar() R],
)

#cv-skill(
  type: [Technologie Stack],
  info: [Tableau #h-bar() Snowflake #h-bar() AWS #h-bar() Docker #h-bar() Git],
)

#cv-skill(
  type: [Zertifizierungen],
  info: [
    #cv-skill-tag([AWS Zertifiziert])
    #cv-skill-tag([Google Analytics])
    #cv-skill-tag([Tableau Desktop])
  ],
)

#cv-skill(
  type: [Persönliche Interessen],
  info: [Schwimmen #h-bar() Kochen #h-bar() Lesen #h-bar() Fotografie],
)
