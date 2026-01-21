/// A boolean state indicating whether the document should display fallback content for elements
/// requiring results from preprocessing. For example, when using prequery images, compiling the
/// document before download the files during preprocessing will fail. If all prequeries used in the
/// document work even before preprocessing, it is not necessary to turn fallback mode on.
///
/// When editing the document and adding images (or other preprocessed content), it is convenient to
/// temporarily add a line at the top to switch fallback mode on:
///
/// ```typ
/// #fallback.update(true)
/// ```
///
/// When querying the document for preprocessing, this can be activated using `--input`:
///
/// ```sh
/// typst query --input prequery-fallback=true ...
/// ```
///
/// -> state
#let fallback = state("prequery-fallback", {
  import "utils.typ": boolean-input
  boolean-input("prequery-fallback")
})

#let _fallback = fallback

/// This is the fundamental function for building prequeries. It adds metadata for preprocessing to
/// the document and conditionally shows some fallback content when @@fallback mode is enabled.
///
/// The body may be given as a function, so that errors from the body don't let compilation fail
/// when in fallback mode.
///
/// - meta (any): the metadata value to provide for preprocessing
/// - lbl (label): the label to give the created metadata
/// - body (content, function): the body to display; if a function is given, that function will not
///   be called in fallback mode
/// - fallback (content): the fallback content to display when in fallback mode
/// -> content
#let prequery(meta, lbl, body, fallback: none) = {
  [#metadata(meta) #lbl]
  context {
    if not _fallback.get() {
      if type(body) != function {
        body
      } else {
        body()
      }
    } else {
      if type(body) != function and fallback == none {
        // in fallback mode, a body that is simple content will still be shown
        // if no fallback content was given
        body
      } else {
        // if the body is a function, or fallback content is given, that is shown
        // if the fallback content is none, then nothing is shown
        fallback
      }
    }
  }
}

#let _builtin_image = image

/// A prequery for images. Apart from the `url` parameter, the image file name is also mandatory; it
/// is part of `args` for technical reasons. Rendering fails (outside fallback mode) before images
/// have been downloaded in a preprocessing step.
///
/// This function provides a dictionary with `url` and `path` as metadata under the label
/// `<web-resource>`. This metadata can be queried like this:
///
/// ```sh
/// typst query --input prequery-fallback=true --field value ... '<web-resource>'
/// ```
///
/// *Fallback:* renders the Unicde character "Frame with Picture" (U+1F5BC).
///
/// - url (string): the URL of the image to be shown
/// - ..args (arguments): arguments to be forwarded to built-in `image`
/// -> content
#let image(url, ..args) = prequery(
  (url: url, path: args.pos().at(0)),
  <web-resource>,
  // this is a bit "magic": Typst doesn't have path hygiene yet
  // (https://github.com/typst/typst/issues/971) - HOWEVER, it seems that the `arguments` type
  // remebers where it comes from. So the first positional parameter in `args` is the path
  // _relative to where this function was called_, which is the path we actually want!
  _builtin_image.with(..args),
  fallback: [\u{1F5BC}],
)
