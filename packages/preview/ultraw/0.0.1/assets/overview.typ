#import "../export/main.typ": *
#import "utils.typ": *

#set page(width: 23cm + 6pt, height: auto, margin: 3pt)

#highlights.add(
  (
    ..highlights.box(color: olive),
    ldel: "*$",
    rdel: "$*",
    sticky: true,
    expand: none,
  ),
  (
    ldel: "*g|",
    rdel: "|g*",
    code-style: it => box(text(fill: gradient.linear(..color.map.rainbow), it)),
    fill: none,
    stroke: none,
  ),
)

#grid(
  columns: (auto, 1fr, auto),
  column-gutter: 3pt,
  align: bottom,

  uraw(
    ..themes.note,
    highlights: (
      (
        line: (8, 12),
        fill: teal.transparentize(70%),
        stroke: teal.darken(30%),
        radius: 3pt,
        expand: left,
      ),
      (line: 14, expand: center, fill: gradient.linear(..color.map.flare)),
    ),
    ````typ
    = Using the *:ultraw:* package

    // It is as simple as that:
    #show: uraw

    You can now write *g|beautiful|g* raw
    text by simply typing it:
    ```rs
    fn main() {
        println!("Hello World!");
    }
    ```

    == Styling

    *:Markers, highlights, or comments:*
    are easily defined. You can even
    write *:pseudo code:* and *:diffs:*.
    ````,
  ),

  align(center + horizon, uraw-pseudo(header: [*Algorithm* Merge Sort])[
    #pseudo-info[*Procedure* MERGE-SORT($L$)]
    + $n <-$ the length of $L$
    + *if* $n <= 1$ *then*
      + *return* $L$
    + *end if*
    + $h <- n / 2$
    + $L_1 <- L[{0, 1, ..., h-1}]$
    + $L_2 <- L[{h, h + 1, ..., n-1}]$
    + $L_1 <-$ MERGE-SORT($L_1$)
    + $L_2 <-$ MERGE-SORT($L_2$)
    + *return* MERGE($L_1$, $L_2$)
  ]),

  grid.cell(rowspan: 2, uraw(
    ..themes.window,
    header: style.window-header[The Merge Sort algorithm in Python.],
    line-spacing: 0.75em,
    lang-tag-fill: blue.lighten(75%),
    highlights: (
      (
        line: (7, 10),
        ..highlights.box(color: orange),
        expand: none,
        fill: orange.transparentize(80%),
      ),
    ),
    markers: (15, octique("alert", color: red)),
    comments: (
      (
        after: 4,
        content: text(
          style: "italic",
          olive,
        )[Safety condition to avoid out-of-bounds indices],
        indent: true,
        marker: octique("feed-issue-closed", color: olive),
        marker-placement: "markers",
        fill: none,
      ),
      (
        after: 5,
        content: [Construction of `l`: #merge-diagram],
        marker: [],
      ),
      (
        after: 11,
        content: [$O($`l1.len()` $+$ `l2.len()`$)$],
        marker: octique-inline("stopwatch"),
      ),
      (
        after: 19,
        content: [$O(h dot log(h))$],
        marker: octique-inline("stopwatch"),
        indent: true,
      ),
      (
        after: 20,
        content: [$O(h dot log(h))$],
        marker: octique-inline("stopwatch"),
        indent: true,
      ),
      (
        after: 21,
        content: [$O(2 h dot log(h) + (h + h)) = O(n dot log(n))$ #text(
            olive,
          )[*✓*]],
        marker: octique-inline("stopwatch"),
      ),
    ),
    ```py
    def merge(l1, l2):
        n = len(l1) + len(l2)
        *$l1.append(float("inf"))
        l2.append(float("inf"))$*
        l = []
        for _ in range(n):
            if l1[0] <= l2[0]:
                l.append(l1.pop(0))
            else:
                l.append(l2.pop(0))
        return l

    def merge_sort(l):
        if len(l) <= 1:
            *!return l!*
        h = int(len(l) / 2)
        l1 = l[:h]
        l2 = l[h:]
        l1 = merge_sort(l1)
        l2 = merge_sort(l2)
        return merge(l1, l2)
    ```,
  )),

  grid.cell(colspan: 2, uraw-diff(
    ..themes.dark,
    header: [`merge_sort` correction],
    line-spacing: 0.8em,
    lang-tag-fill: blue.darken(30%),
    columns: (1fr, 1fr),
    comments: (
      (
        before: 2,
        content: [`l` is returned directly when `merge` returns a copy:],
        version: "old",
        indent: true,
      ),
    ),
    ```py
    def merge_sort(l):
        if len(l) <= 1:
            return l
        h = int(len(l) / 2)
        l1 = l[:h]
        l2 = l[h:]
        l1 = merge_sort(l1)
        l2 = merge_sort(l2)
        return merge(l1, l2)
    ```,
    ```py
    def merge_sort(l):
        if len(l) == 0:
            return []
        elif len(l) == 1:
            return [l[0]]
        h = int(len(l) / 2)
        l1 = l[:h]
        l2 = l[h:]
        l1 = merge_sort(l1)
        l2 = merge_sort(l2)
        return merge(l1, l2)
    ```,
  )),
)
