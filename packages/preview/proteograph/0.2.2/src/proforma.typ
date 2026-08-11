#import "ms2_spectra.typ": *
#import "spectrum.typ": *

#let aa-mass-map = (
  G: 57.021463721083 ,
  A: 71.037113785565 ,
  S: 87.032028405125 ,
  P: 97.052763850047 ,
  V:99.068413914529 ,
  T:101.047678469607 ,
  C:103.009184785565 ,
  I:113.084063979011 ,
  L:113.084063979011 ,
  N:114.042927442166 ,
  D:115.026943024685 ,
  Q:128.058577506648 ,
  K:128.094963016052 ,
  E:129.042593089167 ,
  M:131.040484914529 ,
  H:137.058911859647 ,
  F:147.068413914529 ,
  R:156.101111025652 ,
  Y:163.063328534089 ,
  W:186.07931295157 ,
  U:168.964198469607 ,
  O:255.158291550141 ,)

/// Generates the ion series from a peptide sequence
/// -> object
#let get-mass-array-from-proforma(

  /// The peptide in proforma string *required*
  ///
  /// -> strings
  proforma,
) = {
/*
"y": [
    {
        "charge": 1,
        "intensity": 30,
        "mz": 175.119,
        "mzth": 175.118952176573,
        "size": 1
    },*/

    let json-mass-dict = json("./data/psi-mod-mass.json")
    let string_arr = proforma.split("");
    let mass_arr=()
    let delta = ()
    let in_delta = false
    let current_mass_delta = 0
    for aa_char in string_arr {
      if (aa_char == "[") {
        in_delta = true
      }
      else if (aa_char == "]") {
        in_delta = false
        let delta_chr = delta.join()
        delta = ()
        if (delta_chr.starts-with("MOD:")) {
          current_mass_delta = json-mass-dict.at(delta_chr).diff-mono
        } else {
          current_mass_delta = float(delta_chr)
        }
        if (mass_arr.len() > 0) {
          mass_arr.last() = mass_arr.last() + current_mass_delta
          current_mass_delta = 0
        }
      }
      else if aa_char == "-" {}
      else if aa_char == "?" {}
      else if in_delta {
        delta.push(aa_char)
      } else if (aa_char != "") {
        mass_arr.push(aa-mass-map.at(aa_char) + current_mass_delta)
        current_mass_delta = 0
      }
    }
    (mass_arr)
}


/// Generates the peptide sequence from proforma
/// -> text
#let get-sequence-from-proforma(

  /// The peptide in proforma string *required*
  ///
  /// -> strings
  proforma,
) = {
    let string_arr = proforma.split("");
    let sequence_arr=()
    let in_delta = false
    for aa_char in string_arr {
      if (aa_char == "[") {
        in_delta = true
      }
      else if (aa_char == "]") {
        in_delta = false
      }
      else if aa_char == "-" {}
      else if in_delta {
      } else if (aa_char != "") {
        sequence_arr.push(aa_char)
      }
    }
    (sequence_arr.join())
}


/// Generates the ion series from a peptide sequence
/// -> object
#let get-mass-ion-serie(
  mass-array: (),
  type: "",
  charge: 1,
) = {
/*
"y": [
    {
        "charge": 1,
        "intensity": 30,
        "mz": 175.119,
        "mzth": 175.118952176573,
        "size": 1
    },*/
    let ion-mass-array = ()
    let mass-acc=0
    let mass-shift = 0
    if (type == "b") {
      for aa_mass in mass-array {
        mass-acc = mass-acc+ aa_mass
        ion-mass-array.push(mass-acc)
      }
      //mass-shift = 18.01056
    }
    if (type == "y") {
      for aa_mass in mass-array.rev() {
        mass-acc = mass-acc+ aa_mass
        ion-mass-array.push(mass-acc)
      }
      mass-shift = 18.01056
      //mass-shift = 1.00782503207
    }
    (ion-mass-array.map(((inc-mass)) => {
      (inc-mass + mass-shift + (1.007276466879 * charge))/charge
        }))
}


/// Generates the ion series from a peptide sequence
/// -> object
#let get-matching-mass-ion-serie(

  /// Mass spectra values. *Required*.
  ///
  /// a dictionary with the keys `mz` (array of mass to charge ratios) and `intensity` (array of intensities)
  /// with the same length for each array
  /// #parbreak() (e.g., `spectra: (mz: (256.45, 356.89, 523.78), intensity: (200, 298 ,253))`)
  /// ```example
  /// #import "@preview/proteograph:0.2.2": *
  /// #set text(size: 12pt)
  /// #ms2spectra-plot( spectra: (mz: (256.45, 356.89, 523.78), intensity: (200, 298, 253)))
  /// ```
  /// -> none | dictionary
  spectra: none,
  mass-array: (),
  type: "",
  charge-max: 1,
  precision: 0.02,
) = {
/*
"y": [
    {
        "charge": 1,
        "intensity": 30,
        "mz": 175.119,
        "mzth": 175.118952176573,
        "size": 1
    },*/
    let total-ion-list = ()
    let charge = charge-max
    for charge in range(1,charge-max+1) {
      let mass-list = get-mass-ion-serie(mass-array: mass-array, type: type, charge: charge)
      mass-list = mass-list.slice(0,mass-list.len()-1)

      let spectra-zip = spectra.mz.zip(spectra.intensity)

      let mass-dict = mass-list.enumerate().map(((index, inc-mass)) => {
          let mass-element = ("charge": charge, "intensity":0, "mz": 0, "mzth": inc-mass, "size": index+1)

          let peak-match = spectra-zip.find(((mz, intensity)) => {
            if (((mz - precision) < inc-mass ) and (inc-mass < (mz + precision ))) {(true)}
            else {(false)}
            })
          if (peak-match!=none) {
            mass-element.mz = peak-match.at(0)
            mass-element.intensity = peak-match.at(1)
          }
          (mass-element)
            })
          total-ion-list.push((mass-dict))
      }
    (total-ion-list.flatten())
}


#let spoms-bracket-to-proforma(bracket) = {
  //let pat = regex("\[([A-Z]{1})\]")
  let proforma = bracket.replace(regex("\[([A-Z]{1})\]"),((dictr)) => {dictr.captures.at(0)})
   proforma = proforma.replace(regex("\[([0-9])"),((dictr)) => {"[+"+dictr.captures.at(0)})
  (proforma)
}



/// Generates the ion series from a peptide sequence
/// -> object
#let get-ms2spectra-plot-from-proforma(

  /// The width of the diagram. This can be
  /// - A `length`; in this case, it defines just the width of the data area,
  ///   excluding axes, labels, title etc.
  /// - A `ratio` or `relative` where the ratio part is relative to the width
  ///   of the parent that the diagram is placed in. This is not allowed if the
  ///   parent has an unbounded width, e.g., a page with `width: auto`.
  /// -> length | relative
  width: 15cm,

  /// The height of the diagram. This can be
  /// - A `length`; in this case, it defines just the height of the data area,
  ///   excluding axes, labels, title etc.
  /// - A `ratio` or `relative` where the ratio part is relative to the height
  ///   of the parent that the diagram is placed in. This is not allowed if the
  ///   parent has an unbounded height, e.g., a page with `height: auto`.
  /// -> length | relative
  height: 10cm,

  title: none,
  proforma: "",
  spectra: (),
  precision: 0.02,


    /// m/z range to display. *Optional*.
    /// #parbreak() Example: ```js (450, 950)```
    /// -> none | array
    mz-range: none,

    /// maximum intensity to display. *Optional*.
    /// #parbreak() Example: ```js 30000```
    /// -> none | float
    max-intensity: none,
    delta: none,


    /// Whether to clip the matched ion masss delta to the plot. *Optional*.
    /// -> bool
    delta-fragments: false,
    charge-max: 1,
) = {
  let mass-array = get-mass-array-from-proforma(proforma)
  let ion-y = get-matching-mass-ion-serie(spectra: spectra, mass-array: mass-array, type: "y", charge-max: charge-max, precision: precision)
  let ion-b = get-matching-mass-ion-serie(spectra: spectra, mass-array: mass-array, type: "b", charge-max: charge-max, precision: precision)

  let filter-matching(ion-list) = {ion-list}

  let ion-serie = ("y": filter-matching(ion-y), "b": filter-matching(ion-b))

  ms2spectra-plot(width: width,height: height, title: title, spectra: spectra, ion-series: ion-serie, mz-range:mz-range, max-intensity:max-intensity, delta: delta, delta-fragments: delta-fragments)
}


#let compute-hyperscore(
  proforma: "",
  spectra: (),
  precision: 0.02,
  charge-max: 1,
) = {
  spectra = spectra-filter-normalize-intensity(spectra, 100)
  let mass-array = get-mass-array-from-proforma(proforma)
  let ion-y = get-matching-mass-ion-serie(spectra: spectra, mass-array: mass-array, type: "y", charge-max: charge-max, precision: precision)
  let ion-b = get-matching-mass-ion-serie(spectra: spectra, mass-array: mass-array, type: "b", charge-max: charge-max, precision: precision)

  let sum-int = 0
  let count-y = 0
  for ion in ion-y {
    if (ion.mz > 0) {
      sum-int = sum-int + ion.intensity
      count-y = count-y + 1
    }
  }

  let count-b = 0
  for ion in ion-b {
    if (ion.mz > 0) {
      sum-int = sum-int + ion.intensity
      count-b = count-b + 1
    }
  }


  sum-int =  sum-int * calc.fact(count-y);
  sum-int =  sum-int * calc.fact(count-b);


  let hyperscore = (calc.log(sum-int, base: 10) * 4);
  if(hyperscore < 0) {
    hyperscore = 0
  }
  (hyperscore)
}
