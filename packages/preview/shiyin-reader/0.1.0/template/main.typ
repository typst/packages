#import "@preview/shiyin-reader:0.1.0": poem-book

#let book = (
  metadata: (
    title: "诗词读本",
    volume: "示例卷",
    edition: "2026",
    cover_mode: "general",
  ),
  format: (
    paper: "a4",
    columns: 2,
    gutter_pt: 28,
    body_size: 12,
    leading: 1.75,
    note_size: 9.5,
  ),
  notes: (mode: "short"),
  fonts: (
    body: ("Noto Serif CJK SC", "SimSun"),
    title: ("STKaiti", "KaiTi", "Noto Serif CJK SC"),
  ),
  branding: (
    school_name: "",
    school_name_en: "",
    slogan: "读诗 · 积累 · 成长",
    motto: "诗心常在　书香长伴",
    cover_lines: ("诗中有画", "画中有诗"),
    logo: "",
  ),
  front_matter: (
    title: "卷首语",
    preface: "读诗，是与古人对话，也是在汉字的声音里认识世界。\n\n愿这本小小的读本，陪你从春晓读到静夜，从明月读到高楼，在一次次诵读中，遇见更辽阔的天地。",
    paragraphs: (
      "读诗，是与古人对话，也是在汉字的声音里认识世界。",
      "愿这本小小的读本，陪你从春晓读到静夜，从明月读到高楼，在一次次诵读中，遇见更辽阔的天地。",
    ),
  ),
  features: (
    front_matter: true,
    famous_lines: true,
    poet_bio: true,
    author_index: true,
    end_page: true,
    back_cover: true,
  ),
  appendix: (
    famous_lines: (
      (quote: "春眠不觉晓，处处闻啼鸟。", source: "孟浩然《春晓》"),
      (quote: "举头望明月，低头思故乡。", source: "李白《静夜思》"),
      (quote: "欲穷千里目，更上一层楼。", source: "王之涣《登鹳雀楼》"),
    ),
    poet_heading: "【诗人简介】",
    poets: (
      (
        group: "唐",
        name: "孟浩然",
        years: "689—740",
        bio: "唐代诗人，襄阳人。",
      ),
      (
        group: "唐",
        name: "李白",
        years: "701—762",
        bio: "唐代诗人，字太白，号青莲居士。",
      ),
      (
        group: "唐",
        name: "王之涣",
        years: "688—742",
        bio: "唐代诗人，字季凌。",
      ),
      (
        group: "唐",
        name: "骆宾王",
        years: "约619—687",
        bio: "唐代诗人，婺州义乌人。",
      ),
    ),
    author_index: (
      (
        initial: "L",
        name: "李白",
        dynasty: "唐",
        poems: ((title: "静夜思", poem_id: "jingyesi"),),
      ),
      (
        initial: "L",
        name: "骆宾王",
        dynasty: "唐",
        poems: ((title: "咏鹅", poem_id: "yonge"),),
      ),
      (
        initial: "M",
        name: "孟浩然",
        dynasty: "唐",
        poems: ((title: "春晓", poem_id: "chunxiao"),),
      ),
      (
        initial: "W",
        name: "王之涣",
        dynasty: "唐",
        poems: ((title: "登鹳雀楼", poem_id: "dengguanquelou"),),
      ),
    ),
  ),
  chapters: (
    (
      name: "第一编 春晓",
      subname: "五言绝句",
      bg_color: "#E65100",
      poems: (
        (
          number: 1,
          poem_id: "chunxiao",
          title: "春晓",
          author: "（唐）孟浩然",
          lines: ("春眠不觉晓，处处闻啼鸟。", "夜来风雨声，花落知多少。"),
          notes: (
            (headword: "晓", text: "天刚亮的时候。"),
            (headword: "闻", text: "听见。"),
          ),
        ),
        (
          number: 2,
          poem_id: "jingyesi",
          title: "静夜思",
          author: "（唐）李白",
          lines: ("床前明月光，疑是地上霜。", "举头望明月，低头思故乡。"),
          notes: (
            (headword: "疑", text: "好像。"),
            (headword: "举头", text: "抬头。"),
          ),
        ),
      ),
    ),
    (
      name: "第二编 登鹳雀楼",
      subname: "五言绝句",
      bg_color: "#5E8B65",
      poems: (
        (
          number: 3,
          poem_id: "dengguanquelou",
          title: "登鹳雀楼",
          author: "（唐）王之涣",
          lines: ("白日依山尽，黄河入海流。", "欲穷千里目，更上一层楼。"),
          notes: (
            (headword: "穷", text: "尽，使达到极点。"),
            (headword: "千里目", text: "看到很远的地方。"),
          ),
        ),
        (
          number: 4,
          poem_id: "yonge",
          title: "咏鹅",
          author: "（唐）骆宾王",
          lines: ("鹅，鹅，鹅，曲项向天歌。", "白毛浮绿水，红掌拨清波。"),
          notes: (
            (headword: "曲项", text: "弯着脖子。"),
            (headword: "拨", text: "划动。"),
          ),
        ),
      ),
    ),
  ),
)

#show: poem-book.with(book: book)
