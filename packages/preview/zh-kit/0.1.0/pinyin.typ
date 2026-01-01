#let pinyin-tones = (
  // a o e i u ü
  // ā á ǎ à a
  // ō ó ǒ ò o
  // ē é ě è e
  // ī í ǐ ì i
  // ū ú ǔ ù u
  // ǖ ǘ ǚ ǜ ü
  a: ("ā", "á", "ǎ", "à", "a"),
  o: ("ō", "ó", "ǒ", "ò", "o"),
  e: ("ē", "é", "ě", "è", "e"),
  i: ("ī", "í", "ǐ", "ì", "i"),
  u: ("ū", "ú", "ǔ", "ù", "u"),
  ü: ("ǖ", "ǘ", "ǚ", "ǜ", "ü"),
  v: ("ǖ", "ǘ", "ǚ", "ǜ", "ü"), // v 作为 ü 的别名
)

#let apply-tone(syllable, tone-char, tone-vowel-char-idx, tone-mark) = {
  // syllable: 原始音节字符串，不含声调数字，例如 "ma", "lve"
  // tone-char: 带声调的字符，例如 "ā"
  // tone-vowel-char-idx: 声调应该应用到的元音在 syllable 中的字符索引 (0-indexed)
  // tone-mark: 声调符号本身 (1-4 代表声调, 5 或 0 代表轻声)
  // 此处未直接使用 tone-mark，但保留以备将来逻辑更改时使用

  let clusters = syllable.clusters()
  let result_clusters = ()
  for (idx, cluster) in clusters.enumerate() {
    if idx == tone-vowel-char-idx {
      result_clusters.push(tone-char)
    } else {
      result_clusters.push(cluster)
    }
  }
  return result_clusters.join("")
}

#let format-pinyin-syllable(raw-syllable) = {
  // raw_syllable: 例如 "ma1", "ni3", "hao3", "lv4", "shang5"
  if raw-syllable == none or raw-syllable.len() == 0 {
    return ""
  }

  let tone = 0 // 0 或 5 代表轻声
  let syllable = raw-syllable
  let last-char = raw-syllable.slice(-1)

  if "12345".contains(last-char) {
    tone = int(last-char)
    syllable = raw-syllable.slice(0, -1)
  } else if "0".contains(last-char) { // 允许用 0 表示轻声
    tone = 5 // 将 0 映射为 5 以与 pinyin-tones 数组保持一致 (索引为4)
    syllable = raw-syllable.slice(0, -1)
  }


  if tone == 0 { // 未找到声调数字，或明确指定为轻声 (例如 "ma")
    tone = 5 // 视为轻声
  }

  // 在 pinyin-tones 中已经将 'v' 作为键处理，所以不需要在这里替换
  // syllable = syllable.replace("v", "ü") // 在查找元音之前执行此操作

  let vowel-priority = ("a", "o", "e") // 声调通常优先标记在这些元音上
  let iu-vowels = ("i", "u", "ü", "v")   // 元音 'i' 和 'u' (以及 'ü/v')

  let tone-vowel = ""
  let tone-vowel-pos = -1

  // 根据优先级查找主要元音以标记声调
  // 1. 检查 a, o, e
  let current_char_idx = 0
  for char_cluster in syllable.clusters() {
    let char = char_cluster // char is now a string (grapheme cluster)
    if vowel-priority.contains(char) {
      tone-vowel = char
      tone-vowel-pos = current_char_idx // character index
      break
    }
    current_char_idx += 1
  }

  // 2. 如果未找到，则检查 i, u, ü (或 v 作为别名)
  //    如果出现 'iu' 或 'ui'，声调标在后一个元音上。否则，标在 i, u, ü 中的第一个。
  if tone-vowel-pos == -1 { // 如果之前没有通过 a, o, e 找到声调元音
    let char_idx_outer = 0
    for char_cluster_outer in syllable.clusters() { // 迭代每个字符(簇)
      let char_outer = char_cluster_outer
      if iu-vowels.contains(char_outer) { // 如果当前字符是 i, u, ü, v 中的一个
        // 找到了一个 iu-vowel 类型的元音，现在需要确定声调具体标在哪个上面
        // 规则：在复韵母中，声调标在最后一个元音上 (例如 iu, ui, uei, iou)
        let candidate_tone_vowel = ""
        let candidate_tone_vowel_char_idx = -1
        
        let current_char_idx_inner = 0
        for char_cluster_inner in syllable.clusters() {
          let char_inner = char_cluster_inner
          if iu-vowels.contains(char_inner) { // 只要是 i, u, ü, v 中的一个，就更新为潜在的声调元音
            candidate_tone_vowel = char_inner
            candidate_tone_vowel_char_idx = current_char_idx_inner
          }
          current_char_idx_inner += 1
        }
        
        if candidate_tone_vowel_char_idx != -1 {
          tone-vowel = candidate_tone_vowel
          tone-vowel-pos = candidate_tone_vowel_char_idx // 使用字符索引
        }
        // 一旦根据 iu-vowels 规则找到了声调位置，就跳出最外层循环
        if tone-vowel-pos != -1 {
          break
        }
      }
      char_idx_outer += 1
      // 如果在外层循环中已经确定了 tone-vowel-pos，也跳出
      if tone-vowel-pos != -1 {
          break
      }
    }
  }
  
  // 单个元音音节或上述逻辑失败时的回退方案
  if tone-vowel-pos == -1 {
     let current_char_idx_fallback = 0
     for char_cluster_fallback in syllable.clusters() {
        let char = char_cluster_fallback
        if pinyin-tones.keys().contains(char) {
            tone-vowel = char
            tone-vowel-pos = current_char_idx_fallback // character index
            break
        }
        current_char_idx_fallback += 1
     }
  }


  if tone-vowel-pos != -1 and pinyin-tones.keys().contains(tone-vowel) {
    let tone-char-options = pinyin-tones.at(tone-vowel)
    // tone 是 1-5, 数组索引是 0-4
    let actual-tone-char = tone-char-options.at(tone - 1)
    
    // 对 'ü' 作为声调元音的特殊处理
    // 如果音节以 j, q, x, y 开头，'ü' 应写为带声调的 'u'。
    // 例如 ju1 -> jū, qu3 -> qǔ, xu2 -> xǘ, yu4 -> yù
    // 但是，如果是 nü3 -> nǚ, lü4 -> lǜ，则仍为带声调的 'ü'。
    let starts_with_jqxy = false
    let clusters_arr = syllable.clusters()
    if clusters_arr.len() > 0 {
        let first_letter_cluster = clusters_arr.first()
        if ("j", "q", "x", "y").contains(first_letter_cluster) {
            starts_with_jqxy = true
        }
    }

    if (tone-vowel == "ü" or tone-vowel == "v") and starts_with_jqxy {
        // 我们需要从 pinyin-tones.u 中找到等效的 'u' 声调字符
        let u_tone_char_options = pinyin-tones.at("u")
        let u_actual_tone_char = u_tone_char_options.at(tone - 1)
        // 在应用声调之前，将 tone-vowel-pos (字符索引) 处的 'ü' 或 'v' 替换为 'u'
        let temp_syllable_clusters = ()
        for (idx, cl) in syllable.clusters().enumerate() {
            if idx == tone-vowel-pos { // tone-vowel-pos is char index of 'ü' or 'v'
                temp_syllable_clusters.push("u")
            } else {
                temp_syllable_clusters.push(cl)
            }
        }
        let temp_syllable = temp_syllable_clusters.join("")
        // The tone-vowel-pos for apply-tone is still the same character index
        return apply-tone(temp_syllable, u_actual_tone_char, tone-vowel-pos, tone)
    } else {
       return apply-tone(syllable, actual-tone-char, tone-vowel-pos, tone)
    }

  }

  // 如果未找到元音或发生其他错误，则返回原始音节（如果已剥离声调数字）
  return syllable
}

#let pinyin(text) = {
  // text: 例如 "ni3 hao3 ma5"
  let syllables = text.split(" ")
  let result = () // 用于收集结果的数组
  for syllable in syllables {
    if syllable.trim().len() > 0 {
      result.push(format-pinyin-syllable(syllable.trim()))
    }
  }
  return result.join(" ")
}

// 示例用法 (如果可能，用于在此文件中测试，或用于导入)
// #let test1 = pinyin("ni3 hao3") // 预期: nǐ hǎo
// #let test2 = pinyin("lv4 xing2") // 预期: lǜ xíng
// #let test3 = pinyin("xue2 xi2") // 预期: xué xí
// #let test4 = pinyin("nu3 li4") // 预期: nǔ lì
// #let test5 = pinyin("qing1 tian1") // 预期: qīng tiān
// #let test6 = pinyin("ma") // 预期: ma (轻声)
// #let test7 = pinyin("ma0") // 预期: ma (轻声)
// #let test8 = pinyin("a1 o2 e3 i4 u1 v2") // 预期: ā ó ě ì ū ǖ