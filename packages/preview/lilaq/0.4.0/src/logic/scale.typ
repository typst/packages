/// Scales that can be applied to the displayed data. By default, the 
/// data is scaled linearly but other scales like `lq.scale.log` and 
/// `lq.scale.symlog` are available and completely custom scales can
/// be created with the general `scale` function.  


#import "../math.typ": sign
#import "../algorithm/ticking.typ"

/// Constructor for the scale type. Scales are used to transform data coordinates 
/// into scaled coordinates. Commonly, data is displayed with a linear scale, i.e., 
/// the entire data is just scaled uniformly. However, in order to visualize large 
/// ranges, it is often desirable to use logarithmic scaling or other scales that 
/// improve the readability of the data. 
#let scale(

  /// Transformation from data coordinates to scaled coordinates.  
  /// Note that the transformation function does not need to worry about 
  /// absolute scaling and offsets. As an example, the transformation function 
  /// for the linear scale is just `x => x` and not something like 
  /// `x => a * x + b`. The logarithmic scale uses `x => calc.log(x)`. 
  /// -> function
  transform,

  /// A precise inverse of the `transform` in order to enable the conversion of
  /// scaled coordinates back to data coordinates. 
  /// -> function
  inverse,
  
  /// Name of the scale. Built-in scales are sometimes identified by their name, 
  /// e.g., when a suitable tick locator needs to be selected automatically. 
  /// -> str
  name: "",

  /// An identity value which can be used to find an initial axis range when 
  /// no limits or plots are given. Scales like logarithmic scales that are 
  /// only defined for positive values should set this to 1. 
  /// -> int | float
  identity: 0, 

  /// The default tick locator to use with this scale. 
  /// -> none | function
  locate-ticks: none,

  /// The default subtick locator to use with this scale. 
  /// -> none | function
  locate-subticks: none,

  /// Additional data to store in the scale. 
  /// -> any
  ..args
  
) = (
  transform: transform,
  inverse: inverse,
  name: name,
  identity: identity,
  locate-ticks: locate-ticks,
  locate-subticks: locate-subticks,
  ..args.named()
)


/// Creates a new linear scale. This scale can also be accessed through 
/// the shorthand `"linear"`. 
#let linear() = scale(
  name: "linear",
  x => x,
  x => x,
  locate-ticks: ticking.locate-ticks-linear,
  locate-subticks: ticking.locate-subticks-linear,
)


/// Creates a new logarithmic scale. This scale can also be accessed through 
/// the shorthand `"log"`. 
#let log(
  
  /// The base of the logarithm. This info is only used to determine
  /// the base for ticks. 
  /// -> float
  base: 10
  
) = scale(
  name: "log",
  x => calc.log(x),
  x => calc.pow(10., x),
  base: base,
  identity: 1,
  locate-ticks: ticking.locate-ticks-log.with(base: base),
  locate-subticks: ticking.locate-subticks-log.with(base: base),
)


/// Creates a new symlog scale with a linear scaling in the region 
/// `[threshold, threshold]` around 0 and a logarithmic scaling beyond that. 
/// This scale can also be accessed through the shorthand `"symlog"`. 
#let symlog(
  
  /// The base of the logarithm. 
  /// -> float
  base: 10, 

  /// The threshold for the linear region. 
  /// -> float
  threshold: 1, 

  /// The scaling of the linear region. 
  /// -> float
  linscale: 1
  
) = {
  let c = linscale / (1. - 1. / base)

  import "symlog.typ": symlog-transform
  let transform = symlog-transform(base, threshold, linscale)
  
  let inv-threshold = transform(threshold)
  scale(
    name: "symlog",
    transform,
    x => {
      if x == 0 { return 0. }
      let abs = calc.abs(x)
      if abs <= inv-threshold { return x / c }
      return sign(x) * threshold * calc.pow(base, abs / threshold - c)
    },
    
    threshold: threshold,
    base: base,
    linscale: linscale,
    locate-ticks: ticking.locate-ticks-symlog.with(
      base: base, 
      threshold: threshold, 
      linscale: linscale
    ),
    locate-subticks: ticking.locate-subticks-symlog.with(
      base: base, 
      threshold: threshold
    )
  )
}

#let check-sym(x) = {
  let sym = symlog()
  assert((sym.inverse)((sym.transform)(x)) - x < 1e-15)
}
#check-sym(0)
#check-sym(1)
#check-sym(1.5)
#check-sym(2)
#check-sym(3)




#let scales = (
  linear: linear(),
  log: log(base: 10),
  symlog: symlog(base: 10),
)

