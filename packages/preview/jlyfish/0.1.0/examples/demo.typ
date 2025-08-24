#import "../typst/lib.typ": *

#set page(width: auto, height: auto, margin: 1em)
#set text(font: "Alegreya Sans")
#let note = text.with(size: .7em, fill: luma(100), style: "italic")

#read-julia-output(json("demo-jlyfish.json"))
#jl-pkg("Colors", "Typstry", "Makie", "CairoMakie")

#grid(
  columns: 2,
  gutter: 1em,
  align: top,
  [
    #note[Generate Typst code in Julia:]

    #set text(size: 4em)
    #jl(```julia
      using Typstry, Colors

      parts = map([:red, :green, :purple], ["Ju", "li", "a"]) do name, text
        color = hex(Colors.JULIA_LOGO_COLORS[name])
        "#text(fill: rgb(\"$color\"))[$text]"
      end
      TypstText(join(parts))
    ```)
  ],
  [
    #note[Produce images in Julia:]

    #set image(width: 10em)
    #jl(recompute: false, logs: false, ```
      using Makie, CairoMakie

      as = -2.2:.01:.7
      bs = -1.5:.01:1.5
      C = [a + b * im for a in as, b in bs]
      function mandelbrot(c)
        z = c
        i = 1
        while i < 100 && abs2(z) < 4
          z = z^2 + c
          i += 1
        end
        i
      end

      contour(as, bs, mandelbrot.(C), axis = (;aspect = DataAspect()))
    ```)
  ],
  [
    #note[Hand over raw data from Julia to Typst:]
    #let barchart(counts) = {
      set align(bottom)
      let bars = counts.map(count => rect(
        width: .3em,
        height: count * 9em,
        stroke: white,
        fill: blue,
      ))
      stack(dir: ltr, ..bars)
    }

    #jl-raw(fn: it => barchart(it.result.data), ```julia
      p = .5
      n = 40
      counts = zeros(n + 1)
      for _ in 1:10_000
        count = 0
        for _ in 1:n
          if rand() < p
            count += 1
          end
        end
        counts[count + 1] += 1
      end

      counts ./= maximum(counts)
      lo, hi = findfirst(>(1e-3), counts), findlast(>(1e-3), counts)
      counts[lo:hi]
    ```)
  ],
  [
    #note[See errors, stdout, and logs:]

    #jl(```julia
      println("Hello from stdout!")
      @info "Something to note" n p
      @warn "You should read this!"
      unknown
    ```)
  ]
)


