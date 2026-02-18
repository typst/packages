#import "/src/lib.typ": zebraw

#let _exp(left, right) = {
  block(
    breakable: false,
    html.elem(
      "div",
      (
        left,
        html.elem("div", right, attrs: (style: "padding: 1em; font-size: 0.9em;")),
      ).join(),
      attrs: (class: "exp", style: "margin: 1em 0em;"),
    ),
  )
}
#let exp(code, frame: false) = {
  _exp(
    html.elem("pre", code.text, attrs: (style: "white-space: pre-wrap;")),
    {
      let body = eval(code.text, mode: "markup", scope: (zebraw: zebraw))
      if frame {
        html.elem("div", html.frame(body), attrs: (class: "frame"))
      } else {
        body
      }
    },
  )
}


#let html-example(body) = {
  html.elem(
    "script",
    attrs: (src: "https://unpkg.com/@tailwindcss/browser@4"),
  )
  html.elem(
    "style",
    // 48rem is from tailwindcss, the medium breakpoint.
    ```css
    @media (width >= 64rem) {
      .exp {
        display: grid;
        grid-template-columns: 50% 50%;
        gap: 0.5em;
      }
    }

    @media (width < 64rem) {
      .exp {
        display: block;
      }
    }

    .frame {
      shadow: 0 0 0.5em rgba(0, 0, 0, 0.1);
      border-radius: 0.5em;
      background: #fff;
      padding: 0.5em;
    }
    ```.text,
  )

  html.elem(
    "div",
    attrs: (class: "container xl:max-w-5xl mx-auto p-4"),

    {
      html.elem(
        "h1",
        attrs: (
          class: "text-2xl font-bold underline",
        ),
        [🦓 Zebraw but in HTML world],
      )

      html.elem("h2", [Example], attrs: (class: "text-xl font-bold"))

      [#body]
    },
  )
}
