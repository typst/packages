#import "funarray_unsafe.typ"

// The following line is only for typst package capabilities, to access the module
#let unsafe_functions() = funarray_unsafe

/// splits the array into chunks of given size.
#let chunks(arr, size) = {
    assert.eq(type(arr), "array", message: "Argument `arr` must be an array.")
    assert.eq(type(size), "integer", message: "Argument `size` must be an integer.")
    assert(size > 0, message: "Argument `size` must be > 0.")

    funarray_unsafe.chunks(arr, size)
}

/// inverse of zip method. array(pair) -> pair(array)
#let unzip(arr) = {
    assert.eq(type(arr), "array", message: "Argument `arr` must be an array.")
    assert(arr.all(p => p.len() > 1), message: "Argument `arr`'s elements must have length minimum of 2.")
    funarray_unsafe.unzip(arr)
}

/// cycles through arr until length is met
#let cycle(arr, length) = {
    assert.eq(type(arr), "array", message: "Argument `arr` must be an array.")
    assert.eq(type(length), "integer", message: "Argument `length` must be an integer.")
    assert(arr != (), message: "Argument `arr` cannot be empty.")
    assert(length >= 0, message: "Argument `length` must be >= 0.")

    funarray_unsafe.cycle(arr, length)
}

/// provides a running window of given size
#let windows(arr, size) = {
    assert.eq(type(arr), "array", message: "Argument `arr` must be an array.")
    assert.eq(type(size), "integer", message: "Argument `size` must be an integer.")
    assert(size > 0, message: "Argument `size` must be > 0.")

    funarray_unsafe.windows(arr, size)
}

/// same as windows, but continues wrapping at the border
#let circular_windows(arr, size) = windows(arr + arr.slice(size - 1), size)

/// creates two arrays, 1. where f returns true, 2. where f returns false
#let partition(arr, f) = {
    assert.eq(type(arr), "array", message: "Argument `arr` must be an array.")
    // no check of function signature

    funarray_unsafe.partition(arr, f)
}

/// after partition, maps each partition according to g
#let partition_map(arr, f, g) = {
    // no check for function signature
    
    let parts = partition(arr, f)
    (parts.at(0).map(g), parts.at(1).map(g))
}

/// groups the array into maximally sized chunks, where each elements yields same predicate value
#let group_by(arr, f) = {
    assert.eq(type(arr), "array", message: "Argument `arr` must be an array.")
    // no check of function signature

    funarray_unsafe.group_by(arr, f)
}

/// inserts a value inbetween each element
#let intersperse(arr, sep) = {
    assert.eq(type(arr), "array", message: "Argument `arr` must be an array.")

    funarray_unsafe.intersperse(arr, sep)
}

/// returns all elements until the predicate returns false
#let take_while(arr, f) = {
    assert.eq(type(arr), "array", message: "Argument `arr` must be an array.")
    // no check of function signature

    funarray_unsafe.take_while(arr, f)
}

/// returns all elements starting when the predicate returns false
#let skip_while(arr, f) = {
    assert.eq(type(arr), "array", message: "Argument `arr` must be an array.")
    // no check of function signature

    funarray_unsafe.skip_while(arr, f)
}