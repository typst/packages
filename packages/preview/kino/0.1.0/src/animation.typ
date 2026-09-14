#import "states.typ": (
  begin, current_block, cut_blocks, loop_blocks, time, time_block, timeline,
)
#import "utils.typ": get_block_duration, get_default_dict, get_scaler
#import "transitions.typ": get_transition

/// Terminates the animation. Mandatory.
#let finish() = context {
  if not begin.get() {
    begin.update(_ => true)
  }
}

// Main function for computing `a`("x")
#let build_mapping(block, name) = {
  let name_dict = timeline.get().at(name, default: get_default_dict())
  let end = block
  let start = block - 1
  while not str(start) in name_dict.keys() {
    start -= 1
  }
  let (start_value, _, _, _, _) = name_dict.at(str(start)).at(-1)
  let scaler = get_scaler(name_dict.at("0").at(0).at(0))

  if str(end) in name_dict.keys() {
    let mapping(time) = {
      let start_value_bis = start_value
      for (end_value, hold, duration, dwell, trans) in name_dict.at(str(end)) {
        if hold <= time {
          if time < hold + duration + dwell {
            trans = get_transition(trans)
            time = calc.min(1, calc.max(0, time - hold) / duration)
            return scaler(start_value_bis, end_value, trans(time))
          } else { start_value_bis = end_value }
        } else { break }
      }
      return start_value
    }
    return mapping
  } else {
    return _ => start_value
  }
}

/// Evaluates an animation variable in context.
#let a(
  /// -> str
  name,
) = {
  build_mapping(time_block.get(), name)(time.get())
}

#let slideshow(body) = context {
  let variables = timeline.final()
  let max_block = calc.max(..variables.values().join().keys().map(int))
  time.update(_ => 0)
  for b in range(1, max_block + 2) {
    time_block.update(_ => b)
    page(body)
  }
}

#let fake(body, fps) = context {
  let variables = timeline.final()
  let cut_blocks = cut_blocks.final()
  let loop_blocks = loop_blocks.final()
  let max_block = calc.max(..variables.values().join().keys().map(int))
  if not max_block in cut_blocks {
    cut_blocks = cut_blocks + (max_block,)
  }

  let total_frames = 0
  let local_frames = 0
  let segment = 0

  for b in range(1, max_block + 1) {
    let duration = get_block_duration(variables, b)

    let frames = int(calc.round(fps * duration))
    local_frames += frames

    if b in cut_blocks {
      metadata((
        "kino": (
          "fps": fps,
          "duration": duration,
          "frames": local_frames + 1,
          "from": total_frames,
          "segment": segment,
          "loop": b in loop_blocks,
        ),
      ))
      total_frames += frames
      local_frames = 0
      segment += 1
    }
  }
  page(body)
}

/// The main show rule. Must be applied before any animation primitive is used. The body must contain a call to @finish.
#let animation(
  /// -> content
  body,
  /// Frames per second of animation. Overrides command line parameters.
  /// -> int
  fps: -1,
) = {
  if fps < 0 { fps = int(sys.inputs.at("fps", default: 5)) }
  if int(sys.inputs.at("query", default: 0)) == 1 {
    fake(body, fps)
  } else if fps == 0 {
    slideshow(body)
  } else {
    context {
      let variables = timeline.final()
      let cut_blocks = cut_blocks.final()
      let loop_blocks = loop_blocks.final()
      let max_block = calc.max(..variables.values().join().keys().map(int))
      if not max_block in cut_blocks {
        cut_blocks = cut_blocks + (max_block,)
      }
      let total_frames = 0
      let local_frames = 0
      let segment = 0

      for b in range(1, max_block + 1) {
        let duration = get_block_duration(variables, b)

        let frames = int(calc.round(fps * duration))
        local_frames += frames

        for frame in range(frames) {
          let new_time = (duration * frame) / frames
          time.update(_ => new_time)
          page(body) //+ place(bottom + right, [#segment])
        }

        time_block.update(int => int + 1)

        if b in cut_blocks {
          metadata((
            "kino": (
              "fps": fps,
              "duration": duration,
              "frames": local_frames + 1,
              "from": total_frames,
              "segment": segment,
              "loop": b in loop_blocks,
            ),
          ))
          total_frames += frames
          local_frames = 0
          segment += 1
        }
      }
      time.update(_ => 0)
      page(body)
    }
  }
}

/// Add a cut at the end of the current block.
#let cut(
  /// Whether the pre-cut segment should loop (revealjs only)
  /// -> bool
  loop: false,
) = context {
  if not begin.get() {
    let block = current_block.get()
    cut_blocks.update(array => array + (block,))
    if loop { loop_blocks.update(array => array + (block,)) }
  }
}
