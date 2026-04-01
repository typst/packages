(function themes() {
  var html = document.querySelector('html');
  var themeToggleButton = document.getElementById('theme-toggle');
  var themePopup = document.getElementById('theme-list');
  var themeColorMetaTag = document.querySelector('meta[name="theme-color"]');

  function showThemes() {
    themePopup.style.display = 'block';
    themeToggleButton.setAttribute('aria-expanded', true);
    themePopup.querySelector('button#' + get_theme()).focus();
  }

  function updateThemeSelected() {
    themePopup.querySelectorAll('.theme-selected').forEach(function (el) {
      el.classList.remove('theme-selected');
    });
    themePopup.querySelector('button#' + get_theme()).classList.add('theme-selected');
    window.typstChangeTheme();
  }

  function hideThemes() {
    themePopup.style.display = 'none';
    themeToggleButton.setAttribute('aria-expanded', false);
    themeToggleButton.focus();
  }

  function get_theme() {
    var theme;
    try {
      theme = localStorage.getItem('shiroa-theme');
    } catch (e) {}
    if (theme === null || theme === undefined) {
      return default_theme;
    } else {
      return theme;
    }
  }

  function set_theme(theme, store = true) {
    setTimeout(function () {
      themeColorMetaTag.content = getComputedStyle(document.documentElement).backgroundColor;
    }, 1);

    var previousTheme = get_theme();

    if (store) {
      try {
        localStorage.setItem('shiroa-theme', theme);
      } catch (e) {}
    }

    html.classList.remove(previousTheme);
    html.classList.add(theme);
    updateThemeSelected();
  }

  // Set theme
  var theme = get_theme();
  set_theme(theme, false);

  themeToggleButton.addEventListener('click', function () {
    if (themePopup.style.display === 'block') {
      hideThemes();
    } else {
      showThemes();
    }
  });

  themePopup.addEventListener('click', function (e) {
    var theme;
    if (e.target.className === 'theme') {
      theme = e.target.id;
    } else if (e.target.parentElement.className === 'theme') {
      theme = e.target.parentElement.id;
    } else {
      return;
    }
    set_theme(theme);
  });

  themePopup.addEventListener('focusout', function (e) {
    // e.relatedTarget is null in Safari and Firefox on macOS (see workaround below)
    if (
      !!e.relatedTarget &&
      !themeToggleButton.contains(e.relatedTarget) &&
      !themePopup.contains(e.relatedTarget)
    ) {
      hideThemes();
    }
  });

  // Should not be needed, but it works around an issue on macOS & iOS: https://github.com/rust-lang/mdBook/issues/628
  document.addEventListener('click', function (e) {
    if (
      themePopup.style.display === 'block' &&
      !themeToggleButton.contains(e.target) &&
      !themePopup.contains(e.target)
    ) {
      hideThemes();
    }
  });

  document.addEventListener('keydown', function (e) {
    if (e.altKey || e.ctrlKey || e.metaKey || e.shiftKey) {
      return;
    }
    if (!themePopup.contains(e.target)) {
      return;
    }

    switch (e.key) {
      case 'Escape':
        e.preventDefault();
        hideThemes();
        break;
      case 'ArrowUp':
        e.preventDefault();
        var li = document.activeElement.parentElement;
        if (li && li.previousElementSibling) {
          li.previousElementSibling.querySelector('button').focus();
        }
        break;
      case 'ArrowDown':
        e.preventDefault();
        var li = document.activeElement.parentElement;
        if (li && li.nextElementSibling) {
          li.nextElementSibling.querySelector('button').focus();
        }
        break;
      case 'Home':
        e.preventDefault();
        themePopup.querySelector('li:first-child button').focus();
        break;
      case 'End':
        e.preventDefault();
        themePopup.querySelector('li:last-child button').focus();
        break;
    }
  });
})();

(function sidebar() {
  var html = document.querySelector('html');
  var sidebar = document.getElementById('sidebar');
  var sidebarLinks = document.querySelectorAll('#sidebar a');
  var sidebarToggleButton = document.getElementById('sidebar-toggle');
  var sidebarResizeHandle = document.getElementById('sidebar-resize-handle');
  var firstContact = null;

  sidebar.addEventListener('transitionend', () => {
    window.typstRerender(true);
  });

  function showSidebar() {
    html.classList.remove('sidebar-hidden');
    html.classList.add('sidebar-visible');
    Array.from(sidebarLinks).forEach(function (link) {
      link.setAttribute('tabIndex', 0);
    });
    sidebarToggleButton.setAttribute('aria-expanded', true);
    sidebar.setAttribute('aria-hidden', false);
    try {
      localStorage.setItem('shiroa-sidebar', 'visible');
    } catch (e) {}
  }

  var sidebarAnchorToggles = document.querySelectorAll('#sidebar a.toggle');

  function toggleSection(ev) {
    ev.currentTarget.parentElement.classList.toggle('expanded');
  }

  Array.from(sidebarAnchorToggles).forEach(function (el) {
    el.addEventListener('click', toggleSection);
  });

  function hideSidebar() {
    html.classList.remove('sidebar-visible');
    html.classList.add('sidebar-hidden');
    Array.from(sidebarLinks).forEach(function (link) {
      link.setAttribute('tabIndex', -1);
    });
    sidebarToggleButton.setAttribute('aria-expanded', false);
    sidebar.setAttribute('aria-hidden', true);
    try {
      localStorage.setItem('shiroa-sidebar', 'hidden');
    } catch (e) {}
  }

  // Toggle sidebar
  sidebarToggleButton.addEventListener('click', function sidebarToggle() {
    if (html.classList.contains('sidebar-hidden')) {
      var current_width = parseInt(
        document.documentElement.style.getPropertyValue('--sidebar-width'),
        10,
      );
      if (current_width < 150) {
        document.documentElement.style.setProperty('--sidebar-width', '150px');
      }
      showSidebar();
    } else if (html.classList.contains('sidebar-visible')) {
      hideSidebar();
    } else {
      if (getComputedStyle(sidebar)['transform'] === 'none') {
        hideSidebar();
      } else {
        showSidebar();
      }
    }
  });

  sidebarResizeHandle.addEventListener('mousedown', initResize, false);

  function initResize(e) {
    window.addEventListener('mousemove', resize, false);
    window.addEventListener('mouseup', stopResize, false);
    html.classList.add('sidebar-resizing');
  }
  function resize(e) {
    window.typstRerender(true);
    var pos = e.clientX - sidebar.offsetLeft;
    if (pos < 20) {
      hideSidebar();
    } else {
      if (html.classList.contains('sidebar-hidden')) {
        showSidebar();
      }
      pos = Math.min(pos, window.innerWidth - 100);
      document.documentElement.style.setProperty('--sidebar-width', pos + 'px');
    }
  }
  //on mouseup remove windows functions mousemove & mouseup
  function stopResize(e) {
    window.typstRerender(false);
    html.classList.remove('sidebar-resizing');
    window.removeEventListener('mousemove', resize, false);
    window.removeEventListener('mouseup', stopResize, false);
  }

  document.addEventListener(
    'touchstart',
    function (e) {
      firstContact = {
        x: e.touches[0].clientX,
        time: Date.now(),
      };
    },
    { passive: true },
  );

  document.addEventListener(
    'touchmove',
    function (e) {
      if (!firstContact) return;

      var curX = e.touches[0].clientX;
      var xDiff = curX - firstContact.x,
        tDiff = Date.now() - firstContact.time;

      if (tDiff < 250 && Math.abs(xDiff) >= 150) {
        if (xDiff >= 0 && firstContact.x < Math.min(document.body.clientWidth * 0.25, 300))
          showSidebar();
        else if (xDiff < 0 && curX < 300) hideSidebar();

        firstContact = null;
      }
    },
    { passive: true },
  );
})();
