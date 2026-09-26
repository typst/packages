#import "ms2_spectra.typ": *
#import "spectrum.typ": *
#import "proforma.typ": *


#let generate-ms2pip-spectra(
  mz-start: 0,
  mz-stop: 30000,
  ms2pip: (),
  y-max-intensity: 1,
  b-max-intensity: 1,
  max-intensity: 1,
) = {
  let y-ratio = y-max-intensity
  let b-ratio = y-ratio * (b-max-intensity / y-max-intensity)
  let mass-dict-y = (
    ms2pip
      .theoretical_mz
      .y
      .enumerate()
      .map(((index, inc-mass)) => {
        (inc-mass, ms2pip.predicted_intensity.y.at(index) * y-ratio * 0.1)
      })
  )
  let mass-dict-b = (
    ms2pip
      .theoretical_mz
      .b
      .enumerate()
      .map(((index, inc-mass)) => {
        (inc-mass, ms2pip.predicted_intensity.b.at(index) * b-ratio * 0.1)
      })
  )

  let mz = ()
  let intensity = ()

  for (mz-item, intensity-item) in mass-dict-y {
    if ((mz-item <= mz-stop) and (mz-item >= mz-start)) {
      mz.push(mz-item)
      intensity.push(intensity-item)
    }
  }
  for (mz-item, intensity-item) in mass-dict-b {
    if ((mz-item <= mz-stop) and (mz-item >= mz-start)) {
      mz.push(mz-item)
      intensity.push(intensity-item)
    }
  }

  ("mz": mz, "intensity": intensity)
}


/// Generates the ion series from a peptide sequence
/// -> object
#let get-ms2pip-matching-mass-ion-serie(
  ms2pip-spectra: none,
  ion-serie: (),
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

  let spectra-zip = ms2pip-spectra.mz.zip(ms2pip-spectra.intensity)
  for ion in ion-serie {
    let peak-match = spectra-zip.find(((mz, intensity)) => {
      if (((mz - precision) < ion.mz) and (ion.mz < (mz + precision))) { true } else { false }
    })
    if (peak-match != none) {
      ion.mz = peak-match.at(0)
      ion.intensity = peak-match.at(1)
      total-ion-list.push(ion)
    }
  }
  (total-ion-list.flatten())
}



/// Generates the ion series from a peptide sequence
/// -> object
#let compar-ms2spectra-proforma-with-ms2pip-spectra(
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
  ms2pip: (),
  precision: 0.02,
  /// m/z range to display. *Optional*.
  /// #parbreak() Example: ```js (450, 950)```
  /// -> none | array
  mz-range: none,
  /// maximum intensity to display. *Optional*.
  /// #parbreak() Example: ```js 30000```
  /// -> none | float
  max-intensity: none,
  charge-max: 1,
) = {
  let mass-array = get-mass-array-from-proforma(proforma)
  let ion-y = get-matching-mass-ion-serie(
    spectra: spectra,
    mass-array: mass-array,
    type: "y",
    charge-max: charge-max,
    precision: precision,
  )
  let ion-b = get-matching-mass-ion-serie(
    spectra: spectra,
    mass-array: mass-array,
    type: "b",
    charge-max: charge-max,
    precision: precision,
  )

  let ms2pip-arr = generate-ms2pip-spectra(
    mz-start: spectra.mz.first(),
    mz-stop: spectra.mz.last(),
    ms2pip: ms2pip,
    y-max-intensity: ion-y.fold(0, (acc, x) => calc.max(
      acc,
      x.intensity,
    )),
    b-max-intensity: ion-b.fold(0, (acc, x) => calc.max(
      acc,
      x.intensity,
    )),
    max-intensity: spectra.intensity.fold(0, (acc, x) => calc.max(
      acc,
      x,
    )),
  )
  for mzitem in ms2pip-arr.mz {
    spectra.mz.push(mzitem)
  }
  for mzitem in ms2pip-arr.intensity {
    spectra.intensity.push(mzitem)
  }

  let sorted-spectra = ("mz": (), "intensity": ())
  for (mz, intensity) in spectra.mz.zip(spectra.intensity).sorted(by: (ita, itb) => (ita.at(0) < itb.at(0))) {
    sorted-spectra.mz.push(mz)
    sorted-spectra.intensity.push(intensity)
  }

  for ion in get-ms2pip-matching-mass-ion-serie(
    ms2pip-spectra: ms2pip-arr,
    ion-serie: ion-y,
    precision: precision,
  ) {
    ion-y.push(ion)
  }
  for ion in get-ms2pip-matching-mass-ion-serie(
    ms2pip-spectra: ms2pip-arr,
    ion-serie: ion-b,
    precision: precision,
  ) {
    ion-b.push(ion)
  }

  let ion-serie = (
    "y": ion-y,
    "b": ion-b,
  )

  ms2spectra-plot(
    width: width,
    height: height,
    title: title,
    spectra: sorted-spectra,
    ion-series: ion-serie,
    mz-range: mz-range,
    max-intensity: max-intensity,
    delta: none,
    delta-fragments: false,
  )
}
