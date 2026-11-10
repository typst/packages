#import "doc.typ": _core_doc, current, documents
#import "types.typ": author, category, img
#import "tag.typ": tag
#import "util.typ": _match

#let _document-selector(id) = std.label("tysty-document:" + id)

// Declare a document. Most arguments map 1:1 onto `_Core_doc` fields and
#let meta(
  id: none,
  parent-id: auto,
  file-path: "(no link (uri))",
  //
  title: none,
  authors: none,
  //
  date: datetime.today(),
  lang: "en_US",
  version: "0.0.1",
  doi: "(none)",
  abstract: "",
  keywords: (),
  license: "apache-v2",
  //
  description: "",
  cover_image: img.null,
  category: category.null,
  tags: (),
  tlb: (:),
) = {
  context {
    let doc = (_core_doc.new)(
      id: id,
      parent-id: if parent-id == auto { id } else { parent-id },
      file-path: file-path,

      title: title,
      authors: authors,

      date: date,
      lang: lang,
      version: version,
      doi: doi,
      abstract: abstract,
      keywords: keywords,
      license: license,

      description: description,
      cover_image: cover_image,

      category: category,

      tags: tags,

      tlb: tlb,
    )

    for v in authors {
      assert(
        _match(str, v) or _match(author, v),
        message: "authors must contain strings or author records",
      )
    }
    for t in tags {
      assert(
        _match(tag, t),
        message: "tags must contain tag records",
      )
    }
    for keyword in keywords {
      assert(
        type(keyword) == str,
        message: "keywords must contain strings",
      )
    }

    // Publish the complete record for document queries.
    [#metadata(doc) <tysty-document>]
    // A dedicated marker lets duplicate checks query only this document ID.
    [#metadata(id)#_document-selector(id)]

    (current.update)(
      doc,
    )
  }
  context {
    let matches = query(_document-selector(id))
    assert(matches.len() <= 1, message: "ERROR: duplicate document id: `" + id + "`")
  }
}
