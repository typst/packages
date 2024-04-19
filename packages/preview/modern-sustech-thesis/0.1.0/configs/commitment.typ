#import "font.typ" as fonts


#let commitment(
  isCN: true
) = {
  let title = [title]
  let pars = ([], [])

  let title-CN = [诚信承诺书]
  let content-CN = (
    [1. 本人郑重承诺所呈交的毕业设计（论文），是在导师的指导下， 独立进行研究工作所取得的成果，所有数据、图片资料均真实可靠。],
    [2. 除文中已经注明引用的内容外，本论文不包含任何其他人或 集体已经发表或撰写过的作品或成果。对本论文的研究作出重要贡 献的个人和集体，均已在文中以明确的方式标明。],
    [3. 本人承诺在毕业论文（设计）选题和研究内容过程中没有抄袭他人研究成果和伪造相关数据等行为。],
    [4. 在毕业论文（设计）中对侵犯任何方面知识产权的行为，由本 人承担相应的法律责任。],
  )

  let title-EN = [COMMITMENT OF HONESTY]
  let content-EN = (
    [1. I solemnly promise that the paper presented comes from my independent research work under my supervisor's supervision. All statistics and images are real and reliable.],
    [2. Except for the annotated reference, the paper contents no other published work or achievement by person or group. All people making important contributions to the study of the paper have been indicated clearly in the paper.],
    [3. I promise that I did not plagiarize other people's research achievement or forge related data in the process of designing topic and research content.],
    [4. If there is violation of any intellectual property right, I will take legal responsibility myself.],
  )

  if(isCN){
    title = title-CN
    pars = content-CN
  }else{
    title = title-EN
    pars = content-EN
  }

  set text(
    font: fonts.SongTi,
    weight: "medium",
    size: fonts.No4,
  )

  align(center)[
    #text(
      font: fonts.HeiTi,
      size: fonts.No2,
    )[
      #title
    ]
  ]

  linebreak(justify: true)
  linebreak(justify: true)

  set par(
    leading: 1.5em,
    justify: true,
  )

  for i in pars{
    par()[#i]
    linebreak(justify: true)
  }


  align(right)[
    #if(isCN){
      box(
        width: 10em,
        baseline: 8em,
        )[
          #align(left)[
            作者签名：
            #linebreak()
            日#h(2em)期：
          ]
      ]
    }else{
      box(
        width: 10em,
        baseline: 8em,
        )[
          #align(left)[
            Signature:
            #linebreak()
            Ddate:
          ]
      ]
    }
  ]
}