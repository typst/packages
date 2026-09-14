#set page(width: 10cm, height: auto)

#import "@preview/cellpress-unofficial:0.1.0" as cellpress

#show: cellpress.style-table

= Example table

As seen in @tbl-foo, #lower(lorem(8))

#figure(
	caption: [Table caption],
	table(
		columns: 3,
		cellpress.toprule(),
		table.header([foobar], [baz], [qux]),
		cellpress.midrule(),
		cellpress.tabsubhdr(colspan: 3)[qwerty],
		cellpress.midrule(),
		[a], [b], [c],
		[d], [e], [f],
		cellpress.midrule(),
		cellpress.tabsubhdr(colspan: 3)[asdf],
		cellpress.midrule(),
		[g], [h], [i],
		[j], [k], [l],
		[m], [n], [o],
		cellpress.bottomrule(),
	)
) <tbl-foo>
