#import "/src/lib.typ": backmatter, frontmatter, mainmatter

#show: frontmatter.with(
  letterhead_title: "DEPARTMENT OF THE AIR FORCE",
  letterhead_caption: "washington, DC",
  letterhead_seal: image("assets/dow_seal.png"),
  letterhead_seal_subtitle: "Office of the Secretary",
  date: datetime(month:1,day:1,year:2024),
  subject: "Format for the Official Memorandum",
  memo_for: "XXXX",
  memo_from: (
    "SAF/CN",
    "1800 Air Force Pentagon",
    "Washington, D.C., 20330-1665",
  ),
  references: ("HOI 33-3, Correspondence Preparation, Control, and Tracking",),
  memo_style: "daf",
)

#mainmatter[
  As an action officer, you will prepare official memorandums for the signature of your senior leader using the Headquarters of the Department of the Air Force official memorandum format. This format is unique to the executive part of the Department of the Air Force and differs from other types of correspondence described in the Tongue and Quill.

  Type paragraphs in an indented style 0.5" from the left margin, single-spaced, with double spaces between them. Keep brief, preferably no longer than one page.

  + A subdivided paragraph must have at least two subdivisions.

  + If there is a subparagraph "a," there must be a subparagraph "b." Indent the subparagraph an additional 0.5 inch.

  If appropriate, include a statement of reference to email and telephone concerning the subject matter.
]

#backmatter(
  signature_block: (
    "VENICE M. GOODWINE, SES, DAF",
    "Chief Information Officer",
  ),
  attachments: ("Listed here",),
  cc: ("ORG/SYM",),
)
