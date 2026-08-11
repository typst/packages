#let bili-wasm = plugin("./bili.wasm")

/// Regex representing a valid BVID
///
/// 检测有效 BV 号的正则表达式。
#let bv-regex = regex("^(?:(?:B|b)(?:V|v))?[1-9A-HJ-NP-Za-km-z]{10}$")

/// Fails with an error if the input is not a valid BVID.
///
/// 若输入不是有效的 BV 号字符串，则报错。
#let validate-bv(bvid) = {
  assert(bvid.match(bv-regex) != none, message: "Invalid BVID format.")
}

/// Convert Bilibili BVID to AVID.
///
/// BV 号转 AV 号.
///
/// - bvid (str): 10-character Bilibili BVID, or optionally preceded by `BV` (case insensitive), which, if counted would make the string to have 12 characters. BV 号，10 个字母或数字的组合，可以加上开头的 `BV` 两个字母（大小写不敏感），若算入则共 12 字符。
///
/// -> int
#let bv2av(bvid) = {
  let bvid = bytes(bvid)
  let avid = bili-wasm.bv2av(bvid)
  int.from-bytes(avid, endian: "little")
}

/// Convert Bilibili AVID to BVID.
///
/// AV 号 转 BV 号。
///
/// - avid (int): Numeric Bilibili AVID. 以整数形式呈现的 AV 号。
/// - prefix (bool): Whether to add the `BV` prefix in the output result. 是否加上 `BV` 前缀。
/// -> str
#let av2bv(avid, prefix: false) = {
  let avid = int.to-bytes(avid, endian: "little")
  let bvid = bili-wasm.av2bv(avid)
  let bvid = str(bvid)
  if prefix { "BV" } + bvid
}

#let invalid-video-id-type() = {
  panic("Invalid `video-id` type. Expects `str` or `int`, got `" + str(type(video-id)) +  "`")
}

/// Turn Bilibili video ID into formatted string.
///
/// 将 Bilibili 视频编号转换为格式化字符串。
///
/// - video-id (int | str): The video ID, either AVID or BVID. 视频的 AV 号或 BV 号。
/// - format (auto | "av" | "bv"): The display format, as AVID or BVID or depending on the input `video-id` type when set to `auto`. 显示格式，可选择显示为 AV 号或 BV 号。若设置为 `auto` 则由输入格式决定。
/// - prefix (bool): Whether to add the `AV` or `BV` prefix. 是否添加 `AV` 或 `BV` 前缀。
/// -> str
#let video-id-fmt(video-id, format: auto, prefix: true) = {
  let format = if format == auto {
    if type(video-id) == int { "av" } else { "bv" }
  } else {
    lower(format)
  }
  if format == "bv" {
    if type(video-id) == int {
      av2bv(video-id, prefix: prefix)
    } else if type(video-id) == str {
      validate-bv(video-id)
      if (video-id.len() == 10) {
        if prefix { "BV" } + video-id
      } else {
        if prefix { video-id } else { video-id.slice(2) }
      }
    } else {
      invalid-video-id-type()
    }
  } else if format == "av" {
    let avid = if type(video-id) == str {
      bv2av(video-id)
    } else if type(video-id) == int {
      video-id
    } else {
      invalid-video-id-type()
    }
    if prefix { "AV" } + str(avid)
  } else {
    panic("Invalid video ID format: " + str(format))
  }
}

