#import "@preview/cetz:0.1.2"

/// Returns an object representing mass spectrum content.
#let mass-spectrum(
  data,
  args: (:)
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
    size: (auto, 1),
    range: (40, 400),
    style: (:),
    labels: (
      x: [Mass-Charge Ratio],
      y: [Relative Intensity (%)]
    ),
    linestyle: (this, idx)=>{},

// --------------------------------------------
// "Private" member data
// --------------------------------------------
    
    axes: (
      x: none,
      y: none
    ),
    plot-extras: (this)=>{},

// --------------------------------------------
// Methods
// --------------------------------------------
    
    display: (this) => {
      cetz.canvas({
        import cetz.draw: *
        let (x,y) = (this.setup-axes)(this)      
        cetz.draw.group(ctz=>{
          (this.setup-plot)(this, x, y)
          cetz.axes.axis-viewport(this.size, x, y,{
            (this.plot-extras)(this)
            if this.data.len() > 0 {          
              for (i, row) in data.enumerate() {
                let x = float(row.at(this.keys.mz))
                let y = float(row.at(this.keys.intensity))
                (this.display-single-peak)(this, x, x, y)
              }
            }
          })
        })
      })
    },

    display-single-peak: (this, idx, mz, intensity) => {
      if (mz > this.range.at(0) and mz < this.range.at(1) ){
        cetz.draw.line(
          (mz, 0),
          (rel: (0,intensity)),
          ..(this.linestyle)(this, idx)
        )
      }
    },

    setup-plot: (this, x, y) => {
      cetz.axes.scientific(
        size: this.size,
        left: y,
        right: none,
        bottom: x,
        top: none,
        frame: true,
        label: (offset: 0.3),
        tick: (length:-0.1)
      )
    },

    setup-axes: (this) => {
     this.axes.x = cetz.axes.axis(
          min: this.range.at(0), 
          max: this.range.at(1),
          label: this.labels.x,
        )
     this.axes.y = cetz.axes.axis(
          min: 0, 
          max: 110,
          label: this.labels.y,
          ticks: (step: 20, minor-step: none)
        )
      return this.axes
    },

    get-intensity-at-mz: (this, mz) => {
      return float(
        (this.data).filter(
          it=>float(it.at(this.keys.mz, default:0))==mz
        ).at(0).at(this.keys.intensity)
      )
    },

    callout-above: (this, mz, content: none, y-offset: 1.3em) => {
      if ( content == none ) { content = mz}
      return cetz.draw.content(
        anchor: "bottom",
        (mz, (this.get-intensity-at-mz)(this, mz)), box(inset: 0.3em, [#content])
      )
    },

    calipers: ( this,
      start, end, // mass-charge ratios
      height: none,
      content: none,
      stroke: gray + 0.7pt // Style
    ) => {
      if (content == none){ content = [-#calc.abs(start - end)] }

      // Determine height
      let start_height = (this.get-intensity-at-mz)(this, start)
      let end_height = (this.get-intensity-at-mz)(this, end)
      if ( height == none ) { height = calc.max(start_height, end_height) + 5 }

      let draw-arrow(x, y) = cetz.draw.line(
        (x - 0.5, y + 2),(x + 0.5, y + 2),
        stroke: stroke
      )

      // Draw
      return {
        // Start : horizontal arrow
        draw-arrow(start, start_height)
        draw-arrow(end, end_height)
        
        cetz.draw.merge-path({
          cetz.draw.line( (start, start_height + 2), (start, height) )
          cetz.draw.line((start, height), (end, height))
          cetz.draw.line((end, height),(end, end_height + 2))
        }, stroke: stroke)

        // Content
        cetz.draw.content(
          ( (start + end) / 2, height),
          anchor: "bottom",
          box(inset: 0.3em, content)
        )
      }
    },

    title: (this, content, anchor: "top-left", ..args) => {
      return cetz.draw.content(
        anchor: anchor,
        (this.range.at(0), 110),
        box(inset: 0.5em, content),
        ..args
      )
    }

  )

  // Overrides
  for (key, value) in args.pairs() {
    prototype.insert(key, value)
  }

  // Asserts
  assert(type(prototype.keys.mz) in (int, str))
  assert(type(prototype.keys.intensity) in (int, str))

  return prototype
}

#let MolecularIon(charge:none) = [M#super()[#charge+]]