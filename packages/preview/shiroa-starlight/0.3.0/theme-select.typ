
#import "mod.typ": *
#import "icons.typ": builtin-icon

#let links = (
  (id: "dark", label: "Dark Theme", icon: "moon"),
  (id: "light", label: "Light Theme", icon: "sun"),
)

// ---

#for (id: id, label: theme-label, icon: icon) in links {
  button.with(id: "theme-" + id, class: "sl-flex theme-button")({
    span(class: "sr-only", theme-label)
    if type(icon) == str { builtin-icon(icon) } else { icon }
  })
}

#inline-assets({
  ```js

  // type Theme = 'auto' | 'dark' | 'light';

  /** Key in `localStorage` to store color theme preference at. */
  const storageKey = 'starlight-theme';

  /** Get a typesafe theme string from any JS value (unknown values are coerced to `'auto'`). */
  const parseTheme = (theme) => theme === 'dark' || theme === 'light' ? theme : 'auto';

  /** Load the user’s preference from `localStorage`. */
  const loadTheme = () =>
  	parseTheme(typeof localStorage !== 'undefined' && localStorage.getItem(storageKey));

  /** Store the user’s preference in `localStorage`. */
  function storeTheme(theme) {
  	if (typeof localStorage !== 'undefined') {
  		localStorage.setItem(storageKey, theme === 'light' || theme === 'dark' ? theme : '');
  	}
  }

  /** Get the preferred system color scheme. */
  const getPreferredColorScheme = () =>
  	matchMedia('(prefers-color-scheme: light)').matches ? 'light' : 'dark';

  /** Update select menu UI, document theme, and local storage state. */
  function onThemeChange(theme) {
  	document.documentElement.dataset.themeActive = theme;
  	document.documentElement.dataset.theme = theme === 'auto' ? getPreferredColorScheme() : theme;
  	storeTheme(theme);
  }

  // React to changes in system color scheme.
  matchMedia(`(prefers-color-scheme: light)`).addEventListener('change', () => {
  	if (loadTheme() === 'auto') onThemeChange('auto');
  });

  // customElements.define('starlight-theme-select', StarlightThemeSelect);

  const lightButton = document.getElementById('theme-light');
  const darkButton = document.getElementById('theme-dark');
  const themes = ['light', 'dark'];
  const buttons = themes.map(theme => document.getElementById('theme-' + theme));

  buttons.forEach((button, idx) => {
    button.addEventListener('click', () => {
      const newTheme = themes[idx];
      const isActive = button.classList.contains('active');
      buttons.forEach((_, i) => {
        if (i === idx) {
          button.classList.toggle('active');
        } else {
          buttons[i].classList.remove('active');
        }
      });
      onThemeChange(isActive ? 'auto' : newTheme);
    });
  });

  onThemeChange(loadTheme());
  // this.querySelector('select')?.addEventListener('change', (e) => {
  //   if (e.currentTarget instanceof HTMLSelectElement) {
  //     onThemeChange(parseTheme(e.currentTarget.value));
  //   }
  // });



  ```
})

#add-styles.with(cond: links.len() > 0)(
  ```css
  @layer starlight.core {
    .theme-button {
      background: none;
      border: none;
      padding: 0.5em;
      margin: -0.2em;
    }
    :root[data-theme-active='light'] #theme-light, :root[data-theme-active='dark'] #theme-dark {
      color: var(--sl-color-text-accent);
    }
    .theme-button:hover {
      opacity: 0.66;
    }
  }
  ```,
)
