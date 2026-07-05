#import "@preview/minimal-cv:0.1.0": *


#let secondary-theme = (
  accent-color: red,
  body-color: red,
)


// To learn about theming, see https://github.com/lelimacon/typst-minimal-cv
#show: cv.with(
  theme: (
    //font: "Roboto",
    //accent-color: purple,
    //main-accent-color: red,
    //main-body-color: green,
  ),
  title: "John Doe",
  subtitle: "Developer, Developer, Developer",
  aside: {

    section(
      theme: secondary-theme,
      "Contact",
      {
        entry(
          "Home",
          "Hong Kong, China",
          none,
        )
        entry(
          "Phone",
          link("https://wa.me/85212345678", "+852 1234 5678"),
          none,
        )
        entry(
          "Email",
          link("mailto:contact@me.com", "contact@me.com"),
          none,
        )
        entry(
          "LinkedIn",
          link("https://www.linkedin.com/in/john-doe", "in/john-doe"),
          none,
        )
      },
    )

    section(
      "Technology Stack",
      {
        entry(
          "Web",
          "ASP.NET + Blazor",
          [
            #progress-bar(100%)
          ],
        )
        entry(
          none,
          "Express + React",
          [
            #progress-bar(50%)
          ],
        )
        entry(
          "Desktop",
          "WPF",
          [
            #progress-bar(75%)
          ],
        )
        entry(
          "Native",
          "Xamarin, Flutter",
          [
            #progress-bar(50%)
          ],
        )
        entry(
          "DBMS",
          "MS SQL, PostgreSQL, MongoDB",
          [
            #progress-bar(75%)
          ],
        )
        entry(
          "Ops",
          "Scripting",
          [PowerShell, VBS/VBA, Python],
        )
        entry(
          none,
          "Hosting, CI/CD",
          [Terraform, Azure, DigitalOcean,\ GitHub Actions],
        )
        entry(
          "Other",
          "Gaming",
          [Unity, Godot],
        )
        entry(
          none,
          "Graphics",
          [Illustrator, Blender],
        )
      },
    )

    section(
      "Languages",
      {
        entry(
          right: [_Mother Ship_],
          "Fluent",
          "🇺🇸 English",
          none,
        )
        entry(
          right: [_Ich bin ein Berliner_],
          "Proficient",
          "🇩🇪 German",
          none,
        )
        entry(
          right: "恭喜發財",
          none,
          "🇨🇳 Mandarin",
          none,
        )
        entry(
          right: "いただきます",
          "Basic",
          "🇯🇵 Japanese",
          none,
        )
      },
    )

    section(
      "Extracurricular Activities",
      {
        entry(
          "Culture",
          none,
          [Traveling, photography,\ cinephile, theater],
        )
        entry(
          "Sport",
          none,
          [Hiking, bodybuilding, chess],
        )
      },
    )

  }
)


#section(
  "Professional Experience",
  {
    entry(
      right: [*\@Microsoft* – Cyberport, HK 🇭🇰],
      "2020 - now",
      "Software Engineer",
      [
        #par(lorem(24))
        #list(
          lorem(20),
          lorem(7),
          lorem(16),
          lorem(16),
        )
      ],
    )
    entry(
      theme: secondary-theme,
      right: [*\@Supersoft* -- Seattle, US 🇺🇸],
      "2018 - now",
      "Co-Founder, CTO",
      [
        #par(lorem(28))
        #par(lorem(16))
      ],
    )
    entry(
      right: [*\@Microsoft* -- Berlin, DE 🇩🇪],
      "2016 - 2020",
      "Software Engineer",
      [
        #par(lorem(12))
        #list(
          lorem(20),
          lorem(16),
          lorem(7),
        )
      ],
    )
    entry(
      right: [*\@Microsoft* -- Redmond, US 🇺🇸],
      "2015 - 2016",
      "CS Intern",
      [
        #par(lorem(12))
      ],
    )
    entry(
      right: [*\@MIT* -- Cambridge, US 🇺🇸],
      "2013, 2 yrs",
      "Teaching Assistant",
      [ #lorem(24) ],
    )
  },
)

#section(
  "Educational Background",
  {
    entry(
      theme: secondary-theme,
      right: [*\@SNU 서울대학교* -- Seoul, KR 🇰🇷],
      "2012, 6 mths",
      "Univ. Exchange",
      [ #lorem(16) ],
    )
    entry(
      right: [*\@MIT* -- Cambridge, US 🇺🇸],
      "2010 - 2015",
      "Master of Engineering",
      [ #lorem(24) ],
    )
  },
)
