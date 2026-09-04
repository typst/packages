"use strict";

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
      heading.textContent = heading.getAttribute("data-numbering") + ". " + heading.getAttribute("data-original-text");
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
