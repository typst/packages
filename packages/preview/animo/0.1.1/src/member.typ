// SPDX-FileCopyrightText: 2026 Toon Verstraelen <Toon.Verstraelen@UGent.be>
// SPDX-License-Identifier: Apache-2.0

// Which region each site of a slide sits in, and what a boundary therefore redraws.
//
// Only layout knows which tags a region holds, because a region receives its body as opaque
// content, so this is not something the resolver can answer.
// Every tag site and every region reports itself where it is laid out, and the reports are
// read back with `query` after the slide.
//
// What a boundary redraws follows from those reports and from the epoch it starts:
// the regions that hold the tags the boundary changes, with a region inside another changed
// region left out, because redrawing the outer one redraws it too.
// The browser is handed the group of each, since a key is animo's own way of naming a region
// and a group in the output is addressed by a label.

#import "anim.typ": default-timing

// The label of the report that says which region a site belongs to.
#let member-label = label("animo-member")

// Report which region a tag or a region belongs to,
// as `(slide:, kind:, name:, key:, group:, parent:)`.
//
// `key` is the region the site belongs to, and `parent` the one around the site,
// which differ for a region with a number and for a tag that is its own implicit region.
// `group` is the label that the site's own group carries in the output, and is `none` for a
// site that is not the region its key names.
// It is how a key becomes something the browser can address, because only the site that owns
// the key knows what it called itself.
// A `metadata` element is layout-neutral wherever it sits.
#let member(view, kind, name, key, group: none) = [#metadata((
    slide: view.slide,
    kind: kind,
    name: name,
    key: key,
    group: group,
    parent: view.region.key,
  ))#member-label]

// The membership reports of one slide, read back from its renderings.
//
// Must be called in a context.
#let members-of(index) = (
  query(member-label).map(it => it.value).filter(it => it.slide == index)
)

// Which region each region reported to sit in, as `(child, parent)` pairs.
#let region-parents(members) = {
  let parents = ()
  for it in members {
    if it.key != it.parent and (it.key, it.parent) not in parents {
      parents.push((it.key, it.parent))
    }
  }
  parents
}

// The region a region reported to sit in, or `none` for one that sits in no other.
#let parent-of(parents, key) = {
  let found = parents.find(((child, _)) => child == key)
  if found != none { found.last() }
}

// The region that crossfades for one of the keys a boundary changes: the outermost changed
// region above it, or the key itself when nothing above it changed.
//
// One walk answers both questions a boundary asks of the region graph.
// A key whose owner is itself is a region the boundary redraws, and a key whose owner is
// another is redrawn inside that one, because redrawing the outer region redraws everything
// it holds.
//
// `keys` may hold a region that is not maximal, and the answer is the same either way: the
// walk keeps the last match it finds, and the outermost changed region above a key has no
// changed region above it, so it is in `keys` whether or not the inner ones were filtered
// out first.
#let owner-of(parents, keys, key) = {
  let owner = key
  let above = parent-of(parents, key)
  while above != none {
    if above in keys { owner = above }
    above = parent-of(parents, above)
  }
  owner
}

// Every region that holds a tag the first step of `epoch` addresses, as their keys, in the
// order the membership reports name them.
//
// The key `none` is among them for a tag that no region bounds, which is a `wrap: none` tag
// outside an explicit region: it has no box of its own, so its change is confined to no area
// and the whole rendering is what redraws.
// The answer is only as complete as `members`: a tag reports from the renderings it is laid
// out in, so a tag that only a later epoch lays out is known once that epoch is rendered.
#let changed-keys(epochs, epoch, members) = {
  let changed = epochs.at(epoch).changed
  let keys = ()
  for it in members {
    if it.kind == "tag" and it.name in changed and it.key not in keys {
      keys.push(it.key)
    }
  }
  keys
}

// The regions a boundary redraws, each with the changed tags that belong to it,
// as `(key:, names:)` in the order the membership reports name the keys.
//
// A changed region inside another changed region is not one of them, because redrawing the
// outer one redraws it too, and the tags it holds belong to that outer one.
// The boundary crossfades the outer group and the inner one is redrawn inside it, so the two
// are one crossfade and the timings of both have to agree.
//
// The whole rendering, whose key is `none`, holds every region of the slide, so a boundary
// that redraws it is the one holder and every tag the boundary changes belongs to it.
#let changed-members(epochs, epoch, members) = {
  let parents = region-parents(members)
  let keys = changed-keys(epochs, epoch, members)
  let whole = none in keys
  let owner(key) = if whole { none } else { owner-of(parents, keys, key) }
  let changed = epochs.at(epoch).changed
  let holders = keys
    .filter(key => owner(key) == key)
    .map(key => (key: key, names: ()))
  for it in members {
    if it.kind != "tag" or it.name not in changed { continue }
    let at = holders.position(holder => holder.key == owner(it.key))
    if at != none and it.name not in holders.at(at).names {
      holders.at(at).names.push(it.name)
    }
  }
  holders
}

// The timing of every operation that changes one region at one boundary, in the order the
// operations were written, as `(name:, timing:)` pairs.
#let boundary-timings(epochs, epoch, holder) = {
  let timings = epochs.at(epoch).timings
  holder
    .names
    .map(name => timings
      .at(name, default: ())
      .map(timing => (
        name: name,
        timing: timing,
      )))
    .flatten()
}

// Refuse two operations that change one region at one boundary and disagree about when.
//
// A region crossfades once, so there is nothing for a precedence rule to pick between.
// Two bare tags are always two regions, each its own implicit one, so this refusal applies
// inside an explicit region and between two operations on one tag.
// The comparison is over an operation's timing as a whole rather than over one field of it,
// because a timing record may gain more fields.
//
// Which region a tag belongs to is a layout-time fact, so this reads the membership reports
// and runs where the other layout-informed refusals run, in a context block of its own after
// the slide.
// A panic that depends on `query` is only reported when it is raised there.
//
// Must be called in a context.
#let check-boundary-timings(index, epochs, members) = {
  for epoch in range(1, epochs.len()) {
    for holder in changed-members(epochs, epoch, members) {
      let timings = boundary-timings(epochs, epoch, holder)
      if timings.len() < 2 { continue }
      let first = timings.first()
      for other in timings.slice(1) {
        assert(
          other.timing == first.timing,
          message: "on slide "
            + str(index)
            + ", the operations on "
            + first.name
            + " and "
            + other.name
            + " change one region at one boundary and disagree about their timing, "
            + repr(first.timing)
            + " against "
            + repr(other.timing)
            + "; a region crossfades once, so there is nothing to choose between them: "
            + "give them the same timing, or put them in two regions",
        )
      }
    }
  }
}

// The groups a boundary redraws, as the browser addresses them, each with its timing.
//
// A key is animo's own way of naming a region, and a group in the output is addressed by a
// label, so the two are joined here from the reports of the sites that own their keys.
// A key whose site no rendering reported yet has no group and is left out, which is the
// same incompleteness `changed-members` has.
//
// The whole rendering is the holder with no key, and it has no group either: the runtime
// knows it as the rendering it is showing, and `none` is how the plan says so.
//
// The timing is the first of the region's operations, which is every one of them.
// A boundary whose operations disagree is refused after the slide, and this runs inside it,
// where a panic would be swallowed.
#let changed-groups(epochs, epoch, members) = {
  let groups = ()
  for holder in changed-members(epochs, epoch, members) {
    let found = if holder.key == none { none } else {
      members.find(it => it.group != none and it.key == holder.key)
    }
    if holder.key != none and found == none { continue }
    let group = if found == none { none } else { found.group }
    if group in groups.map(it => it.group) { continue }
    let timings = boundary-timings(epochs, epoch, holder)
    groups.push((
      group: group,
      timing: if timings.len() == 0 { default-timing } else {
        timings.first().timing
      },
    ))
  }
  groups
}
