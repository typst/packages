#import "@preview/typsidian:0.0.3": *

#let edge(big: false, ..args) = {
  let inner = if args.pos().len() > 0 { args.pos().first() } else { [$u, v$] }
  if big {
    $lr(chevron.l #inner chevron.r)$
  } else {
    $chevron.l #inner chevron.r$
  }
}

#let arc(big: false, ..args) = {
  let inner = if args.pos().len() > 0 { args.pos().first() } else { [$u\, v$] }
  if big {
    $lr(accent(chevron.l #inner chevron.r, arrow))$
  } else {
    $accent(chevron.l #inner chevron.r, arrow)$
  }
}

#show: typsidian.with(
  title: "Title",
  author: "Author Name",
  course: "Some Course",
  // theme: "dark"
)

#make-title(show-outline: false, show-author: true, justify: "left")

= Lorem Ipsum Dolor

- Lorem ipsum dolor sit amet, *consectetur adipiscing elit*. Duis pharetra rutrum lectus, id _semper_ metus pharetra a.

#term(pronunciation: [con #sym.bullet sect #sym.bullet etur])[consectetur][#lorem(15)]

== Nullam Suscipit Convallis Bibendum

- Nunc nulla elit, vestibulum nec justo eu, blandit porta justo. Praesent vel purus dictum lorem accumsan dapibus sed in dolor. Nulla luctus lacus *ullamcorper varius scelerisque*.

#box(theme: "example", title: "Fusce quis fermentum", [
  Donec varius _venenatis nibh_. Nunc urna enim, _suscipit quis libero ac_, dignissim pretium arcu. Nam purus felis, _imperdiet_ at lectus ut, maximus viverra nunc.
])

=== Quisque Sit Sagittis Dolor

- Aenean quis rhoncus metus, at dictum enim. Etiam tristique tortor turpis, eu tempor neque tempor sit amet:

$
  tilde(X) (e^(j omega)) = sum^infinity_(k=-infinity) (2 pi)/N tilde(X) [k] delta (omega - (2 pi k)/N).
$

- Integer sit amet porta magna, eget dapibus tortor. Fusce quis fermentum purus. Sed hendrerit lectus sed quam sagittis fermentum. Duis at *accumsan sapien*. Maecenas volutpat mi id _nisl scelerisque_ iaculis:

$
  1/(2 pi) integral_(-epsilon)^(2 pi - epsilon) tilde(X)(e^(i omega)) e^(i omega n) d omega
  = 1/N sum_(k=-infinity)^infinity tilde(X)[k]
  integral_(-epsilon)^(2 pi - epsilon)
  delta(omega - (2 pi k)/N) e^(i omega n) d omega = 1/N sum_(k=0)^(N - 1) tilde(X)[k] e^(i (2 pi \/ N) k n).
$

#box(theme: "important", [
  Donec varius _venenatis nibh_. Nunc urna enim, _suscipit quis libero ac_, dignissim pretium arcu. Nam purus felis, _imperdiet_ at lectus ut, maximus viverra nunc.
])

==== Donec Hendrerit Lectus eu Convallis

- Donec hendrerit eget lectus eu convallis. Vestibulum ante *ipsum primis* in faucibus orci luctus et ultrices posuere cubilia curae; Morbi faucibus neque lectus, eu congue _lectus lacinia_ vitae.

```cpp
for (int j = 0; j < k; j++) {
  for (int i = 0; i < M; i++) {
    double angle = (2.0 * PI * j * i) / M;
    dft_value[j].real += function[i] * cos(angle);
    dft_value[j].img -= function[i] * sin(angle);
  }
}
```

- Ut vel mauris #c("real") in quam #c("img") dignissim ullamcorper. Sed lobortis vel #c("angle") massa nec tincidunt. .
