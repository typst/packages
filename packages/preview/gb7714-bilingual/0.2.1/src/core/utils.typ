// GB/T 7714 双语参考文献系统 - 通用工具函数

// ============================================================================
//                        基础工具函数
// ============================================================================

// 格式化访问日期：[2024-01-15]
#let format-accessed-date(entry) = {
  let f = entry.at("fields", default: (:))
  let date = f.at("urldate", default: f.at("accessed", default: ""))
  if date != "" {
    "[" + str(date) + "]"
  } else {
    ""
  }
}

// 智能连接：避免 "et al.." 等双标点问题
#let smart-join(parts, sep: ". ", trailing: ".") = {
  (
    parts
      .map(p => {
        if p.ends-with(".") or p.ends-with(",") or p.ends-with(";") {
          p.slice(0, -1)
        } else {
          p
        }
      })
      .join(sep)
      + trailing
  )
}

// 统一处理 URL/DOI/accessed（避免重复代码）
#let append-access-info(
  result,
  entry,
  config: (show-url: true, show-doi: true, show-accessed: true),
) = {
  let f = entry.at("fields", default: (:))
  let url = f.at("url", default: "")
  let doi = f.at("doi", default: "")
  let mut = result

  // 访问日期
  if config.show-accessed {
    let accessed = format-accessed-date(entry)
    if accessed != "" {
      mut = mut.trim(".") + accessed + "."
    }
  }

  // 确保有结尾句号
  if not mut.ends-with(".") {
    mut += "."
  }

  // URL
  if config.show-url and url != "" {
    mut += " " + url + "."
  }

  // DOI
  if config.show-doi and doi != "" {
    mut += " DOI:" + doi + "."
  }

  mut
}

// ============================================================================
//                        字段缺失处理函数
// ============================================================================

/// 带分隔符拼接，自动跳过空字段
/// join-non-empty(("a", "", "b"), ", ") => "a, b"
#let join-non-empty(items, sep) = {
  items.filter(x => x != "").join(sep)
}

/// 构建出版信息：地址：出版者，年份
/// 自动处理各字段缺失的情况
#let build-pub-info(
  address,
  publisher,
  year,
  punct,
  include-year: true,
) = {
  let parts = ()

  // 地址：出版者
  if address != "" and publisher != "" {
    parts.push(address + punct.colon + publisher)
  } else if address != "" {
    parts.push(address)
  } else if publisher != "" {
    parts.push(publisher)
  }

  // 年份
  if include-year and year != "" {
    if parts.len() > 0 {
      parts.push(year)
      return parts.join(punct.comma)
    } else {
      return year
    }
  }

  parts.join(punct.comma)
}

/// 追加页码到信息字符串
/// 如果 info 为空，直接返回 pages；否则用冒号连接
#let append-pages(info, pages, punct) = {
  if pages == "" {
    info
  } else if info != "" {
    info + punct.colon + pages
  } else {
    pages
  }
}

/// 构建作者-年份部分（用于 author-date 风格）
#let build-author-year(authors, year, punct) = {
  if authors != "" {
    (
      author-part: authors + punct.comma + year,
      year-in-pub: false,
    )
  } else {
    (
      author-part: none,
      year-in-pub: true,
    )
  }
}

/// 构建期刊出版信息：刊名，年，卷（期）：页码
#let build-journal-info(
  journal,
  year,
  volume,
  number,
  pages,
  punct,
  include-year: true,
) = {
  let result = journal

  if include-year and year != "" {
    if result != "" {
      result += punct.comma + year
    } else {
      result = year
    }
  }

  if volume != "" {
    if result != "" {
      result += punct.comma + str(volume)
    } else {
      result = str(volume)
    }
  }

  if number != "" {
    result += punct.lparen + str(number) + punct.rparen
  }

  if pages != "" {
    if result != "" {
      result += punct.colon + pages
    } else {
      result = pages
    }
  }

  result
}

// ============================================================================
//                        渲染器公共抽象
// ============================================================================

/// 渲染器基础框架
/// 统一处理：作者/年份 -> 内容部分 -> 最终组装
#let render-base(
  entry,
  authors,
  year,
  punct,
  style,
  config,
  build-content,
) = {
  let parts = ()

  // 1. 处理作者和年份
  let year-in-pub = true
  if style == "author-date" {
    let ay = build-author-year(authors, year, punct)
    if ay.author-part != none {
      parts.push(ay.author-part)
    }
    year-in-pub = ay.year-in-pub
  } else {
    if authors != "" {
      parts.push(authors)
    }
  }

  // 2. 调用类型特定的内容构建函数
  let content-parts = build-content(year-in-pub)
  parts += content-parts

  // 3. 组装并添加访问信息
  let result = smart-join(parts)
  append-access-info(result, entry, config: config)
}

/// 简单类型渲染器（适用于结构简单的类型）
/// 格式：作者. 题名[类型]. 出版信息.
#let render-simple(
  entry,
  authors,
  title,
  year,
  address,
  publisher,
  punct,
  style,
  config,
  extra-parts: (),
) = {
  render-base(
    entry,
    authors,
    year,
    punct,
    style,
    config,
    year-in-pub => {
      let parts = ()
      parts.push(title)
      parts += extra-parts

      let pub-info = build-pub-info(
        address,
        publisher,
        year,
        punct,
        include-year: year-in-pub,
      )
      if pub-info != "" {
        parts.push(pub-info)
      }
      parts
    },
  )
}

// ============================================================================
//                        引用编号格式化
// ============================================================================

// 将 [1, 2, 3, 5, 7, 8, 9] 压缩为 "1-3, 5, 7-9"
#let format-citation-numbers(nums) = {
  if nums.len() == 0 { return "" }
  if nums.len() == 1 { return str(nums.first()) }

  let sorted = nums.sorted()
  let ranges = ()
  let start = sorted.first()
  let end = start

  for i in range(1, sorted.len()) {
    if sorted.at(i) == end + 1 {
      end = sorted.at(i)
    } else {
      ranges.push((start, end))
      start = sorted.at(i)
      end = start
    }
  }
  ranges.push((start, end))

  // GB/T 7714: 两篇及以上连续文献用 "-" 压缩
  ranges
    .map(((s, e)) => {
      if s == e { str(s) } else { str(s) + "-" + str(e) }
    })
    .join(",")
}
