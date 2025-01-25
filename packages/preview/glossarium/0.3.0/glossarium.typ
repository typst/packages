/* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.*/

// glossarium figure kind
#let __glossarium_figure = "glossarium_entry"
// prefix of label for references query
#let __glossary_label_prefix = "glossary:"
// global state containing the glossary entry and their location
#let __glossary_entries = state("__glossary_entries", (:))

#let __query_labels_with_key(loc, key, before: false) = {
  if before {
    query(selector(label(__glossary_label_prefix + key)).before(loc, inclusive: false), loc)
  } else {
    query(selector(label(__glossary_label_prefix + key)), loc)
  }
}

// Reference a term
#let gls(key, suffix: none, long: none, display: none) = {
  context {
    let __glossary_entries = __glossary_entries.final(here())
    if key in __glossary_entries {
      let entry = __glossary_entries.at(key)
      
      let gloss = __query_labels_with_key(here(), key, before: true)
      
      let is_first = gloss == ()
      let entlong = entry.at("long", default: "")
      let textLink = if display != none {
        [#display]
      } else if (is_first or long == true) and entlong != [] and entlong != "" and long != false {
        [#entry.short#suffix (#emph(entlong))]
      } else {
        [#entry.short#suffix]
      }
      
      [#link(label(entry.key), textLink)#label(__glossary_label_prefix + entry.key)]
    } else {
      text(fill: red, "Glossary entry not found: " + key)
    }
  }
}

// reference to term with pluralisation
#let glspl(key) = gls(key, suffix: "s")

// show rule to make the references for glossarium
#let make-glossary(body) = {
  show ref: r => {
    if r.element != none and r.element.func() == figure and r.element.kind == __glossarium_figure {
      // call to the general citing function
      gls(str(r.target), suffix: r.citation.supplement)
    } else {
      r
    }
  }
  body
}

#let __normalize-entry-list(entry_list) = {
  let new-list = ()
  for entry in entry_list {
      new-list.push(
        (
          key: entry.key,
          short: entry.short,
          long: entry.at("long", default: ""),
          desc: entry.at("desc", default: ""),
          group: entry.at("group", default: ""),
        ),
      )
    }
    return new-list
}

#let print-glossary(entry_list, show-all: false, disable-back-references: false, enable-group-pagebreak: false) = {
  let entries = __normalize-entry-list(entry_list)
  __glossary_entries.update(x => {
    for entry in entry_list {
      x.insert(
        entry.key,
        entry,
      )
    }
    
    x
  })
  
  let groups = entries.map(x => x.at("group", default: "")).dedup()
  // move no group to the front
  groups.insert(0, "")
  groups.pop()
  
  for group in groups.sorted() {
    if group != "" [#heading(group, level: 2) ]
    for entry in entries.sorted(key: x => x.key) {
      if entry.group == group {
        [
          #show figure.where(kind: __glossarium_figure): it => it.caption
          #par(hanging-indent: 1em, first-line-indent: 0em)[
            #figure(
              supplement: "",
              kind: __glossarium_figure,
              numbering: none,
              caption: {
                context {
                  let term_references = __query_labels_with_key(here(), entry.key)
                  if term_references.len() != 0 or show-all {
                    let desc = entry.at("desc", default: "")
                    let long = entry.at("long", default: "")
                    let hasLong = long != "" and long != []
                    let hasDesc = desc != "" and desc != []
                    {
                      set text(weight: 600)
                      if hasLong {
                        emph(entry.short) + [ -- ] + entry.long
                      } else {
                        emph(entry.short)
                      }
                    }
                    if hasDesc [: #desc ] else [. ]
                    if disable-back-references != true {
                      term_references.map(x => x.location()).sorted(key: x => x.page()).fold(
                        (values: (), pages: ()),
                        ((values, pages), x) => if pages.contains(x.page()) {
                          (values: values, pages: pages)
                        } else {
                          values.push(x)
                          pages.push(x.page())
                          (values: values, pages: pages)
                        },
                      ).values.map(x => link(x)[#numbering(x.page-numbering(), ..counter(page).at(x))]).join(", ")
                    }
                  }
                }
              },
            )[] #label(entry.key)
          ]
          #parbreak()
        ]
      }
    }
    if enable-group-pagebreak {pagebreak(weak: true)} 
  }
};
