#import "helpers.typ": linked-text

#let settings = state("exp-cl-settings", (
  date: "",
  gap: 20pt,
  dated: false,
  author: "",
))

#let absent(value) = {
  value == none or (type(value) == str and value.trim() == "")
}

// One block. Lines inside it stay tight. Empty input prints nothing.
#let line-block(lines, above: 0pt, below: 0pt) = {
  let kept = lines.filter(line => not absent(line))
  if kept.len() > 0 {
    block(width: 100%, above: above, below: below)[
      #for (i, line) in kept.enumerate() {
        if i > 0 { linebreak() }
        line
      }
    ]
  }
}

// Date sits between the sender lines and the company. The first of
// sender or recipient prints it, so a missing block does not drop it.
#let place-date() = context {
  let current = settings.get()
  if not current.dated and not absent(current.date) {
    settings.update(s => s + (dated: true))
    line-block((current.date,), below: current.gap)
  }
}

#let sender(
  author: "",
  pronouns: "",
  location: "",
  email: "",
  email-text: "",
  github: "",
  github-text: "",
  linkedin: "",
  linkedin-text: "",
  phone: "",
  personal-site: "",
  personal-site-text: "",
) = {
  settings.update(s => s + (author: author))
  if not absent(author) {
    set document(author: author, title: author)
  }

  context {
    line-block(
      (
        if not absent(author) { strong(author) },
        location,
        linked-text(phone, link-prefix: "tel:"),
        linked-text(email, link-prefix: "mailto:", text: email-text),
        linked-text(linkedin, link-prefix: "https://", text: linkedin-text),
        linked-text(github, link-prefix: "https://", text: github-text),
        linked-text(personal-site, link-prefix: "https://", text: personal-site-text),
        pronouns,
      ),
      below: settings.get().gap,
    )
    place-date()
  }
}

#let recipient(
  recipient-name: "",
  recipient-title: "",
  company: "",
  company-address: "",
  greeting: "",
) = context {
  place-date()
  line-block((company, company-address), below: settings.get().gap)
  line-block(
    (
      if not absent(greeting) { greeting }
      else if not absent(recipient-name) { [Dear #recipient-name,] }
      else if not absent(recipient-title) { [Dear #recipient-title,] },
    ),
    below: settings.get().gap,
  )
}

#let letter(
  accent-color: "#000000",
  font: "New Computer Modern",
  paper: "us-letter",
  font-size: 12pt,
  gap: 20pt,
  lang: "en",
  date: "",
  closing: "",
  body,
) = {
  settings.update((
    date: date,
    gap: gap,
    dated: false,
    author: "",
  ))

  set text(
    font: font,
    size: font-size,
    lang: lang,
    ligatures: false,
  )

  set page(
    margin: (0.5in),
    paper: paper,
  )

  show link: set text(fill: rgb(accent-color))

  set par(leading: 0.55em, spacing: gap, justify: false)
  set block(spacing: 0pt, above: 0pt, below: 0pt)

  body

  if not absent(closing) {
    line-block((closing,), above: gap)
  }

  context {
    line-block((settings.get().author,), above: gap)
  }
}
