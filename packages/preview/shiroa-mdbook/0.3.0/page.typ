
#import "mod.typ": *
#import "icons.typ": builtin-icon
#import "@preview/shiroa:0.3.0": x-current

// ---

#div.with(id: "body-container")({
  // Provide site root to javascript
  inline-assets(
    replace-raw(
      vars: (
        path_to_root: json.encode(x-url-base),
        preferred_dark_theme: "ayu",
        default_theme: "light",
      ),
      ```js
      var path_to_root = {{ path_to_root }};
      window.typstPathToRoot = path_to_root;
      var default_theme = window.matchMedia("(prefers-color-scheme: dark)").matches ? "{{ preferred_dark_theme }}" : "{{ default_theme }}";
      ```,
    ),
  )

  // Work around some values being stored in localStorage wrapped in quotes
  inline-assets(
    ```js
    // reserved util next major release
    try {
        localStorage.removeItem('mdbook-theme');
        localStorage.removeItem('mdbook-sidebar');
    } catch (e) { }
    try {
        var theme = localStorage.getItem('shiroa-theme');
        var sidebar = localStorage.getItem('shiroa-sidebar');

        if (theme.startsWith('"') && theme.endsWith('"')) {
            localStorage.setItem('shiroa-theme', theme.slice(1, theme.length - 1));
        }

        if (sidebar.startsWith('"') && sidebar.endsWith('"')) {
            localStorage.setItem('shiroa-sidebar', sidebar.slice(1, sidebar.length - 1));
        }
    } catch (e) { }
    ```,
  )

  //  Set the theme before any content is loaded, prevents flash
  inline-assets(
    replace-raw(
      vars: (
        default_theme: "light",
      ),
      ```js
      window.getTypstTheme = function getTypstTheme() {
          var _theme;
          try { _theme = localStorage.getItem('shiroa-theme'); } catch (e) { }
          if (_theme === null || _theme === undefined) { _theme = default_theme; }
          window.typstBookTheme = _theme;
          return _theme;
      }
      window.isTypstLightTheme = function isLightTheme(theme) {
          return theme === 'light' || theme === 'rust';
      }
      var theme = getTypstTheme();
      // todo: consistent theme between html and typst
      var html = document.querySelector('html');
      html.classList.remove('no-js')
      html.classList.remove('{{ default_theme }}')
      html.classList.add(theme);
      html.classList.add('js');
      ```,
    ),
  )

  // Hide / unhide sidebar before it is displayed
  inline-assets(
    ```js
    var html = document.querySelector('html');
    var sidebar = null;
    if (document.body.clientWidth >= 800) {
        try { sidebar = localStorage.getItem('shiroa-sidebar'); } catch (e) { }
        sidebar = sidebar || 'visible';
    } else {
        sidebar = 'hidden';
    }
    html.classList.remove('sidebar-visible');
    html.classList.add("sidebar-" + sidebar);
    ```,
  )
  nav.with(
    id: "sidebar",
    class: "sidebar",
    aria-label: "Table of contents",
  )({
    div.with(class: "sidebar-scrollbox")({
      // {{#toc}}{{/toc}}
      include "page-sidebar.typ"
    })
    div(id: "sidebar-resize-handle", class: "sidebar-resize-handle")[]
  })

  // Track and set sidebar scroll position
  inline-assets(
    ```js
    var sidebarScrollbox = document.querySelector('#sidebar .sidebar-scrollbox');
    sidebarScrollbox.addEventListener('click', function (e) {
        if (e.target.tagName === 'A') {
            sessionStorage.setItem('sidebar-scroll', sidebarScrollbox.scrollTop);
        }
    }, { passive: true });
    var sidebarScrollTop = sessionStorage.getItem('sidebar-scroll');
    sessionStorage.removeItem('sidebar-scroll');
    if (sidebarScrollTop) {
        // preserve sidebar scroll position when navigating via links within sidebar
        sidebarScrollbox.scrollTop = sidebarScrollTop;
    } else {
        // scroll sidebar to current active section when navigating via "next/previous chapter" buttons
        var activeSection = document.querySelector('#sidebar .active');
        if (activeSection) {
            activeSection.scrollIntoView({ block: 'center' });
        }
    }
    ```,
  )

  div.with(id: "page-wrapper", class: "page-wrapper")({
    div.with(class: "page")({
      // include "page-header.typ"
      div(id: "menu-bar-hover-placeholder")[]
      div.with(id: "menu-bar", class: "menu-bar sticky")({
        div.with(class: "left-buttons")({
          //     <button id="sidebar-toggle" class="icon-button" type="button" title="Toggle Table of Contents"
          //         aria-label="Toggle Table of Contents" aria-controls="sidebar">
          //         <i class="fa fa-bars"></i>
          //     </button>

          button(
            id: "sidebar-toggle",
            class: "icon-button",
            type: "button",
            title: "Toggle Table of Contents",
            aria-label: "Toggle Table of Contents",
            aria-controls: "sidebar",
            {
              builtin-icon("bars", class: "fa")
            },
          )
          button(
            id: "theme-toggle",
            class: "icon-button",
            type: "button",
            title: "Change theme",
            aria-label: "Change theme",
            aria-haspopup: "true",
            aria-expanded: "false",
            aria-controls: "theme-list",
            {
              builtin-icon("paintbrush", class: "fa")
            },
          )

          ul.with(id: "theme-list", class: "theme-popup", role: "menu", aria-label: "Themes")({
            li.with(role: "none")({
              button(role: "menuitem", class: "theme", id: "light", "Light")
            })
            li.with(role: "none")({
              button(role: "menuitem", class: "theme", id: "rust", "Rust")
            })
            li.with(role: "none")({
              button(role: "menuitem", class: "theme", id: "coal", "Coal")
            })
            li.with(role: "none")({
              button(role: "menuitem", class: "theme", id: "navy", "Navy")
            })
            li.with(role: "none")({
              button(role: "menuitem", class: "theme", id: "ayu", "Ayu")
            })
          })
          if search-enabled {
            button(
              id: "search-toggle",
              class: "icon-button",
              type: "button",
              title: "Search. (Shortkey: s)",
              aria-label: "Toggle Searchbar",
              aria-expanded: "false",
              aria-keyshortcuts: "S",
              aria-controls: "searchbar",
              {
                builtin-icon("search", class: "fa")
              },
            )
          }
        })

        virt-slot("main-title")
        virt-slot("sa:right-buttons")
      })

      // xxxxxxxxxxxx

      if search-enabled {
        div.with(id: "search-wrapper", class: "hidden")({
          form.with(id: "searchbar-outer", class: "searchbar-outer")({
            input(
              type: "search",
              id: "searchbar",
              name: "searchbar",
              placeholder: "Search this book ...",
              aria-controls: "searchresults-outer",
              aria-describedby: "searchresults-header",
            )[]
          })
          div.with(id: "searchresults-outer", class: "searchresults-outer hidden")({
            div(id: "searchresults-header", class: "searchresults-header")[]
            ul(id: "searchresults")[]
          })
        })
      }
      /// Apply ARIA attributes after the sidebar and the sidebar toggle button are added to the DOM
      inline-assets(
        ```js
        document.getElementById('sidebar-toggle').setAttribute('aria-expanded', sidebar === 'visible');
        document.getElementById('sidebar').setAttribute('aria-hidden', sidebar !== 'visible');
        Array.from(document.querySelectorAll('#sidebar a')).forEach(function (link) {
          link.setAttribute('tabIndex', sidebar === 'visible' ? 0 : -1);
        });
        ```,
      )


      div.with(id: "content", class: "content")({
        main({
          // virt-slot("main-title")
          virt-slot("main-content")
        })

        // <nav class="nav-wrapper" aria-label="Page navigation">
        //     <!-- Mobile navigation buttons -->
        //     {{!-- {{#previous}}
        //     <a rel="prev" href="{{ path_to_root }}{{link}}" class="mobile-nav-chapters previous"
        //         title="Previous chapter" aria-label="Previous chapter" aria-keyshortcuts="Left">
        //         <i class="fa fa-angle-left"></i>
        //     </a>
        //     {{/previous}}

        //     {{#next}}
        //     <a rel="next" href="{{ path_to_root }}{{link}}" class="mobile-nav-chapters next"
        //         title="Next chapter" aria-label="Next chapter" aria-keyshortcuts="Right">
        //         <i class="fa fa-angle-right"></i>
        //     </a>
        //     {{/next}} --}}

        //     <div style="clear: both"></div>
        // </nav>
        // include "page-navigation.typ"
      })
    })

    //         <nav class="nav-wide-wrapper" aria-label="Page navigation">
    //             {{!-- {{#previous}}
    //             <a rel="prev" href="{{ path_to_root }}{{link}}" class="nav-chapters previous" title="Previous chapter"
    // aria-label="Previous chapter" aria-keyshortcuts="Left">
    // <i class="fa fa-angle-left"></i>
    //             </a>
    //             {{/previous}}

    //             {{#next}}
    //             <a rel="next" href="{{ path_to_root }}{{link}}" class="nav-chapters next" title="Next chapter"
    // aria-label="Next chapter" aria-keyshortcuts="Right">
    // <i class="fa fa-angle-right"></i>
    //             </a>
    //             {{/next}} --}}
    //         </nav>
  })

  if search-js {
    shiroa-asset-file("elasticlunr.min.js")
    shiroa-asset-file("mark.min.js")
    shiroa-asset-file("searcher.js")
  }

  shiroa-asset-file("svg_utils.js")
  inline-assets(raw(lang: "js", read("index.js")))
})
