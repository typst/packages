#import "src/config.typ": *
#import "src/utils.typ": *
#import "src/intro.typ": *
#import "src/notion.typ": *


/// Change the synapse configuration.
///
/// - mode (str): Change the synapse mode, which affects how notions are displayed. "paper" mode is optimized for print and will display notions in default document text colors (the color related styles will be ignored), "electronic" mode is optimized for screens and will display notions in color, and "composition" mode display everything like "electronic" mode but also highlight notions with a light red background if they are not introduced yet and display anchors with red markers. The default mode is "composition".
/// - intro-style (function): A text function with any style arguments you want. This style will be applied to notions when they are introduced with the intro() function. The default intro-style is italic with a reddish fill color. Note that in "paper" mode, the fill and stroke styles will be ignored and set to none
/// - syn-style (function): A text function with any style arguments you want. This style will be applied to notions when they are used as synonyms with the syn() function. The default syn-style is bold with a blueish fill color. Note that in "paper" mode, the fill and stroke styles will be ignored and set to none
/// -> none
#let synapse-config(mode: "composition", intro-style: none, syn-style: none) = (
  context {
    _config.update(old => {
      let intro-style = if intro-style != none {
        intro-style
      } else {
        old.intro-style
      }
      let syn-style = if syn-style != none {
        syn-style
      } else {
        old.syn-style
      }
      if mode != "composition" and mode != "paper" and mode != "electronic" {
        panic("Invalid synapse mode: " + repr(mode) + ". Valid modes are: 'composition', 'paper' and 'electronic'")
      }
      return (mode: mode, intro-style: intro-style, syn-style: syn-style)
    })
  }
)


/// This function defines a notion, which is a concept that can be introduced and used as a synonym in the document. Each notion must have at least one synonym, which is the first positional argument. The notion can also have an optional URL and style. The URL makes the notion a link to an external resource, and the style allows you to customize how the notion is displayed when used as a synonym.
/// adding a % in the label name allows to scope the notion so it will be displayed the same but will be considered a different notion. This can be useful when you want to use the same term with different meanings in the same document. For example, you could define notion("set", "set%math") to have two different notions for the word "set", one for general use and one for mathematical use.
///
/// - url (str, none): If provided, the notion will be a link to the provided URL. The default is none, which means the notion should have an internal definition in the document. If url is provided, the notion will not be able to be introduced with the intro() function.
/// - style (function, none): A text function with any style arguments you want. The default is none, which means the notion will have the global default text style.
/// - synonyms: Any number of positional arguments can be provided as synonyms for the notion. Each synonym must be unique and cannot be used as a synonym for another notion.
/// -> content
#let notion(url: none, style: none, ..synonyms) = {
  if synonyms.named().len() > 0 {
    panic("Too many named arguments for notion: " + repr(synonyms.named()))
  }
  if synonyms.pos().len() == 0 {
    panic("At least one synonym must be provided for a notion")
  }
  _notions.update(old => {
    old.at(1).push(_new-notion(synonyms.pos().at(0), url, style))
    for synonym in synonyms.pos() {
      if synonym in old.at(0) {
        panic("Synonym already exists: " + synonym)
      }
      old.at(0).insert(synonym, old.at(1).len() - 1)
    }
    return old
  })
}

#let str-sy(notion, body) = (
  context {
    let notions = _notions.final()

    if notion not in notions.at(0) {
      let display = _get-notion-display(none, "syn-style", notion, body)
      if _config.get().mode == "composition" {
        return highlight(display, fill: rgb("#ff7171"))
      } else {
        return display
      }
    }

    let meta = _get-meta(notion)
    let display = _get-notion-display(meta, "syn-style", notion, body)

    if meta.url != none {
      link(meta.url, display)
    } else if not meta.introduced {
      if _config.get().mode == "composition" {
        highlight(display, fill: rgb("#ffcd71"))
      } else {
        display
      }
    } else {
      link(label(meta.repr), display)
    }
  }
)

/// This function is used to introduce a notion for the first time in the document. It takes a notion and an optional body. If the notion is a string, it will be introduced as is. The introduced notion will be displayed with the intro-style defined in the synapse configuration.
///
/// If the provided notion is a function, the remaining function arguments will be passed to the function. See syn-wrapper for more details on how to use this with functions.
///
/// If the notion has already been introduced before or if the notion has a URL, an error will be thrown to prevent introducing the same notion multiple times or introducing a notion that is meant to be used as a link to an external resource.
///
/// - ..args (str, content, function): The text notion to introduce and either a body or the additional parameter to the introduced function (see syn-wrapper()). 
/// -> content
#let intro(..args) = {
  if args.pos().len() == 0 {
    panic("At least one positional argument must be provided for intro")
  }
  let notion = args.pos().at(0)
  if type(notion) == function {
    let pargs = args.pos()
    pargs.remove(0)
    let nargs = args.named()
    nargs.insert(_notion-wrapper-arg-name, true)
    return notion(..pargs, ..nargs)
  }

  let body = if args.pos().len() > 1 {
    args.pos().at(1)
  } else {
    none
  }

  if type(notion) == str {
    return str-intro(notion, body)
  } else if type(notion) == content {
    if notion.func() == text {
      notion = notion.text
      return str-intro(notion.slice(2, -2), body)
    } else {
      panic("Unsupported content type for intro: " + repr(notion.func()))
    }
  } else {
    panic("Unsupported type for intro: " + type(notion))
  }
}

/// This function allows you to define an anchor point for a notion. It should be paired with an intro() call to work, else it won't have any effect. Once introduced, the notion will be linked here instead of the first introduction point. This is useful for instance when the notion is introduced in a paragraph but you want to link to the paragraph beginning instead of the notion itself. In composition mode, the anchor will be marked with a red marker to indicate that it is an anchor point for a notion. In paper and electronic modes, the anchor will not be visible but will still be linked to the notion introduction point.
///
///  - notion (str): The notion to introduce. This should be the name of a notion defined with the notion() function.
/// -> content
#let intro-ap(notion) = (
  context {
    if not _is-existing-notion(notion) {
      panic("Notion " + notion + " not found: " + repr(
        _notions.get().at(0).keys(),
      ))
    }
    let meta = _get-meta(notion)
    if meta.url != none {
      panic("Notion " + notion + " has a URL: " + meta.url + ", so it cannot be introduced")
    }
    if meta.introduced == true {
      panic("Notion " + notion + " has already been introduced, so it cannot be introduced again")
    }
    [
      #_intro-marker(notion)
      #_notions.update(old => {
        old.at(1).at(old.at(0).at(notion)).anchored = true
        return old
      })
      #label(meta.repr)
    ]
  }
)

/// This function is used to use a notion as a synonym in the document. It takes a notion as an argument. If the notion has been introduced before with the intro() function, it will link to the introduced notion. If the notion is not defined, in composition mode, it will be displayed with a highlight and a reddish fill to indicate that it is an undefined notion if in compose mode.
///
///  - ..args (str, content): The text notion to use as a synonym and an optional body. The body is used to change how the notion is displayed when used as a synonym.
/// -> content
#let syn(..args) = {
  if args.named().len() > 0 {
    panic("syn expects no named arguments, but got: " + repr(args.named()))
  }
  if args.pos().len() == 0 {
    panic("At least one positional argument must be provided for syn")
  }
  if args.pos().len() > 2 {
    panic("Too many positional arguments for syn: " + repr(args.pos()))
  }
  let notion = args.pos().at(0)
  let body = if args.pos().len() > 1 {
    args.pos().at(1)
  } else {
    none
  }
  if type(notion) == str {
    return str-sy(notion, body)
  } else if type(notion) == content {
    if notion.func() == text {
      notion = notion.text
      return str-sy(notion.slice(1, -1), body)
    } else {
      panic("Unsupported content type for syn: " + notion.type)
    }
  } else {
    panic("Unsupported type for syn: " + type(notion))
  }
}

/// This function is a wrapper for a notion that allows you to define how the notion should be displayed depending on the arguments passed. This function can also be used as an argument for the intro() function.
///
/// #example(```
/// #notion("abs")
///
/// #let abs = syn-wrapper("abs", (wrapper, value) => {
///  $wrapper(|)value#wrapper($|$)$
/// })
///
/// #intro(abs, $x$) is a function that returns the absolute value of $x$.\
/// For instance, $abs(-5)$ will return $5$ while $abs(42)$ will return the exact same value of $42$.
/// ```)
///
/// - notion (str): The notion to wrap. This should be the name of a notion defined with the notion() function.
/// - function (function): A function that takes at least a wrapper as argument and returns a content. The wrapper is a function that takes a content and applies either the intro-style or the syn-style to it depending on the context. The function can also take additional arguments, which will be passed when introduced or when used as a synonym.
/// -> function
#let syn-wrapper(notion, function) = (
  (..args) => {
    if _notion-wrapper-arg-name in args.named() and args
      .named()
      .at(_notion-wrapper-arg-name) == true {
      let named = args.named()
      let pos = args.pos()
      named.remove(_notion-wrapper-arg-name)
      return _labeled-intro(
        notion,
        function(_styled-intro.with(notion), ..pos, ..named),
      )
    }

    return function(str-sy.with(notion), ..args)
  }
)


/// Show rule to replace `"<notion>"` with `#syn(notion)` and `""<notion>""` with `#intro(notion)`
#let quote-rule(el) = {
  show regex("\"\"[^\"]+\"\""): it => intro(it)
  show regex("\"[^\"]+\""): it => syn(it)
  el
}
