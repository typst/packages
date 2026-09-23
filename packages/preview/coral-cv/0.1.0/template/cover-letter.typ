// A matching cover letter is included beside the CV template.
#import "@preview/coral-cv:0.1.0": cover-letter

#show: cover-letter.with(
  author: "YOUR NAME",
  location: "Auckland, New Zealand",
  email: "hello@example.com",
  phone: "+64 21 000 0000",
  website: "yourname.dev",
  date: datetime.today().display("[day] [month repr:long] [year]"),
  recipient: [
    Hiring Manager \
    Example Studio \
    Auckland, New Zealand
  ],
  subject: "Senior Product Designer",
)

I am writing to apply for the Senior Product Designer position at Example Studio. My experience turning complex customer needs into clear, useful products aligns strongly with the role.

At Studio North, I led end-to-end design for a platform used by more than 30,000 people. Working closely with engineering and research, I reduced onboarding time by 35% and established a reusable design system across product teams.

I would welcome the opportunity to discuss how my product thinking, research practice, and systems approach could contribute to Example Studio. Thank you for your time and consideration.
