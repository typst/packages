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

#let labels = ("1A", "1B", "1Y", "2A", "2B", "2Y", "GND", "3Y", "3A", "3B", "4Y", "4A", "4B", "VCC")
#dip-chip-label(14, 0.24in, labels, "74LS00")
