#import "@preview/fontawesome:0.6.2": *

#let cventry-padding = (
  top: 0pt,
  bottom: 0pt,
  left: 10pt,
  right: 5pt,
)

#let to-string(input) = {
  if type(input) == str {
    input
  } else if type(input) == content {
    if input.has("text") {
      input.text
    } else if input.has("children") {
      input.children.map(to-string).join("")
    } else if input.has("body") {
      to-string(input.body)
    } else if input == [ ] {
      ""
    } else {
      // fallback, I don't know how to handle this input
      input
    }
  }
}

#let short-uri(uri, get-path: false) = {
  let uri = to-string(uri);
  let cleaned = uri.replace("https://", "")
                   .replace("http://", "")
                   .replace("www.", "")
                   .replace(regex("/$"), "");
  if get-path {
    cleaned.split("/").at(-1).split("?").at(0)
  } else {
    cleaned
  }
}

#let chiline() = {
  v(-3pt);
  line(length: 100%, stroke: gray);
  v(-10pt)
}

#let iconlink(
  uri, text: "", icon: "link", solid: false
) = {
  let uri = to-string(uri);
  let icon = to-string(icon);
  if text != "" {
    [#box(fa-icon(icon, solid: solid), inset: (right: 2pt))#link(uri)[#text]]
  } else {
    link(uri)[#fa-icon(icon, solid: solid)]
  }
}

#let githublink(
  uri, text: ""
) = {
  iconlink(uri, text: text, icon: "github")
}

#let dates(
  from: "", to: ""
) = {
  let from = to-string(from);
  let to = to-string(to);
  if from != "" and to != "" {
    from + " " + sym.dash.em + " " + to
  } else if from != "" {
    from + " " + sym.dash.em + " Now"
  } else {
    ""
  }
}


#let personal-info(
  email: "",
  phone: "",
  github: "",
  website: "",
  linkedin: "",
  ..misc
) = {
  let email = if email != "" {
    iconlink("mailto:" + email, text: email, icon: "envelope", solid: true)
  } else { "" };
  let phone = if phone != "" {
    iconlink("tel:" + phone, text: phone, icon: "phone")
  } else { "" };
  let github = if github != "" {
    iconlink(github,
            text: short-uri(github, get-path: true),
            icon: "github")
  } else { "" };
  let website = if website != "" {
    iconlink(website,
             text: short-uri(website),
             icon: "globe")
  } else { "" };
  let linkedin = if linkedin != "" {
    iconlink(linkedin,
             text: short-uri(linkedin, get-path: true),
             icon: "linkedin")
  } else { "" };

  let display = (email, phone, github, website, linkedin)
        .filter(it => it != "")
        .join(" | ");

  let kv = misc.named()
  for item in kv {
    let key = item.at(0);
    let value = item.at(1);
    display += " | " + iconlink(value, text: short-uri(value), icon: key);
  }

  let tuples = misc.pos()
  for t in tuples {
    if type(t) == dictionary {
      let link = if "link" in t {
        t.at("link")
      } else { "" };
      let text = if "text" in t {
        t.at("text")
      } else { "" };
      let icon = if "icon" in t {
        t.at("icon")
      } else { "link" };
      let solid = if "solid" in t {
        t.at("solid")
      } else { false };
      display += " | " + iconlink(link, text: text, icon: icon, solid: solid);
    }
  }
  display
}


#let cventry(
  tl: lorem(2),
  tr: "2333/23 - 2333/23",
  bl: "",
  br: "",
  padding: (:),
  content
) = {
  // if padding has value for override, use it
  // for key in ("top", "bottom", "left", "right") {
  //   if not key in padding.keys() {
  //     padding.insert(key, cventry-padding.at(key));
  //   }
  // }
  pad(..padding, block(
    inset: (left: 0pt),
    [
      #if type(tl) == str { strong(tl) } else { tl } #h(1fr) #tr \
      #if bl != "" or br != "" {
        bl + h(1fr) + br + linebreak()
      }
      #content
    ]
  ))
}

#let chicv(
  margin: (x: 0.9cm, y: 1.3cm),
  par-padding: cventry-padding,
  body
) = {
  fa-version("6")

  set par(justify: true, leading: 0.7em)

  show heading.where(
    level: 1
  ): set text(
    size: 22pt,
    font: (
      "Montserrat",
      "New Computer Modern",
    ),
    weight: "light",
  )

  show heading.where(
    level: 2
  ): it => text(
    size: 14pt,
    font: (
      "Montserrat",
      "New Computer Modern",
    ),
    weight: "light",
    block(
      chiline() + it,
    )
  )
  set list(indent: 0pt)

  set pad(
    top: if "top" in par-padding { par-padding.at("top") } else { cventry-padding.top },
    bottom: if "bottom" in par-padding { par-padding.at("bottom") } else { cventry-padding.bottom },
    left: if "left" in par-padding { par-padding.at("left") } else { cventry-padding.left },
    right: if "right" in par-padding { par-padding.at("right") } else { cventry-padding.right },
  )

  show link: it => underline(offset: 2pt, it)

  set page(
    margin: margin,
    footer: context [
      #if counter(page).get() != counter(page).final() {
        align(center, text(fill: gray)[ … continues on the next page …])
      } else {
        // show nothing!
      }
    ],
    footer-descent: 10%,
  )

  body
}

#let today() = {
  let month = (
    "January", "February", "March", "April", "May", "June", "July",
    "August", "September", "October", "November", "December",
  ).at(datetime.today().month() - 1);
  let day = datetime.today().day();
  let year = datetime.today().year();
  [#month #day, #year]
}
