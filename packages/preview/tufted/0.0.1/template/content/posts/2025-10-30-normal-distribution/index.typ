#import "../index.typ": *
#show: template

#import "@preview/lilaq:0.5.0" as lq

= The Normal Distribution

The normal distribution, often called the Gaussian distribution or bell curve, is one of the most fundamental concepts in statistics and probability theory @degroot2012probability. Its characteristic symmetric, bell-shaped curve appears throughout nature and human activity, from heights and test scores to measurement errors and biological variations.

== Key Properties

The normal distribution is completely defined by two parameters: the mean ($mu$) and standard deviation ($sigma$) @rice2006mathematical. The mean determines the center of the distribution, while the standard deviation controls its spread. Approximately 68% of values fall within one standard deviation of the mean, 95% within two, and 99.7% within three—a rule known as the empirical rule or 68-95-99.7 rule.

The probability density function is given by:

$ f(x) = 1/(sigma sqrt(2pi)) e^(-(x-mu)^2/(2sigma^2)) $

This formula, developed by Gauss in his astronomical work @gauss1809theoria, has become foundational to modern statistics @stigler1982gauss.


#{
  let diagram = html.frame(lq.diagram(
    xaxis: (subticks: none),
    yaxis: (subticks: none),
    lq.bar(
      range(-7, 8).map(x => x / 2.0),
      range(-7, 8).map(x => {
        let z = x / 2.0
        calc.exp(-z * z / 2) / calc.sqrt(2 * calc.pi)
      }),
      fill: blue.lighten(50%),
    ),
  ))

  figure(caption: [Normal distribution], diagram)
}


== Why It Matters

The normal distribution's importance stems from the Central Limit Theorem#footnote[The Central Limit Theorem requires that the random variables being summed are independent and identically distributed with finite variance. The convergence to normality improves as the number of variables increases.], which states that the sum of many independent random variables tends toward a normal distribution, regardless of the original distribution. This explains why so many natural phenomena follow this pattern.

In practice, the normal distribution enables:
- Statistical inference and hypothesis testing
- Quality control in manufacturing
- Risk assessment in finance
- Modeling of natural measurements

== Real-World Applications

Scientists use normal distributions to model everything from IQ scores to particle velocities in gases. Engineers apply it in reliability analysis and signal processing. Financial analysts rely on it for portfolio theory and option pricing, though real market returns often deviate from normality#footnote[Financial returns often exhibit "fat tails" (higher probability of extreme events) and skewness compared to the normal distribution. This has important implications for risk management and the pricing of derivatives.].

Understanding the normal distribution provides a foundation for statistical thinking and data analysis, making it an essential tool for researchers, analysts, and decision-makers across countless fields.

#bibliography("refs.bib")
