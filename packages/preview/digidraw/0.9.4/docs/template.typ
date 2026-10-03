#import "@preview/digidraw:0.9.4" as dd
#import "@preview/tableau-icons:0.347.0": ti-icon
#import "@preview/cetz:0.5.2"
#import dd: wave

#let myraw(..args) = {
  show raw.where(block: true): block.with(width: 100%, stroke: gray + 0.5pt, inset: 2mm, radius: 1mm)
  show raw.where(block: true): pad.with(x: 2mm)
  
  raw(..args)
}


#let tidylink(..args, paint: purple, stroke: gray + 0.5pt, size: 0.8em) = {
  set underline(stroke: 0pt)
  show link: set text(paint)
  show "wave.": set text(gray)
  show "-": sym.zwj + "-" + sym.zwj
  box(fill: white, outset: (y: 3pt), inset: (x: 2pt), stroke: stroke, radius: 3pt, text(paint, size, link(..args)))
}


#let mylink(..args) = text(blue, underline(offset: 0.15em, emph(link(..args))))


#let manual-template(body) = {

  show raw.where(block: true, lang: "vexample"): it => {
    // lines starting with `//-` are executed, but not shown
    let executed-lines = ()
    // lines starting with `//+` are not executed, but shown
    let visible-lines = ()

    for line in it.lines {
      if line.text.starts-with("//-") {
        executed-lines += (line.text.slice("//+".len()),)
      } else if line.text.starts-with("//+") {
        visible-lines += (line.text.slice("//-".len()),)
        none
      } else {
        executed-lines += (line.text,)
        visible-lines += (line.text,)
      }
    }

    let code(width: 100%, height: auto) = block(
      width: width,
      height: height,
      stroke: gray + 0.5pt,
      inset: 2mm,
      radius: 1mm,
      {
        set text(1.1em)
        raw(visible-lines.join("\n"), lang: "typst")
      },
    )

    let content(width: 100%, height: auto) = block(
      width: width,
      height: height,
      stroke: gray + 0.5pt,
      inset: 2mm,
      radius: 1mm,
      align(center, {
        let content = {
          set text(font: "Atkinson Hyperlegible Next")
          eval(executed-lines.join("\n"), mode: "markup", scope: (dd: dd, wave: wave.with(symbol-width: 1.1cm), cetz: cetz))
        }
        content
      }),
    )

    grid(
      columns: if it.lang == "Vexample" { (auto, 1fr) } else { (1fr,) },
      align: horizon,
      column-gutter: 1mm,
      row-gutter: 2mm,
      code(),
      content(),
    )
  }

  show raw.where(block: true, lang: "hexample"): it => {
    // lines starting with `//-` are executed, but not shown
    let executed-lines = ()
    // lines starting with `//+` are not executed, but shown
    let visible-lines = ()

    for line in it.lines {
      if line.text.starts-with("//-") {
        executed-lines += (line.text.slice("//+".len()),)
      } else if line.text.starts-with("//+") {
        visible-lines += (line.text.slice("//-".len()),)
        none
      } else {
        executed-lines += (line.text,)
        visible-lines += (line.text,)
      }
    }

    let gutter = 3mm
    let inset = 2mm

    layout(size => {
      let code(width: 100%, height: auto) = block(
        width: width,
        height: height,
        stroke: gray + 0.5pt,
        inset: 2mm,
        radius: 1mm,
        {
          set text(1.1em)
          raw(visible-lines.join("\n"), lang: "typst", block: true)
        },
      )

      let content(width: 100%, height: auto) = block(
        width: width,
        height: height,
        stroke: gray + 0.5pt,
        inset: 2mm,
        radius: 1mm,
        align(center, {
          let content = {
            set text(font: "Atkinson Hyperlegible Next")
            eval(executed-lines.join("\n"), mode: "markup", scope: (dd: dd, wave: wave.with(symbol-width: 1.1cm), cetz: cetz))
          }
          content
        }),
      )
      let height = calc.max(
        measure(code(width: size.width / 2 - 1mm)).height,
        measure(content(width: size.width / 2 - 1mm)).height,
      )

      grid(
        columns: (1fr, 1fr),
        column-gutter: 2mm,
        row-gutter: 1mm,
        align: (top,horizon),

        code(height: height), content(height: height),
      )
    })

    //let scale = calc.min(1, size.width / measure(content).width)
  }


  show ref: it => {
    if str(it.target).starts-with("-wave") {
      tidylink(size: 0.9em, it.target,str(it.target).replace("-wave.","").replace("-wave()","wave()"))
    } else if str(it.target).starts-with("-digidraw-x-pattern") {
      tidylink(size: 0.9em, it.target,str(it.target).replace("-digidraw-x-pattern.",""))
    } else if str(it.target).starts-with("-subwave") {
      tidylink(size: 0.9em, it.target,str(it.target).replace("-subwave.","").replace("-subwave()","subwave()"))
    } else {
      it
    }
  }

  body
}
