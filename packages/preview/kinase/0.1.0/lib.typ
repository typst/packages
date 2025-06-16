/// Helper for matching Mails. This one matches every 'mailto:' link
#let l-mailto() = regex("mailto:.*")
/// Helper for matching Mails. This one is more strict and matches only, if a mail is an address that is structurally correct.
#let l-mailto-strict() = regex("^mailto:.*@.*\..*")

/// Helper to match phone numbers. Note that these are country dependent.
///
/// - region (string): ISO 3166-1 alpha-2 region string. Currently supported are US, DE, FR, GB and limited to non mobile.
#let l-phone(region: "US") = {
  if region == "US" {
    return regex(`^(?:\+?1)?[-.\s]?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}$`.text)
  } else if region == "DE" {
    return regex(`^(?:\+?49)?[-.\s]?\(?(?:0|\d{2})\)?[-.\s]?\d{1,5}[-.\s]?\d{1,5}$`.text)  
  } else if region == "GB" {
    return regex(`^(?:\+?44)?[-.\s]?\(?(?:0|\d{2})\)?[-.\s]?\d{1,4}[-.\s]?\d{1,4}[-.\s]?\d{1,4}$`.text)
  } else if region == "FR" {
    return regex(`^(?:\+?33)?[-.\s]?\(?(?:0|\d{1,2})\)?[-.\s]?\d{1,4}[-.\s]?\d{1,4}[-.\s]?\d{1,4}$`.text) 
  } 
  panic("Code invalid or not supported") 
  //TODO add more regions
}

/// Helper to match urls. Matches any well formed url around the base url. E.g. if base is 'google.com', 'https://google.com/docs' and 'http://google.com:8080' are matched as well.
///
/// - base (string): Base url of a hostname. This does not check the url for legality. Though if it is, only legal urls are matched. By default this matches any url like link. Care that you have to escape any symbols with special meaning (e.g. 'typst.app' #sym.arrow `regex("typst\.app")`)
#let l-url(base: ".*?\..*?") = {
  regex(`^(https?://)?(www\.)?`.text + base + `([/][-a-zA-Z0-9@:%._\+~#=]{1,256})?(:\d{1,5})?`.text)
}

/// Array of tuples, consisting of the matcher and corresponding styling function. Care that the order of insertion is the order in which the matchers are evaluated. In practice, this means you should place the more specific matches above more generic ones.
#let link-style = state("now", ())

/// Update the styling array. Entries are inserted. If before and after are none, entries are appended to the end. If a key already exist, the entry is replaced. The order is kept intact.
///
/// - key (regex, string): Matcher for the dest field of th e link function. If the key is a string, it is matched if it is contained. If it is a regex expression, it is matched if the expression produces at least one match.
/// - value (function): A function that takes content and returns content.
/// - before (regex, string): Insert before another key. Excludes after.
/// - after (regex, string): Insert after another key. Excludes before.
/// -> none
#let update-link-style(key: none, value: none, before: none, after: none) = {
  if before != none and after != none {
    panic("before and after exclude each other!")
  }
  link-style.update(arr => {
    let i = arr.map(e => e.at(0)).position(it => it == key)
    if i == none {
      if before != none {
        let i = arr.map(e => e.at(0)).position(it => it == before)
        if i == none {
          panic("before key does not exist")
        }
        arr.insert(i, (key, value))
      } else if after != none {
        let i = arr.map(e => e.at(0)).position(it => it == after)
        if i == none {
          panic("after key does not exist")
        }
        if arr.len() == i {
          arr.push((key, value))
        } else {
          arr.insert(i + 1, (key, value))
        }
      } else {
        arr.push((key, value))
      }
    } else {
      let f = arr.remove(i)
      arr.insert(i, (key, value))
    }
    arr
  })
  none
}

/// Removes an entry from the link-style array, if it exists.
///
/// - key (regex, string): Matcher for the dest field of th e link function. If the key is a string, it is matched if it is contained. If it is a regex expression, it is matched if the expression produces at least one match.
/// -> none
#let remove-update-style(key: none) = {
  link-style.update(arr => {
    let i = arr.map(e => e.at(0)).position(it => it == key)
    if i != none {
      arr.remove(i)
    }
    arr
  })
}


/// Function for creating applying the link-style.
///
/// - body (content): The document body.
#let make-link(body) = {
  show link: it => {
    context {
      let state = link-style.final()
      if type(it.dest) == "string" {
      for p in state {
        let match = p.at(0)
        let match-type = type(match)
        if match-type == "string" and it.dest.contains(match) {
          return p.at(1)(it.body)
        } else if match-type == "regex" {
          if it.dest.match(match) != none {
            return p.at(1)(it.body)
          } 
        }
      }
      } 
      it 
    }
  }
  body
}
