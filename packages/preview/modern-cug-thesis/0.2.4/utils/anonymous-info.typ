  #let anonymous-info(info, anonymous: false, scale: 3) = {
    if anonymous {
      str(info).split("\n").map(
        (s) => if (s.len() >= 9) {
          // 中文字符宽度3个像素，英文字符宽度1个像素
          "▢▢▢▢▢"
          // "█████"
        } else if (s.len() >= 6 and s.len() < 10) {
          "▢▢▢"
          // "███"
        } else {s.clusters().map( 
        (s) => if not s.contains("\n") {"▢"} else {s}).join()
        }
      ).join()
    } else { info }
  }