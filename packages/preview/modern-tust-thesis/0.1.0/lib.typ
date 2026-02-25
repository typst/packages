#import "layouts/doc.typ": doc
#import "layouts/preface.typ": preface
#import "layouts/mainmatter.typ": mainmatter
#import "layouts/appendix.typ": appendix
#import "pages/cover.typ": cover-page
#import "pages/cover-bachelor.typ": cover-bachelor-page
#import "pages/cover-en.typ": cover-en-page
#import "pages/declare.typ": declare-page
#import "pages/abstract.typ": abstract-page
#import "pages/abstract-en.typ": abstract-en-page
#import "pages/outline.typ": outline-page, image-outline-page, table-outline-page, algorithm-outline-page
#import "pages/nomenclature.typ": nomenclature-page, nomenclature-table
#import "pages/bib.typ": bibliography-page
#import "pages/acknowledgement.typ": acknowledgement-page
#import "pages/achievement.typ": achievement-page
#import "pages/summary-en.typ": summary-en-page
#import "pages/task.typ": task-page
#import "utils/figurex.typ": *
#import "utils/style.typ": zihao, ziti
#import "utils/word-counter.typ": *
#import "utils/theoriom.typ": theorem, proof
#import "@preview/lovelace:0.3.0": *

#let codly-setup(use-standard-code-format: true) = {
  import "@preview/codly:1.3.0": codly, codly-init
  import "@preview/codly-languages:0.1.10": *
  
  show: codly-init.with()
  
  if use-standard-code-format {
    codly(
      languages: codly-languages,
      zebra-fill: none,
      stroke: none,
      radius: 0pt,
      inset: 0pt,
      display-name: false,  // 不显示语言名称
      display-icon: false,  // 不显示图标
    )
    show raw.where(block: true): it => {
      set text(font: ziti.songti, size: zihao.wuhao)
      set par(leading: 4pt, spacing: 0pt, first-line-indent: 0pt)
      block(above: 12pt, below: 12pt, inset: (left: 2em), it)
    }
  } else {
    codly(languages: codly-languages)
  }
}

#let documentclass(
  date: datetime.today(),
  twoside: false,
  anonymous: false,
  print: false,
  use-standard-code-format: true,
  info: (:),
  key-to-zh: (:),
) = {
  let doctype = "bachelor"

  info = (
    (
      name: "张三",
      title: "天津科技大学毕业论文模板",
      work-type: "design", // "design" | "thesis"
    )
      + info
  )

  let work-type = info.at("work-type", default: "design")
  let heading = if work-type == "thesis" {
    "天津科技大学本科毕业论文"
  } else {
    "天津科技大学本科毕业设计"
  }
  let cover-color = if work-type == "thesis" { "green" } else { "blue" }

  info = info + (
    work-type: work-type,
    heading: heading,
    cover-color: cover-color,
  )

  (
    doctype: doctype,
    date: date,
    twoside: twoside,
    anonymous: anonymous,
    info: info,
    key-to-zh: key-to-zh,
    codly-setup: (..args) => {
      codly-setup(
        use-standard-code-format: use-standard-code-format,
      )
    },
    doc: (..args) => {
      doc(
        ..args,
        doctype: doctype,
        twoside: twoside,
        print: print,
        info: info + args.named().at("info", default: (:)),
      )
    },
    preface: (..args) => {
      preface(
        ..args,
        doctype: doctype,
        twoside: twoside,
        print: print,
        info: info + args.named().at("info", default: (:)),
      )
    },
    mainmatter: (..args) => {
      mainmatter(
        ..args,
        doctype: doctype,
        twoside: twoside,
        use-standard-code-format: use-standard-code-format,
        info: info + args.named().at("info", default: (:)),
      )
    },
    appendix: (..args) => {
      appendix(
        ..args,
        doctype: doctype,
        twoside: twoside,
        info: info + args.named().at("info", default: (:)),
      )
    },
    cover: (..args) => {
      if doctype == "bachelor" {
        cover-bachelor-page(
          ..args,
          twoside: twoside,
          anonymous: anonymous,
          info: info + args.named().at("info", default: (:)),
          date: date,
          key-to-zh: key-to-zh,
        )
      } else {
        cover-page(
          ..args,
          doctype: doctype,
          twoside: twoside,
          anonymous: anonymous,
          info: info + args.named().at("info", default: (:)),
          date: date,
          key-to-zh: key-to-zh,
        )
      }
    },
    cover-en: (..args) => {
      cover-en-page(
        ..args,
        doctype: doctype,
        twoside: twoside,
        anonymous: anonymous,
        info: info + args.named().at("info", default: (:)),
        date: date,
      )
    },
    declare: (..args) => {
      declare-page(
        ..args,
        doctype: doctype,
        twoside: twoside,
        anonymous: anonymous,
        info: info + args.named().at("info", default: (:)),
      )
    },
    abstract: (..args) => {
      abstract-page(
        ..args,
        twoside: twoside,
        info: info + args.named().at("info", default: (:)),
      )
    },
    abstract-en: (..args) => {
      abstract-en-page(
        ..args,
        twoside: twoside,
        info: info + args.named().at("info", default: (:)),
      )
    },
    outline: (..args) => {
      outline-page(
        ..args,
        doctype: doctype,
        twoside: twoside,
      )
    },
    image-outline: (..args) => {
      image-outline-page(
        ..args,
        twoside: twoside,
      )
    },
    table-outline: (..args) => {
      table-outline-page(
        ..args,
        twoside: twoside,
      )
    },
    algorithm-outline: (..args) => {
      algorithm-outline-page(
        ..args,
        twoside: twoside,
      )
    },
    nomenclature: (..args) => {
      nomenclature-page(
        ..args,
        twoside: twoside,
      )
    },
    bib: (..args) => {
      bibliography-page(
        ..args,
        doctype: doctype,
        twoside: twoside,
      )
    },
    acknowledgement: (..args) => {
      acknowledgement-page(
        ..args,
        doctype: doctype,
        twoside: twoside,
        anonymous: anonymous,
      )
    },
    achievement: (..args) => {
      achievement-page(
        ..args,
        doctype: doctype,
        twoside: twoside,
      )
    },
    summary-en: (..args) => {
      summary-en-page(
        ..args,
        doctype: doctype,
        twoside: twoside,
      )
    },
    task: (..args, body) => {
      task-page(
        ..args,
        twoside: twoside,
        info: info + args.named().at("info", default: (:)),
        body: body,
      )
    },
  )
}
