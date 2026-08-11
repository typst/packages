// cartesian.typ
// Implementation of Cartesian product function.

/// Computes the Cartesian product of a list of arrays.
/// The Cartesian product is the set of all ordered pairs (or tuples) that can be formed
/// by taking one element from each array.
/// The result is a list of tuples, where each tuple contains one element from each array.	
/// If any of the arrays is empty, the result will be an empty set.
/// 
/// -> array(array(any))
#let cartesian-product(
	/// A list of arrays to compute the Cartesian product.
	/// Each array can contain any type of elements.
	/// -> array(array(any))
	..arrays,
) = {
	arrays = arrays.pos()
	if arrays.len() == 0 {
		return none
	}
	if arrays.any(arr => arr.len() == 0) {
		return ()
	}
	// Start with the first array as the initial result
	let result = arrays.at(0).map(x => (x, ))
	// Iterate through the remaining arrays and build the Cartesian product
	for i in range(1, arrays.len()) {
		result = result
			.map(tuple => {
				arrays.at(i).map(x => tuple + (x, ))
			})
			.join()
	}
	return result
}