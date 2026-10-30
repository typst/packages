// SPDX-FileCopyrightText: 2026 Toon Verstraelen <Toon.Verstraelen@UGent.be>
// SPDX-License-Identifier: Apache-2.0

// A tag site: content the timeline can address by name.
//
// The same name may be used several times in one slide, and the timeline then addresses
// all of them together, as if they were one element.
// The same name in two slides does not interfere, because a tag reads the view of the
// slide it sits in and nothing else.
//
// A tag emits the same structure in every state of an epoch and in both targets, and only
// the parameters inside it change.
// The `move`, `scale` and `hide` between the tag's two slots are layout-neutral,
// so nothing moves between two states except what the timeline moves.
// The HTML target applies no display state at all.
// One frame covers every state of the slide, and the browser runtime puts a state's
// display state on the groups as CSS.
//
// Between epochs the content itself may change, and a tag whose content changes forms an
// implicit region.
// Its outer slot is fixed at the largest extent over the epochs, so that the change stays
// inside the box of the tag and nothing around it moves.
// A tag with no box has no extent to fix, so its content may only change inside a region.

#import "canvas.typ": anchor-marker, corner-marker, site-marker
#import "member.typ": member
#import "plan.typ": ask, pristine, provide, varies
#import "region.typ": block-region, footprint-label
#import "site.typ": (
  check-container-child, check-name, describe, display-of, displayed,
)
#import "stack.typ": inline-stack
#import "wrap.typ": choose-wrapper, outer-of, slots

// What a tag site lays out in one epoch, with its wrappers applied, or `none` for nothing.
//
// The wrappers go around the content and inside both slots,
// so that a wrapper that draws ink moves and scales with the element.
// `apply` wraps outermost-last, which is the order of the list.
#let content-of(name, body, epoch) = {
  let resolved = epoch.tags.at(name, default: pristine)
  let laid-out = if resolved.source == "body" {
    body
  } else if resolved.source == "replacement" {
    resolved.body
  } else {
    none
  }
  if laid-out != none {
    resolved.wrappers.fold(laid-out, (it, wrap) => wrap(it))
  }
}

// One rendering of a tag site, for the view it is handed.
//
// Every rendering reports which region the site belongs to, even one that lays nothing out,
// because that is what says which regions a change of its content redraws.
#let render(name, body, wrapper, view) = {
  let changing = varies(view.epochs, name)
  // The view of content that is not laid out the same in every epoch.
  // `base` is the view the content sits under, which for a wrapped tag site is a view in
  // which the enclosing tags include the tag itself.
  let changeable(base, region) = (..base, region: (..region, stable: false))
  if wrapper == none {
    if name in view.continuous {
      panic(
        "the timeline addresses the tag "
          + name
          + " with a continuous primitive, but its wrap is none, "
          + "so it becomes no group that a browser could move, scale, reveal or hide, "
          + "or pan to",
      )
    }
    // Such a tag has no box and no separate footprint,
    // so the region that bounds it is one around it, and a change of its content needs one.
    // Without it the change would be confined to no area, and the HTML target, which lays
    // out what lies outside every region once, would have no rendering to show it in.
    if changing and view.region.key == none {
      panic(
        "the timeline changes the content of the tag "
          + name
          + " with a structural primitive, but its wrap is none and no region holds it; "
          + "a tag whose content changes needs a box that the change stays inside, "
          + "so give it wrap: auto, box or block, or put a region around it",
      )
    }
    let payload = content-of(name, body, view.epochs.at(view.epoch))
    return {
      member(view, "tag", name, view.region.key, groupless: true)
      if changing and payload != none {
        provide(changeable(view, view.region), payload)
      } else { payload }
    }
  }
  let current = display-of(name, view)
  // What this site adds to the tags enclosing whatever it lays out.
  // Only a tag the timeline addresses with a continuous primitive can transform its content,
  // so a tag it never addresses hands its body the view it was given unchanged.
  let inside = if name in view.continuous {
    (..view, within: view.within + (name,))
  } else { view }
  if view.state == none {
    // The HTML target, where the site reports itself so that the slide can check what its
    // timeline asks against the sites its rendering produced.
    site-marker(view, name)
  }
  // The corner a `pan(relto:)` reads on paper.
  // The HTML target has no position introspection, and the browser reads the group's
  // origin there instead.
  let anchor = if view.state != none { anchor-marker(view, name) }
  // The far corner of the box a `scale` grows, which the browser reads to scale about the
  // centre of that box, as the paged outputs do.
  let corner = if view.state == none { corner-marker }

  if not changing or view.region.explicit {
    // Content that never changes lays out the same by itself, and content inside an explicit
    // region changes inside the region's footprint, because the region reflows around the
    // change.
    member(view, "tag", name, view.region.key)
    let payload = content-of(name, body, view.epochs.at(view.epoch))
    if payload == none {
      // Nothing is laid out here, not even an empty wrapper, which would still take a
      // block's spacing.
      // The report keeps the site checked on paper and marks no corner to pan to.
      if view.state != none { site-marker(view, name) }
    } else {
      let payload = if changing {
        provide(changeable(inside, view.region), payload)
      } else if inside != view { provide(inside, payload) } else { payload }
      slots(
        name,
        wrapper,
        anchor: anchor,
        corner: corner,
        payload,
        display: current,
      )
    }
  } else {
    // The implicit region. Every epoch is laid out with a separate view, so that the tags
    // nested in it resolve their content for that epoch as well.
    // In the HTML target it places an epoch stack, as an explicit region does.
    let key = (kind: "tag", name: name)
    let nested = (
      ..changeable(inside, (key: key, explicit: false)),
      stack: false,
    )
    let rendering(epoch) = {
      let payload = content-of(name, body, view.epochs.at(epoch))
      if payload != none {
        // The container of a rendering hugs it, so the corner goes beside the rendering.
        let rendered = displayed(current, wrapper(payload))
        provide((..nested, epoch: epoch), [#rendered#corner])
      }
    }
    let renderings = range(view.epochs.len()).map(rendering)
    let container(sized, inner, footprint) = {
      // The box of the tag is the region this key names, and the label on it is what the
      // runtime crossfades when the content inside changes.
      member(view, "tag", name, key, group: name)
      [#sized({
          anchor
          [#metadata((
              slide: view.slide,
              name: name,
              region: key,
              epoch: view.epoch,
              ..footprint,
            ))#footprint-label]
          inner
        })#label(name)]
    }
    let stacked = view.stack and renderings.len() > 1
    if outer-of(name, wrapper) == box {
      if stacked {
        inline-stack("epoch", renderings, none, container: container)
      } else {
        inline-stack(none, renderings, view.epoch, container: container)
      }
    } else {
      block-region(renderings, view.epoch, container, stacked: stacked)
    }
  }
}

/// Mark a part of a slide so that the timeline can address it by name.
///
/// - name (str): What the timeline refers to.
/// - body (content): What is marked.
/// - wrap (auto, function, none): The container the tag site becomes: `auto`, `box`,
///   `block`, `none` or a function.
/// -> content
#let tag(name, body, wrap: auto) = {
  check-name("a tag", name)
  if type(body) != content {
    // A value that is not content is a value animo cannot reach.
    // It carries no marker, so it reaches no view, and a stream of cetz draw commands is
    // built where it is written, before any show rule or `context` exists that could
    // resolve it for an epoch.
    // Handing it back untouched would make every primitive a silent no-op on it, and the
    // author would meet the mistake in the rendered output, far from the call that caused
    // it.
    panic(
      "the body of the tag "
        + name
        + " is not content, but "
        + describe(body)
        + "; a stream of cetz draw commands is built where it is written, "
        + "before any show rule reaches it, so animo can never resolve it for an epoch: "
        + "tag a cetz content() element, or tag the whole canvas "
        + "and replace it with one drawn differently",
    )
  }
  check-container-child(
    "the tag " + name,
    body,
    "tag(" + repr(name) + ")[..]",
    "tag(" + repr(name) + ", block(fill: .., width: 100%, height: 100%)[..])",
  )
  context {
    let wrapper = choose-wrapper(name, body, wrap)
    ask("the tag " + name, view => render(name, body, wrapper, view))
  }
}
