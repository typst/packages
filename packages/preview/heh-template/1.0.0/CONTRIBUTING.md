# Contribuer à typst-template

Premièrement, merci de prendre le temps de contribuer à ce dépot.

Toutes les contributions, peu importe leur taille sont les bienvenues. Ce document a pour but de faciliter le processus de contribution et la maintenance du dépot en définissant les **prérequis à respecter** en créant une pull request. Il est donc essentiel de prendre connaissance du contenu de ce document **avant** de contribuer

## Rapports de bugs / suggestion de fonctionalités

Pour signaler des problèmes ou suggérer des fonctionnalités, nous utilisons les **issues** de GitHub. Avant de faire une demande, assurez vous qu'une autre issue concernant le même problème ou contenant la même demande **n'est pas déjà ouverte**.

Si une issue existe déjà, vous pouvez éventuellement y contribuer en y ajoutant des **informations supplémentaires** dans le cas d'un rapport de bug (exemple: préciser depuis quand vous avez le problème si personne d'autre ne l'a fait). Dans le cas d'une demande de fonctionnalités, vous pouvez simplement **réagir avec un :+1: pour montrer votre support**

## Contribuer au code

Si vous souhaitez contribuer au code (résoudre un bug, ajouter une fonctionalité, ...), nous vous demandons de faire une **pull request** sur GitHub.

Premièrement, faites attention à bien respecter notre **convention de commit** qui est basée sur les [conventional commits](https://www.conventionalcommits.org/en/v1.0.0/). Nous utilisons le formattage suivant `type(cible (optionnel)): message en français` ou le `type` vient des conventional commits et est en anglais

**Avant** d'envoyer la PR, il est impératif de tester le code en compilant le manuel et la démo et en vérifiant que **tous** les éléments s'affichent correctemnt

Nous vous demandons aussi de formatter le code avec `just fmt` et de suivre les pratiques de style indiquées dans [STYLE.md](STYLE.md)

Bien sûr, si vous avez une hésitation sur comment implémenter une fonctionnalité / formatter votre code / ..., n'hésitez pas à soumettre la pull request et poser les questions nécéssaires, le but n'étant pas non plus de freiner les contributions.

