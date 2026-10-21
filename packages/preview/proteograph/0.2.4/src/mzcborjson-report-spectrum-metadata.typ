
#let find-cv-param(cv-param-list, accession) = {
  cv-param-list.find(cv-param => {
    if (cv-param.accession == accession) {
      true
    } else { false }
  })
}

#let mzcborjson-get-spectrum-ms-level(one-spectrum) = {
  let ms-level-param = find-cv-param(one-spectrum.cvParam, "MS:1000511")
  if (ms-level-param != none) {
    ms-level-param.value
  } else {
    none
  }
}


#let mzcborjson-get-spectrum-title(one-spectrum) = {
  let ms-level-param = find-cv-param(one-spectrum.cvParam, "MS:1000796")
  if (ms-level-param != none) {
    ms-level-param.value
  } else {
    none
  }
}

#let mzcborjson-get-spectrum-scan-start-time-in-seconds(one-spectrum) = {
  let scan-list = one-spectrum.at("scanList", default: none)
  let rt = 0
  if (scan-list != none) {
    let cv-rt = find-cv-param(scan-list.scan.first().cvParam, "MS:1000016")
    rt = cv-rt.value
    if (cv-rt.unitAccession == "UO:0000031") {
      rt = rt * 60
    }
  }
  rt
}
#let mzcborjson-get-precursor-isolation-window(one-precursor) = {
  (
    "cv-target": find-cv-param(one-precursor.isolationWindow.cvParam, "MS:1000827"),
    "cv-target-lower": find-cv-param(one-precursor.isolationWindow.cvParam, "MS:1000828"),
    "cv-target-upper": find-cv-param(one-precursor.isolationWindow.cvParam, "MS:1000829"),
  )
}

#let mzcborjson-report-spectrum-metadata(one-spectrum) = {
  [
    #mzcborjson-get-spectrum-title(one-spectrum)
    / MS level: #mzcborjson-get-spectrum-ms-level(one-spectrum)
    / index: #one-spectrum.index
    / native id: #one-spectrum.id
    / retention time: #calc.round(mzcborjson-get-spectrum-scan-start-time-in-seconds(one-spectrum), digits: 2) seconds (#calc.round(mzcborjson-get-spectrum-scan-start-time-in-seconds(one-spectrum) / 60, digits: 2) minutes)
    #let precursor-list = one-spectrum.at("precursorList", default: none)
    #if (precursor-list != none) {
      for precursor in precursor-list.precursor {
        //print precursor isolation window
        let window = mzcborjson-get-precursor-isolation-window(precursor)
        [
          / precursor: #if ("spectrumRef" in precursor) { precursor.spectrumRef } else { [N.A.] }
          / #window.cv-target.name: #window.cv-target.value #sym.plus.minus #calc.round(window.cv-target-upper.value, digits: 6) [#(calc.round(window.cv-target.value - window.cv-target-lower.value, digits: 4)) - #(calc.round(window.cv-target.value + window.cv-target-upper.value, digits: 4))]
        ]
      }
    }
  ]
}
