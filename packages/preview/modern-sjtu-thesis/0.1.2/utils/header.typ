#import "style.typ": ziti, zihao

#let no-numbering-page-header(
  doctype: "master",
  twoside: false,
  it,
) = {
  set page(header: context {
    set text(font: ziti.songti, size: zihao.xiaowu)
    set par(leading: 12pt)

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

    if twoside {
      // 奇数页和偶数页的页眉是对称的
      if calc.odd(counter(page).get().first()) {
        // 奇数页左边是论文名称，右边是章节标题
        if doctype == "doctor" {
          "上海交通大学博士学位论文"
        } else {
          "上海交通大学硕士学位论文"
        }
        h(1fr)
        headingTitle
      } else {
        // 偶数页对称过来
        headingTitle
        h(1fr)
        if doctype == "doctor" {
          "上海交通大学博士学位论文"
        } else {
          "上海交通大学硕士学位论文"
        }
      }
    } else {
      if doctype == "doctor" {
        "上海交通大学博士学位论文"
      } else {
        "上海交通大学硕士学位论文"
      }
      h(1fr)
      headingTitle
    }

    // 画出页眉的两条线，一粗一细
    v(-10pt)
    line(length: 100%, stroke: 2.2416pt)
    v(-13pt)
    line(length: 100%, stroke: 0.7472pt)
  })

  it
}

#let main-text-page-header(
  doctype: "master",
  twoside: false,
  it,
) = {
  set page(header: context {
    set text(font: ziti.songti, size: zihao.xiaowu)
    set par(leading: 12pt)

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
      headingNumber = "第" + str(counter(heading).get().first() + 1) + "章"
    } else {
      // 如果 filter 出来的结果为空，意味着我们就在章节中间
      // 重新使用 before(here()) 进行 query 来查询章节标题
      elems = query(selector(heading.where(level: 1)).before(here()))
      headingTitle = elems.last().body
      headingNumber = "第" + str(counter(heading).get().first()) + "章"
    }

    if twoside {
      // 奇数页和偶数页的页眉是对称的
      if calc.odd(counter(page).get().first()) {
        // 奇数页左边是论文名称，右边是章节标题
        if doctype == "doctor" {
          "上海交通大学博士学位论文"
        } else {
          "上海交通大学硕士学位论文"
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
        } else {
          "上海交通大学硕士学位论文"
        }
      }
    } else {
      if doctype == "doctor" {
        "上海交通大学博士学位论文"
      } else {
        "上海交通大学硕士学位论文"
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
  })
  it
}

#let appendix-page-header(
  doctype: "master",
  twoside: false,
  it,
) = {
  set page(header: context {
    set text(font: ziti.songti, size: zihao.xiaowu)
    set par(leading: 12pt)

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
      headingNumber = "附录" + str.from-unicode("A".to-unicode() + counter(heading).get().first())
    } else {
      // 如果 filter 出来的结果为空，意味着我们就在章节中间
      // 重新使用 before(here()) 进行 query 来查询章节标题
      elems = query(selector(heading.where(level: 1)).before(here()))
      headingTitle = elems.last().body
      headingNumber = "附录" + str.from-unicode("A".to-unicode() + counter(heading).get().first() - 1)
    }

    if twoside {
      // 奇数页和偶数页的页眉是对称的
      if calc.odd(counter(page).get().first()) {
        // 奇数页左边是论文名称，右边是章节标题
        if doctype == "doctor" {
          "上海交通大学博士学位论文"
        } else {
          "上海交通大学硕士学位论文"
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
        } else {
          "上海交通大学硕士学位论文"
        }
      }
    } else {
      if doctype == "doctor" {
        "上海交通大学博士学位论文"
      } else {
        "上海交通大学硕士学位论文"
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
  })
  it
}

#let no-page-header(body) = {
  set page(header: none)
  body
}