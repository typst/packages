#import "proforma.typ": (
  compute-hyperscore, get-mass-from-proforma, get-ms2spectra-plot-from-proforma, get-mz-from-proforma,
  get-sequence-from-proforma, mass-hplus,
)
#import "protein_diag.typ": protein-diag

#let psm-cbor-compute-precursor-mass(precursor) = {
  // m + (hplus*charge) / z = x
  // m + (hplus*charge) = x * z
  // m  = x * z - (hplus*charge)
  (precursor.mz * precursor.z) - (mass-hplus * precursor.z)
}

#let psm-cbor-print-scan(
  scan,
) = [index=#scan.id.index mh=#calc.round(psm-cbor-compute-precursor-mass(scan.precursor) + mass-hplus, digits: 4) mz=#calc.round(scan.precursor.mz, digits: 4) charge=#scan.precursor.z rt=#calc.round(scan.ms2.rt, digits: 2)s]

#let psm-cbor-write-eval-summary-spoms(psm, offset: 0) = {
  //set text(size: 10pt)
  box(width: 100%, inset: (x: 0.5em), [
    #heading(offset: offset, level: auto, depth: 3, outlined: false, "Spoms ")
    / bracket: #psm.eval.spoms.first.bracket
    / nam: #psm.eval.spoms.first.nam
    / score: #psm.eval.spoms.first.score
    #if ("post" in psm.eval.spoms) {
      [
        #heading(offset: offset, level: auto, depth: 3, outlined: false, "Spoms post")
        / bracket: #psm.eval.spoms.post.bracket
        / nam: #psm.eval.spoms.post.nam
        / score: #psm.eval.spoms.post.score
      ]
    }
  ])
}

#let psm-cbor-write-eval-summary-sage(psm, offset: 0) = {
  //set text(size: 10pt)
  //
  // "aligned_rt": 0.7752373,
  // "calcmass": 2201.9875,
  // "delta_best": 0,
  // "delta_mobility": 0,
  // "delta_next": 58.199557899917075,
  // "delta_rt_model": 0.021523058,
  // "fragment_ppm": 1.9985664,
  // "hyperscore": 58.199557899917075,
  // "ion_mobility": 0,
  // "isotope_error": 0,
  // "label": 1,
  // "longest_b": 1,
  // "longest_y": 14,
  // "longest_y_pct": 0.7368421,
  // "matched_intensity_pct": 39.108612,
  // "matched_peaks": 18,
  // "missed_cleavages": 0,
  // "ms2_intensity": 2451400.5,
  // "peptide_len": 19,
  // "peptide_q": 0.00013915387,
  // "poisson": -15.369707276005169,
  // "posterior_error": -77.74201,
  // "precursor_ppm": 1.4413459,
  // "predicted_mobility": 0,
  // "predicted_rt": 0.75371426,
  // "protein_q": 0.0002800128,
  // "rank": 1,
  // "sage_discriminant_score": 1.3159876,
  // "scored_candidates": 570,
  // "semi_enzymatic": 0,
  // "spectrum_q": 0.000011286809
  box(width: 100%, inset: (x: 0.5em), [
    #heading(offset: offset, level: auto, depth: 3, outlined: false, "Sage ")
    / peptide_q: #psm.eval.sage.peptide_q
    / spectrum_q: #psm.eval.sage.spectrum_q
    / rank: #psm.eval.sage.rank
    / hyperscore: #calc.round(psm.eval.sage.hyperscore, digits: 4)
  ])
}

#let psm-cbor-write-eval-summary(psm, offset: 0) = {
  //set text(size: 10pt)
  if "eval" in psm {
    for engine in psm.eval.keys() {
      if "spoms" == engine {
        psm-cbor-write-eval-summary-spoms(psm, offset: offset)
      } else if "sage" == engine { psm-cbor-write-eval-summary-sage(psm, offset: offset) } else {}
    }
  }
}

#let psm-cbor-display-psm-protein-region(psm, protein-dict) = {
  let tint(c) = (stroke: c, fill: rgb(..c.components().slice(0, 3), 5%), inset: 1pt)
  let pep_len = get-sequence-from-proforma(psm.proforma).len()
  // "protein_list": [
  //   { "accession": "GRMZM2G152908_P01", "positions": [493] },
  //   { "accession": "GRMZM2G152908_P02", "positions": [62] },
  //   { "accession": "GRMZM2G152908_P03", "positions": [493] },
  //   { "accession": "GRMZM2G152908_P04", "positions": [493] }
  // ],
  for prot-ref in psm.protein_list {
    if prot-ref.accession in protein-dict {
      let protein = protein-dict.at(prot-ref.accession)
      [#set par(leading: 0.5em, spacing: 0.5em)
        #prot-ref.accession
        #for position in prot-ref.positions {
          let middle = position + int(pep_len / 2)
          let start = middle - 30
          if (start < 0) { start = 0 }
          let end = start + 60
          if (end >= protein.sequence.len()) {
            end = protein.sequence.len() - 1
          }
          stack(
            dir: ltr,
            align(horizon)[ +#start#h(2%)],
            protein-diag(
              line-length: 60,
              protein.sequence.slice(start, end),
              (pos: ((position + 1) - start, (position + pep_len) - start), style: tint(red)),
            ),
            align(horizon)[#h(2%)+#{ protein.sequence.len() - end - 1 } ],
          )
        }]
    }
  }
}

#let psm-cbor-scan-psm-report(scan, psm, offset: 0, protein-dict: none) = {
  [#heading(offset: offset, level: auto, depth: 1, outlined: false, bookmarked: false, psm.proforma)]

  if (protein-dict != none) {
    psm-cbor-display-psm-protein-region(psm, protein-dict)
  }
  if ("ms2" in scan) {
    [
      #if "spectrum" in scan.ms2 {
        get-ms2spectra-plot-from-proforma(
          width: 14cm,
          height: 5cm,
          proforma: psm.proforma,
          spectra: scan.ms2.spectrum,
          precision: 0.02,
          charge-max: scan.precursor.z,
        )
      }
      #columns(2, gutter: 1cm)[
        #box(width: 100%, inset: (x: 0.5em), [
          #if "spectrum" in scan.ms2 [
            / hyperscore: #calc.round(
                compute-hyperscore(
                  proforma: psm.proforma,
                  spectra: scan.ms2.spectrum,
                  precision: 0.02,
                  charge-max: scan.precursor.z,
                ),
                digits: 2,
              )
          ]
          / peptide length: #get-sequence-from-proforma(psm.proforma).len()
          / peptide mh: #calc.round(
              get-mass-from-proforma(psm.proforma) + mass-hplus,
              digits: 5,
            )
          / charge: #scan.precursor.z
          / #sym.Delta mz: #calc.round(
              scan.precursor.mz - get-mz-from-proforma(psm.proforma, scan.precursor.z),
              digits: 5,
            )
          / #sym.Delta mh: #calc.round(
              psm-cbor-compute-precursor-mass(scan.precursor) - get-mass-from-proforma(psm.proforma),
              digits: 5,
            )
        ])
        #colbreak()
        #psm-cbor-write-eval-summary(offset: offset + 1, psm)
      ]
    ]
  } else {
    [
      #box(width: 100%, baseline: 100%, inset: (x: 0.5em), [
        #psm-cbor-write-eval-summary(offset: offset + 1, psm)
      ])
    ]
  }
}

#let psm-cbor-scan-report(scan, protein-dict: none, offset: 0) = {
  [


    #heading([#set text(hyphenate: true)
      #scan.sample.name])
    #heading(
      offset: offset,
      level: auto,
      depth: 1,
      outlined: false,
      bookmarked: false,
      [Scan #psm-cbor-print-scan(scan)],
    )

    // "id": {
    //   "index": 0,
    //   "native_id": "index=0"
    // },
    // "precursor": {
    //   "intensity": 3291653,
    //   "mh": 1124.582737105304,
    //   "mz": 563.298645019531,
    //   "z": 2
    // },

    #for psm in scan.psm_list {
      psm-cbor-scan-psm-report(scan, psm, offset: offset + 1, protein-dict: protein-dict)
    }
  ]
}
