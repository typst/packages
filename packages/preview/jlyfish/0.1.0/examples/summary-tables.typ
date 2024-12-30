#import "../typst/lib.typ": *

#set page(height: auto, width: auto, margin: 1em)

#read-julia-output(json("summary-tables-jlyfish.json"))

#jl-pkg("SummaryTables")

#jl(```julia
  using SummaryTables
```)

#jl(```julia
  n = 123
  data = (
    sex = rand(["male", "female"], n),
    age = rand(18:60, n),
    typesetting = rand(["Typst", "LaTeX"], n),
    citations = rand(0:100, n),
    editor = rand(["vim", "emacs", "helix", "nano", "micro", "amp"], n)
  )

  table_one(
    data,
    [
      :sex => "Sex",
      :age => "Age (years)",
      :typesetting => "Preferred typesetting system",
      :citations => "Number of citations",
    ],
    groupby = :editor => "Preferred text editor",
    show_n = true,
  )
```)
