#import "@preview/joho-ipsj:0.1.0": acknowledgement, fake-bibliography, table, techrep

#import "@preview/roremu:0.1.0": roremu

#techrep(
  title: [Typstによる情報処理研究報告の作成法],
  title-en: "How to write IPSJ SIG Technical Report with Typst",
  // title_en: [Template for IPSJ Technical Report using Typst],
  affiliations: (
    "IPSJ": [情報処理学会 \ IPSJ, Chiyoda, Tokyo 101–0062, Japan],
  ),
  paffiliations: (
    "JU": [現在，情報処理大学 \ Presently with Johoshori University],
  ),
  authors: (
    (
      name: "情報 太郎",
      name-en: "Taro Joho",
      affiliations: ("IPSJ",),
      email: "joho.taro@ipsj.or.jp",
    ),
    (
      name: "処理 花子",
      name-en: "Hanako Shori",
      affiliations: ("IPSJ",),
      email: none,
    ),
    (
      name: "学会 次郎",
      name-en: "Jiro Gakkai",
      affiliations: ("IPSJ", "JU"),
      email: "gakkai.jiro@ipsj.or.jp",
    ),
  ),
  abstract: [
    #roremu(250)
  ],
  keywords: ("情報処理学会", "研究報告", "Typst"),
  abstract-en: [
    #lorem(150)
  ],
  keywords-en: ("IPSJ", "Technical Report", "Typst"),
  [
    = はじめに
    #roremu(50)@Word
    $E=m c^2$
    #roremu(50, offset: 50)#footnote("脚注の例")
    $ E=m c^2 $
    #roremu(50, offset: 100)#footnote("脚注の例その2")

    = 本論

    #roremu(500)@LaTeX

    = コードブロック
    ```
    fn main() {
      println!("Hello, world!");
    }
    ```

    = おわりに

    #roremu(150)@XeLaTeX
  ],
  bibliography: [
    #bibliography("refs.yml", title: "参考文献")
    #fake-bibliography(yaml("refs.yml"), show-unused: false)
  ],
)
