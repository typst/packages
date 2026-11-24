#let lato-template = ```css
@font-face {
    font-family: "__FAMILY_NAME__";
    src: url("fonts/__SOURCE__") format("woff2");
    font-style: __STYLE__;
    font-weight: __WEIGHT__;
    text-rendering: optimizeLegibility;
}

```.text

#let (header, ..font-list) = csv("fontlist.csv")

#let font-files(root) = font-list.map(((.., font-file)) => asset(root + "/fonts/" + font-file, read(
  font-file,
  encoding: none,
)))


#let font-css = for (style, weight, family-name, source) in font-list {
  lato-template
    .replace("__FAMILY_NAME__", family-name)
    .replace("__STYLE__", style)
    .replace("__WEIGHT__", weight)
    .replace("__SOURCE__", source)
}
