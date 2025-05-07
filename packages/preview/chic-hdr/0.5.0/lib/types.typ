/*
 * Chic-header - A package for Typst
 * Pablo González Calderón (c) 2023
 *
 * types.typ -- The package's file for checking if a
 * dictionary is a valid chic-hdr package element.
 *
 * This file is under the MIT license. For more
 * information see LICENSE on the package's main folder.
 */

/*
 * chic-valid-type
 *
 * Checks if a given argument is a valid element of
 * the chic-hdr package
 *
 * Parameters:
 * - arg: Argument to check
 */
#let chic-valid-type(arg) = {
  return type(arg) == dictionary and "chic-type" in arg
}
