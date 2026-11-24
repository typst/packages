///! The one reading of "this directive names a column that is not there".
///!
///! A column that exists but sits elsewhere is not an unknown column, and
///! saying so would send the reader hunting for a typo that is not there. So a
///! hidden column and a stub column are each named as what they are, and only a
///! name the table does not carry at all is reported as unknown.
///!
///! Written out at three call sites before this existed, and the three had
///! already drifted apart in wording. The order and the problem text are shared;
///! the hints are not, since what to do about a hidden column depends on what
///! the directive was trying to do with it.

#import "errors.typ": check, check-column, column-name

#let check-addressable(
  name,
  scope,
  columns: (),
  hidden: (),
  stub: (),
  hidden-hint: none,
  stub-hint: none,
) = {
  check(
    name not in hidden,
    scope,
    "column " + column-name(name) + " is hidden",
    hint: hidden-hint,
  )
  check(
    name not in stub,
    scope,
    "column " + column-name(name) + " is in the stub",
    hint: stub-hint,
  )
  check-column(columns, scope, name)
}
