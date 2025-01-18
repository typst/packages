#import "/src/lib.typ": *
#set page(width: 16cm, height: auto)
#set text(font: "Noto Serif CJK JP", fallback: false)

#word-count(totals => [
  Hi，这里是中文测试。 #totals
])

#block(fill: orange.lighten(90%), inset: 1em)[
	#show: word-count

	一二三四五 six seven eight. 这句话里共有 #total-words 个词与 #total-characters 个字符.
]
