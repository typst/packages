#let theme_setting_heading = (
    "background-color", // 主题背景颜色 / Theme background color
    "text-color", // 主题文字颜色 / Theme text color
    "stroke-color", // 主题描边颜色 / Theme stroke color
    "fill-color", // 主题填充颜色 / Theme fill color

    "cover-image", // 主题封面图片路径 / Theme cover image paths
    "preface-image", // 主题前言图片路径 / Theme preface image paths
    "content-image" // 主题图片路径 / Theme image paths
)

#let theme_settings = (
  abyss: (rgb("#000000"), rgb("#ffffff"), rgb("#4b5358"), rgb("#1f2833"), "../themes/abyss/cover.svg", "../themes/abyss/preface.svg", "../themes/abyss/content.svg"),
  light: ("", "", "", "", "", "", ""),
)

#let themes(
  theme: "abyss", // 主题名称 / Theme name
  setting: "background-color", // 主题设置名称 / Theme setting name
) = {
  let isSetting(value) = value == setting // 判断

  // 从`主题设置表头`中获取主题设置对应的索引值,并根据索引值从`主题设置`字典中选定主题的设置数组中获取对应的值 / Get the index value corresponding to the theme setting from the `theme setting header`, and use the index value to get the corresponding value from the setting array of the selected theme from the `theme settings` dictionary
  theme_settings.at(theme).at(theme_setting_heading.position(isSetting))
}
