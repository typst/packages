#import "lib.typ": *

#show: project.with(
  title: "Notes on ...",
  author: "Your Name",
  academic-year: "Academic year 2025-2026",
  logo: "UGR-Logo.png", // Your logo
  orcid: "https://orcid.org/xxxx-xxxx-xxxx-xxxx", // Your number
  github: "https://github.com/Your_Username",
)

= Tema 1

Esta es una introducción al tema. Typst ajusta el texto automáticamente.


== Espacios de Probabilidad

#definicion("Espacio de Probabilidad")[
  Un espacio de probabilidad es una terna $(Omega, cal(A), P)$ donde:
  - $Omega$: Espacio muestral.
  - $cal(A)$: $sigma$-álgebra de sucesos.
  - $P$: Medida de probabilidad tal que $P(Omega)=1$.
]

#teorema("Teorema Central del Límite")[
  Dadas $X_1, ..., X_n$ v.a. i.i.d con media $mu$ y varianza $sigma^2$:
  $ sqrt(n) (bar(X)_n - mu) / sigma arrow.r N(0,1) $
]

#demostracion[
  La demostración se basa en la función característica. Sea $phi_X(t)$ la función característica...

  Como vemos, es trivial.
]

== Código en Rust
Aquí tienes un ejemplo de código con resaltado automático:

```rust
fn main() {
    let x: Vec<i32> = vec![1, 2, 3];
    println!("El vector es: {:?}", x);
}
```

