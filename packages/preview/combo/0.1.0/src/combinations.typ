// combinations.typ
// This module implements functions to compute combinations.


/// Counts the *number of combinations with repetition*.
/// Returns the number of possible combinations when choosing $k$ items from $n$ distinct items, allowing repetitions.
/// 
/// -> int
#let count-combinations-with-repetition(
	/// The array of distinct items, or the total number of distinct items.
	/// Both an array and an integer are accepted. In the case of an array, its length is used. In the case of an integer, it must be a non-negative integer.
	/// -> int | array
	items, 
	/// The number of items to choose, among the $n$ distinct items.
	/// Must be a non-negative integer.
	/// -> int
	k,
) = {
	if type(items) == array {
		items = items.len()
	}
	return calc.binom(items + k - 1, k)
}

/// Calculates the number of combinations without repetition.
/// Returns the number of possible combinations when choosing $k$ items from $n$ distinct items, without allowing repetitions.
//
/// -> int
#let count-combinations-no-repetition(
	/// The array of distinct items, or the total number of distinct items.
	/// Both an array and an integer are accepted. In the case of an array, its length is used. In the case of an integer, it must be a non-negative integer.
	/// -> int | array
	items, 
	/// The number of items to choose, among the $n$ distinct items.
	/// Must be a non-negative integer.
	/// -> int
	k,
) = {
	if type(items) == array {
		items = items.len()
	}
	return calc.binom(items, k)
}

/// Computes the *number of combinations* of $n$ elements taken $k$ at a time.
/// The order of elements does not matter, and each element can be chosen only once unless repetition is allowed (by setting `repetition` to #(true)). 
/// 
/// - If `repetition` is #(false), the number is computed using the *binomial coefficient formula* (also known as _"n choose k"_) implemented as the `binom` function in the `calc` module:
/// 	$ C(n, k) = n! / (k! dot (n - k)!) = "binom"(n, k) $
/// - If `repetition` is #(true), the number is computed using the formula for *combinations with repetition*:
/// 	$ C(n + k - 1, k) = "binom"(n + k - 1, k) $
/// 
/// The returned number is given as an *integer*. 
/// 
/// -> int
#let count-combinations(
	/// The array of distinct items, or the total number of distinct items.
	/// Both an array and an integer are accepted. In the case of an array, its length is used. In the case of an integer, it must be a non-negative integer.
	/// -> int | array
	items, 
	/// The number of items to choose, among the $n$ distinct items.
	/// Must be a non-negative integer.
	/// -> int
	k,
	/// Whether to allow repetition of elements in the combinations.
	/// If #(true), elements can be chosen multiple times. If #(false), each element can be chosen only once.
	/// Default is #(false).
	repetition: false,
) = {
	if repetition {
		return count-combinations-with-repetition(items, k)
	} else {
		return count-combinations-no-repetition(items, k)
	}
}

/// Computes the list of combinations of $k$ elements from a set of $n$ elements, allowing repetition.
/// The list of combinations is represented as an array of tuples, where each tuple contains the indices of the chosen elements.
/// Indices are zero-based, meaning they start from 0 up to $n-1$.
/// The number of combinations is computed using the formula for combinations with repetition:
/// $ C(n + k - 1, k) = "binom"(n + k - 1, k) = (n + k - 1)! / (k! dot (n - 1)!) $
//
/// -> array(array(int | any))
#let get-combinations-with-repetition(
	/// The array of distinct items, or the total number of distinct items.
	/// Both an array and an integer are accepted. In the case of an integer, it is interpreted as the total number of distinct items from $0$ to $n-1$. 
	/// -> int | array
	items, 
	/// The number of items to choose, among the $n$ distinct items.
	/// Must be a non-negative integer.
	/// -> int
	k,
) = {
	let n = if type(items) == array {items.len()} else {items}
	if k == 0 {
		// If k is 0, return an empty combination
		return ((), )
	} else if k < 0 or n < 0 {
		// If k or n is negative, panic with an error message
		panic("k and n must be non-negative integers")
	} else if n == 0 {
		// If n is 0, no combinations possible unless k is 0
		return ()
	}
	let combinations = range(n).map(i => (i,))
	for j in range(k - 1) {
		combinations = combinations
			.map(comb => {
				let start = comb.last()
				return range(start, n).map(i => comb + (i,))
			})
			.join()
	}
	if type(items) == array {
		return combinations.map(comb => comb.map(i => items.at(i)))
	} else {
		return combinations
	}
}

/// Computes the list of combinations of $k$ elements from a set of $n$ elements, without allowing repetition. As in combinations, the order of elements does not matter.
/// The list of combinations is represented as an array of tuples, where each tuple contains the indices of the chosen elements.
/// Indices are zero-based, meaning they start from 0 up to $n-1$.
//
/// -> array(array(int | any))
#let get-combinations-no-repetition(
	/// The array of distinct items, or the total number of distinct items.
	/// Both an array and an integer are accepted. In the case of an integer, it is interpreted as the total number of distinct items from $0$ to $n-1$. 
	/// -> int | array
	items, 
	/// The number of items to choose, among the $n$ distinct items.
	/// Must be a non-negative integer.
	/// -> int
	k,
) = {
	let n = if type(items) == array {items.len()} else {items}
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
	for _ in range(k - 1) { /// for "k - 1" times
		combinations = combinations
			.map(comb => {
				return range(comb.last() + 1, n).map(i => comb + (i, ))
			})
			.join()
	}
	if type(items) == array {
		return combinations.map(comb => comb.map(i => items.at(i)))
	} else {
		return combinations
	}
}

/// Computes the *list of combinations* of indices for choosing $k$ elements from a set of $n$ elements.
/// The order of elements does not matter, and each element can be chosen only once unless repetition is allowed (by setting `repetition` to #(true)). 
/// The result is a list of tuples, where each tuple contains the indices of the chosen elements. 
/// Indices are zero-based, meaning they start from 0 up to $n-1$.
/// 
/// - If `repetition` is #(false), combinations are generated without allowing any element to be chosen more than once.
/// - If `repetition` is #(true), combinations are generated allowing elements to be chosen multiple times.
/// The function returns an empty list if $k$ is greater than $n$ when `repetition` is #(false), or if either $n$ or $k$ is negative.
/// If $k$ is 0, the function returns a list containing an empty tuple, representing the single combination of choosing nothing.
/// 
/// -> array(array(int | any))
#let get-combinations(
	/// The array of distinct items, or the total number of distinct items.
	/// Both an array and an integer are accepted. In the case of an integer, it is interpreted as the total number of distinct items from $0$ to $n-1$. 
	/// -> int | array
	items, 
	/// The number of items to choose, among the $n$ distinct items.
	/// Must be a non-negative integer.
	/// -> int
	k,
	/// Whether to allow repetition of elements in the combinations.
	/// If #(true), elements can be chosen multiple times. If #(false), each element can be chosen only once.
	/// Default is #(false).
	repetition: false,
) = {
	if repetition {
		return get-combinations-with-repetition(items, k)
	} else {
		return get-combinations-no-repetition(items, k)
	}
}
