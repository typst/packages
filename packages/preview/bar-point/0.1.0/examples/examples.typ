#set page(width: auto, height: auto, margin: 1cm)
#import "/src/lib.typ": backgammon-board
#import "positions.typ":*

== position 1 layout
// default layout
#backgammon-board(opening-layout)
#backgammon-board(opening-layout, theme: "woodland-brown")
#backgammon-board(opening-layout, theme: "woodland-brown", swap-colours: true, show-bg: true, clockwise: true, show-home-markers: false)


// grayscale example with all parameters
#backgammon-board(
  position-1-layout, 
  
  // core game configuration and movement rules
  turn: "light", 
  bar: (1, 2), 
  dice: (1, 1), 
  cube: (value: 64, owner: none), 
  borne-off: (8, 3),
  clockwise: false, 
  swap-colours: false, 
  ace-point: "dark",
  moves: ((0,6),(0,7),(0,12)),

  // visibility toggles
  show-bg: false, 
  show-border: true, 
  show-pips: true,
  show-labels: true, 
  show-dice: true, 
  show-cube: true, 
  show-home-markers: true,
  show-tray-borders: false, 
  
  // theme and visual appearance
  //theme: "print-grayscale", 
  font: none, 
  adjust-theme: (:),
  rounded: true, 
  scale: 1.0, 
  label-size: 9pt,
  marker-thickness: 2.5pt,
  tray-checker-size: 1.0, 
  arrow-mark: "circle",
) 

// construct a 2x2 grid matrix container block with a comfortable separation pitch
#grid(
  columns: 2,
  gutter: .5cm,
  
  // --------------------------------------------------------------------------
  // board 1
  // --------------------------------------------------------------------------
  backgammon-board(
    position-1-layout,
    theme: "default-green",
    scale: 0.65,
    turn: "dark",
    dice: (3, 1),
    show-home-markers: true,
    borne-off: (4,9),
    tray-checker-size: 0.8,
    moves: ((5,2),(1,0)),
    ace-point: "dark"
  ),

  // --------------------------------------------------------------------------
  // board 2
  // --------------------------------------------------------------------------
  backgammon-board(
    position-1-layout,
    theme: "tournament-blue",
    show-bg: true,
    scale: 0.65,
    turn: "dark",
    dice: (6, 4),
    cube: (value: 2, owner: "dark"),
    show-home-markers: true,
    clockwise: true,
    ace-point: "dark"

  ),

  // --------------------------------------------------------------------------
  // board 3
  // --------------------------------------------------------------------------
  backgammon-board(
    position-1-layout,
    theme: "woodland-brown",
    scale: 0.65,
    swap-colours: true,
    show-home-markers: false,
    show-bg: true,
    ace-point: "dark"
  ),

  // --------------------------------------------------------------------------
  // board 4
  // --------------------------------------------------------------------------
  backgammon-board(
    position-1-layout,
    theme: "print-grayscale",
    scale: 0.65,
    show-home-markers: false,
    show-pips: true,
    ace-point: "dark",
    bar: (5,2),
    ),    
  )


