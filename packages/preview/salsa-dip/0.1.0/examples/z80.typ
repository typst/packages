#import "@preview/salsa-dip:0.1.0": dip-chip-label

#set text(font: ("JetBrains Mono", "Fira Code", "DejaVu Sans Mono"), weight: "extrabold")
#set page(width: auto, height: auto, margin: .125cm)

/// Settings Values:
/// chip-label-size: Font size for the chip label
/// pin-number-margin: Margin to give next to pin numbers
/// pin-number-size: Font size for pin numbers
/// pin-label-size: Font size for pin labels
/// include-numbers: Boolean enabling pin numbers
/// pin-spacing: Spacing of pins
/// vertical-margin: Total margin to put into spacing above and below pin labels

#let z80-labels = ("A11", "A12", "A13", "A14", "A15", "CLK", "D4", "D3", "D5", "D6", "VCC", "D2", "D7", "D0", "D1", overline("INT"), overline("NMI"), overline("HALT"), overline("MREQ"), overline("IOREQ"), overline("RD"), overline("WR"), overline("BUSACK"), overline("WAIT"), overline("BUSREQ"), overline("RESET"), overline("M1"), overline("REFRESH"), "GND", "A0", "A1", "A2", "A3", "A4", "A5", "A6", "A7", "A8", "A9", "A10")

#dip-chip-label(40, 0.54in, z80-labels, "Z80", settings: (pin-number-margin: 1pt, pin-number-size: 2.5pt, chip-label-size: 5pt))
