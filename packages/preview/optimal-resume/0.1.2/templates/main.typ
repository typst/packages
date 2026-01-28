#import "@preview/optimal-resume:0.1.2": *

#show: project

#cv-header(
  name: "Linus Torvalds",
  email: "torvalds@linux-foundation.org",
  phone: "+1 234 567-8910",
  linkedin: "linustorvalds",
  github: "torvalds",
)

#cv-section("Summary")
Software Engineer and Architect of the world's most critical open-source infrastructure. Creator of the *Linux kernel* and the *Git* version control system. Proven track record in managing *massive-scale distributed collaboration*, low-level systems programming, and performance optimization. Expert in *C* and advocate for pragmatic software design.

#cv-section("Experience")

#cv-work(
  company: "Linux Foundation",
  title: "Fellow & Chief Architect",
  location: "Portland, OR",
  start: "2003",
  end: "Present",
  points: (
    [Direct the development and release cycle of the *Linux Kernel*, managing over 30 million lines of code],
    [Coordinate contributions from *thousands of global developers* and tech giants (Intel, Google, AMD)],
    [Enforce strict coding standards and performance requirements to maintain *99.99% system stability*],
    [Design architectural solutions for memory management, process scheduling, and hardware abstraction],
  ),
)

#cv-work(
  company: "Transmeta Corporation",
  title: "Principal Software Engineer",
  location: "Santa Clara, CA",
  start: "1997",
  end: "2003",
  points: (
    [Developed *Code Morphing* software, a dynamic binary translation layer for x86 instruction sets],
    [Optimized VLIW processor performance through low-level firmware and compiler interaction],
    [Contributed to *power-efficient CPU design* for mobile computing devices],
  ),
)

#cv-section("Projects")

#cv-project(
  name: "Linux Kernel",
  tech: "C, Assembly, Makefile",
  github: "torvalds/linux",
  url: "https://kernel.org",
  start: "1991",
  end: "Present",
  points: (
    [Created a *POSIX-compliant monolithic kernel* now powering 100% of the world's supercomputers],
    [Implemented high-performance subsystems for networking, filesystems (ext4, Btrfs), and security],
    [Revolutionized the tech industry by establishing the *GPL-based open-source model*],
  ),
)

#cv-project(
  name: "Git (Version Control System)",
  tech: "C, Shell, Perl",
  github: "git/git",
  url: "https://git-scm.com",
  start: "2005",
  end: "2005",
  points: (
    [Designed a *distributed VCS* to replace BitKeeper, prioritizing speed and data integrity],
    [Engineered a unique *content-addressable storage* architecture using SHA-1 hashing],
    [Adopted by over *90% of software engineers* worldwide as the industry standard],
  ),
)

#cv-project(
  name: "Subsurface",
  tech: "C++, Qt",
  github: "subsurface/subsurface",
  url: "https://subsurface-divelog.org",
  start: "2011",
  end: "Present",
  points: (
    [Created an open-source dive log application to track *SCUBA diving data* and decompressions],
    [Implemented cross-platform support for multiple dive computer hardwares via *libdivecomputer*],
  ),
)

#cv-section("Technical Skills")
- *Systems Programming:* Advanced C, x86/ARM Assembly, Kernel Internals, Interrupt Handling
- *Software Architecture:* Distributed Systems, Monolithic vs Microkernel Design, Version Control Logic
- *Tools & DevOps:* Git, Make, GCC/Clang, Shell Scripting (Bash), QEMU/KVM
- *Philosophy:* "Talk is cheap. *Show me the code.*"

#cv-section("Awards & Honors")
- *Millennium Technology Prize (2012):* For the creation of Linux.
- *IEEE Computer Pioneer Award (2014):* For pioneering open-source development.
- *Internet Hall of Fame (2012):* For global impact on the internet's infrastructure.

#cv-section("Education")
#cv-edu(
  school: "University of Helsinki",
  degree: "M.S. in Computer Science",
  start: "1988",
  end: "1996",
  relevant: [Thesis: *Linux: A Portable Operating System*],
)
