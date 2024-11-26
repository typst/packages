#import "@preview/silver-dev-cv:1.0.1": *

#show: cv.with(
  font-type: "PT Serif",
  continue-header: "false",
  name: "Victor Vigon",
  address: "Buenos Aires, Argentina",
  lastupdated: "true",
  pagecount: "true",
  date: "2024-07-03",
  contacts: (
    (text: "LinkedIn", link: "https://www.example.com"),
    (text: "Github", link: "https://www.github.com"),
    (text: "victor.vigon@example.com", link: "mailto:123@example.com"),
  ),
)


// about
#section[About Me]
#descript[I'm a product-minded backend engineer with deep expertise in Fintech and operations and team leadership. I excel in high-growth high-expectations environments and handle pre and post-product market fit software products.]

#sectionsep
//Experience
#section("Experience")
#job(
  position: "Back End Developer",
  institution: [Nutbank],
  location: "Argentina",
  date: "2020-2024",
  description: [
    - Led a team of four engineers to build a 0-1 product feature that helped users onboard on our application without needing to deposit funds. This involved working with payment railways, onboarding product testing, and owning the entire product pipeline.

    - Designed and developed a new microservices architecture that helped scale our backend services from a 100QPS / 1% failure rate service to a 1000QPS / 0.01% failure rate. This involved infrastructure work as well as hands-on internal libraries design.

    - Worked alongside the product team to improve the onboarding experience at the company, increasing our signup rate by 15% with a downstream impact of 1.5MM/yr revenue.
  ],
)

#job(
  position: "Back End Developer",
  institution: [Mercat Libre],
  location: "Argentina",
  date: "2018-2020",
  description: [
    - Worked in the MercatPago area in a multidisciplinary team with UX Writers and designers, project and product management and technical leadership in an Agile team organization. Shipped features that impacted more than 1 Million DAU.

    - We developed product features for financial applications. Responsibilities include writing unit tests, testing applications, code reviewing, collaborating with product to refine features. The products and pipelines worked managed over 5 Million USD daily volume.
  ],
)

#section("Skills")
#oneline-title-item(
  title: "Skills",
  content: [Golang, Python, Java, SQL, JavaScript, React, AWS],
)

#sectionsep
#section("Projects")
#project(
    title: [MercadoCat.com],
    date: [2019],
    description: [Built an online platform to connect rescue shelters with pet-adopters. More than 100 pets adopted through MercadoCat]
)


#sectionsep
#section("Education")
#education(
  institution: [University of Buenos Aires],
  major: [Software Engineering],
  date: "2015-2018",
  location: "Argentina",
)
