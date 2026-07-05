#import "deps.typ": *

#let border = stroke(.5pt)

#let title-box(
  body,
  size: 20pt,
  inset: 12pt,
  styles: default-styles,
  info: default-info.global,
) = {
  let lang = info.lang

  block(
    align(
      center + horizon,
      text(body, size: size, font: styles.fonts.at(lang).title),
    ),
    inset: inset,
    width: 100%,
  )
}

#let tab-box(
  body,
  height: auto,
  inset: 8pt,
  styles: default-styles,
  info: default-info.global,
) = {
  let lang = info.lang
  block(
    align(
      center + horizon,
      text(body, font: styles.fonts.at(lang).tab),
    ),
    stroke: border,
    inset: inset,
    height: height,
    width: 100%,
  )
}

#let body-box(
  body,
  height: auto,
  inset: 8pt,
  styles: default-styles,
  info: default-info.global,
) = {
  let lang = info.lang
  block(
    align(
      horizon,
      text(body, font: styles.fonts.at(lang).tab),
    ),
    stroke: border,
    inset: inset,
    height: height,
    width: 100%,
  )
}

#let index-box(
  body,
  height: auto,
  inset: 8pt,
  styles: default-styles,
  info: default-info.global,
) = {
  let lang = info.lang
  block(
    align(
      center + horizon,
      text(body, font: styles.fonts.at(lang).tab),
    ),
    stroke: border,
    inset: inset,
    height: height,
    width: 100%,
  )
}

#let with-index-tab-box2(
  index,
  tab,
  col,
  tab2,
  col2,
  index-ratio: 15%,
  col-hcoef: .95pt,
  tab-height: 24pt,
  styles: default-styles,
  info: default-info.global,
) = {
  let b-h1 = col.children.len() * 10
  let b-h2 = col2.children.len() * 10
  let b-h = calc.max(b-h1, b-h2) * col-hcoef

  block(
    align(
      horizon,
      grid(
        columns: (index-ratio, (100% - index-ratio) / 2, (100% - index-ratio) / 2),

        grid.cell(
          index-box(height: b-h + tab-height, styles: styles)[#index],
          rowspan: 2,
        ),
        tab-box(height: tab-height, styles: styles, info: info)[#tab],
        tab-box(height: tab-height, styles: styles, info: info)[#tab2],
        body-box(height: b-h, styles: styles, info: info)[#col],
        body-box(height: b-h, styles: styles, info: info)[#col2],
      ),
    ),
  )
}

#let with-index-tab-box(
  index,
  tab,
  col,
  index-ratio: 15%,
  col-hcoef: .95pt,
  tab-height: 24pt,
  styles: default-styles,
  info: default-info.global,
) = {
  let b-h = col.children.len() * 10 * col-hcoef

  block(
    align(
      horizon,
      grid(
        columns: (index-ratio, (100% - index-ratio)),

        grid.cell(
          index-box(height: b-h + tab-height, styles: styles, info: info)[#index],
          rowspan: 2,
        ),
        tab-box(height: tab-height, styles: styles, info: info)[#tab],
        body-box(height: b-h, styles: styles, info: info)[#col],
      ),
    ),
  )
}

#let with-index-box2(
  index,
  col,
  index2,
  col2,
  index-ratio: 15%,
  col-hcoef: 1.05pt,
  styles: default-styles,
  info: default-info.global,
) = {
  let b-h1 = col.children.len() * 10
  let b-h2 = col2.children.len() * 10
  let b-h = calc.max(b-h1, b-h2) * col-hcoef

  block(
    align(
      horizon,
      grid(
        columns: (index-ratio, (100% - index-ratio) / 2, index-ratio * .7, (100% - index-ratio) / 2 - index-ratio * .7),
        index-box(height: b-h, styles: styles, info: info)[#index],
        body-box(height: b-h, styles: styles, info: info)[#col],
        index-box(height: b-h, styles: styles, info: info)[#index2],
        body-box(height: b-h, styles: styles, info: info)[#col2],
      ),
    ),
  )
}

#let with-index-box(
  index,
  col,
  index-ratio: 15%,
  col-hcoef: .95pt,
  styles: default-styles,
  info: default-info.global,
) = {
  let b-h = col.children.len() * 10 * col-hcoef

  block(
    align(
      horizon,
      grid(
        columns: (index-ratio, (100% - index-ratio)),
        index-box(height: b-h)[#index], body-box(height: b-h)[#col],
      ),
    ),
  )
}

#let with-index-tab4-box(
  index,
  tab,
  tab2,
  tab3,
  tab4,
  index-ratio: 15%,
  tab-height: 24pt,
  styles: default-styles,
  info: default-info.global,
) = {
  block(
    align(
      center,
      grid(
        columns: (
          index-ratio,
          (100% - index-ratio) / 2,
          index-ratio * .7,
          ((100% - index-ratio) / 2 - index-ratio * .7) * .4,
          ((100% - index-ratio) / 2 - index-ratio * .7) * .6,
        ),
        index-box(height: tab-height, styles: styles, info: info)[*#index*],
        body-box(height: tab-height, styles: styles, info: info)[*#tab*],
        index-box(height: tab-height, styles: styles, info: info)[*#tab2*],
        body-box(height: tab-height, styles: styles, info: info)[*#tab3*],
        body-box(height: tab-height, styles: styles, info: info)[*#tab4*],
      ),
    ),
  )
}

#let with-index-mat32-box(
  index,
  body,
  index21,
  index31,
  col21,
  index22,
  index32,
  col22,
  index-ratio: 15%,
  col-hcoefs: (0.8pt, .75pt),
  styles: default-styles,
  info: default-info.global,
) = {
  let b-h1 = body.children.len() * 10
  let b-h21 = col21.children.len() * 10
  let b-h22 = col22.children.len() * 10

  let (col-hcoef, col-hcoef2) = col-hcoefs
  let b-h = calc.max(b-h1 * col-hcoef, (b-h21 + b-h22) * col-hcoef2)

  block(
    grid(
      columns: (
        index-ratio,
        (100% - index-ratio) / 2,
        index-ratio * .7,
        ((100% - index-ratio) / 2 - index-ratio * .7) * .4,
        ((100% - index-ratio) / 2 - index-ratio * .7) * .6,
      ),
      grid.cell(index-box(height: b-h, styles: styles, info: info)[#index], rowspan: 2),
      grid.cell(body-box(height: b-h, styles: styles, info: info)[#body], rowspan: 2),
      index-box(height: b-h / 2, styles: styles, info: info)[#index21],
      index-box(height: b-h / 2, styles: styles, info: info)[#index31],
      body-box(height: b-h / 2, info: info)[#col21],
      index-box(height: b-h / 2, styles: styles, info: info)[#index22],
      index-box(height: b-h / 2, styles: styles, info: info)[#index32],
      body-box(height: b-h / 2, styles: styles, info: info)[#col22],
    ),
  )
}

#let with-mat31-box(
  body,
  index,
  row,
  index2,
  row2,
  index3,
  row3,
  index-ratio: 50%,
  col-hcoefs: (0.35pt, 1.05pt),
  styles: default-styles,
  info: default-info.global,
) = {
  let b-h0 = body.children.len() * 10
  let b-h1 = row.at("text").len()
  let b-h2 = row2.at("text").len()
  let b-h3 = row3.at("text").len()

  let (col-hcoef, col-hcoef2) = col-hcoefs
  let b-h = calc.max(b-h1 * col-hcoef, (b-h1 + b-h2 + b-h3) * col-hcoef2)

  block(
    align(
      horizon,
      grid(
        columns: (index-ratio, (100% - index-ratio) / 3, (100% - index-ratio) / 3 * 2),

        grid.cell(body-box(height: b-h)[#body], rowspan: 3),
        index-box(height: b-h / 2, styles: styles)[#index],
        body-box(height: b-h / 2, styles: styles)[#row],
        index-box(height: b-h / 4, styles: styles)[#index2],
        body-box(height: b-h / 4, styles: styles)[#row2],
        index-box(height: b-h / 4, styles: styles)[#index3],
        body-box(height: b-h / 4, styles: styles)[#row3],
      ),
    ),
  )
}
