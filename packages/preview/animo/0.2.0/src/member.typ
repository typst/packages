// SPDX-FileCopyrightText: 2026 Toon Verstraelen <Toon.Verstraelen@UGent.be>
// SPDX-License-Identifier: Apache-2.0

// Which region each site of a slide sits in, and which regions a boundary therefore crosses.
//
// Only layout knows which tags a region holds, because a region receives its body as opaque
// content, so this is not something the resolver can answer.
// Every tag site and every region reports itself where it is laid out, and the reports are
// read back with `query` after the slide.
//
// A boundary crosses the outermost regions that hold the tags the boundary changes,
// which follow from those reports and from the epoch the boundary starts.
// The HTML target places an epoch stack in every outermost region and none in the regions
// inside one, so such a region crosses a boundary as a whole, with everything inside it.
// The reports serve the refusals that are made after the slide.
// The browser finds the stacks a boundary crosses by itself, from the names of the tags laid
// out in them.
// The exception is a tag that becomes no group, whose region the plan names from the
// reports, because nothing in the output names it.

#import "transition.typ": written

// The label of the report that says which region a site belongs to.
#let member-label = label("animo-member")

// Report which region a tag or a region belongs to,
// as `(slide:, kind:, name:, key:, group:, parent:, groupless:)`.
//
// `key` is the region the site belongs to, and `parent` the one around the site,
// which differ for a region with a number and for a tag that forms an implicit region.
// `group` is the label that the group of the site carries in the output, and is `none` for a
// site that is not the region its key names.
// It is how a key becomes something the browser can address, because only the site that owns
// the key knows what it called itself.
// `groupless` says whether the site is a tag that becomes no group at all.
// A `metadata` element is layout-neutral wherever it sits.
#let member(view, kind, name, key, group: none, groupless: false) = [#metadata((
    slide: view.slide,
    kind: kind,
    name: name,
    key: key,
    group: group,
    parent: view.region.key,
    groupless: groupless,
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

// The outermost region above a key, which is the key itself for a region that sits in no
// other.
// That is the region that holds the epoch stack the key's content changes in.
#let outermost-of(parents, key) = {
  let above = parent-of(parents, key)
  while above != none {
    key = above
    above = parent-of(parents, key)
  }
  key
}

// The regions a boundary crosses, each with the changed tags that belong to it,
// as `(key:, names:)` in the order the membership reports name the tags.
//
// Each is an outermost region, and every changed tag inside it belongs to it, however deep.
// A region inside it is laid out once per rendering of its stack, so the two are one
// crossfade and the timings of both have to agree.
//
// Every tag whose content changes sits in a region, because a tag that has no box and that
// no region holds is refused where it is written.
// The answer is only as complete as `members`, because a tag reports from the renderings it
// is laid out in.
// A tag that only a later epoch lays out is therefore known once that epoch is rendered.
#let changed-members(epochs, epoch, members) = {
  let parents = region-parents(members)
  let changed = epochs.at(epoch).changed
  let holders = ()
  for it in members {
    if it.kind != "tag" or it.name not in changed or it.key == none { continue }
    let key = outermost-of(parents, it.key)
    let at = holders.position(holder => holder.key == key)
    if at == none {
      holders.push((key: key, names: (it.name,)))
    } else if it.name not in holders.at(at).names {
      holders.at(at).names.push(it.name)
    }
  }
  holders
}

// One field of every operation that changes one region at one boundary, in the order the
// operations were written, as `(name:, value:)` pairs.
//
// `field` is the key of the epoch that holds the field per name, which is `timings` or
// `transitions`.
#let boundary-values(epochs, epoch, holder, field) = {
  let values = epochs.at(epoch).at(field)
  holder
    .names
    .map(name => values
      .at(name, default: ())
      .map(value => (
        name: name,
        value: value,
      )))
    .flatten()
}

// Refuse two operations that change one region at one boundary and disagree about when, or
// about how the region crosses it.
//
// A region crosses a boundary once, with every region inside it, so there is nothing for a
// precedence rule to pick between.
// Two bare tags side by side are two regions, each an implicit one, so this refusal
// applies inside a region and between two operations on one tag.
// The comparison is over an operation's timing as a whole rather than over one field of it,
// because a timing record may gain more fields.
// A transition is compared as it was written, so `auto` and `crossfade()` are two answers,
// as are a duration of `auto` and a number equal to the `primitive-duration:` of the deck.
//
// Which region a tag belongs to is a layout-time fact, so this reads the membership reports
// and runs where the other layout-informed refusals run, in a separate context block after
// the slide.
// A panic that depends on `query` is only reported when it is raised there.
//
// Must be called in a context.
#let check-boundaries(index, epochs, members) = {
  for epoch in range(1, epochs.len()) {
    for holder in changed-members(epochs, epoch, members) {
      for (field, what, remedy, shown) in (
        ("timings", "their timing", "give them the same timing", repr),
        (
          "transitions",
          "their transition",
          "give them the same transition",
          written,
        ),
      ) {
        let values = boundary-values(epochs, epoch, holder, field)
        if values.len() < 2 { continue }
        let first = values.first()
        for other in values.slice(1) {
          assert(
            other.value == first.value,
            message: "on slide "
              + str(index)
              + ", the operations on "
              + first.name
              + " and "
              + other.name
              + " change one region at one boundary and disagree about "
              + what
              + ", "
              + shown(first.value)
              + " against "
              + shown(other.value)
              + "; a region crosses a boundary once, with every region inside it, "
              + "so there is nothing to choose between them: "
              + remedy
              + ", or put them in two regions that no other region holds",
          )
        }
      }
    }
  }
}

// The regions a boundary crosses for the tags it changes that become no group, as a
// dictionary from the label of the region's group to the name of the first such tag in it.
//
// The browser finds every other changed tag by its group inside the stack that holds it.
// A tag that becomes no group leaves nothing in the output to find, so the plan names the
// region for it, and the region crosses with the timing and the transition of that tag's
// operations, which are those of every operation that changes the region at the boundary.
// A region whose site no rendering reported has no group and is left out, which is the same
// incompleteness `changed-members` has, and the browser still finds that its renderings
// differ.
#let groupless-regions(epochs, epoch, members) = {
  let parents = region-parents(members)
  let changed = epochs.at(epoch).changed
  let regions = (:)
  for it in members {
    if not it.groupless or it.name not in changed or it.key == none { continue }
    let key = outermost-of(parents, it.key)
    let owner = members.find(other => other.group != none and other.key == key)
    if owner != none and owner.group not in regions {
      regions.insert(owner.group, it.name)
    }
  }
  regions
}
