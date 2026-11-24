// One slanted folder/file panel with a tab icon and an attached number-title label.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _nftb-cubic(p0, p1, p2, p3, n: 20) = range(n + 1).map(i => {
  let t = i / n
  let u = 1 - t
  (
    u * u * u * p0.at(0) + 3 * u * u * t * p1.at(0)
      + 3 * u * t * t * p2.at(0) + t * t * t * p3.at(0),
    u * u * u * p0.at(1) + 3 * u * u * t * p1.at(1)
      + 3 * u * t * t * p2.at(1) + t * t * t * p3.at(1),
  )
})

#let _nftb-outer(w, h, rtl: false) = {
  let p = ((0.973 * w, 0pt), (0.695 * w, 0pt))
  p += _nftb-cubic(
    (0.695 * w, 0pt), (0.684 * w, 0pt),
    (0.675 * w, 0.016 * h), (0.671 * w, 0.042 * h),
  ).slice(1)
  p.push((0.655 * w, 0.129 * h))
  p += _nftb-cubic(
    (0.655 * w, 0.129 * h), (0.647 * w, 0.178 * h),
    (0.629 * w, 0.209 * h), (0.610 * w, 0.209 * h),
  ).slice(1)
  p.push((0.125 * w, 0.209 * h))
  p += _nftb-cubic(
    (0.125 * w, 0.209 * h), (0.114 * w, 0.209 * h),
    (0.104 * w, 0.227 * h), (0.100 * w, 0.254 * h),
  ).slice(1)
  p.push((0.002 * w, 0.896 * h))
  p += _nftb-cubic(
    (0.002 * w, 0.896 * h), (-0.005 * w, 0.945 * h),
    (0.008 * w, h), (0.027 * w, h),
  ).slice(1)
  p.push((0.866 * w, h))
  p += _nftb-cubic(
    (0.866 * w, h), (0.880 * w, h),
    (0.893 * w, 0.975 * h), (0.897 * w, 0.938 * h),
  ).slice(1)
  p.push((0.999 * w, 0.099 * h))
  p += _nftb-cubic(
    (0.999 * w, 0.099 * h), (1.004 * w, 0.050 * h),
    (0.991 * w, 0pt), (0.973 * w, 0pt),
  ).slice(1)
  if rtl { p.map(((x, y)) => (w - x, y)).rev() } else { p }
}

#let _nftb-inner(w, h, rtl: false) = {
  let p = ((0.938 * w, 0.330 * h), (0.868 * w, 0.901 * h))
  p += _nftb-cubic(
    (0.868 * w, 0.901 * h), (0.867 * w, 0.913 * h),
    (0.863 * w, 0.921 * h), (0.859 * w, 0.921 * h),
  ).slice(1)
  p.push((0.046 * w, 0.921 * h))
  p += _nftb-cubic(
    (0.046 * w, 0.921 * h), (0.038 * w, 0.921 * h),
    (0.033 * w, 0.899 * h), (0.036 * w, 0.880 * h),
  ).slice(1)
  p.push((0.123 * w, 0.309 * h))
  p += _nftb-cubic(
    (0.123 * w, 0.309 * h), (0.125 * w, 0.299 * h),
    (0.129 * w, 0.292 * h), (0.133 * w, 0.292 * h),
  ).slice(1)
  p.push((0.929 * w, 0.292 * h))
  p += _nftb-cubic(
    (0.929 * w, 0.292 * h), (0.936 * w, 0.291 * h),
    (0.941 * w, 0.311 * h), (0.938 * w, 0.330 * h),
  ).slice(1)
  if rtl { p.map(((x, y)) => (w - x, y)).rev() } else { p }
}

/// One folder-shaped text panel with an icon tab and a side label.
/// This draws one box only, not the source's four-item stepped stack.
#let nested-file-text-box(
  title: [],
  body: [],
  number: "01",
  icon: none,
  print-icon: none,
  width: 7.5cm,
  height: 2.7cm,
  label-width: 4.4cm,
  label-gap: 0.35cm,
  direction: auto,
  colour: rgb("#42BFEA"),
  panel-colour: auto,
  text-colour: auto,
  label-colour: auto,
  title-size: 12.5pt,
  body-size: 8.2pt,
  body-offset-x: 0pt,
  body-offset-y: 0pt,
  icon-offset-x: 0pt,
  icon-offset-y: 0pt,
  title-offset-x: 0pt,
  title-offset-y: 0pt,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let rtl = if direction == auto { is-rtl() } else { direction == std.rtl }
  set text(dir: if rtl { std.rtl } else { std.ltr })

  let folder-fill = if print-mode { luma(168) } else { colour }
  let inside-fill = if print-mode { white }
    else if panel-colour != auto { panel-colour }
    else { rgb("#F1F1F1") }
  let copy-ink = if print-mode { luma(35) }
    else if text-colour != auto { text-colour }
    else { rgb("#5B5D60") }
  let label-ink = if print-mode { black }
    else if label-colour != auto { label-colour }
    else if text-colour != auto { text-colour }
    else { rgb("#151515") }

  let outer = polygon(fill: folder-fill, stroke: none,
    .._nftb-outer(width, height, rtl: rtl))
  let inner = polygon(fill: inside-fill, stroke: none,
    .._nftb-inner(width, height, rtl: rtl))

  let body-x = width * 0.145
  let body-width = width * 0.70
  let body-box = box(width: body-width, height: height * 0.47,
    align((if rtl { right } else { left }) + top,
      text(size: body-size, fill: copy-ink, body)))

  let icon-width = width * 0.115
  let icon-height = height * 0.26
  let icon-x = if rtl { width * 0.205 } else { width * 0.680 }
  let icon-y = height * 0.015
  let icon-content = if print-mode and print-icon != none { print-icon }
    else if icon != none { icon }
    else { text(size: 14pt, weight: "bold", fill: black, [✦]) }
  let icon-box = box(width: icon-width, height: icon-height,
    align(center + horizon, icon-content))

  let total-width = width + label-gap + label-width
  let folder-x = if rtl { label-width + label-gap } else { 0pt }
  let label-x = if rtl { 0pt } else { width + label-gap }
  let label-box = box(width: label-width, height: height * 0.36,
    align((if rtl { right } else { left }) + horizon,
      text(size: title-size, weight: "bold", fill: label-ink, [#number. #title])))

  box(width: total-width, height: height, inset: 0pt, {
    place(top + left, dx: folder-x, dy: 0pt, outer)
    place(top + left, dx: folder-x, dy: 0pt, inner)
    place(top + left, dx: (folder-x + body-x) + body-offset-x, dy: (height * 0.405) + body-offset-y, body-box)
    place(top + left, dx: (folder-x + icon-x) + icon-offset-x, dy: (icon-y) + icon-offset-y, icon-box)
    place(top + left, dx: (label-x) + title-offset-x, dy: (height * 0.17) + title-offset-y, label-box)
  })
}
