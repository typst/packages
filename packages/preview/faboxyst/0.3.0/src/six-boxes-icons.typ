// Internal SVG symbols shared by the SlideEgg six-box style components.
#let six-box-icon(size, ink, kind) = {
  let head = "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 96 96\" fill=\"none\" stroke=\"" + ink.to-hex() + "\" stroke-width=\"4.2\" stroke-linecap=\"round\" stroke-linejoin=\"round\">"
  let k = calc.rem(kind, 6)
  let art = if k == 0 {
    "<rect x=\"18\" y=\"34\" width=\"60\" height=\"43\" rx=\"5\"/><path d=\"M35 34v-8q0-5 5-5h16q5 0 5 5v8M18 51h60M42 49v8h12v-8\"/>"
  } else if k == 1 {
    "<circle cx=\"38\" cy=\"39\" r=\"17\"/><circle cx=\"64\" cy=\"61\" r=\"12\"/><circle cx=\"38\" cy=\"39\" r=\"6\"/><circle cx=\"64\" cy=\"61\" r=\"4\"/><path d=\"M38 14v8M38 56v8M13 39h8M55 39h8M20 21l6 6M50 51l6 6M20 57l6-6M50 27l6-6M64 42v7M64 73v7M45 61h7M76 61h7\"/>"
  } else if k == 2 {
    "<circle cx=\"43\" cy=\"56\" r=\"25\"/><circle cx=\"43\" cy=\"56\" r=\"14\"/><circle cx=\"43\" cy=\"56\" r=\"4\"/><path d=\"M44 55 75 24M61 24h14v14M67 31l7 7\"/>"
  } else if k == 3 {
    "<path d=\"M15 78h67M23 74V54h12v20M43 74V40h12v34M63 74V27h12v47M18 43l20-16 14 7 25-21M66 13h11v11\"/>"
  } else if k == 4 {
    "<circle cx=\"62\" cy=\"30\" r=\"16\"/><path d=\"M62 20v20M56 25c0-5 12-5 12 1s-12 4-12 10 12 6 12 0M14 71c8-10 17-15 27-15h12l10 4h13c5 0 7 5 3 8L61 81H34l-9-5h-8M42 56v-7c0-6 9-6 9 0v7\"/>"
  } else {
    "<path d=\"M29 18h38v8l-5 19 17 20H17l17-20-5-19v-8ZM29 26h38M43 41l5-7 5 7 8 2-6 6 1 8-8-4-8 4 1-8-6-6 8-2Z M38 65l-8 15M58 65l8 15\"/>"
  }
  image(bytes(head + art + "</svg>"), format: "svg", width: size, height: size)
}
