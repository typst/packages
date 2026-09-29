#import "generic.typ" as generic;
#import "../utils.typ" as utils;

/// Checks if the given content is a panic box created by the error-box function.
#let is_panic(c) = {
  return (
    type(c) == content
      and c.func() == box
      and c
        .fields()
        .pairs()
        .find(((k, v)) => (
          k == "body"
            and "children" in v.fields()
            and v
              .fields()
              .at("children")
              .find(el => el.func() == metadata and el.fields().at("value").at("flag") == "sertyp:panic")
              != none
        ))
        != none
  )
}

#let serializer(c) = {
  utils.assert_type(c, content)
  utils.assert(c.func(), box)
  let body = c.fields().at("body")
  utils.assert_type(body, content)

  import "function.typ" as func_
  utils.assert(func_.serializer(body.func()), "sequence")
  let children = body.fields().at("children")
  utils.assert_type(children, array)
  let meta = children.find(el => el.func() == metadata).at("value")

  return generic.raw_serializer(dictionary)((
    type: meta.at("type"),
    msg: generic.serializer(meta.at("msg")),
  ))
};

#let error-box(ty, msg, small: false) = {
  let bg = rgb("#fdecea")
  let border = rgb("#f5c2c7")
  let text-color = rgb("#842029")
  let icon-red = rgb("#dc3545")

  box(
    fill: bg,
    stroke: border,
    radius: 8pt,
    inset: if small { 5pt } else { 12pt },
  )[
    #stack(
      dir: ltr,
      spacing: if small { 4pt } else { 10pt },
      [
        #circle(
          radius: if small { 8pt } else { 10pt },
          fill: icon-red,
        )[
          #set text(
            fill: white,
            weight: "extrabold",
            size: if small { 10pt } else { 13pt },
            baseline: if small { -2.5pt } else { -2pt },
          )
          #align(center, [!])
        ]
      ],
      [
        #set text(fill: text-color, weight: "regular", baseline: 0pt, size: if small { 8pt } else { 11pt })
        #strong(ty) #parbreak() #v(if small { -5pt } else { -8pt }) #msg
      ],
    )
    #metadata((
      flag: "sertyp:panic",
      type: ty,
      msg: msg,
    ))
  ]
}


#let deserializer(
  m,
  ctx,
) = {
  let (ty, msg) = (m.at("type"), generic.deserializer(m.at("msg"), ctx))
  utils.assert_type(ty, str)
  utils.assert_type(msg, content)
  if ctx.at("panic", default: false) == true {
    panic(ty + ": " + msg)
  }
  error-box(ty, msg, small: ctx.at("small", default: false))
};

#let test(cycle) = {
  let ty = "Test Error"
  let msg = [This is a test error message.]
  let box = error-box(ty, msg)
  utils.assert(is_panic(box), true)

  utils.assert(generic.serializer(box), (type: "panic", value: (type: ty, msg: generic.serializer(msg))))
  cycle(box)
};
