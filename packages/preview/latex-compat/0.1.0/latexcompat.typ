#let _calc_ext_mask_dec(value, position) = {
  // _calc_ext_mask_dec(468, 1) = 8
  // _calc_ext_mask_dec(468, 2) = 6
  // _calc_ext_mask_dec(468, 3) = 4
  let pow = calc.pow(10, position);
  let rem = calc.rem-euclid(value, pow);
  let my_result = (rem - calc.rem-euclid(value, pow/10) ) * 10 / pow;
  return my_result;
}
#let today() = datetime.today().display()
#let _roman_font = state("fontspec_roman_font", none)
#let _sans_font = state("fontspec_sans_font", none)
#let _mono_font = state("fontspec_mono_font", none)

// "series"
#let fontspec_flag_bf = state("fontspec_flag_bf", none)
#let bfseries() = context fontspec_flag_bf.update(true)
#let mdseries() = context fontspec_flag_bf.update(false)

// "shape"
#let fontspec_flag_it = state("fontspec_flag_it", none)
#let itshape() = context fontspec_flag_it.update(true)
#let upshape() = context fontspec_flag_it.update(false)



#let setromanfont(input_font_spec) = {
  _roman_font.update(input_font_spec)
}

#let setsansfont(input_font_spec) = {
  _sans_font.update(input_font_spec)
}

#let setmonofont(input_font_spec) = {
  _mono_font.update(input_font_spec)
}



// NOTE: Mutating context aggressively might cause layout convergence warning

// NOTE: Possible alternative approach: https://discord.com/channels/1054443721975922748/1391247361455689790/1391489700027695234

#let textbf(content) = context {
  let tmp_flag = fontspec_flag_bf.get()
  [#bfseries();#content]
  fontspec_flag_bf.update(tmp_flag)
}
#let textmd(content) = context {
  let tmp_flag = fontspec_flag_bf.get()
  [#mdseries();#content]
  fontspec_flag_bf.update(tmp_flag)
}

#let textup(content) = context {
  let tmp_flag = fontspec_flag_it.get()
  [#upshape();#content]
  fontspec_flag_it.update(tmp_flag)
}
#let textit(content) = context {
  let tmp_flag = fontspec_flag_it.get()
  [#itshape();#content]
  fontspec_flag_it.update(tmp_flag)
}


#let textrm(content) = {
  context {
    let font = _roman_font.get()
    if font != none {
      text(font: font, content)
    } else {
      text(font: "serif", content)
    }
  }
}

#let textsf(content) = {
  context {
    let font = _sans_font.get()
    if font != none {
      text(font: font, content)
    } else {
      text(font: "sans-serif", content)
    }
  }
}

#let texttt(content) = {
  context {
    let font = _mono_font.get()
    if font != none {
      text(font: font, content)
    } else {
      text(font: "monospace", content)
    }
  }
}


// Really this this API?
// #let fontsize(content) = {
//   text(size: length, content)
// }




// Styling lambda mapping
#let _fontspec_super_text_styler(mask, content) = context {
  // ====================================================
  // mask default value is 111 meaning rm/md/up
  // 222 means sf/bf/it
  // 3** means tt/*/*
  // ====================================================
  // Parse mask...
  let f_rmsftt = _calc_ext_mask_dec(mask, 3)
  let f_mdbf = _calc_ext_mask_dec(mask, 2)
  let f_upit = _calc_ext_mask_dec(mask, 1)
  // Default stylers
  let tf_1 = textrm
  let tf_2 = textmd
  let tf_3 = textup
  // Override stylers
  if (f_rmsftt == 2) { tf_1 = textsf }
  if (f_rmsftt == 3) { tf_1 = texttt }
  if (f_mdbf == 2) { tf_2 = textbf }
  if (f_upit == 2) { tf_3 = textit }
  tf_1(tf_2(tf_3(content)))
}




// Miscellaneous...
#let hrulefill = box(width: 1fr, stroke: (bottom: 0.4pt + black))


#let LaTeX = context {
  box(baseline: 24%, {
    [L]
    h(-0.2em)
    box(baseline: -33%, text(size: 0.75em)[A])
    h(-0.05em)
    [T]
    h(-0.05em)
    box(baseline: 33%, [E])
    h(-0.05em)
    [X]
  })
}


#let hspace(width) = context {
  box(width: width, repeat(sym.space.nobreak))
}


#let fboxsep = state("fboxsep", 0.4em)
#let fboxrule = state("fboxrule", 0.4pt)
#let fboxcolor = state("fboxcolor", black)
#let fbox(content) = context {
  box(stroke: fboxrule.get() + fboxcolor.get(), inset: fboxsep.get(), baseline: fboxsep.get(), content)
}






// xcolor
#let pagecolor(fill_color) = context { set page(fill: fill_color) }

#let _at_title = state("document_title", ["Document Title"])
#let _at_author = state("document_author", ["Author"])
#let _at_date = state("document_date", ["Date"])


// Set title, author, and date
#let title(content) = {
  _at_title.update(content)
}
#let author(content) = {
  _at_author.update(content)
}
#let date(content) = {
  _at_date.update(content)
}

#let ATtitle = {
  context {
    _at_title.at(here())
  }
}
#let ATauthor = {
  context {
    _at_author.at(here())
  }
}
#let ATdate = {
  context {
    _at_date.at(here())
  }
}


#let maketitle() = {
  context {
    align(center)[
      #textrm[
        #text(size: 1.6em)[#ATtitle]
        #v(-3pt)

        #text(size: 1em)[#ATauthor]

        #text(size: 1em)[#ATdate]
      ]
    ]
    v(1.5em)
  }
}
// Counters
#let sectsty_sectioning_number_width_h1 = state("sectsty_sectioning_number_width_h1", 36pt)
#let sectsty_sectioning_number_width_h2 = state("sectsty_sectioning_number_width_h2", 36pt)
#let sectsty_sectioning_number_width_h3 = state("sectsty_sectioning_number_width_h3", 36pt)

// Spacing
#let sectsty_spacing_pre_h1 = state("sectsty_spacing_pre_h1", 1.3em)
#let sectsty_spacing_pre_h2 = state("sectsty_spacing_pre_h2", 0.7em)
#let sectsty_spacing_pre_h3 = state("sectsty_spacing_pre_h3", 0.3em)

// Font size
#let sectsty_fontsize_h1 = state("sectsty_fontsize_h1", 1.35em)
#let sectsty_fontsize_h2 = state("sectsty_fontsize_h2", 1.12em)
#let sectsty_fontsize_h3 = state("sectsty_fontsize_h3", 1.0em)

// Font family/weight/style
#let sectsty_h1_style = state("sectsty_h1_style", 121)
#let sectsty_h2_style = state("sectsty_h2_style", 121)
#let sectsty_h3_style = state("sectsty_h3_style", 121)






#let section(numbered: true, content) = context {
  block({
    v(sectsty_spacing_pre_h1.get())
    text(size: sectsty_fontsize_h1.get(), [#_fontspec_super_text_styler(sectsty_h1_style.get(), [
        #if (numbered) {
          counter(heading).step(level: 1)
          box(width: sectsty_sectioning_number_width_h1.get())[#context { counter(heading).display() }. ]
        }
        #content
      ])])
  })
}
#let subsection(numbered: true, content) = context {
  block({
    v(sectsty_spacing_pre_h2.get())
    text(size: sectsty_fontsize_h2.get(), [#_fontspec_super_text_styler(sectsty_h2_style.get(), [
        #if (numbered) {
          counter(heading).step(level: 2)
          box(width: sectsty_sectioning_number_width_h2.get())[#context { counter(heading).display() }. ]
        }
        #content
      ])])
  })
}
#let subsubsection(numbered: true, content) = context {
  block({
    v(sectsty_spacing_pre_h3.get())
    text(size: sectsty_fontsize_h3.get(), [#_fontspec_super_text_styler(sectsty_h3_style.get(), [
        #if (numbered) {
          counter(heading).step(level: 3)
          box(width: sectsty_sectioning_number_width_h3.get())[#context { counter(heading).display() }. ]
        }
        #content
      ])])
  })
}
// Enabled this show rule to fix CJK punct width
#let CJK_PunctStylePlain(doc) = {
  show regex("[，。、]"): it => box(width: 1em, align(left, it))
  show regex("[！？；：（）【】「」『』❲❳［］]"): it => box(width: 1em, align(center, it))
  doc
}
#let __state_documentclass_params = state("__state_documentclass_params", ())


#let documentclass(..params) = {
  let _docinit(doc) = {
    // Define defaults
    let defaults = (fontsize: 10pt, font: "Latin Modern Roman")

    // Merge user params into defaults
    // .named() extracts only the key-value pairs from the arguments
    let final_params = defaults + params.named()

    __state_documentclass_params.update(final_params)

    context {
      let current = __state_documentclass_params.get()
      set text(size: current.fontsize, font: current.font)
      doc
    }
  }
  return _docinit
}
// In using:
// #show: documentclass(fontsize: 10pt)
