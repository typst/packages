# polycv field reference

```yaml
# polycv CV field reference - generated from the schema (make schema).
# <type> shows the value type. Fields are optional unless the comment
# says 'required'. For a filled example, see cv.yml.

meta:                                         # Layout/config block; consumed by the template, not part of the CV data.
  photo: <string>                             # Path to the profile photo, relative to the .typ file.
  photo-size: <integer >= 0>                  # Diameter of the circular photo as a percent of the sidebar width.
  locale: <"en" | "fr">                       # Language for section titles and month names.
  paper: <"a4" | "us-letter">                 # Page paper size (default "a4").
  hyphenate: <bool>                           # Hyphenate justified text (default true; false avoids mid-word breaks).
  scale: <number>                             # Scale text and spacing (default 1.0); smaller values shrink fonts and gaps within fixed margins, fitting more content per line and per page.
  layout: <"basic" | "ats-split" | "header-band">  # Header/column layout: "basic" (simple header), "ats-split" (two-column ATS-friendly header) or "header-band" (full-width band, photo on its left).
  summary-in-header: <bool>                   # Render the summary inside the header (any layout) instead of as a main-column section.
  contact-in-header: <bool>                   # Render the contact line in the header area (any layout) instead of the sidebar.
  entry-inline-meta: <bool>                   # Company + location/dates on the title line, position below.
  keywords-lines: <integer >= 0>              # Number of right-aligned lines for keyword badges (0 = one per line).
  sidebar-sections: <[string]>                # Ordered sidebar section keys (a built-in SectionName or a text-block key).
  main-sections: <[string]>                   # Ordered main-column section keys (a built-in SectionName or a block key).
  section-titles: <object>                    # Override section display titles, keyed by section name.
  section-icons: <object>                     # Override section FontAwesome icons, keyed by section name.
  skill-order: <[string]>                     # Which skill groups to show, in order, by their key in cv.skills. Omit a key to hide that group. If unset, all groups render in their data order.
  show-timeline: <bool>                       # Show the dots + vertical line on experience/education entries.

cv:                                           # CV data.
  name: <string>                              # Full name, shown large in the header.
  headline: <string>                          # Tagline under the name.
  location: <string>                          # Location line (city, country).
  keywords: <[string]>                        # Tag badges shown in the header.
  email: <string | [string]>                  # Email address; a single string or a list of lines.
  phone: <string | [string]>                  # Phone number; a single string or a list of lines.
  address: <string | [string]>                # Postal address; a single string or a list of lines.
  summary: <string>                           # Summary / profile paragraph.
  motivation: <string>                        # Motivation paragraph (cover-letter style intro).
  values: <[string]>                          # Personal values, one bullet each.
  hobbies: <[string]>                         # Hobbies / interests, one bullet each.
  references: <string | [string]>             # References text, or a list of bullets.
  profiles:                                   # Social profiles (network + username).
    - network: <string>                       # required - Network name; must match a key in the template's profiles-config (e.g. "LinkedIn", "GitHub").
      username: <string>                      # required - Handle appended to the network's URL base (e.g. "janedoe").
  skills: <{key: SkillGroup}>                 # Skill groups, keyed by a stable name (used by meta.skill-order). Add any key you like; the key is the icon-independent identifier, the display heading comes from each group's `title` (default: the key).
  text-blocks: <{key: TextBlock}>             # Free-text sidebar/main blocks, keyed by name; place a block by its key in sidebar-sections / main-sections.
  experience:                                 # Professional experience entries.
    - name: <string>                          # Primary title (award/course name). Alias of company for list sections.
      company: <string>                       # Organisation or employer (experience). Alias: degree for education.
      position: <string>                      # Job title or role, shown after the company.
      summary: <string>                       # Short subtitle under the title. Alias: institution for education.
      location: <string>                      # Place (city, country) shown on the right.
      start_date: <string | integer | null>   # Start date, "YYYY-MM" or "YYYY".
      end_date: <string | integer | "present" | null>  # End date, "YYYY-MM", "YYYY" or "present".
      date: <string | integer | null>         # Single date, alternative to start_date/end_date (awards, courses).
      highlights: <[string]>                  # Bullet points; supports *bold* and _italic_ inline markup.
  education:                                  # Education entries.
    - name: <string>                          # Primary title (award/course name). Alias of company for list sections.
      company: <string>                       # Organisation or employer (experience). Alias: degree for education.
      position: <string>                      # Job title or role, shown after the company.
      summary: <string>                       # Short subtitle under the title. Alias: institution for education.
      location: <string>                      # Place (city, country) shown on the right.
      start_date: <string | integer | null>   # Start date, "YYYY-MM" or "YYYY".
      end_date: <string | integer | "present" | null>  # End date, "YYYY-MM", "YYYY" or "present".
      date: <string | integer | null>         # Single date, alternative to start_date/end_date (awards, courses).
      highlights: <[string]>                  # Bullet points; supports *bold* and _italic_ inline markup.
  awards:                                     # Honours and awards.
    - name: <string>                          # Primary title (award/course name). Alias of company for list sections.
      company: <string>                       # Organisation or employer (experience). Alias: degree for education.
      position: <string>                      # Job title or role, shown after the company.
      summary: <string>                       # Short subtitle under the title. Alias: institution for education.
      location: <string>                      # Place (city, country) shown on the right.
      start_date: <string | integer | null>   # Start date, "YYYY-MM" or "YYYY".
      end_date: <string | integer | "present" | null>  # End date, "YYYY-MM", "YYYY" or "present".
      date: <string | integer | null>         # Single date, alternative to start_date/end_date (awards, courses).
      highlights: <[string]>                  # Bullet points; supports *bold* and _italic_ inline markup.
  courses:                                    # Courses and certifications.
    - name: <string>                          # Primary title (award/course name). Alias of company for list sections.
      company: <string>                       # Organisation or employer (experience). Alias: degree for education.
      position: <string>                      # Job title or role, shown after the company.
      summary: <string>                       # Short subtitle under the title. Alias: institution for education.
      location: <string>                      # Place (city, country) shown on the right.
      start_date: <string | integer | null>   # Start date, "YYYY-MM" or "YYYY".
      end_date: <string | integer | "present" | null>  # End date, "YYYY-MM", "YYYY" or "present".
      date: <string | integer | null>         # Single date, alternative to start_date/end_date (awards, courses).
      highlights: <[string]>                  # Bullet points; supports *bold* and _italic_ inline markup.
  publications:                               # Publications.
    - title: <string>                         # required - Publication title.
      authors: <[string]>                     # List of author names.
      summary: <string>                       # Short description or venue note.
      doi: <string>                           # Digital Object Identifier; rendered as a doi.org link.
      url: <string>                           # Direct URL to the publication.
      journal: <string>                       # Journal or conference name.
      date: <string | integer | null>         # Publication date.
  volunteering:                               # Volunteering and community involvement entries.
    - name: <string>                          # Primary title (award/course name). Alias of company for list sections.
      company: <string>                       # Organisation or employer (experience). Alias: degree for education.
      position: <string>                      # Job title or role, shown after the company.
      summary: <string>                       # Short subtitle under the title. Alias: institution for education.
      location: <string>                      # Place (city, country) shown on the right.
      start_date: <string | integer | null>   # Start date, "YYYY-MM" or "YYYY".
      end_date: <string | integer | "present" | null>  # End date, "YYYY-MM", "YYYY" or "present".
      date: <string | integer | null>         # Single date, alternative to start_date/end_date (awards, courses).
      highlights: <[string]>                  # Bullet points; supports *bold* and _italic_ inline markup.
```
