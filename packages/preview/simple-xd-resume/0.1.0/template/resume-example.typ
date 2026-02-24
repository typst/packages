#import "@preview/simple-xd-resume:0.1.0": make-resume

#show: make-resume.with(
  font: "Source Sans 3",
  margin: 1in,
  firstname: "Albert",
  lastname: "Einstein",
  headlines: (
    (name: "Theoretical Physicist", linkto: "ias"),
    (name: "Patent Clerk", linkto: "patent"),
  ),
  email: "albert.einstein@example.com",
  phone-number: "+41 31 123 4567",
  linkedin: (username: "alberteinstein"),
  github: (username: "alberteinstein"),
  homepage: (url: "https://www.einstein-physics.org", display: "einstein-physics.org"),
  telegram: (username: "alberteinstein"),
  experiences: (
    (
      organization: "Institute for Advanced Study",
      startdate: "Oct 1933",
      enddate: "Apr 1955",
      title: "Professor of Theoretical Physics",
      responsibilities: (
        "Conducted research on unified field theory attempting to unify gravity and electromagnetism.",
        "Collaborated with colleagues on foundations of quantum mechanics and statistical physics.",
        "Mentored numerous doctoral students and postdoctoral researchers.",
        "Contributed to public discourse on science, pacifism, and civil liberties.",
      ),
      label: "ias",
    ),
    (
      organization: "University of Berlin",
      startdate: "Apr 1914",
      enddate: "Mar 1933",
      title: "Professor of Physics & Director, Kaiser Wilhelm Institute",
      responsibilities: (
        "Published the General Theory of Relativity (1915), revolutionizing understanding of gravity.",
        "Predicted gravitational lensing, later confirmed during the 1919 solar eclipse.",
        "Contributed to quantum theory including the Einstein-Podolsky-Rosen paradox.",
        "Directed theoretical physics research at Kaiser Wilhelm Institute.",
      ),
      label: "berlin",
    ),
    (
      organization: "ETH Zürich",
      startdate: "Oct 1912",
      enddate: "Mar 1914",
      title: "Professor of Theoretical Physics",
      responsibilities: (
        "Taught advanced courses in theoretical physics and thermodynamics.",
        "Continued development of general relativity with Marcel Grossmann.",
        "Published papers on the foundation of general relativity.",
      ),
      label: "eth",
    ),
    (
      organization: "Swiss Patent Office",
      startdate: "Jun 1902",
      enddate: "Oct 1909",
      title: "Technical Expert (Patent Clerk)",
      responsibilities: (
        "Evaluated patent applications for electromagnetic devices.",
        "Published four groundbreaking papers in 1905 (Annus Mirabilis): photoelectric effect, Brownian motion, special relativity, and mass-energy equivalence (E=mc²).",
        "Completed doctoral dissertation on molecular dimensions.",
      ),
      label: "patent",
    ),
  ),
  educations: (
    (
      organization: "University of Zurich",
      startdate: "Jan 1905",
      enddate: "Jan 1905",
      title: "Doctor of Philosophy in Physics",
      responsibilities: (
        "Dissertation: A New Determination of Molecular Dimensions.",
        "Advisor: Alfred Kleiner.",
      ),
      label: "phd",
    ),
    (
      organization: "ETH Zürich (Swiss Federal Polytechnic)",
      startdate: "Oct 1896",
      enddate: "Jul 1900",
      title: "Diploma in Physics and Mathematics",
      responsibilities: (
        "Studied under Heinrich Weber and Hermann Minkowski.",
        "Graduated with a teaching diploma in physics and mathematics.",
        "Met lifelong collaborator Marcel Grossmann.",
      ),
      label: "ethstudent",
    ),
  ),
  skills: (
    (
      title: "Theoretical Physics",
      items: (
        "Special Relativity",
        "General Relativity",
        "Quantum Mechanics",
        "Statistical Mechanics",
        "Unified Field Theory",
      ),
    ),
    (
      title: "Mathematics",
      items: ("Tensor Calculus", "Differential Geometry", "Riemannian Geometry", "Partial Differential Equations"),
    ),
    (
      title: "Research Methods",
      items: ("Thought Experiments", "Mathematical Modeling", "Scientific Publication", "Peer Collaboration"),
    ),
    (
      title: "Languages",
      items: ("German", "English", "French", "Italian"),
    ),
  ),
)
