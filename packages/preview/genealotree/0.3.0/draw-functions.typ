#import "calc-functions.typ": *

#import "@preview/cetz:0.4.1": draw
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
    if person.label != none {
        let anchor = person.label-anchor
        content(
            (name: person.name, anchor: anchor),
            person.label,
            anchor: "center"
        )
    }
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
        let line-name = person.name + "__l__" + str(angle.deg())
        // set-origin((name: person.name, anchor: "center"))    
        hide(line(
            (name: person.name, anchor: "center"),
            (rel:
                (angle: angle,
                radius: geneal.config.person-radius*calc-radius(angle))
            ),
            name: line-name
        ))
        // set-origin((x: 0, y: 0))
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

#let draw-partner(geneal, person-name, partner-name, orient: "r", position) = {
    let person = get-person-by-name(geneal, person-name)
    let partner = get-person-by-name(geneal, partner-name)
    let union-lab = make-union-label((person.name, partner.name))
    hide(circle(position, name: union-lab + "__c__"))
    let u-dist = geneal.config.union-dist
    let switch-val = if orient == "r" {u-dist/2} else if orient == "l" {-u-dist/2}
    let union = geneal.unions.find(el => {
        person-name in el.parents-names and partner-name in el.parents-names
    })
    get-ctx(ctx => {
        if person.name not in ctx.nodes.keys() {
            move-to((name: union-lab + "__c__", anchor: "center"))
            draw-person(geneal, person, (rel: (-switch-val, 0)))
        }
        if partner.name not in ctx.nodes.keys() {
            move-to((name: union-lab + "__c__", anchor: "center"))
            draw-person(geneal, partner, (rel: (switch-val, 0)))
        }
        if person.name + "__vb__" not in ctx.nodes.keys() {
            line(
                (name: person.name, anchor: "south"),
                (rel: (0, -geneal.config.person-botline)),
                name: person.name + "__vb__"
            )
        }
        if partner.name + "__vb__" not in ctx.nodes.keys() {
            line(
                (name: partner.name, anchor: "south"),
                (rel: (0, -geneal.config.person-botline)),
                name: partner.name + "__vb__"
            )
        }
    })
    
    line(
        (name: person.name + "__vb__", anchor: 100%),
        (name: partner.name + "__vb__", anchor: 100%),
        name: union-lab + "__h__"
    )
    move-to((name: partner-name + "__vb__", anchor: 100%))
    line(
        (rel: (- switch-val, 0)),
        (rel: (0, - geneal.config.union-vline)),
        name: union-lab + "__v__"
    )
    move-to((
        name: union-lab + "__v__",
        anchor: 0%
    ))
}

#let draw-siblings(geneal, union) = {
    let radius = geneal.config.person-radius
    let topline = geneal.config.person-topline
    let botline = geneal.config.person-botline
    let sib-dist = geneal.config.siblings-dist
    let u-dist = geneal.config.union-dist
    move-to((name: make-union-label(union.parents-names) + "__v__", anchor: 100%))
    move-to((rel: (union.size.at(0).l, - topline - radius)))
    
    for child-name in union.children-names {
        let child = get-person-by-name(geneal, child-name)
        
        if child.partners-names == () {
            let child-pos = (rel: (sib-dist/2, 0))
            draw-person(geneal, child, child-pos)
            line(
                (name: child.name, anchor: "north"),
                (rel: (0, topline)),
                name: child.name + "__vt__"
            )
            move-to((name: child.name, anchor: "center"))
            move-to((rel: (sib-dist/2, 0)))
        } else {
            let left-partners = if geneal.config.union-orient == "l" {
                child.partners-names
            } else if geneal.config.union-orient == "r" {
                ()
            } else {
                geneal.unions.filter(el => {
                    child.name == el.parents-names.at(1)
                }).map(el => {
                    el.parents-names.at(0)
                }).rev()
            }

            let right-partners = if geneal.config.union-orient == "l" {
                ()
            } else if geneal.config.union-orient == "r" {
                child.partners-names
            } else {
                geneal.unions.filter(el => {
                    child.name == el.parents-names.at(0)
                }).map(el => {
                    el.parents-names.at(1)
                })
            }
        
            if left-partners != () {
                let spacings-p = union.spacings.pairs()
                let first-left-pos = spacings-p.position(el => {
                    let u-lab = get-names-from-label(el.at(0))
                    left-partners.first() in u-lab and child.name in u-lab
                })
                let last-left-pos = spacings-p.position(el => {
                    let u-lab = get-names-from-label(el.at(0))
                    left-partners.last() in u-lab and child.name in u-lab
                })
                let left-spacings = spacings-p.slice(
                    first-left-pos,
                    last-left-pos
                ).map(el => {
                    el.at(1, default: 0)
                }).sum(default: 0)
                // Draw the child at the right of the last left partner.
                get-ctx(ctx => {
                    if child.name not in ctx.nodes.keys() {
                        draw-person(
                            geneal,
                            child,
                            (rel: (left-spacings + sib-dist + u-dist/2, 0))
                        )
                    }
                })
                
                line(
                    (name: child-name, anchor: "north"),
                    (rel: (0, topline)),
                    name: child-name + "__vt__"
                )
                // Move back to the beginning of the union
                move-to((rel: (
                    - left-spacings - sib-dist - u-dist/2,
                    - topline - radius
                )))
            } else {
                // Draw the child to the right
                get-ctx(ctx => {
                    if child.name not in ctx.nodes.keys() {
                        draw-person(
                            geneal,
                            child,
                            (rel: (sib-dist - u-dist/2, 0))
                        )
                    }
                })
                line(
                    (name: child-name, anchor: "north"),
                    (rel: (0, topline)),
                    name: child-name + "__vt__"
                )
                // Move back to the beginning of the union
                move-to((rel: (- sib-dist + u-dist/2, - topline - radius)))
            }
            
            // Draw the partners
            for partner-name in child.partners-names {
                let orient = if partner-name in left-partners {"l"} else {"r"}
                // Draw the union (union center is at sib-dist to the right
                // of the current position)
                draw-partner(
                    geneal,
                    child-name,
                    partner-name,
                    orient: orient,
                    (rel: (sib-dist, 0))
                )
                // Move to the right, to the spacing needed by the union
                let child-u-lab = make-union-label(
                    (child-name, partner-name)
                )
                move-to((rel: (
                    union.spacings.at(child-u-lab) - sib-dist,
                    botline + radius
                )))
            }
        }
    }

    // draw siblings line
    // line for 1 child is only useful if the only child has a partner.
     if union.children-names.len() == 1 {
        line(
            (name: union.children-names.at(0) + "__vt__", anchor: "end"),
            (name: make-union-label(union.parents-names) + "__v__", anchor: "end"),
            name: make-union-label(union.parents-names) + "__s__"
        )
    } else {
        line(
            (name: union.children-names.at(0) + "__vt__", anchor: "end"),
            (name: union.children-names.at(-1) + "__vt__", anchor: "end"),
            name: make-union-label(union.parents-names) + "__s__"
        )
    }
}

#let draw-roots(geneal) = {
    let radius = geneal.config.person-radius
    let botline = geneal.config.person-botline
    let topline = geneal.config.person-topline
    let vline = geneal.config.union-vline
    let gen-height = radius*2 + botline + vline + topline
    let root-spacings = get-root-spacings(geneal)
    let root-couples = root-spacings.pairs().map(el => {
        get-names-from-label(el.at(0))
    })
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
            root-spacings.at(make-union-label(parents-names), default: 0),
            gen-height*(union.parents-generation - 1)
        )))
    }
}

#let draw-persons(geneal) = {
    for person in geneal.persons.filter(el => {el.coords != none}) {
        draw-person(geneal, person, person.coords)
    }
}

#let draw-unions(geneal) = {
    let radius = geneal.config.person-radius
    let botline = geneal.config.person-botline
    let topline = geneal.config.person-topline
    let vline = geneal.config.union-vline
    
    for union in geneal.unions {
        let u-lab = make-union-label(union.parents-names)
        let p0-name = union.parents-names.at(0)
        let p1-name = union.parents-names.at(1)
        
        get-ctx(ctx => {
            
            if p0-name + "__vb__" not in ctx.nodes.keys() {
                line(
                    (name: p0-name, anchor: "south"),
                    (rel: (0, - botline)),
                    name: p0-name + "__vb__"
                )
            }
            if p1-name + "__vb__" not in ctx.nodes.keys() {
                line(
                    (name: p1-name, anchor: "south"),
                    (rel: (0, - botline)),
                    name: p1-name + "__vb__"
                )
            }
            line(
                (name: p0-name + "__vb__", anchor: 100%),
                (name: p1-name + "__vb__", anchor: 100%),
                name: u-lab + "__h__"
            )
            if union.children-names.len() != 0 {
                let (u-x, u-y) = union.coords
                line(
                    (u-x, u-y - radius - botline),
                    (rel: (0, - vline)),
                    name: u-lab + "__v__"
                )
            }
        })

        for child-name in union.children-names {
            line(
                (name: child-name, anchor: "north"),
                (rel: (0, topline)),
                name: child-name + "__vt__"
            )
        }
        if union.children-names.len() == 0 {
            
        } else if union.children-names.len() == 1 {
            line(
                (name: union.children-names.first() + "__vt__", anchor: 100%),
                (name: u-lab + "__v__", anchor: 100%),
                name: u-lab + "__s__"
            )
        } else {
            line(
                (name: union.children-names.first() + "__vt__", anchor: 100%),
                (name: union.children-names.last() + "__vt__", anchor: 100%),
                name: u-lab + "__s__"
            )
        }
    }
}
