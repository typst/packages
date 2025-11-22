#let theme_setting_heading = (
    "background-color", // 主题背景颜色 / Theme background color
    "text-color", // 主题文字颜色 / Theme text color
    "stroke-color", // 主题描边颜色 / Theme stroke color
    "fill-color", // 主题填充颜色 / Theme fill color

    "cover-image", // 主题封面图片路径 / Theme cover image paths
    "preface-image", // 主题前言图片路径 / Theme preface image paths
    "content-image" // 主题图片路径 / Theme image paths
)

#let settings_csv = csv("index.csv") // 读取主题设置表格 / Read theme setting table

#let settings_dict = ( // 主题设置字典 / Theme setting dictionary
  thene_name: 1,
)

#for (index, value) in settings_csv.enumerate() {
  settings_dict.insert(value.at(0), index) // 构建主题设置字典 / Build theme setting dictionary
}

#let themes(
  theme: "abyss", // 主题名称 / Theme name
  setting: "background-color", // 主题设置名称 / Theme setting name
) = {
  let isSetting(value) = value == setting // 判断是否为要查找的设置 / Check if it is the setting to be found

  let theme_heading = settings_csv.at(1) // csv第二行为`主题设置表头` / The second row of the csv is the `theme setting header`

  let setting_value = settings_csv.at(settings_dict.at(theme)).at(theme_heading.position(isSetting)) // 从`主题设置表头`中获取主题设置对应的索引值,并根据索引值从csv中选定主题的设置行中获取对应的值 / Get the index value corresponding to the theme setting from the `theme setting header`, and use the index value to get the corresponding value from the selected theme's setting row in the csv

  if theme_heading.position(isSetting) in (1, 2, 3, 4) [ // 如果是颜色设置则返回rgb格式 / If it is a color setting, return in rgb format
    #return rgb(setting_value)
  ] else [ // 否则直接返回设置值 / Otherwise, return the setting value directly
    #return setting_value
  ]
}
