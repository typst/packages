#import "citation-styles.typ": format-citation-alphabetic, format-citation-authoryear, format-citation-numeric
#import "reference-styles.typ": format-reference

// Style bundles for the builtin styles.


/// Creates a style bundle out of a citation style
/// and a reference style.
/// 
/// -> dictionary
#let build-style(
  /// A factory for citation styles, i.e. a function which
  /// when called will return a citation style.
  /// 
  /// Citation styles are triples of a label generator,
  /// a reference labeler, and a citation formatter, as
  /// explained in @sec:custom-styles.
  /// 
  /// -> function
  citation-factory, 

  /// A factory for reference styles, i.e. a function which
  /// when called will return a reference style.
  /// 
  /// Reference styles are functions
  /// that typeset reference dictionaries as content,
  /// as explained in @sec:custom-styles.
  /// 
  /// -> function
  reference-factory,

  /// A dictionary of parameters which will be passed
  /// as named arguments to the `citation-factory`.
  /// 
  /// -> dictionary
  citation-parameters: (:),

  /// A dictionary of parameters which will be passed
  /// as named arguments to the `reference-factory`.
  /// 
  /// -> dictionary 
  reference-parameters: (:)
) = {
  let fcite = citation-factory(..citation-parameters)

  let fref = reference-factory(
    reference-label: fcite.reference-label,
    ..reference-parameters
  )

  (
    citation-style: fcite.format-citation,
    reference-style: fref,
    label-generator: fcite.label-generator
  )
}

/// The _numeric_ style bundle, which combines
/// the default reference style with the numeric citation style.
/// 
/// -> dictionary
#let numeric-style(
  /// Dictionary whose entries will be passed as named
  /// parameters to the citation style.
  /// 
  /// -> dictionary
  citation: (:),

  /// Dictionary whose entries will be passed as named
  /// parameters to the reference style.
  /// 
  /// -> dictionary  
  reference: (:)
) = {
  build-style(
    format-citation-numeric,
    format-reference,
    citation-parameters: citation,
    reference-parameters: reference
  )
}

/// The _alphabetic_ style bundle, which combines
/// the default reference style with the alphabetic citation style.
/// 
/// -> dictionary
#let alphabetic-style(
  /// Dictionary whose entries will be passed as named
  /// parameters to the citation style.
  /// 
  /// -> dictionary
  citation: (:),

  /// Dictionary whose entries will be passed as named
  /// parameters to the reference style.
  /// 
  /// -> dictionary  
  reference: (:)
) = {
  build-style(
    format-citation-alphabetic,
    format-reference,
    citation-parameters: citation,
    reference-parameters: reference
  )
}

/// The _authoryear_ style bundle, which combines
/// the default reference style with the authoryear citation style.
/// 
/// -> dictionary
#let authoryear-style(
  /// Dictionary whose entries will be passed as named
  /// parameters to the citation style.
  /// 
  /// -> dictionary
  citation: (:),

  /// Dictionary whose entries will be passed as named
  /// parameters to the reference style.
  /// 
  /// -> dictionary  
  reference: (:)
) = {
  build-style(
    format-citation-authoryear,
    format-reference,
    citation-parameters: citation,
    reference-parameters: reference
  )
}




