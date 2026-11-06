#import "@preview/pergamon:0.7.0": *
// #import "@local/pergamon:0.7.1": *
#let dev = pergamon-dev


////// PERGAMON CONFIG ///////

// modified formatting of volume and number for Pergamon
#let volume-number-pages(reference, options) = {
  let volume = fd(reference, "volume", options)
  let number = fd(reference, "number", options)
  let pages = fd(reference, "pages", options)

  let a = if volume == none and number == none {
    none
  } else if number == none {
    " " + volume
  } else if volume == none {
    panic("Can't use 'number' without 'volume' (in " + reference.entry_key + ")!")
  } else {
    strfmt(" {}({})", volume, number)
  }

  let pp = if pages == none {
    none
  } else if a != none {
    ":" + pages
  } else {
    ", " + (dev.printfield)(reference, "pages", options)
  }
  
  epsilons(a, pp)
}

// Pergamon citation style suitable for ACL
#let acl-cite = format-citation-authoryear(
  author-year-separator: ", "
)

// Define Pergamon refsection for ACL papers
#let acl-refsection = refsection.with(format-citation: acl-cite.format-citation)

// Call this to print the bibliography. All named arguments that you pass
// to this function will be forwarded to the format-reference call, enabling customization.
#let print-acl-bibliography(..pergamon-arguments) = {
  // default arguments for format-reference
  let format-reference-arguments = (
    name-format: "{given} {family}",
    reference-label: acl-cite.reference-label,
    format-quotes: it => it,
    print-isbn: false,

    suppress-fields: (
      "*": ("month",),
      "inproceedings": ("editor",),
    ), 

    print-date-after-authors: true,

    format-functions: (
      "maybe-with-date": (reference, options) => {
        name => {
          periods(
            name,
            (dev.date-with-extradate)(reference, options)
          )
        }
      },

      // reordered location and organization
      "driver-inproceedings": (reference, options) => {
        (dev.require-fields)(reference, options, "author", "title", "booktitle")

        (options.periods)(
          (dev.author-translator-others)(reference, options),
          (dev.date-with-extradate)(reference, options),
          (dev.printfield)(reference, "title", options),
          (options.commas)(
            spaces(options.bibstring.in, (dev.maintitle-booktitle)(reference, options)),
            (dev.printfield)(reference, "pages", options),
            (dev.printfield)(reference, "location", options),
            (dev.printfield)(reference, "organization", options),
          ),
          (dev.doi-eprint-url)(reference, options),
          (dev.addendum-pubstate)(reference, options)
        )
      },

      // TODO: include "edited by"
      "driver-incollection": (reference, options) => {
        (dev.require-fields)(reference, options, "author", "title", "editor", "booktitle")

        (options.periods)(
          (dev.author-translator-others)(reference, options),
          (dev.date-with-extradate)(reference, options),
          (dev.printfield)(reference, "title", options),
          spaces(
            options.bibstring.in,
            (options.commas)(
              (dev.printfield)(reference, "editor", options),
              (dev.maintitle-booktitle)(reference, options),
              (dev.printfield)(reference, "pages", options)
            )
          ),
          (dev.publisher-location-date)(reference, options),
        )
      },

      // different formatting of volume and number
      // TODO: check eid
      "driver-article": (reference, options) => {
          (dev.require-fields)(reference, options, "author", "title", "journaltitle")

          (options.periods)(
            (dev.author-translator-others)(reference, options),
            (dev.date-with-extradate)(reference, options),
            (dev.printfield)(reference, "title", options),
            epsilons(
              emph((dev.printfield)(reference, "journaltitle", options)),
              volume-number-pages(reference, options)
            ),
            (dev.doi-eprint-url)(reference, options),
            (dev.addendum-pubstate)(reference, options)
          )
      },
    ),

    bibstring: (
      "in": "In",
    ),
  ) + pergamon-arguments.named()

  let acl-ref = format-reference(..format-reference-arguments)

  {
    set par(hanging-indent: 1em, leading: 5pt)
    set text(size: 10pt)
    print-bibliography(
      format-reference: acl-ref,
      sorting: "nyt",
      label-generator: acl-cite.label-generator,
      )
  }
}

////// END PERGAMON CONFIG ///////


