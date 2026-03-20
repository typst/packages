#import "@local/adversa:0.1.1": *
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *

#show: codly-init.with()
#show: adversa.with(
  author: "You",
  title: [Algorithms and Data Structures],
  subtitle: [Comprehensive set of notes],
  outline-title: [Contents],
  show-date: true
)

#codly(languages: codly-languages)

= Introduction to the course

Welcome to the comprehensive guide on algorithms and data structures. This text is designed to establish a rigorous foundation in computational complexity, data organization, and problem-solving techniques. 

== Core Concepts
Before we dive into complex structures, we must establish a shared vocabulary. The study of algorithms is not just about writing code; it is about writing *efficient* code.

#definition("Algorithm")[
  An algorithm is a finite sequence of well-defined, computer-implementable instructions, typically used to solve a class of specific problems or to perform a computation.
]

#remark[
  When evaluating an algorithm, we primarily look at its Time Complexity and Space Complexity. Always consider the worst-case scenario (Big-O notation) unless specified otherwise.
]

=== The Importance of Complexity
Understanding asymptotic notation is crucial. Here are the three main types of cases we analyze:
+ *Worst-case scenario:* The maximum execution time required.
+ *Average-case scenario:* The expected execution time over all possible inputs.
+ *Best-case scenario:* The minimum execution time required.

= Sorting and Searching

In this chapter, we will explore fundamental algorithms used to order and retrieve data.

== Comparison-based Sorting
Sorting is a classic problem in computer science. Let us look at the theoretical limits of sorting algorithms that rely on comparing elements.

#theorem("Lower Bound of Comparison Sorting")[
  Any comparison-based sorting algorithm must perform at least $Omega(n log n)$ comparisons in the worst case to sort an array of $n$ elements.
]

#proof[
  Consider a decision tree modeling the operations of a comparison sort on $n$ elements. The tree must have at least $n!$ leaves, representing all possible permutations of the input. Since a binary tree of height $h$ has at most $2^h$ leaves, we have $2^h >= n!$. Taking the base-2 logarithm on both sides yields $h >= log_2(n!)$. Using Stirling's approximation, $log_2(n!) = Theta(n log n)$, concluding the proof.
]

== Practical Implementations
Let's look at how we can implement searching. Binary search is an excellent example of a divide-and-conquer strategy.

#lemma[
  Binary search requires the input array to be strictly sorted prior to execution.
]

#example("Binary Search in Python")[
  Below is a standard iterative implementation of the binary search algorithm.
]

#code[
  ```python
  def binary_search(array: list[int], target: int) -> int:
      left, right = 0, len(array) - 1
      
      while left <= right:
          mid = left + (right - left) // 2
          
          if array[mid] == target:
              return mid
          elif array[mid] < target:
              left = mid + 1
          else:
              right = mid - 1
              
      return -1
  ```
]

= Data Structures Overview

A data structure is a particular way of organizing data in a computer so that it can be used effectively. Different kinds of data structures are suited to different kinds of applications.

== Common Structures
Here is a brief list of structures we will cover:
- Arrays and Strings
- Linked Lists (Singly and Doubly linked)
- Hash Tables
- Trees (Binary, AVL, Red-Black)
- Graphs (Directed and Undirected)

#exercise("Hash Collisions")[
  Explain the difference between Open Addressing and Separate Chaining. What happens to the time complexity of a Hash Table if a poor hash function places all elements into the same bucket?
]

#solution[
  If a hash function places all elements into the same bucket, the Hash Table degenerates into a Linked List. Consequently, the average time complexity for lookup, insertion, and deletion drops from $O(1)$ to $O(n)$.
]

== Performance Summary
Below is a quick reference table summarizing the time complexities of basic operations on various data structures.

#align(center)[
  #tablef(
    columns: 4,
    [*Data Structure*], [*Access*], [*Search*], [*Insertion*],
    [Array], [$O(1)$], [$O(n)$], [$O(n)$],
    [Stack / Queue], [$O(n)$], [$O(n)$], [$O(1)$],
    [Singly Linked List], [$O(n)$], [$O(n)$], [$O(1)$],
    [Hash Table], [N/A], [$O(1)$], [$O(1)$]
  )
]