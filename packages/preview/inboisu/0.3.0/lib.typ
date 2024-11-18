/// Invoice document function
///
/// Usage:
/// #example(`#show: it => doc(client: "超すごい出版 御中", client-details: "〒123-4567 東京都千代田区丸の内1-2-3", it), mode: "markup")
///
/// - title (str): Title of the document
/// - client (str): client of the document
/// - client-details (str): Details of the client
/// - fonts (dict): Fonts of the document
/// - date (datetime): Date of the document
/// - date-display (fn): Date display function
/// - due-date (datetime): Due date of the document
/// - qualified-invoice-number (str): Qualified invoice number of the document. `none` if not qualified.
/// - transfer-destination (list): Transfer destination of the document
/// - tax-rate (float): Tax rate of the document
/// - items (list): Items of the document
/// - notes (list): Notes of the document
/// - body (list): Body of the document
#import "utils/number.typ": n
#import "@preview/tablex:0.0.9": tablex, cellx, hlinex
#let doc(
  title: "請求書",
  client: "名無し　様",
  client-details: none,
  vendor: "ねこかわショップ",
  vendor-details: none,
  invoice-details: none,
  fonts: (
    title-ja: "Noto Sans CJK JP",
    title-en: "Roboto",
    body-ja: "Noto Sans CJK JP",
    body-en: "Roboto",
  ),
  date: datetime.today(),
  date-title: "請求日",
  date-display: date => date.display("[year]年[month]月[day]日"),
  invoice-number: "1234567890",
  invoice-number-title: "請求書番号",
  billing-text: [下記の通りご請求申し上げます。],
  billing-text-below: none,
  transfer-destination: none,
  due-date: none,
  due-date-title: "お支払期限",
  tax-rate: 10%,
  total-title: "ご請求金額",
  total-box-style: (),
  qualified-invoice-number: none,
  items: (),
  notes: none,
  notes-outside: none,
  body,
) = {
  {
    v(1em)
    set align(center)
    set text(weight: "bold", size: 1.5em, font: fonts.title-ja)
    title
    v(1em)
  }
  set text(font: (fonts.body-en, fonts.body-ja))

  grid(
    columns: (1fr, 1fr),
    column-gutter: 2em,
    {
      client
      v(0.5em, weak: true)
      line(length: 100%, stroke: 0.5pt + black)
      client-details
      v(1em)
      h(1em)
      box(invoice-details)
    },
    {
      grid(
        columns: (1fr, 1fr),
        row-gutter: 0.5em,
        align: (left, right),
        invoice-number-title, invoice-number,
        ..if date != none {
          (date-title, date-display(date))
        },
        ..if due-date != none {
          (due-date-title, date-display(due-date))
        },
      )
      v(1em)
      text(weight: "bold", vendor)
      v(0.2em)
      h(1fr)
      box(vendor-details)
      h(1fr)
    },
  )


  billing-text

  let subtotal = items.map(it => it.price * it.amount).sum()
  let tax = if tax-rate != none {
    subtotal * (float(tax-rate))
  } else {
    0
  }
  let total = subtotal + tax

  v(0.5em)
  par([
    #total-title \
    #box(
      width: 50%,
      stroke: 0.5pt + black,
      inset: (
        x: 0.5em,
        y: 1em,
      ),
      {
        h(1fr)
        set text(size: 1.5em)
        n(total) + "円"
      },
      ..total-box-style,
    )
  ])

  // title
  v(1em)

  billing-text-below


  tablex(
    columns: (1fr, auto, auto, auto),
    // map-hlines: h => (..h.filter(it => it.y == 1),),
    auto-hlines: false,
    ..("品目",
    "単価",
    "数量",
    "金額").map(it => text(weight: "bold", it)),
    hlinex(stroke: 0.5pt + black),
    column-gutter: 1em,
    auto-vlines: false,
    map-cells: c => (..c, inset: 0.5em),
    // map-vlines: v =>
    //   (..v, stroke:  if not (0, 4).contains(v.x) { 0.5pt + black } else {none})
    // ,
    ..for (i, item) in items.enumerate() {
      (
        item.name,
        n(item.price),
        str(item.amount),
        n(item.price * item.amount),
      ).map(it => cellx(
        fill: if calc.rem(i, 2) == 0 {
          none
        } else {
          gray
        },
        align: (left, right, right, right),
        it,
      ))
    },
  )



  grid(
    columns: (1fr, 1fr),
    none,
    grid(
      columns: (1fr, 1fr),
      align: (left, right),
      gutter: (1em, 1em),
      text(weight: "bold")[小計],
      n(subtotal) + "円",
      ..if tax-rate != none {
        (text(weight: "bold")[消費税], n(tax) + "円")
      } else {
        ()
      },
      ..(text(weight: "bold")[合計], n(total) + "円"),
      ..if tax-rate != none {
        (text(weight: "bold", size: 0.8em)[内訳 #str(float(tax-rate) * 100)%対象],)
      } else {
        ()
      },
    ),
  )

  body

  v(1fr)

  if transfer-destination != none {
    text(weight: "bold")[振込先]
    box(
      width: 100%,
      stroke: 0.5pt + black,
      inset: 1em,
      transfer-destination,
    )
    v(1em)
  }

  text(weight: "bold")[備考]

  box(
    width: 100%,
    stroke: 0.5pt + black,
    inset: 1em,
    if notes != none {
      notes
    } else {
      "特になし"
    },
  )

  v(1em)
  notes-outside
}
