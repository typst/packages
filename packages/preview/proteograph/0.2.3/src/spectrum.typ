
/// Filter N most intense peaks in a spectra
/// -> object
#let spectra-filter-nmost-intense(spectra, count) = {
  let spectra-zip = spectra.intensity.zip(spectra.mz).sorted(key: it => (it.at(0))).rev().slice(0, count)
  spectra-zip = spectra-zip.sorted(key: it => (it.at(1)))
  let new-spectra = (mz: (), intensity: ())
  new-spectra.mz = spectra-zip.map(((intensity, mz)) => {
    mz
  })
  new-spectra.intensity = spectra-zip.map(((intensity, mz)) => {
    intensity
  })
  (new-spectra)
}


/// Filter N most intense peaks in a spectra
/// -> object
#let spectra-filter-normalize-intensity(spectra, max-intensity) = {
  let exp-max = calc.max(..spectra.intensity)
  let new-int = spectra.intensity.map(((intensity)) => {
    ((intensity / exp-max) * max-intensity)
  })

  spectra.intensity = new-int
  (spectra)
}


/// Filter to keep only m/z higher than threshold
/// -> object
#let spectra-filter-high-pass(spectra, mz-cutoff) = {
  let spectra-zip = spectra.intensity.zip(spectra.mz)
  let new-spectra = (mz: (), intensity: ())

  for (intensity, mz) in spectra-zip {
    if (mz > mz-cutoff) {
      new-spectra.intensity.push(intensity)
      new-spectra.mz.push(mz)
    }
  }
  (new-spectra)
}

/// Filter to keep only m/z lower than threshold
/// -> object
#let spectra-filter-low-pass(spectra, mz-cutoff) = {
  let spectra-zip = spectra.intensity.zip(spectra.mz)
  let new-spectra = (mz: (), intensity: ())

  for (intensity, mz) in spectra-zip {
    if (mz < mz-cutoff) {
      new-spectra.intensity.push(intensity)
      new-spectra.mz.push(mz)
    }
  }
  (new-spectra)
}
