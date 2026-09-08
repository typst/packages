// exec/fr.typ — Wrappers francais pour scratch-run()
// Suit les noms publics de l'API francaise.

#import "../executable.typ" as exec-core

// =====================================================
// MOUVEMENT
// =====================================================

#let avancer(val: 10) = exec-core.move(steps: val)
#let tourner-à-droite(val: 15) = exec-core.turn-right(degrees: val)
#let tourner-à-gauche(val: 15) = exec-core.turn-left(degrees: val)
#let orienter-à(val: 90) = exec-core.set-direction(direction: val)
#let aller-xy(x: 0, y: 0) = exec-core.go-to(x: x, y: y)
#let mettre-x(x: 0) = exec-core.set-x(x: x)
#let mettre-y(y: 0) = exec-core.set-y(y: y)
#let ajouter-x(x: 10) = exec-core.change-x(dx: x)
#let ajouter-y(y: 10) = exec-core.change-y(dy: y)

// Reporters
#let direction() = exec-core.direction()

// =====================================================
// STYLO
// =====================================================

#let effacer-tout() = exec-core.erase-all()
#let estampiller() = exec-core.stamp()
#let écrire() = exec-core.pen-down()
#let relever() = exec-core.pen-up()
#let choisir-couleur(couleur: black) = exec-core.set-pen-color(color: couleur)
#let ajouter-taille(val: 1) = exec-core.change-pen-size(size: val)
#let mettre-taille(val: 1) = exec-core.set-pen-size(size: val)
#let ajouter-stylo(param, valeur: 10) = exec-core.change-pen-param(param, value: valeur)
#let mettre-stylo(param, valeur: 50) = exec-core.set-pen-param(param, value: valeur)

// =====================================================
// VARIABLES ET OPERATEURS
// =====================================================

#let mettre-variable(nom, valeur) = exec-core.set-variable(nom, valeur)
#let ajouter-variable(nom, delta) = exec-core.change-variable(nom, delta)

#let multiplication(a, b) = exec-core.multiply(a, b)
#let division(a, b) = exec-core.divide(a, b)
#let aléatoire(de: 1, à: 10) = exec-core.random(from: de, to: à)
#let arrondi(nombre) = exec-core.round(nombre)

#let supérieur(a, b) = exec-core.greater(a, b)
#let inférieur(a, b) = exec-core.less(a, b)
#let égal(a, b) = exec-core.equals(a, b)

#let intersection(a, b) = exec-core.op-and(a, b)
#let union(a, b) = exec-core.op-or(a, b)
#let contraire(a) = exec-core.op-not(a)

// =====================================================
// CONTROLE
// =====================================================

#let attendre(val: 1) = exec-core.wait(seconds: val)

// =====================================================
// APPARENCE
// =====================================================

#let dire(message) = exec-core.say(message)
#let penser(message) = exec-core.think(message)

// =====================================================
// AIDES
// =====================================================

#let carré(taille: 50) = exec-core.square(size: taille)
#let triangle(taille: 50) = exec-core.triangle(size: taille)
#let cercle(rayon: 50, étapes: 36) = exec-core.circle(radius: rayon, steps: étapes)
#let étoile(taille: 50, pointes: 5) = exec-core.star(size: taille, points: pointes)
#let spirale(debut: 5, fin: 100, étapes: 50) = exec-core.spiral(start: debut, end: fin, steps: étapes)