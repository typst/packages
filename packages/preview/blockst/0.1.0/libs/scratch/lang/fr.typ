// lang/fr.typ — API francaise publique alignee sur l'ancien dossier fr/
// Les noms exportes suivent l'ancienne ecriture publique, y compris les accents.

#import "../core.typ": block, custom-block as render-custom-block, parameter

// =====================
// ÉVÉNEMENTS
// =====================

// --- Noms français ---

#let quand-drapeau(body) = block(
  "event.when_flag_clicked",
  args: (:),
  lang-code: "fr",
  body: body,
)

#let quand-touche(touche, body) = block(
  "event.when_key_pressed",
  args: (key: touche),
  lang-code: "fr",
  body: body,
)

#let quand-sprite(body) = block(
  "event.when_sprite_clicked",
  args: (:),
  lang-code: "fr",
  body: body,
)

#let quand-arriere-plan(fond, body) = block(
  "event.when_scene_starts",
  args: (scene: fond),
  lang-code: "fr",
  body: body,
)

#let quand-depasse(element, valeur, body) = block(
  "event.when_value_exceeds",
  args: (element: element, value: valeur),
  lang-code: "fr",
  body: body,
)

#let quand-message(message, body) = block(
  "event.when_message_received",
  args: (message: message),
  lang-code: "fr",
  body: body,
)

#let envoyer(message) = block(
  "event.broadcast",
  args: (message: message),
  lang-code: "fr",
)

#let envoyer-et-attendre(message) = block(
  "event.broadcast_and_wait",
  args: (message: message),
  lang-code: "fr",
)

// =====================
// MOUVEMENT
// =====================

#let avancer(val: none, pas: 10) = block(
  "motion.move_steps",
  args: (steps: if val != none { val } else { pas }),
  lang-code: "fr",
)

#let tourner-à-droite(val: none, degres: 15) = block(
  "motion.turn_right",
  args: (degrees: if val != none { val } else { degres }),
  lang-code: "fr",
)

#let tourner-à-gauche(val: none, degres: 15) = block(
  "motion.turn_left",
  args: (degrees: if val != none { val } else { degres }),
  lang-code: "fr",
)

#let aller(vers) = block(
  "motion.goto",
  args: (to: vers),
  lang-code: "fr",
)

#let aller-xy(x: 0, y: 0) = block(
  "motion.goto_xy",
  args: (x: x, y: y),
  lang-code: "fr",
)

#let glisser(val: none, secondes: 1, vers) = block(
  "motion.glide",
  args: (secs: if val != none { val } else { secondes }, to: vers),
  lang-code: "fr",
)

#let glisser-xy(val: none, secondes: 1, x: 0, y: 0) = block(
  "motion.glide_to_xy",
  args: (secs: if val != none { val } else { secondes }, x: x, y: y),
  lang-code: "fr",
)

#let orienter-à(val: none, direction: 90) = block(
  "motion.point_in_direction",
  args: (direction: if val != none { val } else { direction }),
  lang-code: "fr",
)

#let orienter-vers(vers) = block(
  "motion.point_towards",
  args: (towards: vers),
  lang-code: "fr",
)

#let ajouter-x(x: 10) = block(
  "motion.change_x",
  args: (dx: x),
  lang-code: "fr",
)

#let mettre-x(x: 0) = block(
  "motion.set_x",
  args: (x: x),
  lang-code: "fr",
)

#let ajouter-y(y: 10) = block(
  "motion.change_y",
  args: (dy: y),
  lang-code: "fr",
)

#let mettre-y(y: 0) = block(
  "motion.set_y",
  args: (y: y),
  lang-code: "fr",
)

#let rebondir() = block(
  "motion.if_on_edge_bounce",
  args: (:),
  lang-code: "fr",
)

#let sens-rotation(style) = block(
  "motion.set_rotation_style",
  args: (style: style),
  lang-code: "fr",
)

#let abscisse() = block(
  "motion.x_position",
  args: (:),
  lang-code: "fr",
)

#let ordonnée() = block(
  "motion.y_position",
  args: (:),
  lang-code: "fr",
)

#let direction() = block(
  "motion.direction",
  args: (:),
  lang-code: "fr",
)

// =====================
// APPARENCE
// =====================

#let dire-pendant(message, val: none, secondes: 2) = block(
  "looks.say_for_secs",
  args: (message: message, secs: if val != none { val } else { secondes }),
  lang-code: "fr",
)

#let dire(message) = block(
  "looks.say",
  args: (message: message),
  lang-code: "fr",
)

#let penser-pendant(message, val: none, secondes: 2) = block(
  "looks.think_for_secs",
  args: (message: message, secs: if val != none { val } else { secondes }),
  lang-code: "fr",
)

#let penser(message) = block(
  "looks.think",
  args: (message: message),
  lang-code: "fr",
)

#let changer-costume(costume) = block(
  "looks.switch_costume_to",
  args: (costume: costume),
  lang-code: "fr",
)

#let costume-suivant() = block(
  "looks.next_costume",
  args: (:),
  lang-code: "fr",
)

#let changer-arrière-plan(fond) = block(
  "looks.switch_backdrop_to",
  args: (backdrop: fond),
  lang-code: "fr",
)

#let arrière-plan-suivant() = block(
  "looks.next_backdrop",
  args: (:),
  lang-code: "fr",
)

#let changer-taille(val: none, valeur: 10) = block(
  "looks.change_size_by",
  args: (change: if val != none { val } else { valeur }),
  lang-code: "fr",
)

#let mettre-taille(val: none, taille: 100) = block(
  "looks.set_size_to",
  args: (size: if val != none { val } else { taille }),
  lang-code: "fr",
)

#let ajouter-effet(effet, val: none, valeur: 25) = block(
  "looks.change_effect_by",
  args: (effect: effet, change: if val != none { val } else { valeur }),
  lang-code: "fr",
)

#let mettre-effet(effet, val: none, valeur: 0) = block(
  "looks.set_effect_to",
  args: (effect: effet, value: if val != none { val } else { valeur }),
  lang-code: "fr",
)

#let supprimer-effets-graphiques() = block(
  "looks.clear_graphic_effects",
  args: (:),
  lang-code: "fr",
)

#let montrer() = block(
  "looks.show",
  args: (:),
  lang-code: "fr",
)

#let cacher() = block(
  "looks.hide",
  args: (:),
  lang-code: "fr",
)

#let aller-au-plan(plan) = block(
  "looks.goto_front_back",
  args: (layer: plan),
  lang-code: "fr",
)

#let déplacer-de-plan(val: 1, direction) = block(
  "looks.go_forward_backward_layers",
  args: (num: val, direction: direction),
  lang-code: "fr",
)

#let numéro-costume(propriete) = block(
  "looks.costume_number_name",
  args: (property: propriete),
  lang-code: "fr",
)

#let numéro-arrière-plan(propriete) = block(
  "looks.backdrop_number_name",
  args: (property: propriete),
  lang-code: "fr",
)

#let taille() = block(
  "looks.size",
  args: (:),
  lang-code: "fr",
)

// =====================
// SON
// =====================

#let jouer-bout(son) = block(
  "sound.play_until_done",
  args: (sound: son),
  lang-code: "fr",
)

#let jouer(son) = block(
  "sound.start_sound",
  args: (sound: son),
  lang-code: "fr",
)

#let arreter-sons() = block(
  "sound.stop_all_sounds",
  args: (:),
  lang-code: "fr",
)

#let ajouter-effet-son(effet, val: none, valeur: 10) = block(
  "sound.change_effect_by",
  args: (effect: effet, value: if val != none { val } else { valeur }),
  lang-code: "fr",
)

#let mettre-effet-son(effet, val: none, valeur: 100) = block(
  "sound.set_effect_to",
  args: (effect: effet, value: if val != none { val } else { valeur }),
  lang-code: "fr",
)

#let annuler-sons() = block(
  "sound.clear_effects",
  args: (:),
  lang-code: "fr",
)

#let ajouter-volume(val: none, volume: 10) = block(
  "sound.change_volume_by",
  args: (volume: if val != none { val } else { volume }),
  lang-code: "fr",
)

#let mettre-volume(val: none, volume: 100) = block(
  "sound.set_volume_to",
  args: (volume: if val != none { val } else { volume }),
  lang-code: "fr",
)

#let volume() = block(
  "sound.volume",
  args: (:),
  lang-code: "fr",
)

// =====================
// STYLO
// =====================

#let effacer-tout() = block(
  "pen.clear",
  args: (:),
  lang-code: "fr",
)

#let estampiller() = block(
  "pen.stamp",
  args: (:),
  lang-code: "fr",
)

#let écrire() = block(
  "pen.pen_down",
  args: (:),
  lang-code: "fr",
)

#let relever() = block(
  "pen.pen_up",
  args: (:),
  lang-code: "fr",
)

#let choisir-couleur(couleur) = block(
  "pen.set_pen_color_to_color",
  args: (color: couleur),
  lang-code: "fr",
)

#let ajouter-stylo(component: "couleur", val: none, valeur: 10) = block(
  "pen.change_pen_param_by",
  args: (param: component, value: if val != none { val } else { valeur }),
  lang-code: "fr",
)

#let mettre-stylo(component: "couleur", val: none, valeur: 50) = block(
  "pen.set_pen_param_to",
  args: (param: component, value: if val != none { val } else { valeur }),
  lang-code: "fr",
)

#let ajouter-taille(val: none, taille: 1) = block(
  "pen.change_pen_size_by",
  args: (size: if val != none { val } else { taille }),
  lang-code: "fr",
)

#let mettre-taille-stylo(val: none, taille: 1) = block(
  "pen.set_pen_size_to",
  args: (size: if val != none { val } else { taille }),
  lang-code: "fr",
)

// =====================
// CONTRÔLE
// =====================

#let attendre(val: none, secondes: 1) = block(
  "control.wait",
  args: (duration: if val != none { val } else { secondes }),
  lang-code: "fr",
)

#let répéter(val: none, fois: 10, body) = block(
  "control.repeat",
  args: (times: if val != none { val } else { fois }),
  lang-code: "fr",
  body: body,
)

#let indéfiniment(body) = block(
  "control.forever",
  args: (:),
  lang-code: "fr",
  body: body,
)

#let si-alors(condition, body) = block(
  "control.if",
  args: (condition: condition),
  lang-code: "fr",
  body: body,
)

#let si-alors-sinon(condition, corps-alors, corps-sinon) = block(
  "control.if_else",
  args: (condition: condition),
  lang-code: "fr",
  body: corps-alors,
  else-body: corps-sinon,
)

#let attendre-que(condition) = block(
  "control.wait_until",
  args: (condition: condition),
  lang-code: "fr",
)

#let tant-que(condition, body) = block(
  "control.repeat_until",
  args: (condition: condition),
  lang-code: "fr",
  body: body,
)

#let stopper(option) = block(
  "control.stop",
  args: (option: option),
  lang-code: "fr",
)

#let quand-clone(body) = block(
  "control.start_as_clone",
  args: (:),
  lang-code: "fr",
  body: body,
)

#let créer-clone(clone) = block(
  "control.create_clone_of",
  args: (clone: clone),
  lang-code: "fr",
)

#let supprimer-clone() = block(
  "control.delete_this_clone",
  args: (:),
  lang-code: "fr",
)

// =====================
// CAPTEURS
// =====================

#let toucher-objet(objet) = block(
  "sensing.touching_object",
  args: (object: objet),
  lang-code: "fr",
)

#let toucher-couleur(couleur) = block(
  "sensing.touching_color",
  args: (color: couleur),
  lang-code: "fr",
)

#let couleurs-se-touchent(couleur1, couleur2) = block(
  "sensing.color_is_touching_color",
  args: (color1: couleur1, color2: couleur2),
  lang-code: "fr",
)

#let distance-de(objet) = block(
  "sensing.distance_to",
  args: (object: objet),
  lang-code: "fr",
)

#let demander(question) = block(
  "sensing.ask_and_wait",
  args: (question: question),
  lang-code: "fr",
)

#let réponse() = block(
  "sensing.answer",
  args: (:),
  lang-code: "fr",
)

#let touche(touche) = block(
  "sensing.key_pressed",
  args: (key: touche),
  lang-code: "fr",
)

#let souris-pressée() = block(
  "sensing.mouse_down",
  args: (:),
  lang-code: "fr",
)

#let souris-x() = block(
  "sensing.mouse_x",
  args: (:),
  lang-code: "fr",
)

#let souris-y() = block(
  "sensing.mouse_y",
  args: (:),
  lang-code: "fr",
)

#let mettre-glissement(mode) = block(
  "sensing.set_drag_mode",
  args: (mode: mode),
  lang-code: "fr",
)

#let volume-sonore() = block(
  "sensing.loudness",
  args: (:),
  lang-code: "fr",
)

#let chrono() = block(
  "sensing.timer",
  args: (:),
  lang-code: "fr",
)

#let reinitialiser-chrono() = block(
  "sensing.reset_timer",
  args: (:),
  lang-code: "fr",
)

#let propriété-scène(propriete, objet) = block(
  "sensing.of",
  args: (property: propriete, object: objet),
  lang-code: "fr",
)

#let temps-actuel(unite) = block(
  "sensing.current",
  args: (timeunit: unite),
  lang-code: "fr",
)

#let jours-depuis-2000() = block(
  "sensing.days_since_2000",
  args: (:),
  lang-code: "fr",
)

#let nom-utilisateur() = block(
  "sensing.username",
  args: (:),
  lang-code: "fr",
)

// =====================
// OPÉRATEURS
// =====================

#let addition(num1, num2) = block(
  "operator.add",
  args: (num1: num1, num2: num2),
  lang-code: "fr",
)

#let soustraction(num1, num2) = block(
  "operator.subtract",
  args: (num1: num1, num2: num2),
  lang-code: "fr",
)

#let multiplication(num1, num2) = block(
  "operator.multiply",
  args: (num1: num1, num2: num2),
  lang-code: "fr",
)

#let division(num1, num2) = block(
  "operator.divide",
  args: (num1: num1, num2: num2),
  lang-code: "fr",
)

#let aléatoire(de: 1, à: 10) = block(
  "operator.random",
  args: (from: de, to: à),
  lang-code: "fr",
)

#let supérieur(operand1, operand2) = block(
  "operator.gt",
  args: (operand1: operand1, operand2: operand2),
  lang-code: "fr",
)

#let inférieur(operand1, operand2) = block(
  "operator.lt",
  args: (operand1: operand1, operand2: operand2),
  lang-code: "fr",
)

#let égal(operand1, operand2) = block(
  "operator.equals",
  args: (operand1: operand1, operand2: operand2),
  lang-code: "fr",
)

#let intersection(operand1, operand2) = block(
  "operator.and",
  args: (operand1: operand1, operand2: operand2),
  lang-code: "fr",
)

#let union(operand1, operand2) = block(
  "operator.or",
  args: (operand1: operand1, operand2: operand2),
  lang-code: "fr",
)

#let contraire(operand) = block(
  "operator.not",
  args: (operand: operand),
  lang-code: "fr",
)

#let regrouper(chaine1, chaine2) = block(
  "operator.join",
  args: (string1: chaine1, string2: chaine2),
  lang-code: "fr",
)

#let lettres(lettre, chaine) = block(
  "operator.letter_of",
  args: (letter: lettre, string: chaine),
  lang-code: "fr",
)

#let longueur(chaine) = block(
  "operator.length",
  args: (string: chaine),
  lang-code: "fr",
)

#let contient(chaine1, chaine2) = block(
  "operator.contains",
  args: (string1: chaine1, string2: chaine2),
  lang-code: "fr",
)

#let modulo(num1, num2) = block(
  "operator.mod",
  args: (num1: num1, num2: num2),
  lang-code: "fr",
)

#let arrondi(num) = block(
  "operator.round",
  args: (num: num),
  lang-code: "fr",
)

#let fonction(operateur, num) = block(
  "operator.mathop",
  args: (operator: operateur, num: num),
  lang-code: "fr",
)

// =====================
// VARIABLES
// =====================

#let mettre-variable(variable, valeur) = block(
  "data.set_variable_to",
  args: (variable: variable, value: valeur),
  lang-code: "fr",
)

#let ajouter-variable(variable, valeur) = block(
  "data.change_variable_by",
  args: (variable: variable, value: valeur),
  lang-code: "fr",
)

#let montrer-variable(variable) = block(
  "data.show_variable",
  args: (variable: variable),
  lang-code: "fr",
)

#let cacher-variable(variable) = block(
  "data.hide_variable",
  args: (variable: variable),
  lang-code: "fr",
)

// =====================
// LISTES
// =====================

#let ajouter-liste(element, liste) = block(
  "data.add_to_list",
  args: (item: element, list: liste),
  lang-code: "fr",
)

#let supprimer-de-liste(index, liste) = block(
  "data.delete_of_list",
  args: (index: index, list: liste),
  lang-code: "fr",
)

#let supprimer-la-liste(liste) = block(
  "data.delete_all_of_list",
  args: (list: liste),
  lang-code: "fr",
)

#let insérer(element, index, liste) = block(
  "data.insert_at_list",
  args: (item: element, index: index, list: liste),
  lang-code: "fr",
)

#let remplacer-element(index, liste, element) = block(
  "data.replace_item_of_list",
  args: (index: index, list: liste, item: element),
  lang-code: "fr",
)

#let élément(index, liste) = block(
  "data.item_of_list",
  args: (index: index, list: liste),
  lang-code: "fr",
)

#let position(element, liste) = block(
  "data.item_number_of_list",
  args: (item: element, list: liste),
  lang-code: "fr",
)

#let longueur-liste(liste) = block(
  "data.length_of_list",
  args: (list: liste),
  lang-code: "fr",
)

#let liste-contient(liste, element) = block(
  "data.list_contains_item",
  args: (list: liste, item: element),
  lang-code: "fr",
)

#let montrer-liste(liste) = block(
  "data.show_list",
  args: (list: liste),
  lang-code: "fr",
)

#let cacher-list(liste) = block(
  "data.hide_list",
  args: (list: liste),
  lang-code: "fr",
)

// Moniteur de variable (comme dans Scratch)
#let variable(nom: "Variable", valeur: 0) = block(
  "data.monitor_variable",
  args: (name: nom, value: valeur),
  lang-code: "fr",
)

// Moniteur de liste (comme dans Scratch)
#let liste(nom: "Liste", elements: (), largeur: 4cm) = block(
  "data.monitor_list",
  args: (name: nom, items: elements, width: largeur),
  lang-code: "fr",
)

// =====================
// BLOCS PERSONNALISÉS
// =====================

#let custom-input(texte) = block(
  "custom.input",
  args: (text: texte),
  lang-code: "fr",
)

#let saisie-perso(texte) = block(
  "custom.input",
  args: (text: texte),
  lang-code: "fr",
)

// Bloc personnalisé avec paramètres
#let custom-block(..args) = render-custom-block(..args)
#let bloc-perso(..args) = render-custom-block(..args)

// Bloc de définition
#let define(label, body) = block(
  "custom.define",
  args: (label: label),
  lang-code: "fr",
  body: body,
)

#let définir(label, body) = block(
  "custom.define",
  args: (label: label),
  lang-code: "fr",
  body: body,
)
