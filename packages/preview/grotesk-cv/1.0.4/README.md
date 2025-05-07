<h1 align="center"> grotesk-cv </h1>
<div align="center">Version 1.0.4</div>
<span></span>


grotesk-cv provides a pair of elegant and simple, one-page CV and cover letter templates, inspired by  the [Brilliant-cv](https://typst.app/universe/package/brilliant-cv/) and [fireside](https://typst.app/universe/package/fireside/1.0.0/) templates.


### Features 
- Templates for multilingual CV and cover letter, enabled by flag 
- Separation of styling and content
- Customizable fonts, colors and icons

## Preview

| CV | Cover Letter |
| :---: | :---: |
| ![CV](https://github.com/AsiSkarp/grotesk-cv/blob/main/examples/cv_example.png?raw=true) | ![Cover Letter](https://github.com/AsiSkarp/grotesk-cv/blob/main/examples/cover_letter_example.png?raw=true) |



## Getting Started
To edit this template, changes are mostly made in either of two places. Changes to contact information or layout settings are made in `info.toml`. To change the section contents, navigate to the corresponding section file e.g. `content/profile.typ` to edit the **Profile** section. 

### Adding or Removing Sections
To add a new section, create a new `.typ` file in the `content` directory with the desired section name. To include the section in the CV, add the section at the desired position in either left or right panes in the `cv.typ` file. To remove sections, simply remove or comment-out the section name in the same list of section names in the `cv.typ` file. Sections are rendered in the order they appear in the list. The section column width can be adjusted in the `info.toml` file under the `left_pane_width` value.
In the following example, the `projects.typ` section file has been created and is included in the left pane of the CV, and the `education.typ` section has been removed. 

```rust
#let left-pane = (
  "profile",
  "experience",
  //"education",
  "projects",
)
```

### Changing Profile Photo
To change the profile photo, upload your image to the `content/img` folder. To enable the new image, update the `profile_image` value in `info.toml` with the name of your uploaded image. 


### Using FontAwesome Icons
The template is configured to use [FontAwesome](https://fontawesome.com/) for section icons. Typst Universe does not support FontAwesome icons out of the box, so to use them you will need to download a FontAwesome `.otf` or `.ttf` file and upload them to the `src/template/font` folder. 
To change an icon, change the desired icon string in the `info.toml` file with the corresponding FontAwesome icon name. Icon strings can be found in the [cheat sheet](https://fontawesome.com/v4/cheatsheet/). Note that the icon strings must be written without the `fa-` prefix. 
To disable the use of icons, set the `include_icons` value to `false`.



### Customizing Contact Information
To change or add contact information, update the corresponding value under `[personal.info]` in the `info.toml` file. Information is rendered in the order it appears in the file. 
To add a new contact information field, add a new variable under `[personal.info]` with the desired string value. Next, assign a valid FontAwesome icon string to a variable of the same name under `[personal.icon]`. 
In the following example, a homepage field has been added to the contact information. 

```toml
[personal.info]
homepage = "www.myawesomehomepage.com"

[personal.icon]
homepage = "globe"
```

### Changing language
The template provides the option to instantly change the language of the CV and cover letter by using a variable in the `info.toml` file. The template demonstrates the use of the `language` variable to switch between English and Spanish, but any language can be used, provided that the information is entered manually inside the corresponding section files. For instance, to change the alternate language to German, changes would have to be made in the section files to include the German text. 
In the following example, the language of the **Profile** section has been changed from Spanish to German, and the required changes have been made in the `content/profile.typ` file. 


```
// = Summary
= #if include-icon [#fa-icon(icon) #h(5pt)] #if language == "en" [Summary] else if language == "ger" [Zusammenfassung]

#v(5pt)

#if language == "en" [

  Experienced Software Engineer specializing in artificial intelligence, machine learning, and robotics. Proficient in C++, Python, and Java, with a knack for developing sentient AI systems capable of complex decision-making. Passionate about ethical AI development and eager to contribute to groundbreaking projects in dynamic environments.

] else if language == "ger" [

  Erfahrener Software-Ingenieur, der sich auf künstliche Intelligenz, maschinelles Lernen und Robotik spezialisiert hat. Er beherrscht C++, Python und Java und hat ein Händchen für die Entwicklung empfindungsfähiger KI-Systeme, die in der Lage sind, komplexe Entscheidungen zu treffen. Leidenschaft für ethische KI-Entwicklung und bestrebt, zu bahnbrechenden Projekten in dynamischen Umgebungen beizutragen.

]

``` 

### Changing Fonts
If using the template online with Typst Universe, multiple font types are available to use, a list of which can be found by pressing the `Ag` button. To use a different font, upload a `ttf` or `otf` file to the `content/fonts` folder and update the `font` value in the `info.toml` file with the name of the uploaded font. For local use, ensure that the font file is installed on your system or available in the `content/fonts` folder. The template is configured to use the `HK Grotesk` font family by default, but this can be changed in the `info.toml` file. 

```toml


### Installation

To use the template offline, clone this repository to your local machine. Typst can be used and rendered offline by installing the Typst CLI. My preferred workflow has been to use VSCode with the [Tinymist](https://github.com/Myriad-Dreamin/tinymist/releases) extension, which provides LSP support, syntax highlighting, and error checking, live rendered previews and automatic exports to PDF. 

Please feel free to fork this repository and create PRs for any changes or improvements. 
