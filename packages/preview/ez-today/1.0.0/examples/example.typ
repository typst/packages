#import "../ez-today.typ"

// Default output
#ez-today.today()

// Custom format with English months
#ez-today.today(lang: "en", format: "M-d-Y")

// Defining some custom names
#let my-months = ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
// Get current date with custom names
#ez-today.today(custom-months: my-months, format: "M-y")

// Get the current date in the ISO 8601 format
#ez-today.today(format: "ISO")