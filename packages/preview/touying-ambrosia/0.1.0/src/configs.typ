#import "touying.typ": config-info as touying-config-info

// Omitted fields must stay absent: configs merge incrementally, and `none`
// explicitly clears a value. A private sentinel keeps those cases distinct.
#let _unset = metadata((kind: "ambrosia-info-unset"))

/// Presentation metadata, including collaborators and linked affiliations.
/// Only supplied fields are emitted; later configuration calls override them.
///
/// - title (content, str): Presentation title.
///
/// - short-title (content, str, auto): Compact footer title; auto uses title.
///
/// - subtitle (content, str): Presentation subtitle.
///
/// - short-subtitle (content, str, auto): Compact subtitle.
///
/// - author (content, str, array, none): Simple presenter name or names.
///
/// - short-author (content, str, auto): Compact footer author; auto uses author short names.
///
/// - authors (array, content, str, none): Collaborator records with name, short,
///   affiliations (institution IDs), and email or emails. Replaces author.
///
/// - institution (content, str, array, none): Simple institution name or names.
///
/// - institutions (dictionary, array, auto, none): Institution IDs mapped to
///   names or records with name and address; arrays also accept an id field.
///   auto uses institution. Array and dictionary order determines markers.
///
/// - email (str, content, none): Shared contact email.
///
/// - emails (array, str, content, none): Shared emails; replaces email.
///
/// - affiliation-numbering (str, function): Typst numbering pattern or function,
///   e.g. "1", "*", or "a". Omission preserves the theme setting.
///
/// - affiliation-scope (str, none): Separate affiliation links for unrelated covers.
///
/// - date (datetime, content, none): Presentation date; none hides it.
///
/// - contact (content, str, none): Upstream Touying contact metadata.
///
/// - logo (content, function, none): Primary logo fallback.
///
/// - logo-light (content, function, none): Light logo variant for custom renderers.
///
/// - extra (dictionary): Upstream Touying extra metadata.
///
/// - args (arguments): Additional named metadata fields; positional arguments are rejected.
///
/// -> dictionary
#let config-info(
  title: _unset,
  short-title: _unset,
  subtitle: _unset,
  short-subtitle: _unset,
  author: _unset,
  short-author: _unset,
  authors: _unset,
  institution: _unset,
  institutions: _unset,
  email: _unset,
  emails: _unset,
  affiliation-numbering: _unset,
  affiliation-scope: _unset,
  date: _unset,
  contact: _unset,
  logo: _unset,
  logo-light: _unset,
  extra: _unset,
  ..args,
) = {
  let fields = (
    title: title, short-title: short-title, subtitle: subtitle, short-subtitle: short-subtitle,
    author: author, short-author: short-author, authors: authors,
    institution: institution, institutions: institutions,
    email: email, emails: emails,
    affiliation-numbering: affiliation-numbering, affiliation-scope: affiliation-scope,
    date: date, contact: contact, logo: logo, logo-light: logo-light, extra: extra,
  ).pairs().filter(pair => pair.last() != _unset).to-dict()
  touying-config-info(..fields, ..args)
}
