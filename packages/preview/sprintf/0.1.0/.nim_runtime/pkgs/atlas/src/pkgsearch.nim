#
#           Atlas Package Cloner
#        (c) Copyright 2021 Andreas Rumpf
#
#    See the file "copying.txt", included in this
#    distribution, for details about the copyright.
#

import std / [json, os, sets, strutils, httpclient, uri]
import basic/[context, reporters, packageinfos]

type PkgCandidates* = array[3, seq[PackageInfo]]

proc determineCandidates*(pkgList: seq[PackageInfo];
                         terms: seq[string]): PkgCandidates =
  result[0] = @[]
  result[1] = @[]
  result[2] = @[]
  for pkg in pkgList:
    block termLoop:
      for term in terms:
        let word = term.toLower
        if word == pkg.name.toLower:
          result[0].add pkg
          break termLoop
        elif word in pkg.name.toLower:
          result[1].add pkg
          break termLoop
        else:
          for tag in pkg.tags:
            if word in tag.toLower:
              result[2].add pkg
              break termLoop

proc singleGithubSearch(term: string, fullSearch = false): JsonNode =
  when UnitTests:
    echo "SEARCH: ", term
    let filename = "query_github_" & term & ".json"
    let path = findAtlasDir() / "tests" / "test_data" / filename
    let node = json.parseFile(path)
    # In tests, mimic the real API shape and return the items array.
    result = node.getOrDefault("items")
  else:
    # For example:
    # https://api.github.com/search/repositories?q=weave+language:nim
    var client = newHttpClient()
    try:
      var searchUrl = "https://api.github.com/search/repositories?q=" & encodeUrl(term)
      if not fullSearch:
        searchUrl &= "+language:nim"

      let x = client.getContent(searchUrl)
      result = parseJson(x).getOrDefault("items")
      if result.kind != JArray:
        error "github search", "got bad results from GitHub"
        result = newJArray()
      # do full search and filter for languages
      if fullSearch:
        var filtered = newJArray()
        for item in result.items():
          let queryUrl = item["languages_url"].getStr
          let langs = client.getContent(queryUrl).parseJson()
          if langs.hasKey("Nim"):
            filtered.add item
        result = filtered

      if result.len() == 0:
        if not fullSearch:
          trace "github search", "no results found by Github quick search; doing full search"
          result = singleGithubSearch(term, fullSearch=true)
        else:
          trace "github search", "no results found by Github full search"
      else:
        trace "github search", "found " & $result.len() & " results on GitHub"
    except CatchableError as exc:
      error "github search", "error searching github: " & exc.msg
      # result = parseJson("{\"items\": []}")
      result = newJArray()
    finally:
      client.close()

proc githubSearch(seen: var HashSet[string]; terms: seq[string]) =
  for term in terms:
    let gs = singleGithubSearch(term)
    for j in items(gs):
      let p = PackageInfo(
        kind: pkPackage,
        name: j.getOrDefault("name").getStr,
        url: j.getOrDefault("html_url").getStr,
        downloadMethod: "git",
        tags: toTags(j.getOrDefault("topics")),
        description: j.getOrDefault("description").getStr,
        license: j.getOrDefault("license").getOrDefault("spdx_id").getStr,
        web: j.getOrDefault("html_url").getStr
      )
      if not seen.containsOrIncl(p.url):
        echo p

proc getUrlFromGithub*(term: string): string =
  var matches = 0
  result = ""
  for j in items(singleGithubSearch(term)):
    let name = j.getOrDefault("name").getStr
    if cmpIgnoreCase(name, term) == 0:
      result = j.getOrDefault("html_url").getStr
      inc matches
  if matches != 1:
    # ambiguous, not ok!
    result = ""

proc search*(pkgList: seq[PackageInfo]; terms: seq[string]) =
  var seen = initHashSet[string]()
  template onFound =
    info "Found package", $pkg
    seen.incl pkg.url
    break forPackage

  for pkg in pkgList:
    if terms.len > 0:
      block forPackage:
        for term in terms:
          let word = term.toLower
          # Search by name.
          if word in pkg.name.toLower:
            onFound()
          # Search by tag.
          for tag in pkg.tags:
            if word in tag.toLower:
              onFound()
    else:
      info("Using package", $pkg)
  githubSearch seen, terms
  if seen.len == 0 and terms.len > 0:
    info("No PackageInfo found", $terms)
