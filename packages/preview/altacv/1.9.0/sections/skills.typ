// `_skills` and `_interests` share the JSON Resume `{name, keywords}`
// shape, differing in heading and in weight: skills as tags, the
// keywords a reader looks for; interests as plain text.

#import "../internal/util/fields.typ": _field
#import "../internal/data/cv.typ": _skill-rating
#import "../internal/components/frame.typ": _section-frame
#import "../internal/components/keywords.typ": _keyword-rows, _label-rows
#import "../internal/components/ratings.typ": _rating-mark

// Each group's `level` after its label: dots where it has a rating
// (`_skill-rating`), else its text.
#let _skills(groups, (labels, prefs, ..)) = _section-frame(
  labels.skills,
  groups,
  _keyword-rows(groups.map(g => (
    g
      + (
        mark: _rating-mark(
          _skill-rating(g, prefs),
          prefs.max-rating,
          fallback: _field(g, "level"),
        ),
      )
  ))),
)

#let _interests(groups, (labels, ..)) = _section-frame(
  labels.interests,
  groups,
  _label-rows(groups),
)
