#import "packages.typ": int-to-cn-num
#import "states.typ": part-state
#import "fonts.typ": 字体, 字号

#let number-with-circle(
  num,
) = "①②③④⑤⑥⑦⑧⑨⑩⑪⑫⑬⑭⑮⑯⑰⑱⑲⑳㉑㉒㉓㉔㉕㉖㉗㉘㉙㉚㉛㉜㉝㉞㉟㊱㊲㊳㊴㊵㊶㊷㊸㊹㊺㊻㊼㊽㊾㊿".clusters().at(
  num - 1,
  default: "®",
)

#let chinese-numbering(
  ..nums,
  in-appendix: false,
  brackets: false,
) = context {
  if not in-appendix {
    if nums.pos().len() == 1 {
      "第" + int-to-cn-num(nums.pos().first()) + "章"
    } else {
      numbering(
        if brackets {
          "(1.1)"
        } else {
          "1.1"
        },
        ..nums,
      )
    }
  } else {
    if nums.pos().len() == 1 {
      "附录 " + numbering("A.1", ..nums)
    } else {
      numbering(
        if brackets {
          "(A.1)"
        } else {
          "A.1"
        },
        ..nums,
      )
    }
  }
}