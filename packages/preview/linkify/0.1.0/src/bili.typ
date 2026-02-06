/// A sub-module of `linkify` that focuses on processing Bilibili video ID. Bilibili currently has two main video ID formats, which are AVID and BVID. AVID was used in the past and #link("https://www.bilibili.com/blackboard/activity-BV-PC.html")[has been substituted by BVID] since 23, March, 2020 with the purpose to enhance platform security and adapt for more videos, but accessing videos via AVID is still supported. The conversion between AVID and BVID is possible via a Base58-based encoding method.
///
/// - AVID is an integer which used to follow increasing order as new videos were published. Videos published later than the time when it was substituted by BVID no longer follows this rule.
/// - BVID is a string containing 10 alphanumeric characters. Characters that might cause ambiguities, such as `0`, `O`, `l`, `I` are not included.
///
///
/// 用于处理 B 站视频编号转换的子模块，支持 AV 号和 BV 号的互转。AV 号和 BV 号是 B 站通行的两种视频编号格式，过去仅有 AV 号，BV 号自 2020 年 3 月 23 日起引入，用以保障平台的安全性并容纳更多的投稿。虽然 AV 号已弃用，但通过 AV 号访问、搜索视频仍然是可行的。AV 号 和 BV 号之间可通过一种 Base58 编码方式实现互转。
///
/// - AV 号是一个整数，在过去，其随着投稿视频的次序依次增加。BV 号启用后，新视频的 AV 号不再服从此规则。
/// - BV 号是一个由 10 个数字或大小写字母组成的字符串。其中易混淆字符 `0`, `O`, `I`, `l` 未被使用。

#import "_impl/bili.typ": (
  av2bv,
  bv2av,
  video-id-fmt,
  validate-bv,
  bv-regex,
)

