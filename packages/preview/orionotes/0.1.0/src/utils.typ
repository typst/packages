// LTeX: language=it-IT
#let get-auth-str(authors, pre-authors) = {
  let many = type(authors) == array and authors.len() > 1
  let auths-str = if type(authors) == str { authors } else { authors.join(", ") }

  let auths-pre = if type(pre-authors) == str { pre-authors }
    else if many { pre-authors.at("plur") }
    else { pre-authors.at("sing") }

  return [#auths-pre: #auths-str]
}

#let get-prof-str(profs, pre-profs) = {
  let many = type(profs) == array and profs.len() > 1
  let profs-str = if type(profs) == str { profs } else { profs.join(", ") }

  let profs-pre = if type(pre-profs) == str { pre-profs }
    else if many { pre-profs.at("plur") }
    else { pre-profs.at("sing") }

  return [#profs-pre: #profs-str]
}
