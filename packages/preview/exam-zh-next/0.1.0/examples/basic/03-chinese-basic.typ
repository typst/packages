// 语文：材料、选择标记、古诗与作文格。

#import "../../src/lib.typ": *

#show: exam.with(title: [高中语文练习卷], subject: [语文])

#make-title()

= 现代文阅读

#material(title: [春日小记], author: [佚名], source: [（节选）])[
    清晨，阳光越过窗台，照亮书桌上的一页纸。远处的树叶在风中轻轻摇动，新的一天就这样安静地开始了。
]

#question[
    下列词语中，加点字读音正确的一项是
    #select(show-mark: true, answer: 2)[安静（jìn）][摇动（yáo）][清晨（qīng）]
]

= 古诗文阅读

#poem(title: [登鹳雀楼], author: [王之涣])[
    白日依山尽，\
    黄河入海流。\
    欲穷千里目，\
    更上一层楼。
]

= 写作

请以“窗外”为题，写一篇不少于 800 字的文章。

#composition-grid(1000, row-sep-ratio: 3, count-marks: (600, 800))
