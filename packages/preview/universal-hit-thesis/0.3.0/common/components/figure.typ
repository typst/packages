#let algorithm-figure(content, caption: none, supplement: [算法], label-name: "", breakable: true) = {
  block(stroke: rgb("#0000"))[
    #let new-label = label(label-name)
    #figure(
      [],
      kind: "algorithm",
      supplement: supplement,
    ) #new-label
    #v(-1.25em)

    #context {
      let heading-number = counter(heading).get().at(0)
      let _prefix = "i-figured-"
      let algo-kind = "algorithm"
      let prefix-alog-number = counter(figure.where(kind: _prefix + repr(algo-kind))).get().at(0)
      let numbers = (heading-number, prefix-alog-number)

      block(
        stroke: (y: 1.3pt),
        inset: 0pt,
        breakable: breakable,
        width: 100%,
        {
          set align(left)
          block(
            inset: (y: 5pt),
            width: 100%,
            stroke: (bottom: .8pt),
            {
              strong({
                supplement
                numbering("1-1", ..numbers)
                if caption != none {
                  [: ]
                } else {
                  [.]
                }
              })
              if caption != none {
                caption
              }
            },
          )
          v(-1em)
          block(
            breakable: breakable,
            content,
          )
        },
      )
    }
  ]
}

#import "@preview/codelst:2.0.2": sourcecode, code-frame
#import "../theme/type.typ": 字体, 字号

#let codelst-sourcecode = sourcecode
#let hit-sourcecode = codelst-sourcecode.with(frame: code => {
  set text(font: 字体.代码, size: 字号.五号)
  code-frame(code)
})

#let code-figure(content, caption: [], supplement: [代码], label-name: "") = {
  let fig = figure(
    hit-sourcecode(content),
    caption: caption,
    kind: raw,
    supplement: supplement,
  )
  [
    #if label-name == "" {
      [#fig]
    } else {
      let new-label = label(label-name)
      [#fig #new-label]
    }
  ]
}

//////// 双语 figure ////////

#let bilingual-figure-caption = (it) => context [
  // #repr(it)
  // #repr(it.fields())
  #block(inset: 0.5em, width: 100%)[
    #set par(first-line-indent: 0em)
    #let fields = it.fields()
    #let fig-counter = fields.counter
    #let fig-counter-value = fig-counter.get().at(0)
    #let heading-counter-value = counter(heading).get().at(0)
    #let body = it.body
    #[#fields.supplement #[#heading-counter-value]-#[#fig-counter-value] #[#h(0.5em)] #body]

    #let before-bilingual-figure-metadata-array = query(metadata.where(label: <bilingual-figure-metadata>).before(here()))
    #let before-last-bilingual-figure-metadata = none
    #if before-bilingual-figure-metadata-array.len() != 0 {
      before-last-bilingual-figure-metadata = before-bilingual-figure-metadata-array.last()
      // [#before-bilingual-figure-metadata-value]
    }
    #let after-bilingual-figure-metadata-array = query(metadata.where(label: <bilingual-figure-metadata>).after(here()))
    #let after-first-bilingual-figure-metadata = none
    #if after-bilingual-figure-metadata-array.len() != 0 {
      after-first-bilingual-figure-metadata = after-bilingual-figure-metadata-array.first()
      // [#after-bilingual-figure-metadata-value]
    }
    #if before-last-bilingual-figure-metadata != none and after-first-bilingual-figure-metadata != none and before-last-bilingual-figure-metadata.value == after-first-bilingual-figure-metadata.value [
      #let supplement-foreign = before-last-bilingual-figure-metadata.value.supplement-foreign
      #let caption-foreign-body = before-last-bilingual-figure-metadata.value.caption-foreign
      #[#supplement-foreign #[#heading-counter-value]-#[#fig-counter-value] #[#h(0.5em)] #caption-foreign-body]
    ]
  ]
]

#let bilingual-figure-counter = counter("bilingual-figure")

#let bilingual-figure = (
  body,
  caption: none,
  gap: 0.65em,
  kind: auto,
  numbering: "1",
  outlined: true,
  placement: none,
  scope: "column",
  supplement: auto,
  label-name: none,
) => context {

  bilingual-figure-counter.step()

  let get-supplement-default-by-kind = (kind) => {
    if kind == image {
      (
        zh: [图],
        en: [Fig.],
      )
    } else if kind == raw {
      (
        zh: [代码],
        en: [Code],
      )
    } else if kind == table {
      (
        zh: [表],
        en: [Table],
      )
    } else {
      (
        zh: none,
        en: none,
      )
    }
  }

  let internal-kind = none

  let afer-figure-array = query(figure.where().after(here()))
  if afer-figure-array.len() > 0 {
    internal-kind = afer-figure-array.first().kind
  }

  let supplement-native = none
  let supplement-foreign = none


  if supplement == auto or type(supplement) == dictionary {
    let supplement-default = get-supplement-default-by-kind(internal-kind)
    let supplement-blingual = if supplement == auto {supplement-default} else  {supplement-default + supplement}
    supplement-native = supplement-blingual.zh
    supplement-foreign = supplement-blingual.en
  } else {
    supplement-native = supplement
  }

  let caption-native = none
  let caption-foreign = none
  if type(caption) == dictionary {
    let caption-default = (
      zh: [],
      en: [],
    )
    let caption-blingual = caption-default + caption
    caption-native = caption-blingual.zh
    caption-foreign = caption-blingual.en
    if text.lang == "en" {
      (caption-native, caption-foreign) = (caption-foreign, caption-native)
    }
  } else {
    caption-native = caption
  }

  context [
    #let bilingual-counter-value = bilingual-figure-counter.get()
    #if supplement-foreign != none and caption-foreign != none [
      #metadata((
        bilingual-counter-value: bilingual-counter-value,
        supplement-foreign: supplement-foreign,
        caption-foreign: caption-foreign,
      )) <bilingual-figure-metadata>
    ]

    #let internal-figure = figure(
        body, 
        caption: caption-native, 
        gap: gap,
        kind: kind,
        numbering: numbering,
        outlined: outlined,
        placement: placement,
        scope: scope,
        supplement: supplement-native
      )

    #if label-name != none [
      #internal-figure #label(label-name)
    ] else [
      #internal-figure
    ]

    #if supplement-foreign != none and caption-foreign != none [
      #metadata((
        bilingual-counter-value: bilingual-counter-value,
        supplement-foreign: supplement-foreign,
        caption-foreign: caption-foreign,
      )) <bilingual-figure-metadata>
    ]
  ]
}

////////////////////////////