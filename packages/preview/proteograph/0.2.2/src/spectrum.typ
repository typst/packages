
/// Filter N most intense peaks in a spectra
/// -> object
#let spectra-filter-nmost-intense(spectra,count) = {
  let spectra-zip = spectra.intensity.zip(spectra.mz).sorted(key: it => (it.at(0))).rev().slice(0,count)
  spectra-zip = spectra-zip.sorted(key: it => (it.at(1)))
  let new-spectra = (mz:(), intensity:())
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
