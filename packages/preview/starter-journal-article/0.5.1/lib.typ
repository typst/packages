#import "lang/index.typ": lang-templates
#import "lang/i18n.typ": i18n

#let author-meta(
  ..affiliation,
  email: none,
  alias: none,
  address: none,
  cofirst: false
) = {
  let info = (
    "affiliation": affiliation
  )
  if email != none {
    info.insert("email", email)
  }
  if alias != none {
    info.insert("name", alias)
  }
  if address != none {
    info.insert("address", address)
  }
  if cofirst != none {
    info.insert("cofirst", cofirst)
  }
  info
}

#let article(
  // Article's Title
  title: "Article Title",
  
  // A dictionary of authors.
  // Dictionary keys are authors' names.
  // Dictionary values are meta data of every author, including
  // label(s) of affiliation(s), email, contact address,
  // or a self-defined name (to avoid name conflicts).
  // Once the email or address exists, the author(s) will be labelled
  // as the corresponding author(s), and their address will show in footnotes.
  // 
  // Example:
  // (
  //   "Auther Name": (
  //     "affiliation": "affil-1",
  //     "email": "author.name@example.com", // Optional
  //     "address": "Mail address",  // Optional
  //     "name": "Alias Name", // Optional
  //     "cofirst": false // Optional, identify whether this author is the co-first author
  //   )
  // )
  authors: ("Author Name": author-meta("affiliation-label")),

  // A dictionary of affiliation.
  // Dictionary keys are affiliations' labels.
  // These labels show be constent with those used in authors' meta data.
  // Dictionary values are addresses of every affiliation.
  //
  // Example:
  // (
  //   "affiliation-label": "Institution Name, University Name, Road, Post Code, Country"
  // )
  affiliations: ("affiliation-label": "Affiliation address"),

  // The paper's abstract.
  abstract: [],

  // The paper's keywords.
  keywords: (),

  // Templates for the following parts:
  // - `title`: how to show the title of this article.
  // - `author-list`: how to show the list of the authors.
  // - `author`: how to show each author's information.
  // - `affiliation`: how to show the affiliations.
  // - `abstract`: how to show the abstract and keywords.
  // - `body`: how to show main text.
  // Please see below for more infomation.
  template: (:),

  // Paper's content
  body
) = context {
  // Set document properties
  set document(title: title, author: authors.keys())
  show footnote.entry: it => {
    let loc = it.note.location()
    stack(
      dir: ltr,
      spacing: 0.2em,
      box(width: it.indent, {
        set align(right)
        super(baseline: -0.2em, numbering(it.note.numbering, ..counter(footnote).at(loc)))
      }),
      it.note.body
    )
  }
  set footnote(numbering: "*")

  let (
    default-title,
    default-author-info,
    default-abstract,
    default-body,
  ) = lang-templates.at(text.lang, default: lang-templates.en)
  let template = (
    title: default-title,
    author-info: default-author-info,
    abstract: default-abstract,
    body: default-body,
    ..template,
  )

  // Title block
  (template.title)(title)

  set align(left)
  // Restore affiliations' keys for looking up later
  // to show superscript labels of affiliations for each author.
  let inst_keys = affiliations.keys()

  // Find co-fisrt authors
  let cofirst_index = authors.values().enumerate().filter(
    meta => "cofirst" in meta.at(1) and meta.at(1).at("cofirst") == true
  ).map(it => it.at(0))

  let author_list = ()

  // Authors and affiliations
  // Authors' block
  // Process the text for each author one by one
  for (ai, au) in authors.keys().enumerate() {
    let author_list_item = (
      name: none,
      insts: (),
      corresponding: false,
      cofirst: "no",
      address: none,
      email: none,
    )

    let au_meta = authors.at(au)
    // Write auther's name
    let aname = if au_meta.keys().contains("name") and au_meta.name != none {
      au_meta.name
    } else {
      au
    }
    author_list_item.insert("name", aname)
    
    // Get labels of author's affiliation
    let au_inst_id = au_meta.affiliation.pos()
    let au_inst_primary = ""
    // Test whether the author belongs to multiple affiliations
    if type(au_inst_id) == array {
      // If the author belongs to multiple affiliations,
      // record the first affiliation as the primary affiliation,
      au_inst_primary = affiliations.at(au_inst_id.first())
      // and convert each affiliation's label to index
      let au_inst_keys = au_inst_id.map(id => inst_keys.find(key => key == id))
      // Output affiliation
      author_list_item.insert("insts", au_inst_keys)
    } else if (type(au_inst_id) == str) {
      // If the author belongs to only one affiliation,
      // set this as the primary affiliation
      au_inst_primary = affiliations.at(au_inst_id)
      // convert the affiliation's label to index
      let au_inst_key = inst_keys.find(key => key == au_inst_id)
      // Output affiliation
      author_list_item.insert("insts", (au_inst_key,))
    }

    // Corresponding author
    if au_meta.keys().contains("email") or au_meta.keys().contains("address") {
      author_list_item.insert("corresponding", true)
      let address = if not au_meta.keys().contains("address") or au_meta.address == "" {
        au_inst_primary
      } else { au_meta.address }
      author_list_item.insert("address", address)
      
      let email = if au_meta.keys().contains("email") and au_meta.email != none {
        au_meta.email
      } else { none }
      author_list_item.insert("email", email)
    }

    if cofirst_index.len() > 0 {
      if ai == 0 {
        author_list_item.insert("cofirst", "thefirst")
      } else if cofirst_index.contains(ai) {
        author_list_item.insert("cofirst", "cofirst")
      }
    }

    author_list.push(author_list_item)
  }

  let used_affiliations_keys = author_list.map(it => it.insts).flatten().dedup()
  let used_affiliations = used_affiliations_keys.map(it => (it, affiliations.at(it))).to-dict()
  
  author_list = author_list.map(au => (
    :
    ..au,
    insts: au.insts.map(it => used_affiliations_keys.position(key => key == it))
  ))

  (template.author-info)(author_list, used_affiliations, styles: template)

  (template.abstract)(abstract, keywords)

  counter(footnote).update(0)

  show: template.body
  
  body
}

#let suffix(
  body
) = {
  set heading(numbering: none)
  body
}

#let appendix(
  body
) = context {
  let (gettext, locale) = i18n(text.lang)
  counter(heading).update(0)
  set heading(numbering: "A.1.", supplement: gettext("appendix"))
  show heading: it => context block(above: 1em, below: 1em, {
    if it.level == 1 {
      gettext("appendix") + " " + counter(heading).display(it.numbering)
    } else {
      counter(heading).display(it.numbering)
    }
    h(4pt)
    it.body
  })
  show figure: set figure(numbering: (..nums) => context {
    (counter(heading.where(level: 1)).display("A"), ..nums.pos().map(str)).join(".")
  })
  body
}

#let booktab(
  ..args,
  top-bottom: 1pt,
  mid: 0.5pt
) = {
  show table.cell.where(y: 0): strong
  table(
    stroke: (x, y) => (
      top: if y == 0 { top-bottom } else if y == 1 { mid } else { 0pt },
    ),
    ..args,
    table.hline(stroke: top-bottom)
  )
}
