
#import "src/bibtypst.typ": add-bib-resource, refsection, print-bibliography, if-citation, cite, citet, citep, citen, citeg, citename, citeyear, add-category, has-category
#import "src/reference-styles.typ": format-reference
#import "src/citation-styles.typ": format-citation-authoryear, format-citation-alphabetic, format-citation-numeric
#import "src/names.typ": family-names, format-name
#import "src/bib-util.typ": fd, ifdef, nn, concatenate-names
#import "src/content-to-string.typ": content-to-string
#import "src/templating.typ": commas, periods, spaces, epsilons

#let pergamon-dev = {
  import "src/reference-styles.typ": *
  import "src/printfield.typ": *

  (
    printfield: printfield,
    print-name: print-name,
    link-title: link-title,
    authorstrg: authorstrg,
    language: language,
    date-with-extradate: date-with-extradate, 
    author: author,
    author-editor: author-editor,
    editor: editor,
    maybe-with-date: maybe-with-date,
    editor-others: editor-others,
    translator-others: translator-others,
    author-translator-others: author-translator-others,
    volume-number-eid: volume-number-eid,
    type-number-location: type-number-location,
    issue-date: issue-date,
    issue: issue,
    journal-issue-title: journal-issue-title,
    periodical: periodical,
    title-issuetitle: title-issuetitle,
    withothers: withothers,
    bytranslator-others: bytranslator-others,
    byeditor-others: byeditor-others,
    byauthor: byauthor,
    bybookauthor: bybookauthor,
    byholder: byholder,
    byeditor: byeditor,
    note-pages: note-pages,
    doi-eprint-url: doi-eprint-url,
    addendum-pubstate: addendum-pubstate,
    maintitle: maintitle,
    booktitle: booktitle,
    maintitle-booktitle: maintitle-booktitle,
    maintitle-title: maintitle-title,
    event-venue-date: event-venue-date,
    volume-part-if-maintitle-undef: volume-part-if-maintitle-undef,
    series-number: series-number,
    publisher-location-date: publisher-location-date,
    organization-location-date: organization-location-date,
    institution-location-date: institution-location-date,
    location-date: location-date,
    chapter-pages: chapter-pages,
    author-editor-others-translator-others: author-editor-others-translator-others,
    title-with-language: title-with-language,
    require-fields: require-fields,
    driver-article: driver-article,
    driver-inproceedings: driver-inproceedings,
    driver-incollection: driver-incollection,
    driver-book: driver-book,
    driver-misc: driver-misc,
    driver-thesis: driver-thesis,
    driver-booklet: driver-booklet,
    driver-collection: driver-collection,
    driver-inbook: driver-inbook,
    driver-manual: driver-manual,
    driver-online: driver-online,
    driver-patent: driver-patent,
    driver-periodical: driver-periodical,
    driver-proceedings: driver-proceedings,
    driver-report: driver-report,
    driver-unpublished: driver-unpublished,
    driver-dataset: driver-dataset,
    ifen: ifen,
  )
}
