#let _do_range(s1: str, s2: str) = {
  let res = ("",)
  let rgx = regex("([0-9]+|[A-Z]+|[a-z]+)")
  let s1_r = s1.matches(rgx).map(it => it.captures.at(0))
  let s2_r = s2.matches(rgx).map(it => it.captures.at(0))


  if (s1_r.len() != s2_r.len()) {
    return false
  }
  if (s1_r.join() != s1 or s2_r.join() != s2) {
    return false
  }

  let index = 0
  while index < s1_r.len() {
    let part1 = s1_r.at(index)
    let part2 = s2_r.at(index)
    index += 1

    if (part1.match(regex("^-?\d+$")) != none and part2.match(regex("^-?\d+$")) != none) {
      let n1 = int(part1)
      let n2 = int(part2)
      if (n1 > n2) { return false }
      res = res
        .map(
          r => range(n1, n2 + 1).map(z => r + str(z)),
        )
        .flatten()
    } else if (
      (part1.match(regex("[a-z]+")) != none and part2.matches(regex("[a-z]+")) != none)
        or (part1.match(regex("[A-Z]+")) != none and part2.matches(regex("[A-Z]+")) != none)
    ) {
      if (part1.len() != part2.len()) {
        return false
      }

      let is_lower = (part1.match(regex("[a-z]+")) != none and part2.matches(regex("[a-z]+")) != none)
      let (aA, zZ) = if is_lower { ("a", "z") } else { ("A", "Z") }
      let index = 0
      while index < part1.len() {
        let u1 = part1.at(index).to-unicode()
        let u2 = part2.at(index).to-unicode()
        if (u1 > u2 and index == 0) {
          return false
        }
        if (res.len() == 1) {
          res = range(u1, u2 + 1).map(v => str.from-unicode(v))
        } else {
          res = res
            .enumerate()
            .map(r => if (r.at(0) == 0) {
              range(u1, zZ.to-unicode() + 1)
            } else if (r.at(0) == res.len() - 1) {
              range(aA.to-unicode(), u2 + 1)
            } else {
              range(aA.to-unicode(), zZ.to-unicode() + 1)
            }.map(u => r.at(1) + str.from-unicode(u)))
            .flatten()
        }
        index += 1
      }
    } else {
      return false
    }
  }
  return res
}

#let _construct_node(content: none) = {
  return (content: content)
}


/*
 * A: xxx; A.Z; A.Z - B;
 */

#let _token = (
  NULL: 0,
  NAME: 1,
  COMMA: 2,
  DOT: 3,
  COLON_EXP: 4,
  SIM_ARROW: 5,
  EOF: 6,
  ERR: 7,
  ARROW: 8,
  NODE_DETAIL: 9,
)

#let _interpret-edge-or-node-desc(desc) = {
  desc = desc.replace("\\,", "_inner_sym_1_").replace("\\:", "_inner_sym_2_")

  let fields = desc.split(",").filter(it => it != "")
  if fields.any(it => it.matches(":").len() > 1) {
    return false
  }

  let res = (
    fields
      .filter(it => it.find(":") == none)
      .map(
        it => it.trim().replace("_inner_sym_1_", ",").replace("_inner_sym_2_", ":"),
      ),
    fields
      .filter(it => it.find(":") != none)
      .map(
        it => it
          .split(":")
          .map(
            it => it.trim().replace("_inner_sym_1_", ",").replace("_inner_sym_2_", ":"),
          ),
      )
      .to-dict(),
  )
  return res
}

#let _get_nxt_tk(st: str) = {
  // lexer
  // 0: null
  // 1: name
  // 2: comma
  // 3: .
  // 4: :
  // 5: -
  // 5: sim_arrow: -,
  // 6: END
  // 7: err
  // 8: arrow: --
  st = st.trim()
  if (st == "") { return (_token.EOF, "", "") }
  st += " " // dummy

  let token_type = _token.NULL
  let info = ""
  let char = st.at(0)
  if (char == ".") {
    token_type = _token.DOT
  } else if (char == "-") {
    // detail arrow
    if (st.slice(1).find("-") != none) {
      token_type = _token.ARROW
      let (text, end) = st.slice(1).match(regex(".{0,}-"))
      text = text.slice(0, -1)
      st = st.slice(1 + end - 1) // +1 is first "-", -1 is end "-"
      info = _interpret-edge-or-node-desc(text)
      if (type(info) == bool) {
        return (_token.ERR, info, st)
      }
      if not st.starts-with("-") {
        token_type = _token.ERR
        return (token_type, info, st)
      }
      st = st.slice(1)
      return (token_type, info, st)
    }
    // simple arrow
    token_type = _token.SIM_ARROW
  } else if char == ">" or char == "<" {
    token_type = _token.ARROW
    st = st.slice(1)
    return (
      token_type,
      ((if char == ">" { "\"->\"" } else { "\"<-\"" },), (:)),
      st,
    )
  } else if (char == ":") {
    token_type = _token.COLON_EXP
    return (token_type, st.slice(1).trim(), "")
  } else if (char == ",") {
    token_type = _token.COMMA
  } else if (char.matches(regex("[A-Za-z0-9_]")).len() == 1) {
    token_type = _token.NAME
    let index = 0
    while index < st.len() and char.matches(regex("[A-Za-z0-9_]")).len() == 1 {
      info += char
      index += 1
      char = st.at(index)
    }
    st = st.slice(index - 1)
  } else {
    // err char
    token_type = _token.ERR
  }
  st = st.slice(1)
  st.trim()
  return (token_type, info, st)
}


#let _parse_of_node_ids(st: str, names: ()) = {
  let (token_type, name, st) = _get_nxt_tk(st: st)
  if (token_type == _token.NAME) {
    let mid_res = _get_nxt_tk(st: st)
    let (nxt_token_type, nxt_name, _) = mid_res
    if (nxt_token_type == _token.DOT) {
      // range
      st = mid_res.at(2)
      let (nnxt_token_type, nnxt_name, _st) = _get_nxt_tk(st: st)
      st = _st
      if (nnxt_token_type != _token.NAME) {
        return false
      }
      // do range
      names += _do_range(s1: name, s2: nnxt_name)
      if (type(names) == bool) {
        return false
      }
      let nxt_res = _get_nxt_tk(st: st)
      let (nnxt_tk_ty, _, _st) = nxt_res
      if (nnxt_tk_ty == _token.COMMA) {
        st = _st
        return _parse_of_node_ids(names: names, st: st)
      }
    } else if (nxt_token_type == _token.COMMA) {
      st = mid_res.at(2)
      names += (name,)
      return _parse_of_node_ids(names: names, st: st)
    } else {
      names += (name,)
    }
  } else {
    return false
  }
  return (names, st)
}


#let _process_st(st: str, nodes: dictionary, edges: array, meta-info: dictionary) = {
  // metainfo


  let firstRes = _parse_of_node_ids(st: st)
  if (type(firstRes) == bool) { return false }
  for new_name in firstRes.at(0) {
    nodes.insert(
      new_name,
      nodes.at(new_name, default: _construct_node()),
    )
  }
  st = firstRes.at(1)

  // middle
  let (tk_type, mid_content, _st) = _get_nxt_tk(st: st)
  st = _st
  if (tk_type == _token.EOF) {
    return (nodes, edges)
  } else if (tk_type == _token.COLON_EXP) {
    for new_name in firstRes.at(0) {
      nodes.insert(new_name, (
        content: if (nodes.at(new_name).content == none) {
          mid_content.replace("|_name|", new_name)
        } else {
          nodes.at(new_name).content + "\n" + mid_content.replace("|_name|", new_name)
        },
      ))
    }

    let (tk_ty, _, _) = _get_nxt_tk(st: st)
    if (tk_ty != _token.EOF) {
      return false
    }
    return (nodes, edges)

    // last
  } else if (tk_type == _token.ERR) {
    return false

    // process arrow content
  } else if (tk_type == _token.SIM_ARROW or tk_type == _token.ARROW) {
    let ed_info = ((), (:))
    if tk_type == _token.ARROW {
      ed_info = mid_content
    }
    let res = _parse_of_node_ids(st: st)
    if (type(res) == bool) { return false }
    let (nnew_names, _st) = res

    st = _st

    for nn_name in nnew_names {
      // add to nodes
      nodes.insert(
        nn_name,
        nodes.at(nn_name, default: _construct_node()),
      )
      for pre_name in firstRes.at(0) {
        if pre_name == nn_name and meta-info.no-loop {
          continue
        }
        edges.push(
          (
            pre_name,
            nn_name,
            (
              ed_info
                .at(0)
                .map(
                  v => eval(v.replace("|_from|", pre_name).replace("|_to|", nn_name)),
                ),
              ed_info
                .at(1)
                .pairs()
                .map(
                  p => (
                    p.at(0).replace("|_from|", pre_name).replace("|_to|", nn_name),
                    eval(p.at(1).replace("|_from|", pre_name).replace("|_to|", nn_name)),
                  ),
                )
                .to-dict(), // dict
            ),
          ),
        )
        if not meta-info.multi-edge {
          edges = edges.dedup(key: v => {
            return (v.at(0), v.at(1)).sorted()
          })
        }
      }
    }

    let (tk_ty, _, _) = _get_nxt_tk(st: st)
    if (tk_ty != _token.EOF) {
      return false
    }
    return (nodes, edges)
  } else {
    return false
  }
}

#let _mete-info-lookup = (
  noloop: "no-loop",
  multi-edge: "multi-edge",
)
#let _parse-meta-info(st: str, pre: dictionary) = {
  if st in _mete-info-lookup {
    pre.insert(_mete-info-lookup.at(st), true)
    return (true, pre)
  } else {
    return (false, pre)
  }
}

#let h-graph-parser(code) = {
  let sentences = code.trim().split(";").map(it => it.trim()).filter(it => it != "")
  let nodes = (:)
  let edges = ()
  let render_args = (:)
  let meta-info-std = (
    no-loop: false,
    multi-edge: false,
  )
  let meta-info = meta-info-std

  for (index, st) in sentences.enumerate() {
    // if it is meta-info, parse it, otherwise use _process_st
    if st == "----" {
      meta-info = meta-info-std
    } else if st.starts-with("@") {
      let is-ok = true
      (is-ok, meta-info) = _parse-meta-info(st: st.slice(1), pre: meta-info)
      if not is-ok {
        return (false, [Error when processing line #{ index + 1 }: #highlight(sentences.at(index))])
      }
    } else if (st.trim().at(0) == "#") {
      let (k, v) = st.slice(1).split(":").slice(0, 2).map(v => v.trim())
      render_args.insert(k, v)
    } else {
      let res = _process_st(
        st: st,
        nodes: nodes,
        edges: edges,
        meta-info: meta-info,
      )
      if (type(res) == bool) {
        return (false, [Error when processing line #{ index + 1 }: #highlight(sentences.at(index))])
      } else {
        (nodes, edges) = res
      }
    }
  }
  return (nodes, edges, render_args)
}





