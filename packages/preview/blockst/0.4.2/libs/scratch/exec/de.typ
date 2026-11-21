// exec/de.typ — German-named wrappers for scratch-run()
// Wraps the English core in executable.typ with German function and parameter names.

#import "../executable.typ": *

// =====================================================
// BEWEGUNG (Motion)
// =====================================================

#let gehe(schritte: 10) = move(steps: schritte)
#let drehe-rechts(grad: 15) = turn-right(degrees: grad)
#let drehe-links(grad: 15) = turn-left(degrees: grad)
#let setze-richtung(richtung: 90) = set-direction(direction: richtung)
#let gehe-zu(x: 0, y: 0) = go-to(x: x, y: y)
#let setze-x(x: 0) = set-x(x: x)
#let setze-y(y: 0) = set-y(y: y)
#let aendere-x(dx: 10) = change-x(dx: dx)
#let aendere-y(dy: 10) = change-y(dy: dy)

// Reporters — language-neutral, re-exported for convenience
// x-position, y-position, variable are identical in both languages
#let richtung() = direction()

// =====================================================
// MALSTIFT (Pen)
// =====================================================

#let loesche-alles() = erase-all()
#let hinterlasse-abdruck() = stamp()
#let stift-ein() = pen-down()
#let schalte-stift-ein() = pen-down()
#let stift-aus() = pen-up()
#let schalte-stift-aus() = pen-up()
#let setze-stiftfarbe-auf(farbe: black) = set-pen-color(color: farbe)
#let setze-farbe(farbe: black) = set-pen-color(color: farbe)
#let aendere-stiftdicke(dicke: 1) = change-pen-size(size: dicke)
#let setze-stiftdicke(dicke: 1) = set-pen-size(size: dicke)
#let setze-dicke(dicke: 1) = set-pen-size(size: dicke)
#let aendere-stift-param(param, wert: 10) = change-pen-param(param, value: wert)
#let setze-stift-param(param, wert: 50) = set-pen-param(param, value: wert)

// =====================================================
// VARIABLEN & OPERATOREN
// =====================================================

#let setze-variable(name, wert) = set-variable(name, wert)
#let aendere-variable(name, delta) = change-variable(name, delta)

// Arithmetic
#let mal(a, b) = multiply(a, b)
#let geteilt(a, b) = divide(a, b)
#let zufallszahl(von: 1, bis: 10) = random(from: von, to: bis)
#let runde(zahl) = round(zahl)

// Comparisons
#let groesser(a, b) = greater(a, b)
#let kleiner(a, b) = less(a, b)
#let gleich(a, b) = equals(a, b)

// Logic
#let und(a, b) = op-and(a, b)
#let oder(a, b) = op-or(a, b)
#let nicht(a) = op-not(a)

// =====================================================
// STEUERUNG (Control Flow)
// =====================================================

#let warte(sekunden: 1) = wait(seconds: sekunden)

// =====================================================
// AUSSEHEN (Looks)
// =====================================================

#let sage(nachricht) = say(nachricht)
#let denke(nachricht) = think(nachricht)

// =====================================================
// HILFSFUNKTIONEN (Helpers)
// =====================================================

#let quadrat(groesse: 50) = square(size: groesse)
#let dreieck(groesse: 50) = triangle(size: groesse)
#let kreis(radius: 50, schritte: 36) = circle(radius: radius, steps: schritte)
#let stern(groesse: 50, zacken: 5) = star(size: groesse, points: zacken)
#let spirale(start: 5, ende: 100, schritte: 50) = spiral(start: start, end: ende, steps: schritte)
