#import "template.typ": *

#let pg-snippet(the_file) = {


  heading(level: 3, "Example :")
  raw(read(the_file), lang:"typst")

  heading(level: 3, "Result :")
  {
    include(the_file)
  }
}


= Reference

== Retention time alignment

The alignment of retention times between MS runs done with MassChroQ3 are represented as follow in the JSON output

#code-block(read("mcq3_alignment.json"), "json", title: "MS run alignment data")


#pg-snippet("../examples/rt_align.typ")


#{
  let module = tidy.parse-module(read("../src/rt_align.typ"), name: "Retention time alignment full documentation")
  tidy.show-module(module, style: tidy.styles.default)
}


== MS2 spectra

=== Simple MS2 spectra


The spectra is a dictionnary containing 2 arrays of floats : mz and intensity

#code-block(read("spectra.json"), "json", title: "spectra dictionnary")

#pg-snippet("../examples/simple_psm.typ")

=== MS2 spectra with ion annotations

This example shows an MS2 spectra with ion series annotation

The ion annotations are described in a dictionnary :

#code-block(read("ion-series.json"), "json", title: "ion-series dictionnary")

The first key is the ion series name as follow :

#ion-colors.keys().join(", ")

and any ion can be described by :

#{
let module = tidy.parse-module(read("ion_description.typ"))
tidy.show-module(module, style: tidy.styles.default)
}

#pg-snippet("../examples/complete_psm.typ")

=== MS2 spectra zoom (mz_range and intensity)

This example shows an MS2 spectra zoomed on a specific  m/z range and maximum intensity.

#pg-snippet("../examples/complete_psm_mzrange.typ")

=== MS2 spectra with ion annotations and MS2 fragments mass delta

This example shows an MS2 spectra with ion series annotation
#pg-snippet("../examples/complete_psm_delta_fragments.typ")

#{
  let module = tidy.parse-module(read("../src/ms2_spectra.typ"), name: "MS2 spectra full documentation")
  tidy.show-module(module, style: tidy.styles.default)
}
