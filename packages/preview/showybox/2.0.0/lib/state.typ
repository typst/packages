/*
 * ShowyBox - A package for Typst
 * Pablo González Calderón and Showybox Contributors (c) 2023
 *
 * lib/state.typ -- The package's file containing all the
 * internal functions used to handle showybox state and id
 *
 * This file is under the MIT license. For more
 * information see LICENSE on the package's main folder.
 */

#let _showy-state(id) = state("showybox-state-for-id-" + repr(id), 0pt)
#let _showy-id = counter("showybox-id")