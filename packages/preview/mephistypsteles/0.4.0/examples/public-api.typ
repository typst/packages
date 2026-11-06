#set page(height: auto, margin: 1cm)

#import "@preview/mephistypsteles:0.4.0": *

#let file = ```typ
#import "@preview/cetz:0.1.0"
/// Test 1
#import "thing.typ" as stuff: a, b
/// Test 2
#import "other.typ": *

/// Test 3
#let first = 3

/// Test 4
///
/// Multiple lines
#let second(a, b) = a + b

/// Parameter docstrs
#let third(
	/// Parameter 1
	this,
	/// Parameter 2
	that
) = ()

/// Parameter docstrs (assignment to closure)
#let fourth = (
	/// Parameter 1
	me,
	/// Parameter 2
	you
) => ()
```.text

#public-api(file)