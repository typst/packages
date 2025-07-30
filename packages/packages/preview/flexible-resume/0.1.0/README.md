# Flexible resume template

A Typst resume template with priority-based content filtering. Create single-page resumes or multi-page CVs from the same source.

Requires [Typst](https://typst.app/docs/tutorial/installation/).

## Features

- Priority-based filtering for different levels of detail
- Adaptive layouts based on target page count
- Profile image support with proper alignment
- Programming language highlighting in monospace
- Smart date and list formatting

## Usage

```typst
#import "@preview/flexible-resume:0.1.0": *

#show: resume.with(
  name: "Your Name",
  email: "your.email@example.com", 
  website: "your-website.com",
  phone: "+1 234 567 8900",
  target-pages: 2,
)

#section("Experience")[
  #experience(
    organization: "Company Name",
    industry: "Industry",
    location: "City, Country",
    title: "Your Title", 
    start-date: "Jan. 2020",
    end-date: "Dec. 2023",
    items: (
      pitem(
        title: "Achievement",
        description: "What you accomplished",
        priority: 1,
        languages: ("Python", "Rust"),
      ),
    ),
  )
]
```

## Functions

Main template:
```typst
#resume(
  name: "", email: "", website: "", phone: "",
  profile-image: none, target-pages: 2, font: "Fira Sans",
  body,
)
```

Content functions:
```typst
#section(title, priority: 1, body)
#experience(organization: "", industry: "", location: "", title: "", 
           start-date: "", end-date: none, priority: 1, items: ())
#education(organization: "", location: "", degree: "", 
          start-date: "", end-date: none, priority: 1)  
#project(title: "", organization: "", start-date: "", 
        end-date: none, priority: 2, items: ())
#skill(category, description, priority: 2)
#pitem(title: "", description: "", priority: 2, languages: ())
```

## Priority system

- `target-pages: 1` - Shows only priority 1 items
- `target-pages: 2` - Shows priority 1-2 items
- Priority 1: Essential items
- Priority 2+: Additional detail

Programming languages in `pitem()` appear in monospace:
```typst
pitem(languages: ("Python", "Rust"))
```

## Example

```typst
#import "@preview/flexible-resume:0.1.0": *

#show: resume.with(
  name: "Jane Doe", email: "jane@example.com",
  website: "janedoe.dev", phone: "+1 555-0123",
  profile-image: "profile.jpg", target-pages: 2,
)

#section("Experience")[
  #experience(
    organization: "Tech Corp", industry: "Software",
    location: "San Francisco, CA", title: "Senior Developer",
    start-date: "2022", priority: 1,
    items: (
      pitem(
        title: "Full-stack development",
        description: "Led development of customer portal",
        priority: 1, languages: ("React", "Node.js"),
      ),
    ),
  )
]
```

## License

MIT