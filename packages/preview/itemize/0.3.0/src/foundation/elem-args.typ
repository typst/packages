#import "../util/parse-args.typ": *

#let ElemType = (
  "list": "list",
  "enum": "enum",
  "all": "all",
)

#let default-elem-format-args = (
  "indent",
  "body-indent",
  "label-indent",
  "item-spacing",
  "hanging-indent",
  "line-indent",
  "label-width",
  "body-format",
  "label-format",
  // "item-format", for future
  "label-align",
  "label-baseline",
  "label-inset",
  "first-line-inset",
  "tight-mode",
  "tight-item-mode",
  "step", /*only works for enum*/
  "ref-numbering", /*only works for enum*/
  "supplement",
  "description-config", /* vers0.3.0 */
  "whole-spacing", /* vers0.3.0 */
  "body-margin", /* vers0.3.0 */
  "hanging-type", /* vers0.3.0 */
)

#let parse-elem-args(elem-args: (:)) = {
  if type(elem-args) == dictionary {
    for k in default-elem-format-args {
      let value = elem-args.at(k, default: none)
      (str(k): value)
    }
    // text args
    let dic = for k in default-text-args.keys() {
      let v = elem-args.at(k, default: none)
      if v != none {
        (str(k): v)
      }
    }
    (text-args: arguments(..dic))
  } else {
    for k in default-elem-format-args {
      (str(k): none)
    }
    (text-args: none)
  }
}
