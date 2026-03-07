#import "@preview/qilin-resume-studio:0.1.0": resume

#let data = yaml("data.yml")

#show: resume.with(data: data)
