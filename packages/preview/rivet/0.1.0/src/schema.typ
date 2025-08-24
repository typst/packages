#import "config.typ" as conf
#import "renderer.typ"
#import "structure.typ"
#import "xml-loader.typ"

#let valid-extensions = ("yaml", "json", "xml")

#let parse-file(path) = {
  let ext = path.split(".").last()

  if not ext in valid-extensions {
    let fmts = valid-extensions.map(fmt => "." + fmt).join(", ")
    fmts = "(" + fmts + ")"
    panic("." + ext + " files are not supported. Valid formats: " + fmts)
  }

  if ext == "yaml" {
    return yaml(path)
  } else if ext == "json" {
    return json(path)
  } else if ext == "xml" {
    return xml-loader.load(path)
  }
}

#let parse-raw(schema) = {
  let lang = schema.lang
  let content = schema.text
  if not lang in valid-extensions {
    let fmts = valid-extensions.join(", ")
    fmts = "(" + fmts + ")"
    panic("Unsupported format '" + lang + "'. Valid formats: " + fmts)
  }

  if lang == "yaml" {
    return yaml.decode(content)
  } else if lang == "json" {
    return json.decode(content)
  } else if lang == "xml" {
    return xml-loader.parse(xml.decode(content).first())
  }
}

#let load(path-or-schema) = {
  let schema = if type(path-or-schema) == str {
    parse-file(path-or-schema)
  } else if type(path-or-schema) == dictionary {
    path-or-schema
  } else {
    parse-raw(path-or-schema)
  }

  if "colors" in schema {
    for struct in schema.colors.keys() {
      for (span, col) in schema.colors.at(struct) {
        if type(col) == str {
          if col.starts-with("#") {
            col = rgb(col)
          } else {
            let (r, g, b) = col.split(",").map(v => int(v))
            col = rgb(r, g, b)
          }
        } else if type(col) == array {
          col = rgb(..col)
        } else if type(col) != color {
          panic("Invalid color format")
        }
        schema.colors.at(struct).at(span) = col
      }
    }
  } else {
    schema.insert("colors", (:))
  }

  let structures = (:)
  for (id, data) in schema.structures {
    id = str(id)
    structures.insert(id, structure.load(id, data))
  }
  return (
    structures: structures,
    colors: schema.at("colors", default: (:))
  )
}

#let render(schema, width: 100%, config: auto) = {
  if config == auto {
    config = conf.config()
  }
  let renderer_ = renderer.make(config)
  (renderer_.render)(schema, width: width)
}