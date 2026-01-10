// PPT模板使用示例 - 展示所有功能
#import "@preview/storytiles:0.0.1": *

#show: doc => ppt-conf(
  title: "image-ppt 模板",
  author: "xbtt",
  theme: rgb("#1f4e79"),
  font-size: 12pt,
  doc,
)

// 标题页
#title-page(
  main-title: "image-ppt 模板",
  subtitle: "功能演示与使用指南",
  author: "xbtt",
  institution: "开源项目",
  is-first-page: true,
  // logo: image("typst_logo.jpg")  // 如果需要logo可以取消注释
)

// 目录页
#outline-page()

// 1. 标准四图片页面（显示页眉页脚）
#four-image-page(
  title: "标准模式展示",
  images: (
    image("typst_logo.jpg"), // 测试图片
    none, // 占位符
    image("typst_logo.jpg"), // 测试图片
    none, // 占位符
  ),
  captions: (),
  content: [
    #floating-box(
      x: 35%,
    )[
      *标准模式特点*：

      - ✅ 显示页眉和页脚
      - ✅ 图片使用标准尺寸（35% × 40%）
      - ✅ 支持图片说明文字
      - ✅ 支持额外文字内容
    ]

  ],
)

// 2. 无页眉页脚模式（图片自动放大）
#four-image-page(
  title: "无页眉页脚模式",
  show-header: false, // 隐藏页眉
  show-footer: false, // 隐藏页脚
  images: (
    image("typst_logo.jpg"),
    image("typst_logo.jpg"),
    none,
    none,
  ),
  captions: ("1", "1", "1", "1"),
  content: [
    #floating-box(
      x: 35%,
    )[
      *无页眉页脚模式特点*：

      - ❌ 隐藏页眉和页脚
      - ✅ 图片尺寸自动增大（40% × 40%）
      - ✅ 更多显示空间
      - ✅ 适合图片重点展示
    ]
  ],
)

// 3. 全屏图片模式（最大化显示）
#four-image-page(
  show-header: false,
  show-footer: false,
  title: none, // 无标题
  content: none, // 无额外内容
  gap: 0.0em,
  images: (
    image("typst_logo.jpg"), // 全屏模式图片更大
    image("typst_logo.jpg"),
    image("typst_logo.jpg"),
    image("typst_logo.jpg"),
  ),
  captions: (), // 无说明文字
)

// 4. 只隐藏页眉的模式
#four-image-page(
  title: "只隐藏页眉模式",
  show-header: false, // 隐藏页眉
  show-footer: true, // 显示页脚
  images: (
    figure(image("typst_logo.jpg"), caption: "图片1"),
    none,
    none,
    image("typst_logo.jpg"),
  ),
  captions: ("图片1", "", "", "图片4"),
  content: [
    #floating-box(
      x: 35%,
    )[
      *只隐藏页眉模式特点*：

      - ❌ 隐藏页眉
      - ✅ 保留页脚
      - ✅ 适合需要页码但不需要标题的场景
    ]
  ],
)

// 5. 只隐藏页脚的模式
#four-image-page(
  title: "只隐藏页脚模式",
  show-header: true, // 显示页眉
  show-footer: false, // 隐藏页脚
  images: (
    none,
    image("typst_logo.jpg"),
    image("typst_logo.jpg"),
    none,
  ),
  captions: ("", "图片2", "图片3", ""),
  content: [
    #floating-box(
      x: 35%,
    )[
      *只隐藏页脚模式*：

      - ✅ 保留页眉
      - ❌ 隐藏页脚
      - ✅ 适合不需要页码的展示场景
    ]
  ],
)// 6. 线性布局展示
#four-image-page(
  title: "线性布局模式",
  layout: "linear", // 线性排列
  images: (
    image("typst_logo.jpg"),
    none,
    image("typst_logo.jpg"),
    none,
  ),
  captions: (
    "线性图1",
    "占位符",
    "线性图2",
    "占位符",
  ),
  content: [
    *线性布局特点*：

    - ✅ 垂直排列图片
    - ✅ 适合流程展示
    - ✅ 图片更大（60% × 80%）
    - ✅ 更适合长图显示
  ],
)

// 7. 线性布局全屏模式
#four-image-page(
  show-header: false,
  show-footer: false,
  layout: "linear",
  title: none,
  content: none,
  images: (
    image("typst_logo.jpg"),
    image("typst_logo.jpg"),
    none,
  ),
  captions: ("", "", ""),
)

// 8. 自定义布局页面
#custom-layout-page(
  title: "自定义布局展示",
  content: [
    这个页面演示了自定义图片位置功能：

    - ✅ 自由控制图片位置（x, y坐标）
    - ✅ 自定义图片大小（width, height）
    - ✅ 支持图片说明文字
    - ✅ 灵活的页面布局

    右上角和左下角分别放置了测试图片。
  ],
  images: (
    (
      content: image("typst_logo.jpg"),
      x: 60%,
      y: 10%,
      width: 35%,
      height: 25%,
      caption: "右上角图片",
    ),
    (
      content: image("typst_logo.jpg"),
      x: 5%,
      y: 60%,
      width: 30%,
      height: 20%,
      caption: "左下角图片",
    ),
    (
      content: none, // 占位符示例
      x: 70%,
      y: 70%,
      width: 25%,
      height: 15%,
      caption: "占位符",
    ),
  ),
)

// 9. 纯文字页面
#text-page(
  title: "使用说明",
  content: [
    = 模板功能概览

    本PPT模板提供了以下主要功能：

    == 页面类型
    - *标题页*：演示文稿封面
    - *目录页*：自动生成目录
    - *四图片页*：2×2网格或线性布局
    - *自定义布局页*：自由控制图片位置
    - *纯文字页*：支持多栏布局

    == 页眉页脚控制
    - `show-header: true/false` - 控制页眉显示
    - `show-footer: true/false` - 控制页脚显示
    - 图片大小根据页面空间自动调整

    == 图片处理
    - 在主文件中使用 `image()` 函数加载图片
    - 支持相对路径和绝对路径
    - 自动错误处理，显示友好占位符
    - 支持多种图片格式

    == 尺寸自适应
    - *全屏模式*：49.5% × 100%（网格）
    - *无边框模式*：40% × 100%（网格）
    - *标准模式*：35% × 100%（网格）
    - *线性布局*：更大的垂直空间

    == 使用建议

    1. *图片准备*：建议使用统一尺寸的图片
    2. *路径管理*：推荐使用相对路径，便于项目移植
    3. *内容规划*：合理安排文字和图片的比例
    4. *样式定制*：可以修改主题色和字体大小
  ],
  column-count: 2,
)

// 10. 自定义尺寸示例
#four-image-page(
  title: "自定义尺寸示例",
  images: (
    image("typst_logo.jpg"),
    image("typst_logo.jpg"),
    image("typst_logo.jpg"),
    image("typst_logo.jpg"),
  ),
  grid-align-x: left, // 图片水平居中
  captions: ("小图1", "小图2", "小图3", "小图4"),
  image-height: 25%, // 自定义高度
  image-width: 30%, // 自定义宽度
  content: [
    #floating-box()[
      *自定义尺寸功能*：

      - ✅ 手动指定图片高度：25%
      - ✅ 手动指定图片宽度：30%
      - ✅ 覆盖自动计算的尺寸
      - ✅ 适合特殊布局需求
    ]
  ],
)

// 11. 浮动内容框基础示例
#four-image-page(
  title: "浮动内容框演示",
  images: (
    image("typst_logo.jpg"),
    image("typst_logo.jpg"),
    none,
    none,
  ),
  captions: ("背景图1", "背景图2", "", ""),
  content: [
    #floating-box(
      x: 5%,
      y: 5%,
    )[
      *浮动内容框功能*：

      - ✅ 在页面任意位置添加内容框
      - ✅ 自定义位置和大小
      - ✅ 支持半透明背景
      - ✅ 可选阴影效果
      - ✅ 层级控制（浮在其他内容上方）

      右下角有一个浮动的提示框 →]
    // 添加右下角的浮动提示框
    #floating-box(
      [
        = 💡 重要提示

        这是一个浮动的内容框，可以放置在页面的任意位置！

        *特点*：
        - 半透明背景
        - 圆角边框
        - 阴影效果
      ],
      x: 65%, // 距页面左边65%
      y: 50%, // 距页面顶部50%（页面中间）
      width: 30%,
      background: rgb(255, 255, 255, 200),
      border-color: rgb("#e74c3c"),
      border-width: 2pt,
      shadow: true,
    )

  ],
)



// 12. 多个浮动框组合示例
#text-page(
  title: "多浮动框组合",
  column-count: 2,
  content: [
    = 浮动内容框高级用法

    这个页面展示了如何在同一页面使用多个浮动框：

    == 用途示例
    - *注释框*：为特定内容添加解释
    - *警告框*：突出显示重要信息
    - *提示框*：提供额外的帮助信息
    - *装饰框*：增强页面视觉效果

    == 设计建议
    1. 避免过多浮动框，影响阅读
    2. 保持一致的视觉风格
    3. 合理安排位置，避免遮挡主要内容
    4. 使用不同颜色区分不同类型的信息

    各个角落都有不同类型的浮动框示例。
  ],
)

// 左上角 - 注释框
#floating-box(
  [
    *📝 注释*

    这里可以添加对主要内容的补充说明。
  ],
  x: 5%, // 距页面左边5%
  y: 15%, // 距页面顶部15%
  width: 20%,
  background: rgb(255, 255, 224, 200), // 淡黄色
  border-color: rgb("#f39c12"),
  shadow: false,
)

// 右上角 - 警告框
#floating-box(
  [
    *⚠️ 重要*

    关键信息提醒，请注意查看！
  ],
  x: 75%, // 距页面左边75%
  y: 15%, // 距页面顶部15%
  width: 20%,
  background: rgb(255, 240, 240, 200), // 淡红色
  border-color: rgb("#e74c3c"),
  border-width: 2pt,
)

// 左下角 - 提示框
#floating-box(
  [
    *💡 提示*

    有用的小贴士和建议。
  ],
  x: 5%, // 距页面左边5%
  y: 75%, // 距页面顶部75%
  width: 20%,
  background: rgb(240, 248, 255, 200), // 淡蓝色
  border-color: rgb("#3498db"),
  border-radius: 8pt,
)

// 右下角 - 装饰框
#floating-box(
  [
    *🎨 装饰*

    美化页面的装饰元素。
  ],
  x: 75%, // 距页面左边75%
  y: 75%, // 距页面顶部75%
  width: 20%,
  background: rgb(248, 255, 248, 200), // 淡绿色
  border-color: rgb("#27ae60"),
  border-radius: 10pt,
  shadow: true,
)

// 13. 浮动框与图片结合
#four-image-page(
  title: "浮动框与图片的完美结合",
  show-header: false,
  show-footer: false,
  images: (
    image("typst_logo.jpg"),
    image("typst_logo.jpg"),
    image("typst_logo.jpg"),
    image("typst_logo.jpg"),
  ),
  captions: (),
  content: [
    // 中央说明框
    #floating-box(
      [
        = 🖼️ 图片展示区

        四张图片展示了不同的内容，每张图片都有其独特的价值。

        *浮动框优势*：
        - 不影响图片布局
        - 提供额外信息层
        - 增强视觉层次
      ],
      x: 30%, // 距页面左边30%
      y: 35%, // 距页面顶部35%（接近中央）
      width: 40%,
      background: rgb(255, 255, 255, 240),
      border-color: rgb("#8e44ad"),
      border-width: 3pt,
      border-radius: 15pt,
      padding: 12pt,
      shadow: true,
    )], // 移除浮动框，改为在页面外单独定义
)



