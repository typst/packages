// icons.typ — 自繪 SVG 圖示（stroke 風格、24×24 viewBox，無外部依賴）
// 新增圖示：在 `_icons` 加一筆 `名稱: "<path d='…'/>"`，即可用 `#ic("名稱")`。
// 需要填色的部分寫 `fill='currentColor'`，會套用 ic() 的 color。

#import "palette.typ": c

#let _icons = (
  scale: "<path d='M12 3v18'/><path d='M7 21h10'/><path d='M4 7h16'/><path d='M7 7l-3 7h6z'/><path d='M17 7l-3 7h6z'/>",
  school: "<path d='M3 21h18'/><path d='M5 21V10l7-5 7 5v11'/><path d='M10 21v-5h4v5'/><path d='M12 9.5v.01'/>",
  court: "<path d='M3 21h18'/><path d='M4 18h16'/><path d='M12 3l9 6H3z'/><path d='M6 11v5M10 11v5M14 11v5M18 11v5'/>",
  user: "<circle cx='12' cy='8' r='4'/><path d='M4 21a8 8 0 0 1 16 0'/>",
  users: "<circle cx='9' cy='8' r='3.5'/><path d='M2 21a7 7 0 0 1 14 0'/><path d='M16 4.5a3.5 3.5 0 0 1 0 7'/><path d='M18 14.5a7 7 0 0 1 4 6.5'/>",
  file: "<path d='M14 3H6a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9z'/><path d='M14 3v6h6'/><path d='M8 13h8M8 17h6'/>",
  check: "<path d='M20 6L9 17l-5-5'/>",
  x: "<path d='M18 6L6 18M6 6l12 12'/>",
  yes: "<circle cx='12' cy='12' r='9'/><path d='M8 12l3 3 5-6'/>",
  no: "<circle cx='12' cy='12' r='9'/><path d='M9 9l6 6M15 9l-6 6'/>",
  maybe: "<circle cx='12' cy='12' r='9'/><path d='M9.5 9a2.5 2.5 0 1 1 3.5 2.3c-.7.3-1 .9-1 1.7'/><path d='M12 17h.01'/>",
  book: "<path d='M4 19.5A2.5 2.5 0 0 1 6.5 17H20V3H6.5A2.5 2.5 0 0 0 4 5.5z'/><path d='M4 19.5A2.5 2.5 0 0 0 6.5 22H20v-5'/>",
  shield: "<path d='M12 3l8 3v6c0 5-3.5 8-8 9-4.5-1-8-4-8-9V6z'/><path d='M9 12l2 2 4-4'/>",
  speech: "<path d='M21 12a8 8 0 0 1-11.6 7.1L4 20l1-4.6A8 8 0 1 1 21 12z'/>",
  bulb: "<path d='M9 18h6M10 21h4'/><path d='M12 3a6 6 0 0 0-4 10.5c.7.7 1 1.5 1 2.5h6c0-1 .3-1.8 1-2.5A6 6 0 0 0 12 3z'/>",
  repair: "<path d='M3 12a9 9 0 0 1 15.5-6.3L21 8'/><path d='M21 3v5h-5'/><path d='M21 12a9 9 0 0 1-15.5 6.3L3 16'/><path d='M3 21v-5h5'/>",
  cap: "<path d='M2 9l10-5 10 5-10 5z'/><path d='M6 11v5c3 2.5 9 2.5 12 0v-5'/><path d='M22 9v6'/>",
  mail: "<rect x='3' y='5' width='18' height='14' rx='2'/><path d='M3 7l9 6 9-6'/>",
  bell: "<path d='M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9'/><path d='M10.3 21a1.9 1.9 0 0 0 3.4 0'/>",
  globe: "<circle cx='12' cy='12' r='9'/><path d='M3 12h18'/><path d='M12 3a14 14 0 0 1 0 18a14 14 0 0 1 0-18'/>",
  search: "<circle cx='11' cy='11' r='7'/><path d='M21 21l-4.3-4.3'/>",
  lock: "<rect x='4' y='11' width='16' height='10' rx='2'/><path d='M8 11V7a4 4 0 0 1 8 0v4'/>",
  coin: "<circle cx='12' cy='12' r='9'/><path d='M15 9.5c-.5-1-1.6-1.5-3-1.5-1.7 0-3 .9-3 2s1.3 1.7 3 2 3 .9 3 2-1.3 2-3 2c-1.4 0-2.5-.5-3-1.5'/><path d='M12 6v2M12 16v2'/>",
  alert: "<path d='M12 3L2 20h20z'/><path d='M12 10v4M12 17h.01'/>",
  eye: "<path d='M2.5 12S6 6 12 6s9.5 6 9.5 6-3.5 6-9.5 6-9.5-6-9.5-6z'/><circle cx='12' cy='12' r='3'/>",
  eyeoff: "<path d='M3 3l18 18'/><path d='M10.6 6.1A10 10 0 0 1 12 6c6 0 9.5 6 9.5 6a17 17 0 0 1-2.7 3.3M6.6 6.6A17 17 0 0 0 2.5 12S6 18 12 18a9.7 9.7 0 0 0 5.4-1.6'/>",
  target: "<circle cx='12' cy='12' r='9'/><circle cx='12' cy='12' r='5'/><circle cx='12' cy='12' r='1'/>",
  pen: "<path d='M12 20h9'/><path d='M16.5 3.5a2.1 2.1 0 0 1 3 3L7 19l-4 1 1-4z'/>",
  layers: "<path d='M12 3l9 5-9 5-9-5z'/><path d='M3 13l9 5 9-5'/><path d='M3 17l9 5 9-5'/>",
  arrow: "<path d='M5 12h14M13 6l6 6-6 6'/>",
  down: "<path d='M12 5v14M6 13l6 6 6-6'/>",
  link: "<path d='M10 14a5 5 0 0 0 7 0l3-3a5 5 0 0 0-7-7l-1 1'/><path d='M14 10a5 5 0 0 0-7 0l-3 3a5 5 0 0 0 7 7l1-1'/>",
  vote: "<path d='M3 13h18v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z'/><path d='M8 13V4h8v9'/><path d='M10.5 8.5l1.3 1.3 2.2-2.6'/><path d='M7 17h10'/>",
  plus: "<circle cx='12' cy='12' r='9'/><path d='M12 8v8M8 12h8'/>",
  ban: "<circle cx='12' cy='12' r='9'/><path d='M5.6 5.6l12.8 12.8'/>",
  half: "<circle cx='12' cy='12' r='9'/><path d='M12 3a9 9 0 0 0 0 18z' fill='currentColor'/>",
)

#let ic(name, color: c.accent, size: 1em) = box(
  baseline: 0.15em,
  image(
    bytes(
      "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' color='"
        + color.to-hex()
        + "' stroke='"
        + color.to-hex()
        + "' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'>"
        + _icons.at(name)
        + "</svg>",
    ),
    format: "svg",
    height: size,
  ),
)
