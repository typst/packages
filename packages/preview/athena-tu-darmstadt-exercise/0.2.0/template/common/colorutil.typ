#let calc-color-component(srgb) = {
  if srgb <= 0.03928 {
    return srgb / 12.92
  } else {
    return calc.pow((srgb + 0.055) / 1.055, 2.4)
  }
}

#let calc-relative-luminance(color) = {
  let rgb_color = rgb(color.to-hex())
  let components = rgb_color.components(alpha: false)

  let r_srgb = float(components.at(0))
  let b_srgb = float(components.at(1))
  let g_srgb = float(components.at(2))
  return calc-color-component(r_srgb) * 0.2126 + calc-color-component(b_srgb) * 0.0722 + calc-color-component(g_srgb) * 0.7152
}

#let calc-contrast(rl1, rl2) = {
  let l1 = calc.max(rl1, rl2)
  let l2 = calc.min(rl1, rl2)
  return (l1 + 0.05) / (l2 + 0.05)
}