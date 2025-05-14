#import "@preview/cheda-seu-thesis:0.3.4": bachelor-trans-conf, bachelor-utils
#let (thanks, show-appendix) = bachelor-utils


#show: bachelor-trans-conf.with(
  student-id: "00121001",
  author: "王东南",
  school: "示例学院",
  major: "示例专业",
  advisor: "湖牌桥",
  thesis-name-cn: "新兴排版方式下的摸鱼科学优化研究",
  thesis-name-raw: "Optimization of Fish-Touching Strategies \n in Emerging Typesetting Environments",
  date: "某个完成日期",
  cn-abstract: [示例摘要],
  cn-keywords: ("关键词1", "关键词2"),
  en-abstract: [如果需要隐藏英文摘要页，只需要将 `en-abstract` 和 `en-keywords` 都设为 none。 \ #lorem(100)],
  en-keywords: ("Keywords1", "Keywords2"),
  outline-depth: 3,
)

= 使用说明

翻译模板的使用方法与毕设模板完全相同，因此不再重复叙述。
