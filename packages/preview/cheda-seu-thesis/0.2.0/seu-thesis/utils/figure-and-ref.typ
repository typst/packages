//  原本想改用 i-figure ，但是我发现各种要求挺烦的，最后还是用自己造的轮子了
#import "states.typ": part-state
#import "fonts.typ": 字体, 字号

// 用法: 
// #show figure: show-figure
// #show ref: show-ref
// #show 

#let tb-numbering(
  it,
  loc: none, 
  baseloc: none,   
  main-body-table-numbering: "1.1",
  main-body-image-numbering: "1-1", // 其他也会视为 image
  appendix-table-numbering: "A.1",
  appendix-image-numbering: "A-1", // 其他也会视为 image
) = {
  if part-state.at(loc) != "附录" {
    numbering(
      if it.kind == table {main-body-table-numbering} else {main-body-image-numbering}, 
      counter(heading.where(level: 1)).at(loc).first(), // 章节号
      (
        counter(figure.where(kind: it.kind))
        .at(loc)
        .first() - 
        counter(figure.where(kind: it.kind))
        .at(baseloc)
        .first()
      ) // 图序号，使用总序号减章节开始时序号实现
    )
  } else if part-state.at(loc) == "附录" {
    numbering(
      if it.kind == table {appendix-table-numbering} else {appendix-image-numbering}, 
      counter(heading.where(level: 1)).at(loc).first(), // 章节号
      (
        counter(figure.where(kind: it.kind))
        .at(loc)
        .first() - 
        counter(figure.where(kind: it.kind))
        .at(baseloc)
        .first()
      ) // 图序号，使用总序号减章节开始时序号实现
    )
  }
}

#let show-figure(
  it, 
  main-body-table-numbering: "1.1",
  main-body-image-numbering: "1-1", // 其他也会视为 image
  appendix-table-numbering: "A.1",
  appendix-image-numbering: "A-1", // 其他也会视为 image
) = {
  show figure.where(
    kind: table
  ): set figure.caption(position: top)

  show figure.caption: it => {
    if it.kind != table {
      v(0.5em)
    } // 图和图序号行间隔 0.5em

    set text(font: 字体.宋体, size: 字号.五号, weight: "regular")

    locate(loc => {
      let baseloc = query(
        selector(
          heading.where(level: 1)
        ).before(loc), 
        loc
      ).last().location()
      // 使用此一级章节的开始处作为基准点
      
      it.supplement // "图 1-1" "表 1-2" 里的 "图" "表" 字符

      tb-numbering(
        it,
        loc: loc, 
        baseloc: baseloc,   
        main-body-table-numbering: main-body-table-numbering,
        main-body-image-numbering: main-body-image-numbering,
        appendix-table-numbering: appendix-table-numbering,
        appendix-image-numbering: appendix-image-numbering,
      )
    })
    h(0.5em) // numbering 和 body 之间隔1个空格
    it.body

    // if it.kind == table {
    //   v(0.5em)
    // } // 表格序号行和表格间隔 0.5em
  }

  show figure: it => {
    if it.kind == table {
      align(center, block(it.caption))
      align(center, block(it.body))
      v(0.5em)
    } else if it.kind == image {
      v(0.5em)
      it
    }
  }
  it
}


#let show-ref(
  it,
  main-body-table-numbering: "1.1",
  main-body-image-numbering: "1-1", // 其他也会视为 image
  appendix-table-numbering: "A.1",
  appendix-image-numbering: "A-1", // 其他也会视为 image
) = {
  let el = it.element

  if el != none and el.func() == figure {
    let loc = el.location()
    let baseloc = query(
      selector(
        heading.where(level: 1)
      ).before(loc), 
      loc
    ).last().location()

    el.supplement

    tb-numbering(
      el,
      loc: loc, 
      baseloc: baseloc,   
      main-body-table-numbering: main-body-table-numbering,
      main-body-image-numbering: main-body-image-numbering,
      appendix-table-numbering: appendix-table-numbering,
      appendix-image-numbering: appendix-image-numbering,
    )
  } else if el != none and el.func() == math.equation {  
    let loc = el.location()
    el.supplement
    " "
    if part-state.at(loc) == "附录" {
      numbering("(A.1)", counter(heading.where(level:1)).at(loc).first(), counter(math.equation).at(loc).first())
    } else {
      numbering("(1.1)", counter(heading.where(level:1)).at(loc).first(), counter(math.equation).at(loc).first())
    }
  } else {
    it
  }
}

#let set-math-numbering(
  it,
  main-body-numbering: "(1.1)",
  appendix-numbering: "(A.1)",
) = {
  locate(loc => {
    if part-state.at(loc) == "附录" {
      numbering(appendix-numbering, counter(heading.where(level: 1)).at(loc).first(), counter(math.equation).at(loc).first())
    } else {
      numbering(main-body-numbering, counter(heading.where(level: 1)).at(loc).first(), counter(math.equation).at(loc).first())
    }
  })
}

// 公式序号显示：右侧最下一行
// 参考 https://github.com/typst/typst/discussions/3106
// #show math.equation: show-math-equation-degree
#let show-math-equation-degree(eq) = {
  // apply custom style only to block equations with numbering enabled
  if eq.block and eq.numbering != none {
    // default numbering of the equation
    let eqCounter = counter(math.equation).at(eq.location())
    let eqNumbering = numbering(eq.numbering, ..eqCounter)

    set align(left)
  
    grid(
      // change "0pt" to "auto" to give the numbering its own space on the line
      columns: (4em, 100% - 4em, 0pt),
      
      // note that "numbering: none" avoids infinite recursion
      h(4em),
      
      block(math.equation(eq.body, block: true, numbering: none)),

      align(right + bottom)[#eqNumbering],
    )
  } else {
    eq
  }
}

