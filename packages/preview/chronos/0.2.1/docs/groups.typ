/// Creates a group of sequences
/// #examples.grp
/// - name (content): The group's name
/// - desc (none, content): Optional description
/// - type (str): The groups's type (should only be set through other functions like @@_alt() or @@_loop() )
/// - elmts (array): Elements inside the group (can be sequences, other groups, notes, etc.)
#let _grp(
  name,
  desc: none,
  type: "default",
  elmts
) = {}

/// Creates an alt-else group of sequences
/// 
/// It contains at least one section but can have as many as needed
/// #examples.alt
/// - desc (content): The alt's label
/// - elmts (array): Elements inside the alt's first section
/// - ..args (content, array): Complementary "else" sections.\ You can add as many else sections as you need by passing a content (else section label) followed by an array of elements (see example)
#let _alt(
  desc,
  elmts,
  ..args
)

/// Creates a looped group of sequences
/// #examples.loop
/// - desc (content): Loop description
/// - min (none, number): Optional lower bound of the loop
/// - max (auto, number): Upper bound of the loop. If left as `auto` and `min` is set, it will be infinity (`'*'`)
/// - elmts (array): Elements inside the group
#let _loop(
  desc,
  min: none,
  max: auto,
  elmts
) = {}

/// Synchronizes multiple sequences\
/// All elements inside a synchronized group will start at the same time
/// #examples.sync
/// - elmts (array): Synchronized elements (generally sequences or notes)
#let _sync(
  elmts
)

/// Creates an optional group\
/// This is a simple wrapper around @@_grp()
/// - desc (content): Group description
/// - elmts (array): Elements inside the group
#let _opt(desc, elmts) = {}

/// Creates a break group\
/// This is a simple wrapper around @@_grp()
/// - desc (content): Group description
/// - elmts (array): Elements inside the group
#let _break(desc, elmts) = {}