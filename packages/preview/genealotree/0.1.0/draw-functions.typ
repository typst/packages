#import "calc-functions.typ": get-person-by-name, set-generations, set-subtree-unions, set-unions-sizes-compact, get-root-couples, get-root-spacings

#import "@preview/cetz:0.2.2": draw
#import draw: *

#let draw-infos(person) = {
    let paddings = if person.partners-names == () {
        (0.4em, 1.5em)
    } else {
        (0.7, 2em)
    }
    let geno = if person.geno-label != none {
        [(#person.geno-label.at(0)\/\/#person.geno-label.at(1))]
    } else {none}
    let pheno = if person.pheno-label != none {
        [\[#person.pheno-label\]]
    } else {none}
    let i = 0
    for info in (geno, pheno).filter(el => {el != none}) {
        content(
            (name: person.name, anchor: "south"),
            info,
            anchor: "north",
            padding: paddings.at(i),
        )
        move-to((name: person.name, anchor: "center"))
        i += 1
    }
}

#let calc-radius(angle) = {
    let remangle = calc.rem-euclid(angle.deg(), 90)
    if remangle < 45 {
        1/calc.cos(remangle*1deg)
    } else {
        1/calc.cos(90deg - remangle*1deg)
    }
}

#let draw-male-pheno(geneal, person, pheno, start: 90deg, delta: 360deg) = {
    let stop = start + delta
    let angles = (
        90deg,
        135deg,
        225deg,
        315deg,
        405deg,
        450deg
    )
    angles.push(start)
    angles.push(stop)
    let angles = angles.dedup().sorted()
    let start-index = angles.position(el => {el == start})
    let stop-index = angles.position(el => {el == stop})
    let angles = angles.slice(start-index, stop-index + 1)
    let lines = ()
    for angle in angles {
        let line-name = person.name + "-" + str(angle.deg())
        set-origin((name: person.name, anchor: "center"))    
        hide(line(
            (name: person.name, anchor: "center"),
            (
                angle: angle,
                radius: geneal.config.person-radius*calc-radius(angle)
            ),
            name: line-name
        ))
        set-origin((0,0))
        lines.push(line-name + ".end")
    }
    if delta == 360deg {
        line(
            (name: person.name, anchor: "north"),
            ..lines,
            close: true,
            fill: geneal.phenos.at(pheno)
        )
    } else {
        line(
            (name: person.name, anchor: "center"),
            ..lines,
            close: true,
            fill: geneal.phenos.at(pheno)
        )
    }
}

#let draw-phenos(geneal, person, position) = {
    let phenos = person.phenos.filter(el => {el in geneal.phenos})
    let nb-phenos = phenos.len()
    if nb-phenos == 0 {none}
    else if person.sex == "f" {
        let i = 0
        for pheno in phenos {
            arc(
                (name: person.name, anchor: "center"),
                radius: geneal.config.person-radius,
                start: 90deg + i/nb-phenos*360deg,
                delta: 1/nb-phenos*360deg,
                fill: geneal.phenos.at(pheno),
                mode: "PIE",
                anchor: "origin"
            )
            i+=1
        }
    } else if person.sex == "m" {
        let i = 0
        for pheno in phenos {
            draw-male-pheno(
                geneal,
                person,
                pheno,
                start: 90deg + i/nb-phenos*360deg,
                delta: 1/nb-phenos*360deg
            )
            i+=1
        }
    }
    move-to((name: person.name, anchor: "center"))
}

#let draw-person(geneal, person, position) = {
    let radius = geneal.config.person-radius
    if person.sex == "f" {
        circle(
            position,
            radius: radius,
            name: person.name,
        )
    } else if person.sex == "m" {
        move-to(position)
        rect(
            (rel: (-radius, -radius)),
            (rel: (2*radius, 2*radius)),
            name: person.name,
        )
        move-to((rel: (-radius, -radius)))
    }
    draw-phenos(geneal, person, position)
    if not person.alive {
        line((rel: (-1.5*radius, -radius)), (rel: (3*radius, 2*radius)))
        move-to((name: person.name, anchor: "center"))
    }
    draw-infos(person)
}

#let make-label(parent-names) = {
    parent-names.sorted().join("")
}

#let draw-partner(geneal, person-name, partner-name, orient: "r", position) = {
    let u-dist = geneal.config.union-dist
    let switch-val = if orient == "r" {-u-dist/2} else if orient == "l" {u-dist/2}
    let person = get-person-by-name(geneal, person-name)
    let partner = get-person-by-name(geneal, partner-name)
    get-ctx(ctx => {
        if person.name not in ctx.nodes.keys() {
            move-to(position)
            draw-person(geneal, person, (rel: (switch-val, 0)))
        }
        if partner.name not in ctx.nodes.keys() {
            move-to((rel: (-switch-val, 0)))
            draw-person(geneal, partner, (rel: (-switch-val, 0)))
        }
    })
    line(
        (name: person.name, anchor: "south"),
        (rel: (0, -geneal.config.person-botline)),
        name: person.name + "--vb--"
    )
    line(
        (name: partner.name, anchor: "south"),
        (rel: (0, -geneal.config.person-botline)),
        name: partner.name + "--vb--"
    )
    line(
        (name: person.name + "--vb--", anchor: 100%),
        (name: partner.name + "--vb--", anchor: 100%),
        name: make-label((person.name, partner.name)) + "--h--"
    )
    line(
        (name: make-label(
            (person.name, partner.name)
        ) + "--h--", anchor: 50%),
        (rel: (0, -geneal.config.union-vline)),
        name: make-label((person.name, partner.name)) + "--v--"
    )
    move-to((
        name: make-label((person.name, partner.name)) + "--h--",
        anchor: 50%
    ))
}

#let draw-siblings(geneal, union) = {
    let radius = geneal.config.person-radius
    let topline = geneal.config.person-topline
    let sib-dist = geneal.config.siblings-dist
    move-to((name: make-label(union.parents-names) + "--v--", anchor: 100%))
    move-to((rel: (union.size.at(0).l, - topline - radius)))
    for child-name in union.children-names {
        let child = get-person-by-name(geneal, child-name)
        if child.partners-names == () {
            let child-pos = (rel: (sib-dist/2,0))
            draw-person(geneal, child, child-pos)
            line(
                (name: child.name, anchor: "north"),
                (rel: (0, topline)),
                name: child.name + "--vt--"
            )
            move-to((name: child.name, anchor: "center"))
            move-to((rel: (sib-dist/2, 0)))
        } else {
            let partner-name = child.partners-names.at(0)
            let child-union = geneal.unions.find(el => {
                child-name in el.parents-names and partner-name in el.parents-names
            })
            let pos = union.children-names.position(el => {
                el == child.name
            })
            let orient = if pos == 0 and union.children-names.len() != 1 {"l"} else {"r"}
            draw-partner(
                geneal,
                child.name,
                partner-name,
                orient: orient,
                (rel: (sib-dist, 0))
            )
            line(
                (name: child.name, anchor: "north"),
                (rel: (0, topline)),
                name: child.name + "--vt--"
            )
            move-to((
                name: make-label(child-union.parents-names) + "--h--",
                anchor: "50%"
            ))
            move-to((rel: (-sib-dist, radius + topline)))
            move-to((rel: (union.spacings.at(child.name), 0)))
        }
    }
    // draw siblings line
    // line for 1 child is only useful if the only child has a partner.
     if union.children-names.len() == 1 {
        line(
            (name: union.children-names.at(0) + "--vt--", anchor: "end"),
            (name: make-label(union.parents-names) + "--v--", anchor: "end"),
            name: make-label(union.parents-names) + "--s--"
        )
    } else {
        line(
            (name: union.children-names.at(0) + "--vt--", anchor: "end"),
            (name: union.children-names.at(-1) + "--vt--", anchor: "end"),
            name: make-label(union.parents-names) + "--s--"
        )
    }
}

#let draw-roots(geneal) = {
    let radius = geneal.config.person-radius
    let botline = geneal.config.person-botline
    let topline = geneal.config.person-topline
    let vline = geneal.config.union-vline
    let gen-height = radius*2 + botline + vline + topline
    move-to((0, -2*radius - botline))
    let root-couples = get-root-couples(geneal)
    let root-spacings = get-root-spacings(geneal)
    for parents-names in root-couples {
        let union = geneal.unions.find(el => {
            el.parents-names == parents-names
        })
        move-to((rel: (
            0,
            -gen-height*(union.parents-generation - 1) + botline + radius)
        ))
        draw-partner(geneal, ..parents-names, ())
        move-to((rel: (
            root-spacings.at(parents-names.join(), default: 0),
            gen-height*(union.parents-generation - 1)
        )))
    }
}
