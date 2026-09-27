// Couleurs de la charte ECE
#let ece = rgb("#007A7B")
#let gamboge = rgb("#E39B0F")
#let darkpowderblue = rgb("#003399")
#let verylightgray = rgb("#F0F0F0")
#let warning-red = rgb("#D32F2F")

// Polices recommandées
#let font-presets = (
  "arial": "Arial",
  "latex": "New Computer Modern",
  "typst-modern": "Libertinus Serif",
  "modern-sans": ("Helvetica Neue", "Arial"),
  "editorial": ("Charter", "PT Serif", "Times New Roman"),
)
#let polices-presets = font-presets

// Raccourcis de notation scientifique
// Résistances & impédances
#let ohm = $Omega$
#let kohm = $k Omega$
#let mohm = $M Omega$

// Capacités
#let uf = $mu upright("F")$
#let nf = $upright("nF")$
#let pf = $upright("pF")$

// Tensions
#let vpp = $V_("pp")$
#let vrms = $V_("rms")$
#let vdc = $V_("dc")$
#let vac = $V_("ac")$
#let mv = $upright("mV")$
#let uv = $mu upright("V")$

// Courants
#let ma = $upright("mA")$
#let ua = $mu upright("A")$
#let na = $upright("nA")$

// Fréquences
#let hz = $upright("Hz")$
#let khz = $upright("kHz")$
#let mhz = $upright("MHz")$
#let ghz = $upright("GHz")$
#let fcut = $f_0$

// Temps
#let ms = $upright("ms")$
#let us = $mu upright("s")$
#let ns = $upright("ns")$
#let ps = $upright("ps")$

// Puissances & décibels
#let mw = $upright("mW")$
#let uw = $mu upright("W")$
#let db = $upright("dB")$
#let dbm = $upright("dBm")$

// Température
#let degc = $degree upright("C")$
#let celsius = $degree upright("C")$
