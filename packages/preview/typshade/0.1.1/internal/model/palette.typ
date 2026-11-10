// Copyright (C) 2026 Eito Yoneyama
// SPDX-License-Identifier: GPL-2.0

#let _color-db = (
  Black: (0, 0, 0),
  White: (255, 255, 255),
  Gray: (128, 128, 128),
  Gray0: (255, 255, 255),
  Gray5: (242, 242, 242),
  Gray10: (230, 230, 230),
  Gray15: (217, 217, 217),
  Gray20: (204, 204, 204),
  Gray25: (191, 191, 191),
  Gray30: (179, 179, 179),
  LightGray: (171, 171, 171),
  Gray35: (166, 166, 166),
  Gray40: (153, 153, 153),
  Gray45: (140, 140, 140),
  Gray50: (128, 128, 128),
  Gray55: (115, 115, 115),
  Gray60: (102, 102, 102),
  Gray65: (89, 89, 89),
  DarkGray: (87, 87, 87),
  Gray70: (77, 77, 77),
  Gray75: (64, 64, 64),
  Gray80: (51, 51, 51),
  Gray85: (38, 38, 38),
  Gray90: (26, 26, 26),
  Gray95: (13, 13, 13),
  Red: (255, 0, 0),
  Blue: (0, 0, 255),
  Green: (0, 255, 0),
  Magenta: (255, 0, 255),
  Cyan: (0, 255, 255),
  Yellow: (255, 255, 0),
  Orange: (255, 99, 33),
  YellowOrange: (255, 148, 0),
  YellowGreen: (217, 255, 79),
  Goldenrod: (255, 230, 41),
  GreenYellow: (217, 255, 79),
  RoyalBlue: (0, 128, 255),
  RoyalPurple: (64, 25, 255),
  PineGreen: (15, 191, 105),
  OliveGreen: (55, 153, 8),
  BrickRed: (184, 28, 15),
  Mahagony: (166, 25, 22),
  Brown: (102, 19, 0),
  MidnightBlue: (3, 126, 255),
  CornflowerBlue: (89, 222, 255),
  Apricot: (255, 173, 122),
  SkyBlue: (97, 255, 224),
  RedViolet: (157, 17, 168),
  CarnationPink: (255, 166, 255),
  LightMagenta: (255, 128, 255),
  LightBlue: (128, 128, 255),
  LightGreen: (128, 255, 128),
  LightRed: (255, 128, 128),
  LightBrown: (179, 107, 89),
  TC0: (153, 153, 255),
  TC1: (102, 255, 77),
  TC2: (153, 255, 77),
  TC3: (204, 255, 0),
  TC4: (255, 255, 0),
  TC5: (255, 204, 0),
  TC6: (255, 153, 0),
  TC7: (255, 102, 0),
  TC8: (255, 51, 0),
  TC9: (255, 32, 0),
  BlackWhite0: (0, 0, 0),
  BlackWhite5: (13, 13, 13),
  BlackWhite10: (26, 26, 26),
  BlackWhite15: (38, 38, 38),
  BlackWhite20: (51, 51, 51),
  BlackWhite25: (64, 64, 64),
  BlackWhite30: (77, 77, 77),
  BlackWhite35: (89, 89, 89),
  BlackWhite40: (102, 102, 102),
  BlackWhite45: (115, 115, 115),
  BlackWhite50: (128, 128, 128),
  BlackWhite55: (140, 140, 140),
  BlackWhite60: (153, 153, 153),
  BlackWhite65: (166, 166, 166),
  BlackWhite70: (179, 179, 179),
  BlackWhite75: (191, 191, 191),
  BlackWhite80: (204, 204, 204),
  BlackWhite85: (217, 217, 217),
  BlackWhite90: (230, 230, 230),
  BlackWhite95: (242, 242, 242),
  BlackWhite100: (255, 255, 255),
  WhiteBlack0: (255, 255, 255),
  WhiteBlack5: (242, 242, 242),
  WhiteBlack10: (230, 230, 230),
  WhiteBlack15: (217, 217, 217),
  WhiteBlack20: (204, 204, 204),
  WhiteBlack25: (191, 191, 191),
  WhiteBlack30: (179, 179, 179),
  WhiteBlack35: (166, 166, 166),
  WhiteBlack40: (153, 153, 153),
  WhiteBlack45: (140, 140, 140),
  WhiteBlack50: (128, 128, 128),
  WhiteBlack55: (115, 115, 115),
  WhiteBlack60: (102, 102, 102),
  WhiteBlack65: (89, 89, 89),
  WhiteBlack70: (77, 77, 77),
  WhiteBlack75: (64, 64, 64),
  WhiteBlack80: (51, 51, 51),
  WhiteBlack85: (38, 38, 38),
  WhiteBlack90: (26, 26, 26),
  WhiteBlack95: (13, 13, 13),
  WhiteBlack100: (0, 0, 0),
  BrewerA: (51, 255, 0),
  BrewerC: (166, 237, 255),
  BrewerG: (25, 179, 255),
  BrewerT: (179, 255, 140),
)

#let _scale-db = (
  BlueRed: (
    (0, (26, 26, 128)),
    (25, (110, 110, 173)),
    (50, (219, 209, 209)),
    (75, (232, 99, 94)),
    (100, (222, 41, 10)),
  ),
  RedBlue: (
    (0, (222, 38, 10)),
    (25, (232, 99, 94)),
    (50, (219, 209, 209)),
    (75, (110, 110, 173)),
    (100, (38, 43, 140)),
  ),
  GreenRed: (
    (0, (0, 255, 0)),
    (50, (115, 140, 0)),
    (100, (242, 13, 0)),
  ),
  RedGreen: (
    (0, (255, 0, 0)),
    (50, (140, 115, 0)),
    (100, (13, 242, 0)),
  ),
  ColdHot: (
    (0, (0, 0, 255)),
    (25, (0, 230, 255)),
    (50, (0, 255, 10)),
    (75, (250, 255, 0)),
    (100, (232, 0, 0)),
  ),
  HotCold: (
    (0, (255, 0, 0)),
    (25, (255, 153, 0)),
    (50, (41, 255, 0)),
    (75, (0, 255, 222)),
    (100, (0, 20, 255)),
  ),
  TCoffee: (
    (0, (153, 153, 255)),
    (10, (102, 255, 77)),
    (20, (153, 255, 77)),
    (30, (204, 255, 0)),
    (40, (255, 255, 0)),
    (50, (255, 204, 0)),
    (60, (255, 153, 0)),
    (70, (255, 102, 0)),
    (80, (255, 51, 0)),
    (90, (255, 32, 0)),
    (100, (255, 32, 0)),
  ),
)

#let _pep-groups = (
  "FYW",
  "ILVM",
  "RK",
  "DE",
  "GA",
  "ST",
  "NQ",
)

#let _pep-sims = (
  F: "YW",
  Y: "WF",
  W: "YF",
  I: "LVM",
  L: "VMI",
  V: "MIL",
  R: "KH",
  K: "HR",
  H: "RK",
  A: "GS",
  G: "A",
  S: "TA",
  T: "S",
  D: "EN",
  E: "DQ",
  N: "QD",
  Q: "NE",
)

#let _dna-groups = (
  "GAR",
  "CTY",
)

#let _dna-sims = (
  A: "GR",
  G: "AR",
  R: "AG",
  C: "TY",
  T: "CY",
  Y: "CT",
)

#let _functional-presets = (
  charge: (
    (name: "acidic (-)", residues: "DE", fg: "White", bg: "Red"),
    (name: "basic (+)", residues: "KRH", fg: "White", bg: "Blue"),
  ),
  hydropathy: (
    (name: "acidic (-)", residues: "DE", fg: "White", bg: "Red"),
    (name: "basic (+)", residues: "KRH", fg: "White", bg: "Blue"),
    (name: "polar uncharged", residues: "YSTGNQC", fg: "Black", bg: "Yellow"),
    (name: "hydrophobic nonpolar", residues: "AFPMWVIL", fg: "White", bg: "Green"),
  ),
  structure: (
    (name: "external", residues: "DEHKNQR", fg: "Black", bg: "Orange"),
    (name: "ambivalent", residues: "ACGPSTWY", fg: "Black", bg: "Yellow"),
    (name: "internal", residues: "FILMV", fg: "White", bg: "Green"),
  ),
  chemical: (
    (name: "acidic (-)", residues: "DE", fg: "White", bg: "Red"),
    (name: "aliphatic", residues: "AGVIL", fg: "White", bg: "Black"),
    (name: "aliphatic (small)", residues: "AG", fg: "White", bg: "Gray"),
    (name: "amide", residues: "NQ", fg: "White", bg: "Green"),
    (name: "aromatic", residues: "FYW", fg: "White", bg: "Brown"),
    (name: "basic (+)", residues: "KRH", fg: "White", bg: "Blue"),
    (name: "hydroxyl", residues: "ST", fg: "Black", bg: "Magenta"),
    (name: "imino", residues: "P", fg: "Black", bg: "Orange"),
    (name: "sulfur", residues: "CM", fg: "Black", bg: "Yellow"),
  ),
  rasmol: (
    (name: "Asp, Glu", residues: "DE", fg: "Red", bg: "White"),
    (name: "Arg, Lys, His", residues: "KRH", fg: "Blue", bg: "White"),
    (name: "Phe, Tyr, Trp", residues: "FYW", fg: "MidnightBlue", bg: "White"),
    (name: "Ala, Gly", residues: "AG", fg: "Gray", bg: "White"),
    (name: "Cys, Met", residues: "CM", fg: "Yellow", bg: "White"),
    (name: "Ser, Thr", residues: "ST", fg: "Orange", bg: "White"),
    (name: "Asn, Gln", residues: "NQ", fg: "Cyan", bg: "White"),
    (name: "Leu, Val, Ile", residues: "LVI", fg: "Green", bg: "White"),
    (name: "Pro", residues: "P", fg: "Apricot", bg: "White"),
  ),
  DNA: (
    (name: "C", residues: "Cc", fg: "Black", bg: "BrewerC"),
    (name: "G", residues: "Gg", fg: "White", bg: "BrewerG"),
    (name: "A", residues: "Aa", fg: "Black", bg: "BrewerA"),
    (name: "T,U", residues: "TtUu", fg: "Black", bg: "BrewerT"),
  ),
)

#let _default-logo-colors = (
  P: (
    D: "Red", E: "Red",
    C: "Yellow", M: "Yellow",
    K: "Blue", R: "Blue",
    S: "Orange", T: "Orange",
    F: "MidnightBlue", Y: "MidnightBlue",
    N: "Cyan", Q: "Cyan",
    G: "LightGray",
    L: "Green", V: "Green", I: "Green",
    A: "DarkGray",
    W: "LightMagenta",
    H: "CornflowerBlue",
    P: "Apricot",
    B: "LightMagenta", Z: "LightMagenta",
  ),
  N: (
    G: "Black",
    A: "Green",
    T: "Red",
    U: "Red",
    C: "Blue",
  ),
)

#let _logo-color-presets = (
  nucleotide: (
    (residues: "G", color: "Black"),
    (residues: "A", color: "Green"),
    (residues: "TU", color: "Red"),
    (residues: "C", color: "Blue"),
  ),
  rasmol: (
    (residues: "DE", color: "Red"),
    (residues: "CM", color: "Yellow"),
    (residues: "KR", color: "Blue"),
    (residues: "ST", color: "Orange"),
    (residues: "FY", color: "MidnightBlue"),
    (residues: "NQ", color: "Cyan"),
    (residues: "G", color: "LightGray"),
    (residues: "LVI", color: "Green"),
    (residues: "A", color: "DarkGray"),
    (residues: "W", color: "CarnationPink"),
    (residues: "H", color: "CornflowerBlue"),
    (residues: "P", color: "Apricot"),
    (residues: "BZ", color: "LightMagenta"),
  ),
  chemical: (
    (residues: "DE", color: "Red"),
    (residues: "VIL", color: "Black"),
    (residues: "AG", color: "Gray"),
    (residues: "NQ", color: "Green"),
    (residues: "FYW", color: "Brown"),
    (residues: "KRH", color: "Blue"),
    (residues: "ST", color: "Magenta"),
    (residues: "P", color: "Orange"),
    (residues: "CM", color: "Yellow"),
  ),
  hydropathy: (
    (residues: "DE", color: "Red"),
    (residues: "KRH", color: "Blue"),
    (residues: "YSTGNQC", color: "Yellow"),
    (residues: "AFPMWVIL", color: "Green"),
  ),
  structure: (
    (residues: "DEHKNQR", color: "Orange"),
    (residues: "ACGPSTWY", color: "Yellow"),
    (residues: "FILMV", color: "Green"),
  ),
  "standard area": (
    (residues: "G", color: "BrickRed"),
    (residues: "AS", color: "Orange"),
    (residues: "CP", color: "Yellow"),
    (residues: "TDVN", color: "YellowGreen"),
    (residues: "IE", color: "PineGreen"),
    (residues: "LQHM", color: "SkyBlue"),
    (residues: "FK", color: "RoyalPurple"),
    (residues: "Y", color: "RedViolet"),
    (residues: "RW", color: "Black"),
  ),
  "accessible area": (
    (residues: "C", color: "BrickRed"),
    (residues: "IVG", color: "Orange"),
    (residues: "FLMA", color: "Yellow"),
    (residues: "WSTH", color: "YellowGreen"),
    (residues: "P", color: "PineGreen"),
    (residues: "YDN", color: "SkyBlue"),
    (residues: "EQ", color: "RoyalPurple"),
    (residues: "R", color: "RedViolet"),
    (residues: "K", color: "Black"),
  ),
  hardness: (
    (residues: "ADEGILPQSTV", color: "BlueRed5"),
    (residues: "KN", color: "BlueRed20"),
    (residues: "R", color: "BlueRed40"),
    (residues: "CFH", color: "BlueRed60"),
    (residues: "MY", color: "BlueRed80"),
    (residues: "W", color: "BlueRed100"),
  ),
  DNA: (
    (residues: "A", color: "BrewerA"),
    (residues: "C", color: "BrewerC"),
    (residues: "G", color: "BrewerG"),
    (residues: "TU", color: "BrewerT"),
  ),
)

#let _rgb(tuple) = rgb(int(calc.round(tuple.at(0))), int(calc.round(tuple.at(1))), int(calc.round(tuple.at(2))))

#let _mix-rgb(a, b, ratio) = (
  int(calc.round(a.at(0) + (b.at(0) - a.at(0)) * ratio)),
  int(calc.round(a.at(1) + (b.at(1) - a.at(1)) * ratio)),
  int(calc.round(a.at(2) + (b.at(2) - a.at(2)) * ratio)),
)

#let _color-name(value) = if type(value) == str { value } else { str(value) }

#let _rgb-components(value, default: "Black") = {
  if value == none {
    return _color-db.at(default)
  }
  let key = _color-name(value)
  if _color-db.keys().contains(key) {
    return _color-db.at(key)
  }
  let scale-hit = key.matches(regex("^([A-Za-z]+)(\\d+)$"))
  if scale-hit.len() > 0 and _scale-db.keys().contains(scale-hit.first().captures.at(0)) {
    let level = int(scale-hit.first().captures.at(1))
    let points = _scale-db.at(scale-hit.first().captures.at(0))
    if level <= points.first().at(0) {
      return points.first().at(1)
    }
    if level >= points.last().at(0) {
      return points.last().at(1)
    }
    for idx in range(0, points.len() - 1) {
      let left = points.at(idx)
      let right = points.at(idx + 1)
      if level >= left.at(0) and level <= right.at(0) {
        let span = right.at(0) - left.at(0)
        let ratio = if span == 0 { 0.0 } else { (level - left.at(0)) / span }
        return _mix-rgb(left.at(1), right.at(1), ratio)
      }
    }
  }
  _color-db.at(default)
}

#let resolve-color(value, default: "Black") = {
  if value == none {
    return _rgb(_color-db.at(default))
  }
  if type(value) == color {
    return value
  }
  let key = _color-name(value)
  if key.starts-with("#") {
    return rgb(key)
  }
  if key.starts-with("rgb(") {
    return rgb(key)
  }
  let scale-hit = key.matches(regex("^([A-Za-z]+)(\\d+)$"))
  if scale-hit.len() > 0 and _scale-db.keys().contains(scale-hit.first().captures.at(0)) {
    return scale-color(scale-hit.first().captures.at(0), int(scale-hit.first().captures.at(1)))
  }
  if _color-db.keys().contains(key) {
    return _rgb(_color-db.at(key))
  }
  black
}

#let scale-color(name, value) = {
  let clamped = calc.max(0, calc.min(100, value))
  let key = _color-name(name)
  if key == "BlackWhite" or key == "WhiteBlack" {
    let scale-key = key + str(calc.round(clamped / 5) * 5)
    return resolve-color(scale-key, default: "Black")
  }
  if not _scale-db.keys().contains(key) {
    return resolve-color("Gray50")
  }
  let points = _scale-db.at(key)
  if clamped <= points.first().at(0) {
    return _rgb(points.first().at(1))
  }
  if clamped >= points.last().at(0) {
    return _rgb(points.last().at(1))
  }
  for idx in range(0, points.len() - 1) {
    let left = points.at(idx)
    let right = points.at(idx + 1)
    if clamped >= left.at(0) and clamped <= right.at(0) {
      let span = right.at(0) - left.at(0)
      let ratio = if span == 0 { 0.0 } else { (clamped - left.at(0)) / span }
      return _rgb(_mix-rgb(left.at(1), right.at(1), ratio))
    }
  }
  _rgb(points.last().at(1))
}
