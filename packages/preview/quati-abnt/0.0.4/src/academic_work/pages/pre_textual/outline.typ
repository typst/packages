// # Outline. Sumário.
// NBR 6027:2012, NBR 14724:2024 4.2.1.13

#import "../../../common/util/font_family.typ": font_family_for_highlighted_text_state
#import "../../../common/components/heading.typ": capitalize_or_underline_if_needed, get_styling_for_heading
#import "../../../common/template.typ": should_use_larger_text_to_highlight_state
#import "../../components/heading.typ": not_start_on_new_page
#import "../../components/page.typ": not_number_page, should_consider_only_odd_pages

#let include_outline_page() = context {
  let font_family_for_highlighted_text = font_family_for_highlighted_text_state.get()

  set text(
    font: font_family_for_highlighted_text,
  )

  not_number_page(
    not_start_on_new_page()[
      #page()[
        #show outline.entry: it => {
          let (
            font_size,
            leading,
            spacing,
            should_capitalize,
            font_weight,
            text_style,
            should_underline,
          ) = get_styling_for_heading(
            should_use_larger_text_to_highlight: should_use_larger_text_to_highlight_state.get(),
            it,
          )

          set text(
            font: font_family_for_highlighted_text,
            size: font_size,
            weight: font_weight,
            style: text_style,
          )

          set par(
            leading: leading,
            spacing: spacing,
            first-line-indent: 0cm,
          )

          let prefix = it.prefix()
          if it.element.supplement == [Apêndice] {
            prefix = [Apêndice #prefix #sym.dash.em]
          }
          if it.element.supplement == [Anexo] {
            prefix = [Anexo #prefix #sym.dash.em]
          }
          prefix = capitalize_or_underline_if_needed(
            should_capitalize: should_capitalize,
            should_underline: should_underline,
            prefix,
          )

          let inner = capitalize_or_underline_if_needed(
            should_capitalize: should_capitalize,
            should_underline: should_underline,
            it.inner(),
          )

          // NBR 14724:2024 5.2.2.
          // Headings must have a blank space of 1.5 above and below.
          block(
            below: spacing * 2,
          )[
            #link(
              it.element.location(),
              it.indented(
                [#prefix],
                inner,
              ),
            )
          ]
        }

        #outline(
          depth: 5,
          indent: 0cm,
        )
      ]

      #if not should_consider_only_odd_pages.get() {
        pagebreak(weak: true, to: "odd")
      }
    ],
  )
}
