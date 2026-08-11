#import "state.typ": folio-init, folio-state
#import "guard.typ": section-guard
#import "audit.typ": data-audit-header, data-audit-orphans
#import "resolve.typ": nonempty

#import "../phases/initiation.typ": initiation
#import "../phases/planning.typ": planning
#import "../phases/execution.typ": execution
#import "../phases/closure.typ": closure
#import "../phases/custom.typ": custom
#import "../components/initiation.typ": cover
#import "pipeline.typ": pmbok-pipeline

#let project-doc(data: (:), config: (:), brand: (:)) = body => {
  let resolved-config = (
    audit: config.at("audit", default: false),
    cover: config.at("cover", default: auto),
    toc: config.at("toc", default: true),
    sections: config.at("sections", default: (:)),
    extra-sections: config.at("extra-sections", default: ()),
    extra-checks: config.at("extra-checks", default: ()),
  )

  show: rest => folio-init(
    data: data,
    config: resolved-config,
    brand: brand,
    rest,
  )

  context {
    let st = folio-state.get()

    // Process extra-sections
    let current-pipeline = pmbok-pipeline
    let extra-sections = st.config.at("extra-sections", default: ())

    for extra in extra-sections {
      let id = extra.at("id")
      let phase = extra.at("phase")
      let data-path = extra.at("data-path")
      let render = extra.at("render")
      let before = extra.at("before", default: none)
      let after = extra.at("after", default: none)

      // Check for ID collision
      if current-pipeline.any(p => p.section_id == id) {
        panic("Section ID collision in extra-sections: " + id)
      }

      let new-record = (
        phase: phase,
        section_id: id,
        data_path: data-path,
        render_fn: render,
      )

      if before != none {
        let idx = current-pipeline.position(p => p.section_id == before)
        if idx == none {
          panic("Anchor section_id not found for 'before': " + before)
        }
        current-pipeline = (
          current-pipeline.slice(0, idx)
            + (new-record,)
            + current-pipeline.slice(idx)
        )
      } else if after != none {
        let idx = current-pipeline.position(p => p.section_id == after)
        if idx == none {
          panic("Anchor section_id not found for 'after': " + after)
        }
        current-pipeline = (
          current-pipeline.slice(0, idx + 1)
            + (new-record,)
            + current-pipeline.slice(idx + 1)
        )
      } else {
        // Append to the end of its phase if no anchor
        let phase-entries = current-pipeline
          .enumerate()
          .filter(e => e.at(1).phase == phase)
        if phase-entries.len() > 0 {
          let insert-at = phase-entries.last().at(0) + 1
          current-pipeline = (
            current-pipeline.slice(0, insert-at)
              + (new-record,)
              + current-pipeline.slice(insert-at)
          )
        } else {
          current-pipeline = current-pipeline + (new-record,)
        }
      }
    }

    if st.config.audit == true {
      data-audit-header()
    }

    if (
      st.config.cover == true
        or (st.config.cover == auto and nonempty(st.data, "project.name"))
    ) {
      cover()
      pagebreak()
    }

    if st.config.toc == true {
      outline(title: "Table of Contents", indent: auto, depth: 3)
    }

    initiation(pipeline: current-pipeline)
    planning(pipeline: current-pipeline)
    execution(pipeline: current-pipeline)
    closure(pipeline: current-pipeline)
    custom(pipeline: current-pipeline)

    if st.config.audit == true {
      data-audit-orphans()
    }

    body
  }
}
