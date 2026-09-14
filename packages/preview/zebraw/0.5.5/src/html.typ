#import "util.typ": *

#let repr-or-str(x) = {
  if type(x) == str {
    x
  } else {
    repr(x)
  }
}

#let create-style(..styles) = styles.pos().filter(s => s != none).flatten().join("; ")

#let zebraw-html-show(
  numbering: none,
  inset: none,
  background-color: none,
  highlight-color: none,
  comment-color: none,
  lang-color: none,
  comment-flag: none,
  lang: none,
  comment-font-args: none,
  lang-font-args: none,
  numbering-font-args: none,
  extend: none,
  hanging-indent: none,
  indentation: none,
  highlight-lines: (),
  numbering-offset: 0,
  header: none,
  footer: none,
  numbering-separator: none,
  line-range: (0, -1),
  wrap: true,
  block-width: 42em,
  it,
) = context {
  let args = parse-zebraw-args(
    numbering: numbering,
    inset: inset,
    background-color: background-color,
    highlight-color: highlight-color,
    comment-color: comment-color,
    lang-color: lang-color,
    comment-flag: comment-flag,
    lang: lang,
    comment-font-args: comment-font-args,
    lang-font-args: lang-font-args,
    numbering-font-args: numbering-font-args,
    extend: extend,
    hanging-indent: hanging-indent,
    indentation: indentation,
    numbering-separator: numbering-separator,
  )

  // Extract args
  let numbering = args.numbering
  let inset = args.inset
  let background-color = args.background-color
  let highlight-color = args.highlight-color
  let comment-color = args.comment-color
  let lang-color = args.lang-color
  let comment-flag = args.comment-flag
  let lang = args.lang
  let comment-font-args = args.comment-font-args
  let lang-font-args = args.lang-font-args
  let numbering-font-args = args.numbering-font-args
  let extend = args.extend
  let hanging-indent = args.hanging-indent
  let indentation = args.indentation
  let numbering-separator = args.numbering-separator
  let fast-preview = args.fast-preview

  // Process highlight lines
  let (highlight-nums, comments) = tidy-highlight-lines(highlight-lines)

  // Common styles
  let numbering-width = if numbering == true {
    if it.lines.len() + numbering-offset < 100 {
      2.1em
    } else {
      auto
    }
  } else if type(numbering) == array { auto } else { 0 }

  let number-div-style = (
    "margin: 0",
    "text-align: right",
    "vertical-align: top",
    // "padding-right: 0.65em",
    "user-select: none",
    "flex-shrink: 0",
    "width: " + repr-or-str(numbering-width),
    "padding: " + repr-or-str(inset.top) + " 0.65em " + repr-or-str(inset.bottom) + " 0.35em",
    "height: 100%",
  )

  let pre-style = (
    "padding-top: " + repr-or-str(inset.top),
    "padding-bottom: " + repr-or-str(inset.bottom),
    "margin: 0",
    "padding-left: " + repr-or-str(inset.left),
    "padding-right: " + repr-or-str(inset.right),
    ..if wrap { ("white-space: pre-wrap",) },
  )

  let text-div-style = (
    "text-align: left",
    "display: flex",
    "align-items: center",
    "width: 100%",
  )

  let background-text-style = (
    "user-select: none",
    "opacity: 0",
    "color: transparent",
  )

  // Helper for creating code line elements
  let build-code-line-elem(line, is-background: false) = {
    // Create main line element
    let line-elem = html.elem(
      "div",
      attrs: (
        style: create-style(
          text-div-style,
          if is-background { ("background: " + line.fill.to-hex(),) },
        ),
        ..if not is-background { (class: "zebraw-code-line-container", translate: "no") },
      ),
      {
        // Line number
        set text(..numbering-font-args)
        html.elem(
          "pre",
          attrs: (
            style: create-style(
              number-div-style,
              "display: flex",
              "justify-content: flex-end",
              if is-background { background-text-style } else { ("opacity: 0.7",) },
            ),
          ),
          if type(line.number) == array {
            line
              .number
              .map(n => html.elem(
                "span",
                attrs: (style: "margin-left: 0.2em"),
                n,
              ))
              .join()
          } else {
            [#line.number]
          },
        )

        // Code content
        html.elem(
          "pre",
          attrs: (
            style: create-style(
              pre-style,
              "position: relative", // Add relative positioning
              if numbering-separator == true and not is-background {
                ("border-left: 1px solid #ccc",)
              },
            ),
            ..if not is-background { (class: "zebraw-code-line", translate: "no") },
          ),
          {
            show underline: it => html.elem(
              "span",
              attrs: (style: "text-decoration: underline"),
              it,
            )

            show text: it => context {
              let c = text.fill
              let b = text.weight
              html.elem(
                "span",
                attrs: (
                  style: create-style(if is-background { background-text-style } else {
                    ("color: " + c.to-hex(), "font-weight: " + b)
                  }),
                ),
                it,
              )
            }
            line.indentation + line.body
          },
        )
      },
    )

    // Create comment element if needed
    let comment-elem = if line.comment != none {
      html.elem(
        "div",
        attrs: (
          style: create-style(
            text-div-style,
            if is-background { ("background: " + line.comment.fill.to-hex(),) },
            "align-items: flex-start", // 改为顶部对齐，防止垂直居中导致的奇怪布局
          ),
          ..if not is-background { (class: "zebraw-code-comment-container") },
        ),
        {
          html.elem(
            "pre",
            attrs: (
              style: create-style(
                number-div-style,
                if is-background { background-text-style } else { ("opacity: 0.7",) },
              ),
            ),
            "",
          )

          // 注释内容容器
          html.elem(
            "div",
            attrs: (
              style: create-style(
                "margin: 0",
                "padding: "
                  + repr-or-str(inset.top)
                  + " "
                  + repr-or-str(inset.right)
                  + " "
                  + repr-or-str(inset.bottom)
                  + " "
                  + repr-or-str(inset.left), // 使用与代码行一致的内边距
                "width: 100%",
                if wrap { ("white-space: pre-wrap",) } else { ("white-space: pre",) },
              ),
              class: "zebraw-code-comment",
            ),
            {
              // 注释标记
              html.elem(
                "span",
                attrs: (
                  style: create-style(
                    ("user-select: none",),
                    if is-background { background-text-style },
                  ),
                  class: "zebraw-comment-flag",
                ),
                if line.comment.comment-flag != "" {
                  line.comment.indentation
                  strong(text(ligatures: true, line.comment.comment-flag))
                  " "
                } else { },
              )

              // 注释文本
              html.elem(
                "span",
                attrs: (
                  ..if is-background { (style: create-style(background-text-style)) },
                  class: "zebraw-comment-text",
                ),
                line.comment.body,
              )
            },
          )
        },
      )
    }

    // Return both elements
    if comment-elem != none {
      (line-elem, comment-elem)
    } else {
      (line-elem,)
    }
  }

  // Process lines
  let lines = tidy-lines(
    numbering,
    it.lines,
    highlight-nums,
    comments,
    highlight-color,
    background-color,
    comment-color,
    comment-flag,
    comment-font-args,
    numbering-offset,
    inset,
    is-html: true,
    line-range: line-range,
  )

  // Helper for creating header/footer cells
  let build-cell(is-header, content, is-background: false) = html.elem(
    "div",
    attrs: (
      style: create-style(
        if is-background {
          (
            "background: "
              + if content != none {
                comment-color.to-hex()
              } else {
                if is-header {
                  curr-background-color(background-color, 0).to-hex()
                } else {
                  curr-background-color(background-color, lines.len() + 1).to-hex()
                }
              },
          )
        },
        "width: 100%",
      ),
    ),
    html.elem(
      "div",
      attrs: (
        style: create-style(
          "padding: " + repr-or-str(inset.right) + " " + repr-or-str(inset.left),
          if is-background { background-text-style },
        ),
      ),
      text(..comment-font-args, content),
    ),
  )

  // Helper functions for header/footer
  let create-header-footer(is_header, content, comments, extend, is_background: false) = {
    let key = if is_header { "header" } else { "footer" }

    if content != none or comments.keys().contains(key) {
      (build-cell(is_header, if content != none { content } else { comments.at(key) }, is-background: is_background),)
    } else if extend {
      (build-cell(is_header, none, is-background: is_background),)
    } else {
      ()
    }
  }

  // Main code block container
  html.elem(
    "div",
    attrs: (
      style: create-style(
        "position: relative",
        "width: " + repr-or-str(block-width),
        "font-size: 0.8em",
      ),
      class: "zebraw-code-block",
    ),
    {
      // Language label
      let has-lang = (type(lang) == bool and lang and it.lang != none) or type(lang) != bool
      if has-lang {
        html.elem(
          "div",
          attrs: (
            style: create-style(
              "position: absolute",
              "top: -" + repr-or-str(inset.top + inset.bottom),
              "right: 0",
              "padding: 0.25em",
              "background: " + lang-color.to-hex(),
              "font-size: 0.8em",
              "border-radius: " + repr-or-str(inset.left),
            ),
            class: "zebraw-code-lang",
            translate: "no",
          ),
          if type(lang) == bool { it.lang } else { lang },
        )
      }

      // Background layer
      html.elem(
        "div",
        attrs: (
          style: create-style(
            "position: absolute",
            "top: 0",
            "left: 0",
            "width: 100%",
            "height: 100%",
            "overflow: hidden",
            "z-index: 0",
            "pointer-events: none",
            "border-radius: " + repr-or-str(inset.left),
          ),
        ),
        (
          ..create-header-footer(true, header, comments, extend, is_background: true),
          ..lines.map(line => build-code-line-elem(line, is-background: true)).flatten(),
          ..create-header-footer(false, footer, comments, extend, is_background: true),
        ).join(),
      )

      // Foreground content
      html.elem(
        "div",
        attrs: (
          style: create-style(
            "overflow-x: auto",
            "overflow-y: hidden",
          ),
        ),
        (
          ..create-header-footer(true, header, comments, extend),
          ..lines.map(line => build-code-line-elem(line)).flatten(),
          ..create-header-footer(false, footer, comments, extend),
        ).join(),
      )

      html.elem(
        "script",
        ```javascript
        document.querySelectorAll('.zebraw-code-block').forEach(codeBlock => {
          const copyButton = codeBlock.querySelector('.zebraw-code-lang');
          if (!copyButton) return;

          copyButton.style.cursor = 'pointer';
          copyButton.title = 'Click to copy code';

          copyButton.addEventListener('click', () => {
            const code = Array.from(codeBlock.querySelectorAll('.zebraw-code-line'))
              .map(line => line.textContent)
              .join('\n');

            navigator.clipboard.writeText(code)
              .catch(() => {
                const textarea = document.createElement('textarea');
                textarea.value = code;
                document.body.appendChild(textarea);
                textarea.select();
                document.execCommand('copy');
                document.body.removeChild(textarea);
              });

            const originalTitle = copyButton.title;
            copyButton.title = 'Code copied!';
            setTimeout(() => copyButton.title = originalTitle, 2000);
          });
        });
        ```.text,
      )
    },
  )
}
