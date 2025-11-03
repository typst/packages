#import "../core/rnd.typ": *

// TODO: Fix extremely tall sweeps break, since height / 1.5 gets larger than width
// TODO: Does not support relative sweep-widths

#let bottom-left-sweep(height, width, sweep-color, sweep-width: none, sweep-text: none) = {
  context {
    let theme = state("theme-state").get()
    let sel-sweep-text
    if sweep-text == none {
      sel-sweep-text = random-string(1, 4732)
    } else {
      sel-sweep-text = sweep-text
    }

    let sel-sweep-width = if sweep-width == none { width / 1.5 } else { sweep-width }

    set text(fill: theme.elem-fg)

    box(height: height, width: width + sel-sweep-width, {
      // Top left rounded corner
      place(
        top + left,
        box(
          clip: true,
          width: height / .75,
          height: height / .75,
          radius: height / 1.5,
          [
            #place(top + left, box(fill: sweep-color, width: height / 1.5, height: height / 3)),
            #place(top + left, box(fill: sweep-color, width: height / 3, height: height / 1.5)),
          ],
        ),
      )
      // Right extending box
      place(top + right, box(
        fill: sweep-color,
        height: height / 3,
        width: sel-sweep-width,
      ))
      // Fill to right extending box
      place(top + left, dx: height / 1.5, box(
        fill: sweep-color,
        height: height / 3,
        width: width - height / 3,
      ))
      // Fill to inner rounded corner
      place(top + left, dy: height / 3, dx: height / 3, box(
        fill: sweep-color,
        height: height / 3,
        width: width - height / 3,
      ))
      // Fill for inner rounded corner
      place(top + left, dy: height / 3, dx: width, box(
        fill: sweep-color,
        width: height / 6,
        height: height / 6,
      ))
      // Overlay for inner rounded corner
      place(top + left, dy: height / 3, dx: width, box(
        fill: theme.bg,
        width: height / 3,
        height: height / 3,
        radius: height / 6,
      ))
      // Bottom  box
      place(bottom + left, box(
        fill: sweep-color,
        width: width,
        height: height / 3,
        inset: 5pt,
        align(end + bottom, sel-sweep-text),
      ))
    })
  }
}

#let bottom-right-sweep(height, width, sweep-color, sweep-width: none, sweep-text: none) = {
  context {
    let theme = state("theme-state").get()
    let sel-sweep-text
    if sweep-text == none {
      sel-sweep-text = random-string(1, 4732)
    } else {
      sel-sweep-text = sweep-text
    }

    let sel-sweep-width = if sweep-width == none { width / 1.5 } else { sweep-width }

    set text(fill: theme.elem-fg)

    box(height: height, width: width + sel-sweep-width, {
      // Top left rounded corner
      place(
        top + right,
        box(
          clip: true,
          width: height / .75,
          height: height / .75,
          radius: height / 1.5,
          [
            #place(top + right, box(fill: sweep-color, width: height / 1.5, height: height / 3)),
            #place(top + right, box(fill: sweep-color, width: height / 3, height: height / 1.5)),
          ],
        ),
      )
      // Right extending box
      place(top + left, box(
        fill: sweep-color,
        height: height / 3,
        width: sel-sweep-width,
      ))
      // Fill to right extending box
      place(top + right, dx: -height / 1.5, box(
        fill: sweep-color,
        height: height / 3,
        width: width - height / 3,
      ))
      // Fill to inner rounded corner
      place(top + right, dy: height / 3, dx: -height / 3, box(
        fill: sweep-color,
        height: height / 3,
        width: width - height / 3,
      ))
      // Fill for inner rounded corner
      place(top + right, dy: height / 3, dx: -width, box(
        fill: sweep-color,
        width: height / 6,
        height: height / 6,
      ))
      // Overlay for inner rounded corner
      place(top + right, dy: height / 3, dx: -width, box(
        fill: theme.bg,
        width: height / 3,
        height: height / 3,
        radius: height / 6,
      ))
      // Bottom  box
      place(bottom + right, box(
        fill: sweep-color,
        width: width,
        height: height / 3,
        inset: 5pt,
        align(end + bottom, sel-sweep-text),
      ))
    })
  }
}

#let top-left-sweep(height, width, sweep-color, sweep-width: none, sweep-text: none) = {
  context {
    let theme = state("theme-state").get()
    let sel-sweep-text
    if sweep-text == none {
      sel-sweep-text = random-string(1, 4732)
    } else {
      sel-sweep-text = sweep-text
    }

    let sel-sweep-width = if sweep-width == none { width / 1.5 } else { sweep-width }

    set text(fill: theme.elem-fg)

    box(height: height, width: width + sel-sweep-width, {
      // Bottom Left rounded corner
      place(top + left, dy: -height / 3, box(
        clip: true,
        width: height / .75,
        height: height / .75,
        radius: height / 1.5,
        [
          #place(bottom + left, box(fill: sweep-color, width: height / 1.5, height: height / 3))
          #place(bottom + left, box(fill: sweep-color, width: height / 3, height: height / 1.5))
        ],
      ))
      // Right extending box
      place(bottom + left, dx: width, box(fill: sweep-color, height: height / 3, width: sel-sweep-width))
      // Fill to right extending box
      place(bottom + left, dx: height / 1.5, box(
        fill: sweep-color,
        height: height / 3,
        width: width - height / 1.5,
      ))
      // // Fill for inner rounded corner
      place(bottom + left, dy: -height / 3, dx: width, box(
        fill: sweep-color,
        width: height / 6,
        height: height / 6,
      ))
      // // Overlay for inner rounded corner
      place(bottom + left, dy: -height / 3, dx: width, box(
        fill: theme.bg,
        width: height / 3,
        height: height / 3,
        radius: height / 6,
      ))
      // // Fill to inner rounded corner
      place(bottom + left, dy: -height / 3, dx: height / 3, box(
        fill: sweep-color,
        height: height / 3,
        width: width - height / 3,
      ))
      // // Top box
      place(top + left, box(
        fill: sweep-color,
        width: width,
        height: height / 3,
        inset: 5pt,
        align(end + top, sel-sweep-text),
      ))
    })
  }
}

#let top-right-sweep(height, width, sweep-color, sweep-width: none, sweep-text: none) = {
  context {
    let theme = state("theme-state").get()
    let sel-sweep-text
    if sweep-text == none {
      sel-sweep-text = random-string(1, 4732)
    } else {
      sel-sweep-text = sweep-text
    }

    let sel-sweep-width = if sweep-width == none { width / 1.5 } else { sweep-width }

    set text(fill: theme.elem-fg)

    box(height: height, width: width + sel-sweep-width, {
      // Bottom Left rounded corner
      place(top + right, dy: -height / 3, box(
        clip: true,
        width: height / .75,
        height: height / .75,
        radius: height / 1.5,
        [
          #place(bottom + right, box(fill: sweep-color, width: height / 1.5, height: height / 3))
          #place(bottom + right, box(fill: sweep-color, width: height / 3, height: height / 1.5))
        ],
      ))
      // Right extending box
      place(bottom + left, box(fill: sweep-color, height: height / 3, width: sel-sweep-width))
      // Fill to right extending box
      place(bottom + right, dx: -height / 1.5, box(
        fill: sweep-color,
        height: height / 3,
        width: width - height / 1.5,
      ))
      // // Fill for inner rounded corner
      place(bottom + right, dy: -height / 3, dx: -width, box(
        fill: sweep-color,
        width: height / 6,
        height: height / 6,
      ))
      // // Overlay for inner rounded corner
      place(bottom + right, dy: -height / 3, dx: -width, box(
        fill: theme.bg,
        width: height / 3,
        height: height / 3,
        radius: height / 6,
      ))
      // // Fill to inner rounded corner
      place(bottom + right, dy: -height / 3, dx: -height / 3, box(
        fill: sweep-color,
        height: height / 3,
        width: width - height / 3,
      ))
      // // Top box
      place(top + right, box(
        fill: sweep-color,
        width: width,
        height: height / 3,
        inset: 5pt,
        align(end + top, sel-sweep-text),
      ))
    })
  }
}
