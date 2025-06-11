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

#let idx-box(
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

#let with-idx-tab-box2(
  idx,
  tab,
  col,
  tab2,
  col2,
  idx-ratio: 15%,
  col-hcoef: 0.75pt,
  tab-height: 24pt,
  styles: default-styles,
  info: default-info.global,
) = {
  let b-h1 = col.at("text").len()
  let b-h2 = col2.at("text").len()
  let b-h = calc.max(b-h1, b-h2) * col-hcoef

  block(
    align(
      horizon,
      grid(
        columns: (idx-ratio, (100% - idx-ratio) / 2, (100% - idx-ratio) / 2),

        grid.cell(
          idx-box(height: b-h + tab-height, styles: styles)[#idx],
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

#let with-idx-tab-box(
  idx,
  tab,
  col,
  idx-ratio: 15%,
  col-hcoef: 0.55pt,
  tab-height: 24pt,
  styles: default-styles,
  info: default-info.global,
) = {
  let b-h = col.at("text").len() * col-hcoef

  block(
    align(
      horizon,
      grid(
        columns: (idx-ratio, (100% - idx-ratio)),

        grid.cell(
          idx-box(height: b-h + tab-height, styles: styles, info: info)[#idx],
          rowspan: 2,
        ),
        tab-box(height: tab-height, styles: styles, info: info)[#tab],
        body-box(height: b-h, styles: styles, info: info)[#col],
      ),
    ),
  )
}

#let with-idx-box2(
  idx,
  col,
  idx2,
  col2,
  idx-ratio: 15%,
  col-hcoef: 0.55pt,
  styles: default-styles,
  info: default-info.global,
) = {
  let b-h1 = col.at("text").len()
  let b-h2 = col2.at("text").len()
  let b-h = calc.max(b-h1, b-h2) * col-hcoef

  block(
    align(
      horizon,
      grid(
        columns: (idx-ratio, (100% - idx-ratio) / 2, idx-ratio * .7, (100% - idx-ratio) / 2 - idx-ratio * .7),
        idx-box(height: b-h, styles: styles, info: info)[#idx],
        body-box(height: b-h, styles: styles, info: info)[#col],
        idx-box(height: b-h, styles: styles, info: info)[#idx2],
        body-box(height: b-h, styles: styles, info: info)[#col2],
      ),
    ),
  )
}

#let with-idx-box(
  idx,
  col,
  idx-ratio: 15%,
  col-hcoef: 0.35pt,
  styles: default-styles,
  info: default-info.global,
) = {
  let b-h = col.at("text").len() * col-hcoef

  block(
    align(
      horizon,
      grid(
        columns: (idx-ratio, (100% - idx-ratio)),
        idx-box(height: b-h)[#idx], body-box(height: b-h)[#col],
      ),
    ),
  )
}

#let with-idx-tab4-box(
  idx,
  tab,
  tab2,
  tab3,
  tab4,
  idx-ratio: 15%,
  tab-height: 24pt,
  styles: default-styles,
  info: default-info.global,
) = {
  block(
    align(
      center,
      grid(
        columns: (
          idx-ratio,
          (100% - idx-ratio) / 2,
          idx-ratio * .7,
          ((100% - idx-ratio) / 2 - idx-ratio * .7) * .4,
          ((100% - idx-ratio) / 2 - idx-ratio * .7) * .6,
        ),
        idx-box(height: tab-height, styles: styles, info: info)[*#idx*],
        body-box(height: tab-height, styles: styles, info: info)[*#tab*],
        idx-box(height: tab-height, styles: styles, info: info)[*#tab2*],
        body-box(height: tab-height, styles: styles, info: info)[*#tab3*],
        body-box(height: tab-height, styles: styles, info: info)[*#tab4*],
      ),
    ),
  )
}

#let with-idx-mat32-box(
  idx,
  body,
  idx21,
  idx31,
  col21,
  idx22,
  idx32,
  col22,
  idx-ratio: 15%,
  col-hcoefs: (0.6pt, 1.35pt),
  styles: default-styles,
  info: default-info.global,
) = {
  let b-h1 = body.at("text").len()
  let b-h21 = col21.at("text").len()
  let b-h22 = col22.at("text").len()

  let (col-hcoef, col-hcoef2) = col-hcoefs
  let b-h = calc.max(b-h1 * col-hcoef, (b-h21 + b-h22) * col-hcoef2)

  block(
    grid(
      columns: (
        idx-ratio,
        (100% - idx-ratio) / 2,
        idx-ratio * .7,
        ((100% - idx-ratio) / 2 - idx-ratio * .7) * .4,
        ((100% - idx-ratio) / 2 - idx-ratio * .7) * .6,
      ),
      grid.cell(idx-box(height: b-h, styles: styles, info: info)[#idx], rowspan: 2),
      grid.cell(body-box(height: b-h, styles: styles, info: info)[#body], rowspan: 2),
      idx-box(height: b-h / 2, styles: styles, info: info)[#idx21],
      idx-box(height: b-h / 2, styles: styles, info: info)[#idx31],
      body-box(height: b-h / 2, info: info)[#col21],
      idx-box(height: b-h / 2, styles: styles, info: info)[#idx22],
      idx-box(height: b-h / 2, styles: styles, info: info)[#idx32],
      body-box(height: b-h / 2, styles: styles, info: info)[#col22],
    ),
  )
}

#let with-mat31-box(
  body,
  idx,
  row,
  idx2,
  row2,
  idx3,
  row3,
  idx-ratio: 50%,
  col-hcoefs: (0.35pt, 1.05pt),
  styles: default-styles,
  info: default-info.global,
) = {
  let b-h0 = body.at("text").len()
  let b-h1 = row.at("text").len()
  let b-h2 = row2.at("text").len()
  let b-h3 = row3.at("text").len()

  let (col-hcoef, col-hcoef2) = col-hcoefs
  let b-h = calc.max(b-h1 * col-hcoef, (b-h1 + b-h2 + b-h3) * col-hcoef2)

  block(
    align(
      horizon,
      grid(
        columns: (idx-ratio, (100% - idx-ratio) / 3, (100% - idx-ratio) / 3 * 2),

        grid.cell(body-box(height: b-h)[#body], rowspan: 3),
        idx-box(height: b-h / 2, styles: styles)[#idx],
        body-box(height: b-h / 2, styles: styles)[#row],
        idx-box(height: b-h / 4, styles: styles)[#idx2],
        body-box(height: b-h / 4, styles: styles)[#row2],
        idx-box(height: b-h / 4, styles: styles)[#idx3],
        body-box(height: b-h / 4, styles: styles)[#row3],
      ),
    ),
  )
}

