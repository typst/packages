// lang/de.typ — German block aliases (complete)
// Uses core.typ for schema-based rendering

#import "../core.typ": block, custom-block as render-custom-block, parameter

// =====================
// EREIGNISSE (Events)
// =====================

#let wenn-gruene-flagge-geklickt(body) = block(
  "event.when_flag_clicked",
  args: (:),
  lang-code: "de",
  body: body,
)

#let wenn-taste-gedrueckt(taste, body) = block(
  "event.when_key_pressed",
  args: (key: taste),
  lang-code: "de",
  body: body,
)

#let wenn-diese-figur-angeklickt(body) = block(
  "event.when_sprite_clicked",
  args: (:),
  lang-code: "de",
  body: body,
)

#let wenn-buehnenbildwechsel(szene, body) = block(
  "event.when_scene_starts",
  args: (scene: szene),
  lang-code: "de",
  body: body,
)

#let wenn-ueberschreitet(element, wert, body) = block(
  "event.when_value_exceeds",
  args: (element: element, value: wert),
  lang-code: "de",
  body: body,
)

#let wenn-nachricht-empfangen(nachricht, body) = block(
  "event.when_message_received",
  args: (message: nachricht),
  lang-code: "de",
  body: body,
)

#let sende-nachricht(nachricht) = block(
  "event.broadcast",
  args: (message: nachricht),
  lang-code: "de",
)

#let sende-nachricht-und-warte(nachricht) = block(
  "event.broadcast_and_wait",
  args: (message: nachricht),
  lang-code: "de",
)

// =====================
// BEWEGUNG (Motion)
// =====================

#let gehe(schritte: 10) = block("motion.move_steps", args: (steps: schritte), lang-code: "de")

#let drehe-rechts(grad: 15) = block("motion.turn_right", args: (degrees: grad), lang-code: "de")

#let drehe-links(grad: 15) = block(
  "motion.turn_left",
  args: (degrees: grad),
  lang-code: "de",
)

#let gehe-zu-position(zu) = block(
  "motion.goto",
  args: (to: zu),
  lang-code: "de",
)

#let gehe-zu(x: 0, y: 0) = block(
  "motion.goto_xy",
  args: (x: x, y: y),
  lang-code: "de",
)

#let gleite-zu-position(sekunden: 1, zu) = block(
  "motion.glide",
  args: (secs: sekunden, to: zu),
  lang-code: "de",
)

#let gleite-zu(sekunden: 1, x: 0, y: 0) = block(
  "motion.glide_to_xy",
  args: (secs: sekunden, x: x, y: y),
  lang-code: "de",
)

#let setze-richtung(richtung: 90) = block(
  "motion.point_in_direction",
  args: (direction: richtung),
  lang-code: "de",
)

#let drehe-dich-zu(zu) = block(
  "motion.point_towards",
  args: (towards: zu),
  lang-code: "de",
)

#let aendere-x(dx: 10) = block(
  "motion.change_x",
  args: (dx: dx),
  lang-code: "de",
)

#let setze-x(x: 0) = block(
  "motion.set_x",
  args: (x: x),
  lang-code: "de",
)

#let aendere-y(dy: 10) = block(
  "motion.change_y",
  args: (dy: dy),
  lang-code: "de",
)

#let setze-y(y: 0) = block(
  "motion.set_y",
  args: (y: y),
  lang-code: "de",
)

#let pralle-vom-rand-ab() = block(
  "motion.if_on_edge_bounce",
  args: (:),
  lang-code: "de",
)

#let setze-drehtyp(stil) = block(
  "motion.set_rotation_style",
  args: (style: stil),
  lang-code: "de",
)

#let x-position() = block(
  "motion.x_position",
  args: (:),
  lang-code: "de",
)

#let y-position() = block(
  "motion.y_position",
  args: (:),
  lang-code: "de",
)

#let richtung() = block(
  "motion.direction",
  args: (:),
  lang-code: "de",
)

// =====================
// AUSSEHEN (Looks)
// =====================

#let sage-fuer-sekunden(nachricht, sekunden: 2) = block(
  "looks.say_for_secs",
  args: (message: nachricht, secs: sekunden),
  lang-code: "de",
)

#let sage(nachricht) = block(
  "looks.say",
  args: (message: nachricht),
  lang-code: "de",
)

#let denke-fuer-sekunden(nachricht, sekunden: 2) = block(
  "looks.think_for_secs",
  args: (message: nachricht, secs: sekunden),
  lang-code: "de",
)

#let denke(nachricht) = block(
  "looks.think",
  args: (message: nachricht),
  lang-code: "de",
)

#let wechsle-zu-kostuem(kostuem) = block(
  "looks.switch_costume_to",
  args: (costume: kostuem),
  lang-code: "de",
)

#let naechstes-kostuem() = block(
  "looks.next_costume",
  args: (:),
  lang-code: "de",
)

#let wechsle-zu-buehnenbild(buehnenbild) = block(
  "looks.switch_backdrop_to",
  args: (backdrop: buehnenbild),
  lang-code: "de",
)

#let naechstes-buehnenbild() = block(
  "looks.next_backdrop",
  args: (:),
  lang-code: "de",
)

#let aendere-groesse(aenderung: 10) = block(
  "looks.change_size_by",
  args: (change: aenderung),
  lang-code: "de",
)

#let setze-groesse(groesse: 100) = block(
  "looks.set_size_to",
  args: (size: groesse),
  lang-code: "de",
)

#let aendere-effekt(effekt, aenderung: 25) = block(
  "looks.change_effect_by",
  args: (effect: effekt, change: aenderung),
  lang-code: "de",
)

#let setze-effekt(effekt, wert: 0) = block(
  "looks.set_effect_to",
  args: (effect: effekt, value: wert),
  lang-code: "de",
)

#let schalte-grafikeffekte-aus() = block(
  "looks.clear_graphic_effects",
  args: (:),
  lang-code: "de",
)

#let zeige-dich() = block(
  "looks.show",
  args: (:),
  lang-code: "de",
)

#let verstecke-dich() = block(
  "looks.hide",
  args: (:),
  lang-code: "de",
)

#let gehe-zu-ebene(ebene) = block(
  "looks.goto_front_back",
  args: (layer: ebene),
  lang-code: "de",
)

#let gehe-ebenen(anzahl: 1, richtung) = block(
  "looks.go_forward_backward_layers",
  args: (num: anzahl, direction: richtung),
  lang-code: "de",
)

#let kostuem-eigenschaft(eigenschaft) = block(
  "looks.costume_number_name",
  args: (property: eigenschaft),
  lang-code: "de",
)

#let buehnenbild-eigenschaft(eigenschaft) = block(
  "looks.backdrop_number_name",
  args: (property: eigenschaft),
  lang-code: "de",
)

#let groesse() = block(
  "looks.size",
  args: (:),
  lang-code: "de",
)

// =====================
// KLANG (Sound)
// =====================

#let spiele-klang-ganz(klang) = block(
  "sound.play_until_done",
  args: (sound: klang),
  lang-code: "de",
)

#let spiele-klang(klang) = block(
  "sound.start_sound",
  args: (sound: klang),
  lang-code: "de",
)

#let stoppe-alle-klaenge() = block(
  "sound.stop_all_sounds",
  args: (:),
  lang-code: "de",
)

#let aendere-klangeffekt(effekt, wert: 10) = block(
  "sound.change_effect_by",
  args: (effect: effekt, value: wert),
  lang-code: "de",
)

#let setze-klangeffekt(effekt, wert: 100) = block(
  "sound.set_effect_to",
  args: (effect: effekt, value: wert),
  lang-code: "de",
)

#let schalte-klangeffekte-aus() = block(
  "sound.clear_effects",
  args: (:),
  lang-code: "de",
)

#let aendere-lautstaerke(lautstaerke: 10) = block(
  "sound.change_volume_by",
  args: (volume: lautstaerke),
  lang-code: "de",
)

#let setze-lautstaerke(lautstaerke: 100) = block(
  "sound.set_volume_to",
  args: (volume: lautstaerke),
  lang-code: "de",
)

#let lautstaerke() = block(
  "sound.volume",
  args: (:),
  lang-code: "de",
)

// =====================
// MALSTIFT (Pen)
// =====================

#let loesche-alles() = block(
  "pen.clear",
  args: (:),
  lang-code: "de",
)

#let hinterlasse-abdruck() = block(
  "pen.stamp",
  args: (:),
  lang-code: "de",
)

#let schalte-stift-ein() = block(
  "pen.pen_down",
  args: (:),
  lang-code: "de",
)

#let schalte-stift-aus() = block(
  "pen.pen_up",
  args: (:),
  lang-code: "de",
)

#let setze-stiftfarbe-auf(farbe) = block(
  "pen.set_pen_color_to_color",
  args: (color: farbe),
  lang-code: "de",
)

#let aendere-stift-param(param, wert: 10) = block(
  "pen.change_pen_param_by",
  args: (param: param, value: wert),
  lang-code: "de",
)

#let setze-stift-param(param, wert: 50) = block(
  "pen.set_pen_param_to",
  args: (param: param, value: wert),
  lang-code: "de",
)

#let aendere-stiftdicke(dicke: 1) = block(
  "pen.change_pen_size_by",
  args: (size: dicke),
  lang-code: "de",
)

#let setze-stiftdicke(dicke: 1) = block(
  "pen.set_pen_size_to",
  args: (size: dicke),
  lang-code: "de",
)

// =====================
// STEUERUNG (Control)
// =====================

#let warte(dauer: 1) = block(
  "control.wait",
  args: (duration: dauer),
  lang-code: "de",
)

#let wiederhole(anzahl: 10, body) = block(
  "control.repeat",
  args: (times: anzahl),
  lang-code: "de",
  body: body,
)

#let wiederhole-fortlaufend(body) = block(
  "control.forever",
  args: (:),
  lang-code: "de",
  body: body,
)

#let falls(bedingung, body) = block(
  "control.if",
  args: (condition: bedingung),
  lang-code: "de",
  body: body,
)

#let falls-sonst(bedingung, dann, sonst) = block(
  "control.if_else",
  args: (condition: bedingung),
  lang-code: "de",
  body: dann,
  else-body: sonst,
)

#let warte-bis(bedingung) = block(
  "control.wait_until",
  args: (condition: bedingung),
  lang-code: "de",
)

#let wiederhole-bis(bedingung, body) = block(
  "control.repeat_until",
  args: (condition: bedingung),
  lang-code: "de",
  body: body,
)

#let stoppe(option) = block(
  "control.stop",
  args: (option: option),
  lang-code: "de",
)

#let wenn-ich-als-klon-entstehe(body) = block(
  "control.start_as_clone",
  args: (:),
  lang-code: "de",
  body: body,
)

#let erzeuge-klon(klon) = block(
  "control.create_clone_of",
  args: (clone: klon),
  lang-code: "de",
)

#let loesche-diesen-klon() = block(
  "control.delete_this_clone",
  args: (:),
  lang-code: "de",
)

// =====================
// SENSING
// =====================

#let wird-beruehrt(objekt) = block(
  "sensing.touching_object",
  args: (object: objekt),
  lang-code: "de",
)

#let wird-farbe-beruehrt(farbe) = block(
  "sensing.touching_color",
  args: (color: farbe),
  lang-code: "de",
)

#let farbe-beruehrt-farbe(farbe1, farbe2) = block(
  "sensing.color_is_touching_color",
  args: (color1: farbe1, color2: farbe2),
  lang-code: "de",
)

#let entfernung-von(objekt) = block(
  "sensing.distance_to",
  args: (object: objekt),
  lang-code: "de",
)

#let frage(frage) = block(
  "sensing.ask_and_wait",
  args: (question: frage),
  lang-code: "de",
)

#let antwort() = block(
  "sensing.answer",
  args: (:),
  lang-code: "de",
)

#let taste-gedrueckt(taste) = block(
  "sensing.key_pressed",
  args: (key: taste),
  lang-code: "de",
)

#let maustaste-gedrueckt() = block(
  "sensing.mouse_down",
  args: (:),
  lang-code: "de",
)

#let maus-x() = block(
  "sensing.mouse_x",
  args: (:),
  lang-code: "de",
)

#let maus-y() = block(
  "sensing.mouse_y",
  args: (:),
  lang-code: "de",
)

#let setze-ziehbarkeit(modus) = block(
  "sensing.set_drag_mode",
  args: (mode: modus),
  lang-code: "de",
)

#let lautstaerke-fuehlen() = block(
  "sensing.loudness",
  args: (:),
  lang-code: "de",
)

#let stoppuhr() = block(
  "sensing.timer",
  args: (:),
  lang-code: "de",
)

#let setze-stoppuhr-zurueck() = block(
  "sensing.reset_timer",
  args: (:),
  lang-code: "de",
)

#let eigenschaft-von(eigenschaft, objekt) = block(
  "sensing.of",
  args: (property: eigenschaft, object: objekt),
  lang-code: "de",
)

#let aktuell(zeiteinheit) = block(
  "sensing.current",
  args: (timeunit: zeiteinheit),
  lang-code: "de",
)

#let tage-seit-2000() = block(
  "sensing.days_since_2000",
  args: (:),
  lang-code: "de",
)

#let benutzername() = block(
  "sensing.username",
  args: (:),
  lang-code: "de",
)

// =====================
// OPERATOREN (Operators)
// =====================

#let addiere(zahl1, zahl2) = block(
  "operator.add",
  args: (num1: zahl1, num2: zahl2),
  lang-code: "de",
)

#let subtrahiere(zahl1, zahl2) = block(
  "operator.subtract",
  args: (num1: zahl1, num2: zahl2),
  lang-code: "de",
)

#let multipliziere(zahl1, zahl2) = block(
  "operator.multiply",
  args: (num1: zahl1, num2: zahl2),
  lang-code: "de",
)

#let dividiere(zahl1, zahl2) = block(
  "operator.divide",
  args: (num1: zahl1, num2: zahl2),
  lang-code: "de",
)

#let zufallszahl(von: 1, bis: 10) = block(
  "operator.random",
  args: (from: von, to: bis),
  lang-code: "de",
)

#let groesser-als(operand1, operand2) = block(
  "operator.gt",
  args: (operand1: operand1, operand2: operand2),
  lang-code: "de",
)

#let kleiner-als(operand1, operand2) = block(
  "operator.lt",
  args: (operand1: operand1, operand2: operand2),
  lang-code: "de",
)

#let gleich(operand1, operand2) = block(
  "operator.equals",
  args: (operand1: operand1, operand2: operand2),
  lang-code: "de",
)

#let und(operand1, operand2) = block(
  "operator.and",
  args: (operand1: operand1, operand2: operand2),
  lang-code: "de",
)

#let oder(operand1, operand2) = block(
  "operator.or",
  args: (operand1: operand1, operand2: operand2),
  lang-code: "de",
)

#let nicht(operand) = block(
  "operator.not",
  args: (operand: operand),
  lang-code: "de",
)

#let verbinde(string1, string2) = block(
  "operator.join",
  args: (string1: string1, string2: string2),
  lang-code: "de",
)

#let zeichen-von(position, text) = block(
  "operator.letter_of",
  args: (letter: position, string: text),
  lang-code: "de",
)

#let laenge-von(text) = block(
  "operator.length",
  args: (string: text),
  lang-code: "de",
)

#let enthaelt(text1, text2) = block(
  "operator.contains",
  args: (string1: text1, string2: text2),
  lang-code: "de",
)

#let modulo(zahl1, zahl2) = block(
  "operator.mod",
  args: (num1: zahl1, num2: zahl2),
  lang-code: "de",
)

#let runde(zahl) = block(
  "operator.round",
  args: (num: zahl),
  lang-code: "de",
)

#let mathematik(operator, zahl) = block(
  "operator.mathop",
  args: (operator: operator, num: zahl),
  lang-code: "de",
)

// =====================
// VARIABLEN (Variables)
// =====================

#let setze-variable(variable, wert) = block(
  "data.set_variable_to",
  args: (variable: variable, value: wert),
  lang-code: "de",
)

#let aendere-variable(variable, wert) = block(
  "data.change_variable_by",
  args: (variable: variable, value: wert),
  lang-code: "de",
)

#let zeige-variable(variable) = block(
  "data.show_variable",
  args: (variable: variable),
  lang-code: "de",
)

#let verstecke-variable(variable) = block(
  "data.hide_variable",
  args: (variable: variable),
  lang-code: "de",
)

// =====================
// LISTEN (Lists)
// =====================

#let fuege-zu-liste-hinzu(element, liste) = block(
  "data.add_to_list",
  args: (item: element, list: liste),
  lang-code: "de",
)

#let entferne-aus-liste(index, liste) = block(
  "data.delete_of_list",
  args: (index: index, list: liste),
  lang-code: "de",
)

#let entferne-alles-aus-liste(liste) = block(
  "data.delete_all_of_list",
  args: (list: liste),
  lang-code: "de",
)

#let fuege-bei-ein(element, index, liste) = block(
  "data.insert_at_list",
  args: (item: element, index: index, list: liste),
  lang-code: "de",
)

#let ersetze-element(index, liste, element) = block(
  "data.replace_item_of_list",
  args: (index: index, list: liste, item: element),
  lang-code: "de",
)

#let element-von-liste(index, liste) = block(
  "data.item_of_list",
  args: (index: index, list: liste),
  lang-code: "de",
)

#let nummer-von-element(element, liste) = block(
  "data.item_number_of_list",
  args: (item: element, list: liste),
  lang-code: "de",
)

#let laenge-von-liste(liste) = block(
  "data.length_of_list",
  args: (list: liste),
  lang-code: "de",
)

#let liste-enthaelt(liste, element) = block(
  "data.list_contains_item",
  args: (list: liste, item: element),
  lang-code: "de",
)

#let zeige-liste(liste) = block(
  "data.show_list",
  args: (list: liste),
  lang-code: "de",
)

#let verstecke-liste(liste) = block(
  "data.hide_list",
  args: (list: liste),
  lang-code: "de",
)

// Visuelle Variablen-Darstellung (Monitor)
#let variable(name: "Variable", wert: 0) = block(
  "data.monitor_variable",
  args: (name: name, value: wert),
  lang-code: "de",
)

// Visuelle Listen-Darstellung (Monitor)
#let liste(name: "Liste", items: (), width: 4cm, height: auto) = block(
  "data.monitor_list",
  args: (name: name, items: items, width: width, height: height),
  lang-code: "de",
)

// =====================
// CUSTOM BLOCKS
// =====================

// =====================
// CUSTOM BLOCKS
// =====================

#let eigene-eingabe(text) = block(
  "custom.input",
  args: (text: text),
  lang-code: "de",
)

// Eigener Block mit Parametern (alte API aus scratch.typ)
#let eigener-block(..args) = render-custom-block(..args)

// Definiere-Block (alte API aus scratch.typ)
#let definiere(label, body) = block(
  "custom.define",
  args: (label: label),
  lang-code: "de",
  body: body,
)

// Parameter reporter for custom blocks — re-exported from mod.typ
