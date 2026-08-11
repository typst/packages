// registry.typ — Hierarchical block registry for Scratch
// Structure: group key → block key → metadata (shape, optional category or icon)
// Translation strings are kept separately in lang/translations/*.toml

#let REGISTRY = (
  // =====================
  // EVENTS
  // =====================
  event: (
    when_flag_clicked:     (shape: "hat"),
    when_key_pressed:      (shape: "hat"),
    when_sprite_clicked:   (shape: "hat"),
    when_scene_starts:     (shape: "hat"),
    when_value_exceeds:    (shape: "hat"),
    when_message_received: (shape: "hat"),
    broadcast:             (shape: "stack"),
    broadcast_and_wait:    (shape: "stack"),
  ),

  // =====================
  // MOTION
  // =====================
  motion: (
    move_steps:          (shape: "stack"),
    turn_right:          (shape: "stack"),
    turn_left:           (shape: "stack"),
    goto:                (shape: "stack"),
    goto_xy:             (shape: "stack"),
    glide:               (shape: "stack"),
    glide_to_xy:         (shape: "stack"),
    point_in_direction:  (shape: "stack"),
    point_towards:       (shape: "stack"),
    change_x:            (shape: "stack"),
    set_x:               (shape: "stack"),
    change_y:            (shape: "stack"),
    set_y:               (shape: "stack"),
    if_on_edge_bounce:   (shape: "stack"),
    set_rotation_style:  (shape: "stack"),
    x_position:          (shape: "reporter"),
    y_position:          (shape: "reporter"),
    direction:           (shape: "reporter"),
  ),

  // =====================
  // LOOKS
  // =====================
  looks: (
    say_for_secs:               (shape: "stack"),
    say:                        (shape: "stack"),
    think_for_secs:             (shape: "stack"),
    think:                      (shape: "stack"),
    switch_costume_to:          (shape: "stack"),
    next_costume:               (shape: "stack"),
    switch_backdrop_to:         (shape: "stack"),
    next_backdrop:              (shape: "stack"),
    change_size_by:             (shape: "stack"),
    set_size_to:                (shape: "stack"),
    change_effect_by:           (shape: "stack"),
    set_effect_to:              (shape: "stack"),
    clear_graphic_effects:      (shape: "stack"),
    "show":                       (shape: "stack"),
    hide:                        (shape: "stack"),
    goto_front_back:            (shape: "stack"),
    go_forward_backward_layers: (shape: "stack"),
    costume_number_name:        (shape: "reporter"),
    backdrop_number_name:       (shape: "reporter"),
    size:                       (shape: "reporter"),
  ),

  // =====================
  // SOUND
  // =====================
  sound: (
    play_until_done:  (shape: "stack"),
    start_sound:      (shape: "stack"),
    stop_all_sounds:  (shape: "stack"),
    change_effect_by: (shape: "stack"),
    set_effect_to:    (shape: "stack"),
    clear_effects:    (shape: "stack"),
    change_volume_by: (shape: "stack"),
    set_volume_to:    (shape: "stack"),
    volume:           (shape: "reporter"),
  ),

  // =====================
  // PEN
  // =====================
  pen: (
    clear:                  (shape: "stack"),
    stamp:                  (shape: "stack"),
    pen_down:               (shape: "stack", icon: "pen"),
    pen_up:                 (shape: "stack", icon: "pen"),
    set_pen_color_to_color: (shape: "stack"),
    change_pen_param_by:    (shape: "stack"),
    set_pen_param_to:       (shape: "stack"),
    change_pen_size_by:     (shape: "stack"),
    set_pen_size_to:        (shape: "stack"),
  ),

  // =====================
  // CONTROL
  // =====================
  control: (
    wait:              (shape: "stack"),
    repeat:            (shape: "c-block"),
    forever:           (shape: "cap"),
    "if":                (shape: "c-block"),
    if_else:           (shape: "c-block"),
    wait_until:        (shape: "stack"),
    repeat_until:      (shape: "c-block"),
    stop:              (shape: "cap"),
    start_as_clone:    (shape: "hat"),
    create_clone_of:   (shape: "stack"),
    delete_this_clone: (shape: "cap"),
  ),

  // =====================
  // SENSING
  // =====================
  sensing: (
    touching_object:         (shape: "boolean"),
    touching_color:          (shape: "boolean"),
    color_is_touching_color: (shape: "boolean"),
    distance_to:             (shape: "reporter"),
    ask_and_wait:            (shape: "stack"),
    answer:                  (shape: "reporter"),
    key_pressed:             (shape: "boolean"),
    mouse_down:              (shape: "boolean"),
    mouse_x:                 (shape: "reporter"),
    mouse_y:                 (shape: "reporter"),
    set_drag_mode:           (shape: "stack"),
    loudness:                (shape: "reporter"),
    timer:                   (shape: "reporter"),
    reset_timer:             (shape: "stack"),
    of:                      (shape: "reporter"),
    current:                 (shape: "reporter"),
    days_since_2000:         (shape: "reporter"),
    username:                (shape: "reporter"),
  ),

  // =====================
  // OPERATORS
  // =====================
  operator: (
    add:       (shape: "reporter"),
    subtract:  (shape: "reporter"),
    multiply:  (shape: "reporter"),
    divide:    (shape: "reporter"),
    random:    (shape: "reporter"),
    gt:        (shape: "boolean"),
    lt:        (shape: "boolean"),
    equals:    (shape: "boolean"),
    "and":       (shape: "boolean"),
    "or":        (shape: "boolean"),
    "not":       (shape: "boolean"),
    join:      (shape: "reporter"),
    letter_of: (shape: "reporter"),
    length:    (shape: "reporter"),
    contains:  (shape: "boolean"),
    mod:       (shape: "reporter"),
    round:     (shape: "reporter"),
    mathop:    (shape: "reporter"),
  ),

  // =====================
  // DATA (Variables & Lists)
  // Both sub-groups share the "data" group prefix.
  // The explicit category field distinguishes variables from lists.
  // =====================
  data: (
    // Variables
    set_variable_to:    (shape: "stack",    category: "variables"),
    change_variable_by: (shape: "stack",    category: "variables"),
    show_variable:      (shape: "stack",    category: "variables"),
    hide_variable:      (shape: "stack",    category: "variables"),
    // Monitors (visual watcher widgets)
    monitor_variable: (shape: "monitor-variable", category: "variables"),
    monitor_list:     (shape: "monitor-list",      category: "lists"),
    // Lists
    add_to_list:          (shape: "stack",    category: "lists"),
    delete_of_list:       (shape: "stack",    category: "lists"),
    delete_all_of_list:   (shape: "stack",    category: "lists"),
    insert_at_list:       (shape: "stack",    category: "lists"),
    replace_item_of_list: (shape: "stack",    category: "lists"),
    item_of_list:         (shape: "reporter", category: "lists"),
    item_number_of_list:  (shape: "reporter", category: "lists"),
    length_of_list:       (shape: "reporter", category: "lists"),
    list_contains_item:   (shape: "boolean",  category: "lists"),
    show_list:            (shape: "stack",    category: "lists"),
    hide_list:            (shape: "stack",    category: "lists"),
  ),

  // =====================
  // CUSTOM BLOCKS
  // =====================
  custom: (
    input:  (shape: "input"),
    block:  (shape: "stack"),
    define: (shape: "define"),
  ),
)

