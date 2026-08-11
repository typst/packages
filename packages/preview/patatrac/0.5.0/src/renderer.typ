/// This is the constructor for a renderer. Let's start with an example
/// ```typc
/// let dictionary-of-drawing-functions = (
///   rect: (obj, style) => {...},
///   circle: (obj, style) => {...},
///   ...
/// )
/// let renderer = renderer(dictionary-of-drawing-functions)
/// let draw = renderer(rect: (stroke: 2pt))
/// ```
/// 
/// This constructor takes one positional argument which is expected to be a 
/// `dictionary-of-drawing-functions`
/// having keys corresponding to object types and function
/// valued fields. These functions must take two positional parameters: the first is
/// expected to be an object (groups of objects are automatically broken into individual 
/// objects by the renderer); the second parameter must be of type dictionary and is meant 
/// to specify styling options for drawing the object. The result of these drawing functions 
/// is a graphical representation of the inputted object, according to the specified style.
/// 
/// A renderer is a function that takes a set of default styling options and produces 
/// a function that is ready for drawing. This is the function we usually call `draw`.
/// 
/// The render does also something special: if it is called on the string `"functions"` it returns the
/// whole `dictionary-of-drawing-functions`. First of all, this is useful to retrieve the full
/// list of supported types. Moreover, given a render `rendererA` and a
/// render `rendererB`, `renderer(rendererB() + rendererA())` results in a new render that tries
/// to render with `rendererB` when `rendererA` is unable to do so. 
/// 
/// Remarks:
///  - When a group of objects is given to a renderer all objects are rendered, one by one.
///  - This design implies that styling options are shared between all elements
///    that are drawn using the same call to a renderer. This has the intended
///    consequence that multiple calls to the renderer are required to draw
///    objects that require different styling options. 
///  - The active anchor of an object can be used as available information 
///    when drawing. This should be generally avoided but has some reasonable
///    applications, for example for the placement of labels.
#let renderer(dictionary-of-drawing-functions) = (..defaults) => {
  if (
    defaults.pos().len() == 1 and 
    defaults.named().keys().len() == 0 and 
    defaults.pos().at(0) == "functions" 
  ) {
    return dictionary-of-drawing-functions
  }

  if defaults.pos().len() > 0 {
    panic("Unexpected positional arguments. You are calling a renderer not a rendering function! To turn a renderer into an actual rendering function either call the renderer without any parameter or specify named arguments to set the default styling for each object type. For example, a sensible definition of a rendering function `draw` could be `let draw = patatrac.renderers.cetz.standard()`.")
  }

  let defaults = defaults.named()
  
  return (..args) => {
    let objects = args.pos().flatten()
    let style = args.named()

    return objects.map(obj => {
      // Not an object
      if type(obj) != function {
        panic("Only objects can be rendered but type " + repr(type(obj)) + " was found.")
      }
      // Unknown object type
      if not(obj("type") in dictionary-of-drawing-functions) {
        panic("This renderer has no drawing function for objects of type " + repr(obj("type")) + ". The supported object types are " + repr(dictionary-of-drawing-functions.keys()))
      } 

      // Calculate default styling for this object type
      let final-obj-style = none
      let default = defaults.at(obj("type"), default: (:))
      if type(default) == dictionary {
        final-obj-style = default + style
      } else if type(default) == function {
        final-obj-style = default(style)
      }

      return dictionary-of-drawing-functions.at(obj("type"))(obj, final-obj-style)
    }).flatten()
  }
}