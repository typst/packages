// permutations.typ
// This module implements functions to compute permutations.

#import "cartesian.typ": cartesian-product
#import "combinations.typ": get-combinations-no-repetition

/// Counts the *number of permutations with repetition*.
/// Returns the number of possible permutations when choosing $k$ items from $n$ distinct items, allowing repetitions.
/// -> int
#let count-permutations-with-repetition(
	/// The array of distinct items, or the total number of distinct items.
	/// Both an array and an integer are accepted. In the case of an array, its length is used. In the case of an integer, it must be a non-negative integer.
	/// -> int | array
	items, 
	/// The number of items to choose, among the $n$ distinct items.
	/// Must be a non-negative integer.
	/// -> int
	k: auto,
) = {
	if type(items) == array {
		items = items.len()
	}
	if k == auto {
		k = items
	}
	return calc.pow(items, k)
}

/// Calculates the number of permutations without repetition.
/// Returns the number of possible permutations when choosing $k$ items from $n$ distinct items, without allowing repetitions.
/// -> int
#let count-permutations-no-repetition(
	/// The array of distinct items, or the total number of distinct items.
	/// Both an array and an integer are accepted. In the case of an array, its length is used. In the case of an integer, it must be a non-negative integer.
	/// -> int | array
	items, 
	/// The number of items to choose, among the $n$ distinct items.
	/// Must be a non-negative integer.
	/// -> int
	k: auto,
) = {
	if type(items) == array {
		items = items.len()
	}
	if k == auto {
		k = items
	}
	return calc.perm(items, k)
}

/// Computes the *number of permutations* of $n$ elements taken $k$ at a time.
/// The order of elements matters, and each element can be chosen only once unless repetition is allowed (by setting `repetition` to #(true)). 
/// - If `repetition` is #(false), the number is computed using the formula for *permutations without repetition* implemented as the `perm` function in the `calc` module:
/// 	$ P(n, k) = n! / (n - k)! = "perm"(n, k) $
/// - If `repetition` is #(true), the number is computed using the formula for *permutations with repetition*:
/// 	$ n^k = "pow"(n, k) $	
/// The returned number is given as an *integer*.
/// -> int
#let count-permutations(
	/// The array of distinct items, or the total number of distinct items.
	/// Both an array and an integer are accepted. In the case of an array, its length is used. In the case of an integer, it must be a non-negative integer.
	/// -> int | array
	items, 
	/// The number of items to choose, among the $n$ distinct items.
	/// Must be a non-negative integer.
	/// -> int
	k: auto, 
	/// Whether to allow repetition of elements in the permutations.
	/// If #(true), elements can be chosen multiple times. If #(false), each element can be chosen only once.
	/// Default is #(false).
	/// -> bool
	repetition: false,
) = {
	if repetition {
		return count-permutations-with-repetition(items, k: k)
	} else {
		return count-permutations-no-repetition(items, k: k)
	}
}

/// Generates all *permutations with repetition* of $n$ elements taken $k$ at a time.
/// The order of elements matters, and each element can be chosen multiple times.
/// The list of permutations is represented as an array of tuples, where each tuple contains the indices of the chosen elements.
/// Indices are zero-based, meaning they start from 0 up to $n-1$.
/// If $k$ is not provided or set to #(auto), it defaults to $n$, generating permutations that use all elements.
/// The function returns an empty list if either $n$ or $k$ is negative.
/// -> array(array(int | any))
#let get-permutations-with-repetition(
	/// The array of distinct items, or the total number of distinct items.
	/// Both an array and an integer are accepted. In the case of an integer, it is interpreted as the total number of distinct items from $0$ to $n-1$.
	/// -> int | array
	items, 
	/// The number of items to choose, among the $n$ distinct items.
	/// Must be a non-negative integer.
	/// -> int
	k: auto,
) = {
	let n = if type(items) == array {items.len()} else {items}
	if k == auto {
		k = n
	}
	if n <= 0 or k < 0 {
		return () // Empty array
	} else if k == 0 {
		return ((),) // Array with one empty array
	}
	let arrs = (array(range(n)),) * k
	let permutations = cartesian-product(..arrs)
	if type(items) == array {
		return permutations.map(comb => {return comb.map(i => items.at(i))})
	} else {
		return permutations
	}
}

// Auxiliary function to get the next lexicographic permutation.
// Gets a permutation "p" (as an array of integer) and returns the next permutation in lexicographic order, or #(none) if "p" is the last permutation.
#let get-next-permutation(p) = {
	// 1. Find longest non-increasing suffix
	let i = p.len() - 1
	while i > 0 and p.at(i - 1) >= p.at(i) {
		i = i - 1
	}
	if i <= 0 {
		// This is the last permutation
		return none
	}
	// 2. Find rightmost successor to pivot (i - 1) in the suffix
	let j = p.len() - 1
	while p.at(j) <= p.at(i - 1) {
		j = j - 1
	}
	// 3. Swap the pivot with j (we assume that i - 1 < j)
	let p_swap = p.slice(0, i - 1) + (p.at(j), ) + p.slice(i, j) + (p.at(i - 1), ) + p.slice(j + 1)
	// 4. Reverse the suffix
	return p_swap.slice(0, i) + p_swap.slice(i, ).rev()
}

// Auxiliary function to get all permutations of an array sorted in ascending order, without repetitions.
// The input array must be sorted in ascending order and contain no repeated elements.
#let permute-sorted-array-without-repetitions(arr) = {
	let permutations = ()
	let curr_perm = arr
	while curr_perm != none {
		permutations.push(curr_perm)
		curr_perm= get-next-permutation(curr_perm)
	}
	return permutations
}

/// Generates all *permutations without repetition* of $n$ elements taken $k$ at a time.
/// The order of elements matters, and each element can be chosen only once.
/// The list of permutations is represented as an array of tuples, where each tuple contains the indices of the chosen elements.
/// Indices are zero-based, meaning they start from 0 up to $n-1$.
/// If $k$ is not provided or set to #(auto), it defaults to $n$, generating permutations that use all elements.
/// The function returns an empty list if $k$ is greater than $n$, or if either $n$ or $k$ is negative.
/// If $k$ is 0, the function returns a list containing an empty tuple, representing the single permutation of choosing nothing.
/// If $k$ equals $n$, a more efficient algorithm is used to generate all permutations of the entire set.
/// In the general case where $0 < k < n$, the function first generates all combinations of size $k$, and then generates all permutations for each combination.
/// The result is an array of tuples, where each tuple contains the indices of the chosen elements.
//
/// -> array(array(int | any))
#let get-permutations-no-repetition(
	/// The array of distinct items, or the total number of distinct items.
	/// Both an array and an integer are accepted. In the case of an integer, it is interpreted as the total number of distinct items from $0$ to $n-1$.
	/// -> int | array
	items, 
	/// The number of items to choose, among the $n$ distinct items.
	/// Must be a non-negative integer.
	/// -> int
	k: auto,
) = {
	// "n" is the total number of distinct items
	let n = if type(items) == array {items.len()} else {items}
	// If k is not provided, default to n
	if k == auto {k = n}
	// Handle edge cases
	if k > n or n <= 0 or k < 0 {
		return () // Empty array

	} else if k == 0 {
		// Special case: only one permutation, the empty permutation
		return ((),)
		
	} else if k == 1 {
		// Special case: each permutation is a single element
		if type(items) == array {
			return items.map(i => (i,))
		} else {
			return range(n).map(i => (i,))
		}

	} else if k == 2 {
		// Special case: generate all permutations of pairs
		let arr = if type(items) == array {items} else {array(range(n))}
		let permutations_of_pairs = ()
		for i in range(n) {
			for j in range(n) {
				if i != j {
					permutations_of_pairs.push((arr.at(i), arr.at(j)))
				}
			}
		}
		return permutations_of_pairs

	} else if k == n {
		// Special case: generate all permutations of the entire set
		let arr = if type(items) == array {items} else {array(range(n))}
		return permute-sorted-array-without-repetitions(arr)
		
	} else if k == n - 1 {
		// Special case: generate all permutations of the entire set, with the last element removed
		let arr = if type(items) == array {items} else {array(range(n))}
		let remove-last-element(arr) = arr.slice(0, -1)
		return permute-sorted-array-without-repetitions(arr).map(remove-last-element)

	} else {
		// General case: k € [3; n-2] inclusive
		let permutations_k_minus_1 = get-permutations-no-repetition(items, k: k - 1)
		items = if type(items) == array {itemstr} else {array(range(n))}

		// For each element in the array, we append it to each permutation of size k-1 that does not already contain it
		let permutations = permutations_k_minus_1.map(p => {
			let added_perms = ()
			for i in items {
				if not i in p {
					added_perms.push(p + (i,))
				}
			}
			return added_perms
		}).join()
		return permutations
	}
}

/// Generates all permutations of $n$ elements taken $k$ at a time.
/// The order of elements matters. By default, each element can be chosen only once, but this can be changed by setting `repetition` to #(true). 
/// The list of permutations is represented as an array of tuples, where each tuple contains the indices of the chosen elements.
/// Indices are zero-based, meaning they start from 0 up to $n-1$.
/// If $k$ is not provided or set to #(auto), it defaults to $n$, generating permutations that use all elements.
/// The function returns an empty list if $k$ is greater than $n$ when `repetition` is #(false), or if either $n$ or $k$ is negative.
/// If $k$ is 0, the function returns a list containing an empty tuple, representing the single permutation of choosing nothing.
/// - If `repetition` is #(false), permutations are generated without allowing any element to be chosen more than once.
/// - If `repetition` is #(true), permutations are generated allowing elements to be chosen multiple times. 
/// -> array(array(int | any))
#let get-permutations(
	/// The array of distinct items, or the total number of distinct items.
	/// Both an array and an integer are accepted. In the case of an integer, it is interpreted as the total number of distinct items from $0$ to $n-1$.
	/// -> int | array
	items, 
	/// The number of items to choose, among the $n$ distinct items.
	/// Must be a non-negative integer.
	/// -> int
	k: auto,
	/// Whether to allow repetition of elements in the permutations.
	/// If #(true), elements can be chosen multiple times. If #(false), each element can be chosen only once.
	/// Default is #(false).
	/// -> bool
	repetition: false,
) = {
	if repetition {
		return get-permutations-with-repetition(items, k: k)
	} else {
		return get-permutations-no-repetition(items, k: k)
	}
}
