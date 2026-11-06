//==============================================================================
// L-system generator arguments library
//
// Public functions:
//     lsystem-names, lsystem-use
//==============================================================================


//----------------------------------------------------------
// Private functions
//----------------------------------------------------------

// Preset arguments set
#let _lsystem-set = (
  "Dragon Curve": (
    draw-forward-sym: "F",
    move-forward-sym: "",
    axiom: "FX",
    rule-set: ("X": "X+YF+", "Y": "-FX-Y"),
    angle: 1/2,
    cycle: false
  ),

  "Hilbert Curve": (
    draw-forward-sym: "F",
    move-forward-sym: "",
    axiom: "W",
    rule-set: ("V": "-WF+VFV+FW-", "W": "+VF-WFW-FV+"),
    angle: 1/2,
    cycle: false
  ),

  "Peano Curve": (
    draw-forward-sym: "F",
    move-forward-sym: "",
    axiom: "X",
    rule-set: ("X": "XFYFX+F+YFXFY-F-XFYFX", "Y": "YFXFY-F-XFYFX+F+YFXFY"),
    angle: 1/2,
    cycle: false
  ),

  "Rounded Peano Curve": (
    draw-forward-sym: "F",
    move-forward-sym: "",
    axiom: "+FA",
    rule-set: ("A": "A-F-FA+F+FA+F+FA+F+FA-F-FA-F-FA-F-FA+F+FA", "B": "+A-BB--B-A++A+B"),
    angle: 1/4,
    cycle: false
  ),

  "Smoother Peano Curve": (
    draw-forward-sym: "F",
    move-forward-sym: "",
    axiom: "++FA",
    rule-set: ("A": "A-BA+CA+CA+CA-BA-BA-BA+CA", "B": "F-F-F-F", "C": "F+F+F+F"),
    angle: 1/8,
    cycle: false
  ),

  "Koch Curve": (
    draw-forward-sym: "F",
    move-forward-sym: "",
    axiom: "F",
    rule-set: ("F": "F-F++F-F"),
    angle: 1/3,
    cycle: false
  ),

  "Koch Snowflake": (
    draw-forward-sym: "F",
    move-forward-sym: "",
    axiom: "F++F++F",
    rule-set: ("F": "F-F++F-F"),
    angle: 1/3,
    cycle: true
  ),

  "Sierpinski Curve": (
    draw-forward-sym: "F",
    move-forward-sym: "",
    axiom: "F--XF--F--XF",
    rule-set: ("X": "XF+G+XF--F--XF+G+X"),
    angle: 1/4,
    cycle: true
  ),

  "Sierpinski Square Curve": (
    draw-forward-sym: "F",
    move-forward-sym: "",
    axiom: "F+XF+F+XF",
    rule-set: ("X": "XF-F+F-XF+F+XF-F+F-X"),
    angle: 1/2,
    cycle: true
  ),

  "Sierpinski Arrowhead Curve": (
    draw-forward-sym: "F",
    move-forward-sym: "",
    axiom: "XF",
    rule-set: ("X": "YF+XF+Y", "Y": "XF-YF-X"),
    angle: 1/3,
    cycle: false
  ),

  "Sierpinski Triangle": (
    draw-forward-sym: "FG",
    move-forward-sym: "",
    axiom: "F-G-G",
    rule-set: ("F": "F-G+F+G-F", "G": "GG"),
    angle: 2/3,
    cycle: true
  ),

  "Sierpinski Hexagon": (
    draw-forward-sym: "X",
    move-forward-sym: "Y",
    axiom: "X",
    rule-set: ("X": "X+X+X+X+X+X+YYY", "Y": "YYY"),
    angle: 1/3,
    cycle: true
  ),

  "Fern 1": (
    draw-forward-sym: "F",
    move-forward-sym: "",
    axiom: "X",
    rule-set: ("X": "F+[[X]-X]-F[-FX]+X", "F": "FF"),
    angle: 5/36,
    cycle: false
  ),

  "Fern 2": (
    draw-forward-sym: "F",
    move-forward-sym: "",
    axiom: "Y",
    rule-set: ("X": "X[-FFF][+FFF]FX", "Y": "YFX[+Y][-Y]"),
    angle: 13/90,
    cycle: false
  ),

  "Fern 3": (
    draw-forward-sym: "F",
    move-forward-sym: "",
    axiom: "F",
    rule-set: ("F": "F[+FF][-FF]F[-F][+F]F"),
    angle: 1/8,
    cycle: false
  ),

  "Fern 4": (
    draw-forward-sym: "F",
    move-forward-sym: "",
    axiom: "X",
    rule-set: ("X": "F[+X]F[-X]+X", "F": "FF"),
    angle: 1/9,
    cycle: false
  ),

  "Cantor Set": (
    draw-forward-sym: "F",
    move-forward-sym: "f",
    axiom: "F",
    rule-set: ("F": "FfF", "f": "fff"),
    angle: 1/2,
    cycle: false
  ),

  "Moore Curve": (
    draw-forward-sym: "F",
    move-forward-sym: "",
    axiom: "LFL+F+LFL",
    rule-set: ("L": "-RF+LFL+FR-", "R": "+LF-RFR-FL+"),
    angle: 1/2,
    cycle: false
  ),

  "Gosper Curve": (
    draw-forward-sym: "AB",
    move-forward-sym: "",
    axiom: "A",
    rule-set: ("A": "A-B--B+A++AA+B-", "B": "+A-BB--B-A++A+B"),
    angle: 1/3,
    cycle: false
  ),

  "Rectangle Island Curve": (
    draw-forward-sym: "F",
    move-forward-sym: "b",
    axiom: "F-F-F-F",
    rule-set: ("F": "F-b+FF-F-FF-Fb-FF+b-FF+F+FF+Fb+FFF", "b": "bbbbbb"),
    angle: 1/2,
    cycle: false
  ),

  "Pentaplexity": (
    draw-forward-sym: "F",
    move-forward-sym: "",
    axiom: "F++F++F++F++F",
    rule-set: ("F": "F++F++F|F-F++F"),
    angle: 1/5,
    cycle: true
  ),

  "McWorter Dendrite Fractal": (
    draw-forward-sym: "F",
    move-forward-sym: "",
    axiom: "F-F-F-F-F",
    rule-set: ("F": "F-F-F++F+F-F"),
    angle: 2/5,
    cycle: true
  ),

  "Rings": (
    draw-forward-sym: "F",
    move-forward-sym: "",
    axiom: "F+F+F+F",
    rule-set: ("F": "FF+F+F+F+F+F-F"),
    angle: 1/2,
    cycle: true
  ),

  "Levy Curve": (
    draw-forward-sym: "F",
    move-forward-sym: "",
    axiom: "F",
    rule-set: ("F": "-F++F-"),
    angle: 1/4,
    cycle: false
  ),

  "Board": (
    draw-forward-sym: "F",
    move-forward-sym: "",
    axiom: "F+F+F+F",
    rule-set: ("F": "FF+F+F+F+FF"),
    angle: 1/2,
    cycle: true
  ),

  "Quadratic Snowflake": (
    draw-forward-sym: "F",
    move-forward-sym: "",
    axiom: "FF+FF+FF+FF",
    rule-set: ("F": "F+F-F-F+F"),
    angle: 1/2,
    cycle: true
  ),

  "Crystal": (
    draw-forward-sym: "F",
    move-forward-sym: "",
    axiom: "F+F+F+F",
    rule-set: ("F": "FF+F++F+F"),
    angle: 1/2,
    cycle: true
  ),

  "Cesero fractal": (
    draw-forward-sym: "F",
    move-forward-sym: "",
    axiom: "F++++F++++F++++F",
    rule-set: ("F": "F+++F------F+++F"),
    angle: 1/8,
    cycle: true
  ),

  "Penrose Tiling": (
    draw-forward-sym: "1",
    move-forward-sym: "",
    axiom: "[7]++[7]++[7]++[7]++[7]",
    rule-set: ("6": "81++91----71[-81----61]++", "7": "+81--91[---61--71]+", "8": "-61++71[+++81++91]-", "9": "--81++++61[+91++++71]--71", "1": ""),
    angle: 1/5,
    cycle: false
  ),

  "Mango Leaf": (
    draw-forward-sym: "F",
    move-forward-sym: "f",
    axiom: "Y---Y",
    rule-set: ("X": "{F-F}{F-F}--[--X]{F-F}{F-F}--{F-F}{F-F}--", "Y": "f-F+X+F-fY"),
    angle: 1/3,
    cycle: true
  ),

  "Snake Kolam": (
    draw-forward-sym: "F",
    move-forward-sym: "",
    axiom: "F+XF+F+XF",
    rule-set: ("X": "X{F-F-F}+XF+F+X{F-F-F}+X"),
    angle: 1/2,
    cycle: true
  ),

  "Kolam": (
    draw-forward-sym: "F",
    move-forward-sym: "",
    axiom: "(-D--D)",
    rule-set: ("A": "F++FFFF--F--FFFF++F++FFFF--F", "B": "F--FFFF++F++FFFF--F--FFFF++F", "C": "BFA--BFA", "D": "CFC--CFC"),
    angle: 1/4,
    cycle: true
  ),

  "Cross": (
    draw-forward-sym: "F",
    move-forward-sym: "",
    axiom: "F+F+F+F",
    rule-set: ("F": "F+F-F+F+F"),
    angle: 1/2,
    cycle: true
  ),
)


//----------------------------------------------------------
// Public functions
//----------------------------------------------------------

// Get all names in L-system generator library
#let lsystem-names = _lsystem-set.keys()


// Get arguments in L-system generator library by name
#let lsystem-use(name) = _lsystem-set.at(name)
