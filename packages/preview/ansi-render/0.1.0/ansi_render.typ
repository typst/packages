// add your theme here!
#let terminal_themes = (
	// vscode terminal theme
	vscode: (
		black: rgb(0, 0, 0),
		red: rgb(205, 49, 49),
		green: rgb(13, 188, 121),
		yellow: rgb(229, 229, 16),
		blue: rgb(36, 114, 200),
		magenta: rgb(188, 63, 188),
		cyan: rgb(17, 168, 205),
		white: rgb(229, 229, 229),
		gray: rgb(102, 102, 102),
		bright_red: rgb(214, 76, 76),
		bright_green: rgb(35, 209, 139),
		bright_yellow: rgb(245, 245, 67),
		bright_blue: rgb(59, 142, 234),
		bright_magenta: rgb(214, 112, 214),
		bright_cyan: rgb(41, 184, 219),
		bright_white: rgb(229, 229, 229),
		default_text: rgb(229, 229, 229), // white
		default_bg: rgb(0, 0, 0), // black
	),

	// putty terminal theme
	putty: (
		black: rgb(0, 0, 0),
		red: rgb(187, 0, 0),
		green: rgb(0, 187, 0),
		yellow: rgb(187, 187, 0),
		blue: rgb(0, 0, 187),
		magenta: rgb(187, 0, 187),
		cyan: rgb(0, 187, 187),
		white: rgb(187, 187, 187),
		gray: rgb(85, 85, 85),
		bright_red: rgb(255, 0, 0),
		bright_green: rgb(0, 255, 0),
		bright_yellow: rgb(255, 255, 0),
		bright_blue: rgb(0, 0, 255),
		bright_magenta: rgb(255, 0, 255),
		bright_cyan: rgb(0, 255, 255),
		bright_white: rgb(255, 255, 255),
		default_text: rgb(187, 187, 187), // white
		default_bg: rgb(0, 0, 0), // black
	),

	// themes from Windows Terminal
	Campbell: (
		black: rgb("#0C0C0C"),
		red: rgb("#C50F1F"),
		green: rgb("#13A10E"),
		yellow: rgb("#C19C00"),
		blue: rgb("#0037DA"),
		magenta: rgb("#881798"),
		cyan: rgb("#3A96DD"),
		white: rgb("#CCCCCC"),
		gray: rgb("#767676"),
		bright_red: rgb("#E74856"),
		bright_green: rgb("#16C60C"),
		bright_yellow: rgb("#F9F1A5"),
		bright_blue: rgb("#3B78FF"),
		bright_magenta: rgb("#B4009E"),
		bright_cyan: rgb("#61D6D6"),
		bright_white: rgb("#F2F2F2"),
		default_text: rgb("#CCCCCC"),
		default_bg: rgb("#0C0C0C"),
	),

	"Campbell Powershell": (
		black: rgb("#0C0C0C"),
		red: rgb("#C50F1F"),
		green: rgb("#13A10E"),
		yellow: rgb("#C19C00"),
		blue: rgb("#0037DA"),
		magenta: rgb("#881798"),
		cyan: rgb("#3A96DD"),
		white: rgb("#CCCCCC"),
		gray: rgb("#767676"),
		bright_red: rgb("#E74856"),
		bright_green: rgb("#16C60C"),
		bright_yellow: rgb("#F9F1A5"),
		bright_blue: rgb("#3B78FF"),
		bright_magenta: rgb("#B4009E"),
		bright_cyan: rgb("#61D6D6"),
		bright_white: rgb("#F2F2F2"),
		default_text: rgb("#CCCCCC"),
		default_bg: rgb("#012456"),
	),

	Vintage: (
		black: rgb("#000000"),
		red: rgb("#800000"),
		green: rgb("#008000"),
		yellow: rgb("#808000"),
		blue: rgb("#000080"),
		magenta: rgb("#800080"),
		cyan: rgb("#008080"),
		white: rgb("#C0C0C0"),
		gray: rgb("#808080"),
		bright_red: rgb("#FF0000"),
		bright_green: rgb("#00FF00"),
		bright_yellow: rgb("#FFFF00"),
		bright_blue: rgb("#0000FF"),
		bright_magenta: rgb("#FF00FF"),
		bright_cyan: rgb("#00FFFF"),
		bright_white: rgb("#FFFFFF"),
		default_text: rgb("#C0C0C0"),
		default_bg: rgb("#000000"),
	),

	"One Half Dark": (
		black: rgb("#282C34"),
		red: rgb("#E06C75"),
		green: rgb("#98C379"),
		yellow: rgb("#E5C07B"),
		blue: rgb("#61AFEF"),
		magenta: rgb("#C678DD"),
		cyan: rgb("#56B6C2"),
		white: rgb("#DCDFE4"),
		gray: rgb("#5A6374"),
		bright_red: rgb("#E06C75"),
		bright_green: rgb("#98C379"),
		bright_yellow: rgb("#E5C07B"),
		bright_blue: rgb("#61AFEF"),
		bright_magenta: rgb("#C678DD"),
		bright_cyan: rgb("#56B6C2"),
		bright_white: rgb("#DCDFE4"),
		default_text: rgb("#DCDFE4"),
		default_bg: rgb("#282C34"),
	),

	"One Half Light": (
		black: rgb("#383A42"),
		red: rgb("#E45649"),
		green: rgb("#50A14F"),
		yellow: rgb("#C18301"),
		blue: rgb("#0184BC"),
		magenta: rgb("#A626A4"),
		cyan: rgb("#0997B3"),
		white: rgb("#FAFAFA"),
		gray: rgb("#4F525D"),
		bright_red: rgb("#DF6C75"),
		bright_green: rgb("#98C379"),
		bright_yellow: rgb("#E4C07A"),
		bright_blue: rgb("#61AFEF"),
		bright_magenta: rgb("#C577DD"),
		bright_cyan: rgb("#56B5C1"),
		bright_white: rgb("#FFFFFF"),
		default_text: rgb("#383A42"),
		default_bg: rgb("#FAFAFA"),
	),

	"Solarized Dark": (
		black: rgb("#002B36"),
		red: rgb("#DC322F"),
		green: rgb("#859900"),
		yellow: rgb("#B58900"),
		blue: rgb("#268BD2"),
		magenta: rgb("#D33682"),
		cyan: rgb("#2AA198"),
		white: rgb("#EEE8D5"),
		gray: rgb("#073642"),
		bright_red: rgb("#CB4B16"),
		bright_green: rgb("#586E75"),
		bright_yellow: rgb("#657B83"),
		bright_blue: rgb("#839496"),
		bright_magenta: rgb("#6C71C4"),
		bright_cyan: rgb("#93A1A1"),
		bright_white: rgb("#FDF6E3"),
		default_text: rgb("#839496"),
		default_bg: rgb("#002B36"),
	),

	"Solarized Light": (
		black: rgb("#002B36"),
		red: rgb("#DC322F"),
		green: rgb("#859900"),
		yellow: rgb("#B58900"),
		blue: rgb("#268BD2"),
		magenta: rgb("#D33682"),
		cyan: rgb("#2AA198"),
		white: rgb("#EEE8D5"),
		gray: rgb("#073642"),
		bright_red: rgb("#CB4B16"),
		bright_green: rgb("#586E75"),
		bright_yellow: rgb("#657B83"),
		bright_blue: rgb("#839496"),
		bright_magenta: rgb("#6C71C4"),
		bright_cyan: rgb("#93A1A1"),
		bright_white: rgb("#FDF6E3"),
		default_text: rgb("#657B83"),
		default_bg: rgb("#FDF6E3"),
	),

	"Tango Dark": (
		black: rgb("#000000"),
		red: rgb("#CC0000"),
		green: rgb("#4E9A06"),
		yellow: rgb("#C4A000"),
		blue: rgb("#3465A4"),
		magenta: rgb("#75507B"),
		cyan: rgb("#06989A"),
		white: rgb("#D3D7CF"),
		gray: rgb("#555753"),
		bright_red: rgb("#EF2929"),
		bright_green: rgb("#8AE234"),
		bright_yellow: rgb("#FCE94F"),
		bright_blue: rgb("#729FCF"),
		bright_magenta: rgb("#AD7FA8"),
		bright_cyan: rgb("#34E2E2"),
		bright_white: rgb("#EEEEEC"),
		default_text: rgb("#D3D7CF"),
		default_bg: rgb("#000000"),
	),

	"Tango Light": (
		black: rgb("#000000"),
		red: rgb("#CC0000"),
		green: rgb("#4E9A06"),
		yellow: rgb("#C4A000"),
		blue: rgb("#3465A4"),
		magenta: rgb("#75507B"),
		cyan: rgb("#06989A"),
		white: rgb("#D3D7CF"),
		gray: rgb("#555753"),
		bright_red: rgb("#EF2929"),
		bright_green: rgb("#8AE234"),
		bright_yellow: rgb("#FCE94F"),
		bright_blue: rgb("#729FCF"),
		bright_magenta: rgb("#AD7FA8"),
		bright_cyan: rgb("#34E2E2"),
		bright_white: rgb("#EEEEEC"),
		default_text: rgb("#555753"),
		default_bg: rgb("#FFFFFF"),
	),
)

// ansi rendering function
#let ansi_render(body, font: "consolas", size: 11pt, theme: terminal_themes.vscode) = {
	// dict with text style
	let match_text = (
		"1": (weight: "bold"),
		"3": (style: "italic"),
		"23": (style: "normal"),
		"30": (fill: theme.black),
		"31": (fill: theme.red),
		"32": (fill: theme.green),
		"33": (fill: theme.yellow),
		"34": (fill: theme.blue),
		"35": (fill: theme.magenta),
		"36": (fill: theme.cyan),
		"37": (fill: theme.white),
		"39": (fill: theme.default_text),
		"90": (fill: theme.gray),
		"91": (fill: theme.bright_red),
		"92": (fill: theme.bright_green),
		"93": (fill: theme.bright_yellow),
		"94": (fill: theme.bright_blue),
		"95": (fill: theme.bright_magenta),
		"96": (fill: theme.bright_cyan),
		"97": (fill: theme.bright_white),
		"default": (weight: "regular", style: "normal", fill: theme.default_text)
	)
	// dict with background style
	let match_bg = (
		"40": (fill: theme.black),
		"41": (fill: theme.red),
		"42": (fill: theme.green),
		"43": (fill: theme.yellow),
		"44": (fill: theme.blue),
		"45": (fill: theme.magenta),
		"46": (fill: theme.cyan),
		"47": (fill: theme.white),
		"49": (fill: theme.default_bg),
		"100": (fill: theme.gray),
		"101": (fill: theme.bright_red),
		"102": (fill: theme.bright_green),
		"103": (fill: theme.bright_yellow),
		"104": (fill: theme.bright_blue),
		"105": (fill: theme.bright_magenta),
		"106": (fill: theme.bright_cyan),
		"107": (fill: theme.bright_white),
		"default": (fill: theme.default_bg)
	)

	let match_options(opt) = {
		// parse 38;5 48;5
		let parse_8bit_color(num) = {
			num = int(num)
			let colors = (0, 95, 135, 175, 215, 255)
			if num <= 7 { match_text.at(str(num+30)) }
			else if num <= 15 { match_bg.at(str(num+32)) }
			else if num <= 231 {
				num -= 16
				let (r, g, b) = (colors.at(int(num/36)), colors.at(calc.rem(int(num/6),6)), colors.at(calc.rem(num,6)))
				(fill: rgb(r, g, b))
			} else {
				num -= 232
				let (r, g, b) = (8+10*num, 8+10*num, 8+10*num)
				(fill: rgb(r, g, b))
			}
		}

		let (opt_text, opt_bg) = ((:), (:))
		let (ul, ol, reverse, last) = (none, none, none, none)
		let count = 0
		let color = (0, 0, 0)

		// match options
		for i in opt {
			if last == "382" or last =="482" {
				color.at(count) = int(i)
				count += 1
				if count == 3 {
					if last == "382" { opt_text += (fill: rgb(..color)) }
					else { opt_bg += (fill: rgb(..color)) }
					count = 0
					last = none
				}
				continue
			}
			else if last == "385" {
				opt_text += parse_8bit_color(i)
				last = none
				continue
			}
			else if last == "485" {
				opt_bg += parse_8bit_color(i)
				last = none
				continue
			}
			else if i == "0" {
				opt_text += match_text.default
				opt_bg += match_bg.default
				ul = false
				ol = false
				reverse = false
			}
			else if i in match_bg.keys() { opt_bg += match_bg.at(i) }
			else if i in match_text.keys() { opt_text += match_text.at(i) }
			else if i == "4" { ul = true }
			else if i == "24" { ul = false }
			else if i == "53" { ol = true }
			else if i == "55" { ol = false }
			else if i == "7" { reverse = true }
			else if i == "27" { reverse = false }
			else if i == "38" or i == "48" {
				last = i
				continue
			}
			else if i == "2" or i == "5" {
				if last == "38" or last == "48" {
					last += i
					count = 0
					continue
				}
			}
			last = none
		}
		(text: opt_text, bg: opt_bg, ul: ul, ol: ol, reverse: reverse)
	}

	let parse_option(body) = {
		let arr = ()
		let cur = 0
		for map in body.matches(regex("\x1b\[([0-9;]*)m([^\x1b]*)")) {
			// loop through all matches
			let str = map.captures.at(1)
			// split the string by newline and preserve newline
			let split = str.split("\n")
			for (k, v) in split.enumerate() {
				if k != split.len()-1 {
					v = v + "\n"
				}
				let temp = (v, ())
				for option in map.captures.at(0).split(";") {
					temp.at(1).push(option)
				}
				arr.push(temp)
			}
			cur += 1
		}
		arr
	}

	set text(..(match_text.default), font: font, size: size, top-edge: "ascender", bottom-edge: "descender")
	set par(leading: 0em)

	let option = (
		text: match_text.default,
		bg: match_bg.default,
		ul: false,
		ol: false,
		reverse: false
	)
	show: c => rect(..(match_bg.default), c)
	// work around for rendering first line without escape sequence
	body = "\u{1b}[0m" + body
	for (str, opt) in parse_option(body) {
		let m = match_options(opt)
		option.text += m.text
		option.bg += m.bg
		if m.reverse != none { option.reverse = m.reverse }
		if option.reverse {
			(option.text.fill, option.bg.fill) = (option.bg.fill, option.text.fill)
		}
		if m.ul != none { option.ul = m.ul }
		if m.ol != none { option.ol = m.ol }

		// hack for under/overline trailing whitespace
		str = str.replace(regex("([ \t]+)$"), m => m.captures.at(0) + "\u{200b}")
		{
			show: c => box(..option.bg, c)
			show: c => text(..option.text, c)
			show: c => if option.ul {
				underline(c)
			} else {
				c
			}
			show: c => if option.ol {
				overline(c)
			} else {
				c
			}
			[#str]
		}
		// fill trailing newlines
		let s =	str.find(regex("\n+$"))
		if s != none {
			for i in s {
				linebreak()
			}
		}
	}
}
