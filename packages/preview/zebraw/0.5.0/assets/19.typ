#{
// render_code
context zebraw-init(
  fast-preview: true,
  indentation: 2,
  [
    #context preview(````typ
    #zebraw(
      hanging-indent: true,
      ```typ
      #let forecast(day) = block[
        #box(square(
          width: 2cm,
          inset: 8pt,
          fill: if day.weather == "sunny" {
            yellow
          } else {
            aqua
          },
          align(
            bottom + right,
            strong(day.weather),
          ),
        ))
        #h(6pt)
        #set text(22pt, baseline: -8pt)
        #day.temperature °#day.unit
      ]
      ```
    )
    ````)
  ],
)
}