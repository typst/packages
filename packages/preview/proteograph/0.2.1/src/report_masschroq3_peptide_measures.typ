#import "xic_plot.typ": xic-isotope-plot, xic-plot
#import "isotope_pattern.typ": isotope-pattern-plot

#let get-isotope-pattern-data(one_peptide, charge: 1) = {
	let result = (mz: (), intensity: (), th-ratio: (), isotope-number-start: 0, title: "")
	let sorted_xics = one_peptide.xics.sorted(key: it => (it.isotope))
	for xic in sorted_xics {
		if (xic.charge == charge) and (xic.rank == 1) {
			if (result.mz.len() == 0) {
				result.isotope-number-start = xic.isotope
				result.title = "charge: " + str(charge)
			}
			result.mz.push(xic.mz)
			result.th-ratio.push(xic.th_ratio)
			if ("peak" in xic) {
				result.intensity.push(xic.peak.area)
			}
			else {
				result.intensity.push(0)
			}
		}
	}
	(result)
}

#let get-xic-data(one_peptide, type: "trace") = {
	let isotope_list = ()
	for xic in one_peptide.xics {
		let isotope = ()
		if (type == "trace") {
			if ("trace" in xic) {
				isotope = xic.trace
			}
			else if ("peak_shape" in xic) {
				isotope = xic.peak_shape.trace
			}
		}
		else {
			if ("peak_shape" in xic) {
				isotope = xic.peak_shape.trace
			}
		}
		if ("x" in isotope) {
			isotope.insert("title","isotope "+ str(xic.isotope)+ " z=" + str(xic.charge))
			isotope.insert("isotope",xic.isotope)
			isotope.insert("charge",xic.charge)
			if ("peak" in xic) {
				isotope.insert("peak-begin",xic.peak.rt.first())
				isotope.insert("peak-end",xic.peak.rt.last())
			}
			if (xic.rank == 1) {
				isotope_list.push(isotope)
			}
		}
	}
	(isotope_list)
}

#let check-peak-quality(quality) = {
	if (quality.first() == "a") {
		if (quality.contains("b")) {
			text(fill: orange,quality)
		} else {
			text(fill: green,quality)
		}
	}
	else if (quality.first() == "z") {
		if (quality.contains("b")) {
			text(fill: orange,quality)
		} else {
			text(fill: green,quality)
		}
	}
	else {
		text(fill: red,quality)
	}
}

#let write-isotope-summary(one_peptide) = {
	let isotope_list = ()
	set text(size: 10pt)
	for xic in one_peptide.xics {
		if (xic.rank == 1) {
			box(width:11em, baseline: 100%, inset: (x: 0.5em),[
			#heading(level: 2, "isotope " + str(xic.isotope))
				/ mz: #calc.round(xic.mz, digits: 5)
				/ charge: #xic.charge
				/ th ratio: #calc.round(xic.th_ratio, digits: 2)
				/ mz range: #calc.round(xic.xic_coord.mz_range.first(), digits: 3); #sym.dash.em #calc.round(xic.xic_coord.mz_range.last(), digits: 3);
				/ quality: #check-peak-quality(xic.quality)
				#if "tim_im_range" in xic.xic_coord {[/ tims range: #xic.xic_coord.tim_im_range.first(); #sym.dash.em #xic.xic_coord.tim_im_range.last();]}
				#if "peak" in xic {[/ area: #calc.round(xic.peak.area, digits: 0)]}
			])
		}
	}
}

#let mcqjson-report-peptide-measures(mcq-json, peptide-id: none, type: "trace") = {
	if (peptide-id in mcq-json.quantification_data) {
		//choose max_intensity
		let max-intensity = 0
		for peptide_measures in mcq-json.quantification_data.at(peptide-id) {
			for xic in peptide_measures.xics {
				if ("peak" in xic) {
					if (max-intensity < xic.peak.max_intensity) {
						max-intensity = xic.peak.max_intensity
					}
				}
			}
		}
	
		for peptide_measures in mcq-json.quantification_data.at(peptide-id) {
			//choose range
			let rt-apex = ()
			let rt-max = peptide_measures.rt_target
				for xic in peptide_measures.xics {
					if ("peak" in xic) {
						rt-apex.push(xic.peak.rt.at(1))
						if (rt-max < xic.peak.rt.last()) {
							rt-max = xic.peak.rt.last()
						}
					}
				}
			
			let rt-range = auto
			if (rt-apex.len() > 0) {
				rt-apex = rt-apex.sum()/rt-apex.len()
				let rt-min = rt-apex - (rt-max - rt-apex)
				let rt-range = (rt-min, rt-max)
				rt-range.at(0) = rt-range.at(0) + ((1/10) * (rt-range.at(1) - rt-range.at(0)))
			}
			
			
		
		
			heading(level: 1, peptide-id + " in " +peptide_measures.msrun)
			[
			#mcq-json.msrun_list.at(peptide_measures.msrun).file
			
			#peptide_measures.proforma  mods: #peptide_measures.mods

			/ targeted retention time: #peptide_measures.rt_target

			#write-isotope-summary(peptide_measures)
			
			//#get-xic-data(peptide_measures).sorted(key: it => (it.isotope, it.charge))
			]

			xic-plot(height: 10cm,
				title: "XIC "+peptide_measures.proforma,
				rt-range: rt-range,
				max-intensity: max-intensity,
				..get-xic-data(peptide_measures, type: type)
			)
			
			scale(60%,stack(
				dir: ltr,
				for charge in peptide_measures.xics.map((xic) => {xic.charge}).dedup().sorted() {
					let isotope_pattern_data = get-isotope-pattern-data(peptide_measures, charge: charge)
					isotope-pattern-plot(legend: none,height: 3cm, width: 5cm, ..isotope_pattern_data)
				}
			))
			//[#isotope_pattern_data]
			pagebreak()
		}
	}
}


#let mcqjson-report-all-peptide-measures(mcq-json, type: "trace") = {
	for peptide-id in mcq-json.quantification_data.keys() {
		mcqjson-report-peptide-measures(mcq-json, peptide-id: peptide-id, type: type)
	}
}

