// lang/en.typ — English aliases (Complete)
// All Scratch blocks with English function names

#import "../core.typ": block, custom-block as render-custom-block, parameter

// =====================
// EVENTS
// =====================

#let when-flag-clicked(body) = block(
  "event.when_flag_clicked",
  args: (:),
  lang-code: "en",
  body: body,
)

#let when-key-pressed(key, body) = block(
  "event.when_key_pressed",
  args: (key: key),
  lang-code: "en",
  body: body,
)

#let when-sprite-clicked(body) = block(
  "event.when_sprite_clicked",
  args: (:),
  lang-code: "en",
  body: body,
)

#let when-backdrop-switches(backdrop, body) = block(
  "event.when_scene_starts",
  args: (scene: backdrop),
  lang-code: "en",
  body: body,
)

#let when-exceeds(element, value, body) = block(
  "event.when_value_exceeds",
  args: (element: element, value: value),
  lang-code: "en",
  body: body,
)

#let when-message-received(message, body) = block(
  "event.when_message_received",
  args: (message: message),
  lang-code: "en",
  body: body,
)

#let broadcast(message) = block(
  "event.broadcast",
  args: (message: message),
  lang-code: "en",
)

#let broadcast-and-wait(message) = block(
  "event.broadcast_and_wait",
  args: (message: message),
  lang-code: "en",
)

// =====================
// MOTION
// =====================

#let move(steps: 10) = block(
  "motion.move_steps",
  args: (steps: steps),
  lang-code: "en",
)

#let turn-right(degrees: 15) = block(
  "motion.turn_right",
  args: (degrees: degrees),
  lang-code: "en",
)

#let turn-left(degrees: 15) = block(
  "motion.turn_left",
  args: (degrees: degrees),
  lang-code: "en",
)

#let goto(to) = block(
  "motion.goto",
  args: (to: to),
  lang-code: "en",
)

#let goto-xy(x: 0, y: 0) = block(
  "motion.goto_xy",
  args: (x: x, y: y),
  lang-code: "en",
)

#let glide(secs: 1, to) = block(
  "motion.glide",
  args: (secs: secs, to: to),
  lang-code: "en",
)

#let glide-to-xy(secs: 1, x: 0, y: 0) = block(
  "motion.glide_to_xy",
  args: (secs: secs, x: x, y: y),
  lang-code: "en",
)

#let point-in-direction(direction: 90) = block(
  "motion.point_in_direction",
  args: (direction: direction),
  lang-code: "en",
)

#let point-towards(towards) = block(
  "motion.point_towards",
  args: (towards: towards),
  lang-code: "en",
)

#let change-x(dx: 10) = block(
  "motion.change_x",
  args: (dx: dx),
  lang-code: "en",
)

#let set-x(x: 0) = block(
  "motion.set_x",
  args: (x: x),
  lang-code: "en",
)

#let change-y(dy: 10) = block(
  "motion.change_y",
  args: (dy: dy),
  lang-code: "en",
)

#let set-y(y: 0) = block(
  "motion.set_y",
  args: (y: y),
  lang-code: "en",
)

#let if-on-edge-bounce() = block(
  "motion.if_on_edge_bounce",
  args: (:),
  lang-code: "en",
)

#let set-rotation-style(style) = block(
  "motion.set_rotation_style",
  args: (style: style),
  lang-code: "en",
)

#let x-position() = block(
  "motion.x_position",
  args: (:),
  lang-code: "en",
)

#let y-position() = block(
  "motion.y_position",
  args: (:),
  lang-code: "en",
)

#let direction() = block(
  "motion.direction",
  args: (:),
  lang-code: "en",
)

// =====================
// LOOKS
// =====================

#let say-for-secs(message, secs: 2) = block(
  "looks.say_for_secs",
  args: (message: message, secs: secs),
  lang-code: "en",
)

#let say(message) = block(
  "looks.say",
  args: (message: message),
  lang-code: "en",
)

#let think-for-secs(message, secs: 2) = block(
  "looks.think_for_secs",
  args: (message: message, secs: secs),
  lang-code: "en",
)

#let think(message) = block(
  "looks.think",
  args: (message: message),
  lang-code: "en",
)

#let switch-costume-to(costume) = block(
  "looks.switch_costume_to",
  args: (costume: costume),
  lang-code: "en",
)

#let next-costume() = block(
  "looks.next_costume",
  args: (:),
  lang-code: "en",
)

#let switch-backdrop-to(backdrop) = block(
  "looks.switch_backdrop_to",
  args: (backdrop: backdrop),
  lang-code: "en",
)

#let next-backdrop() = block(
  "looks.next_backdrop",
  args: (:),
  lang-code: "en",
)

#let change-size-by(change: 10) = block(
  "looks.change_size_by",
  args: (change: change),
  lang-code: "en",
)

#let set-size-to(size: 100) = block(
  "looks.set_size_to",
  args: (size: size),
  lang-code: "en",
)

#let change-effect-by(effect, change: 25) = block(
  "looks.change_effect_by",
  args: (effect: effect, change: change),
  lang-code: "en",
)

#let set-effect-to(effect, value: 0) = block(
  "looks.set_effect_to",
  args: (effect: effect, value: value),
  lang-code: "en",
)

#let clear-graphic-effects() = block(
  "looks.clear_graphic_effects",
  args: (:),
  lang-code: "en",
)

#let show-sprite() = block(
  "looks.show",
  args: (:),
  lang-code: "en",
)

#let hide-sprite() = block(
  "looks.hide",
  args: (:),
  lang-code: "en",
)

#let goto-layer(layer) = block(
  "looks.goto_front_back",
  args: (layer: layer),
  lang-code: "en",
)

#let go-layers(num: 1, direction) = block(
  "looks.go_forward_backward_layers",
  args: (num: num, direction: direction),
  lang-code: "en",
)

#let costume-property(property) = block(
  "looks.costume_number_name",
  args: (property: property),
  lang-code: "en",
)

#let backdrop-property(property) = block(
  "looks.backdrop_number_name",
  args: (property: property),
  lang-code: "en",
)

#let size() = block(
  "looks.size",
  args: (:),
  lang-code: "en",
)

// =====================
// SOUND
// =====================

#let play-sound-until-done(sound) = block(
  "sound.play_until_done",
  args: (sound: sound),
  lang-code: "en",
)

#let start-sound(sound) = block(
  "sound.start_sound",
  args: (sound: sound),
  lang-code: "en",
)

#let stop-all-sounds() = block(
  "sound.stop_all_sounds",
  args: (:),
  lang-code: "en",
)

#let change-sound-effect-by(effect, value: 10) = block(
  "sound.change_effect_by",
  args: (effect: effect, value: value),
  lang-code: "en",
)

#let set-sound-effect-to(effect, value: 100) = block(
  "sound.set_effect_to",
  args: (effect: effect, value: value),
  lang-code: "en",
)

#let clear-sound-effects() = block(
  "sound.clear_effects",
  args: (:),
  lang-code: "en",
)

#let change-volume-by(volume: 10) = block(
  "sound.change_volume_by",
  args: (volume: volume),
  lang-code: "en",
)

#let set-volume-to(volume: 100) = block(
  "sound.set_volume_to",
  args: (volume: volume),
  lang-code: "en",
)

#let volume() = block(
  "sound.volume",
  args: (:),
  lang-code: "en",
)

// =====================
// PEN
// =====================

#let erase-all() = block(
  "pen.clear",
  args: (:),
  lang-code: "en",
)

#let stamp() = block(
  "pen.stamp",
  args: (:),
  lang-code: "en",
)

#let pen-down() = block(
  "pen.pen_down",
  args: (:),
  lang-code: "en",
)

#let pen-up() = block(
  "pen.pen_up",
  args: (:),
  lang-code: "en",
)

#let set-pen-color-to(color) = block(
  "pen.set_pen_color_to_color",
  args: (color: color),
  lang-code: "en",
)

#let change-pen-param-by(param, value: 10) = block(
  "pen.change_pen_param_by",
  args: (param: param, value: value),
  lang-code: "en",
)

#let set-pen-param-to(param, value: 50) = block(
  "pen.set_pen_param_to",
  args: (param: param, value: value),
  lang-code: "en",
)

#let change-pen-size-by(size: 1) = block(
  "pen.change_pen_size_by",
  args: (size: size),
  lang-code: "en",
)

#let set-pen-size-to(size: 1) = block(
  "pen.set_pen_size_to",
  args: (size: size),
  lang-code: "en",
)

// =====================
// CONTROL
// =====================

#let wait(duration: 1) = block(
  "control.wait",
  args: (duration: duration),
  lang-code: "en",
)

#let repeat(times: 10, body) = block(
  "control.repeat",
  args: (times: times),
  lang-code: "en",
  body: body,
)

#let forever(body) = block(
  "control.forever",
  args: (:),
  lang-code: "en",
  body: body,
)

#let if-then(condition, body) = block(
  "control.if",
  args: (condition: condition),
  lang-code: "en",
  body: body,
)

#let if-then-else(condition, then-body, else-body) = block(
  "control.if_else",
  args: (condition: condition),
  lang-code: "en",
  body: then-body,
  else-body: else-body,
)

#let wait-until(condition) = block(
  "control.wait_until",
  args: (condition: condition),
  lang-code: "en",
)

#let repeat-until(condition, body) = block(
  "control.repeat_until",
  args: (condition: condition),
  lang-code: "en",
  body: body,
)

#let stop(option) = block(
  "control.stop",
  args: (option: option),
  lang-code: "en",
)

#let when-i-start-as-clone(body) = block(
  "control.start_as_clone",
  args: (:),
  lang-code: "en",
  body: body,
)

#let create-clone-of(clone) = block(
  "control.create_clone_of",
  args: (clone: clone),
  lang-code: "en",
)

#let delete-this-clone() = block(
  "control.delete_this_clone",
  args: (:),
  lang-code: "en",
)

// =====================
// SENSING
// =====================

#let touching-object(object) = block(
  "sensing.touching_object",
  args: (object: object),
  lang-code: "en",
)

#let touching-color(color) = block(
  "sensing.touching_color",
  args: (color: color),
  lang-code: "en",
)

#let color-is-touching-color(color1, color2) = block(
  "sensing.color_is_touching_color",
  args: (color1: color1, color2: color2),
  lang-code: "en",
)

#let distance-to(object) = block(
  "sensing.distance_to",
  args: (object: object),
  lang-code: "en",
)

#let ask-and-wait(question) = block(
  "sensing.ask_and_wait",
  args: (question: question),
  lang-code: "en",
)

#let answer() = block(
  "sensing.answer",
  args: (:),
  lang-code: "en",
)

#let key-pressed(key) = block(
  "sensing.key_pressed",
  args: (key: key),
  lang-code: "en",
)

#let mouse-down() = block(
  "sensing.mouse_down",
  args: (:),
  lang-code: "en",
)

#let mouse-x() = block(
  "sensing.mouse_x",
  args: (:),
  lang-code: "en",
)

#let mouse-y() = block(
  "sensing.mouse_y",
  args: (:),
  lang-code: "en",
)

#let set-drag-mode(mode) = block(
  "sensing.set_drag_mode",
  args: (mode: mode),
  lang-code: "en",
)

#let loudness() = block(
  "sensing.loudness",
  args: (:),
  lang-code: "en",
)

#let timer() = block(
  "sensing.timer",
  args: (:),
  lang-code: "en",
)

#let reset-timer() = block(
  "sensing.reset_timer",
  args: (:),
  lang-code: "en",
)

#let property-of(property, object) = block(
  "sensing.of",
  args: (property: property, object: object),
  lang-code: "en",
)

#let current(timeunit) = block(
  "sensing.current",
  args: (timeunit: timeunit),
  lang-code: "en",
)

#let days-since-2000() = block(
  "sensing.days_since_2000",
  args: (:),
  lang-code: "en",
)

#let username() = block(
  "sensing.username",
  args: (:),
  lang-code: "en",
)

// =====================
// OPERATORS
// =====================

#let add(num1, num2) = block(
  "operator.add",
  args: (num1: num1, num2: num2),
  lang-code: "en",
)

#let subtract(num1, num2) = block(
  "operator.subtract",
  args: (num1: num1, num2: num2),
  lang-code: "en",
)

#let multiply(num1, num2) = block(
  "operator.multiply",
  args: (num1: num1, num2: num2),
  lang-code: "en",
)

#let divide(num1, num2) = block(
  "operator.divide",
  args: (num1: num1, num2: num2),
  lang-code: "en",
)

#let pick-random(from: 1, to: 10) = block(
  "operator.random",
  args: (from: from, to: to),
  lang-code: "en",
)

#let greater-than(operand1, operand2) = block(
  "operator.gt",
  args: (operand1: operand1, operand2: operand2),
  lang-code: "en",
)

#let less-than(operand1, operand2) = block(
  "operator.lt",
  args: (operand1: operand1, operand2: operand2),
  lang-code: "en",
)

#let equals(operand1, operand2) = block(
  "operator.equals",
  args: (operand1: operand1, operand2: operand2),
  lang-code: "en",
)

#let op-and(operand1, operand2) = block(
  "operator.and",
  args: (operand1: operand1, operand2: operand2),
  lang-code: "en",
)

#let op-or(operand1, operand2) = block(
  "operator.or",
  args: (operand1: operand1, operand2: operand2),
  lang-code: "en",
)

#let op-not(operand) = block(
  "operator.not",
  args: (operand: operand),
  lang-code: "en",
)

#let join(string1, string2) = block(
  "operator.join",
  args: (string1: string1, string2: string2),
  lang-code: "en",
)

#let letter-of(letter, string) = block(
  "operator.letter_of",
  args: (letter: letter, string: string),
  lang-code: "en",
)

#let length-of(string) = block(
  "operator.length",
  args: (string: string),
  lang-code: "en",
)

#let contains(string1, string2) = block(
  "operator.contains",
  args: (string1: string1, string2: string2),
  lang-code: "en",
)

#let mod(num1, num2) = block(
  "operator.mod",
  args: (num1: num1, num2: num2),
  lang-code: "en",
)

#let round(num) = block(
  "operator.round",
  args: (num: num),
  lang-code: "en",
)

#let mathop(operator, num) = block(
  "operator.mathop",
  args: (operator: operator, num: num),
  lang-code: "en",
)

// =====================
// VARIABLES
// =====================

#let set-variable-to(variable, value) = block(
  "data.set_variable_to",
  args: (variable: variable, value: value),
  lang-code: "en",
)

#let change-variable-by(variable, value) = block(
  "data.change_variable_by",
  args: (variable: variable, value: value),
  lang-code: "en",
)

#let show-variable(variable) = block(
  "data.show_variable",
  args: (variable: variable),
  lang-code: "en",
)

#let hide-variable(variable) = block(
  "data.hide_variable",
  args: (variable: variable),
  lang-code: "en",
)

// =====================
// LISTS
// =====================

#let add-to-list(item, list) = block(
  "data.add_to_list",
  args: (item: item, list: list),
  lang-code: "en",
)

#let delete-of-list(index, list) = block(
  "data.delete_of_list",
  args: (index: index, list: list),
  lang-code: "en",
)

#let delete-all-of-list(list) = block(
  "data.delete_all_of_list",
  args: (list: list),
  lang-code: "en",
)

#let insert-at-list(item, index, list) = block(
  "data.insert_at_list",
  args: (item: item, index: index, list: list),
  lang-code: "en",
)

#let replace-item-of-list(index, list, item) = block(
  "data.replace_item_of_list",
  args: (index: index, list: list, item: item),
  lang-code: "en",
)

#let item-of-list(index, list) = block(
  "data.item_of_list",
  args: (index: index, list: list),
  lang-code: "en",
)

#let item-number-of-list(item, list) = block(
  "data.item_number_of_list",
  args: (item: item, list: list),
  lang-code: "en",
)

#let length-of-list(list) = block(
  "data.length_of_list",
  args: (list: list),
  lang-code: "en",
)

#let list-contains-item(list, item) = block(
  "data.list_contains_item",
  args: (list: list, item: item),
  lang-code: "en",
)

#let show-list(list) = block(
  "data.show_list",
  args: (list: list),
  lang-code: "en",
)

#let hide-list(list) = block(
  "data.hide_list",
  args: (list: list),
  lang-code: "en",
)

// Visual variable monitor (like Scratch variable watcher)
#let variable-display(name: "Variable", value: 0) = block(
  "data.monitor_variable",
  args: (name: name, value: value),
  lang-code: "en",
)

// Visual list monitor (like Scratch list watcher)
#let list(name: "List", items: (), width: 4cm) = block(
  "data.monitor_list",
  args: (name: name, items: items, width: width),
  lang-code: "en",
)

// =====================
// CUSTOM BLOCKS
// =====================
// CUSTOM BLOCKS
// =====================

#let custom-input(text) = block(
  "custom.input",
  args: (text: text),
  lang-code: "en",
)

// Custom block with parameters (old API from scratch.typ)
#let custom-block(..args) = render-custom-block(..args)

// Define block (old API from scratch.typ)
#let define(label, body) = block(
  "custom.define",
  args: (label: label),
  lang-code: "en",
  body: body,
)

// Parameter reporter for custom blocks is exported
// (imported directly from scratch.typ and is already available)
