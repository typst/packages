#import "utils/style.typ": ziti, zihao
#import "layouts/doc.typ": doc
#import "layouts/preface.typ": preface
#import "layouts/mainmatter.typ": mainmatter
#import "layouts/appendix.typ": appendix
#import "pages/cover.typ": cover-page
#import "pages/cover-en.typ": cover-en-page
#import "pages/declare.typ": declare-page
#import "pages/abstract.typ": abstract-page
#import "pages/abstract-en.typ": abstract-en-page
#import "pages/outline.typ": outline-page
#import "pages/bib.typ": bibliography-page
#import "pages/acknowledgement.typ": acknowledgement-page
#import "pages/achievement.typ": achievement-page

#let documentclass(
  doctype: "master",
  date: datetime.today(),
  twoside: false,
  anonymous: false,
  info: (:),
) = {
  date = date
  info = (
    student_id: "520XXXXXXXX",
    name: "张三",
    name_en: "Zhang San",
    degree: "工学硕士",
    supervisor: "李四教授",
    supervisor_en: "Prof. Li Si",
    title: "上海交通大学学位论文格式模板",
    title_en: "DISSERTATION TEMPLATE FOR MASTER DEGREE OF ENGINEERING IN SHANGHAI JIAO TONG UNIVERSITY",
    school: "某某学院",
    school_en: "School of XXXXXXX",
    major: "某某专业",
  ) + info

  (
    doctype: doctype,
    date: date,
    twoside: twoside,
    anonymous: anonymous,
    info: info,
    doc: (..args) => {
      doc(
        ..args,
        twoside: twoside,
        info: info + args.named().at("info", default: (:)),
      )
    },
    preface: (..args) => {
      preface(
        ..args,
        doctype: doctype,
        twoside: twoside,
      )
    },
    mainmatter: (..args) => {
      mainmatter(
        ..args,
        doctype: doctype,
        twoside: twoside,
      )
    },
    appendix: (..args) => {
      appendix(
        ..args,
        doctype: doctype,
        twoside: twoside,
      )
    },
    cover: (..args) => {
      cover-page(
        ..args,
        doctype: doctype,
        twoside: twoside,
        anonymous: anonymous,
        info: info + args.named().at("info", default: (:)),
        date: date,
      )

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
      outline-page(..args, twoside: twoside)
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
  )
}