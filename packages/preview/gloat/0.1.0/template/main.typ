#import "@preview/gloat:0.1.0": *

#show: cv.with(
  author: "Jacky Cao",
  address: "Chicago IL, US",
  contacts: (
    [#link("mailto:email@domain")[jcao\@uchicago.edu]],
    [#link("your-website-url")[jc.ao]],
    [#link("https://github.com/user")[gh/jcao]],
    [#link("https://www.linkedin.com/in/user/")[in/jcao]],
  ),
)

= Education

#edu(
  institution: "Harvard University",
  location: "Cambridge MA, US",
  gpa: "3.97",
  degrees: (
    [Ph.D. Physics],
  ),
  date: datetime(year: 2023, month: 4, day: 28),
)

#edu(
  institution: "Wellesley College",
  location: "Wellesley MA, US",
  gpa: "4.00",
  degrees: (
    [B.A. Psychology & Physics],
  ),
  date: datetime(year: 2017, month: 5, day: 14),
)

= Research Experience

#exp(
  role: "Postdoctoral Researcher",
  org: "University of Chicago, Kadanoff Center for Theoretical Physics - Lab of Léon Foucalt",
  location: "Chicago IL, US",
  start: datetime(year: 2023, month: 10, day: 11),
  end: "Present",
  details: [
    - Led and mentored a subgroup of 3 graduate students in quantum field theory.
    - Organized weekly meetings and curated papers for the Kadanoff Center journal club.
    - Developed an original research project to deconvolute the de Broglie waveforms of electrons.
  ],
)

#exp(
  role: "Research Assistant",
  org: "Harvard University, Department of Physics - Lab of Joseph Fourier Lab",
  location: "Cambridge MA, US",
  start: datetime(year: 2017, month: 10, day: 11),
  end: datetime(year: 2023, month: 5, day: 20),
  details: [
    - Developed a signal processing pipeline to analyze ECG data from thousands of patients in minutes.
    - Translated three signal processing tools from MATLAB to python, increasing processing speed tenfold.
    - Developed an image processing package for deconvoluting time-varying fluorescence microscopy signals.
  ],
)

#exp(
  role: "Research Intern",
  org: "Wellesley College, Department of Physics - Lab of John Muradeli",
  location: "Wellesley MA, US",
  start: datetime(year: 2014, month: 9, day: 15),
  end: datetime(year: 2017, month: 5, day: 4),
  details: [
    - Developed an implementation of the synchrosqueeze algorithm for gpu-accelerated signal processing.
    - Created a discrete signal processing pipeline in python to identify abrupt changes in audio.
    - Presented weekly progress updates at lab meetings.
  ],
)

= Awards

#award(
  date: datetime(year: 2023, month: 12, day: 5),
  name: "MPS-Ascend Postdoctoral Research Fellowship",
  from: "National Science Foundation",
)

#award(
  date: datetime(year: 2017, month: 3, day: 4),
  name: "NSF Graduate Research Fellowship Program",
  from: "National Science Foundation",
)

#award(
  date: datetime(year: 2015, month: 4, day: 4),
  name: "Campus Research Fellowship",
  from: "Wellesley College",
)

= Publications

#paper(
  authors: ([*Cao J*], [Foucalt L]),
  title: "Beyond the Quantum Manifold",
  journal: "Physics Letters B",
  published: datetime(year: 2025, month: 03, day: 17),
  vol: 862,
  pages: 139301,
)

#paper(
  authors: ([*Cao J*], [Fourier J]),
  title: "Waves all the way down: signal processing in 2025",
  journal: "Physics Letters B",
  vol: 858,
  pages: 138736,
  published: datetime(year: 2021, month: 6, day: 12),
)

#paper(
  authors: ([*Cao J*], [Smith I], [Ng V], [Muradeli J]),
  title: "A method for time-aware deconvolution of brainwaves",
  journal: "Signal Processing",
  published: datetime(year: 2017, month: 6, day: 3),
  vol: 212,
  pages: 109153,
)

#paper(
  authors: ([Karamazov I], [*Cao J*], [Muradeli J]),
  title: "I'm not coming up with more than three paper names",
  published: datetime(year: 2015, month: 7, day: 30),
)


