#!/usr/bin/env bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "${SCRIPT_DIR}"

echo "> will download fonts ..."


# roboto font
#wget https://dl.dafont.com/dl/?f=roboto
wget https://mirrors.ctan.org/fonts/roboto.zip
unzip -o roboto.zip
mv roboto/opentype roboto_
rm -r roboto
mv roboto_ roboto
rm roboto/RobotoCondensed*
rm roboto/RobotoSerif_Condensed*
rm roboto/RobotoSerif*
rm roboto.zip

# xcharta font
wget http://mirrors.ctan.org/fonts/xcharter.zip
unzip -o xcharter.zip
mv xcharter/opentype xcharter_
rm -r xcharter
mv xcharter_ xcharter
rm xcharter.zip