#import "@preview/check-six:0.1.0": *

#show: checklist.with(
  title: "Cessna 152 Checklist",
  subtitle: "For flight simulation use only",
  paper: "a4",        // "a5" -> automatically single-column and smaller
  // cols: 2,         // override the column count manually
  // boxes: true,     // add a checkbox before every item
  // base-size: 14pt, // Set base font-size for the document
  accent: rgb("#1b3a6b"),
  version: "1.0",
  footer: "Cessna 152 - Normal Procedures",
)

#section("Preflight Inspection")[
  #item("Ignition", "OFF")
  #item("Master Switch", "ON")
  #item("Fuel Quantity", "CHECK")
  #item("Flaps", "30°")
  #item("Master Switch", "OFF")
  #item("Weight and Balance", "CHECK")
  #item("Engine and Pitot Covers", "REMOVE")
  #item("Wheel Chocks", "PULLED")
  #item("Outside Inspection", "PERFORM")
]

#section("Before Starting Engine")[
  #item("Preflight Inspection", "COMPLETE")
  #item("Parking Brake", "SET")
  #item("Fuel Shutoff Valve", "ON")
  #item("Radios & Electronic Equipment", "OFF")
  #item("Circuit Breakers", "CHECK IN")
]

#section("Starting the Engine")[
  #item("Mixture", "RICH")
  #item("Carb Heat", "COLD")
  #item("Primer", "AS REQ (up to 3 strokes)")
  #item("Throttle", "OPEN 1/2 inch")
  #item("Master Switch (BAT & ALT)", "ON")
  #item("Beacon", "ON")
  #item("Ignition", "START then BOTH")
  #item("Throttle", "1,000 RPM")
  #item("Oil Pressure", "CHECK")
  #caution[
    If no oil pressure is indicating within 30 seconds,
    shut down the engine immediately.
  ]
  #item("Ammeter", "CHECK")
]

#section("Engine Runup", keep-together: true)[
  #item("Parking Brake", "SET")
  #item("Throttle", "~ 1,700 RPM")
  #item("Magneto Check", "LEFT, RIGHT, BOTH")
  #sub[Verify max drop = 125 RPM & max diff = 50 RPM]
  #item("Carb Heat Check", "ON, then OFF")
  #note[Verify RPM decreases and increases again.]
  #item("Suction Gage", "GREEN RANGE")
  #item("Throttle", "~ 1,000 RPM")
]

// --- example of a numbered section ---
#section(
  "Quick Start-Up",
  numbered: true,
  subtitle: "Short form, without cold-start details",
)[
  #item("Batt. Switch", "MAIN POWER")
  #item("Parking Brake", "ON")
  #item("Jet Fuel Starter", "START 2")
  #item("Internal & External Lights", "AS NEEDED")
  #item("Canopy", "Closed, Sealed & Locked")
  #item("ENG", "IDLE at 20% RPM")
  #warn[Only continue once ENG RPM has reached 65%.]
  #item("Altimeter", "ELEC")
  #item("Avionics", "ALL ON, INS NORM")
  #item("Ejection Seat", "ARMED")
]

#section("Emergency - Engine Failure", color: rgb("#c0202a"))[
  #item("Airspeed", "65 KIAS")
  #item("Mixture", "IDLE CUTOFF")
  #item("Fuel Shutoff Valve", "OFF")
  #item("Ignition", "OFF")
  #item("Master Switch", "OFF")
  #item("Flaps", "AS REQUIRED")
]

#section("Collection of all Elements in this Template")[
  #item("This is a regular Item", "It really is!")
  #sub[This is a sub-item, which can be used to add additional information to the parent item.]
  #note[This is a note]
  #warn[This is a warning]
  #caution[This is a caution field]
]
