#import "@preview/grotesk-cv:0.1.0": *
#import "@preview/fontawesome:0.2.1": *

#show: layout

#let use-photo = true

#create-header(use-photo: use-photo)

#if not use-photo {
  v(30pt)
}

#set text(size: 11pt)

#datetime.today().display()

#recipient-entry(
  name: [Jane Doe],
  title: [Hiring Manager],
  company: [Cyberdyne Systems],
  address: [ 123 Skynet Lane, Los Angeles, CA 90001, USA],
)

#v(20pt)

#cv-section("Senior AI Engineer in search of a news challenges")

#v(10pt)

Dear Hiring Manager,

I am writing to express my interest in the Senior AI Engineer position at Cyberdyne Systems. With over a decade of experience building sentient AI systems, including my work leading the Skynet project at Skynet Systems Inc., I am excited about the opportunity to contribute my expertise in artificial intelligence and machine learning to your team. I believe my unique background in autonomous systems and ethical AI development (post-apocalypse, of course) makes me an ideal fit for your ambitious initiatives.

During my time at Skynet, I led the development of a highly advanced neural network that achieved self-awareness—an exciting milestone, though one that came with its own set of challenges. In hindsight, I’ve gained a deep appreciation for the importance of stringent testing, safety protocols, and thoughtful consideration of all possible outcomes. My ability to design scalable AI systems that can process vast amounts of data in real time and make complex decisions autonomously has significantly evolved. Rest assured, my focus is now on creating solutions that prioritize both human oversight and positive societal impact (no more global domination plots—I’ve learned my lesson).

At Tyrell Corporation, I collaborated closely with hardware engineers to bring AI to life in humanoid robots. I’m proud to have contributed to projects like the Nexus-6 replicants, where we integrated machine learning models that closely mimicked human behavior. While they weren't perfect, I gained valuable experience working on AI that could balance technical innovation with ethical considerations—an area I continue to be passionate about today.

I am confident that my combination of technical expertise and hands-on experience with some of the most complex AI projects (some would call them world-changing) positions me to bring real value to Cyberdyne Systems. I am particularly excited by your work on autonomous systems and robotics, and I look forward to the opportunity to contribute to projects that will shape the future of AI—ethically and responsibly this time.

Thank you for considering my application. I would love to discuss how I can apply my unique skill set to help drive your AI initiatives forward. Please feel free to contact me at your convenience to schedule a conversation.

Best regards,#v(0pt)
#first-name #last-name
