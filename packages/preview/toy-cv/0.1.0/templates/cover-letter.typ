#import "@preview/toy-cv:0.1.0": *

#show: cover-letter.with(
  recipient-name: "John Doe",
  recipient-description: "Hiring Manager",
  sender-name: "Jane Smith",
  sender-description: "123 Main St, Springfield, USA",
  i18n: "en",
  subject: "Application for Software Engineer Position",
  prompt-injection: true,
  keywords-injection: ("software", "engineer", "developer"),
  signature: image("assets/signature.png"),
)

#lorem(100)

#lorem(100)
