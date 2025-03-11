#import "../base-type.typ": base-type
#import "../assertions-util.typ": assert-base-type
#import "../ctx.typ": z-ctx
#import "../assertions-util.typ": *
#import "../assertions/string.typ": matches

/// Valkyrie schema generator for strings
///
/// -> schema
#let string(
  assertions: (),
  min: none,
  max: none,
  ..args,
) = {

  assert-positive-type(min, types: (int,), name: "Minimum length")
  assert-positive-type(max, types: (int,), name: "Maximum length")

  base-type(name: "string", types: (str,), ..args) + (
    min: min,
    max: max,
    assertions: (
      (
        precondition: "min",
        condition: (self, it) => it.len() >= self.min,
        message: (self, it) => "Length must be at least " + str(self.min),
      ),
      (
        precondition: "max",
        condition: (self, it) => it.len() <= self.max,
        message: (self, it) => "Length must be at most " + str(self.max),
      ),
      ..assertions,
    ),
  )
}

#let email = string.with(
  description: "email",
  assertions: (
    matches(
      regex("^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]{2,3}){1,2}$"),
      message: (self, it) => "Must be an email address",
    ),
  ),
);

#let ip = string.with(
  description: "ip",
  assertions: (
    matches(
      regex("^(?:(?:25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.){3}(?:25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])$"),
      message: (self, it) => "Must be a valid IP address",
    ),
  ),
);
