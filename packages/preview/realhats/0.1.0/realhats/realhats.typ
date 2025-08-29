#import "@preview/suiji:0.3.0": gen-rng-f, choice-f
#import "@preview/jumble:0.0.1": sha1

// Filepaths and placement information for each hat
#let realhats-dict = (
  "ash": (
    "image": image(
      "hats/realhats-ash.svg",
      width: 0.776em
    ),
    "dx": 0.000em,
    "dy": 0.100em
  ),
  "beret": (
    "image": image(
      "hats/realhats-beret.svg",
      width: 1.078em
    ),
    "dx": 0.150em,
    "dy": 0.350em
  ),
  "birthday": (
    "image": image(
      "hats/realhats-birthday.svg",
      width: 0.819em
    ),
    "dx": 0.000em,
    "dy": 0.050em
  ),
  "cowboy": (
    "image": image(
      "hats/realhats-cowboy.svg",
      width: 0.948em
    ),
    "dx": 0.000em,
    "dy": 0.080em
  ),
  "crown": (
    "image": image(
      "hats/realhats-crown.svg",
      width: 0.948em
    ),
    "dx": 0.000em,
    "dy": 0.060em
  ),
  "dunce": (
    "image": image(
      "hats/realhats-dunce.svg",
      width: 0.703em
    ),
    "dx": 0.000em,
    "dy": 0.080em
  ),
  "fez": (
    "image": image(
      "hats/realhats-fez.svg",
      width: 0.431em
    ),
    "dx": 0.000em,
    "dy": 0.100em
  ),
  "mortarboard": (
    "image": image(
      "hats/realhats-mortarboard.svg",
      width: 0.862em
    ),
    "dx": 0.000em,
    "dy": 0.080em
  ),
  "policeman": (
    "image": image(
      "hats/realhats-policeman.svg",
      width: 0.776em
    ),
    "dx": 0.000em,
    "dy": 0.110em
  ),
  "santa": (
    "image": image(
      "hats/realhats-santa.svg",
      width: 0.962em
    ),
    "dx": 0.110em,
    "dy": 0.066em
  ),
  "scottish": (
    "image": image(
      "hats/realhats-scottish.svg",
      width: 1.078em
    ),
    "dx": 0.220em,
    "dy": 0.370em
  ),
  "sombrero": (
    "image": image(
      "hats/realhats-sombrero.svg",
      width: 0.862em
    ),
    "dx": 0.000em,
    "dy": 0.075em
  ),
  "tophat": (
    "image": image(
      "hats/realhats-tophat.svg",
      width: 0.776em
    ),
    "dx": 0.000em,
    "dy": 0.130em
  ),
  "witch": (
    "image": image(
      "hats/realhats-witch.svg",
      width: 0.862em
    ),
    "dx": 0.000em,
    "dy": 0.050em
  ),
  "tile-blue": (
    "image": image(
      "hats/realhats-tile-blue.svg",
      width: 0.862em
    ),
    "dx": 0.000em,
    "dy": 0.090em
  ),
  "tile-gray": (
    "image": image(
      "hats/realhats-tile-gray.svg",
      width: 0.862em
    ),
    "dx": 0.000em,
    "dy": 0.090em
  ),
  "tile-light-blue": (
    "image": image(
      "hats/realhats-tile-light-blue.svg",
      width: 0.862em
    ),
    "dx": 0.000em,
    "dy": 0.090em
  ),
  "tile-white": (
    "image": image(
      "hats/realhats-tile-white.svg",
      width: 0.862em
    ),
    "dx": 0.000em,
    "dy": 0.090em
  ),
  "vueltiao": (
    "image": image(
      "hats/vueltiao.png",
      width: 1.0em
    ),
    "dx": 0.000em,
    "dy": 0.100em
  )
)

#let realhats-list = realhats-dict.keys()

// Seed random number generator using the current date
#let seed-bytes = sha1(datetime.today().display())
#let seed = int.from-bytes(seed-bytes.slice(0, 8))
#let hat-rng = gen-rng-f(seed)
#let (hat-rng, first-hat) = choice-f(hat-rng, realhats-dict.keys())
#let hat-rng-state = state("hat-rng-state", (hat-rng, first-hat))

// To be used inside realhat
#let place-hat(body, hat, dx: 0em, dy: 0em) = {
  h(0em, weak: true)
  set align(center)
  set text(top-edge: "bounds", bottom-edge: "baseline")
  box(stack(
    dir: btt,
    {
      set text(top-edge: "bounds")
      $body$
    },
    v(-dy),
    {
      move(hat, dx: dx)
    }
  ))
  h(0em, weak: true)
}

// Place random hat on top of input body
#let realhat(body, hat: none) = context {
  if hat == none {
    hat-rng-state.update(((rng, _)) => choice-f(rng, realhats-dict.keys()))
    let hat-choice-name = hat-rng-state.get().at(1)
    let hat-choice = realhats-dict.at(hat-choice-name)
    place-hat(body, hat-choice.image, dx: hat-choice.dx, dy: hat-choice.dy)
  } else {
    let hat-choice = realhats-dict.at(hat)
    place-hat(body, hat-choice.image, dx: hat-choice.dx, dy: hat-choice.dy)
  }
}

#let hat = realhat // To replace standard hat function in math mode