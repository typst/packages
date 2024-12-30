#import "utils/number.typ": n
#import "@preview/tablex:0.0.9": tablex, cellx, hlinex

/// インボイスドキュメント関数 / Invoice document function
///
/// - title (str): ドキュメントのタイトル / Title of the document
/// - client (str): 顧客 / client of the document
/// - client-details (str): 顧客の詳細 / Details of the client
/// - vendor (str): Name of the vendor/seller
/// - vendor-details (content): ベンダーの詳細 / Details of the vendor
/// - vendor-details-below (content): ベンダーの詳細を下に表示 / Additional vendor details to display below
/// - invoice-details (content): 請求書の詳細 / Additional invoice details
/// - fonts (dict): フォントの設定 / Fonts of the document
/// - date (datetime): Date of the document
/// - date-title (str): 日付のラベル / Label for the date field
/// - date-display (fn): 日付の表示関数 / Date display function
/// - invoice-number (str): 請求書番号 / Invoice number
/// - invoice-number-title (str): 請求書番号のラベル / Label for the invoice number
/// - invoice-properties (dict): 請求書の追加プロパティ / Additional invoice properties to display
/// - billing-text (content): 合計金額の上に表示されるテキスト / Text displayed above the total amount
/// - billing-text-below (content): 合計金額の下に表示されるテキスト / Text displayed below the total amount
/// - due-date (datetime): 支払期限 / Due date of the document
/// - due-date-title (str): 支払期限のラベル / Label for the due date
/// - tax-rate (float): 税率 / Tax rate of the document
/// - total-title (str): 合計金額のラベル / Label for the total amount
/// - total-box-style (dict): 合計金額のスタイルプロパティ / Style properties for the total amount box
/// - qualified-invoice-number-title (str): 適格請求書番号のラベル / Label for the qualified invoice number
/// - qualified-invoice-number (str): 適格請求書番号 / Qualified invoice number of the document. `none` if not qualified.
/// - transfer-destination (list): 振込先 / Transfer destination of the document
/// - items (list): 項目 / Items of the document
/// - notes (content): 備考 / Notes of the document
/// - notes-outside (content): 備考の外側に表示されるテキスト / Additional notes displayed outside the notes box
/// - body (list): 本文 / Body of the document
/// -> content
#let doc(
  title: "請求書",
  client: "名無し　様",
  client-details: none,
  vendor: "ねこかわショップ",
  vendor-details: none,
  vendor-details-below: none,
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
  invoice-properties: (:),
  billing-text: [下記の通りご請求申し上げます。],
  billing-text-below: none,
  transfer-destination: none,
  due-date: none,
  due-date-title: "お支払期限",
  tax-rate: 10%,
  total-title: "ご請求金額",
  total-box-style: (),
  qualified-invoice-number-title: "適格請求書番号",
  qualified-invoice-number: none,
  items: (),
  notes: none,
  notes-outside: none,
  body,
) = {
  // Calculations
  let subtotal = items.map(it => it.price * it.amount).sum(default: 0)
  let tax = if tax-rate != none {
    subtotal * (float(tax-rate))
  } else {
    0
  }
  let total = subtotal + tax

  // Rendering
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
      v(0.5em)
      h(1em)
      box(invoice-details)
      v(0.5em)


      billing-text


      v(0.5em)
      par([
        #total-title \
        #box(
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
        ..invoice-properties.pairs().map(x => (x.at(0), x.at(1))).flatten(),
        ..if qualified-invoice-number != none {
          (qualified-invoice-number-title, qualified-invoice-number)
        },
      )
      v(1em)
      text(weight: "bold", vendor)
      v(0.2em)
      h(1fr)
      box(vendor-details)
      h(1fr)
      v(0.5em)
      vendor-details-below
    },
  )



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
    column-gutter: 0pt,
    auto-vlines: false,
    map-cells: c => (..c, inset: (x: 1em, y: 0.5em)),
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
          rgb(200, 200, 200)
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
