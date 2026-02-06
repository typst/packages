# v0.1.3
bug fix:

  - v13 would error with label, fixed now

# v0.1.2
features:

  - fixed issues with left part of equation
  - rewrote `math-to-data`, please refer to the docs
  - multiplication without dots works pretty seamlessly now
  - no error when equation is empty or only has `e`

removed:
  
  - `math-to-code` has been removed, it was quite useless

# v0.1.1
features: 

  - added ability to use labels

bug fixes:

  - the variable will now be in math mode in v13
  - expressions (without a left side) would cause an error

# v0.1.0
features:

  -  e, pi and tau work now
  -  sin, cos, etc. works now
  -  fixed a bug where top part of exponent couldn't be a sequence
  -  cleaned up some code
  -  dynamic table naming
  -  multiple variable support
  -  made the docs readable
  -  added math-to-data
