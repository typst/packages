#import "../colors/palettes.typ": style
#import "../colors/palettes.typ": palette
#import "./tools.typ" : *



#let check-fonts(value) = {
  if value != none {
    assert(type(value) == dictionary,
    message: "`fonts` must be a dictionary, received : " + str(type(value)))

    let expected-keys = (
      body: (str, array, dictionary),
      header: (str, array, dictionary),
      mono: (str, array, dictionary)
    )
    check-expected-keys("fonts", value, expected-keys)
  }
}

#let check-custom-i18n(custom-i18n) = {
  if custom-i18n != none {
    check-type("custom-i18n", custom-i18n, (dictionary,))
    for lang in custom-i18n.keys() {
      check-type("custom-i18n." + str(lang), custom-i18n.at(lang), (dictionary,))
      let allowed-keys = (
        appendices: (str,),
        author: (str,),
        authors: (str,),
        index: (str,),
        ingredients: (str,),
        notes: (str,),
        preparation:  (str,),
        toc: (str,),
        page-numbering: (str,),
        page-ref-numbering: (str,),
        step-numbering: (str,)
      )
      check-allowed-keys("custom-i18n." + str(lang), custom-i18n.at(lang), allowed-keys)
    }
  }
}

#let check-style(value) = {
  if value != none {
    check-type("style", value, (str,))
    let ok = style.values().any(t => t == value)
    let expected-styles = style.values().map(v => "`"+ v+"`").join(" or ")
    assert(ok, message: 
      "Invalid parameter `style`.\n" +
      "  Received Value   : " + value + ")\n" +
      "  Expected Value in : " + expected-styles)
  }
}

#let check-palette(value) = {
  if value != none {
    check-type("palette", value, (dictionary,))
    let expected-keys = (
      dark: (color,),
      medium:  (color,),
      light:  (color,)
    )
  }
}

#let check-margin(value) = {
  if value != none {
    check-type("margin", value, (relative,dictionary))
    if type(value) == dictionary {
      let allowed-keys = (
        top: (relative, length),
        right: (relative, length),
        bottom: (relative, length),
        left: (relative, length),
        inside: (relative, length),
        outside: (relative, length),
        x: (relative, length),
        y: (relative, length),
        rest: (relative, length)
      )
      check-allowed-keys("margin", value, allowed-keys)
    }
  } 
}

#let check-custom-indexes(value) = {  
  if value != none {

    check-type("custom-indexes", value, (array,))
    
    let expected-keys = (
      title: (str, content),
      tags: (array,)
    )

    for elt in value {
      check-expected-keys("element in custom-indexes", elt, expected-keys)
    }
      
  }
}

#let check-cookbook(
  title,
  book-author,
  subtitle,
  date,
  paper,
  cover-image,
  custom-i18n,
  style,
  chapter-on-odd,
  palette,
  back-cover-content,
  back-cover-image,
  custom-indexes,
  custom-appendices,
  custom-cover,
  custom-back-cover,
  only-recipes,
  lang,
  margin,
  front-matter,
  back-matter,
  font-size,
  fonts,
  paper-width,
  paper-height
) = {
  check-type("title", title, (str, content))
  check-type("book-author", book-author, (str, content))
  check-type("subtitle", subtitle, (str, content))
  check-type("date", date, (datetime,))
  check-type("paper", paper, (str,))
  check-type("cover-image", cover-image, (content,), with-none: true)
  check-custom-i18n(custom-i18n)
  check-style(style)
  check-type("chapter-on-odd", chapter-on-odd, (bool,))
  check-palette(palette)
  check-type("back-cover-content", back-cover-content, (content,), with-none: true)
  check-type("back-cover-image", back-cover-image, (content,), with-none: true)
  check-custom-indexes(custom-indexes)
  check-type("custom-appendices", custom-appendices, (content,), with-none: true)
  check-type("custom-cover", custom-cover, (content,), with-none: true)
  check-type("custom-back-cover", custom-back-cover, (content,), with-none: true)
  check-type("only-recipes", only-recipes, (bool,))
  check-type("lang", lang, (str,), with-none: true)
  check-margin(margin)
  check-type("front-matter", front-matter, (content,), with-none: true)
  check-type("back-matter", back-matter, (content,), with-none: true)
  check-type("font-size", font-size, (length,), with-none: true)
  check-fonts(fonts)
  check-type("paper-width", paper-width, (length,), with-none: true)
  check-type("paper-height", paper-height, (length,), with-none: true)
}
