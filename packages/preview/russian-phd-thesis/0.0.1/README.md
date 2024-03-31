# Шаблон русской кандидатской диссертации

Шаблон русской кандидатской диссертации на языке разметки [Typst](https://typst.app/) - современной альтернативы LaTeX.

## Использование

В веб-приложении нажмите "Start from template" и на панели найдите `russian-phd-thesis`.

Вы также можете инициализировать проект командой:

```bash
typst init @preview/russian-phd-thesis
```

Будет создана новая директория со всеми файлами, необходимыми для начала работы.

Также шаблон можно запустить в контейнере Docker и в `github.com/codespaces`.

## Конфигурация

Для настройки пользовательских данных необходимо редактировать файл `template/common/data.typ`. Шрифт и цвет ссылок можно поменять в файле `template/common/style.typ`.

Общая характеристика работы для диссертации и автореферата формируется из данных в файле `template/common/characteristic.typ`. Заключение для диссертации и автореферата формируется из данных в файле `template/common/concl.typ`.

Список литературы формируется из файлов `template/common/external.bib` и `template/common/author.bib`.

Список сокращений и условных обозначений формируется из данных, записанных в файле `template/common/acronyms.typ` `template/common/symbols.typ`. Список определений формируется из данных в файле `template/common/glossary.typ`.

## Компиляция  

Для компиляции проекта из CLI используйте:

```bash
typst compile template/thesis.typ
```

Или если вы хотите следить за изменениями:

```bash
typst watch template/thesis.typ
```

## Особенности

- Стандарт ГОСТ Р 7.0.11-2011.

## Благодарности

- Благодарность авторам шаблона диссертации на [LaTeX](https://github.com/AndreyAkinshin/Russian-Phd-LaTeX-Dissertation-Template)
