/*
 * panic-page.typ
 *
 * @project: modern-ecnu-thesis
 * @author: Juntong Chen (dev@jtchen.io)
 * @created: 2025-01-05 02:03:18
 * @modified: 2025-01-08 21:34:45
 *
 * Copyright (c) 2025 Juntong Chen. All rights reserved.
 */
#import "../utils/style.typ": 字号, 字体

#let panic-page(
  body
) = {
  pagebreak(weak: true)

  align(center, text(font: 字体.等宽, size: 10pt, "Panic: " + body))
}
