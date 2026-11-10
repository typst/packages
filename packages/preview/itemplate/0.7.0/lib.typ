
/* 
This is a Typst template for generating interactive HTML documents. It compiles Typst markup into a self-contained HTML file with a responsive layout, featuring a sidebar table of contents.

The template comes with built-in support for:

- **Three.js** for embedding 3D scenes (e.g. the orbital cube demo).
*/

// 默认主题：集中定义界面配色，可通过 itemplate(theme: (...)) 覆盖其中任意一项。
#let default-theme = (
  aside-bag: rgb("#f5f2ed"),
  aside-title-bag: rgb("#ede8dffb"),
  aside-title-hover-bag: rgb("#eee5d3"),
  toc-root-a-hover-bag: rgb("#eee5d3"),
  resize-handle-hover-bag: rgb("#dfb663"),
  aside-title-font-color: rgb("#924d0ca9"),
  toc-root-a-font-color: rgb("#542d06"),
  main-bag: rgb("#fffefc"),
  header-bag: rgb("#fffefc"),
  header-button-bag: rgb("#ebe5d9"),
  header-icon-bag: "transparent",
  header-button-hover-bag: rgb("#dfb663"),
  header-border-color: rgb("#dfdfdf"),
  header-button-font-color: rgb("#2d2d2d"),
  header-title-font-color: rgb("#aeaeae"),
  header-icon-font-color: rgb("#b0b0b0"),
  article-font-color: rgb("#2d2d2d"),
  // lil-gui 调试面板
  lil-gui-bag: rgb("#dddddd"),
  lil-gui-title-bag: rgb("#cccccc"),
  lil-gui-title-font-color: rgb("#000000"),
  lil-gui-widget-bag: rgb("#cccccc"),
  lil-gui-hover-bag: rgb("#bbbbbb"),
  lil-gui-font-color: rgb("#000000"),
  lil-gui-string-font-color: rgb("#017005"),
  lil-gui-number-font-color: rgb("#090909"),
  // 小屏展开侧栏时的遮罩
  overlay-bag: rgb(1, 1, 1, 30%),
)

// 将主题字典转换为 :root 中的 CSS 变量声明。
#let theme-to-css(theme) = {
  let declarations = theme
    .pairs()
    .map(((name, value)) => {
      let css-value = if type(value) == color { value.to-hex() } else { str(value) }
      "  --" + name + ": " + css-value + ";"
    })
  ":root {\n" + declarations.join("\n") + "\n}"
}

#let itemplate(
  doc-title: "Document",
  doc-author: "Author",
  lang: "en",
  theme: (:),
  body,
) = {
  context if target() == "html" {
    let resolved-theme = default-theme + theme
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

        html.style(theme-to-css(resolved-theme))

        html.style(
          ```css
            :root {

              --aside-width: 320px;
              --header-height: 60px;
              --article-height: calc(100vh - var(--header-height));

              --aside-title-height: 60px;
              --aside-nav-height: calc(100vh - var(--aside-title-height));

              --level-1-height: 40px;
              --level-others-height: 30px;

              --aside-title-padding: 10px 20px;
              --toc-root-level-1-padding: 10px 20px 10px 20px;
              --toc-root-level-2-padding: 10px 20px 10px 30px;
              --toc-root-level-3-padding: 10px 20px 10px 40px;

              --aside-title-font-size: 1.2rem;

              --toc-root-a-level-1-font-size: 1rem;
              --toc-root-a-others-font-size: 1rem;
              --toc-root-arrow-font-size: 1.2rem;

              --header-button-font-size: 2rem;
              --header-button-padding: 10px;
              --header-button-border-radius: 50%;
              --header-title-font-size: 1.5rem;
              --header-icon-font-size: 1.5rem;
              --header-icon-padding: 10px;

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
              --background-color: var(--lil-gui-bag);
              --title-background-color: var(--lil-gui-title-bag);
              --title-text-color: var(--lil-gui-title-font-color);
              --widget-color: var(--lil-gui-widget-bag);
              --hover-color: var(--lil-gui-hover-bag);
              --text-color: var(--lil-gui-font-color);
              --string-color: var(--lil-gui-string-font-color);
              --number-color: var(--lil-gui-number-font-color);
          }

          .lil-gui .title {
              background-color: var(--lil-gui-title-bag);
          }

          .lil-gui .controller {
              background-color: var(--lil-gui-bag);
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

          @media (hover: hover) {
              .aside-title-large-screen:hover,
              .aside-title-small-screen:hover {
                  background-color: var(--aside-title-hover-bag);
              }
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

          @media (hover: hover) {
              #resize-handle:hover {
                  background-color: var(--resize-handle-hover-bag);
                  cursor: col-resize;
              }
          }

          #resize-handle.resizing {
              background-color: var(--resize-handle-hover-bag);
              cursor: col-resize;
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

          #toc-root>li>a {
              font-size: var(--toc-root-a-level-1-font-size);
              padding: var(--toc-root-level-1-padding);
              font-weight: 500;
          }

          #toc-root>li>ol>li>a {
              padding: var(--toc-root-level-2-padding);
          }

          #toc-root>li>ol>li>ol>li>a {
              padding: var(--toc-root-level-3-padding);
          }

          @media (hover: hover) {
              #toc-root li a:hover {
                  background-color: var(--toc-root-a-hover-bag);
              }
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
              width: 20%;
          }

          .header-middle {
              width: 60%;
              text-align: center;
              font-size: var(--header-title-font-size);
              font-weight: 500;
              color: var(--header-title-font-color);
              overflow: hidden;
          }

          .header-right {
              width: 20%;
              display: flex;
              justify-content: flex-end;
              align-items: center;
              gap: 30px;
              overflow: hidden;
              background-color: transparent;
              color: var(--header-icon-font-color);
              font-size: var(--header-icon-font-size);
          }

          .icon-Aside {
              font-size: var(--header-button-font-size);
              padding: var(--header-button-padding);
              background-color: var(--header-button-bag);
              color: var(--header-button-font-color);
              border-radius: var(--header-button-border-radius);
          }

          @media (hover: hover) {
              .icon-Aside:hover {
                  background-color: var(--header-button-hover-bag);
                  transform: translateY(-5px);
                  transition: transform 0.3s ease;
                  cursor: pointer;
              }
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
                  background-color: var(--overlay-bag);
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

              .icon-Aside {
                  display: none;
              }

            }

          /* 标题跳转时留出 header 高度 + 缓冲间距，防止被遮挡 */
          article :is(h1, h2, h3, h4, h5, h6) {
              scroll-margin-top: calc(var(--header-height) + 2px);
          }

          /* highlight.css */

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

          mover[accent="true"]>mo {
              margin-left: 0.2em;
          }

          /* 调整行间距和段间距 */

          p {
              margin: 1rem 0;
          }

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
              scrollbar-width: none;
              /* Firefox */
              -ms-overflow-style: none;
              /* IE 10+ */
          }

          math[display="block"]::-webkit-scrollbar {
              display: none;
              /* Chrome, Safari, Edge */
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

          const HEADING_SELECTOR = "h2, h3, h4";

          const root = document.documentElement;
          const tocRoot = document.getElementById("toc-root");
          const aside = document.querySelector("aside");
          const main = document.querySelector("main");
          const overlay = document.querySelector(".overlay");
          const resizeHandle = document.querySelector("#resize-handle");

          const getLevel = (heading) => Number(heading.tagName[1]);

          // 小屏状态下 显示/隐藏 侧边栏及其遮罩层
          function setAsideOpen(open) {
            aside.classList.toggle("show", open);
            overlay.classList.toggle("show", open);
          }

          // 给每个标题生成 id、多级编号，并据此构建侧边栏目录
          function buildToc() {
            const headings = Array.from(document.querySelectorAll(HEADING_SELECTOR));
            if (!tocRoot || headings.length === 0) return;

            tocRoot.replaceChildren();

            const levels = headings.map(getLevel);
            const counters = [];
            // 栈顶记录当前标题应插入的 ol 及其层级
            const stack = [{ level: Math.min(...levels), ol: tocRoot }];

            headings.forEach((heading, index) => {
              const level = levels[index];
              const originalText = heading.textContent;

              // 多级编号：h2 -> 1，h3 -> 1.1，h4 -> 1.1.1
              while (counters.length < level - 1) counters.push(0);
              counters.length = level - 1;
              counters[level - 2] += 1;

              const numbering = counters.join(".");
              heading.id = "heading-" + counters.join("-");
              heading.dataset.numbering = numbering;
              heading.dataset.originalText = originalText;
              heading.textContent = numbering + " " + originalText;

              const li = document.createElement("li");
              const a = document.createElement("a");
              a.href = "#" + heading.id;
              a.textContent = heading.textContent;

              // 后面存在层级更深的标题时，才显示展开/收起箭头
              if (levels[index + 1] > level) {
                const arrow = document.createElement("span");
                arrow.className = "iconfont icon-arrow2";
                a.append(arrow);
              }
              li.append(a);

              // 回退到与当前标题同级的 ol
              while (stack[stack.length - 1].level > level) stack.pop();

              // 首次出现更深的层级时，在上一个 li 中新建子 ol
              if (level > stack[stack.length - 1].level) {
                const subOl = document.createElement("ol");
                stack[stack.length - 1].ol.lastElementChild?.append(subOl);
                stack.push({ level, ol: subOl });
              }

              stack[stack.length - 1].ol.append(li);
            });
          }

          // 点击箭头展开/收起子目录
          function initTocToggle() {
            tocRoot?.addEventListener("click", (e) => {
              const arrow = e.target.closest(".icon-arrow2");
              if (!arrow) return;

              e.preventDefault();
              e.stopPropagation();

              const nestedOl = arrow.closest("li").querySelector(":scope > ol");
              if (!nestedOl) return;

              nestedOl.classList.toggle("show");
              arrow.classList.toggle("rotate-90");
            });
          }

          // 大屏按钮开合侧边栏；小屏点击遮罩收起侧边栏
          function initAsideToggle() {
            document.querySelector(".icon-Aside")?.addEventListener("click", () => {
              main.classList.toggle("hidden");
              aside.classList.toggle("hidden");
            });

            overlay?.addEventListener("click", () => setAsideOpen(false));
          }

          // 小屏状态下 手指右滑滑出侧边栏，左滑收起侧边栏
          function initAsideSwipe() {
            const mediaQuery = window.matchMedia("(max-width: 1000px)");
            const SWIPE_THRESHOLD = 50;
            let startX = 0;
            let startY = 0;
            let tracking = false;

            // 判断触摸起点是否位于可横向滚动的容器（如长公式、代码块）或 canvas 内
            // 若是，则该区域的手势留给元素自身的横向滚动，不触发侧边栏滑动手势
            function isInScrollableArea(target) {
              let el = target instanceof Element ? target : null;
              while (el && el !== document.body) {
                if (el instanceof HTMLCanvasElement) return true;
                const overflowX = getComputedStyle(el).overflowX;
                if ((overflowX === "auto" || overflowX === "scroll" || overflowX === "overlay") &&
                  el.scrollWidth > el.clientWidth + 1) {
                  return true;
                }
                el = el.parentElement;
              }
              return false;
            }

            document.addEventListener("touchstart", (e) => {
              if (!mediaQuery.matches || e.touches.length !== 1 || isInScrollableArea(e.target)) return;
              startX = e.touches[0].clientX;
              startY = e.touches[0].clientY;
              tracking = true;
            }, { passive: true });

            document.addEventListener("touchend", (e) => {
              if (!tracking) return;
              tracking = false;

              const dx = e.changedTouches[0].clientX - startX;
              const dy = e.changedTouches[0].clientY - startY;

              // 水平位移足够大且以水平为主时才视为有效滑动
              if (Math.abs(dx) < SWIPE_THRESHOLD || Math.abs(dx) <= Math.abs(dy)) return;

              // 右滑滑出侧边栏，左滑收起侧边栏
              setAsideOpen(dx > 0);
            }, { passive: true });
          }

          // 拖拽 resizeHandle 调整侧边栏宽度
          function initAsideResize() {
            if (!resizeHandle) return;

            const MIN_WIDTH = 0;
            const MAX_WIDTH = 500;
            let startX = 0;
            let startWidth = 0;
            let frame = 0;

            const onMouseMove = (e) => {
              if (frame) return;

              frame = requestAnimationFrame(() => {
                frame = 0;
                const width = Math.min(MAX_WIDTH, Math.max(MIN_WIDTH, startWidth + e.clientX - startX));
                root.style.setProperty("--aside-width", width + "px");
              });
            };

            const onMouseUp = () => {
              if (frame) {
                cancelAnimationFrame(frame);
                frame = 0;
              }
              resizeHandle.classList.remove("resizing");
              aside.classList.remove("resizing");
              main.classList.remove("resizing");
              document.body.style.userSelect = "";
              // 仅在拖拽期间监听，避免全局 mousemove 常驻
              document.removeEventListener("mousemove", onMouseMove);
              document.removeEventListener("mouseup", onMouseUp);
            };

            resizeHandle.addEventListener("mousedown", (e) => {
              startX = e.clientX;
              startWidth = parseFloat(getComputedStyle(root).getPropertyValue("--aside-width")) ||
                aside.getBoundingClientRect().width;
              resizeHandle.classList.add("resizing");
              aside.classList.add("resizing");
              main.classList.add("resizing");
              document.body.style.userSelect = "none";
              document.addEventListener("mousemove", onMouseMove);
              document.addEventListener("mouseup", onMouseUp);
            });
          }

          buildToc();
          initTocToggle();
          initAsideToggle();
          initAsideSwipe();
          initAsideResize();
          ```.text,
        )
      })
      html.body({
        html.div(class: ("container",), {
          html.aside({
            html.span(class: ("aside-title-large-screen",), "Table of Contents")
            html.span(class: ("aside-title-small-screen",), doc-title)
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
                // html.span(class: ("iconfont", "icon-menu3"))[]
              })
              html.span(class: ("header-middle",), doc-title)
              html.span(class: ("header-right",), {
                // html.a(class: ("iconfont-home",), {
                //   html.span(class: ("iconfont", "icon-home"))[]
                // })
                // html.a(class: ("iconfont-github",), {
                //   html.span(class: ("iconfont", "icon-github"))[]
                // })
                // html.a(class: ("iconfont-print",), {
                //   html.span(class: ("iconfont", "icon-print"))[]
                // })
                // html.a(class: ("iconfont-paintbrush",), {
                //   html.span(class: ("iconfont", "icon-paintbrush"))[]
                // })
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
    panic("bundle export is not supported by itemplate(version 0.7.0), please export the document to html instead")
  } else {
    body
  }
}

#let myutils-setup(doc) = {
  context if (target() == "html" or target() == "bundle") {
    html.elem(
      "style",
      ```css
      .svg-graph > svg, img {
        display: block;
        max-width: 95%;
        height: auto;
        margin: 0 auto;
      }

      @media screen and (max-width: 601px) {
        img {
          width: 95%;
          max-width: 600px;
        }
      }

      @media screen and (min-width: 602px) and (max-width: 1001px) {
        img {
          width: 80%;
          max-width: 600px;
        }
      }

      @media screen and (min-width: 1001px) {
        img {
          width: 70%;
          max-width: 600px;
        }
      }
      ```.text,
    )

    // show规则的作用域必须改为全局
  }

  show heading: set heading(numbering: none)

  show grid: it => if (target() == "html" or target() == "bundle") {
    html.elem("div", attrs: (class: "svg-graph"), html.frame(it))
  } else { it }

  show image: it => if (target() == "html" or target() == "bundle") {
    html.img(src: it.source)
  } else {
    it
  }

  doc
}
