// category-map.typ — Mapping from registry group keys to colour palette keys
// Used by core.typ to derive the correct key in the colors dictionary
// from the group prefix of a block ID.

// Group key (from block ID prefix) → colour key (in rendering/colors.typ)
#let CATEGORY_MAP = (
  event:    "events",
  motion:   "motion",
  looks:    "looks",
  sound:    "sound",
  pen:      "pen",
  control:  "control",
  sensing:  "sensing",
  operator: "operators",
  data:     "variables",  // Default colour for data group; data list entries override to "lists"
  custom:   "custom",
)
