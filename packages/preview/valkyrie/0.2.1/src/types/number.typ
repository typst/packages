#import "../base-type.typ": base-type
#import "../assertions-util.typ": *

#let number(
  assertions: (),
  min: none,
  max: none,
  ..args,
) = {

  assert-positive-type(min, types: (int,), name: "Minimum length")
  assert-positive-type(max, types: (int,), name: "Maximum length")

  base-type(name: "number", types: (float, int), ..args) + (
    min: min,
    max: max,
    assertions: (
      (
        precondition: "min",
        condition: (self, it) => it >= self.min,
        message: (self, it) => "Value must be at least " + str(self.min),
      ),
      (
        precondition: "max",
        condition: (self, it) => it <= self.max,
        message: (self, it) => "Value must be at most " + str(self.max),
      ),
      ..assertions,
    ),
  )
}

#let integer = number.with(description: "integer", types: (int,))
#let floating-point = number.with(description: "float", types: (float,))