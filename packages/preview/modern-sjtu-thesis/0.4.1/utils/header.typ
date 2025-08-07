#import "style.typ": ziti, zihao
#import "@preview/a2c-nums:0.0.1": int-to-cn-num

#let no-numbering-page-header(
  doctype: "master",
  twoside: false,
  bachelor-abs: false,
  bachelor-abs-en: false,
  bachelor-achi: false,
  bachelor-ackn: false,
  bachelor-bib: false,
  bachelor-sum: false,
  it,
) = {
  set page(
    header: context {
      set text(font: ziti.songti, size: zihao.xiaowu)
      set par(leading: 12pt, first-line-indent: 0em)

      // 获取当前标题内容
      let headingTitle = ""
      let headingNumber = ""

      // 对章节第一页做特殊处理，因为制作章节第一页的页眉时，当前章节标题还没出现
      // 所以 query 中使用 after(here())
      // 同时要 filter 出当前页的，不能把后面章节标题弄进来了
      let elems = query(selector(heading.where(level: 1)).after(here())).filter(it => (
        it.location().page() == here().page()
      ))

      if elems.len() != 0 {
        // 如果 filter 出来的结果非空，意味着我们就在章节首页
        // 在制作页眉时当前章节标题还没出现，因此章节编号要加上 1
        headingTitle = elems.last().body
      } else {
        // 如果 filter 出来的结果为空，意味着我们就在章节中间
        // 重新使用 before(here()) 进行 query 来查询章节标题
        elems = query(selector(heading.where(level: 1)).before(here()))
        headingTitle = elems.last().body
      }

      if bachelor-achi {
        headingTitle = "学术论文和科研成果目录"
      }
      if bachelor-ackn {
        headingTitle = "致谢"
      }
      if bachelor-bib {
        headingTitle = "参考文献"
      }
      if bachelor-sum or bachelor-abs or bachelor-abs-en {
        headingTitle = ""
      }

      block(height: if doctype == "bachelor" { 1cm } else { 1.75cm })

      if twoside {
        // 奇数页和偶数页的页眉是对称的
        if calc.odd(counter(page).get().first()) {
          // 奇数页左边是论文名称，右边是章节标题
          if doctype == "doctor" {
            "上海交通大学博士学位论文"
          } else if doctype == "master" {
            "上海交通大学硕士学位论文"
          } else {
            "上海交通大学学位论文"
          }
          h(1fr)
          headingTitle
        } else {
          // 偶数页对称过来
          headingTitle
          h(1fr)
          if doctype == "doctor" {
            "上海交通大学博士学位论文"
          } else if doctype == "master" {
            "上海交通大学硕士学位论文"
          } else {
            "上海交通大学学位论文"
          }
        }
      } else {
        if doctype == "doctor" {
          "上海交通大学博士学位论文"
        } else if doctype == "master" {
          "上海交通大学硕士学位论文"
        } else {
          "上海交通大学学位论文"
        }
        h(1fr)
        headingTitle
      }

      // 画出页眉的两条线，一粗一细
      v(-10pt)
      line(length: 100%, stroke: 2.2416pt)
      v(-13pt)
      line(length: 100%, stroke: 0.7472pt)
      block(height: 1fr)
    },
  )

  it
}

#let main-text-page-header(
  doctype: "master",
  twoside: false,
  it,
) = {
  set page(
    header: context {
      set text(font: ziti.songti, size: zihao.xiaowu)
      set par(leading: 12pt, first-line-indent: 0em)

      // 获取当前标题内容
      let headingTitle = ""
      let headingNumber = ""

      // 对章节第一页做特殊处理，因为制作章节第一页的页眉时，当前章节标题还没出现
      // 所以 query 中使用 after(here())
      // 同时要 filter 出当前页的，不能把后面章节标题弄进来了
      let elems = query(selector(heading.where(level: 1)).after(here())).filter(it => (
        it.location().page() == here().page()
      ))

      if elems.len() != 0 {
        // 如果 filter 出来的结果非空，意味着我们就在章节首页
        // 在制作页眉时当前章节标题还没出现，因此章节编号要加上 1
        headingTitle = elems.last().body
        headingNumber = if doctype == "bachelor" {
          "第" + int-to-cn-num(counter(heading).get().first() + 1) + "章"
        } else {
          "第" + str(counter(heading).get().first() + 1) + "章"
        }
      } else {
        // 如果 filter 出来的结果为空，意味着我们就在章节中间
        // 重新使用 before(here()) 进行 query 来查询章节标题
        elems = query(selector(heading.where(level: 1)).before(here()))
        headingTitle = elems.last().body
        headingNumber = if doctype == "bachelor" { "第" + int-to-cn-num(counter(heading).get().first()) + "章" } else {
          "第" + str(counter(heading).get().first()) + "章"
        }
      }

      block(height: if doctype == "bachelor" { 1cm } else { 1.75cm })

      if twoside {
        // 奇数页和偶数页的页眉是对称的
        if calc.odd(counter(page).get().first()) {
          // 奇数页左边是论文名称，右边是章节标题
          if doctype == "doctor" {
            "上海交通大学博士学位论文"
          } else if doctype == "master" {
            "上海交通大学硕士学位论文"
          } else {
            "上海交通大学学位论文"
          }
          h(1fr)
          headingNumber
          h(1em)
          headingTitle
        } else {
          // 偶数页对称过来
          headingNumber
          h(1em)
          headingTitle
          h(1fr)
          if doctype == "doctor" {
            "上海交通大学博士学位论文"
          } else if doctype == "master" {
            "上海交通大学硕士学位论文"
          } else {
            "上海交通大学学位论文"
          }
        }
      } else {
        if doctype == "doctor" {
          "上海交通大学博士学位论文"
        } else if doctype == "master" {
          "上海交通大学硕士学位论文"
        } else {
          "上海交通大学学位论文"
        }
        h(1fr)
        headingNumber
        h(1em)
        headingTitle
      }

      // 画出页眉的两条线，一粗一细
      v(-10pt)
      line(length: 100%, stroke: 2.2416pt)
      v(-13pt)
      line(length: 100%, stroke: 0.7472pt)
      block(height: 1fr)
    },
  )
  it
}

#let appendix-page-header(
  doctype: "master",
  twoside: false,
  it,
) = {
  set page(
    header: context {
      set text(font: ziti.songti, size: zihao.xiaowu)
      set par(leading: 12pt, first-line-indent: 0em)

      // 获取当前标题内容
      let headingTitle = ""
      let headingNumber = ""

      // 对章节第一页做特殊处理，因为制作章节第一页的页眉时，当前章节标题还没出现
      // 所以 query 中使用 after(here())
      // 同时要 filter 出当前页的，不能把后面章节标题弄进来了
      let elems = query(selector(heading.where(level: 1)).after(here())).filter(it => (
        it.location().page() == here().page()
      ))

      if elems.len() != 0 {
        // 如果 filter 出来的结果非空，意味着我们就在章节首页
        // 在制作页眉时当前章节标题还没出现，因此章节编号要加上 1
        headingTitle = if doctype == "bachelor" { h(-1em) } else { elems.last().body }
        headingNumber = if doctype == "bachelor" {
          "附录" + str(counter(heading).get().first() + 1)
        } else {
          "附录" + str.from-unicode("A".to-unicode() + counter(heading).get().first())
        }
      } else {
        // 如果 filter 出来的结果为空，意味着我们就在章节中间
        // 重新使用 before(here()) 进行 query 来查询章节标题
        elems = query(selector(heading.where(level: 1)).before(here()))
        headingTitle = if doctype == "bachelor" { h(-1em) } else { elems.last().body }
        headingNumber = if doctype == "bachelor" {
          "附录" + str(counter(heading).get().first())
        } else {
          "附录" + str.from-unicode("A".to-unicode() + counter(heading).get().first() - 1)
        }
      }

      block(height: if doctype == "bachelor" { 1cm } else { 1.75cm })

      if twoside {
        // 奇数页和偶数页的页眉是对称的
        if calc.odd(counter(page).get().first()) {
          // 奇数页左边是论文名称，右边是章节标题
          if doctype == "doctor" {
            "上海交通大学博士学位论文"
          } else if doctype == "master" {
            "上海交通大学硕士学位论文"
          } else {
            "上海交通大学学位论文"
          }
          h(1fr)
          headingNumber
          h(1em)
          headingTitle
        } else {
          // 偶数页对称过来
          headingNumber
          h(1em)
          headingTitle
          h(1fr)
          if doctype == "doctor" {
            "上海交通大学博士学位论文"
          } else if doctype == "master" {
            "上海交通大学硕士学位论文"
          } else {
            "上海交通大学学位论文"
          }
        }
      } else {
        if doctype == "doctor" {
          "上海交通大学博士学位论文"
        } else if doctype == "master" {
          "上海交通大学硕士学位论文"
        } else {
          "上海交通大学学位论文"
        }
        h(1fr)
        headingNumber
        h(1em)
        headingTitle
      }

      // 画出页眉的两条线，一粗一细
      v(-10pt)
      line(length: 100%, stroke: 2.2416pt)
      v(-13pt)
      line(length: 100%, stroke: 0.7472pt)
      block(height: 1fr)
    },
  )
  it
}

#let no-page-header(body) = {
  set page(header: none)
  body
}
