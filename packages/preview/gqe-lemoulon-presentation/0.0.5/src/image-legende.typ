
#let image-legende(width: auto, image: none, body) = block(width: width, {
    stack(dir: ttb, spacing: 0.2em,{
        image
    },{
        set align(horizon+center)
        set text(size: 14pt)
        body
    }
    )
}
)


