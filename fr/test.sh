#!/bin/bash

rep=$(LANG=C diff -qr ./_i18n/fr/_posts/ ./_i18n/en/_posts/  | grep -oP "^Only in \K.*")   
if [ -z "$rep" ]
then
    echo "rien à faire"
else
    rep=$(echo $rep | sed 's/: //')
    content=$(cat $rep)
    title=$(echo $content | grep  -Po 'title: "\K[^"]*')
    newdateheure="$(date +"%Y-%m-%d %T") +0100"
    text=$(echo $content | grep  -Po '(?<=translate-->).*(?=\<!--endtranslate)')
   #echo $text
    textru="dsqfsdfd"
    contentru=$(echo "$content" | sed -n "1,/<!--translate-->/p;/<!--endtranslate-->/,$p")
    contentru=$(echo "$contentru" | sed "/<!--end/i $text")
    #contentru=$(echo "$content" | sed "s/$text/$textru/g")
    echo $contentru
fi


