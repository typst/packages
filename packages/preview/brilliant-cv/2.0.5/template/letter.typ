// Imports
#import "@preview/brilliant-cv:2.0.5": letter
#let metadata = toml("./metadata.toml")


#show: letter.with(
  metadata,
  myAddress: "Your Address Here",
  recipientName: "Company Name Here",
  recipientAddress: "Company Address Here",
  date: datetime.today().display(),
  subject: "Subject: Hey!",
  signature: image("src/signature.png"),
)

Dear Hiring Manager,

I am excited to submit my application for the Senior Data Analyst position at ABC Company. With over 5 years of experience in data analysis and a demonstrated track record of success, I am confident in my ability to make a valuable contribution to your team.

In my current role as a Data Analyst at XYZ Company, I have gained extensive experience in data mining, quantitative analysis, and data visualization. Through my work, I have developed a deep understanding of statistical concepts and have become adept at using tools such as SQL, Python, and R to extract insights from complex datasets. I have also gained valuable experience in presenting complex data in a visually appealing and easily accessible manner to stakeholders across all levels of an organization.

I believe that my experience in data analysis makes me an ideal candidate for the Senior Data Analyst position at ABC Company. I am particularly excited about the opportunity to apply my skills to support your organization's mission and drive impactful insights. Your focus on driving innovative solutions to complex problems aligns closely with my own passion for using data analysis to drive positive change in organizations.

In my current role, I have been responsible for leading data projects from initiation to completion. I work closely with cross-functional teams to identify business problems and use data to develop solutions that drive business outcomes. I have a proven track record of delivering high-quality work on time and within budget.

Furthermore, I have extensive experience in developing and implementing data-driven solutions that improve business operations. For example, I have implemented predictive models that have improved sales forecasting accuracy by 10%, resulting in significant cost savings. I have also developed dashboards that provide real-time insights into business performance, enabling stakeholders to make more informed decisions.

As a highly motivated and detail-oriented individual, I am confident that I would thrive in the fast-paced and dynamic environment at ABC Company. I am excited about the opportunity to work with a talented team of professionals and to continue developing my skills in data analysis.

Thank you for considering my application. I look forward to the opportunity to discuss my qualifications further.

Sincerely,
