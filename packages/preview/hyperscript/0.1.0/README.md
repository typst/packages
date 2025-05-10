# `hyperscript`
### Create HTML in Typst with CSS-style selectors

`hyperscript` provides the `h` function that is a convenience wrapper for `html.elem`.

`h(selector, attributes, ..content)`

* `selector` -- A CSS-style selector.
* `attributes` (optional dictionary) -- Attributes for the HTML tag.
* `content` -- Content enclosed by the tag. Can be strings or content.

`selector` has the format "name.class1.class2#id[attr1=something][attr2=else]". All of the components are optional. If "name" is left out, "div" is assumed. One or more classes can be provided. All classes and the id are merged into `attributes`.

Note that `html.elem` doesn't have a way to pass in raw strings. Everything is encoded for HTML. Be careful with `<script>` tags, particularly text that includes "<".

`hyperscript` also provides `hc` which is a method wrapped in a context that checks that the target is HTML.

Here are examples:

```typst
#import "@preview/hyperscript:0.1.0": *

#h("#hello")
// <div id="hello"></div>

#h("section.container")
// <section class="container"></section>

#h("input[type=text][placeholder=Name]")
// <input type="text" placeholder="Name" />

#h(".myclass", (placeholder: "one"))[hello *world*]
// <div class="myclass" placeholder="one">hello <strong>world</strong></div>

Here's a link: #h("a#exit.external[href='https://example.com']", "Leave")
// <p>Here's a link: <a href="https://example.com" class="external" id="exit">Leave</a></p>

#h(".fancy-list#mylist")[
  - one
  - two
  - three
]
// <div class="fancy-list" id="mylist">
//   <ul>
//     <li>one</li>
//     <li>two</li>
//     <li>three</li>
//   </ul>
// </div>

```

This approach is based on [Mithril](https://mithril.js.org/hyperscript.html). Related work includes [hyperscript](https://github.com/hyperhype/hyperscript).

[This](https://arthurclemens.github.io/mithril-template-converter/index.html) is a useful tool to convert HTML to hyperscript format.
