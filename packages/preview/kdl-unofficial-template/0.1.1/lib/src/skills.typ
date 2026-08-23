#import "@preview/cetz:0.5.2"
#import "./style.typ": *

#let attrs = (
  fort: (
    name: "Fortitude",
    move: "Endure Injury",
  ),
  will: (
    name: "Willpower",
    move: "Keep it Together",
  ),
  refl: (
    name: "Reflexes",
    move: "Avoid Harm",
  ),
  reas: (
    name: "Reason",
    move: "Investigate",
  ),
  char: (
    name: "Charisma",
    move: "Influence Other",
  ),
  intu: (
    name: "Intuition",
    move: "Read a Person",
  ),
  viol: (
    name: "Violence",
    move: "Engage in Combat",
  ),
  perc: (
    name: "Perception",
    move: "Observe a Situation",
  ),
  cool: (
    name: "Coolness",
    move: "Act under Pressure",
  ),
  soul: (
    name: "Soul",
    move: "See through the Illusion",
  ),
  dis: (
    name: "Disadvantage",
    move: "Disadvantage",
  ),
)

#let skill-tree(
  fort: "",
  will: "",
  refl: "",
  reas: "",
  char: "",
  intu: "",
  viol: "",
  perc: "",
  cool: "",
  soul: "",
) = block(width: 100%, breakable: false, {
  set align(center)
  cetz.canvas(length: 0.50cm, {
    import cetz.draw: *
    let active(coord, body, value: none) = {
      let radius = 0.95
      circle(coord, radius: 0.95, stroke: 0.1cm + colors.primary, fill: if is-printer-friendly { white } else {
        colors.secondary.lighten(30%)
      })
      content((rel: (0, -1.8), to: coord), box(fill: white.opacify(-95%), radius: 5mm, inset: 1mm, align(center, text(
        size: 7pt,
        body,
      ))))
      content(coord, text(value, size: 14pt))
    }
    let passive(coord, body, value: none) = {
      line(
        (rel: (0, -1.1), to: coord),
        (rel: (1.1, 0), to: coord),
        (rel: (0, 1.1), to: coord),
        (rel: (-1.1, 0), to: coord),
        (rel: (0, -1.1), to: coord),
        stroke: 1mm + colors.primary,
        close: true,
        fill: if is-printer-friendly { white } else { colors.secondary.lighten(30%) },
      )
      content((rel: (0, -2.0), to: coord), box(align(center, text(size: 6.5pt, body))))
      content((rel: (0, 0.1), to: coord), text(value, size: 14pt))
    }
    let pwill = (0, 10)
    let pfort = (-4, 8)
    let prefl = (+4, 8)
    let preas = (-4, 4)
    let pintu = (+4, 4)
    let pperc = (+0, 2)
    let pcool = (-4, -1)
    let pviol = (+4, -1)
    let pchar = (0, -3)
    let psoul = (0, -8)

    let linestyle = (
      stroke: colors.primary,
      mark: (
        end: "barbed",
        start: "barbed",
        reverse: true,
        pos: 1.2cm,
        fill: colors.primary,
        length: 1.4cm,
        width: 0.4cm,
      ),
    )

    line(pfort, pwill, ..linestyle)
    line(prefl, pwill, ..linestyle)
    line((-3.8, 8), pperc, stroke: colors.primary, mark: (
      end: "barbed",
      start: "barbed",
      pos: 1.4cm,
      fill: colors.primary,
      length: 1.4cm,
      width: 0.4cm,
    ))
    line((3.8, 8), pperc, stroke: colors.primary, mark: (
      end: "barbed",
      start: "barbed",
      pos: 1.4cm,
      fill: colors.primary,
      length: 1.4cm,
      width: 0.4cm,
    ))
    line(preas, pperc, ..linestyle)
    line(preas, pintu, stroke: colors.primary, mark: (
      end: "barbed",
      start: "barbed",
      pos: 1.4cm,
      fill: colors.primary,
      length: 1.4cm,
      width: 0.4cm,
    ))
    line(pintu, pperc, ..linestyle)
    line(pcool, pperc, ..linestyle)
    line(pviol, pperc, ..linestyle)
    line(pcool, pchar, ..linestyle)
    line(pviol, pchar, ..linestyle)

    line(pchar, pperc, stroke: colors.primary, mark: (
      end: "barbed",
      reverse: true,
      pos: 1.2cm,
      fill: colors.primary,
      length: 1.2cm,
      width: 0.4cm,
    ))
    line(psoul, pchar, stroke: colors.primary, mark: (
      end: "barbed",
      reverse: true,
      pos: 1.2cm,
      fill: colors.primary,
      length: 1.2cm,
      width: 0.4cm,
    ))
    line(pcool, preas, stroke: colors.primary, mark: (
      end: "barbed",
      reverse: true,
      pos: 1.2cm,
      fill: colors.primary,
      length: 1.2cm,
      width: 0.4cm,
    ))
    line(
      pviol,
      pintu,
      stroke: colors.primary,
      mark: (
        end: "barbed",
        reverse: true,
        pos: 1.2cm,
        fill: colors.primary,
        length: 1.2cm,
        width: 0.4cm,
      ),
    )

    passive(pwill, [#strong(attrs.will.name)\ #attrs.will.move], value: [#will])
    passive(pfort, [#strong(attrs.fort.name)\ #attrs.fort.move], value: [#fort])
    passive(prefl, [#strong(attrs.refl.name)\ #attrs.refl.move], value: [#refl])
    active(preas, [#strong(attrs.reas.name)\ #attrs.reas.move], value: [#reas])
    active(pchar, [#strong(attrs.char.name)\ #attrs.char.move], value: [#char])
    active(pintu, [#strong(attrs.intu.name)\ #attrs.intu.move], value: [#intu])
    active(pviol, [#strong(attrs.viol.name)\ #attrs.viol.move], value: [#viol])
    active(pperc, [#strong(attrs.perc.name)\ #attrs.perc.move], value: [#perc])
    active(pcool, [#strong(attrs.cool.name)\ #attrs.cool.move], value: [#cool])
    active(psoul, [#strong(attrs.soul.name)\ #attrs.soul.move], value: [#soul])
  })
})
