#import "/core/util.typ": handle

// Functions to handle rich objects. A rich object is an object that can be
// available in multiple formats. It is given as a dict with fields
// 
// - data: a dict with MIME types as keys and data in the corresponding MIME
//   type as values.
// - metadata: a dict of metadata. The dict can contain directly the metadata
//   if the same metadata applies to all MIME types, or it can have MIME types
//   as keys, and MIME-specific metadata dicts as values.
// - output_type: the output type (this field is absent for attachments).
// 
// This is how display_data/execute_result outputs and Markdown cell
// attachments are stored in the notebook.

// Preprocess a "rich" object, which can be available in multiple formats,
// to select the best format among those available.
// The item is a dict with at least 'data' and 'metadata' fields, with 'data'
// a dict keyed by MIME types.
// Can return none if item is available only in unsupported formats (and
// ignore-wrong-format is true) or if the item is empty (data dict empty in
// notebook JSON).
#let preprocess(item, ctx: none) = {
  // Ignore item with no format (data dict empty)
  if item.data.len() == 0 { return none }
  // Pick the first desired format that is available, or none
  let available = item.data.keys()
  let fmt = ctx.format.find(f => f in available)
  if fmt == none {
    if not ctx.ignore-wrong-format {
      panic("output item " + repr(ctx.item-desc) +
      " from cell " + str(ctx.cell.index) +
      " has no appropriate format: item has " +
        repr(item.data.keys()) + ", we want " +
        repr(ctx.format))
    }
    return none
  }

  // Get data for this format
  let data = item.data.at(fmt)
  if type(data) == array {
    // Normalize to a single value
    data = data.join()
  }

  // Get metadata for this format. If metadata doesn't have a key for the
  // format, use the whole metadata instead.
  let metadata = item.metadata.at(fmt, default: item.metadata)

  return (
    data: data,
    metadata: metadata,
    format: fmt,
  )
}

// Process an item given as a dict with keys data, metadata and format.
// - handler-args: extra arguments to pass to the handler that will handle the
//   item data (there is no such arguments when processing an output item, but
//   for an image attachment in a Markdown cell for example the Markdown can
//   define an 'alt' value that will be passed as a handler argument.
#let process(
  item,
  ctx: none,
  handler-args: none,
) = {
  if item.data.len() == 0 { return none }
  // Add some context fields
  ctx.item-desc.metadata = item.metadata
  ctx.item-desc.format = item.format
  return handle(item.data, mime: item.format, ctx: ctx, ..handler-args)
}
