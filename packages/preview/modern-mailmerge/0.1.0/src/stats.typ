// src/stats.typ - Inspection & Fast Preview Helpers for Typst Mail Merge

#import "utils.typ": read-csv-data
#import "core.typ": mail-merge, process-records

/// Inspects a CSV dataset and returns a summary dictionary of record count, field headers, and a sample record.
/// - data (str | array): CSV file path or raw array data.
/// - filter (none | function | dictionary): Filter condition to inspect specific subset.
/// - trim (bool): Trim whitespace from string CSV values.
/// - default-value (str): Default fallback string for missing fields.
/// -> dictionary
#let mail-merge-stats(
  data,
  filter: none,
  trim: true,
  default-value: ""
) = {
  let records = process-records(
    data,
    filter: filter,
    trim: trim,
    default-value: default-value
  )

  if records.len() == 0 {
    return (
      total-records: 0,
      fields: (),
      sample-record: (:)
    )
  }

  let first = records.at(0)
  let clean-fields = first.keys().filter(k => not k.starts-with("_"))
  let sample = (:)
  for (k, v) in first.pairs() {
    if not k.starts-with("_") {
      sample.insert(k, v)
    }
  }

  (
    total-records: records.len(),
    fields: clean-fields,
    sample-record: sample
  )
}

/// Convenience wrapper around `mail-merge` that defaults to limiting output to the first N records for rapid draft previews.
/// - data (str | array): CSV file path or array data.
/// - template (function): Template closure.
/// - limit (int): Maximum records to preview (default: 3).
/// - ..options: Additional options passed to mail-merge (filter, sort-by, etc.).
/// -> content
#let mail-merge-preview(
  data,
  template,
  limit: 3,
  ..options
) = {
  mail-merge(data, template, limit: limit, ..options.named())
}
