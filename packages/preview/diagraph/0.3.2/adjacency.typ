#import "internals.typ": render

#let inches = (
  "width",
  "height",
  "len",
  "lheight",
  "lwidth",
  "margin",
  "nodesep",
  "page",
  "size",
  "vertices",
)

#let value-to-str(key, value) = {
  if type(value) == length {
    if key in inches {
      str(value.to-absolute().inches())
    } else {
      str(value.to-absolute().pt())
    }
  } else if type(value) == color {
    "\"" + value.to-hex() + "\""
  } else if value == none {
    "none"
  } else if value == true {
    "true"
  } else if value == false {
    "false"
  } else {
    "\"" + str(value) + "\""
  }
}

#let dict-to-graph-args(args, sep: ";", parent: "") = {
  for (key, value) in args {
    (
      if type(value) == dictionary {
        if sep == "," {
          panic("Invalid argument for " + parent + "[" + key + "=...]")
        }
        key + "[" + dict-to-graph-args(value, sep: ",", parent: key) + "]"
      } else {
        (
          key
            + "="
            + if type(value) == array {
              "\"(" + value.map(value-to-str.with(key)).join(",") + ")\""
            } else {
              value-to-str(key, value)
            }
        )
      }
        + sep
    )
  }
}

#let create-nodes(min, max) = {
  range(min, max).map(str).join(";")
}

#let create-attributes(labels) = {
  labels
    .enumerate()
    .map(label => {
      if type(label.at(1)) == dictionary {
        let _ = label.at(1).remove("label", default: "")
        _ = label.at(1).remove("xlabel", default: "")
        str(label.at(0)) + "[" + dict-to-graph-args(label.at(1), sep: ",") + "]"
      }
    })
    .join("")
}

#let create-clusters(clusters) = {
  clusters
    .enumerate()
    .map(cluster => {
      let id = str(cluster.at(0))
      let nodes = cluster.at(1)
      "subgraph cluster_" + id + "{"
      if type(nodes) == dictionary {
        let _ = nodes.remove("label", default: "")
        let subnodes = nodes.remove("nodes")
        dict-to-graph-args(nodes)
        subnodes.map(str).join(";")
      } else {
        nodes.map(str).join(";")
      }
      "};"
    })
    .join("")
}

#let build-edges(adjacency, directed) = {
  adjacency
    .enumerate()
    .map(edges-list => {
      edges-list
        .at(1)
        .enumerate()
        .map(edge => {
          if edge.at(1) == none {
            ""
          } else {
            str(edges-list.at(0))
            if directed {
              " -> "
            } else {
              " -- "
            }
            str(edge.at(0)) + ";"
          }
        })
        .join("")
    })
    .join("")
}

#let adjacency(..args) = context {
  if args.pos().len() != 1 {
    panic("adjacency() requires one argument: an adjacency matrix")
  }
  let adjacency = args.at(0)
  let graph-params = args.named()
  let vertex-labels = graph-params.remove("vertex-labels", default: ())
  let directed = graph-params.remove("directed", default: true)
  let clusters = graph-params.remove("clusters", default: ())
  let debug = graph-params.remove("debug", default: false)
  let clip = graph-params.remove("clip", default: true)

  render(
    if directed {
      "digraph"
    } else {
      "graph"
    }
      + "{"
      + dict-to-graph-args(graph-params)
      + create-nodes(
        0,
        adjacency.len(),
      )
      + ";"
      + create-clusters(clusters)
      + create-attributes(vertex-labels)
      + build-edges(adjacency, directed)
      + "}",
    debug: debug,
    clip: clip,
    labels: name => {
      let id = int(name)
      if id < vertex-labels.len() {
        let label = vertex-labels.at(id)
        if type(label) == dictionary {
          label.at("label", default: "")
        } else {
          label
        }
      } else {
        ""
      }
    },
    xlabels: name => {
      let id = int(name)
      if id < vertex-labels.len() {
        let label = vertex-labels.at(id)
        if type(label) == dictionary {
          label.at("xlabel", default: none)
        } else {
          none
        }
      } else {
        none
      }
    },
    edges: (name, edges) => {
      let id = int(name)
      let result = (:)
      for edge in edges {
        let edge-id = int(edge)
        let label = adjacency.at(id).at(edge-id)
        if label != none {
          result.insert(edge, [#label])
        }
      }
      result
    },
    clusters: name => {
      let id = int(name.split("_").at(1))
      if id < clusters.len() {
        let cluster = clusters.at(id)
        if type(cluster) == dictionary {
          cluster.at("label", default: none)
        } else {
          none
        }
      } else {
        none
      }
    },
  )
}

