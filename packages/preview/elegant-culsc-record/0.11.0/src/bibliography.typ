// Authors: csimide, OrangeX4
// Modified by: chillcicada
// Re-Customized by: SchrodingerBlume,
// Tested only on gb-7714-2015-numeric

#let print-bib(
  bibliography: none,
  full: false,
  style: "gb-7714-2015-numeric",
  mapping: (:),
  extra-comma-before-et-al-trans: false,
  allow-comma-in-name: false,
  uppercase-english-names: true,
  before-suffix-comma: true,  // Jr/Sr/III 等后缀前是否添加逗号，默认启用
  gbpunctwidth: "full",
  bib-number-gutter: 1em,
  bib-number-align: "right",  // 编号对齐方式，"right" 或 "left"
) = {
  assert(bibliography != none, message: "请传入带有 source 的 bibliography 函数。")

  // 添加一个显式的一级标题，确保页眉能够正确识别
  heading(level: 2, numbering: none, bookmarked: true)[参考文献]
  
  // Please fill in the remaining mapping table here
  mapping = (
    (
      //"等": "et al",
      "卷": "Vol.",
      "册": "Bk.",
      //"译": ", tran",
      // "等译": "et al. tran",
      // 注: 请见下方译者数量判断部分。
    )
      + mapping
  )

  let to-string(content) = {
    if content.has("text") {
      content.text
    } else if content.has("children") {
      content.children.map(to-string).join("")
    } else if content.has("child") {
      to-string(content.child)
    } else if content.has("body") {
      to-string(content.body)
    } else if content == [ ] {
      " "
    }
  }

  // 标点符号转换函数
  let convert-punctuation(text, is-chinese) = {
    if not is-chinese {
      return text
    }
    
    // 提取并保护 URL，避免 URL 中的标点被替换
    let urls = ()
    let url-pattern = regex("(https?://|www\.)[^\s\u4e00-\u9fff]+")
    let protected-text = text
    let url-matches = text.matches(url-pattern)
    
    // 用占位符替换 URL
    for (i, match) in url-matches.enumerate() {
      let placeholder = "Xurlx" + str(i) + "Xurlx"
      urls.push((placeholder: placeholder, url: match.text))
      protected-text = protected-text.replace(match.text, placeholder)
    }
    
    // 根据 gbpunctwidth 配置进行标点转换
    if gbpunctwidth == "half" {
      // 全部半角：全角标点 -> 半角标点 + 空格
      protected-text = protected-text.replace("，", ", ")
      protected-text = protected-text.replace("．", ". ")
      protected-text = protected-text.replace("；", "; ")
      protected-text = protected-text.replace("：", ": ")
      protected-text = protected-text.replace("？", "? ")
      protected-text = protected-text.replace("！", "! ")
      protected-text = protected-text.replace("（", "(")
      protected-text = protected-text.replace("）", ")")
      protected-text = protected-text.replace("【", "[")
      protected-text = protected-text.replace("】", "]")
    } else if gbpunctwidth == "full" {
      // 全部全角（[] 除外）
      protected-text = protected-text.replace(",", "，")
      // protected-text = protected-text.replace(".", "．")
      protected-text = protected-text.replace(";", "；")
      protected-text = protected-text.replace(":", "：")
      protected-text = protected-text.replace("?", "？")
      protected-text = protected-text.replace("!", "！")
      //protected-text = protected-text.replace("(", "（")
      //protected-text = protected-text.replace(")", "）")
      // [] 保持半角，不做转换
      protected-text = protected-text.replace("【", "[")
      protected-text = protected-text.replace("】", "]")
      // 移除可能因为替换产生的多余空格
      protected-text = protected-text.replace(regex("([，．；：？！（）])(\s+)"), m => m.captures.at(0))
    }
    
    // 恢复 URL
    for item in urls {
      protected-text = protected-text.replace(item.placeholder, item.url)
    }
    
    protected-text
  }  
  
  // 调整编号列：对齐方式和间距
  show grid.cell.where(x: 0): it => {
    set align(if bib-number-align == "right" { right } else { left })
    it
    h(bib-number-gutter - 8pt)
  }
  
  show grid.cell.where(x: 1): it => context {
    // 后续的操作是对 string 进行的。
    let ittext = to-string(it)

    // === 全局保护被反引号包围的内容 ===
    let protected_contents = ()
    let protected_text = ittext
    let backtick_pattern = regex("`([^`]+)`")
    let backtick_matches = ittext.matches(backtick_pattern)
    
    // 用占位符替换反引号包围的内容（使用纯大写字母的占位符）
    for (i, match) in backtick_matches.enumerate() {
      let placeholder = "XPROTECTEDX" + str(i) + "XPROTECTEDX"
      let original_content = match.captures.at(0)  // 提取反引号内的内容
      protected_contents.push((placeholder: placeholder, content: original_content))
      protected_text = protected_text.replace(match.text, placeholder)
    }
    
    ittext = protected_text

    // === 手动模式检测 ===
    // 如果检测到 [manual]，只保留 [manual] 之后的内容，并去掉最后的文献类型标识
    let manual_match = ittext.match(regex("\[manual\]"))
    if manual_match != none {
      let content = ittext.slice(manual_match.end)
      // 去掉末尾的文献类型标识 [X] 或 [X/Y]，包括后面的句点和空白
      content = content.replace(regex("\[[A-Z]+(?:/[A-Z]+)?\]\.?\s*$"), "")
      
      // === 恢复被保护的内容 ===
      for item in protected_contents {
        content = content.replace(item.placeholder, item.content)
      }
      
      return content
    }
    
    // === 文献类型标识替换（支持有无 author） ===
    
    // 处理报纸文献 [N] + [J] 或 [J/OL]
    ittext = ittext.replace(regex("\[N\]([^\[]*?)\[J\]"), itt => {
      let middle-content = itt.captures.at(0)
      middle-content + "[N]"
    })
    
    ittext = ittext.replace(regex("\[N\]([^\[]*?)\[J/OL\]"), itt => {
      let middle-content = itt.captures.at(0)
      middle-content + "[N/OL]"
    })
    
    // 处理析出标准文献 [S] + [M]//
    ittext = ittext.replace(regex("\[S\]([^\[]*?)\[M\]//"), itt => {
      let middle-content = itt.captures.at(0)
      middle-content + "[S]//"
    })
    
    // 处理非析出标准文献 [S] + [M]
    ittext = ittext.replace(regex("\[S\]([^\[]*?)\[M\]"), itt => {
      let middle-content = itt.captures.at(0)
      middle-content + "[S]"
    })

    // 处理网络标准文献 [S] + [M/OL]
    ittext = ittext.replace(regex("\[S\]([^\[]*?)\[M/OL\]"), itt => {
      let middle-content = itt.captures.at(0)
      middle-content + "[S/OL]"
    })

    // 处理析出汇编文献 [G] + [M]// 或 [M/OL]//
    ittext = ittext.replace(regex("\[G\]([^\[]*?)\[M/OL\]//"), itt => {
      let middle-content = itt.captures.at(0)
      middle-content + "[G/OL]//"
    })
    
    ittext = ittext.replace(regex("\[G\]([^\[]*?)\[M\]//"), itt => {
      let middle-content = itt.captures.at(0)
      middle-content + "[G]//"
    })
    
    // 处理非析出汇编文献 [G] + [M] 或 [M/OL]
    ittext = ittext.replace(regex("\[G\]([^\[]*?)\[M/OL\]"), itt => {
      let middle-content = itt.captures.at(0)
      middle-content + "[G/OL]"
    })
    
    ittext = ittext.replace(regex("\[G\]([^\[]*?)\[M\]"), itt => {
      let middle-content = itt.captures.at(0)
      middle-content + "[G]"
    })

    // 处理连续出版物 [J] + [J] 或 [J] + [EB/OL]
    ittext = ittext.replace(regex("\[J\]([^\[]*?)\[J\]"), itt => {
      let middle-content = itt.captures.at(0)
      middle-content + "[J]"
    })
    
    ittext = ittext.replace(regex("\[J\]([^\[]*?)\[EB/OL\]"), itt => {
      let middle-content = itt.captures.at(0)
      middle-content + "[J/OL]"
    })
    
    ittext = ittext.replace(regex("\[J\]([^\[]*?)\[J/OL\]"), itt => {
      let middle-content = itt.captures.at(0)
      middle-content + "[J/OL]"
    })
    
    // 处理其他所有自定义文献类型 [类型] + [Z]
    // 匹配 [某类型]...[Z] 模式，将 [Z] 替换为 [某类型]，并删除第一个 [某类型]
    ittext = ittext.replace(regex("\[([A-Z]+(?:/[A-Z]+)?)\]([^\[]*?)\[Z\]"), itt => {
      let custom-type = itt.captures.at(0)
      let middle-content = itt.captures.at(1)
      // 返回：中间内容 + [自定义类型]
      middle-content + "[" + custom-type + "]"
    })

    // 处理其他所有自定义文献类型 [类型] + [EB/OL]
    // 匹配 [某类型]...[OL] 模式，将 [EB/OL] 替换为 [某类型]，并删除第一个 [某类型]
    ittext = ittext.replace(regex("\[([A-Z]+(?:/[A-Z]+)?)\]([^\[]*?)\[EB/OL\]"), itt => {
      let custom-type = itt.captures.at(0)
      let middle-content = itt.captures.at(1)
      // 返回：中间内容 + [自定义类型]
      middle-content + "[" + custom-type + "]"
    })
    
    // === 连续出版物格式处理 ===
    // 处理有 URL 的连续出版物（中英文通用）
    ittext = ittext.replace(
      regex(":\s*(?:卷|Vol\.)\s*(\d+)\s*\[(?:J|EB/OL|J/OL)\]\.\s*([^:]*?):\s*([^,]+),\s*(\d{4}):\s*([^\[]+?)(\[doi:[^\]]+\])?(\[\d{4}-\d{2}-\d{2}\])\.\s+(https?://[^\s]+)\."),
      itt => {
        let volume_str = itt.captures.at(0)
        let location = itt.captures.at(1).trim()
        let publisher = itt.captures.at(2).trim()
        let year_str = itt.captures.at(3)
        let pages_str = itt.captures.at(4).trim()
        let doi_part = itt.captures.at(5)
        let urldate = itt.captures.at(6)
        let url = itt.captures.at(7)
        
        // 提取 DOI
        let has_doi = doi_part != none
        let doi_value = ""
        if has_doi {
          let doi_match = doi_part.match(regex("\[doi:([^\]]+)\]"))
          if doi_match != none {
            doi_value = "DOI: " + doi_match.captures.at(0)
          }
        }
        
        let page_base = pages_str
        let doc_type = "[J/OL]"
        
        // 解析卷
        let vol_parts = volume_str.split("000")
        let start_vol = vol_parts.at(0)
        let end_vol = if vol_parts.len() > 1 { vol_parts.at(1) } else { start_vol }
        
        // 解析期
        let page_parts = page_base.split("000")
        let start_page = page_parts.at(0)
        let end_page = if page_parts.len() > 1 { page_parts.at(1) } else { start_page }
        
        // 解析年份
        let start_year = ""
        let end_year = ""
        
        if year_str.len() == 4 and year_str.slice(0, 2) != "19" and year_str.slice(0, 2) != "20" {
          let start_year_2digit = year_str.slice(0, 2)
          let end_year_2digit = year_str.slice(2, 4)
          
          let current_year = datetime.today().year()
          let current_year_2digit = str(current_year).slice(2, 4)
          
          start_year = if int(start_year_2digit) <= int(current_year_2digit) {
            "20" + start_year_2digit
          } else {
            "19" + start_year_2digit
          }
          
          end_year = if int(end_year_2digit) <= int(current_year_2digit) {
            "20" + end_year_2digit
          } else {
            "19" + end_year_2digit
          }
        } else {
          start_year = year_str
          end_year = year_str
        }
        
        let has_vol = start_vol != "0" and end_vol != "0"
        let has_page = start_page != "0" and end_page != "0"
        let is_ongoing = (start_vol == end_vol) and (start_page == end_page) and (start_year == end_year)
        
        let build_year_vol_page(year, vol, page) = {
          if has_vol and has_page {
            year + ", " + vol + "(" + page + ")"
          } else if has_vol {
            year + ", " + vol
          } else if has_page {
            year + "(" + page + ")"
          } else {
            year
          }
        }
        
        let build_publication_info(loc, pub) = {
          if loc != "" and pub != "" {
            loc + ": " + pub
          } else if loc != "" {
            loc
          } else if pub != "" {
            pub
          } else {
            ""
          }
        }
        
        let pub_info = build_publication_info(location, publisher)
        
        // 构建在线资源部分（顺序：urldate, url, doi）
        let online_parts = ()
        online_parts.push(urldate)
        online_parts.push(url)
        if has_doi {
          online_parts.push(doi_value)
        }
        
        let online_info = online_parts.join(". ")
        
        if is_ongoing {
          let year_vol_page_part = build_year_vol_page(start_year, start_vol, start_page)
          let base_info = doc_type + ". " + year_vol_page_part + "-. "
          
          if pub_info != "" {
            base_info = base_info + pub_info + ", " + start_year + "-"
          } else {
            base_info = base_info + start_year + "-"
          }
          
          base_info + ". " + online_info + "."
        } else {
          let start_part = build_year_vol_page(start_year, start_vol, start_page)
          let end_part = build_year_vol_page(end_year, end_vol, end_page)
          let base_info = doc_type + ". " + start_part + "-" + end_part + ". "
          
          if pub_info != "" {
            base_info = base_info + pub_info + ", " + start_year + "-" + end_year
          } else {
            base_info = base_info + start_year + "-" + end_year
          }
          
          base_info + ". " + online_info + "."
        }
      }
    )
    
    // 处理没有 URL 的连续出版物
    ittext = ittext.replace(
      regex(":\s*(?:卷|Vol\.)\s*(\d+)\s*\[J\]\.\s*([^:]*?):\s*([^,]+),\s*(\d{4}):\s*(.+)\."),
      itt => {
        let volume_str = itt.captures.at(0)
        let location = itt.captures.at(1).trim()
        let publisher = itt.captures.at(2).trim()
        let year_str = itt.captures.at(3)
        let pages_str = itt.captures.at(4).trim()
        
        let page_base = pages_str
        let doi_match = pages_str.match(regex("\[doi:([^\]]+)\]"))
        
        let has_doi = doi_match != none
        let doi_value = if has_doi { "DOI: " + doi_match.captures.at(0) } else { "" }
        
        page_base = page_base.replace(regex("\[doi:[^\]]+\]"), "").trim()
        
        let doc_type = if has_doi { "[J/OL]" } else { "[J]" }
        
        // 解析卷
        let vol_parts = volume_str.split("000")
        let start_vol = vol_parts.at(0)
        let end_vol = if vol_parts.len() > 1 { vol_parts.at(1) } else { start_vol }
        
        // 解析期
        let page_parts = page_base.split("000")
        let start_page = page_parts.at(0)
        let end_page = if page_parts.len() > 1 { page_parts.at(1) } else { start_page }
        
        // 解析年份
        let start_year = ""
        let end_year = ""
        
        if year_str.len() == 4 and year_str.slice(0, 2) != "19" and year_str.slice(0, 2) != "20" {
          let start_year_2digit = year_str.slice(0, 2)
          let end_year_2digit = year_str.slice(2, 4)
          
          let current_year = datetime.today().year()
          let current_year_2digit = str(current_year).slice(2, 4)
          
          start_year = if int(start_year_2digit) <= int(current_year_2digit) {
            "20" + start_year_2digit
          } else {
            "19" + start_year_2digit
          }
          
          end_year = if int(end_year_2digit) <= int(current_year_2digit) {
            "20" + end_year_2digit
          } else {
            "19" + end_year_2digit
          }
        } else {
          start_year = year_str
          end_year = year_str
        }
        
        let has_vol = start_vol != "0" and end_vol != "0"
        let has_page = start_page != "0" and end_page != "0"
        let is_ongoing = (start_vol == end_vol) and (start_page == end_page) and (start_year == end_year)
        
        let build_year_vol_page(year, vol, page) = {
          if has_vol and has_page {
            year + ", " + vol + "(" + page + ")"
          } else if has_vol {
            year + ", " + vol
          } else if has_page {
            year + "(" + page + ")"
          } else {
            year
          }
        }
        
        let build_publication_info(loc, pub) = {
          if loc != "" and pub != "" {
            loc + ": " + pub
          } else if loc != "" {
            loc
          } else if pub != "" {
            pub
          } else {
            ""
          }
        }
        
        let pub_info = build_publication_info(location, publisher)
        
        if is_ongoing {
          let year_vol_page_part = build_year_vol_page(start_year, start_vol, start_page)
          let base_info = doc_type + ". " + year_vol_page_part + "-. "
          
          if pub_info != "" {
            base_info = base_info + pub_info + ", " + start_year + "-"
          } else {
            base_info = base_info + start_year + "-"
          }
          
          if has_doi {
            base_info + ". " + doi_value + "."
          } else {
            base_info + "."
          }
        } else {
          let start_part = build_year_vol_page(start_year, start_vol, start_page)
          let end_part = build_year_vol_page(end_year, end_vol, end_page)
          let base_info = doc_type + ". " + start_part + "-" + end_part + ". "
          
          if pub_info != "" {
            base_info = base_info + pub_info + ", " + start_year + "-" + end_year
          } else {
            base_info = base_info + start_year + "-" + end_year
          }
          
          if has_doi {
            base_info + ". " + doi_value + "."
          } else {
            base_info + "."
          }
        }
      }
    )
    
    // === 标准文献在线资源处理 ===
    // 处理标准文献的 URL/urldate/DOI，将 [S] 改为 [S/OL]，[S]// 改为 [S/OL]//
    ittext = ittext.replace(
      regex("\[S\](//)?([^\d]*?:\s*[^,]+,\s*\d{4}:\s*)(.+)\."),
      itt => {
        let slash_slash = if itt.captures.at(0) != none { itt.captures.at(0) } else { "" }
        let before_pages = itt.captures.at(1)  // 出版信息部分
        let pages_str = itt.captures.at(2).trim()  // pages 字段
        
        // 解析 pages 字段
        let page_base = pages_str
        let url_match = pages_str.match(regex("\[url:([^\]]+)\]"))
        let urldate_match = pages_str.match(regex("\[urldate:([^\]]+)\]"))
        let doi_match = pages_str.match(regex("\[doi:([^\]]+)\]"))
        
        let has_url = url_match != none
        let has_urldate = urldate_match != none
        let has_doi = doi_match != none
        
        let url_value = if has_url { url_match.captures.at(0) } else { "" }
        let urldate_value = if has_urldate { urldate_match.captures.at(0) } else { "" }
        let doi_value = if has_doi { doi_match.captures.at(0) } else { "" }
        
        // 移除所有标记
        page_base = page_base.replace(regex("\[url:[^\]]+\]"), "")
        page_base = page_base.replace(regex("\[urldate:[^\]]+\]"), "")
        page_base = page_base.replace(regex("\[doi:[^\]]+\]"), "")
        page_base = page_base.trim()
        
        // 判断是否为在线文献
        let is_online = has_url or has_doi
        let doc_type = if is_online { "[S/OL]" } else { "[S]" }
        
        // 构建在线资源部分
        let online_parts = ()
        if has_urldate {
          online_parts.push("[" + urldate_value + "]")
        }
        if has_url {
          online_parts.push(url_value)
        }
        if has_doi {
          online_parts.push(doi_value)
        }
        
        let online_info = if online_parts.len() > 0 {
          online_parts.join(". ")
        } else {
          ""
        }
        
        // 构建结果
        if online_info != "" {
          doc_type + slash_slash + before_pages + page_base + ". " + online_info + "."
        } else {
          doc_type + slash_slash + before_pages + page_base + "."
        }
      }
    )
    
    // === 报纸日期格式处理 ===
    // 情况1：有年月日和版次 - "年, 月(版): 日." 转换为 "年-月-日(版)."
    ittext = ittext.replace(regex("\[N\]\.([^\d]*?)(\d{4}),\s*(\d{1,2})\((\d{1,2})\):\s*(\d+)\."), itt => {
      let middle = itt.captures.at(0)
      let year = itt.captures.at(1)
      let month = itt.captures.at(2)
      let page = itt.captures.at(3)
      let day = itt.captures.at(4)
      // 月份和日期补零
      if month.len() == 1 { month = "0" + month }
      if day.len() == 1 { day = "0" + day }
      "[N]." + middle + year + "-" + month + "-" + day + "(" + page + ")."
    })
    
    // 情况2：只有年月和版次 - "年, 月(版)." 转换为 "年-月(版)."
    ittext = ittext.replace(regex("\[N\]\.([^\d]*?)(\d{4}),\s*(\d{1,2})\((\d{1,2})\)\."), itt => {
      let middle = itt.captures.at(0)
      let year = itt.captures.at(1)
      let month = itt.captures.at(2)
      let page = itt.captures.at(3)
      // 月份补零
      if month.len() == 1 { month = "0" + month }
      "[N]." + middle + year + "-" + month + "(" + page + ")."
    })
    
    // 情况3：有年月日但无版次 - "年, 月: 日." 转换为 "年-月-日."
    ittext = ittext.replace(regex("\[N\]\.([^\d]*?)(\d{4}),\s*(\d{1,2}):\s*(\d+)\."), itt => {
      let middle = itt.captures.at(0)
      let year = itt.captures.at(1)
      let month = itt.captures.at(2)
      let day = itt.captures.at(3)
      // 月份和日期补零
      if month.len() == 1 { month = "0" + month }
      if day.len() == 1 { day = "0" + day }
      "[N]." + middle + year + "-" + month + "-" + day + "."
    })
    
    // 情况4：只有年月但无版次 - "年, 月." 转换为 "年-月."
    ittext = ittext.replace(regex("\[N\]\.([^\d]*?)(\d{4}),\s*(\d{1,2})\."), itt => {
      let middle = itt.captures.at(0)
      let year = itt.captures.at(1)
      let month = itt.captures.at(2)
      // 月份补零
      if month.len() == 1 { month = "0" + month }
      "[N]." + middle + year + "-" + month + "."
    })
    
    // 网络报纸文献
    // 情况1：有年月日+版次+URL - "年, 月(版): 日[urldate]" 转换为 "年-月-日(版)[urldate]"
    ittext = ittext.replace(regex("\[N/OL\]\.([^\d]*?)(\d{4}),\s*(\d{1,2})\((\d{1,2})\):\s*(\d+)(\[\d{4}-\d{2}-\d{2}\])"), itt => {
      let middle = itt.captures.at(0)
      let year = itt.captures.at(1)
      let month = itt.captures.at(2)
      let page = itt.captures.at(3)
      let day = itt.captures.at(4)
      let urldate = itt.captures.at(5)
      // 月份和日期补零
      if month.len() == 1 { month = "0" + month }
      if day.len() == 1 { day = "0" + day }
      "[N/OL]." + middle + year + "-" + month + "-" + day + "(" + page + ")" + urldate
    })
    
    // 情况2：只有年月+版次+URL - "年, 月(版)[urldate]" 转换为 "年-月(版)[urldate]"
    ittext = ittext.replace(regex("\[N/OL\]\.([^\d]*?)(\d{4}),\s*(\d{1,2})\((\d{1,2})\)(\[\d{4}-\d{2}-\d{2}\])"), itt => {
      let middle = itt.captures.at(0)
      let year = itt.captures.at(1)
      let month = itt.captures.at(2)
      let page = itt.captures.at(3)
      let urldate = itt.captures.at(4)
      // 月份补零
      if month.len() == 1 { month = "0" + month }
      "[N/OL]." + middle + year + "-" + month + "(" + page + ")" + urldate
    })
    
    // 情况3：有年月日但无版次+URL - "年, 月: 日[urldate]" 转换为 "年-月-日[urldate]"
    ittext = ittext.replace(regex("\[N/OL\]\.([^\d]*?)(\d{4}),\s*(\d{1,2}):\s*(\d+)(\[\d{4}-\d{2}-\d{2}\])"), itt => {
      let middle = itt.captures.at(0)
      let year = itt.captures.at(1)
      let month = itt.captures.at(2)
      let day = itt.captures.at(3)
      let urldate = itt.captures.at(4)
      // 月份和日期补零
      if month.len() == 1 { month = "0" + month }
      if day.len() == 1 { day = "0" + day }
      "[N/OL]." + middle + year + "-" + month + "-" + day + urldate
    })
    
    // 情况4：只有年月但无版次+URL - "年, 月[urldate]" 转换为 "年-月[urldate]"
    ittext = ittext.replace(regex("\[N/OL\]\.([^\d]*?)(\d{4}),\s*(\d{1,2})(\[\d{4}-\d{2}-\d{2}\])"), itt => {
      let middle = itt.captures.at(0)
      let year = itt.captures.at(1)
      let month = itt.captures.at(2)
      let urldate = itt.captures.at(3)
      // 月份补零
      if month.len() == 1 { month = "0" + month }
      "[N/OL]." + middle + year + "-" + month + urldate
    })

    // === 处理年份为 9999 的情况（去除年份） ===
    // 仅处理作为年份出现的 9999
    ittext = ittext.replace(regex(":\s*9999\s*\["), ": [")           // 处理 ": 9999 [" 的情况
    ittext = ittext.replace(regex(",\s*9999\s*\."), ".")             // 处理 ", 9999." 的情况
    ittext = ittext.replace(regex(",\s*9999\s*\)"), ")")             // 处理 ", 9999)" 的情况
    ittext = ittext.replace(regex(",\s*9999\s*-"), " -")             // 处理 ", 9999-" 的情况（连续出版物）
    ittext = ittext.replace(regex("-9999\s*\."), ".")                // 处理 "-9999." 的情况（持续中）
    ittext = ittext.replace(regex("\s*9999\s*(\[\d{4}-\d{2}-\d{2}\])"), m => m.captures.at(0))  // 处理 "9999[日期]" 的情况
    ittext = ittext.replace(regex(",\s*9999\s*:"), ":")              // 处理 ", 9999:" 的情况

    // === 处理出版年无法确定时，使用版权年的标识 [c]===
    // 将 "Publisher[c], year" 转换为 "Publisher, cyear"
    ittext = ittext.replace(regex("([^,\[]+)\[c\],\s*(\d{4})"), m => {
      let publisher = m.captures.at(0)
      let year = m.captures.at(1)
      publisher + ", c" + year
    })
    
    // === 处理印刷年的标识 [p] ===
    // 中文：将 "Publisher[p], year" 转换为 "Publisher, year 印刷"
    // 英文：将 "Publisher[p], year" 转换为 "Publisher, year"（国标未规定，保持原样）
    ittext = ittext.replace(regex("([^,\[]+)\[p\],\s*(\d{4})"), m => {
      let publisher = m.captures.at(0)
      let year = m.captures.at(1)
      
      // 判断是否为中文文献（此时尚未进行中英文判断，需要临时判断）
      let temp_text = ittext.replace(regex("[等卷册和版本章期页篇译间者(不详)]"), "")
      let is_chinese_temp = temp_text.find(regex("\p{sc=Hani}{2,}")) != none
      
      if is_chinese_temp {
        // 中文：1995 印刷
        publisher + ", " + year + " 印刷"
      } else {
        // 英文：国标未规定，本包处理为 
        publisher + ", " + "printed " + year
      }
    })
    
    // === 处理估计出版年的标识 [est] ===
    // 中英文统一：将 "Publisher[est], year" 转换为 "Publisher, [year]"
    ittext = ittext.replace(regex("([^,\[]+)\[est\],\s*(\d{4})"), m => {
      let publisher = m.captures.at(0)
      let year = m.captures.at(1)
      publisher + ", [" + year + "]"
    })

    // === 自定义年份前缀/后缀 ===
    // <xxxx 表示前缀：显示为 "xxxx year"
    // xxxx> 表示后缀：显示为 "year xxxx"
    // ?> 或 <? 表示无 publisher 时的前缀/后缀
    
    // 首先处理 ?> 和 <? 的特殊情况（无 publisher）
    // 处理 "?: <?, year" 或 "地址: <?, year" 格式
    ittext = ittext.replace(regex("([^:]*?):\s*<\?,\s*(\d{4})"), m => {
      let before = m.captures.at(0).trim()
      let year = m.captures.at(1)
      
      // 如果 before 也是 ?，说明完全没有地址和出版社
      if before == "?" {
        year
      } else {
        before + ", " + year
      }
    })
    
    // 处理后缀 ?>suffix, year
    ittext = ittext.replace(regex("([^:]*?):\s*\?>([^,]+),\s*(\d{4})"), m => {
      let before = m.captures.at(0).trim()
      let suffix = m.captures.at(1)
      let year = m.captures.at(2)
      
      // 如果 before 也是 ?，说明完全没有地址和出版社
      if before == "?" {
        year + " " + suffix
      } else {
        before + ", " + year + " " + suffix
      }
    })
    
    // 处理没有冒号的情况（只有 publisher 字段，没有 address）
    // 处理 "<?something, year"
    ittext = ittext.replace(regex("([^\.:]+)\.\s*<\?([^,]+),\s*(\d{4})"), m => {
      let before = m.captures.at(0)
      let prefix_content = m.captures.at(1)
      let year = m.captures.at(2)
      
      before + ". " + prefix_content + " " + year
    })
    
    // 处理 "?>something, year"
    ittext = ittext.replace(regex("([^\.:]+)\.\s*\?>([^,]+),\s*(\d{4})"), m => {
      let before = m.captures.at(0)
      let suffix_content = m.captures.at(1)
      let year = m.captures.at(2)
      
      before + ". " + year + " " + suffix_content
    })
    
    // 处理前缀 <xxxx（普通情况，有 publisher）
    ittext = ittext.replace(regex("([^,<]+)<([^,>?]+),\s*(\d{4})"), m => {
      let publisher = m.captures.at(0)
      let prefix = m.captures.at(1)
      let year = m.captures.at(2)
      publisher + ", " + prefix + " " + year
    })
    
    // 处理后缀 xxxx>（普通情况，有 publisher）
    ittext = ittext.replace(regex("([^,>?]+)>([^,>]+),\s*(\d{4})"), m => {
      let publisher_raw = m.captures.at(0)
      let suffix = m.captures.at(1)
      let year = m.captures.at(2)
      
      let publisher = publisher_raw.replace(">", "")
      publisher + ", " + year + " " + suffix
    })
    
    // === 清理残留的 ? 占位符 ===
    // 清理 ". ?, year" 的情况
    ittext = ittext.replace(regex("\.\s*\?,\s*(\d{4})"), m => {
      let year = m.captures.at(0)
      ". " + year
    })
    
    // 清理 "address: ?, year" 的情况
    ittext = ittext.replace(regex(":\s*\?,\s*(\d{4})"), m => {
      let year = m.captures.at(0)
      ", " + year
    })

    // === 处理姓名前缀（全局处理） ===
    let name_prefixes = (
      "de", "des", "van", "von", "der", "den", "del", "della", "di", "da", 
      "le", "la", "du", "d'", "l'", "mac", "mc", "o'", "de la", "van de", 
      "van der", "von der", "te", "ten", "ter", "zum", "zur"
    )
    
    for prefix in name_prefixes {
      // 匹配模式：LASTNAME INITIALS prefix后跟标点/空格/结尾
      // 不使用lookahead，直接匹配后面的字符
      let pattern = regex("([A-Z]+)\s+([A-Z](?:\s+[A-Z])*)\s+" + prefix + "([\.,\s]|$)")
      
      ittext = ittext.replace(pattern, m => {
        let lastname = m.captures.at(0)
        let initials = m.captures.at(1)
        let after = m.captures.at(2)  // 保留后面的标点/空格
        
        if uppercase-english-names {
          upper(prefix) + " " + lastname + " " + initials + after
        } else {
          upper(prefix.at(0)) + lower(prefix.slice(1)) + " " + lastname + " " + initials + after
        }
      })
    }

    // === 处理后缀前的逗号 ===
    if before-suffix-comma {
      ittext = ittext.replace(regex("([A-Z]+)\s+(Jr|JR|Sr|SR|II|III|IV|V|VI)([,\.\s\u4e00-\u9fff\[]|$)"), m => {
        let name = m.captures.at(0)
        let suffix = m.captures.at(1)
        let after = m.captures.at(2)
        name + ", " + suffix + after
      })
    }
    
    // === 判断是否为中文文献 ===
    let pureittext = ittext.replace(regex("[等卷册和版本章期页篇译间者(不详)]"), "")
    let is-chinese = pureittext.find(regex("\p{sc=Hani}{2,}")) != none
    
    if is-chinese {
      // === 中文文献的特殊处理 ===
      
      // 应用标点符号转换
      let converted = convert-punctuation(ittext, true)
      
      // 查找所有URL
      let url-pattern = regex("https?://[^\s\u4e00-\u9fff]+")
      let url-matches = converted.matches(url-pattern)
      
      if url-matches.len() == 0 {
        // 没有URL，直接恢复保护内容并返回
        for item in protected_contents {
          converted = converted.replace(item.placeholder, item.content)
        }
        converted
      } else {
        // 有URL，需要构建content
        let result = ()
        let last-pos = 0
        
        for match in url-matches {
          // 添加URL之前的文本
          if match.start > last-pos {
            result.push(converted.slice(last-pos, match.start))
          }
          
          // 处理URL：每个字符后都插入极小空格
          let url-text = match.text
          let display-chars = url-text.clusters()
          let display-parts = ()
          
          for (i, char) in display-chars.enumerate() {
            display-parts.push(char)
            // 每个字符后都插入极小空格
            if i < display-chars.len() - 1 {
              display-parts.push(h(0.000000001em))
            }
          }
          
          // 用link()，dest是原始URL，body是带极小空格的显示内容
          result.push(link(url-text, display-parts.join()))
          
          last-pos = match.end
        }
        
        // 添加最后一个URL之后的文本
        if last-pos < converted.len() {
          result.push(converted.slice(last-pos))
        }
        
        let final_result = result.join()
        
        // === 恢复被保护的内容 ===
        for item in protected_contents {
          final_result = final_result.replace(item.placeholder, item.content)
        }
        
        final_result
      }
    } else {
      // === 英文文献的处理 ===

      let reptext = ittext

      // === 首先处理机构名（无论 uppercase-english-names 设置如何） ===
      let bracket_match = reptext.match(regex("\[[A-Z/]+\]"))
      
      if bracket_match != none {
        let before_bracket = reptext.slice(0, bracket_match.start)
        
        // 找到最后一个句点的位置
        let parts = before_bracket.split(".")
        if parts.len() > 1 {
          // 作者部分是除了最后一部分外的所有部分
          let author_parts = parts.slice(0, -1)
          let author_part = author_parts.join(".") + "."
          let rest_part = reptext.slice(author_part.len())
          
          // 机构名关键词（扩充列表）
          let organization_keywords = (
            "DEPARTMENT", "DEPT", "UNIVERSITY", "UNIV", "INSTITUTE", "INST",
            "ADMINISTRATION", "ADMIN", "COMMITTEE", "COMM", "ORGANIZATION", 
            "ORGANISATION", "ORG", "ASSOCIATION", "ASSOC", "CORPORATION", "CORP",
            "COMPANY", "CO", "MINISTRY", "BUREAU", "AGENCY", "CENTER", "CENTRE",
            "COUNCIL", "FOUNDATION", "NATIONAL", "INTERNATIONAL", "FEDERAL",
            "STATE", "GOVERNMENT", "GOVT", "COMMISSION", "LABORATORY", "LAB",
            "ACADEMY", "SOCIETY", "SOC", "DIVISION", "DIV", "OFFICE", "SERVICE",
            "BOARD", "SCHOOL", "COLLEGE", "RESEARCH", "HOSPITAL", "LIBRARY",
            "MUSEUM", "PRESS", "GROUP", "NETWORK", "CONSORTIUM", "ALLIANCE",
            "COALITION", "PROGRAM", "PROGRAMME", "PROJECT", "SYSTEM", "SYSTEMS",
            "STANDARDS", "TECHNICAL", "SCIENTIFIC", "INDUSTRIAL", "PUBLIC",
            "PRIVATE", "CHAMBER", "TRADE", "COMMERCE", "HEALTH", "ENVIRONMENTAL",
            "ENERGY", "TRANSPORTATION", "EDUCATION", "FINANCIAL", "ECONOMIC"
          )
          
          // 检查是否包含"介词+名词"的典型机构名结构
          let has_org_structure = (
            author_part.contains(" OF ") or 
            author_part.contains(" FOR ") or
            author_part.contains(" AND ")
          )
          
          // 统计单词数量
          let word_count = author_part.split(regex("[\s,]+")).filter(w => w.len() > 0).len()
          
          // 判断是否为机构名
          let is_organization = (
            organization_keywords.any(keyword => author_part.contains(keyword))
            or (has_org_structure and word_count >= 5)
          )
          
          if is_organization {
            // 虚词列表（应该保持小写）
            let articles_prepositions = (
              "OF", "THE", "AND", "FOR", "IN", "ON", "AT", "TO", 
              "A", "AN", "BY", "WITH", "FROM", "INTO", "OR", "NOR"
            )
            
            // 机构名：每个词首字母大写，虚词小写（跳过占位符）
            let converted_author = author_part.replace(regex("XPROTECTEDX\d+XPROTECTEDX|[A-Z]{2,}"), word_match => {
              let word = word_match.text
              
              // 跳过占位符
              if word.starts-with("XPROTECTEDX") {
                return word
              }
              
              // 保留的缩写
              let preserve_uppercase = (
                "URL", "DOI", "ISBN", "ISSN", "GB", "ISO", "IEC", "ANSI", "ASTM", "PB",
                "US", "UK", "EU", "UN", "USA", "USSR", "UAE", "UNESCO",
                "IEEE", "ACM", "NASA", "NOAA", "FDA", "EPA", "NIH", "NSF", "NIST",
                "MIT", "UCLA", "UCSB", "UCSD", "UIUC", "CMU", "ETH",
                "IBM", "HP", "AT", "IT", "AI", "ML", "NLP", "API", "SDK",
                "WHO", "WTO", "IMF", "OECD", "NATO"
              )
              
              if word in preserve_uppercase {
                word
              // 虚词转为小写
              } else if word in articles_prepositions {
                lower(word)
              // 其他词：首字母大写
              } else {
                upper(word.at(0)) + lower(word.slice(1))
              }
            })
            
            reptext = converted_author + rest_part
          }
        }
      }
      
      // === 然后处理人名（仅当 uppercase-english-names 为 false 时） ===
      if not uppercase-english-names {
        let bracket_match = reptext.match(regex("\[[A-Z/]+\]"))
        
        if bracket_match != none {
          let before_bracket = reptext.slice(0, bracket_match.start)
          let parts = before_bracket.split(".")
          
          if parts.len() > 1 {
            let author_parts = parts.slice(0, -1)
            let author_part = author_parts.join(".") + "."
            let rest_part = reptext.slice(author_part.len())
            
            // 检查是否已经被处理过（包含小写字母说明已处理，即已识别为机构名）
            if author_part.match(regex("[a-z]")) == none {
              // 人名：直接首字母大写，不处理虚词（跳过占位符）
              let converted_author = author_part.replace(regex("XPROTECTEDX\d+XPROTECTEDX|[A-Z]{2,}"), word_match => {
                let word = word_match.text
                // 跳过占位符
                if word.starts-with("XPROTECTEDX") {
                  return word
                }
                upper(word.at(0)) + lower(word.slice(1))
              })
              
              reptext = converted_author + rest_part
            }
          }
        }
      }
  
      // 第xxx卷、第xxx册的情况：变为 Vol. XXX 或 Bk. XXX。

      reptext = reptext.replace(regex("(第\s?)?\d+\s?[卷册]"), itt => {
        if itt.text.contains("卷") {
          "Vol. "
        } else {
          "Bk. "
        }
        itt.text.find(regex("\d+"))
      })

      // 第xxx版/第xxx本的情况：变为 1st ed 格式。
      reptext = reptext.replace(regex("(第\s?)?\d+\s?[版本]"), itt => {
        let num = itt.text.find(regex("\d+"))
        num
        if num.clusters().len() == 2 and num.clusters().first() == "1" {
          "th"
        } else {
          (
            "1": "st",
            "2": "nd",
            "3": "rd",
          ).at(num.clusters().last(), default: "th")
        }
        " ed"
      })

      // 译者数量判断：单数时需要用 trans，复数时需要用 tran 。
      reptext = reptext.replace(regex("\].+?译"), itt => {
        let comma-in-itt = itt.text.replace(regex(",?\s?译"), "").matches(",")
        if (
          type(comma-in-itt) == array
            and comma-in-itt.len()
              >= (
                if allow-comma-in-name { 2 } else { 1 }
              )
        ) {
          if extra-comma-before-et-al-trans {
            itt.text.replace(regex(",?\s?译"), ", tran")
          } else {
            itt.text.replace(regex(",?\s?译"), " tran")
          }
        } else {
          itt.text.replace(regex(",?\s?译"), ", trans")
        }
      })

      // `等` 特殊处理：`等`后方接内容也需要译作 `et al.`
      reptext = reptext.replace(regex("等."), itt => {
        "et al."
        if not itt.text.last() in (".", ",", ";", ":", "[", "]", "/", "\\", "<", ">", "?", "(", ")", " ", "\"", "'") {
          " "
        }
        if not itt.text.last() == "." {
          itt.text.last()
        }
      })

      // 其他情况：直接替换
      reptext = reptext.replace(regex("\p{sc=Hani}+"), itt => {
        mapping.at(itt.text, default: itt.text)
      })

      // 同样处理URL
      let url-pattern = regex("https?://[^\s]+")
      let url-matches = reptext.matches(url-pattern)
      
      if url-matches.len() == 0 {
        // === 恢复被保护的内容 ===
        for item in protected_contents {
          reptext = reptext.replace(item.placeholder, item.content)
        }
        reptext
      } else {
        let result = ()
        let last-pos = 0
        
        for match in url-matches {
          if match.start > last-pos {
            result.push(reptext.slice(last-pos, match.start))
          }
          
          let url-text = match.text
          let display-chars = url-text.clusters()
          let display-parts = ()
          
          for (i, char) in display-chars.enumerate() {
            display-parts.push(char)
            if i < display-chars.len() - 1 {
              display-parts.push(h(0.000000001em))
            }
          }
          
          result.push(link(url-text, display-parts.join()))
          last-pos = match.end
        }
        
        if last-pos < reptext.len() {
          result.push(reptext.slice(last-pos))
        }
        
        let final_result = result.join()
        
        // === 恢复被保护的内容 ===
        for item in protected_contents {
          final_result = final_result.replace(item.placeholder, item.content)
        }
        
        final_result
      }
    }
  }

  set text(lang: "zh", hyphenate: false)

  // 拉丁字母语言（英语、西班牙语、法语等）
  show regex("\\b[\\p{Latin}]{6,}\\b"): it => {
    text(lang: "en", hyphenate: true, it)
  }
  
  // 西里尔字母语言（俄语等）
  show regex("\\b[\\p{Cyrillic}]{6,}\\b"): it => {
    text(lang: "ru", hyphenate: true, it)
  }
  
  // 希腊字母
  show regex("\\b[\\p{Greek}]{6,}\\b"): it => {
    text(lang: "el", hyphenate: true, it)
  }
  
  bibliography(title: none, full: full, style: style)
}