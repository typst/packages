#import "../codly.typ": *

#let icon(codepoint) = {
  text(
      font: "tabler-icons", 
      fallback: false, 
      weight: "regular", 
      size: 8pt,
  )[#codepoint]
}

#set raw(syntaxes: (
  "./Phos.sublime-syntax"
))

#show: codly.with(languages: (
  rust: (name: "Rust", icon: icon("\u{fa53}"), color: rgb("#CE412B")),
  phos: (name: "PHÔS", icon: icon("\u{ed8a}"), color: rgb("#de8f6e")),
))

```rust
pub fn main() {
    println!("Hello, world!");
}
```

```phos
syn beam_forming(
    input: optical,
    phase_shifts: (electrical...),
) -> (optical...) {
    input
        |> split(splat(1.0, phase_shifts.len()))
        |> constrain(d_phase = 0)
        |> zip(phase_shifts)
        |> map(set modulate(type_: Modulation::Phase))
        |> constrain(d_delay = 0)
}
```