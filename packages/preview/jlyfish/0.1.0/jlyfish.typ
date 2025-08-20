#import "@preview/based:0.1.0": base64

#let jlyfish-output-data = state("jlyfish-output-data", (:))
#let jlyfish-code-counter = counter("jlyfish-code-counter")

#let read-julia-output(data) = {
  assert.eq(type(data), dictionary)
  for (_id, evaluation) in data {
    assert.eq(type(evaluation), dictionary)
    for k in evaluation.keys() {
      assert(k in ("result", "stdout", "logs", "code"))
    }
  }
  
  jlyfish-output-data.update(data)
}

#let jl-pkg(cmd: "add", ..pkgs) = {
  let pkgs = pkgs.pos()
  assert(pkgs.all(pkg => type(pkg) == str))
  [#metadata((cmd: cmd, pkgs: pkgs)) <jlyfish-data>]
}

#let jl-raw(
  preferred-mimes: (),
  recompute: true,
  display: false,
  fn: evaluated => none,
  it
) = {
  if type(preferred-mimes) != array {
    preferred-mimes = (preferred-mimes, )
  }

  context {
    let id = str(jlyfish-code-counter.get().first())
    let output = jlyfish-output-data.get()

    // box(inset: 3pt, fill: aqua, radius: 3pt)[#id]
    [#metadata((
      preferredmimes: preferred-mimes,
      code: it.text,
      id: id,
      display: display,
      recompute: recompute,
    )) <jlyfish-data>]


    let ev = output.at(id, default: none)
    if ev == none {
      [*??*]
    } else if ev.code != it.text {
      // out of sync
      [*??*]
    } else {
      fn(ev)
    }
  }

  jlyfish-code-counter.step()
}

#let jl(
  preferred-mimes: (),
  recompute: true,
  code: false,
  result: auto,
  stdout: auto,
  logs: auto,
  it
) = {
  let relevant-result(result) = not (
    result.mime == "text/plain"
    and
    result.data in ("", "nothing")
  )
  let display-result(result) = {
    if result.mime == "text/plain" {
      // set align(bottom)
      set text(fill: red, weight: "bold") if result.failed
      // raw(block: false, lang: "julia-text-output", result.data)
      text(result.data)
    } else if result.mime == "text/typst" {
      eval(result.data, mode: "markup")
    } else if result.mime.starts-with("image/") {
      let format = "unknown format"
      let img-data = ()
      if result.mime == "image/png" {
        format = "png"
        img-data = base64.decode(result.data)
      } else if result.mime == "image/jpg" {
        format = "jpg"
        img-data = base64.decode(result.data)
      } else if result.mime == "image/svg+xml" {
        format = "svg"
        img-data = result.data
      }
      image.decode(img-data, format: format)
    } else {
      panic("Unsupported MIME type: " + result.mime)
    }
  }

  let relevant-stdout(output) = output != ""
  let display-stdout(output) = {
    let output-block-selector = raw.where(block: true, lang: "stdout")
    // show output-block-selector: set block(
    //   above: 1pt,
    //   width: 80%,
    //   fill: luma(100),
    //   inset: 3pt,
    // )
    // show output-block-selector: set text(fill: luma(250))

    linebreak()
    text(size: .6em)[_stdout:_]
    raw(block: true, lang: "stdout", output)
  }

  let relevant-logs(logs) = logs.len() > 0
  let display-logs(logs) = {
    let display-attachment(attachment) = {
      let (key, val) = attachment
      ( raw(key + " ="), display-result(val) )
    }

    let display-attachments(attached) = if attached.len() > 0 {
      set text(size: .6em)
      grid( columns: 2, column-gutter: .8em, row-gutter: .3em,
        ..attached.pairs().map(display-attachment).flatten()
      )
    }

    let icons = (
      (min: 2000, color: red, text: [e]),
      (min: 1000, color: orange, text: [w]),
      (min: 0, color: aqua, text: [i]),
      (min: -calc.inf, color: gray, text: [d]),
    )

    let display-log(log) = {
      let icon = icons.find(it => log.level.level >= it.min)

      (
        // text(fill: gray, weight: "bold")[log],
        text(fill: icon.color, weight: "bold", icon.text),
        align(bottom, {
          text(size: .8em, log.message)
          // text(size: .8em, eval(log.message, mode: "markup"))
          display-attachments(log.attached)
        })
      )
    }

    grid(
      columns: (auto, 1fr), column-gutter: 1em, row-gutter: .5em,
      ..logs.map(display-log).flatten()
    )
  }
  
  let fn(evaluated) = {
    if code {
      it
    }
    if result != false and relevant-result(evaluated.result) {
      display-result(evaluated.result)
    }
    if stdout != false and relevant-stdout(evaluated.stdout) {
      display-stdout(evaluated.stdout)
    }
    if logs != false and relevant-logs(evaluated.logs) {
      display-logs(evaluated.logs)
    }
  }

  jl-raw(
    preferred-mimes: preferred-mimes,
    recompute: recompute,
    display: true,
    fn: fn,
    it
  )
}

