// 字体家族设置 / Font family settings
#let cjk-serif-family = (           // 衬线字体 / Serif font family
    "寒蟬錦書宋",             // HanChanJinShuSong Pro
    "LXGW WenKai",              // 霞鹜文楷 / LXGW WenKai
    "思源宋体 CN",              // Source Han Serif CN
    "Songti SC",                // 宋体 SC / Songti SC
    "SimSun",                   // 宋体 / SimSun
)

#let cjk-sans-family = (            // 无衬线字体 / Sans-serif font family
    "Sarasa Fixed SC",           // 更纱黑体 SC / Sarasa Fixed SC
    "思源黑体 CN",              // Source Han Sans CN
    "Inter",                    // Inter font
    "PingFang SC",              // 苹方 SC / PingFang SC
    "SimHei"                    // 黑体 / SimHei
)

#let cjk-mono-family = (            // 等宽字体 / Monospace font family
    "霞鹜文楷 Mono",            // LXGW WenKai Mono
    "WenQuanYi Zen Hei Mono",   // 文泉驿正黑等宽 / WenQuanYi Zen Hei Mono
    "JetBrains Mono",           // JetBrains Mono
    "Source Code Pro",          // Source Code Pro
    "Noto Sans Mono CJK SC",    // Noto Sans Mono CJK SC
    "Menlo",                    // Menlo
    "Consolas",                 // Consolas
)

#let cjk-art-family = ( // 标题字体 / Title font family
    "DuanNingMaoBiXiaoKai", // 段宁毛笔小楷 / DuanNingMaoBiXiaoKai
)

#let cjk-bold-family =( // 粗体字体 / Bold font family
    "寒蟬錦書宋Pro", // HanChanJinShuSong Pro Soft
)

#let cjk-italic-family =( // 斜体字体 / Italic font family
    "Smiley Sans",
)

#let latin-serif-family = (         // 拉丁衬线字体 / Latin serif font family
    "Times New Roman",          // Times New Roman
    "Georgia",                  // Georgia
)

#let latin-sans-family = (          // 拉丁无衬线字体 / Latin sans-serif font family
    "Times New Roman",          // Times New Roman
    "Georgia",                  // Georgia
)

#let latin-mono-family = (          // 拉丁等宽字体 / Latin monospace font family
    "JetBrains Mono",           // JetBrains Mono
    "Consolas",                 // Consolas
    "Menlo",                    // Menlo
)

#let latin-art-family = (         // 拉丁标题字体 / Latin title font family
    
)

#let latin-bold-family =( // 拉丁粗体字体 / Latin bold font family
    "Times New Roman Bold",     // Times New Roman Bold
    "Georgia Bold",             // Georgia Bold
)

#let latin-italic-family =( // 拉丁斜体字体 / Latin italic font family
    "Times New Roman Italic",   // Times New Roman Italic
    "Georgia Italic",           // Georgia Italic
)

// 合并中英文字体家族 / Merge Chinese and English font families
#let serif-family = latin-serif-family + cjk-serif-family
#let sans-family = latin-sans-family + cjk-sans-family
#let mono-family = latin-mono-family + cjk-mono-family
#let art-font = latin-art-family + cjk-art-family
#let bold-family = latin-bold-family + cjk-bold-family
#let italic-family = latin-italic-family + cjk-italic-family
