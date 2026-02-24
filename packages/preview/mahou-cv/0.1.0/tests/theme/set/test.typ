#import "/src/theme.typ": set-theme, theme-state

#let user-theme = (
  margin: 23pt,
  font: "EB Garamond",
  color: (
    header: (
      accent: red,
      body: red,
    )
  )
)

#set-theme(user-theme)

#context {
  let theme = theme-state.get()
  assert.eq(theme.margin, 23pt)
  assert.eq(theme.font, "EB Garamond")
  assert.eq(theme.color.header.accent, red)
  assert.eq(theme.color.header.body, red)
}
