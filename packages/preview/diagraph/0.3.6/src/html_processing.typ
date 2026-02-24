#let plugin = plugin("../graphviz_interface/diagraph.wasm")


#let lower-string(text) = {
	for c in text {
		if c >= "A" and c <= "Z" {
			str.from-unicode(c.at(0).to-unicode() + 32)
		} else {
			c
		}
	}
}

#let font-content(attr, content) = {
	set text(fill: rgb(plugin.convert_color(attr.at("color")))) if "color" in attr
	set text(size: int(attr.at("point-size")) * 1pt) if "point-size" in attr 
	set text(font: attr.at("face"))	if "face" in attr 
	
	text(content)
}

#let html-to-content(html-text) = {
	// replace single tags like <br/> with opening and closing tags
	
	let html-body = if type(html-text) == dictionary {
		html-text.children
	} else {
		xml(bytes("<e>" + html-text + "</e>")).at(0).children
	}

	for children in html-body {
		if type(children) == str {
			children
		} else {
			let tag = lower-string(children.tag)
			if tag == "br" {
				linebreak()
				continue
			}
			let sub-children = for child in children.children {
				let result = html-to-content(child)
				if result == none {
					return none
				}
				result
			}
			if tag == "i" {
				text(style: "italic", sub-children)
			} else if tag == "b" {
				text(weight: "bold", sub-children)
			} else if tag == "u" {
				underline(sub-children)
			} else if tag == "o" {
				overline(sub-children)
			} else if tag == "sub" {
				sub(sub-children)
			} else if tag == "sup" {
				super(sub-children)
			} else if tag == "s" {
				strike(sub-children)
			} else if tag == "font" {
				font-content(children.attrs, sub-children)
			} else {
				return none
			}
		}
	}
}
