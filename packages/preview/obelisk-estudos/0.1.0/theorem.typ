// Ambientes numerados: numeração compartilhada, rótulos laterais e referências.

#import "settings.typ": settings
#import "theme.typ": theorem-style
#import "layout.typ": place-side

// Largura da barra colorida que marca o ambiente na margem externa.
#let theorem-bar = 4pt

// Todos os ambientes compartilham um contador: <matéria>.<assunto>.<n>.
#let thm-counter = counter("theorem")

// Renderiza um ambiente: barra lateral, rótulo e conteúdo.
#let theorem-render(env, title, number, body, theme-key: "theorem") = context {
  let s = settings.get()
  let style = theorem-style(s.theme, theme-key)

  let label = block(
    width: s.side.width,
    text(
      fill: style.label,
      font: s.fonts.sans,
      [*#env #number*\ #if title != none { title }],
    ),
  )

  // A barra ultrapassa o bloco em meio passo da grade de cada lado.
  let overshoot = s.texts.step / 2
  block(
    block([#place-side(label) #body], width: s.body.width, breakable: true),
    width: 100%,
    breakable: true,
    outset: (
      left: s.side.half-gutter,
      right: s.side.half-gutter,
      top: overshoot,
      bottom: overshoot,
    ),
    stroke: (left: (paint: style.paint, thickness: theorem-bar)),
  )
}

// Aplicado por `init`: ajusta a figura, reinicia a numeração por matéria e
// formata referências numeradas e referências pelo título.
#let theorem-rules(it, base-level: 1, pattern: "1.1.1") = {
  show figure.where(kind: "theorem"): it => align(left, it.body)

  thm-counter.update((1,))

  // Reinicia a numeração e mantém os números dos títulos como prefixo.
  show heading: it => {
    it
    if it.numbering != none and it.level <= base-level {
      context {
        thm-counter.update(counter(heading).get() + (1,))
      }
    }
  }

  show ref: it => {
    let el = it.element
    if el != none and el.func() == figure and el.kind == "theorem" {
      let location = el.location()
      if it.supplement == [!] and el.caption != none {
        return link(location, el.caption.body)
      }
      return link(
        location,
        [#el.supplement #numbering(pattern, ..thm-counter.at(location))],
      )
    }
    it
  }

  it
}

// Os ambientes aceitam `[conteúdo]` ou `[título][conteúdo]`.
#let split-arguments(args, name) = {
  if args.len() == 1 {
    (none, args.at(0))
  } else if args.len() == 2 {
    (args.at(0), args.at(1))
  } else {
    panic(
      name + " expects 1 or 2 positional arguments, got " + str(args.len()) + ".",
    )
  }
}

// Cria uma função de ambiente. `theme-key` seleciona o traço correspondente no tema.
#let make-environment(full-name, short-name, theme-key) = (..args) => {
  let (title, body) = split-arguments(args.pos(), full-name)
  figure(
    kind: "theorem",
    supplement: full-name,
    caption: title,
    outlined: false,
  )[
    #context {
      let s = settings.get()
      thm-counter.step(level: s.headings.thm.base + 1)
      theorem-render(
        short-name,
        title,
        numbering(s.headings.thm.numbering, ..thm-counter.get()),
        body,
        theme-key: theme-key,
      )
    }
  ]
}

#let theorem = make-environment("Teorema", "TEO", "theorem")
#let proposition = make-environment("Proposição", "PROP", "proposition")
#let corollary = make-environment("Corolário", "COR", "corollary")
#let lemma = make-environment("Lema", "LEM", "lemma")
#let definition = make-environment("Definição", "DEF", "definition")
#let example = make-environment("Exemplo", "EX", "example")
#let remark = make-environment("Observação", "OBS", "remark")

// Aliases em português para manter uma API natural nos arquivos de estudo.
#let teorema = theorem
#let proposicao = proposition
#let corolario = corollary
#let lema = lemma
#let definicao = definition
#let exemplo = example
#let observacao = remark

#let proof(..args) = context {
  let (title, body) = split-arguments(args.pos(), "Demonstração")
  let s = settings.get()
  let half-gutter = s.side.half-gutter
  block(
    width: 100%,
    breakable: true,
    outset: (
      left: half-gutter,
      right: half-gutter,
      top: s.texts.ascender,
      bottom: 0pt,
    ),
  )[
    _#if title != none { [#title] } else { [Demonstração] }._ #body #h(1fr) $square$
  ]
}

#let prova = proof
