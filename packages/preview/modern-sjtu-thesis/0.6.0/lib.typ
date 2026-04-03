#import "utils/style.typ": preset-ziti, zihao
#import "utils/word-counter.typ": *
#import "utils/figurex.typ": *
#import "layouts/doc.typ": doc
#import "layouts/preface.typ": preface
#import "layouts/mainmatter.typ": *
#import "layouts/appendix.typ": appendix
#import "pages/cover.typ": cover-page
#import "pages/cover-bachelor.typ": cover-bachelor-page
#import "pages/cover-en.typ": cover-en-page
#import "pages/declare.typ": declare-page
#import "pages/abstract.typ": abstract-page
#import "pages/abstract-en.typ": abstract-en-page
#import "pages/outline.typ": algorithm-outline-page, image-outline-page, outline-page, table-outline-page
#import "pages/nomenclature.typ": nomenclature-page, nomenclature-table
#import "pages/bib.typ": bibliography-page
#import "pages/acknowledgement.typ": acknowledgement-page
#import "pages/achievement.typ": achievement-page
#import "pages/summary-en.typ": summary-en-page
#import "@preview/lovelace:0.3.1": *

#let documentclass(
  doctype: "master",
  date: datetime.today(),
  twoside: false,
  anonymous: false,
  print: false,
  font-set: none,
  fonts: preset-ziti,
  info: (:),
  key-to-zh: (:),
) = {
  date = date
  info = (
    (
      student-id: "520XXXXXXXX",
      name: "张三",
      name-en: "Zhang San",
      degree: "工学硕士",
      supervisor: "李四教授",
      supervisor-en: "Prof. Li Si",
      title: "上海交通大学学位论文格式模板",
      title-en: "DISSERTATION TEMPLATE FOR MASTER DEGREE OF ENGINEERING IN SHANGHAI JIAO TONG UNIVERSITY",
      school: "某某学院",
      school-en: "School of XXXXXXX",
      major: "某某专业",
    )
      + info
  )
  key-to-zh = key-to-zh
  fonts = {
    if font-set == "webapp" {
      (
        en-serif: "TeX Gyre Termes",
        en-sans: "TeX Gyre Heros",
        songti: ((name: "TeX Gyre Termes", covers: "latin-in-cjk"), "Noto Serif CJK SC"),
        heiti: ((name: "TeX Gyre Termes", covers: "latin-in-cjk"), "Noto Sans CJK SC"),
        dengkuan: ("Fira Mono", (name: "Noto Sans CJK SC", covers: regex("\p{script=Han}"))),
        math: ("New Computer Modern Math", (name: "Noto Serif CJK SC", covers: regex("\p{script=Han}"))),
      )
    } else if font-set == "mac" {
      (
        en-serif: "Times New Roman",
        en-sans: "Arial",
        songti: ((name: "Times New Roman", covers: "latin-in-cjk"), "Songti SC"),
        heiti: ((name: "Times New Roman", covers: "latin-in-cjk"), "Heiti SC"),
        kaiti: ((name: "Times New Roman", covers: "latin-in-cjk"), "Kaiti SC"),
        fangsong: ((name: "Times New Roman", covers: "latin-in-cjk"), "FangSong SC"),
        dengkuan: ("Menlo", (name: "Heiti SC", covers: regex("\p{script=Han}"))),
        math: ("STIX Two Math", (name: "Songti SC", covers: regex("\p{script=Han}"))),
      )
    } else if font-set == "windows" {
      (
        en-serif: "Times New Roman",
        en-sans: "Arial",
        songti: ((name: "Times New Roman", covers: "latin-in-cjk"), "SimSun"),
        heiti: ((name: "Times New Roman", covers: "latin-in-cjk"), "SimHei"),
        kaiti: ((name: "Times New Roman", covers: "latin-in-cjk"), "KaiTi"),
        fangsong: ((name: "Times New Roman", covers: "latin-in-cjk"), "FangSong"),
        dengkuan: ("Consolas", (name: "SimHei", covers: regex("\p{script=Han}"))),
        math: ("Cambria Math", (name: "SimSun", covers: regex("\p{script=Han}"))),
      )
    } else if font-set == "webapp-upload" {
      (
        en-serif: "TeX Gyre Termes",
        en-sans: "TeX Gyre Heros",
        songti: ((name: "TeX Gyre Termes", covers: "latin-in-cjk"), "ST Songti"),
        heiti: ((name: "TeX Gyre Termes", covers: "latin-in-cjk"), "SimHei"),
        kaiti: ((name: "TeX Gyre Termes", covers: "latin-in-cjk"), "Kaiti"),
        fangsong: ((name: "TeX Gyre Termes", covers: "latin-in-cjk"), "FangSong"),
        dengkuan: ("Fira Mono", (name: "SimHei", covers: regex("\p{script=Han}"))),
        math: ("New Computer Modern Math", (name: "ST Songti", covers: regex("\p{script=Han}"))),
      )
    } else if font-set == "linux" {
      (
        en-serif: "Liberation Serif",
        en-sans: "Liberation Sans",
        songti: ((name: "Liberation Serif", covers: "latin-in-cjk"), "Noto Serif CJK SC"),
        heiti: ((name: "Liberation Serif", covers: "latin-in-cjk"), "Noto Sans CJK SC"),
        dengkuan: ("Liberation Mono", (name: "Noto Sans CJK SC", covers: regex("\p{script=Han}"))),
        math: ("Latin Modern Math", (name: "Noto Serif CJK SC", covers: regex("\p{script=Han}"))),
      )
    } else {
      fonts
    }
  }

  (
    doctype: doctype,
    date: date,
    twoside: twoside,
    anonymous: anonymous,
    print: print,
    info: info,
    key-to-zh: key-to-zh,
    ziti: fonts,
    doc: (..args) => {
      doc(
        ..args,
        doctype: doctype,
        twoside: twoside,
        print: print,
        info: info + args.named().at("info", default: (:)),
        ziti: fonts,
      )
    },
    preface: (..args) => {
      preface(
        ..args,
        doctype: doctype,
        twoside: twoside,
        print: print,
        ziti: fonts,
      )
    },
    mainmatter: (..args) => {
      mainmatter(
        ..args,
        doctype: doctype,
        twoside: twoside,
        ziti: fonts,
      )
    },
    appendix: (..args) => {
      appendix(
        ..args,
        doctype: doctype,
        twoside: twoside,
        ziti: fonts,
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
          ziti: fonts,
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
          ziti: fonts,
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
        ziti: fonts,
      )
    },
    declare: (..args) => {
      declare-page(
        ..args,
        doctype: doctype,
        twoside: twoside,
        anonymous: anonymous,
        info: info + args.named().at("info", default: (:)),
        ziti: fonts,
      )
    },
    abstract: (..args) => {
      abstract-page(
        ..args,
        twoside: twoside,
        info: info + args.named().at("info", default: (:)),
        ziti: fonts,
      )
    },
    abstract-en: (..args) => {
      abstract-en-page(
        ..args,
        doctype: doctype,
        twoside: twoside,
        info: info + args.named().at("info", default: (:)),
        ziti: fonts,
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
        ziti: fonts,
      )
    },
    bib: (..args) => {
      bibliography-page(
        ..args,
        doctype: doctype,
        twoside: twoside,
        ziti: fonts,
      )
    },
    acknowledgement: (..args) => {
      acknowledgement-page(
        ..args,
        doctype: doctype,
        twoside: twoside,
        anonymous: anonymous,
        ziti: fonts,
      )
    },
    achievement: (..args) => {
      achievement-page(
        ..args,
        doctype: doctype,
        twoside: twoside,
        ziti: fonts,
      )
    },
    summary-en: (..args) => {
      summary-en-page(
        ..args,
        title: info.title-en,
        doctype: doctype,
        twoside: twoside,
        ziti: fonts,
      )
    },
  )
}
