#import "/src/symbol.typ": interface, symbol
#import "/src/deps.typ": cetz
#import cetz.draw: line, on-layer, rect, set-style

/// Battery symbol to use inside a circuit
///
/// - name (str): symbole unique identifier
/// - node (coordinate): symbol position coordinates
/// - cells (int | 'multi'): number of battery cells
/// - show-polarity (bool): displays polarity
/// -> content
#let battery(name, node, cells: 2, polarity: false, ..params) = {
    assert(type(cells) == str and cells == "multi" or type(cells) == int and cells >= 1, message: "cells must be 'multi' or at least 1 number")

    // Drawing function
    let draw(ctx, position, style) = {
        set-style(stroke: style.stroke)

        let width
        if cells == "multi" {
            width = style.distance * 2 + style.multi.distance

            line((-width / 2, -style.minus-width / 2), (rel: (0, style.minus-width)))
            line((-width / 2 + style.distance, -style.plus-width / 2), (rel: (0, style.plus-width)))

            let step = style.multi.distance / style.multi.number / cetz.util.resolve-number(ctx, 1pt) * 1pt
            line((-width / 2 + style.distance, 0), (rel: (style.multi.distance, 0)), stroke: (dash: (step, step)))

            line((width / 2 - style.distance, -style.minus-width / 2), (rel: (0, style.minus-width)))
            line((width / 2, -style.plus-width / 2), (rel: (0, style.plus-width)))
        } else {
            width = style.distance * (cells * 2 - 1)

            for i in range(cells * 2, step: 2) {
                line((-width / 2 + style.distance * i, -style.minus-width / 2), (rel: (0, style.minus-width)))
                line((-width / 2 + style.distance * (i + 1), -style.plus-width / 2), (rel: (0, style.plus-width)))
            }
        }
        interface((-width / 2, -style.plus-width / 2), (width / 2, style.plus-width / 2), io: position.len() < 2)

        if polarity {
            set-style(stroke: ctx.style.zap.sign.stroke)
            line((-width / 2 - style.polarity.padding.at(0), (style.plus-width / 2 + style.polarity.padding.at(1) + ctx.style.zap.sign.size) * style.polarity.side), (
                rel: (-2 * ctx.style.zap.sign.size, 0),
            ))
            line((width / 2 + style.polarity.padding.at(0) + ctx.style.zap.sign.size, (style.plus-width / 2 + style.polarity.padding.at(1)) * style.polarity.side), (
                rel: (0, 2 * ctx.style.zap.sign.size),
            ))
            line((rel: (ctx.style.zap.sign.size, -ctx.style.zap.sign.size)), (rel: (-2 * ctx.style.zap.sign.size, 0)))
        }
    }

    // Constructor call
    symbol("battery", name, node, draw: draw, ..params)
}

#let cell(name, node, ..params) = battery(name, node, ..params, cells: 1)
#let multicell(name, node, ..params) = battery(name, node, ..params, cells: "multi")
