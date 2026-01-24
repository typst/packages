// citeproc-typst - Text Handler
//
// Handles <text> CSL element.

#import "../core/mod.typ": finalize, is-empty
#import "../core/constants.typ": RENDER-CONTEXT
#import "../data/variables.typ": get-variable
#import "../parsing/locales.typ": lookup-term
#import "../text/ranges.typ": format-page-range
#import "../text/quotes.typ": apply-quotes

// =============================================================================
// Bibliography Auto-linking (CSL Appendix VI)
// =============================================================================

/// Wrap identifier variables in hyperlinks for bibliography entries
///
/// CSL spec (Appendix VI): DOI, URL, PMID, PMCID should be anchored as links
/// - DOI: prepend "https://doi.org/"
/// - URL: output as is
/// - PMID: prepend "https://www.ncbi.nlm.nih.gov/pubmed/"
/// - PMCID: prepend "https://www.ncbi.nlm.nih.gov/pmc/articles/"
///
/// - var-name: Variable name (DOI, URL, PMID, PMCID)
/// - val: Variable value
/// - ctx: Context (checks render-context and auto-links option)
/// Returns: Linked content or original value
#let _maybe-link-identifier(var-name, val, ctx) = {
  // Only link in bibliography context
  let render-context = ctx.at("render-context", default: "")
  if render-context != RENDER-CONTEXT.bibliography {
    return val
  }

  // Check if auto-linking is enabled (default: true)
  let auto-links = ctx.at("auto-links", default: true)
  if not auto-links {
    return val
  }

  let val-str = if type(val) == str { val } else { str(val) }

  if var-name == "URL" {
    // URL: link as-is
    link(val-str, val-str)
  } else if var-name == "DOI" {
    // DOI: prepend https://doi.org/
    let url = if val-str.starts-with("http") { val-str } else {
      "https://doi.org/" + val-str
    }
    link(url, val-str)
  } else if var-name == "PMID" {
    // PMID: prepend https://www.ncbi.nlm.nih.gov/pubmed/
    let url = "https://www.ncbi.nlm.nih.gov/pubmed/" + val-str
    link(url, val-str)
  } else if var-name == "PMCID" {
    // PMCID: prepend https://www.ncbi.nlm.nih.gov/pmc/articles/
    let url = "https://www.ncbi.nlm.nih.gov/pmc/articles/" + val-str
    link(url, val-str)
  } else {
    val
  }
}

/// Handle <text> element
#let handle-text(node, ctx, interpret) = {
  let attrs = node.at("attrs", default: (:))

  let result = if "variable" in attrs {
    let var-name = attrs.variable
    let val = get-variable(ctx, var-name)

    if val != "" {
      // Apply page range formatting for page variables
      if var-name == "page" or var-name == "page-first" {
        let page-format = ctx.style.at("page-range-format", default: none)
        format-page-range(val, format: page-format, ctx: ctx)
      } else if var-name in ("URL", "DOI", "PMID", "PMCID") {
        // Auto-link identifier variables in bibliography
        _maybe-link-identifier(var-name, val, ctx)
      } else {
        val
      }
    } else { [] }
  } else if "macro" in attrs {
    let macro-name = attrs.macro
    // Check if we have precomputed results (memoization)
    let precomputed = ctx.at("macro-results", default: none)
    if precomputed != none and macro-name in precomputed {
      // Use precomputed result - O(1) lookup instead of recursive expansion
      precomputed.at(macro-name)
    } else {
      // Fallback to normal expansion (for sorting, etc.)
      let macro-def = ctx.macros.at(macro-name, default: none)
      if macro-def != none {
        macro-def
          .children
          .map(n => interpret(n, ctx))
          .filter(x => not is-empty(x))
          .join()
      } else { [] }
    }
  } else if "value" in attrs {
    attrs.value
  } else if "term" in attrs {
    let form = attrs.at("form", default: "long")
    let plural = attrs.at("plural", default: "false") == "true"
    lookup-term(ctx, attrs.term, form: form, plural: plural)
  } else { [] }

  // Apply quotes if requested (CSL quotes="true")
  let quoted-result = if (
    attrs.at("quotes", default: "false") == "true" and not is-empty(result)
  ) {
    apply-quotes(result, ctx, level: 0)
  } else {
    result
  }

  finalize(quoted-result, attrs)
}
