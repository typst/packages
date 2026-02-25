// Gives the anchor for the label depending on the component orientation in degrees
#let get-label-anchor(angle-deg) = {
    let angle = angle-deg.deg()
    let normalized-angle = calc.rem(if angle < 0 { angle + 360 } else { angle }, 360)

    let tolerance = 15

    if calc.abs(normalized-angle) < tolerance {
        return "south"
    } else if calc.abs(normalized-angle - 90) < tolerance {
        return "east"
    } else if calc.abs(normalized-angle - 180) < tolerance {
        return "north"
    } else if calc.abs(normalized-angle - 270) < tolerance {
        return "west"
    } else {
        if normalized-angle > 0 and normalized-angle < 90 {
            return "south-east"
        } else if normalized-angle > 90 and normalized-angle < 180 {
            return "north-east"
        } else if normalized-angle > 180 and normalized-angle < 270 {
            return "north-west"
        } else {
            return "south-west"
        }
    }
}

// Gives the opposite anchor
#let opposite-anchor(anchor) = {
    if anchor == "north" {
        "south"
    } else if anchor == "south" {
        "north"
    } else if anchor == "east" {
        "west"
    } else if anchor == "west" {
        "east"
    } else if anchor == "north-east" {
        "south-west"
    } else if anchor == "north-west" {
        "south-east"
    } else if anchor == "south-east" {
        "north-west"
    } else if anchor == "south-west" {
        "north-east"
    } else if anchor == "center" {
        "center"
    } else {
        panic("anchor not recognized: " + anchor)
    }
}

#let stroke-to-dict(style) = {
    let style = stroke(style)
    let raw-dict = (
        thickness: style.thickness,
        paint: style.paint,
        join: style.join,
        cap: style.cap,
        miter-limit: style.miter-limit,
        dash: style.dash,
    )
    let dict = (:)
    for (k, v) in raw-dict {
        if v != auto {
            dict.insert(k, v)
        }
    }
    return dict
}

#import "/src/dependencies.typ": cetz

#let resolve(dict) = {
    // Special dictionaries
    let hold = ("stroke", "scale", "position")

    let resolve-recursive(dict, defs) = {
        let dict-defs = (:)
        for (k, v) in dict {
            if type(v) != dictionary {
                if v == auto and k in defs.keys() {
                    dict.at(k) = defs.at(k)
                }
                dict-defs.insert(k, dict.at(k))
            } else if k in hold {
                for key in defs.at(k, default: (:)).keys() {
                    if key in v.keys() and v.at(key) == auto or key not in v.keys() {
                        dict.at(k).insert(key, defs.at(k).at(key))
                    }
                }
                dict-defs.insert(k, dict.at(k))
            }
        }
        for (k, v) in dict {
            if type(v) == dictionary and k not in hold {
                dict.at(k) = resolve-recursive(dict.at(k), defs + dict-defs)
            }
        }
        return dict
    }
    return resolve-recursive(dict, (:))
}

#let expand-stroke(dict) = {
    let expand-stroke-recursive(dict) = {
        for (k, v) in dict {
            if type(v) == dictionary {
                dict.at(k) = expand-stroke-recursive(dict.at(k))
            } else if k == "stroke" and v != auto {
                dict.at(k) = stroke-to-dict(v)
            }
        }
        return dict
    }
    return expand-stroke-recursive(dict)
}

#let set-style(..style) = {
    cetz.draw.set-ctx(ctx => {
        let new-style = style.named()
        for key in new-style.keys() {
            let style-dict = ((key): (new-style.at(key)))
            if ctx.zap.style.at(key, default: (:)) == (:) {
                ctx.style = cetz.styles.merge(ctx.style, style-dict)
            } else {
                ctx.zap.style = cetz.styles.merge(ctx.zap.style, expand-stroke(style-dict))
            }
        }
        return ctx
    })
}

#let resolve-style(style) = {
    if style.arrow.stroke.paint == auto {
        style.arrow.stroke.paint = style.foreground
    }
    if style.stroke.paint == auto {
        style.stroke.paint = style.foreground
    }
    if style.decoration.stroke.paint == auto {
        style.decoration.stroke.paint = style.foreground
    }
    if style.background == auto {
        style.background = ctx.background
    }
    if style.fill == auto {
        style.fill = style.background
    }
    if style.node.fill == auto {
        style.node.fill = style.foreground
    }
    if style.node.nofill == auto {
        style.node.nofill = style.fill
    }
    if style.node.stroke.paint == auto {
        style.node.stroke.paint = none
        style = resolve-style(style)
        style.node.stroke.paint = style.node.fill
        return style
    }
    if style.inductor.fill == auto {
        style.inductor.fill = none
        style = resolve-style(style)
        style.inductor.fill = style.inductor.stroke.paint
        return style
    }
    return resolve(style)
}

#let get-style(ctx) = {
    return resolve-style(ctx.zap.style)
}
