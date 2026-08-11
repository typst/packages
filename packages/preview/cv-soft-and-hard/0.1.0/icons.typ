#let icon-template(img, alt, baseline: 0.15em, height: 1em, ..box-args) = {
  box(
    image(
      img,
      alt: alt,
      height: height,
    ),
    baseline: baseline,
    ..box-args,
  )
}

#let rust = {
  icon-template(
    "icons/Rust_programming_language_black_logo.svg",
    "Rust Icon",
  )
}

#let cpp = {
  icon-template(
    "icons/ISO_C++_Logo.svg",
    "C++ Icon",
  )
}

#let cplain = {
  icon-template(
    "icons/C_Programming_Language.svg",
    "C Icon",
  )
}

#let csharp = {
  icon-template(
    "icons/Logo_C_sharp.svg",
    "C Sharp Icon",
  )
}

#let python = {
  icon-template(
    "icons/Python-logo-notext.svg",
    "Python Icon",
  )
}

#let typst-logo = {
  icon-template(
    "icons/Typst-t.svg",
    "Typst Icon",
    clip: true,
    radius: 0.1em,
    fill: gradient.linear(rgb("#5bdaa7"), rgb("#239caf"), angle: 45deg),
    inset: 2pt,
    height: 1em - 4pt
  )
}

#let hugo = {
  icon-template(
    "icons/Hugo.svg",
    "Hugo Icon"
  )
}

#let javascript = {
  icon-template(
    "icons/Unofficial_JavaScript_logo_2.svg",
    "Javascript Icon",
    clip: true,
    radius: 0.1em,
  )
}

#let typescript = {
  icon-template(
    "icons/Typescript_logo_2020.svg",
    "Typescript Icon",
  )
}

#let php = {
  icon-template(
    "icons/Official PHP Logo.svg",
    "PHP Icon",
  )
}

#let swift = {
  icon-template(
    "icons/swift-svgrepo-com.svg",
    "Swift Icon",
  )
}

#let java = {
  icon-template(
    "icons/java_logo_logos_icon.svg",
    "Java Icon",
  )
}

#let go = {
  icon-template(
    "icons/Go_Logo_Blue.svg",
    "Go Icon",
    height: 0.9em,
  )
}

#let lua = {
  icon-template(
    "icons/Lua-Logo.svg",
    "Lua Icon",
  )
}
