#let numfmt = plugin("numfmt.wasm")

#let format(..args, opt: (:)) = {
  str(numfmt.format(..args.pos().map(x => bytes({ str(x) })), bytes(json.encode(opt))))
}

#let format-color(..args) = {
  let color = str(numfmt.format-color(..args.pos().map(x => bytes(str(x)))))

  // https://www.excelsupersite.com/what-are-the-56-colorindex-colors-in-excel/
  let color-map = (
    "black": rgb(0, 0, 0),
    "white": rgb(255, 255, 255),
    "red": rgb(255, 0, 0),
    "green": rgb(0, 255, 0),
    "blue": rgb(0, 0, 255),
    "yellow": rgb(255, 255, 0),
    "magenta": rgb(255, 0, 255),
    "cyan": rgb(0, 255, 255),
    "color9": rgb(128, 0, 0),
    "color10": rgb(0, 128, 0),
    "color11": rgb(0, 0, 128),
    "color12": rgb(128, 128, 0),
    "color13": rgb(128, 0, 128),
    "color14": rgb(0, 128, 128),
    "color15": rgb(192, 192, 192),
    "color16": rgb(128, 128, 128),
    "color17": rgb(153, 153, 255),
    "color18": rgb(153, 51, 102),
    "color19": rgb(255, 255, 204),
    "color20": rgb(204, 255, 255),
    "color21": rgb(102, 0, 102),
    "color22": rgb(255, 128, 128),
    "color23": rgb(0, 102, 204),
    "color24": rgb(204, 204, 255),
    "color25": rgb(0, 0, 128),
    "color26": rgb(255, 0, 255),
    "color27": rgb(255, 255, 0),
    "color28": rgb(0, 255, 255),
    "color29": rgb(128, 0, 128),
    "color30": rgb(128, 0, 0),
    "color31": rgb(0, 128, 128),
    "color32": rgb(0, 0, 255),
    "color33": rgb(0, 204, 255),
    "color34": rgb(204, 255, 255),
    "color35": rgb(204, 255, 204),
    "color36": rgb(255, 255, 153),
    "color37": rgb(153, 204, 255),
    "color38": rgb(255, 153, 204),
    "color39": rgb(204, 153, 255),
    "color40": rgb(255, 204, 153),
    "color41": rgb(51, 102, 255),
    "color42": rgb(51, 204, 204),
    "color43": rgb(153, 204, 0),
    "color44": rgb(255, 204, 0),
    "color45": rgb(255, 153, 0),
    "color46": rgb(255, 102, 0),
    "color47": rgb(102, 102, 153),
    "color48": rgb(150, 150, 150),
    "color49": rgb(0, 51, 102),
    "color50": rgb(51, 153, 102),
    "color51": rgb(0, 51, 0),
    "color52": rgb(51, 51, 0),
    "color53": rgb(153, 51, 0),
    "color54": rgb(153, 51, 102),
    "color55": rgb(51, 51, 153),
    "color56": rgb(51, 51, 51),
  )
  color-map.at(color, default: eval(color))
}

// #numfmt.get-locale()

// // #locale("zh-CN")

// // #call-js-function(numfmt-bytecode, "getLocale", "zh-CN")

// // #format("d dd ddd dddd ddddd", 3290.1278435, (locale: "zh-CH", overflow: "######"))
// #format("[$-F800]dddd\,\ mmmm\ dd\,\ yyy", 3290.1278435, opt: (locale: "zh-CN"))
// #format("[>=100]\"A\"0;[<=-100]\"B\"0;\"C\"0", 6.3)

// #format-color("[blue]0;[green]-0;[magenta]0;[cyan]@", 0)
