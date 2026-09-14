#import"./global.typ": *

/// Define a new block of options.
/// 
/// *Example:*
/// ``` 
/// #g-subquestion(points:2)[This is a sub-question]
/// ```
///
/// - body (string, content): Body of option label.
#let option(
    body) = {
      body
    }