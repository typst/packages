#import "@preview/cetz:0.2.2"
#import "styles.typ": *

#let render-activities(slices: ()) = {
    cetz.canvas({
        import cetz.chart
        // A linear gradient from blue gradient-init to blue gradient-end
        let gradient = gradient.linear(colors.gradient-init, colors.gradient-end)

        chart.piechart(
            slices,
            radius: 1.5,
            slice-style: gradient,
            inner-radius: .5,
            label-key: "name",
            value-key: "val",
        )
    })
}