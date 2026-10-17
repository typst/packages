
#let itemplate(
  doc-title: "Document",
  doc-author: "Author",
  lang: "en",
  body,
) = {
  context if target() == "html" {
    html.html(lang: lang, {
      html.head({
        html.meta(
          charset: "utf-8",
        )

        html.meta(
          name: "viewport",
          content: "width=device-width, initial-scale=1.0",
        )

        html.title(doc-title)

        html.link(
          rel: "stylesheet",
          blocking: "blocking",
          href: "https://cdn.jsdelivr.net/npm/@hexiongwu1995/itemplate/icon_font/iconfont.css",
        )

        html.script(
          type: "importmap",
          ```json
          {
            "imports": {
              "three": "https://cdn.jsdelivr.net/npm/three@0.185.1/build/three.module.js",
              "three/addons/": "https://cdn.jsdelivr.net/npm/three@0.185.1/examples/jsm/",
              "cannon-es": "https://cdn.jsdelivr.net/npm/cannon-es@0.20.0/dist/cannon-es.js",
              "fundamental-physical-constants": "https://unpkg.com/fundamental-physical-constants/FundamentalPhysicalConstants.js"
            }
          }
          ```.text,
        )
        // a test message to prove the workflow works
        // another test message to prove the workflow works in the process of pull request reviewing

        // html.script(
        //   ```js
        //   MathJax = {
        //     loader: {
        //       load: ['input/asciimath', 'output/chtml']
        //     }
        //   };
        //   ```.text,
        // )

        // html.script(src: "https://cdn.jsdelivr.net/npm/mathjax@4/startup.js", defer: true)

        // html.script(src: "https://cdn.jsdelivr.net/npm/mathjax@4/tex-mml-chtml.js", defer: true)

        // html.link(rel: "stylesheet", href: "https://unpkg.com/@hexiongwu1995/itemplate/styles/style.css")

        // html.link(rel: "stylesheet", href: "./assets/style.css")

        html.style(
          ```css
          :root {
            --enable-numbering: true;
            --all-expanded: false;
            --aside-width: 320px;
            --header-height: 60px;
            --article-height: calc(100vh - var(--header-height));

            --aside-title-height: 60px;
            --function-panel-height: 60px;
            --aside-nav-height: calc(100vh - var(--aside-title-height) - var(--function-panel-height));

            --level-1-height: 40px;
            --level-others-height: 30px;

            --aside-title-padding: 10px 20px;
            --aside-function-item-padding: 10px 20px 10px 20px;
            --toc-root-level-1-padding: 10px 20px 10px 20px;
            --toc-root-level-2-padding: 10px 20px 10px 30px;
            --toc-root-level-3-padding: 10px 20px 10px 40px;

            --aside-bag: #f5f2ed;
            --aside-title-bag: #ede8dffb;
            /* --function-item-bag: transparent; */
            /* --aside-icon-bag: transparent; */

            --aside-title-hover-bag: #eee5d3;
            --aside-function-item-hover-bag: #eee5d3;
            --toc-root-a-hover-bag: #eee5d3;
            --resize-handle-hover-bag: #dfb663;

            --aside-title-font-color: #924d0ca9;
            /* --aside-normal-font-color: #2d2d2d; */
            --aside-function-item-font-color: #69390963;
            --toc-root-a-font-color: #542d06;

            --aside-divider-color: #eae5defe;

            --main-bag: #fffefc;
            --header-bag: #fffefc;
            --header-button-bag: #ebe5d9;
            /* --header-icon-bag: transparent; */

            --header-button-hover-bag: #dfb663;

            --header-border-color: #dfdfdf;

            --header-button-font-color: #2d2d2d;
            --header-title-font-color: #aeaeae;
            --header-icon-font-color: #b0b0b0;

            --active-font-color: #0574ea;

            --aside-title-font-size: 1.2rem;
            --aside-function-icon-font-size: 1rem;
            --aside-function-text-font-size: 0.8rem;
            /* --toc-root-a-line-height: 1.5rem; */
            --toc-root-a-level-1-font-size: 1rem;
            --toc-root-a-others-font-size: 1rem;
            --toc-root-arrow-font-size: 1.2rem;

            --header-button-font-size: 2rem;
            --header-button-padding: 10px;
            --header-button-border-radius: 50%;
            --header-title-font-size: 1.5rem;
            --header-icon-font-size: 1.5rem;
            --header-icon-padding: 10px;

            --article-font-color: #2d2d2d;

            --article-font-size: 1rem;
            /* --article-p-margin-top: 1.5rem; */
          }

          .lil-gui.root {
            position: absolute;
            top: 0px;
            right: 0px;
            z-index: 10;
            width: 25%;
            max-width: 250px;
          }

          .lil-gui {
            --background-color: #dddddd;
            --title-background-color: #cccccc;
            --title-text-color: #000000;
            --widget-color: #cccccc;
            --hover-color: #bbbbbb;
            --text-color: #000000;
            --string-color: #017005;
            --number-color: #090909;
          }

          .lil-gui .title {
            background-color: #cccccc;
          }

          .lil-gui .controller {
            background-color: #dddddd;
          }

          @media screen and (max-width: 700px) {
            .lil-gui.root {
              display: none;
            }
          }

          * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
          }

          html,
          body,
          .container {
            width: 100vw;
            height: 100vh;
            margin: 0;
            padding: 0;
          }

          .container {
            display: flex;
            justify-content: flex-end;
            align-items: flex-start;
            position: relative;
          }

          aside {
            position: relative;
            width: var(--aside-width);
            height: 100vh;
            background-color: var(--aside-bag);
            overflow: hidden;
            transition: width 0.3s ease;
          }

          aside.resizing {
            transition: none;
          }

          aside.hidden {
            width: 0;
          }

          .aside-title-large-screen,
          .aside-title-small-screen {
            display: block;
            width: 100%;
            line-height: var(--aside-title-height);
            padding-left: 20px;
            text-align: left;
            background-color: var(--aside-title-bag);
            color: var(--aside-title-font-color);
            font-size: var(--aside-title-font-size);
            font-weight: 500;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
          }

          .aside-title-large-screen:hover,
          .aside-title-small-screen:hover {
            background-color: var(--aside-title-hover-bag);
          }

          .aside-title-small-screen {
            display: none;
          }

          #resize-handle {
            position: absolute;
            /* z-index: 10; */
            top: 0;
            right: 0;
            width: 4px;
            height: 100vh;
            background-color: transparent;
          }

          #resize-handle:hover {
            background-color: var(--resize-handle-hover-bag);
            cursor: col-resize;
          }

          #resize-handle.resizing {
            background-color: var(--resize-handle-hover-bag);
            cursor: col-resize;
          }

          .function-panel {
            width: 100%;
            height: var(--function-panel-height);
            border-bottom: 2px solid var(--aside-divider-color);
            background-color: transparent;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
          }

          .icon-Numbering,
          .icon-expand-all {
            width: 50%;
            height: 100%;
            padding: var(--aside-function-item-padding);
            display: flex;
            justify-content: flex-start;
            align-items: center;
            gap: 20px;
            background-color: transparent;
            color: var(--aside-function-item-font-color);
            font-size: var(--aside-function-icon-font-size);
            overflow: hidden;
          }

          .icon-Numbering .numbering-text,
          .icon-expand-all .expand-all-text {
            font-size: var(--aside-function-text-font-size);
          }

          .icon-Numbering:hover,
          .icon-expand-all:hover {
            background-color: var(--aside-function-item-hover-bag);
            cursor: pointer;
          }

          nav {
            width: 100%;
            height: var(--aside-nav-height);
            overflow-y: auto;
            overflow-x: hidden;
            padding: 10px 0;
            scrollbar-width: none;
            /* Firefox 隐藏滚动条 */
            -ms-overflow-style: none;
            /* IE/Edge 旧版本隐藏滚动条 */
          }

          nav::-webkit-scrollbar {
            /*  Chrome、Safari、新版 Edge 隐藏滚动条 */
            display: none;
          }

          #toc-root,
          #toc-root ol,
          #toc-root li,
          #toc-root a {
            width: 100%;
          }

          #toc-root li {
            list-style: none;
          }

          #toc-root a {
            font-size: var(--toc-root-a-others-font-size);
            /* line-height: 2em; */
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 10px;
            flex-wrap: nowrap;
            color: var(--toc-root-a-font-color);
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
          }

          #toc-root > li > a {
            font-size: var(--toc-root-a-level-1-font-size);
            padding: var(--toc-root-level-1-padding);
            font-weight: 500;
          }

          #toc-root > li > ol > li > a {
            padding: var(--toc-root-level-2-padding);
          }

          #toc-root > li > ol > li > ol > li > a {
            padding: var(--toc-root-level-3-padding);
          }

          #toc-root li a:hover {
            background-color: var(--toc-root-a-hover-bag);
          }

          aside a {
            text-decoration: none;
            /* color: var(--aside-normal-font-color); */
          }

          #toc-root li ol {
            display: none;
            opacity: 0;
          }

          #toc-root li ol.show {
            display: block;
            opacity: 1;
          }

          span.icon-arrow2 {
            font-size: var(--toc-root-arrow-font-size);
            padding: 0px 10px;
          }

          span.rotate-90 {
            transform: rotate(90deg);
            transition: transform 0.3s ease;
          }

          .overlay {
            display: none;
          }

          main {
            position: relative;
            z-index: 5;
            width: calc(100vw - var(--aside-width));
            height: 100vh;
            background-color: var(--main-bag);
            overflow-y: auto;
            overflow-x: hidden;
            transition: width 0.3s ease;
          }

          main.hidden {
            width: 100vw;
          }

          main.resizing {
            transition: none;
          }

          header {
            position: sticky;
            z-index: 10;
            top: 0;
            width: 100%;
            height: var(--header-height);
            background-color: var(--header-bag);
            border-bottom: 1px solid var(--header-border-color);
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 0px 20px;
            overflow: hidden;
          }

          .header-left {
            width: 33%;
          }

          .header-middle {
            width: 33%;
            text-align: center;
            font-size: var(--header-title-font-size);
            font-weight: 500;
            color: var(--header-title-font-color);
            overflow: hidden;
          }

          .header-right {
            width: 33%;
            display: flex;
            justify-content: flex-end;
            align-items: center;
            gap: 30px;
            overflow: hidden;
            background-color: transparent;
            color: var(--header-icon-font-color);
            font-size: var(--header-icon-font-size);
          }

          .icon-Aside,
          .icon-menu3 {
            font-size: var(--header-button-font-size);
            padding: var(--header-button-padding);
            background-color: var(--header-button-bag);
            color: var(--header-button-font-color);
            border-radius: var(--header-button-border-radius);
          }

          .icon-Aside:hover,
          .icon-menu3:hover {
            background-color: var(--header-button-hover-bag);
            transform: translateY(-5px);
            transition: transform 0.3s ease;
            cursor: pointer;
          }

          .icon-menu3 {
            display: none;
          }

          header a {
            text-decoration: none;
            color: var(--header-icon-font-color);
          }

          article {
            width: 100%;
            height: auto;
            max-width: 1000px;
            margin: 20px auto;
            padding: 20px 20px 150px 20px;
            overflow-x: hidden;
            overflow-y: auto;
          }

          article li {
            /* list-style: none; */
            list-style-position: inside;
            padding-left: 2em;
          }

          article a {
            color: var(--article-font-color);
          }

          @media screen and (max-width: 1000px) {
            :root {
              --aside-width: 300px;
              --header-height: 0;
            }

            aside {
              position: absolute;
              z-index: 20;
              top: 0;
              left: calc(-1 * var(--aside-width));
            }

            aside.show {
              transform: translateX(var(--aside-width));
              transition: transform 0.3s ease-in-out;
            }

            .aside-title-large-screen {
              display: none;
            }

            .aside-title-small-screen {
              display: block;
            }

            #resize-handle {
              display: none;
            }

            .overlay {
              display: none;
            }

            .overlay.show {
              display: block;
              position: absolute;
              z-index: 10;
              top: 0;
              left: 0;
              width: 100vw;
              height: 100vh;
              background-color: rgba(1, 1, 1, 0.3);
            }

            main {
              position: relative;
              z-index: 5;
              width: 100vw;
            }

            header {
              height: var(--header-height);
              overflow: hidden;
            }

            /*
            .header-left {
              width: 20%;
            }

            .header-middle {
              text-align: left;
              width: 0;
            }

            .header-right {
              width: 45%;
              gap: 20px;
            }
            */

            .icon-Aside {
              display: none;
            }

            .icon-menu3 {
              display: block;
              position: fixed;
              z-index: 100;
              right: 40px;
              bottom: 100px;
            }

            .icon-menu3:hover {
              transform: rotateX(180deg);
              transition: transform 0.3s ease;
              cursor: pointer;
            }
          }

          /* 行间距和段间距 */
          p {
            line-height: 1.2;
            margin: 1rem 0;
          }

          /* 标题跳转时留出 header 高度 + 缓冲间距，防止被遮挡 */
          article :is(h1, h2, h3, h4, h5, h6) {
            scroll-margin-top: calc(var(--header-height) + 2px);
          }

          /* highlight.css */

          div.highlight {
            width: 90%;
            padding: 10px 15px;
            margin: 2rem 0;
            border-left: 3px solid #b8b8b8;
            background-color: #f8f9fa;
            border-radius: 4px;
          }

          table {
            width: 90%;
            border: 1px solid;
            border-collapse: collapse;
            overflow-x: auto;
          }

          table th,
          table td {
            border: 1px solid;
            padding: 8px;
          }

          /* theoframe.css */

          figure {
            width: 95%;
            margin: 20px auto;
            scroll-margin-top: calc(var(--header-height) + 2px);
            overflow: hidden;
          }

          article a {
            color: var(--article-font-color);
            text-decoration: none;
          }

          /* mathfonts.css */

          html {
            font-family: "NewComputerModern10", "Latin Modern Math", "STIX Two Math", "Noto Sans Math", "Cambria Math", "Fira Math", "Times New Roman", "KaiTi", sans-serif;
          }

          math {
            font-family: "NewComputerModernMath", "Latin Modern Math", "STIX Two Math", "Noto Sans Math", math;
            font-weight: 400;
            font-style: normal;
          }

          mover[accent="true"] > mo {
            margin-left: 0.2em;
          }

          /* 调整行间距和段间距 */

          p {
            line-height: 1.5;
            margin-bottom: 0.8em;
          }

          article div {
            line-height: 1.5;
            margin-bottom: 0.8em;
          }

          article li {
            line-height: 1.5;
          }

          math {
            font-size: clamp(0.6rem, 3.5vw, 1rem);
            line-height: 1.5;
            margin-bottom: 0.8em;
          }

          math[display="block"] {
            max-width: 100%;
            overflow-x: auto;
            overflow-y: hidden;
            scrollbar-width: none; /* Firefox */
            -ms-overflow-style: none; /* IE 10+ */
          }

          math[display="block"]::-webkit-scrollbar {
            display: none; /* Chrome, Safari, Edge */
          }
          ```.text,
        )

        html.link(rel: "stylesheet", href: "https://fred-wang.github.io/MathFonts/NewComputerModern/mathfonts.css")
        // html.link(rel: "stylesheet", href: "https://fred-wang.github.io/MathFonts/LatinModern/mathfonts.css")
        // html.link(rel: "preconnect", href: "https://fonts.googleapis.com")
        // html.link(rel: "preconnect", href: "https://fonts.gstatic.com", crossorigin: "anonymous")
        // html.link(rel: "stylesheet", href: "https://fonts.googleapis.com/css2?family=Noto+Sans+Math&family=STIX+Two+Math&display=swap")

        // html.script(src: "https://unpkg.com/@hexiongwu1995/itemplate/scripts/script.js", defer: true)
        // html.script(src: "./assets/script.js", defer: true)
        html.script(
          type: "module",
          ```js
          /*
          方案二： 在script.js中统一管理所有动画的可见性和启停。
          问题：IntersectionObserver 只能观察 DOM 元素，但无法直接控制另一个文件中的 requestAnimationFrame 循环。
          需要跨文件通信才能统一管理所有 three-animation 元素的动画启停，而且同样需要在每个动画文件中通过isIntersecting和isVisible控制动画启停。
          这是更加复杂的方案，因为逻辑拆分在多个文件中，难以理解。
          */

          function getLevel(heading) {
            return parseInt(heading.tagName[1], 10);
          }

          // 给每个 heading 生成id、添加numbering和data-original-text属性
          function initHeadings() {
            const headings = Array.from(document.querySelectorAll("h2, h3, h4"));

            const counters = [];

            if (headings.length > 0) {
              headings.forEach((heading) => {
                const level = getLevel(heading);

                // 确保数组有足够的长度
                while (counters.length < level - 1) {
                  counters.push(0);
                }
                // 截断到当前层级
                counters.length = level - 1;
                // 当前层级计数+1（用 level-2 作为索引）
                counters[level - 2] = counters[level - 2] + 1;

                const id = counters.join("-");
                heading.id = "heading-" + id;

                const numbering = counters.join(".");

                heading.setAttribute("data-original-text", heading.textContent);
                heading.setAttribute("data-numbering", numbering);
              });
            }
          }

          // 保存 heading 与 TOC 中 <a> 元素的映射，用于后续更新文本而不重建结构
          const tocLinkMap = new Map();

          function buildToc() {
            const headings = Array.from(document.querySelectorAll("h2, h3, h4"));
            const tocRoot = document.getElementById("toc-root");
            if (headings.length === 0) return;

            tocRoot.innerHTML = "";
            tocLinkMap.clear();

            const stack = [{ level: getLevel(headings[0]), ol: tocRoot }];

            headings.forEach((heading, index) => {
              const currentLevel = getLevel(heading);

              const arrow = document.createElement("span");
              arrow.classList.add("iconfont", "icon-arrow2");

              // 新建一个li元素，用于承载当前的heading元素
              const li = document.createElement("li");
              const a = document.createElement("a");
              a.href = "#" + heading.id;

              // 保存映射关系，方便后续更新文本
              tocLinkMap.set(heading, a);

              // 判断当前 heading 后面是否存在层级更深的子 heading
              const nextHeading = headings[index + 1];
              const hasChildren = nextHeading && getLevel(nextHeading) > currentLevel;

              if (hasChildren) {
                a.appendChild(arrow);
              }
              li.appendChild(a);

              // 如果栈顶的heading level 大于 当前的heading level，让栈顶回退到栈顶level等于当前heading level的状态
              while (stack[stack.length - 1].level > currentLevel) {
                stack.pop();
              }

              if (currentLevel > stack[stack.length - 1].level) {
                // 如果当前的heading level 大于栈顶的heading level

                // 新建一个空的ol元素，挂在栈顶的ol元素的最后一个li元素下
                const newOl = document.createElement("ol");
                const parentLi = stack[stack.length - 1].ol.lastElementChild;
                if (parentLi) {
                  parentLi.appendChild(newOl);
                }

                // 将当前的heading level 和 新建的ol元素压到栈顶
                stack.push({ level: currentLevel, ol: newOl });
              }

              // 将li元素添加到栈顶的ol元素下
              stack[stack.length - 1].ol.appendChild(li);
            });

            updateHeadingText();
          }

          // 只更新 TOC 和 heading 的文本内容，不重建 DOM 结构
          function updateHeadingText() {
            const root = document.documentElement;
            const headings = Array.from(document.querySelectorAll("h2, h3, h4"));
            if (headings.length === 0) return;

            const enableNumbering = getComputedStyle(root).getPropertyValue("--enable-numbering").trim();

            headings.forEach((heading) => {
              const a = tocLinkMap.get(heading);

              // 保留 arrow 元素，只更新文本部分
              const arrow = a.querySelector(".icon-arrow2");

              if (enableNumbering === "false") {
                heading.textContent = heading.getAttribute("data-original-text");

                a.innerHTML = "";
                a.textContent = heading.textContent;
                if (arrow) {
                  a.appendChild(arrow);
                }
              } else if (enableNumbering === "true") {
                heading.textContent = heading.getAttribute("data-numbering") + " " + heading.getAttribute("data-original-text");
                a.innerHTML = "";
                a.textContent = heading.textContent;
                if (arrow) {
                  a.appendChild(arrow);
                }
              } else {
                console.log("--enable-numbering:", enableNumbering);
                console.log(new Error("--enable-numbering must be true or false"));
              }
            });
          }

          // 显示/隐藏目录编号
          function switchNumbering() {
            const root = document.documentElement;
            const toggleNumbering = document.querySelector(".icon-Numbering");
            const iconNumbering = document.querySelector(".icon-Numbering");

            if (toggleNumbering) {
              toggleNumbering.addEventListener("click", () => {
                iconNumbering.style.userSelect = "none";
                const enableNumbering = getComputedStyle(root).getPropertyValue("--enable-numbering").trim();
                const resetNumbering = enableNumbering === "true" ? "false" : "true";
                root.style.setProperty("--enable-numbering", resetNumbering);

                updateHeadingText();
              });
            }
          }

          // 点击arrow切换目录展开状态
          function toggleNestedToc() {
            const nav = document.querySelector("nav");
            if (nav) {
              nav.addEventListener("click", (e) => {
                const arrow = e.target.closest(".icon-arrow2");
                if (!arrow) return;

                e.preventDefault();
                e.stopPropagation();

                const li = arrow.closest("li");
                const nestedOl = li.querySelector(":scope > ol");

                if (!nestedOl) return;

                nestedOl.classList.toggle("show");
                arrow.classList.toggle("rotate-90");
              });
            }
          }

          // 展开/收起 所有目录
          function toggleAllToc() {
            const root = document.documentElement;
            const iconExpand = document.querySelector(".icon-expand-all");
            const tocRoot = document.getElementById("toc-root");

            if (iconExpand) {
              iconExpand.addEventListener("click", () => {
                iconExpand.style.userSelect = "none";
                const ol = tocRoot.querySelectorAll("ol");
                const arrows = tocRoot.querySelectorAll(".icon-arrow2");
                const allExpandedValue = getComputedStyle(root).getPropertyValue("--all-expanded").trim();
                const newAllExpanded = allExpandedValue === "false" ? "true" : "false";
                root.style.setProperty("--all-expanded", newAllExpanded);

                if (newAllExpanded === "true") {
                  ol.forEach((item) => {
                    item.classList.add("show");
                  });
                  arrows.forEach((arrow) => {
                    arrow.classList.add("rotate-90");
                  });
                } else if (newAllExpanded === "false") {
                  ol.forEach((item) => {
                    item.classList.remove("show");
                  });
                  arrows.forEach((arrow) => {
                    arrow.classList.remove("rotate-90");
                  });
                } else {
                  alert("展开/收起所有目录失败");
                }
              });
            }
          }

          // 大屏状态下 显示/隐藏 侧边栏
          function largeScreenToggleAside() {
            const iconAside = document.querySelector(".icon-Aside");
            const aside = document.querySelector("aside");
            const main = document.querySelector("main");

            if (iconAside) {
              iconAside.addEventListener("click", () => {
                main.classList.toggle("hidden");
                aside.classList.toggle("hidden");
              });
            }
          }

          // 小屏状态下 显示/隐藏 侧边栏
          function smallScreenToggleAside() {
            const aside = document.querySelector("aside");
            const iconMenu3 = document.querySelector(".icon-menu3");
            const overlay = document.querySelector(".overlay");

            if (iconMenu3) {
              iconMenu3.addEventListener("click", () => {
                iconMenu3.classList.toggle("show");
                aside.classList.toggle("show");
                overlay.classList.toggle("show");
              });
            }

            if (overlay) {
              overlay.addEventListener("click", () => {
                iconMenu3.classList.remove("show");
                aside.classList.remove("show");
                overlay.classList.remove("show");
              });
            }
          }

          // 侧边栏宽度调整
          function adjustAsideWidth() {
            const root = document.documentElement;
            const resizeHandle = document.querySelector("#resize-handle");
            const asideEl = document.querySelector("aside");
            const mainEl = document.querySelector("main");

            if (resizeHandle && asideEl && mainEl) {
              let isResizing = false;
              let startX = 0;
              let startWidth = 0;
              let rafId = null;
              const minWidth = 0;
              const maxWidth = 500;

              resizeHandle.addEventListener("mousedown", (e) => {
                isResizing = true;
                startX = e.clientX;
                const currentWidth = parseInt(getComputedStyle(root).getPropertyValue("--aside-width").trim(), 10);
                startWidth = currentWidth;
                resizeHandle.classList.add("resizing");
                asideEl.classList.add("resizing");
                mainEl.classList.add("resizing");
                document.body.style.userSelect = "none";
              });

              document.addEventListener("mousemove", (e) => {
                if (!isResizing) return;
                if (rafId) return;

                rafId = requestAnimationFrame(() => {
                  rafId = null;
                  const delta = e.clientX - startX;
                  let newWidth = startWidth + delta;
                  if (newWidth < minWidth) newWidth = minWidth;
                  if (newWidth > maxWidth) newWidth = maxWidth;
                  root.style.setProperty("--aside-width", newWidth + "px");
                });
              });

              document.addEventListener("mouseup", () => {
                if (!isResizing) return;
                isResizing = false;
                if (rafId) {
                  cancelAnimationFrame(rafId);
                  rafId = null;
                }
                resizeHandle.classList.remove("resizing");
                asideEl.classList.remove("resizing");
                mainEl.classList.remove("resizing");
                document.body.style.userSelect = "";
              });
            }
          }

          function initializeApp() {
            initHeadings();
            console.log("已为标题添加id, 多级序号属性和原始标题内容属性");
            buildToc();
            console.log("已构建目录");
            switchNumbering();
            console.log("开始监听目录编号显示/隐藏的切换按钮");
            toggleNestedToc();
            console.log("开始监听目录展开/收起的切换箭头");
            toggleAllToc();
            console.log("开始监听目录全部展开/收起的切换按钮");
            largeScreenToggleAside();
            console.log("开始监听大屏状态下侧边栏显示/隐藏的切换按钮");
            smallScreenToggleAside();
            console.log("开始监听小屏状态下侧边栏显示/隐藏的切换按钮");
            adjustAsideWidth();
            console.log("开始监听侧边栏宽度调整的resizeHandle");
          }

          initializeApp();
          ```.text,
        )
      })
      html.body({
        html.div(class: ("container",), {
          html.aside({
            html.span(class: ("aside-title-large-screen",), "Table of Contents")
            html.span(class: ("aside-title-small-screen",), doc-title)
            html.div(class: ("function-panel",), {
              html.span(class: ("iconfont", "icon-Numbering"), {
                html.span(class: "numbering-text")[Numbering Titles]
              })
              html.span(class: ("iconfont", "icon-expand-all"), {
                html.span(class: "expand-all-text")[Expand All]
              })
            })
            html.nav({
              html.ol(id: "toc-root")[]
            })
            html.div(id: "resize-handle")[]
          })
          html.div(class: ("overlay",))[]
          html.main({
            html.header({
              html.span(class: ("header-left",), {
                html.span(class: ("iconfont", "icon-Aside"))[]
                html.span(class: ("iconfont", "icon-menu3"))[]
              })
              html.span(class: ("header-middle",), doc-title)
              html.span(class: ("header-right",), {
                html.a(class: ("iconfont-home",), {
                  html.span(class: ("iconfont", "icon-home"))[]
                })
                html.a(class: ("iconfont-github",), {
                  html.span(class: ("iconfont", "icon-github"))[]
                })
                html.a(class: ("iconfont-print",), {
                  html.span(class: ("iconfont", "icon-print"))[]
                })
                html.a(class: ("iconfont-paintbrush",), {
                  html.span(class: ("iconfont", "icon-paintbrush"))[]
                })
              })
            })
            html.article({
              body
            })
          })
        })
      })
    })
  } else if target() == "bundle" {
    panic("bundle export is not supported by itemplate(version 0.5.0), please export the document to html instead")
  } else {
    body
  }
}
