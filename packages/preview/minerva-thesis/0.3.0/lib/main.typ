#import "@preview/subpar:0.2.2"
#import "@preview/abbr:0.3.1"
#import "@preview/hydra:0.6.3": hydra
#import "states.typ": *
#import "settings.typ": *
#import "utils.typ": *


// dictionary keys produced by split-pattern and named arguments of compose-pattern and add-chapter-number (except loc) should be the same

#let split-pattern(pattern) = {
  let counting = "[\u{0031}\u{0061}\u{0041}\u{0069}\u{0049}\u{03B1}\u{0391}\u{4E00}\u{58F9}\u{3042}\u{3044}\u{30A2}\u{30A4}\u{05D0}\u{AC00}\u{3131}\u{002A}\u{0661}\u{06F1}\u{0967}\u{09E7}\u{0995}\u{2460}\u{24F5}]"
  let not-counting = "[^\u{0031}\u{0061}\u{0041}\u{0069}\u{0049}\u{03B1}\u{0391}\u{4E00}\u{58F9}\u{3042}\u{3044}\u{30A2}\u{30A4}\u{05D0}\u{AC00}\u{3131}\u{002A}\u{0661}\u{06F1}\u{0967}\u{09E7}\u{0995}\u{2460}\u{24F5}]*"

  let prefix = pattern
    .match(regex("(" + not-counting + ")" + counting))
    .captures
    .at(0)
  pattern = pattern.slice(prefix.len())

  let suffix = pattern
    .match(regex(counting + "(" + not-counting + ")$"))
    .captures
    .at(0)
  if suffix.len() > 0 {
    pattern = pattern.slice(0, -suffix.len())
  }
  (numbering: pattern, prefix: prefix, suffix: suffix)
}

#let compose-pattern(prefix: none, numbering: none, suffix: none) = {
  prefix + numbering + suffix
}


#let get-el-suppl(terms, el, case: 0, default: auto) = {
  let the-term = terms.at(el, default: (:)).at("supplement", default: default)
  if type(the-term) == array { the-term.at(case, default: default) } else if (
    case == 0
  ) { the-term } else { default }
}

#let get-heading-term(terms, el, case: 0, default: auto) = {
  let the-term = terms.at(el, default: default)
  if type(the-term) == array { the-term.at(case, default: default) } else if (
    case == 0
  ) { the-term } else { default }
}


#let add-chapter-number(
  numbering: default-numbering,
  prefix: none,
  suffix: none,
  separator: default-separator,
  ..num,
  loc: auto,
) = {
  let the-loc = if loc == auto { here() } else { loc }
  let the-number = std.numbering(numbering, ..num)
  let new-number = if chapter-type.at(the-loc) != none {
    let the-numbering = heading-numbering
      .at(the-loc)
      .at(chapter-type.at(the-loc), default: (:))
      .at("numbering", default: "1.1")
    let the-chapter-number = std.numbering(
      the-numbering,
      counter(heading).at(the-loc).first(),
    )
    the-chapter-number + separator + the-number
  } else { the-number + "no chapter" }
  prefix + new-number + suffix
}

// TODO overal nagaan of show text: convert-text-arg(...) niet moet vervangen worden door show: convert-text-arg(...) of de functie convert-text-arg(...) manueel toepassen op stukken content // anders wordt bijv. math niet goed aangepast (geschaald)

#let convert-text-arg(targ, default: none) = {
  let the-fnctn = if type(targ) == dictionary { text.with(..targ) } else if (
    type(targ) == function
  ) { targ } else if type(targ) == array {
    targ
      .map(t => if type(t) == dictionary { text.with(..t) } else { t })
      .fold(t => t, (a, f) => t => f(a(t)))
  } else { t => t }

  if default != none {
    t => convert-text-arg(default)(the-fnctn(t))
  } else { the-fnctn }
}

#let figure-block(breakable: false, fill: auto, inset: auto, body) = {
  show figure: it => {
    show figure.caption: set block(breakable: false) if breakable
    let the-kind = if type(it.kind) == str { it.kind } else {
      str(repr(it.kind))
    }
    let the-figure-settings = figure-settings.get().at(store.get())
    let the-fill = if fill == auto {
      the-figure-settings.figure-fill.at(
        the-kind,
        default: the-figure-settings.figure-fill.at("rest"),
      )
    } else { fill }
    let the-inset = if inset == auto {
      if the-fill == none { 0pt } else {
        the-figure-settings.figure-inset.at(
          the-kind,
          default: the-figure-settings.figure-inset.at("rest"),
        )
      }
    } else { inset }
    if the-inset == 0pt and the-fill == none {
      show figure: set block(breakable: breakable)
      it
    } else {
      set block(breakable: breakable, fill: the-fill, inset: the-inset)
      show figure.caption: set block(fill: none, inset: 0pt)
      show table: set block(fill: none, inset: 0pt) // probably not needed
      show grid: set block(fill: none, inset: 0pt) // prevents that fill and inset are applied to the grid in m-subpar-grid
      show image: set block(fill: none, inset: 0pt) // probably not needed
      it
    }
  }
  body
}

#let m-figure(
  outline-caption: auto,
  caption: none,
  outlined: auto,
  label: none,
  breakable: false,
  fill: auto,
  inset: auto,
  body,
  ..args,
) = context {
  let the-outlined = if outlined == auto { figure.outlined } else { outlined }
  let the-figure
  let the-body = {
    set block(inset: 0pt, fill: none)
    body
  }
  if the-outlined and outline-caption != auto {
    {
      show figure: it => it.counter.update(v => (
        v - 1
      ))
      figure(body, ..args, outlined: true, caption: outline-caption)
    }
    the-figure = [#figure(
        the-body,
        ..args,
        caption: caption,
        outlined: false,
      ) #label]
  } else if label != none {
    the-figure = [#figure(
        the-body,
        ..args,
        outlined: the-outlined,
        caption: caption,
      ) #label]
  } else {
    the-figure = figure(
      the-body,
      ..args,
      outlined: the-outlined,
      caption: caption,
    )
  }
  figure-block(breakable: breakable, fill: fill, inset: inset, the-figure)
}

#let m-subpar(
  kind: image,
  outline-caption: auto,
  caption: none,
  outlined: auto,
  label: none,
  breakable: false,
  fill: auto,
  inset: auto,
  show-sub: auto,
  show-sub-caption: auto,
  numbering: auto, // should not be set!
  numbering-sub: auto,
  numbering-sub-ref: auto, // should not be set!
  breakable-sub: false,
  subfigure-caption-position: auto,
  subfigure-caption-align: auto,
  subfigure-caption-text-align: auto,
  subfigure-caption-sep: auto,
  subfigure-numbering: auto,
  subfigure-ref-numbering: auto,
  subfigure-caption-text: auto,
  subfigure-caption-prefix-text: auto,
  subpar-function: subpar.super,
  ..args,
) = context {
  let the-outlined = if outlined == auto { figure.outlined } else { outlined }
  let the-figure
  let the-kind = if type(kind) == str { kind } else { str(repr(kind)) }
  let the-figure-settings = figure-settings.get().at(store.get())

  let the-supplement = get-el-suppl(
    terminologies.get().at(store.get()),
    "figure-" + the-kind,
  )

  let the-show-sub = if show-sub == auto {
    it => {
      set block(inset: 0pt, fill: none, breakable: breakable-sub)
      set figure.caption(position: if subfigure-caption-position == auto {
        the-figure-settings
          .subfigure-caption-position
          .at(
            the-kind,
            default: the-figure-settings.subfigure-caption-position.at("rest"),
          )
      } else { subfigure-caption-position })
      it
    }
  } else { show-sub }

  let the-show-sub-caption = if show-sub-caption == auto {
    (num, it) => {
      set align(if subfigure-caption-align == auto {
        the-figure-settings.subfigure-caption-align.at(
          the-kind,
          default: the-figure-settings.subfigure-caption-align.at("rest"),
        )
      } else { subfigure-caption-align })

      let the-prefix = {
        show: if subfigure-caption-prefix-text == auto {
          the-figure-settings
            .subfigure-caption-prefix-text
            .at(
              the-kind,
              default: the-figure-settings
                .subfigure-caption-prefix-text
                .at("rest"),
            )
        } else { convert-text-arg(subfigure-caption-prefix-text) } // niet show text: ... !
        num
        if it.body != [] {
          if subfigure-caption-sep == auto {
            the-figure-settings.subfigure-caption-sep.at(
              the-kind,
              default: the-figure-settings.subfigure-caption-sep.at("rest"),
            )
          } else { subfigure-caption-sep }
        }
      }
      let the-subfigure-caption-text-align = if (
        subfigure-caption-text-align == auto
      ) {
        the-figure-settings
          .subfigure-caption-text-align
          .at(
            the-kind,
            default: the-figure-settings
              .subfigure-caption-text-align
              .at("rest"),
          )
      } else { subfigure-caption-text-align }
      let the-caption = if the-subfigure-caption-text-align == "indent" {
        table(
          column-gutter: 0.15em,
          stroke: none,
          inset: 0pt,
          align: (right + top, left + top),
          columns: 2,
          the-prefix, it.body,
        )
      } else if type(the-subfigure-caption-text-align) == alignment {
        box(align(the-subfigure-caption-text-align, the-prefix + it.body))
      } else { the-prefix + it.body }

      show: if subfigure-caption-text == auto {
        the-figure-settings.subfigure-caption-text.at(
          the-kind,
          default: the-figure-settings.subfigure-caption-text.at("rest"),
        )
      } else { convert-text-arg(subfigure-caption-text) } // niet show text: ... !
      the-caption
    }
  } else { show-sub-caption }

  let the-subfigure-num = if subfigure-numbering == auto {
    the-figure-settings.subfigure-numbering.at(
      the-kind,
      default: the-figure-settings.subfigure-numbering.at("rest"),
    )
  } else { subfigure-numbering }
  let the-subfigure-ref-num = if subfigure-ref-numbering == auto {
    the-figure-settings.subfigure-ref-numbering.at(
      the-kind,
      default: the-figure-settings.subfigure-ref-numbering.at("rest"),
    )
  } else { subfigure-ref-numbering }

  let the-fig-numbering = the-figure-settings.figure-numbering.at(
    the-kind,
    default: the-figure-settings.figure-numbering.at("rest", default: (
      numbering: default-numbering,
    )),
  )

  let the-numbering = if numbering == auto {
    // if only numbering functions (**) :
    //       the-figure-settings.numbering-function.with(numbering: the-figure-settings.figure-numbering.at(the-kind, default: the-figure-settings.figure-numbering.rest ) )
    //  else
    if type(the-figure-settings.numbering-function) == function {
      the-figure-settings.numbering-function.with(..the-fig-numbering)
    } else { compose-pattern(..the-fig-numbering) }
  } else { numbering }

  let the-numbering-sub = if numbering-sub == auto {
    (..num) => std.numbering(the-subfigure-num, num.pos().last())
  } else { numbering-sub }

  let the-numbering-sub-ref = if numbering-sub-ref == auto {
    (ifig, isubfig) => {
      if numbering == auto {
        if type(the-figure-settings.numbering-function) == function {
          (
            the-fig-numbering.at("prefix", default: none)
              + (the-figure-settings.numbering-function)(
                numbering: the-fig-numbering.numbering,
                ifig,
              )
              + std.numbering(the-subfigure-ref-num, isubfig)
              + the-fig-numbering.at("suffix", default: none)
          )
        } else {
          (
            the-fig-numbering.at("prefix", default: none)
              + std.numbering(
                the-fig-numbering.at("numbering", default: default-numbering),
                ifig,
              )
              + std.numbering(the-subfigure-ref-num, isubfig)
              + the-fig-numbering.at("suffix", default: none)
          )
        }
      } else {
        if type(numbering) == str {
          let the-pattern = split-pattern(numbering)
          (
            the-pattern.at("prefix", default: none)
              + std.numbering(
                the-pattern.at("numbering", default: default-numbering),
                ifig,
              )
              + std.numbering(the-subfigure-ref-num, isubfig)
              + the-pattern.at("suffix", default: none)
          )
        } else {
          (
            std.numbering(numbering, ifig)
              + std.numbering(the-subfigure-ref-num, isubfig)
          )
        }
      }
    }
  } else { numbering-sub-ref }

  set figure(placement: none) if breakable
  if the-outlined and outline-caption != auto {
    {
      show figure: it => it.counter.update(v => v - 1)
      subpar-function(
        numbering: the-numbering,
        kind: kind,
        supplement: the-supplement,
        ..args,
        outlined: true,
        caption: outline-caption,
      )
    }
    the-figure = subpar-function(
      kind: kind,
      show-sub: the-show-sub,
      show-sub-caption: the-show-sub-caption,
      numbering: the-numbering,
      numbering-sub: the-numbering-sub,
      numbering-sub-ref: the-numbering-sub-ref,
      supplement: the-supplement,
      ..args,
      label: label,
      caption: caption,
      outlined: false,
    )
  } else {
    the-figure = subpar-function(
      kind: kind,
      show-sub: the-show-sub,
      show-sub-caption: the-show-sub-caption,
      numbering: the-numbering,
      numbering-sub: the-numbering-sub,
      numbering-sub-ref: the-numbering-sub-ref,
      supplement: the-supplement,
      ..args,
      outlined: the-outlined,
      label: label,
      caption: caption,
    )
  }
  figure-block(
    breakable: breakable,
    fill: fill,
    inset: inset,
    the-figure,
  )
}

#let m-subpar-super = m-subpar.with(subpar-function: subpar.super)
#let m-subpar-grid = m-subpar.with(subpar-function: subpar.grid)

#let set-header-title(title)={
  header-title.update(title)
}

#let convert-figure-arg(
  arg,
  default: none,
  auto-value: none,
  figure-kinds: (),
) = {
  let the-kinds = ("image", "table", "raw", "rest") + figure-kinds

  let are-kinds = false
  if type(arg) == dictionary {
    let keys = arg.keys()
    let i = 0
    while (not are-kinds) and i < arg.len() {
      if keys.at(i) in the-kinds { are-kinds = true }
      i += 1
    }
  }

  if type(arg) == dictionary and (are-kinds) {
    let the-arg = (rest: default)
    for (key, value) in arg {
      the-arg.insert(key, if value == auto { auto-value } else { value })
    }
    the-arg
  } else if arg == auto {
    (rest: auto-value)
  } else {
    (rest: arg)
  }
}

#let convert-figure-text-arg(arg, default: none, figure-kinds: ()) = {
  let the-kinds = ("image", "table", "raw", "rest") + figure-kinds

  let are-kinds = false
  if type(arg) == dictionary {
    for key in arg.keys() {
      if key in the-kinds { are-kinds = true }
    }
  }

  let the-arg = if type(arg) == dictionary and (are-kinds) {
    (rest: auto) + arg
  } else if arg == auto {
    (rest: auto)
  } else {
    (rest: arg)
  }

  let the-args = (:)

  let default-fnctn = convert-text-arg(default)
  for (kind, value) in the-arg {
    the-args.insert(kind, t => default-fnctn(convert-text-arg(value)(t)))
  }
  the-args
}


#let compose-locale(language, region: auto)={
  let the-region=if region==auto {default-region.at(language, default: none)} else {region}
  lower(language)+if the-region!=none {locale-sep+upper(the-region)}
}

#let locales=state("locales",(m: compose-locale(default-language))) // must be initialised, otherwise problems with getting current locale
// #let locales=state("locales",(m: "nl-BE"))
// #let locales=state("locales",(:))

#let current-locale()={locales.get().at(store.get(), default: none)}

#let set-locale(locale, store: none)= body => {
  locales.update(it => {
    it.insert(store, locale.locale)
    it
    }
  )
  set text(
      lang: locale.language,
      region: locale.region,
  )
  body
}

#let split-locale(locale, region: auto)={
  let the-locale=(if type(locale)==str {locale}  else {current-locale()})
  if the-locale!=none {
    the-locale=the-locale.split(locale-sep)
    let language=the-locale.at(0)
    let region=if the-locale.len()>1 {the-locale.at(1)} else { if region==auto  {default-region.at(language, default: none)} else {region}  }
    (language: language,  region: region, locale: compose-locale(language, region: region))
  } /*else {
    split-locale(locales.get().at("m")) // if current-locale() is not found, then the default locale (m)
  }*/
}


#let localise(item, locale: auto, final: true)={
//   let not-found=(found:false)
  let is-locale(dict)={
    let is-loc=dict.len()>0
    for key in dict.keys() {
      is-loc=is-loc and (key.len()==2 or (key.len()==5 and key.at(2)==locale-sep))
    }
    is-loc
  }


  let the-locale=split-locale(locale)
  let localised= if type(item)==dictionary {
    if is-locale(item) {
      if the-locale.locale in item {
        localise(item.at(the-locale.locale), locale: the-locale.locale, final: false )
      } else if the-locale.region!=none and the-locale.language in item {
        localise(item.at(the-locale.language), locale: the-locale.locale, final: false)
      } else { (found:false) }
    } else {
      let dict=(:)
      for (key,value) in item {
        value=localise(value, locale: the-locale.locale, final: false)
        if value.found  {dict.insert(key,value.value)}
      }
      (found: true, value: dict)
    }
  } else if type(item)==array {
      (found: true, value: item.map(it=>localise(it, locale: the-locale.locale)) )
  } else {
    (found: true, value: item)
  }
  if final {if localised.found {localised.value} else {none}} else {localised}
}


#let set-figures(
  base-font: none,
  base-font-size: none,
  figure-kinds: (),
  figure-text: auto,
  figure-fill: auto,
  figure-inset: default-figure-inset,
  figure-numbering: "1",
  numbering-function: none,
  separator: default-separator,
  caption-align: center,
  caption-text-align: "indent",
  caption-separator: default-caption-separator,
  caption-text: auto,
  caption-prefix-text: default-caption-prefix-text,
  caption-position: default-caption-position,
  subfigure-caption-position: top,
  subfigure-caption-align: auto,
  subfigure-caption-text-align: auto,
  subfigure-caption-sep: auto,
  subfigure-numbering: default-subfigure-numbering,
  subfigure-ref-numbering: auto,
  subfigure-caption-text: auto,
  subfigure-caption-prefix-text: auto,
  figure-ref-text: none,
  store: none,
) = body => {
  let the-convert-figure-text-arg = convert-figure-text-arg.with(
    figure-kinds: figure-kinds,
  )
  let the-convert-figure-arg = convert-figure-arg.with(
    figure-kinds: figure-kinds,
  )

  let the-figure-numbering = the-convert-figure-arg(
    figure-numbering,
    default: default-numbering,
  )
  //  ** convert numbering pattern to function =>  only numbering functions :
  //   let the-numbering-function=if type(numbering-function)==function {numbering-function} else {(..num, numbering: none, loc: none)=>std.numbering(numbering,..num)}
  //   let the-numbering-function=if type(numbering-function)==function {numbering-function} else {(..num, numbering: none)=>std.numbering(numbering,..num)
  let the-separator = the-convert-figure-arg(separator, default: (
    numbering: default-separator,
  )) // there is only one separator for any kind of figures and equations, but let's treat it like the other arguments

  let the-caption-position = the-convert-figure-arg(
    caption-position,
    default: bottom,
  )

  let the-font = if base-font != none { (font: base-font) } else { (:) }
  let the-font-size = if type(base-font-size) == length {
    (size: base-font-size)
  } else { (:) }

  let the-figure-text = the-convert-figure-text-arg(
    figure-text,
    default: the-font + the-font-size,
  )
  let the-caption-text = the-convert-figure-text-arg(
    caption-text,
    default: the-font + the-font-size,
  )
  let the-caption-prefix-text = the-convert-figure-text-arg(caption-prefix-text)
  let the-caption-align = the-convert-figure-arg(caption-align, default: center)
  let the-caption-text-align = the-convert-figure-arg(
    caption-text-align,
    default: "indent",
  )
  let the-caption-separator = the-convert-figure-arg(
    caption-separator,
    default: default-caption-separator,
  )
  let the-subfigure-numbering = the-convert-figure-arg(
    subfigure-numbering,
    default: default-subfigure-numbering,
  )

  let the-orig = the-figure-numbering
  for (kind, num) in the-figure-numbering {
    if type(num) == str {
      the-figure-numbering.insert(kind, split-pattern(num))
    }
  }

  figure-settings.update(
    it => {
      it.insert(store, (
        //         base-font: base-font,
        //         base-font-size: base-font-size,
        figure-kinds: figure-kinds,
        figure-text: the-figure-text,
        figure-fill: the-convert-figure-arg(
          figure-fill,
          auto-value: default-figure-fill,
        ), // if figure-fill==auto{default-figure-fill} else {figure-fill},
        figure-inset: the-convert-figure-arg(
          figure-inset,
          default: default-figure-inset,
          auto-value: default-figure-inset,
        ),
        figure-numbering: the-figure-numbering,
        separator: the-separator,
        // if only numbering functions (**) :
        //         numbering-function: the-numbering-function,
        // else:
        numbering-function: numbering-function,
        caption-position: the-caption-position,
        caption-align: the-caption-align,
        caption-text-align: the-caption-text-align,
        caption-separator: the-caption-separator,
        caption-text: the-caption-text,
        caption-prefix-text: the-caption-prefix-text,
        subfigure-caption-position: the-convert-figure-arg(
          subfigure-caption-position,
          default: top,
        ),
        subfigure-caption-align: if subfigure-caption-align == auto {
          the-caption-align
        } else {
          the-convert-figure-arg(subfigure-caption-align, default: center)
        },
        subfigure-caption-text-align: if subfigure-caption-text-align == auto {
          the-caption-text-align
        } else {
          the-convert-figure-arg(
            subfigure-caption-text-align,
            default: "indent",
          )
        },
        subfigure-caption-sep: if subfigure-caption-sep == auto {
          the-caption-separator
        } else {
          the-convert-figure-arg(
            subfigure-caption-sep,
            default: default-caption-separator,
          )
        },
        subfigure-numbering: the-subfigure-numbering,
        subfigure-ref-numbering: if subfigure-ref-numbering == auto {
          the-subfigure-numbering
        } else {
          the-convert-figure-arg(
            subfigure-ref-numbering,
            default: default-subfigure-numbering,
          )
        },
        subfigure-caption-text: if subfigure-caption-text == auto {
          the-caption-text
        } else { the-convert-figure-text-arg(subfigure-caption-text) },
        subfigure-caption-prefix-text: if subfigure-caption-prefix-text
          == auto { the-caption-prefix-text } else {
          the-convert-figure-text-arg(subfigure-caption-prefix-text)
        },
        figure-ref-text: the-convert-figure-text-arg(figure-ref-text),
      ))
      it
    },
  )
  // if only numbering functions (**) :
  //   set figure(numbering: the-numbering-function.with(numbering: the-figure-numbering.remove("rest", default: default-numbering)))
  // else:
  set figure(numbering: if type(numbering-function) == function {
    numbering-function.with(
      ..the-figure-numbering.remove("rest", default: (
        numbering: default-numbering,
      )),
      separator: the-separator.remove("rest", default: default-separator),
    )
  } else {
    compose-pattern(..the-figure-numbering.remove("rest", default: (
      numbering: default-numbering,
    )))
  })

  set figure.caption(position: the-caption-position.remove(
    "rest",
    default: bottom,
  ))

  let the-default-figure-text = the-figure-text.remove("rest", default: none)
  if type(the-default-figure-text) == function {
    body = {
      show figure: the-default-figure-text
      body
    }
  }

  let elfunc = (image: image, table: table, raw: raw)

  // de volgende zaken kunnen niet meer in een show-rule (als een functie) van een figure/figure.caption ingesteld worden en moeten dus op voorhand gebeuren.

  show: the-figure-numbering
    .pairs()
    .map(((kind, num)) => body => {
      show figure.where(kind: elfunc.at(kind, default: kind)): set figure(
        numbering: if type(numbering-function) == function {
          numbering-function.with(..num, separator: separator)
        } else { compose-pattern(..num) },
      )
      body
    })
    .fold(b => b, (a, f) => b => f(a(b)))

  show: the-caption-position
    .pairs()
    .map(((kind, pos)) => body => {
      show figure.where(kind: elfunc.at(
        kind,
        default: kind,
      )): set figure.caption(position: pos)
      body
    })
    .fold(b => b, (a, f) => b => f(a(b)))

  show: the-figure-text
    .pairs()
    .filter(((kind, tfnctn)) => type(tfnctn) == function)
    .map(
      ((kind, tfnctn)) => body => {
        show figure.where(kind: elfunc.at(kind, default: kind)): tfnctn
        body
      },
    )
    .fold(b => b, (a, f) => b => f(a(b)))

  body
}



#let set-equations(
  math-font: auto,
  math-font-size: auto,
  //       base-font-size: none,
  equation-numbering: auto,
  numbering-function: none,
  equation-left-margin: auto,
  separator: default-separator,
  store: none,
  ..args,
) = body => {
  show math.equation: set text(font: math-font) if math-font != auto
  show math.equation: set text(size: math-font-size) if (
    type(math-font-size) == length
  )
  show math.equation.where(block: true): set align(if equation-left-margin
    == auto { center } else { left })
  show math.equation.where(block: true): set block(inset: (
    left: equation-left-margin,
  )) if type(equation-left-margin) in (relative, length, ratio)
  let the-equation-numbering = if equation-numbering == auto {
    "(" + default-numbering + ")"
  } else { equation-numbering }
  let the-numbering-pattern
  if type(the-equation-numbering) == str {
    the-numbering-pattern = the-equation-numbering
    the-equation-numbering = split-pattern(the-equation-numbering)
  } else {
    the-numbering-pattern = compose-pattern(..the-equation-numbering)
  }
  set math.equation(numbering: if type(numbering-function) == function {
    numbering-function.with(
      ..the-equation-numbering,
      separator: separator,
    )
  } else { the-numbering-pattern })

  equation-settings.update(
    it => {
      it.insert(
        store,
        (
          equation-numbering: the-equation-numbering,
          numbering-function: numbering-function,
          separator: separator,
        ), // + args.named() // allows to call set-equations with a set of equation settings as arguments, currently not needed
      )
      it
    },
  )

  body
}
}

#let set-terminology(
  terminology,
  store: none,
  figure-kinds: (),
) = body => {
  let the-term

  let terminology = terminology

  the-term = get-el-suppl(terminology, "figure-image")
  show figure.where(kind: image): set figure(supplement: the-term) if (
    the-term != auto
  )

  the-term = get-el-suppl(terminology, "figure-table")
  show figure.where(kind: table): set figure(supplement: the-term) if (
    the-term != auto
  )

  the-term = get-el-suppl(terminology, "figure-raw")
  show figure.where(kind: raw): set figure(supplement: the-term) if (
    the-term != auto
  )

  the-term = get-el-suppl(terminology, "math-equation")
  set math.equation(supplement: the-term) if the-term != auto

  the-term = get-heading-term(terminology, "section")
  set heading(supplement: the-term) if the-term != auto

  the-term = get-heading-term(terminology, "bibliography")
  set bibliography(title: the-term) if the-term != auto

  if type(figure-kinds) == array {
    for kind in figure-kinds {
      the-term = get-el-suppl(terminology, "figure-" + kind)
      body = {
        show figure.where(kind: kind): set figure(supplement: the-term)
        body
      }
    }
  }

  terminologies.update(
    it => {
      it.insert(store, terminology)
      it
    },
  )

  body
}

#let set-page-number-width(pg-width) = {
  page-number-width.update(pg-width)
}

#let hide-page-number = { // page number on the current page (does not affect page number in the ToC)
  page-number-on-page.update(false)
}

#let hide-page-header ={
  header-on-page.update(false)
}

#let show-headers(switch)={
  show-header.update(switch)
}

#let show-page-numbers(switch)={  // both on the page itself and in the ToC
  show-page-number.update(switch)
}

#let start-at-odd-page(weak: true) = {
  content-switch.update(false) // used to omit page number and header on inserted blank page and omit header on the next (odd) page
  pagebreak(weak: weak, to: "odd")
  content-switch.update(true)
  page-number-on-page.update(true)
}

#let double-blank-page={
  start-at-odd-page(weak:false)
  hide-page-number
  start-at-odd-page(weak:false)
}

#let part-number = counter("part")

#let part(title, page-number: false, label: none) = context {
  if not page-number {show-page-numbers(false)}
  // supplement is needed to detect a part in the ref show-rule. The number is stored in part-number.
  show heading.where(level: 1): set heading(
    numbering: none,
    supplement: get-heading-term(
      terminologies.get().at(store.get()),
      "part",
      default: "Part",
    ),
  )
  part-number.step()
  context {
    // a heading for the Table of Contents only. start-at-odd-page is needed for right location in ToC
    show heading: it => { start-at-odd-page() }
    heading[#capitalise(get-heading-term(
        terminologies.get().at(store.get()),
        "part",
        default: "Part",
      )) #part-number.display(part-num.get()) -- #title]
  }
  part-heading.update(true) // see heading show-rule
  [ #heading(title, outlined: false, bookmarked: false) #if label != none {
      label
    } ]
  start-at-odd-page()
  if not page-number {show-page-numbers(true)}
  part-heading.update(false)
}


#let thesis(
  authors: none,
  title: none,
  keywords: none,
  description: none,
  language: "en",
  region: auto,
  faculty: none,
  supervisors: none,
  multiple-supervisors: auto,
  counsellors: none,
  multiple-counsellors: auto,
  date: none,
  terminology: (:),
  paper: none,
  page-width: 160mm,
  page-height: 240mm,
  page-margin: auto,
  font: auto,
  font-size: 11pt,
  header-heading-levels: (even: 1, odd: 2),
  header-text: none,
  header-prefix-text: none,
  header-separator: [ -- ],
  chapter-title-text: auto,
  chapter-show: auto,
  chapter-number-text: auto,
  chapter-number-align: right,
  chapter-title-align: right,
  part-title-text: auto,
  part-number-text: auto,
  part-numbering: "I",
  chapter-numbering: "1.1",
  appendix-numbering: "A.1",
  equation-numbering: "(1)",
  figure-numbering: "1",
  per-chapter-numbering: true,
  math-font: auto,
  math-font-size: auto,
  equation-left-margin: auto,
  figure-kinds: (:),
  figure-fill: none, // auto = default-figure-fill
  figure-inset: 0.5em, // default-figure-inset
  figure-text: auto,
  caption-position: (table: top, rest: bottom), // = default-caption-position
  caption-align: center,
  caption-text-align: "indent",
  caption-separator: sym.colon + sym.space, // = default-caption-separator, not [: ] because caption may be set via table which "eats" the space
  caption-text: none,
  caption-prefix-text: (weight: "semibold"), // = default-caption-prefix-text
  subfigure-numbering: "a", // default-subfigure-numbering
  subfigure-ref-numbering: auto,
  subfigure-caption-position: top,
  subfigure-caption-align: auto,
  subfigure-caption-text-align: auto,
  subfigure-caption-sep: auto,
  subfigure-caption-text: auto,
  subfigure-caption-prefix-text: auto,
  figure-ref-text: none,
  body,
) = {
  let the-store = "m"

  store.update(the-store)

  let locale = split-locale(language, region: region)
//   set-locale(locale.locale, store: the-store)



  let the-localise = localise.with(locale: locale.locale)
  let the-terminology = the-localise(default-terminology)

  let the-figure-kinds = (:)

  // user-defined figure kinds are stored in the terminology with key figure-<kind>
  for (key, value) in figure-kinds {
    the-figure-kinds.insert("figure-" + key, value)
  }

  // update the terminology, possibly for different languages for use in title-page, abstract or in change-locale, original value = default-values
  // the dictionaries should have the same format with respect to localisation as the original  terminology-defaults, eg.
  //   math-equation: (
  //     supplement: (
  //       en: ("Equation","Equations"),
  //       nl: ("Vergelijking","Vergelijkingen")
  //     ),
  //     outline-title: (
  //       en: "List of Equations",
  //       nl: "Lijst van vergelijkingen"
  //     )
  //   )
  //   don't merge this with:
  //   math-equation: (
  //     nl: (supplement: ("Formule","Formules"),
  //          outline-title: "List of Equiations"
  //     )
  //   )

  terminology-defaults.update(it => merge-dictionaries(it, merge-dictionaries(
    terminology,
    the-figure-kinds,
  )))
  the-terminology = merge-dictionaries(the-terminology, merge-dictionaries(
    the-localise(terminology),
    the-localise(the-figure-kinds),
  ))

  let the-figure-kind-names = figure-kinds.keys() // names of user-defined figure kinds (without the prefix "figure-")

  let the-chapter-show() = if chapter-show == auto {
      part-number.final().first() > 0
  } else { chapter-show }

  abbr.config(style: it => { it })

  let the-multiple-supervisors
  let the-multiple-counsellors

  if authors != none { thesis-authors.update(authors) }
  if title != none { thesis-title.update(title) }
  if description != none { thesis-description.update(description) }
  if faculty != none { thesis-faculty.update(faculty) }
  if supervisors != none { thesis-supervisors.update(supervisors) }
  if multiple-supervisors == auto {
    if type(supervisors) == array {
      the-multiple-supervisors = supervisors.len() > 1
    } else { the-multiple-supervisors = false }
  } else { the-multiple-supervisors = multiple-supervisors }
  if type(the-multiple-supervisors) == bool {
    thesis-multiple-supervisors.update(the-multiple-supervisors)
  }
  if counsellors != none { thesis-counsellors.update(counsellors) }
  if multiple-counsellors == auto {
    if type(counsellors) == array {
      the-multiple-counsellors = counsellors.len() > 1
    } else { the-multiple-counsellors = false }
  } else { the-multiple-counsellors = multiple-counsellors }
  if type(the-multiple-counsellors) == bool {
    thesis-multiple-counsellors.update(the-multiple-counsellors)
  }

  if date != none { thesis-date.update(date) }
  if keywords != none { thesis-keywords.update(keywords) }

  set text(font: font) if font != auto
  set text(size: font-size) if type(font-size) == length

//   set text(
//     lang: locale.language,
//     region: locale.region,
//   )

  set par(justify: true)
  set list(indent: 0.5em)
  set enum(indent: 0.5em)

  set page(paper: paper) if paper != none
  set page(width: page-width, height: page-height) if paper == none

  let has-header = header-heading-levels != none
  let the-levels = if has-header {
    if type(header-heading-levels) == dictionary {
      header-heading-levels
    } else { (even: header-heading-levels, odd: header-heading-levels) }
  }

// Controle van het tonen van paginanummers en headers bij een pagebreak via boolean state ("switch") content-switch
// paginanummer en headers worden geregeld via  page-number-on-page en header-on-page
// content-switch  wordt ingesteld in start-at-odd-page()
// Bij een pagebreak() met daarop volgend een state-update, wordt de state-update maar uitgevoerd op de nieuwe pagina, dus nadat de header op die pagina al is gezet. In de header van die pagina zijn de vroegere state nog actief.
// start-at-odd-page()  zet content-switch false van de huidige pagina tot en met de header van de eerstvolgende oneven pagina
// In de footer van huidige en evt. de ingevoegde even pagina wordt  page-number-on-page en header-on-page op false gezet zodat op de volgende pagina geen paginanummer en header worden gezet. Op de eerstvolgende oneven pagina wordt page-number-on-page wel terug aangezet.
// Om header en paginanummer beide terug aan te zetten op eerstvolgende oneven pagina, de content-switch weer aanzetten in de footer (nu als comment hieronder)

  set page(
    margin: if page-margin == auto {
      (
        top: if has-header { 20mm } else { 15mm },
        bottom: 15mm,
        inside: 25mm,
        outside: 15mm,
      )
    } else { page-margin },
    header: context {
      if has-header and show-header.get() and header-on-page.get() {
        let the-align
        let the-level
        let highest(level) = {
//        let the-hydra = hydra(book: true, skip-starting: false, level)
          let the-hydra=hydra(
            book:true,
            skip-starting: false,
            display: (ctx,cand) => {
                if cand.at("numbering", default:none) != none {
                  show: convert-text-arg(header-prefix-text)
                  if level==1 and the-chapter-show() and cand.at("supplement", default:none) != none  {
                    cand.at("supplement")
                    [ ]
                  }
                  numbering(cand.numbering, ..counter(heading).at(cand.location()))
                  header-separator
                }
                let the-custom-title=header-title.at(cand.location())
                if the-custom-title!=auto {
                  the-custom-title
                } else {
                  cand.body
                }
            },
            level
          )
          if the-hydra == none and level > 1 { highest(level - 1) } else { the-hydra }
        }
        if calc.odd(counter(page).get().first()) {
          the-align = right
          the-level = the-levels.at("odd", default: 2)
        } else {
          the-align = left
          the-level = the-levels.at("even", default: 1)
        }
        set par(leading: 0.5em)
        //         show text: convert-text-arg(header-text)
        align(the-align, block(
          width: 100%,
          stroke: (bottom: 0.5pt),
          inset: (bottom: 0.5em),
//           convert-text-arg(header-text)(highest(the-level))
          convert-text-arg(header-text)(
            if store.get().match(regex("^ea-")) != none {
              if type(header-title.get()) in (content,str) {header-title.get()}
            } else {
              highest(the-level)
            })
        ))
      }
//       else { repr(content-switch.get())+[ ]+repr(header-on-page.get()) } // debug
      header-on-page.update(true) // The default (for the next page) is true.
    },
    footer: context {
      if page.numbering !=none and show-page-number.get() and page-number-on-page.get() {
          align(
            if calc.odd(counter(page).get().first()) { right } else { left },
            counter(page).display(),
          )
      }
      if not content-switch.get() { // content-switch can be set false by start-at-odd-page()
        page-number-on-page.update(false) // no page number on the next page (if inserted)
        header-on-page.update(false) // no page number on the next page (if inserted)
      } else {
        page-number-on-page.update(true) // The default (for the next page) is true.
      }
//       content-switch.update(true) // If page numbers and headers should be switched on again on first page after start-at-odd-page()
    },
  )

  show figure.caption: it => {
    let the-kind = if type(it.kind) == str { it.kind } else {
      str(repr(it.kind))
    }
    let settings = figure-settings.get().at(store.get())
    set align(settings.caption-align.at(
      the-kind,
      default: settings.caption-align.at("rest"),
    ))

    let the-prefix = {
      show: settings.caption-prefix-text.at(
        the-kind,
        default: settings.caption-prefix-text.at("rest"),
      ) // niet show text: ...
      it.supplement
      sym.space.nobreak
      it.counter.display(it.numbering)
      //       it.separator // zou ook kunnen ingesteld worden met show figure.where(...): set figure(separator: ...) in setfigures()
      settings.caption-separator.at(
        the-kind,
        default: settings.caption-separator.at("rest"),
      )
    }

    let the-caption-text-align = settings.caption-text-align.at(
      the-kind,
      default: settings.caption-text-align.at("rest"),
    )

    let the-caption = if the-caption-text-align == "indent" {
      table(
        column-gutter: 0.15em,
        stroke: none,
        inset: 0pt,
        align: (right, left),
        columns: 2,
        the-prefix, it.body,
      )
    } else if type(the-caption-text-align) == alignment {
      // de caption text op zich ook nog aligneren (los van caption-align), bijv. bij een caption-align=center en caption-text-align=left zou een korte caption gecentereerd zijn en een caption over meerdere lijnen links gealigneerd
      box(align(the-caption-text-align, the-prefix + it.body))
    } else {
      the-prefix + it.body
    }

    // niet show text: ... want dan is table niet altijd goed (prefix wat hoger dan body van de caption)  (dit komt blijkbaar door het instellen van figure-text)
    show: settings.caption-text.at(
      the-kind,
      default: settings.caption-text.at("rest"),
    )
    the-caption
  }

  part-num.update(part-numbering)
  heading-numbering.update(
    (
      chapter: split-pattern(chapter-numbering),
      appendix: split-pattern(appendix-numbering),
    ),
  )

  show ref: it => {
    if it.form == "normal" {
      let el = it.element

      let the-supplement
      let empty-supplement = false
      let target-terminology
      let ref-terminology
      let ref-store
      let target-store
      let el-function

      if el != none {
        ref-store = store.get()
        target-store = store.at(el.location())
        target-terminology = terminologies.get().at(target-store, default: (:))
        ref-terminology = terminologies.get().at(ref-store, default: (:))
        el-function = el.func()
      }

      //       // als het supplement op none is gezet (met een set-rule voor math.equation (of voor andere??) ), is el.supplement=[] (en niet none)
      //       // Het al dan niet toevoegen / verwijderen van haakjes wordt dus bepaald door [] of niet [] -> empty-supplement
      //       // Toch haakjes weghalen bij leeg supplement kan door supplement op none of "" te zetten (= iets leegs, maar niet [])
      //       // -> in dat geval wel de spatie na het lege supplement niet toeveogen (zie lijn onder (2))
      //
      //       // (1) haakjes behouden bij patroon met haakjes als supplement=[] is. (Haakjes worden door standaard ref indien nummering een patroon is verwijderd.)
      //       // (2) functie gebruiken zonder haakjes voor refs. (bij functie met haakjes) als er een supplement is verschillend van []
      //       // Alternatief: zie comments onder show/set-rules van math.equation
      //       //  (1) laten zoals het hier is of patroon zonder haakjes nemen en haakjes altijd toevoegen bij het zetten van de vgl. (of iets anders)
      //       //  (2) functie zonder haakjes gebruiken en er aan toevoegen bij het zetten van de vgl.

      let empty-supplement

      if el == none {
        it
      } else if el-function == math.equation {
        the-supplement = if it.supplement == auto {
          if ref-store == target-store { el.supplement } else {
            let the-suppl = get-el-suppl(
              ref-terminology,
              "math-equation",
              default: "Equation",
            )
            if the-suppl in (none, "") { [] } else { the-suppl }
          }
        } else { it.supplement }
        empty-supplement = the-supplement == []

        if empty-supplement and type(el.numbering) == str {
          // (1) prefix/suffix (meestal haakjes) in een numbering pattern worden weggelaten door standaard ref. Hier ze behouden als suppl=[]:
          link(el.location(), numbering(
            el.numbering,
            ..counter(el-function).at(el.location()),
          ))
        } else if (not empty-supplement) and type(el.numbering) == function {
          //
          // (2) functie zonder prefix/suffix aanroepen
          link(
            el.location(),
            if the-supplement not in ([], none, "") {
              the-supplement + sym.space
            }
              + numbering(
                {
                  let target-equation-settings = equation-settings
                    .get()
                    .at(target-store)
                  let the-numbering-function = target-equation-settings.at(
                    "numbering-function",
                    default: none,
                  ) // should be a function as type(el.numbering)==function
                  let the-numbering-format = target-equation-settings.at(
                    "equation-numbering",
                    default: (numbering: default-numbering),
                  )
                  if type(the-numbering-function) == function {
                    the-numbering-function.with(
                      numbering: the-numbering-format.at(
                        "numbering",
                        default: default-numbering,
                      ), // zonder prefix/suffix
                      separator: target-equation-settings.at(
                        "separator",
                        default: default-separator,
                      ),
                      loc: el.location(),
                    )
                  } else { compose-pattern(..the-numbering-format) } // just in case...
                },
                ..counter(el-function).at(el.location()),
              ),
          )
        } else if ref-store != target-store and it.supplement == auto {
          // keep numbering, but change supplement (only if supplement is not  already given)
          ref(it.target, form: it.form, supplement: the-supplement)
        } else {
          it
        }
      } else if el-function == figure {
        let the-kind=if type(el.kind) == str {el.kind} else { str(repr(el.kind)) }
        let ref-text-settings = figure-settings
            .get()
            .at(ref-store, default: (:))
            .at("figure-ref-text", default: (:))
        show: ref-text-settings.at(
            the-kind,
            default: ref-text-settings.at("rest", default: t => t),
          )
        if type(el.numbering) == str {
          // standaard worden prefix/suffix weggelaten bij een patroon, wat raar is want bij de figuur zelf en in de list of figures staan ze er wel.
          // Bij vergelijkingen heeft het weghalen van de prefix/suffix wel zin als er een supplement is want in de vgl. zelf staat dat supplement er niet.
          let the-supplement = if it.supplement == auto {
            if ref-store == target-store { el.supplement } else {
              get-el-suppl(
                ref-terminology,
                "figure-" + the-kind
              )
            }
          } else { it.supplement }
          link(
            el.location(),
            if the-supplement not in ([], none, "") {
              the-supplement + sym.space
            }
              + numbering(el.numbering, ..el.counter.at(el.location())),
          ) // patroon met prefix/suffix
        } else if ref-store != target-store and it.supplement == auto {
          ref(it.target, form: it.form, supplement: get-el-suppl(
            ref-terminology,
            "figure-" + the-kind,
          ))
        } else { it }
      } else if el.func() == heading {
        let the-term
        if part-heading.at(el.location()) {
          the-supplement = if it.supplement == auto {
            if ref-store == target-store { el.supplement } else {
              the-term = get-heading-term(
                ref-terminology,
                "part",
                default: "Part",
              )
              if the-term in (none, "") { [] } else { the-term }
            }
          } else { it.supplement }
          empty-supplement = the-supplement == []
          link(
            el.location(),
            if the-supplement not in ([], none, "") {
              the-supplement + sym.space
            }
              + numbering(
                {
                  let the-num = part-num.at(el.location())
                  if empty-supplement { the-num } else {
                    split-pattern(the-num).numbering
                  }
                },
                ..part-number.at(el.location()),
              ),
          )
        } else if ref-store != target-store or it.supplement != auto {
          let the-chapter-type = chapter-type.at(el.location())
          the-supplement = if it.supplement == auto {
            if ref-store == target-store { el.supplement } else if (
              el.level == 1
            ) {
              the-term = get-heading-term(ref-terminology, the-chapter-type)
              if the-term in (none, "") { [] } else { the-term }
            } else {
              the-term = get-heading-term(ref-terminology, "section")
              if the-term in (none, "") { [] } else { the-term }
            }
          } else { it.supplement }
          empty-supplement = the-supplement == []
          link(
            el.location(),
            if the-supplement not in ([], none, "") {
              the-supplement + sym.space
            }
              + numbering(
                if empty-supplement { el.numbering } else {
                  heading-numbering.get().at(the-chapter-type).numbering
                }, // el.numbering is met pre-/suffix, het andere zonder, zie chapter() en appendix()
                ..counter(heading).at(el.location()),
              ),
          )
        } else {
          it
        }
      } else { it }
    } else { it }
  }

  context {
    let base-font-size = text.size

    let the-per-chapter-numbering = (
      numbering-function: if per-chapter-numbering in (none, false) {
        none
      } else { add-chapter-number },
      separator: if per-chapter-numbering in (auto, true) {
        default-separator
      } else { per-chapter-numbering },
    )

    show: set-locale(locale, store: the-store)

    show: set-figures(
      base-font: text.font,
      base-font-size: base-font-size,
      ..the-per-chapter-numbering,
      figure-numbering: figure-numbering,
      figure-kinds: the-figure-kind-names,
      figure-fill: figure-fill,
      figure-inset: figure-inset,
      figure-text: figure-text,
      caption-position: caption-position,
      caption-align: caption-align,
      caption-text-align: caption-text-align,
      caption-separator: caption-separator,
      caption-text: caption-text,
      caption-prefix-text: caption-prefix-text,
      subfigure-caption-position: subfigure-caption-position,
      subfigure-caption-align: subfigure-caption-align,
      subfigure-caption-text-align: subfigure-caption-text-align,
      subfigure-caption-sep: subfigure-caption-sep,
      subfigure-numbering: subfigure-numbering,
      subfigure-ref-numbering: subfigure-ref-numbering,
      subfigure-caption-text: subfigure-caption-text,
      subfigure-caption-prefix-text: subfigure-caption-prefix-text,
      figure-ref-text: figure-ref-text,
      store: the-store,
    )

    show: set-terminology(
      the-terminology,
      figure-kinds: the-figure-kind-names,
      store: the-store,
    )

    show: set-equations(
      math-font: math-font,
      math-font-size: math-font-size,
      //       base-font-size: base-font-size,
      equation-numbering: equation-numbering,
      ..the-per-chapter-numbering,
      equation-left-margin: equation-left-margin,
      store: the-store,
    )

    //  alternatief voor numbering function met haakjes (chapter-equation-parentheses):
    //  numbering function zonder haakjes nemen maar haakjes toevoegen bij het zetten van de vgl.:
    //    set math.equation(numbering: add-chapter-number.with ) if per-chapter-numbering
    //    let add-parentheses(..num, numbering: none) = {
    //       "(" + std.numbering(numbering, ..num) + ")"
    //     }
    //    show math.equation.where(block: true): it => {
    //       let the-add-parentheses=add-parentheses.with(numbering:math.equation.numbering)
    //       if type(it.numbering) == function and it.numbering != the-add-parentheses {
    //         counter(math.equation).update(v => v - 1)
    //         math.equation(block: true, numbering: the-add-parentheses , it.body)
    //       } else { it }
    //     }
    // nog anders: altijd patronen/functies zonder haakjes nemen en dus altijd toevoegen bij het zetten van de vgl.  "type(it.numbering) == function and" hierboven dan weggelaten
    // in ieder geval moet dan de show-rule van ref aangepast worden (en is dan eenvoudiger dan de huidige met numbering patronen/functies met haakjes )

    show heading: it => {
      set block(below: 1em)
      it
      set-header-title(auto)
    }

    show heading.where(level: 1): it => {
      if per-chapter-numbering not in (none, false) {
        counter(math.equation).update(0)
        counter(figure.where(kind: image)).update(0)
        counter(figure.where(kind: table)).update(0)
        counter(figure.where(kind: raw)).update(0)
        for kind in the-figure-kinds {
          counter(figure.where(kind: kind)).update(0)
        }
      }
      start-at-odd-page()
      set par(justify: false)
      if show-heading.get() {
        let the-term
        let non-empty-term
        if part-heading.get() {
          v(2*base-font-size)
          {
            the-term = get-heading-term(
              terminologies.get().at(store.get()),
              "part",
              default: "Part",
            )
            non-empty-term = the-term not in (none, [], "")
            //             show text: convert-text-arg(part-number-text, default: (size: 4*base-font-size, fill: gray) )
            align(
              chapter-number-align,
              convert-text-arg(part-number-text, default: (
                size: if non-empty-term {3.2} else {4.8} * base-font-size,
                fill: gray,
              ))(
                if non-empty-term { capitalise(the-term) + sym.space }
                  + part-number.display(
                    //               {if non-empty-term {split-pattern(part-num.get()).numbering} else {part-num.get() }}
                    part-num.get(),
                  ),
              ),
            )
          }
          // ofwel met show text: ... en text(it.body)
          // ofwel met show: convert...
          // ofwel de functie convert-text-arg loslaten op it.body
          // anders staat bijv. math in it.body niet correct
          //           show text: convert-text-arg(part-title-text, default: (size: 3.2*base-font-size, hyphenate: false) )
          //           align(chapter-title-align, text(it.body))
          align(
            chapter-title-align,
            convert-text-arg(part-title-text, default: (
              size: 3.2 * base-font-size,
              hyphenate: false,
            ))(it.body),
          )
        } else {
          let the-chapter-type = chapter-type.get()
          v(2*base-font-size)
          if it.numbering != none {
            the-term = get-heading-term(
              terminologies.get().at(store.get()),
              the-chapter-type,
            )
            let non-empty-term = (
              the-term not in (none, [], "") and the-chapter-show()
            )
            //             show text: convert-text-arg(chapter-number-text, default: (size: 3.2*base-font-size, fill: gray) )
            align(
              chapter-number-align,
              convert-text-arg(chapter-number-text, default: (
                size: if non-empty-term {3.2} else {4.8} * base-font-size,
                fill: gray,
              ))(
                if non-empty-term {
                  (
                    capitalise(get-heading-term(
                      terminologies.get().at(store.get()),
                      the-chapter-type,
                    ))
                      + sym.space
                  )
                }
                  + counter(heading).display(if non-empty-term {
                    heading-numbering.get().at(the-chapter-type).at("numbering")
                  } else { it.numbering }),
              ),
            )
          }
          align(
            chapter-title-align,
            convert-text-arg(chapter-title-text, default: (
              size: 3.2 * base-font-size,
              hyphenate: false,
            ))(it.body),
          )
          v(4.8 * base-font-size)
        }
      }
      set-header-title(auto)
    }

    show outline: set heading(outlined: true)
    show outline.entry.where(level: 1): set block(above: 1em)

    show outline.entry: it => {
      let pg-width = page-number-width.get()
      //       set box(baseline: 100%)
      let el = it.element
      let loc = el.location()

      // exclude equations before the outline (assuming that the outline is put before the chapters )
      if el != none and el.func() == math.equation {
        if loc.page() < here().page() { return }
      }

      let firstlevelheading = el.func() == heading and it.level == 1
      set text(weight: "semibold") if firstlevelheading
      let thefill = if firstlevelheading { none } else { it.fill }
      let firstlevelheading = firstlevelheading and the-chapter-show()
      let is-page-number-shown = it.page() not in ("",[],none) and show-page-number.at(loc)
      link(loc, block(
        width: 100%,
        block(
          width: 100% - pg-width,
          if it.prefix() == none {
            box(par(
              justify: true,
              it.body()
                + [ ]
                + if is-page-number-shown {
                  box(
                    //                   baseline: 0%,
                    width: 1fr,
                    if filled-outline.at(loc) {
                      set text(weight: "regular")
                      it.fill
                      //  corresponds to repeat(text(weight: "regular")[.], gap: 0.15em), i.e. the default fill, if fill is not changed
                    } else {
                      thefill
                    },
                  )
                },
            ))
          } else {
            it.indented(
              ..if firstlevelheading { (gap: 0pt) } else { (:) },
              if not firstlevelheading {
                //                 box(
                text(weight: "semibold", it.prefix())
                //                 )
              },
              box(par(
                justify: true,
                if firstlevelheading {
                  (
                    get-heading-term(
                      terminologies.get().at(store.get()),
                      chapter-type.at(loc),
                    )
                      + " "
                      + it.prefix()
                      + [ -- ]
                  )
                }
                  + it.body()
                  + [ ]
                  + {
                    if is-page-number-shown {
                      box(
                        //                   baseline: 0%,
                        width: 1fr,
                        thefill,
                      )
                    }
                  },
              )),
            )
          },
        )
          + if is-page-number-shown {
            place(
              bottom + right,
              it.page(),
            )
          },
      ))
    }

    let the-title = the-localise(title)
    set document(title: the-title) if the-title != none
    let the-authors = the-localise(authors)
    set document(author: the-authors) if (
      type(the-authors) == str or type(the-authors) == array
    )
    let the-keywords = the-localise(keywords)
    set document(keywords: the-keywords) if (
      type(the-keywords) == str or type(the-keywords) == array
    )
    let the-description = the-localise(description)
    set document(description: the-description) if the-description != none
    set document(date: date) if type(date) == datetime

    body

  }


}


#let ref-list(..args, supplement: auto) = {
  let labels = args.pos()
  let the-labels = labels.flatten()

  // if the supplement is auto, do not pass "supplement: auto" to the ref function, because for user-defined kinds of figures this gives an error (a supplement should be given) although a supplement is provided by a show-set rule for the user-defined kinds
  let the-ref(item, supplement) = {
    ref(item, ..if supplement != auto { (supplement: supplement) } else { (:) })
  }

  if labels.len() == 1 and type(labels.first()) == label {
    the-ref(labels.first(), supplement) // only one label => regular ref (possibly with given supplement)
  } else if the-labels.len() > 1 {
    context {
      let plural(suppl) = {
        show ".s": "s."
        suppl + "s"
      }

      let el = query(the-labels.first()).first()
      let eq-suppl
      let ref-store = store.get()
      let target-store = store.at(el.location())
      let target-terminology = terminologies.get().at(target-store)
      let ref-terminology = terminologies.get().at(ref-store)

      let is-eq = el.func() == math.equation
      if is-eq {
        eq-suppl = get-el-suppl(ref-terminology, "math-equation")
      }

      let the-supplement = if supplement == auto {
        if is-eq {
          if eq-suppl == none {
            none
          } else {
            get-el-suppl(
              ref-terminology,
              "math-equation",
              case: 1,
              default: plural(el.supplement),
            )
          }
        } else if el.func() == figure {
          let the-kind = if type(el.kind) == function {
            str(repr(el.kind))
          } else { el.kind }
          let ref-text-settings = figure-settings
            .get()
            .at(ref-store, default: (:))
            .at("figure-ref-text", default: (:))
          show: ref-text-settings.at(
            the-kind,
            default: ref-text-settings.at("rest", default: t => t),
          )
          get-el-suppl(
            ref-terminology,
            "figure-" + the-kind,
            case: 1,
            default: plural(el.supplement),
          )
        } else if el.func() == heading {
          if el.level == 1 {
            if (
              el.supplement
                == [#get-heading-term(
                  target-terminology,
                  "part",
                  default: [Part],
                )]
            ) {
              get-heading-term(
                ref-terminology,
                "part",
                case: 1,
                default: plural(el.supplement),
              )
            } else if (
              el.supplement
                == [#get-heading-term(
                  target-terminology,
                  "chapter",
                  default: [Chapter],
                )]
            ) {
              get-heading-term(
                ref-terminology,
                "chapter",
                case: 1,
                default: plural(el.supplement),
              )
            } else if (
              el.supplement
                == [#get-heading-term(
                  target-terminology,
                  "appendix",
                  default: [Appendix],
                )]
            ) {
              get-heading-term(
                ref-terminology,
                "appendix",
                case: 1,
                default: plural(el.supplement),
              )
            } else { plural(el.supplement) } // just guess a plural form :)
          } else {
            get-heading-term(
              ref-terminology,
              "section",
              case: 1,
              default: plural(el.supplement),
            )
          }
        }
      } else { supplement }

      let ref-supplement = if is-eq {
        if the-supplement in ([], none, "") { [] } else { none } // "else ..." is niet eigenlijk niet nodig door initiële waarde die al none is
        // [] of niet [] bepaalt de haakjes rond vergelijkingen in show rule van ref  (bij set math.equation(supplement:none) wordt el.supplement=[] in ref )
        // Als the-supplement leeg is moeten de haakjes blijven/toegevoegd worden (zoals in het geval van set math.equation(supplement:none)  ), dus [] doorgeven.
        // Als the-supplement niet leeg is moet ref geen supplement toevoegen maar moeten de haakjes toch weg. Dus iets "leeg" meegeven, maar niet [], bijv. none.
      } else { none }

      let the-list = labels.map(it => {
        if type(it) == label {
          the-ref(it, ref-supplement)
        } else if type(it) == array {
          let first = it.first()
          let last = it.last()
          if first == last {
            the-ref(first, ref-supplement)
          } else {
            (
              the-ref(first, ref-supplement)
                + [--]
                + the-ref(last, ref-supplement)
            )
          }
        }
      })

      if the-supplement not in (auto, none, [], "") { the-supplement + " " } // an alternative is to pass "the-supplement" to the ref of the first label; The supplement is now not clickable)
      the-list.join(", ", last: get-prefix-last(
        ref-terminology,
        the-list.len(),
      ))
    }
  }
}

#let ref-range(..args, supplement: auto) = ref-list(
  (..args.pos(),),
  supplement: supplement,
)

#let table-of-contents = context {
  outline(
    title: terminologies
      .get()
      .at(store.get())
      .at("table-of-contents", default: auto),
    target: heading,
  )
}



#let list-of-figure-kind(kind) = context {
  let the-kind = (
    "figure-" + if type(kind) == function { str(repr(kind)) } else { kind }
  )
  outline(
    title: terminologies
      .get()
      .at(store.get())
      .at(the-kind, default: (:))
      .at("outline-title", default: auto),
    target: figure.where(kind: kind),
  )
}

#let list-of-figures = list-of-figure-kind(image)
#let list-of-tables = list-of-figure-kind(table)
#let list-of-listings = list-of-figure-kind(raw)

#let list-of-equations = context {
  outline(
    title: terminologies
      .get()
      .at(store.get())
      .at("math-equation", default: (:))
      .at("outline-title", default: auto),
    target: math.equation,
  )
}

#let list-of-abbreviations = context {
  abbr.list(
    title: terminologies
      .get()
      .at(store.get())
      .at("list-of-abbreviations", default: "List of Abbreviations"),
  )
}

#let front-matter(show-headings: true, show-headers: false, body) = {

  start-at-odd-page()
  set page(numbering: "i")

  set heading(numbering: none)
  show-heading.update(show-headings)
  filled-outline.update(true)
  chapter-type.update(none)

  show-header.update(show-headers)

  body
}

#let chapter(show-headers: true, body ) = context {
  let the-chapter-type = "chapter"

  start-at-odd-page()
  set page(numbering: "1")

  chapter-type.update(the-chapter-type)
  counter(page).update(1)
  show-heading.update(true)
  set heading(numbering: compose-pattern(
    ..(heading-numbering.get().at(the-chapter-type)),
  ))
  show heading.where(level: 1): set heading(supplement: get-heading-term(
    terminologies.get().at(store.get()),
    the-chapter-type,
    default: [Chapter],
  ))
  counter(heading).update(0) // not really necessary as front-matter headings are not numbered
  filled-outline.update(false)
  show-header.update(show-headers)

  body
}

#let appendix(flyleaf: auto, show-headers: true, body) = context {
  let the-chapter-type = "appendix"
  let the-terminology = terminologies.get().at(store.get())
  let appendix-label = get-heading-term(
    the-terminology,
    the-chapter-type,
    default: [Appendix],
  )
  let appendices-label = get-heading-term(
    the-terminology,
    the-chapter-type,
    case: 1,
    default: [Appendices],
  )

  let n-app = query(
    selector(heading.where(
      supplement: [#appendix-label], /*, numbering: appendix-num.get()*/
    )).after(here()),
  ).len()

  start-at-odd-page()
  set page(numbering: "1")

  chapter-type.update(the-chapter-type)

  if flyleaf not in (none,false) and n-app > 0 {
    show-page-numbers(false)
    set heading(numbering: none)
    [= #{
      if flyleaf == auto {
        if n-app == 1 { appendix-label } else { appendices-label }
      } else { flyleaf }
    }]
    start-at-odd-page()
    show-page-numbers(true)
  }

  show-heading.update(true)
  counter(heading).update(0)
  set heading(numbering: compose-pattern(
    ..heading-numbering.get().at(the-chapter-type),
  ))
  show heading.where(level: 1): set heading(supplement: appendix-label)
  filled-outline.update(false)
  show-header.update(show-headers)
  body
}

#let back-matter(show-headings: true, show-headers: true, body) = {

  start-at-odd-page()
  set page(numbering: "1")
  show-heading.update(show-headings)
  set heading(numbering: none)
  show heading.where(level: 1): set heading(supplement: none)
  filled-outline.update(true)
  chapter-type.update(none)

  show-header.update(show-headers)

  body
}

#let change-locale(
  language: auto,
  region: auto,
  terminology: (:),
  figure-set: auto,
  equation-set: auto,
  per-chapter-numbering: false,
  body,
) = context {
  let locale = split-locale(language, region: region)
  let the-store = store.get()
  let the-localise = localise.with(locale: locale.locale)

  let the-per-chapter-numbering = (
    numbering-function: if per-chapter-numbering in (none, false) {
      none
    } else { add-chapter-number },
    separator: if per-chapter-numbering in (auto, true) {
      default-separator
    } else { per-chapter-numbering },
  )

  let the-terminology = merge-dictionaries(
    the-localise(terminology-defaults.get()),
    the-localise(terminology),
  )
  let the-figure-settings = (
    if figure-set == auto {
      figure-settings.get().at(the-store, default: (:))
    } else { figure-set }
      + the-per-chapter-numbering
  )
  let the-equation-settings = (
    if equation-set == auto {
      equation-settings.get().at(the-store, default: (:))
    } else { equation-set }
      + the-per-chapter-numbering
  )


  let the-store = "cl-" + if type(language)==str {language} else {repr(language)} + "-" + if type(region)==str {region} else {repr(region)} + "-" + str((repr(body)+repr(terminology)+repr(figure-set)+repr(equation-set)+repr(per-chapter-numbering)).len())

  store.update(the-store)

  {
    show: set-locale(locale, store: the-store)
    show: set-terminology(the-terminology, store: the-store)
    show: set-figures(..the-figure-settings, store: the-store)
    show: set-equations(..the-equation-settings, store: the-store)

    body
  }

  // still in the original context => previous store
  store.update(store.get())
}


