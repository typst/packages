#let digit-names = (
	none,
	(m: "один", f: "одна"),
	(m: "два", f: "две"),
	"три",
	"четыре",
	"пять",
	"шесть",
	"семь",
	"восемь",
	"девять",
);
#let ten-names = (
	none,
	"десять",
	"двадцать",
	"тридцать",
	"сорок",
	"пятьдесят",
	"шестьдесят",
	"семьдесят",
	"восемьдесят",
	"девяносто",
);
#let teen-names = (
	"десять",
	"одиннадцать",
	"двенадцать",
	"тринадцать",
	"четырнадцать",
	"пятнадцать",
	"шестнадцать",
	"семнадцать",
	"восемнадцать",
	"девятнадцать",
);
#let hundred-names = (
	none,
	"сто",
	"двести",
	"триста",
	"четыреста",
	"пятьсот",
	"шестьсот",
	"семьсот",
	"восемьсот",
	"девятьсот",
);
#let agree-noun(t, o, decl) = {
	if t == 1 {
		decl.gen-pl
	} else if o == 1 {
		decl.nom-sg
	} else if o >= 5 or o == 0 {
		decl.gen-pl
	} else {
		decl.gen-sg
	}
}
#let agree-num(noun, num) = {
	if type(num) == dictionary {
		num.at(noun.gender)
	} else {
		num
	}
}
#let decl(..pat) = base => pat.named().pairs().map(((form, end)) => (form, base + end)).to-dict();
#let decl-fi4a = decl(
	nom-sg: "а",
	gen-sg: "и",
	gen-pl: "",
);
#let decl-mi1a = decl(
	nom-sg: "",
	gen-sg: "а",
	gen-pl: "ов",
);
#let scale-names = (
	(
		gender: "m",
		nom-sg: none,
		gen-sg: none,
		gen-pl: none,
	),
	decl-fi4a("тысяч") + (gender: "f"),
	..(
		"миллион",
		"миллиард",
		..(
			"тр",
			"квадр",
			"квинт",
			"секст",
			"септ",
			"окт",
			"нон",
			"дец",
			"ундец",
			"дуодец",
			"тредец",
			"кваттордец",
			"квиндец",
			"сексдец",
			"септдец",
			"дуодевигинт",
			"ундевигинт",
			"вигинт",
		).map(x => x + "иллион"),
	)
	.map(decl-mi1a)
	.map(x => x + (gender: "m"))
);
#let convert-group(digits, scale-idx, options) = {
	let hund = int(digits.at(0));
	let (tens, ones) = digits.slice(1).codepoints().map(int);
	let res = (
		hundred-names.at(hund),
	);
	if tens == 1 {
		res.push(teen-names.at(ones));
	} else {
		res += (
			ten-names.at(tens),
			agree-num(
				scale-names.at(scale-idx),
				digit-names.at(ones),
			),
		);
	};
	res.filter(x => x != none).join(" ")
}
#let join-parts(parts, options) = {
	parts
		.map(((scale, text, digits)) => (
			text,
			agree-noun(
				..digits.slice(1).codepoints().map(int),
				scale-names.at(scale),
			),
		))
		.flatten()
		.filter(x => x != none)
		.join(" ")
}
#let format-negative(x) = "минус " + x;

#let lang-config = (
	zero-name: "ноль",
	convert-group: convert-group,
	join-parts: join-parts,
	format-negative: format-negative,
);
