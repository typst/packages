#import "relationships.typ": aggregation, association, implementation, inheritance, aggregation, dependency, composition
#import "classes.typ": class, column, group, row, source
#import "draw.typ": draw-source-uml-diagram, draw-uml-diagram
#import "themes.typ": theme, themes
#import "parser/plugin.typ" as plugin-parser

#let parsers = (
  java: plugin-parser.parse-java,
  csharp: plugin-parser.parse-csharp,
  php: plugin-parser.parse-php,
)
