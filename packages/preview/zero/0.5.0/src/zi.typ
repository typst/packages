#import "units.typ"

#let declare(..unit) = {
  assert(unit.named().len() == 0, )

  (..value) => if value.pos().len() == 0 { 
    units.unit(units.parse-unit(..unit.pos()), ..value)
  } else { 
    units.qty(..value, units.parse-unit(..unit.pos()))
  }
}

// SI base units ..
#let ampere = declare("A")
#let candela = declare("cd")
#let kelvin = declare("K")
#let kilogram = declare("kg")
#let metre = declare("m")
#let meter = metre
#let mole = declare("mol")
#let second = declare("s")

// .. and shorthands
#let A = ampere
#let cd = candela
#let K = kelvin
#let kg = kilogram
#let m = metre
#let mol = mole
#let s = second


// Derived units ..
#let becquerel = declare("Bq")
#let degreeCelsius = declare(sym.degree + "C")
#let coulomb = declare("C")
#let farad = declare("F")
#let gray = declare("Gy")
#let hertz = declare("Hz")
#let henry = declare("H")
#let joule = declare("J")
#let lumen = declare("lm")
#let katal = declare("kat")
#let lux = declare("lx")
#let newton = declare("N")
#let ohm = declare(sym.Omega)
#let pascal = declare("Pa")
#let radian = declare("rad")
#let siemens = declare("S")
#let sievert = declare("Sv")
#let steradian = declare("sr")
#let tesla = declare("T")
#let volt = declare("V")
#let watt = declare("W")
#let weber = declare("Wb")

// .. and shorthands
#let Bq = becquerel
#let C = coulomb
#let F = farad
#let Gy = gray
#let Hz = hertz
#let H = henry
#let J = joule
#let lm = lumen
#let kat = katal
#let lx = lux
#let N = newton
#let Ω = ohm
#let Pa = pascal
#let rad = radian
#let S = siemens
#let Sv = sievert
#let sr = steradian
#let T = tesla
#let V = volt
#let W = watt
#let Wb = weber


#let astronomicalunit = declare("au")
#let bel = declare("B")
#let dalton = declare("Da")
#let day = declare("d")
#let decibel = declare("dB")
#let degree = declare(sym.degree)
#let electronvolt = declare("eV")
#let hectare = declare("ha")
#let hour = declare("h")
#let litre = declare("L")
#let liter = declare("L")
#let arcminute = declare(sym.prime)
#let minute = declare("min")
#let arcsecond = declare(sym.prime.double)
#let neper = declare("Np")
#let tonne = declare("t")
#let gram = declare("g")

// Common units with prefixes
#let mm = declare("mm")
#let km = declare("km")
#let cm = declare("cm")
#let µm = declare("µm")
#let nm = declare("nm")
#let pm = declare("pm")
#let ms = declare("ms")
#let µs = declare("µs")
#let ns = declare("ns")
#let ps = declare("ps")
#let mK = declare("mK")
#let nK = declare("nK")
#let mF = declare("mF")
#let µF = declare("µF")
#let nF = declare("nF")
#let pF = declare("pF")
#let mH = declare("mH")
#let THz = declare("THz")
#let GHz = declare("GHz")
#let MHz = declare("MHz")
#let kHz = declare("kHz")
#let MJ = declare("MJ")
#let kJ = declare("kJ")
#let mJ = declare("mJ")
#let GPa = declare("GPa")
#let MPa = declare("MPa")
#let kPa = declare("kPa")
#let kPa = declare("kPa")
#let MN = declare("MN")
#let kN = declare("kN")
#let mN = declare("mN")
#let kT = declare("kT")
#let mT = declare("mT")
#let µT = declare("µT")
#let nT = declare("nT")
#let GV = declare("GV")
#let MV = declare("MV")
#let kV = declare("kV")
#let mV = declare("mV")
#let µV = declare("µV")
#let nV = declare("nV")
#let kA = declare("kA")
#let mA = declare("mA")
#let µA = declare("µA")
#let nA = declare("nA")
#let TW = declare("TW")
#let GW = declare("GW")
#let kW = declare("kW")
#let mW = declare("mW")
#let mSv = declare("mSv")


// combined units
#let m-s = declare("m/s")
#let km-h = declare("km/h")
