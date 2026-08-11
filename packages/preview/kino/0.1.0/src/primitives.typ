#import "states.typ": (
  begin, current_block, cut_blocks, loop_blocks, max_block, timeline,
)
#import "utils.typ": check_types, get_block_duration, get_default_dict

// Main function to add animation to the main timeline
#let add_anim(
  block: 1,
  hold: 0,
  duration: 1,
  dwell: 0,
  transition: "linear",
  mode: "append",
  ..args,
) = {
  context {
    let dict = timeline.get()
    for (name, value) in args.named() {
      let name_dict = dict.at(name, default: get_default_dict(type: value))
      let block_list = name_dict.at(str(block), default: ())

      // Check that value types match
      if name in dict {
        check_types((name_dict.at("0").at(0).at(0), value))
      }
      // Check for collision if inserted in place
      if mode == "place" {
        assert(
          block_list.len() == 0,
          message: "collision in the block "
            + str(block)
            + " for variable "
            + name,
        )
      }
    }
  }
  timeline.update(dict => {
    // Compute hold shift depending on the insertion mode
    let shift = 0
    if mode == "append" {
      shift = get_block_duration(dict, block)
    }
    for (name, value) in args.named() {
      let name_dict = dict.at(name, default: get_default_dict(type: value))
      let block_list = name_dict.at(str(block), default: ())
      block_list.push((value, hold + shift, duration, dwell, transition))
      name_dict.insert(str(block), block_list)
      dict.insert(name, name_dict)
    }
    return dict
  })
}

/// Initialize one or several animation variables.
#let init(..args) = context {
  if not begin.get() {
    add_anim(block: 0, ..args)
  }
}

/// Animate variables in a new block, or in the specified block. Changes the current block.
/// ```typst
/// #animate(x:50%, y:3cm)
/// #animate(x:20%)
/// #animate(block:2, y:4cm)
/// ```
/// #let var = (
///   "x": (
///     "0": ((0, 0, 0, 0, 0),),
///     "1": ((0, 0, 1, 0, 0),),
///     "2": ((0, 0, 1, 0, 0),),
///   ),
///   "y": (
///     "0": ((0, 0, 0, 0, 0),),
///     "1": ((0, 0, 1, 0, 0),),
///     "2": ((0, 1, 1, 0, 0),),
///   ),
/// )
/// #_show_timeline(var)
#let animate(
  /// A block identifier to start animation at.
  /// -> int
  block: -1,
  /// Waiting time before animation.
  /// -> second
  hold: 0,
  /// Duration of the animation.
  /// -> second
  duration: 1,
  /// Waiting time after animation.
  /// -> second
  dwell: 0,
  /// A transition name or custom transition.
  /// -> transition | str
  transition: "linear",
  ..args,
) = context {
  if not begin.get() {
    let my_block = if block < 0 { max_block.get() } else { block }
    current_block.update(_ => my_block)
    add_anim(
      block: my_block,
      hold: hold,
      duration: duration,
      dwell: dwell,
      transition: transition,
      ..args,
    )
    max_block.update(b => { if block < 0 { b + 1 } else { b } })
  }
}


/// Animate variables at the start of the current block, _if there is no collision_.
/// ```typst
/// #animate(x:1)
/// #then(x:2)
/// #meanwhile(y:1)
/// #meanwhile(z:3%)
/// //#meanwhile(y:2) raises an error
/// ```
/// #let var = (
///   "x": (
///     "0": ((0, 0, 0, 0, 0),),
///     "1": ((0, 0, 1, 0, 0),(0,1,1,0,0)),
///   ),
///   "y": (
///     "0": ((0, 0, 0, 0, 0),),
///     "1": ((0, 0, 1, 0, 0),),
///   ),
///   "z": (
///     "0": ((0, 0, 0, 0, 0),),
///     "1": ((0, 0, 1, 0, 0),),
///   ),
/// )
/// #_show_timeline(var)
#let meanwhile(
  /// -> second
  hold: 0,
  /// -> second
  duration: 1,
  /// -> second
  dwell: 0,
  /// -> transition | str
  transition: "linear",
  ..args,
) = context {
  if not begin.get() {
    let my_block = current_block.get()
    add_anim(
      block: my_block,
      hold: hold,
      duration: duration,
      dwell: dwell,
      transition: transition,
      mode: "place",
      ..args,
    )
  }
}

/// Animate variables in the current block.
/// ```typst
/// #animate(x:1)
/// #then(x:2)
/// #then(y:1)
/// ```
/// #let var = (
///   "x": (
///     "0": ((0, 0, 0, 0, 0),),
///     "1": ((0, 0, 1, 0, 0),(0,1,1,0,0)),
///   ),
///   "y": (
///     "0": ((0, 0, 0, 0, 0),),
///     "1": ((0, 2, 1, 0, 0),),
///   ),
/// )
/// #_show_timeline(var)
#let then(
  /// -> second
  hold: 0,
  /// -> second
  duration: 1,
  /// -> second
  dwell: 0,
  /// -> transition | str
  transition: "linear",
  ..args,
) = context {
  if not begin.get() {
    let my_block = current_block.get()
    add_anim(
      block: my_block,
      hold: hold,
      duration: duration,
      dwell: dwell,
      transition: transition,
      ..args,
    )
  }
}

/// Add waiting time in the current or specified block.
#let wait(
  /// -> int
  block: -1,
  /// -> second
  duration: 1,
) = context {
  if not begin.get() {
    let my_block = if block < 0 { current_block.get() } else { block }
    add_anim(
      block: my_block,
      duration: duration,
      builtin_pause_counter: 0%,
    )
  }
}
