// Re-export the main theme file from the lib directory
#import "theme.typ": *

// Note: Basic Touying functions like `pause` and `slide` are already available
// through theme.typ's `#import "@preview/touying:0.7.1": *`

// Re-export additional Touying utilities for user convenience
// These animation and utility functions are useful but not in Touying's main namespace
#import "@preview/touying:0.7.1": alternatives, meanwhile, only, uncover
#import "@preview/touying:0.7.1": utils  // Includes slide-counter and other utilities
