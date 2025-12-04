// combinatorics.typ
// Utility functions to handle combinatorial operations on card hands


/// Produces all combinations of k elements from a set of n elements. 
/// This is a helper function to generate combinations for the `choose-k-out-of-n` function.
/// The elements are guaranteed to be in increasing order, starting from 0 to n-1. The result is a list of ordered tuples, where each tuple represents a combination of k elements.
/// Repeated elements are not allowed, and the order of elements in each combination is preserved.
/// 
/// -> array(array(int))
#let get-combinations-k-out-of-n(
	/// The number of elements to choose from the set.
	/// Must be a non-negative integer.
	/// -> int
	k, 
	/// The total number of elements in the set.
	/// Must be a non-negative integer.
	/// -> int
	n
) = {
	if k == 0 {
		// If k is 0, return an empty combination
		return ((), )
	} else if k > n {
		// If k is greater than n, return an empty set
		return ()
	} else if k < 0 or n < 0 {
		// If k or n is negative, panic with an error message
		panic("k and n must be non-negative integers")
	}
	let combinations = range(n).map(n => (n, ))
	for j in range(k - 1) { // for "k - 1" times
		combinations = combinations
			.map(comb => {
				return range(comb.last() + 1, n).map(i => comb + (i, ))
			})
			.join()
	}
	return combinations
}

/// Generates all combinations of k elements from a given array of n elements.
/// This function uses the `get-combinations-k-out-of-n` helper function to generate combinations.
/// The result is a list of arrays, where each array represents a combination of k elements from the input array.
/// 
/// -> array(array(any))
#let choose-k-out-of-n(
	/// The number of elements to choose from the set.
	/// Must be a non-negative integer.
	/// -> int
	k, 
	/// The array of elements to choose from.
	/// Must be a non-empty array.
	/// -> array(any)
	cards,
) = {
	let comb-indices = get-combinations-k-out-of-n(k, cards.len())
	return comb-indices.map(comb => {
		return comb.map(i => cards.at(i))
	})
}


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