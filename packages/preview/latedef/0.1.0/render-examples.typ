// compile with [typst c render-examples.typ 'example-images/{p}.png']

#let prefix = ```#import "latedef.typ": latedef-setup
```.text

#set page(width: auto, height: auto, margin: 5pt)

#let first = true
#let fail-next = false
#let isolate-next = false
#for (i, s) in read("README.md").split("```typst").enumerate() {
	let (example, ..rest) = s.split("```")
	if not first and not fail-next {
		if isolate-next {
			example = example.replace("latedef-setup(", "latedef-setup(group: \"" + str(i) + "\", ")
		}

		pagebreak(weak: true)
		eval(prefix + example, mode: "markup")
	}
	fail-next = rest.len() > 0 and rest.last().ends-with("<!-- fail-example -->\n")
	isolate-next = rest.len() > 0 and rest.last().ends-with("<!-- isolate-example -->\n")
	first = false
}