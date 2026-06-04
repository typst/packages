# canonical-nthu-thesis

A [Typst](https://typst.app/docs/) template for master theses and doctoral dissertations for NTHU (National Tsing Hua University).

國立清華大學碩士（博士）論文[Typst](https://typst.app/docs/)模板。

- [Typst Universe Package](https://typst.app/universe/package/canonical-nthu-thesis)
- [Codeberg Repo](https://codeberg.org/kotatsuyaki/canonical-nthu-thesis)

![](./covers.png)


## Usage

### Installing the Chinese fonts

This template uses the official fonts from the Ministry of Education of Taiwan (Edukai/TW-MOE-Std-Kai), which are required to be downloaded and installed manually from [language.moe.gov.tw](https://language.moe.gov.tw/001/Upload/Files/site_content/M0001/edukai-5.0.zip).  The Typst web app has the fonts installed by default, so there is no need to install the fonts on the web app.

此模板中文部分使用教育部標準楷書字體（Edukai/TW-MOE-Std-Kai），在本地編譯文件前需要自[language.moe.gov.tw](https://language.moe.gov.tw/001/Upload/Files/site_content/M0001/edukai-5.0.zip)下載並手動安裝。Typst web app已預裝該字體，故無需額外安裝。


### Editing

All the content of the thesis are in the `thesis.typ` file.
In the beginning of `thesis.typ`, there is a call to the `setup-thesis(info, style)` function that configures the metadata (the titles and the author etc.) and the styling of the thesis document.
Replace the values with your own.

所有論文內容皆位於`thesis.typ`檔案內。該檔案前段的部分呼叫了`setup-thesis(info, style)`函式，設置論文的雜項資訊（標題及作者等）及外觀選項，請置換為自己的資訊。


### Local usage

```sh
$ typst init @preview/canonical-nthu-thesis:0.2.0 my-thesis
$ cd my-thesis
$ typst watch thesis.typ
```


## Development

Development and issue tracking happens on the [repository on Codeberg](https://codeberg.org/kotatsuyaki/canonical-nthu-thesis).


## License

This project is licensed under the MIT License.
