#import "@preview/cetz:0.1.2"
#import "util.typ": *
#import "defaults.typ": *

/// Returns an object representing mass spectrum content.
///
/// - data (array): The mass spectrum in the format of a 2D array, or an array of dictionarys.
///         By default, the mass-charges ratios are in the first column, and the relative
///         intensities are in the second column.
/// - args (dictionary): Override default behaviour of the mass spectrum by overriding methods,
///         or setting fields.
/// -> dictionary, none
#let mass-spectrum(
  data,
  args: (:),
) = {

  let prototype = (
    
// --------------------------------------------
// Public member data
// --------------------------------------------

    data: data,
    keys: (
      mz: 0,
      intensity: 1
    ),
    size: (14,5),
    range: (40, 400),
    style: mass-spectrum-default-style,
    labels: (
      x: [Mass-Charge Ratio],
      y: [Relative Intensity (%)]
    ),
    linestyle: (this, idx)=>{},
    plot-extras: (this)=>{},
  )

  // Overrides. This ensures the prototype is properly formed by the time we need it
  prototype = merge-dictionary(prototype,args)
  prototype.style = merge-dictionary(mass-spectrum-default-style,prototype.style)

// --------------------------------------------
// Methods : Utility
// --------------------------------------------

  /// Get the intensity of a mass-peak for a given mass-charge ratio
  //
  // - mz (string, integer, float): Mass-charge ratio for which the intensity is being queried
  // -> float
  prototype.get-intensity-at-mz = (mz) => {
    let intensity_arr = (prototype.data).filter(
        it=>float(it.at(prototype.keys.mz, default:0))==mz
      )
    if ( intensity_arr.len() == 0 ) {return 0}
    return float(
      intensity_arr.at(0).at(prototype.keys.intensity)
    )
  }

// --------------------------------------------
// Methods : Additional Content
// --------------------------------------------

  // Plot-extras function that will place content above a mass peak
  // - mz (string, integer, float): Mass-charge above which to display content
  // - content (content, string, none): Content to show above mass peak. Defaults to given mz
  // - y-offset (length): Distance at which to display content above mass peak
  // -> content
  prototype.callout-above = (mz, content: none, y-offset: 0.3em) => {
    if ( mz <= prototype.range.at(0) or mz >= prototype.range.at(1) ){ return }
    if ( content == none ) { content = mz}
    return cetz.draw.content(
      anchor: "bottom",
      (mz, (prototype.get-intensity-at-mz)(mz)), box(inset: y-offset, [#content]),
      ..prototype.style.callouts
    )
  }

  prototype.callipers = (
    start, end, // mass-charge ratios
    height: none,
    content: none,
  ) => {
    if (content == none){ content = [-#calc.abs(start - end)] }

    // Determine height
    let start_height = (prototype.get-intensity-at-mz)(start)
    let end_height = (prototype.get-intensity-at-mz)(end)
    if ( height == none ) { height = calc.max(start_height, end_height) + 5 }

    let draw-arrow(x, y) = cetz.draw.line(
      (x - 0.5, y + 2),(x + 0.5, y + 2),
      ..prototype.style.callipers.line
    )

    // Draw
    return {
      // Start : horizontal arrow
      draw-arrow(start, start_height)
      draw-arrow(end, end_height)
      
      cetz.draw.merge-path({
        cetz.draw.line((start, start_height + 2), (start, height))
        cetz.draw.line((start, height), (end, height))
        cetz.draw.line((end, height),(end, end_height + 2))
      }, ..prototype.style.callipers.line)

      // Content
      cetz.draw.content(
        ( (start + end) / 2, height),
        anchor: "bottom",
        box(inset: 0.3em, content),
        ..prototype.style.callipers.content
      )
    }
  }

  prototype.title = (content, anchor: "top-left", ..args) => {
    return cetz.draw.content(
      anchor: anchor,
      (prototype.range.at(0), 110),
      box(inset: 0.5em, content),
      ..prototype.style.title,
      ..args
    )
  }

// --------------------------------------------
// Methods : Property Setup, Internal
// --------------------------------------------

  prototype.setup-plot = (ctx, x, y, ..arguments) => {
    cetz.axes.scientific(
      size: prototype.size,
      
      // Axes
      top: none, bottom: x,
      right: none, left: y, // TODO: Optional secondary axis
      ..arguments
    )
  }

  prototype.setup-axes = () => {
    let axes = (:)
    axes.x = cetz.axes.axis(
      min: prototype.range.at(0), 
      max: prototype.range.at(1),
      label: prototype.labels.x,
      //ticks: (step: 10, minor-step: none)
    )
    axes.y = cetz.axes.axis(
      min: 0, 
      max: 110,
      label: prototype.labels.y,
      ticks: (step: 20, minor-step: none)
    )
    return axes
  }


// --------------------------------------------
// Methods : Rendering
// --------------------------------------------

  // ms.display-single-peak handles the rendering of a single mass peak
  prototype.display-single-peak = (idx, mz, intensity, ..arguments) =>{
    if (mz > prototype.range.at(0) and mz < prototype.range.at(1) ){
      cetz.draw.line(
        (mz, 0),
        (rel: (0,intensity)),
        ..arguments, // Global style is overriden by individual style
        ..(prototype.linestyle)(prototype, idx)
      )
    }
  }
  
  /// The ms.display method is responsible for rendering
  prototype.display = () => {

    // Setup canvas
    cetz.canvas({

      import cetz.draw: *
      let (x,y) = (prototype.setup-axes)()    

      // Begin group  
      cetz.draw.group(ctx=>{

        // Style
        let style = merge-dictionary(
          merge-dictionary(mass-spectrum-default-style, cetz.styles.resolve(ctx.style, (:), root: "mass-spectrum")),
          prototype.style
        )

        // Setup scientific axes
        (prototype.setup-plot)(ctx, x, y, ..style.axes)

        cetz.axes.axis-viewport(prototype.size, x, y,{

          // Add in plot extras first
          (prototype.plot-extras)(prototype)

          // Add each individual mass peak
          if prototype.data.len() > 0 {          
            for (i, row) in data.enumerate() {
              let x = float(row.at(prototype.keys.mz))
              let y = float(row.at(prototype.keys.intensity))
              (prototype.display-single-peak)(x, x, y, ..style.peaks)
            }
          }
        })
      })
    })
  }

  // Asserts
  assert(type(prototype.keys.mz) in (int, str))
  assert(type(prototype.keys.intensity) in (int, str))

  return prototype
}

#let MolecularIon(charge:none) = [M#super()[#charge+]]