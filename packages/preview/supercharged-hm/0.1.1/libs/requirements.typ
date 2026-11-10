// Copyright 2024 Felix Schladt https://github.com/FelixSchladt

#import "@preview/drafting:0.2.2": *
#import "@preview/glossarium:0.5.9": *
#import "@preview/linguify:0.5.0": *

#import "utils.typ": *
#import "stringify.typ": *

#import "../lang.typ": *

// ----------------------------------------------------------------------------------
// Label Registry
// ----------------------------------------------------------------------------------

#let label-registry = state("label-reg", ())

#let _add_req_label(title) = {
  context {
    let name = "req_" + plain-text(title).replace(" ", "_")
  
    let dup = false
    
      let labels = label-registry.get()
      while name in labels {
        if dup {
          name = name.trim("_" + name.last(), at: end, repeat: false) + "_" + str(int(name.last()) + 1)
          continue
        }
        name = name + "_1"
        dup = true
    }
  
    label-registry.update(
      label-reg => {
        label-reg.push(name.replace(" ", "_"))
        label-reg
      } 
    )
  }
}

#let _show_req_labels() = {
  context {
    let labels = label-registry.get()
    for label in labels {
      label + " "
    }
  }
}

#let _get_latest_req_label() = {
  let labels = label-registry.get()
  str(labels.last())
}


// ----------------------------------------------------------------------------------
// Requirements
// ----------------------------------------------------------------------------------

#let requirements(
  functional-chapter-description: str,
  functional:    (
    (
      title: str, 
      description: str, 
      authors: (), 
      tracebility: str, 
      subrequirements: ()
    ),
  ), 
  non-functional-chapter-description: str,
  nonfunctional: (
    (
      title: str, 
      description: str, 
      authors: (), 
      tracebility: str, 
      subrequirements: ()
    ),
  )
) = {
  let requirement(
    title, 
    description, 
    functional, 
    tracebility: str, 
    authors: (), 
    subrequirements: ()
  ) = (
    title: title,
    authors: authors,
    description: description,
    tracebility: tracebility,
    functional: functional,
    subrequirements: subrequirements
  )

  let get_numbering(prenum, ctr, total_reqs_ctr) = {
    let ctr_dep = str(total_reqs_ctr).len()
    let ctr_str = str(ctr)
    while (ctr_str.len() != ctr_dep) {
      ctr_str = "0" + ctr_str
    }
    return prenum + ctr_str
  }

  let display_reqs(reqs, ctr, total_num, prenumbering) = {
    for req in  reqs{
      ctr += 1
      let numbering = get_numbering(prenumbering, ctr, total_num)

      // Assign label
      _add_req_label(req.title)

      // Display requirement
      context [
        #show heading.where(level: 4): it => {
          block(it.body)
        }
        #set par(justify: false)
        #heading(level:4, supplement: none, "[" + numbering + "] " + req.title)
        #label(_get_latest_req_label())
      ]
      
      // Show authors if provided
      if req.authors.len() > 0{
        authors_list(req.authors)
      }
      
      req.description

      linebreak()
      req.tracebility

      if req.subrequirements.len() > 0 {
        display_reqs(req.subrequirements, 0, req.subrequirements.len(), numbering + ".")
      }
    }
  }

  let convert_to_requirements(reqs) = {
    let out_reqs = ()
    for req in reqs {
      let subreq = ()
      if "subrequirements" in req {
        subreq = convert_to_requirements(req.at("subrequirements"))
      }

      let tracebility = ""
      if "tracebility" in req {
        tracebility = req.at("tracebility")
      }

      let authors = ()
      if "authors" in req {
        authors = req.at("authors")
      }
      
      let x = type(req)

      out_reqs.push(
        requirement(
          req.at("title"), 
          req.at("description"), 
          tracebility: tracebility, 
          false, 
          authors: authors, 
          subrequirements: subreq,
        )
      )
    }
    return out_reqs
  }

  let freqs = convert_to_requirements(functional)
  let nreqs = convert_to_requirements(nonfunctional)

  let ctr = 0
  for (title, lbl, description, requirements) in (
    (
      linguify("lib_req_func-req", from: lang-db), 
      <req_funcional>, 
      functional-chapter-description, 
      freqs
    ), (
      linguify("lib_req_nonfunc-req", from: lang-db), 
      <req_nonfunctional>, 
      non-functional-chapter-description, 
      nreqs
    )
  ){
    [#[== #title] #lbl]
    description

    display_reqs(requirements, ctr, nreqs.len() + freqs.len(), "R")
    
    ctr+= requirements.len()
  }
}
