#import "@preview/lilaq:0.4.0" as lq
#import "@preview/tiptoe:0.3.0"
#import "ion_series.typ": *



#let ms2spectra-delta-diagram = it => {
  show: lq.set-diagram(
    xlabel: [$m/z$],
    ylabel: [Mass delta (ppm)],
    legend: none,
    grid: none,
    xaxis: (mirror: none),
    yaxis: (mirror: none),
  )
  it
}

#let ms2spectra-diagram = it => {
  show: lq.set-diagram(
    xlabel: [$m/z$],
    ylabel: [Intensity],
    legend: none,
    grid: none,
    xaxis: (mirror: none),
    yaxis: (mirror: none),
  )
  it
}

#let ms2spectra-simple-plot(spectra) = {
    lq.stem(spectra.mz, spectra.intensity,
        color: black,
        base-stroke : none,
        mark: none)
}

#let ms2spectra-ion-plot(type, ion_arr) = {

        let mz_arr = ()
        let int_arr = ()
        for one_ion in ion_arr {
            mz_arr.push(one_ion.mz)
            int_arr.push(one_ion.intensity)
        }
        (
        lq.stem(mz_arr, int_arr, stroke: 1.1pt, base-stroke : none, color: ion-colors.at(type), mark:none, label: [#type])
        ,
        ion_arr.map((one_ion) => {
          let display = true
          if(("isotope" in one_ion)) {
             if (one_ion.isotope != 0) {
                display = false
             }
          }
          if(display) {
            let align = bottom
            lq.place(clip: true, one_ion.mz, one_ion.intensity, pad(bottom: 0.3em, left: 20%)[#text(ion-colors.at(type), size: 8pt)[#psm-ionlabel(type,one_ion.size, one_ion.charge)]], align: align)
            }
        })
        )
}


#let ms2spectra-delta-plot(delta_arr) = {
        delta_arr.map((delta) => {
          let level = 1em * delta.level + 1em
          (
          lq.line(
              tip: tiptoe.bar,
              toe: tiptoe.bar,
              stroke: (paint: ion-colors.at(delta.ion)),
              (delta.mz.at(0), level), (delta.mz.at(1), level)),
          lq.place(clip: true, (delta.mz.at(1)+delta.mz.at(0))/2, level,
              pad(bottom: 0.8em)[#text(ion-colors.at(delta.ion), size: 8pt)[#delta.label]]
          )
          )
        })
}



#let xic-plot(
  title: none,
  rt_range: auto,
  max_intensity: none,
  ..xic_json_list
) = {
    let ylimit = auto;
    if (max_intensity != none) {ylimit = (0, max_intensity)}

    lq.diagram(
    title: title,
    xlabel: [Retention time (s)],
    ylabel: [Intensity],
    ylim: ylimit,
    xlim: rt_range,


    ..xic_json_list.pos().map((one_xic) => {
        let label = none
        if ("title" in one_xic) {label = one_xic.title}
        lq.plot(one_xic.x, one_xic.y, label: label)
    })
    )
}

#let ms2spectra-ion-delta-plot(type, ion_arr) = {
  let one_million = 1000000

        let mz_arr = ()
        let mz_delta_arr = ()
        for one_ion in ion_arr {
            mz_arr.push(one_ion.mz)
            mz_delta_arr.push((one_ion.mz - one_ion.mzth) / (one_ion.mz / one_million))
        }
        lq.scatter(mz_arr, mz_delta_arr, color: ion-colors.at(type))
}


/// Generates an annotated MS2 spectra plot.
/// -> content
#let ms2spectra-plot(

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
  
  /// Shows the plot title. *Optional*.
  /// -> str | content
  title: none,


  /// m/z range to display. *Optional*.
  /// #parbreak() Example: ```js (450, 950)```
  /// -> none | array
  mz_range: none,

  /// maximum intensity to display. *Optional*.
  /// #parbreak() Example: ```js 30000```
  /// -> none | float
  max_intensity: none,


  /// Mass spectra values. *Optional*.
  /// a dictionary with the keys `mz` (array of mass to charge ratios) and `intensity` (array of intensities)
  /// with the same length for each array
  /// #parbreak() (e.g., `spectra: (mz: (256.45, 356.89, 523.78), intensity: (200, 298 ,253))`)
  /// ```example
  /// #import "@local/proteograph:0.1.0": *
  /// #set text(size: 12pt)
  /// #ms2spectra-plot( spectra: (mz: (256.45, 356.89, 523.78), intensity: (200, 298, 253)))
  /// ```
  /// -> none | dictionary
  spectra: none,

  ion-series: none,
  delta: none,


  /// Whether to clip the matched ion masss delta to the plot. *Optional*.
  /// -> bool
  delta-fragments: false
) = {
    let ylimit = auto;
    if (max_intensity != none) {ylimit = (0, max_intensity)}
    let mzpc = (spectra.mz.last() - spectra.mz.first()) / 100
    let inside_xlim = (spectra.mz.first()- 2*mzpc, spectra.mz.last()+ 2*mzpc)
    if (mz_range != none) {inside_xlim = mz_range}
    let ms2-height = height
    if (delta-fragments) {ms2-height = height - 1.5cm}

    show: ms2spectra-diagram

    
    lq.diagram(
    width: width,
    height: ms2-height,
    title: title,
    xlim: inside_xlim,
    ylim: ylimit,

    if((spectra != none)) {ms2spectra-simple-plot(spectra)},

    ..if((ion-series != none)) {ion-series.pairs().map(((type, ion_arr)) => {
        ms2spectra-ion-plot(type, ion_arr)
        }).flatten()},

    ..if((delta != none)) {ms2spectra-delta-plot(delta).flatten()}
    )

    if(delta-fragments) {
          lq.diagram(
            width: width,
            height: 1.5cm,
            margin: 0%,
            ylabel: [#sym.Delta ppm],
            ylim: (-10, 10),
            xlim: inside_xlim,
            xaxis: none,

          ..if((ion-series != none)) {ion-series.pairs().map(((type, ion_arr)) => {
              ms2spectra-ion-delta-plot(type, ion_arr)
              }).flatten()},

          lq.line(stroke: (paint: blue, dash: "dashed"),(0, 0), ( 100%,0))
        )
      }
    
}

