// Used to define kilogram
#let gram = $g$

// SI units
#let ampere = $A$
#let candela = $c d$
#let kelvin = $kelvin$
#let kilogram = $k#gram$
#let metre = $m$
#let meter = metre
#let mole = $m o l$
#let second = $s$


// Derived units
#let becquerel = $B q$
#let degreeCelsius = $degree.c$
#let coulomb = $C$
#let farad = $F$
#let gray = $G y$
#let hertz = $H z$
#let henry = $H$
#let joule = $J$
#let lumen = $l m$
#let katal = $k a t$
#let lux = $l x$
#let newton = $N$
#let ohm = $ohm$
#let pascal = $P a$
#let radian = $r a d$
#let siemens = $S$
#let sievert = $S v$
#let steradian = $s r$
#let tesla = $T$
#let volt = $V$
#let watt = $W$
#let weber = $W b$

// Non-SI units
#let astronomicalunit = $a u$
#let bel = $B$
#let dalton = $D a$
#let day = $d$
#let decibel = $d#bel$
#let electronvolt = $e V$
#let hectare = $h a$
#let hour = $h$
#let litre = $L$
#let liter = litre
#let arcminute = $prime$
#let minute = $m i n$
#let arcsecond = $prime.double$
#let neper = $N p$
#let tonne = $t$
#let byte = $B$

// Unit abbreviations
#let fg = $f#gram$
#let pg = $p#gram$
#let ng = $n#gram$
#let ug = $mu#gram$
#let mg = $m#gram$
#let kg = kilogram

#let pm = $p#metre$
#let nm = $n#metre$
#let um = $mu#metre$
#let mm = $m#metre$
#let cm = $c#metre$
#let dm = $d#metre$
#let km = $k#metre$

// #let as = $a#second$
#let fs = $f#second$
#let ps = $p#second$
#let ns = $n#second$
#let us = $mu#second$
#let ms = $m#second$

#let fmol = $f#mole$
#let pmol = $p#mole$
#let nmol = $n#mole$
#let umol = $mu#mole$
#let mmol = $m#mole$
#let mol = mole
#let kmol = $k#mole$

#let pA = $p#ampere$
#let nA = $n#ampere$
#let uA = $mu#ampere$
#let mA = $m#ampere$
#let kA = $k#ampere$

#let L = $#litre$
#let uL = $mu#litre$
#let mL = $m#litre$
#let hL = $h#litre$

#let mHz = $m#hertz$
#let Hz = hertz
#let kHz = $k#hertz$
#let MHz = $M#hertz$
#let GHz = $G#hertz$
#let THz = $T#hertz$

#let mN = $m#newton$
#let kN = $k#newton$
#let MN = $M#newton$

#let Pa = pascal
#let kPa = $k#pascal$
#let MPa = $M#pascal$
#let GPa = $G#pascal$

#let mohm = $m#ohm$
#let kohm = $k#ohm$
#let Mohm = $M#ohm$

#let pV = $p#volt$
#let nV = $n#volt$
#let uV = $mu#volt$
#let mV = $m#volt$
#let kV = $k#volt$

#let nW = $n#watt$
#let uW = $mu#watt$
#let mW = $m#watt$
#let kW = $k#watt$
#let MW = $M#watt$
#let GW = $G#watt$

#let uJ = $u#joule$
#let mJ = $m#joule$
#let kJ = $k#joule$

#let eV = electronvolt
#let meV = $m#electronvolt$
#let keV = $k#electronvolt$
#let MeV = $M#electronvolt$
#let GeV = $G#electronvolt$
#let TeV = $T#electronvolt$

#let kWh = $kW h$

#let fF = $f#farad$
#let pF = $p#farad$
#let nF = $n#farad$
#let uF = $mu#farad$
#let mF = $m#farad$

#let fH = $f#henry$
#let pH = $p#henry$
#let nH = $n#henry$
#let mH = $m#henry$
#let uH = $mu#henry$

#let nC = $n#coulomb$
#let uC = $mu#coulomb$
#let mC = $m#coulomb$

#let dB = decibel

#let cd = candela
#let Bq = becquerel
#let Gy = gray
#let lm = lumen
#let kat = katal
#let lx = lux
#let rad = radian
#let Sv = sievert
#let sr = steradian
#let Wb = weber
#let au = astronomicalunit
#let Da = dalton
#let ha = hectare
#let Np = neper

#let kB = $k#byte$
#let MB = $M#byte$
#let GB = $G#byte$
#let TB = $T#byte$
#let PB = $P#byte$
#let EB = $E#byte$

#let KiB = $K i#byte$
#let MiB = $M i#byte$
#let GiB = $G i#byte$
#let TiB = $T i#byte$
#let PiB = $P i#byte$
#let EiB = $E i#byte$


#let _dict = (
  ampere: ampere,
  pA: pA,
  nA: nA,
  uA: uA,
  mA: mA,
  A: ampere,
  kA: kA,

  astronomicalunit: astronomicalunit,
  au: au,

  arcminute: arcminute,

  arcsecond: arcsecond,

  becquerel: becquerel,
  Bq: Bq,

  bel: bel,
  decibel: decibel,
  dB: dB,

  candela: candela,
  cd: cd,

  dalton: dalton,
  Da: Da,

  day: day,

  degree: sym.degree,

  degreeCelsius: sym.degree.c,

  coulomb: coulomb,
  C: coulomb,
  nC: nC,
  mC: mC,
  uC: uC,

  electronvolt: electronvolt,
  meV: meV,
  eV: eV,
  keV: keV,
  MeV: MeV,
  GeV: GeV,
  TeV: TeV,

  kWh: kWh,

  farad: farad,
  F: farad,
  fF: fF,
  pF: pF,
  nF: nF,
  uF: uF,
  mF: mF,

  gray: gray,
  Gy: Gy,

  hectare: hectare,
  ha: ha,

  henry: henry,
  H: henry,
  fH: fH,
  pH: pH,
  nH: nH,
  mH: mH,
  uH: uH,

  hertz: hertz,
  mHz: mHz,
  Hz: Hz,
  kHz: kHz,
  MHz: MHz,
  GHz: GHz,
  THz: THz,

  hour: hour,

  joule: joule,
  uJ: uJ,
  mJ: mJ,
  J: joule,
  kJ: kJ,

  katal: katal,
  kat: kat,

  kelvin: kelvin,
  K: kelvin,

  kilogram: kilogram,
  gram: gram,
  fg: fg,
  pg: pg,
  ng: ng,
  ug: ug,
  mg: mg,
  g: gram,
  kg: kg,

  litre: litre,
  liter: liter,
  uL: uL,
  mL: mL,
  L: litre,
  hL: hL,

  lumen: lumen,
  lm: lm,

  lux: lux,
  lx: lx,

  metre: metre,
  meter: meter,
  pm: pm,
  nm: nm,
  um: um,
  mm: mm,
  cm: cm,
  dm: dm,
  m: metre,
  km: km,

  minute: minute,

  mole: mole,
  fmol: fmol,
  pmol: pmol,
  nmol: nmol,
  umol: umol,
  mmol: mmol,
  mol: mol,
  kmol: kmol,

  neper: neper,
  Np: Np,

  newton: newton,
  mN: mN,
  N: newton,
  kN: kN,
  MN: MN,

  ohm: ohm,
  mohm: mohm,
  kohm: kohm,
  Mohm: Mohm,

  pascal: pascal,
  Pa: Pa,
  kPa: kPa,
  MPa: MPa,
  GPa: GPa,

  radian: radian,
  rad: rad,

  second: second,
  "as": $a#second$,
  fs: fs,
  ps: ps,
  ns: ns,
  us: us,
  ms: ms,
  s: second,

  siemens: siemens,

  sievert: sievert,
  Sv: Sv,

  steradian: steradian,
  sr: sr,

  tesla: tesla,
  T: tesla,

  tonne: tonne,

  volt: volt,
  pV: pV,
  nV: nV,
  uV: uV,
  mV: mV,
  V: volt,
  kV: kV,

  watt: watt,
  nW: nW,
  uW: uW,
  mW: mW,
  W: watt,
  kW: kW,
  MW: MW,
  GW: GW,

  weber: weber,
  Wb: Wb,

  byte: byte,
  kB: kB,
  MB: MB,
  GB: GB,
  TB: TB,
  PB: PB,
  EB: EB,
  KiB: KiB,
  MiB: MiB,
  GiB: GiB,
  TiB: TiB,
  PiB: PiB,
  EiB: EiB,

)
