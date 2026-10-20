#import "@preview/tschich:0.1.0": *

#set text(
  size: 9pt, font: "EB Garamond",
  number-type: "old-style")

#set par(
  justify: true, spacing: 0.65em,
  first-line-indent: (amount: 1em, all: false))

#let parstart(body) = {
  text(tracking: 0.5pt)[#smallcaps[#body]#h(0.5pt)]}

/// Nine Part Division

#set page(
  width: 110mm, height: 165mm,
  margin: tschich(110mm, 165mm), binding: right,
  numbering: "1"); #counter(page).update(1)

#parstart[Zwei Konstanten] regieren die Proportionen eines gut gemachten Buches: Hand und Auge. Das gesunde Auge ist immer um zwei Spannen von der Buchseite entfernt, und alle Menschen fassen Bücher auf die gleiche Weise an.

Die Buchgrößen werden vom Gebrauchszweck bestimmt. Sie sind auf die durchschnittliche Größe und die Hände von Erwachsenen bezogen. Schon Kinderbücher dürfen nicht in Foliogröße hergestellt werden, weil einem Kinde dieses Format unhandlich ist. Ein hoher oder wenigstens genügender Grad von Handlichkeit wird erwartet: ein Buch in Tischgröße ist ein Unding, Bücher von Briefmarken große sind Spielereien. Sehr schwere Bücher sind ebenso unwillkommen; ältere Leute könnten sie vielleicht nicht ohne fremde Hilfe bewegen. Riesen müßten viel größere Buchformate und Zeitungen haben; Zwergen wären viele unserer Bücher zu groß.

Zwei Hauptgruppen von Büchern gibt es: jene, die wir auf den Tisch legen, um sie zu studieren, und die andern, die wir im Stuhl zurückgelehnt, im Sessel oder in der Eisenbahn lesen. Studierbücher sollten wir schräg vor uns aufstellen. Dazu raffen sich aber nur wenige auf. Uns über das Buchzu beugen, ist der Gesundheit genau so abträglich wie die übliche Schreibhaltung, die der flache Tisch fordert. Der Schreiber des Mittelalters schrieb auf einem Pult, das wir kaum noch Pult zu nennen wagen, so steil war es (zuweilen bis fünfundsechzig Grad). Das Pergament war mit einem quergespannten Band festgehalten und wurde nach und nach aufwärts geschoben. Die Schreiblinie, stets waagerecht, war in Augenhöhe, und der Schreiber saß nahezu aufrecht vor dem Pergament. Noch um die Jahrhundertwende schrieben Pfarrer und Beamte stehend an einem Pültchen: eine gesunde, vernünftige Schreib- und Lesehaltung, die leider ganz selten geworden ist.

Die Lesehaltung hat jedoch mit der Größe und Ausdehnung der Studierbücher nichts zu tun. Ihre Formate reichen von Großoktav bis Großquart; größere Formate sind Ausnahmen. Studier- oder Tischbücher liegen auf dem Tisch und können nicht in der freien Hand gelesen werden.

Bücher, die man gerne freihändig läse, zeigen alle Abarten des Oktavformats. Vollkommen wären die seltenen noch kleineren Bücher, falls sie schlank sind: sie können ohne Mühe stundenlang in der freien Hand gehalten werden.

Aus einem aufgestellten Buche wird nur beim Gottesdienst vorgelesen: die Augen des Vorlesers mögen um Armeslänge von den Buchstaben des Textes entfernt sein. Eine gewöhnliche Buchseite ist bloß eine Ellenlänge vom Auge des Lesers entfernt. Nur von profanen Büchern ist hier die Rede: nicht alle der folgenden Erwägungen und Regeln gelten auch für sakrale Bücher.

Es gibt viele Proportionen der Seiten große, das heißt des Längenverhältnisses von Breite und Höhe. Jedermann kennt zumindest vom Hörensagen das Verhältnis des Goldenen Schnittes: genau 1 : 1,618. Die Proportion 5 : 8 ist nichts an-
deres als eine Annäherung an den Goldenen Schnitt. Es fällt schwer, dies noch von der Proportion 2 : 3 zu behaupten. [...]


/// Medieval Ideal Canon

#set page(
  width: 110mm, height: 165mm,
  margin: tschich-old(110mm, 165mm, 1/3), binding: right,
  numbering: "1"); #counter(page).update(1)

#parstart[Zwei Konstanten] regieren die Proportionen eines gut gemachten Buches: Hand und Auge. Das gesunde Auge ist immer um zwei Spannen von der Buchseite entfernt, und alle Menschen fassen Bücher auf die gleiche Weise an.

Die Buchgrößen werden vom Gebrauchszweck bestimmt. Sie sind auf die durchschnittliche Größe und die Hände von Erwachsenen bezogen. Schon Kinderbücher dürfen nicht in Foliogröße hergestellt werden, weil einem Kinde dieses Format unhandlich ist. Ein hoher oder wenigstens genügender Grad von Handlichkeit wird erwartet: ein Buch in Tischgröße ist ein Unding, Bücher von Briefmarken große sind Spielereien. Sehr schwere Bücher sind ebenso unwillkommen; ältere Leute könnten sie vielleicht nicht ohne fremde Hilfe bewegen. Riesen müßten viel größere Buchformate und Zeitungen haben; Zwergen wären viele unserer Bücher zu groß.

Zwei Hauptgruppen von Büchern gibt es: jene, die wir auf den Tisch legen, um sie zu studieren, und die andern, die wir im Stuhl zurückgelehnt, im Sessel oder in der Eisenbahn lesen. Studierbücher sollten wir schräg vor uns aufstellen. Dazu raffen sich aber nur wenige auf. Uns über das Buchzu beugen, ist der Gesundheit genau so abträglich wie die übliche Schreibhaltung, die der flache Tisch fordert. Der Schreiber des Mittelalters schrieb auf einem Pult, das wir kaum noch Pult zu nennen wagen, so steil war es (zuweilen bis fünfundsechzig Grad). Das Pergament war mit einem quergespannten Band festgehalten und wurde nach und nach aufwärts geschoben. Die Schreiblinie, stets waagerecht, war in Augenhöhe, und der Schreiber saß nahezu aufrecht vor dem Pergament. Noch um die Jahrhundertwende schrieben Pfarrer und Beamte stehend an einem Pültchen: eine gesunde, vernünftige Schreib- und Lesehaltung, die leider ganz selten geworden ist.

Die Lesehaltung hat jedoch mit der Größe und Ausdehnung der Studierbücher nichts zu tun. Ihre Formate reichen von Großoktav bis Großquart; größere Formate sind Ausnahmen. Studier- oder Tischbücher liegen auf dem Tisch und können nicht in der freien Hand gelesen werden.

Bücher, die man gerne freihändig läse, zeigen alle Abarten des Oktavformats. Vollkommen wären die seltenen noch kleineren Bücher, falls sie schlank sind: sie können ohne Mühe stundenlang in der freien Hand gehalten werden.

Aus einem aufgestellten Buche wird nur beim Gottesdienst vorgelesen: die Augen des Vorlesers mögen um Armeslänge von den Buchstaben des Textes entfernt sein. Eine gewöhnliche Buchseite ist bloß eine Ellenlänge vom Auge des Lesers entfernt. Nur von profanen Büchern ist hier die Rede: nicht alle der folgenden Erwägungen und Regeln gelten auch für sakrale Bücher.

Es gibt viele Proportionen der Seiten große, das heißt des Längenverhältnisses von Breite und Höhe. Jedermann kennt zumindest vom Hörensagen das Verhältnis des Goldenen Schnittes: genau 1 : 1,618. Die Proportion 5 : 8 ist nichts an-
deres als eine Annäherung an den Goldenen Schnitt. Es fällt schwer, dies noch von der Proportion 2 : 3 zu behaupten. [...]
