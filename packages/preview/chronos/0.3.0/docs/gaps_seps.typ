/// Creates a separator before the next element
/// #examples.seps
/// - name (content): Name to display in the middle of the separator
#let _sep(name) = {}

/// Creates a delay before the next element
/// #examples.delays
/// - name (content, none): Name to display in the middle of the delay area
/// - size (int): Size of the delay
#let _delay(name: none, size: 30) = {}

/// Creates a gap before the next element
/// #examples.gaps
/// - size (int): Size of the gap
#let _gap(size: 20) = {}