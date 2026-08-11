#import "proforma.typ": get-ms2spectra-plot-from-proforma, compute-hyperscore

#let print-scan(scan) = [index=#scan.id.index mh=#calc.round(scan.precursor.mh, digits: 4) mz=#calc.round(scan.precursor.mz, digits: 4) charge=#scan.precursor.z rt=#calc.round(scan.ms2.rt, digits: 2)s]

#let write-eval-summary-spoms(psm, offset: 0) = {
	//set text(size: 10pt)
			box(width:100%, baseline: 100%, inset: (x: 0.5em),[
			#heading(offset: offset, level: auto, depth: 3, outlined: false, "Spoms ")
				/ bracket: #psm.eval.spoms.first.bracket
				/ nam: #psm.eval.spoms.first.nam
				/ score: #psm.eval.spoms.first.score
				#if ("post" in psm.eval.spoms) {[
				#heading(offset: offset, level: auto, depth: 3, outlined: false, "Spoms post")
				/ bracket: #psm.eval.spoms.post.bracket
				/ nam: #psm.eval.spoms.post.nam
				/ score: #psm.eval.spoms.post.score
				]}
			])
}


#let write-eval-summary(psm, offset: 0) = {
	//set text(size: 10pt)
	if "eval" in psm {
	  if "spoms" in psm.eval {
			write-eval-summary-spoms(psm, offset: offset)
		}
  }
}

#let psm-cbor-scan-psm-report(scan, psm, offset: 0) = {
  [#heading(offset: offset, level: auto, depth: 1, outlined: false, bookmarked: false, psm.proforma)]
  if "ms2" in scan {[
    #columns(2, gutter: 1cm)[
      #get-ms2spectra-plot-from-proforma(width: 7cm, height: 5cm, proforma: psm.proforma, spectra: scan.ms2.spectrum, precision: 0.02, charge-max: scan.precursor.z)
      #colbreak()
      / hyperscore: #calc.round(compute-hyperscore(proforma: psm.proforma, spectra: scan.ms2.spectrum, precision: 0.02, charge-max: scan.precursor.z),digits: 2)
      #box(width:100%, baseline: 100%, inset: (x: 0.5em),[
        #write-eval-summary(offset: offset+1,psm)
      ])
    ]
  ]}
  else {[
    #box(width:100%, baseline: 100%, inset: (x: 0.5em),[
      #write-eval-summary(offset: offset+1,psm)
    ])
  ]}
}

#let psm-cbor-scan-report(scan, offset: 0) = {
[

  #heading(offset: offset, level: auto, depth: 1, outlined: false, bookmarked: false, [Scan #print-scan(scan)])

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
    psm-cbor-scan-psm-report(scan, psm, offset: offset+1)
  }
]
}
