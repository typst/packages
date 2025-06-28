#import "@preview/physica:0.9.5": *
#import "@preview/unify:0.7.1": *
#import "@preview/equate:0.3.2": *

#import "defaults.typ": config as defaults
#import "theme.typ"
#import "util.typ"

#import "components.typ": author, question, solution, feeder, components-wrapper as qns
#import "markscheme.typ"
#import "drawing.typ"

#import "internal.typ"

/*******
 * Setup
 *******/

/// Setup the project: import relevant packages, configure global styles like font and page numbering.
/// [WARN] `authors` requires specific structure, use function `author()` to help construct them.
///
/// - project (str, content): The name of the project.
/// - group (str, content, none): The group name.
/// - implicit-head (bool): Whether to implicitly generate a project head of the title, group and authors.
/// - config (dictionary, module, array): The config, containing various document processing and style information. Can be an `array` of configs in `dictionary` a/o `module`.
/// - authors (arguments): The authors of the project.
/// - body (block): The content of the document.
///
/// -> content
#let setup(
  title: "Group Project",
  group: none,
  implicit-head: true,
  config: (:),
  ..authors,
  body,
) = [
  #import "components.typ": *
  #import "util.typ": *

  // load config
  #if type(config) == dictionary { config = (config,) }
  #let conf = merge-configs(defaults, ..config)
  #context config-state.update(conf)

  // make authors
  #let authors = authors.pos().map(a => if type(a) == function { a() } else { a })

  // populate title and author metadata
  #set document(
    title: title,
    author: authors.map(a => {
      if type(a.plain) == str {
        return a.plain
      }
      if type(a.name.first) == content {
        if "text" in a.name.first.fields() {
          a.name.first = a.name.first.text
        } else {
          // If the name is not normal, set "<unsupported>".
          a.name.first = "<unsupported>"
        }
      }
      if type(a.name.last) == content {
        if "text" in a.name.last.fields() {
          a.name.last = a.name.last.text
        } else {
          // If the name is not normal, set "<unsupported>".
          a.name.last = "<unsupported>"
        }
      }
      a.name.first + " " + a.name.last
    }),
  )

  //REGION: global
  #set text(
    font: conf.global.font-major,
    size: conf.global.font-size,
    fill: conf.global.color-major,
  )
  #set page(background: conf.global.background)

  //REGION: raw
  #show raw: set text(
    font: conf.raw.font-major,
    fill: conf.raw.color-major,
  )
  #show raw: conf.raw.rule

  //REGION: ref
  #show ref: set text(fill: conf.ref.color-major)
  #show ref: conf.ref.rule

  //REGION: link
  #show link: set text(fill: conf.link.color-major)
  #show link: conf.link.rule

  //REGION: math
  #show math.equation: set text(
    font: conf.math.font-major,
    fill: conf.math.color-major,
  )

  #set math.equation(numbering: conf.math.numbering)
  #show: doc => compose(
    doc,
    (if conf.math.transpose { super-T-as-transpose }),
    (
      if conf.math.equate {
        equate.with(
          breakable: true,
          sub-numbering: true,
          number-mode: (if conf.math.implicit-numbering { "line" } else { "label" }),
        )
      }
    ),
  )

  //REGION: arbitrary global
  #show: conf.global.rule

  //REGION: package hard rules
  // show question and solution figures as none
  #show: qns-nullifier

  //REGION: doc head
  #if implicit-head {
    project-head-visualizer(
      title,
      group,
      author-set-visualizer(
        authors.map(a => author-visualizer(a, config: conf)),
        config: conf,
      ),
      config: conf,
    )
  }

  #body
]

////////////////
/* Shorthands */
////////////////

// Block style limit notation.
#let limm = $limits("lim")$

// Block style sum notation.
#let summ = $limits(sum)$

// A horizontal rule.
#let hrule = {
  v(0.2em)
  line(length: 100%, stroke: 0.4pt)
}

