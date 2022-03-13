#!/bin/bash
files=$(ls ./assets/videos/*.mp4)

for item in ${files[*]}
do
  itemnew=${item::-3}
  itemnew="${itemnew}webm"
  if test -f "$itemnew"; then
    echo "$itemnew exists."
  else
     ffmpeg  -i $item -codec:v libvpx -quality good -cpu-used 0 -b:v 600k -maxrate 600k -bufsize 1200k -qmin 10 -qmax 42 -vf scale=-1:480 -threads 4 -codec:a libvorbis -b:a 128k $itemnew
  fi
done

token="5ace2a57-53f8-0401-d9c5-679bef3840f8:fx"

# twitter
api_key="YlLIxcxhHinIEz2jy5oWsGsAl"
api_secret="xiGb5pDeXpL1eMIURQm5900xeF8gFfEBSdngTW9QoX1Ir9EBef"
bearer_token="AAAAAAAAAAAAAAAAAAAAACPCaAEAAAAAEiTHGe1%2FnEYgh7Lx70i8%2FnszUkQ%3DBnCQ3CB7l1yYVvZMBtOyBJk933TGogNFKSCzhMjxN4Odx8XZF5"
access_token="1500744221191548930-gomjgwWoTfmfG5uzIjbInVelySv8sL"
access_token_secret="c1JdvyOaobly6aC0vJtDrYymu59fVQETIourAaqsZVSSI"

rep=$(LANG=C diff -qr ./_i18n/fr/_posts/ ./_i18n/en/_posts/  | grep -oP "^Only in \K.*")   
if [ -z "$rep" ]
then
    echo "rien à faire"
else
    rep=$(echo $rep | sed 's/: //')
    content=$(cat $rep)
    repru=$(echo $rep | sed 's/fr/ru/')
    repen=$(echo $rep | sed 's/fr/en/')
    title=$(echo $content | grep  -Po 'title: "\K[^"]*')
    titleru=$(python3 -m deepl --auth-key=$token text --to=RU "$title")
    titleen=$(python3 -m deepl --auth-key=$token text --to=EN-GB "$title")
    dateheure=$(echo $content | grep  -Po '(?<=date: ).*(?=categories)')
    dateheure=${dateheure::-1}
    newdateheure="$(date +"%Y-%m-%d %T") +0100"
    text=$(echo $content | grep  -Po '(?<=translate-->).*(?=\<!--endtranslate)')
    text=${text::-1}
    text=${text:1}
    textru=$(python3 -m deepl --auth-key=$token text --to=RU "$text")
    texten=$(python3 -m deepl --auth-key=$token text --to=EN-GB "$text")
    content=$(echo "$content" | sed "s/$dateheure/$newdateheure/g")
    echo "$content" > $rep
    contentru=$(echo "$content")
    contentru=$(echo "$contentru"| sed "s/\"$title\"/\"$titleru\"/g")
    contentru=$(echo "$contentru" | sed "s/$text/$textru/g")
    contentru=$(echo "$contentru" | sed "s/source :/источник :/g")
    echo "$contentru" > $repru
    contenten=$(echo "$content")
    contenten=$(echo "$contenten" | sed "s/\"$title\"/\"$titleen\"/g")
    contenten=$(echo "$contenten" | sed "s/$text/$texten/g")
    echo "$contenten" > $repen
fi

rm -rf _config.yml
cp _config.yml.github _config.yml
JEKYLL_ENV=production jekyll build
git add .
now=$(date)
git commit -m "$now"
git push
cd _site
rm -rf *.sh
touch .nojekyll
git add .
now=$(date)
git commit -m "$now"
git push --force --set-upstream origin gh-pages
cd ..
rm -rf _config.yml
cp _config.yml.githubcopy _config.yml
JEKYLL_ENV=production jekyll build
cd _site_github
shopt -s extglob
rm -rf !(.git)
cd ..
cp -r ./_site/* ./_site_github
cd _site_github
rm -rf *.sh
touch .nojekyll
git add .
now=$(date)
git commit -m "$now"
git push --force --set-upstream origin gh-pages
cd ..
rm -rf _config.yml
cp _config.yml.docker _config.yml
JEKYLL_ENV=production jekyll build
sshpass -p "ukraine69@" ssh ukraine@192.168.0.189 "rm -rf /disk/save/containers/ukr/*"
sshpass -p "ukraine69@" scp -r _site/* ukraine@192.168.0.189:/disk/save/containers/ukr
sshpass -p "ukraine69@" ssh ukraine@192.168.0.189 "rm /disk/save/containers/ukr/publish.sh"

repparse=${rep:18}
repparse=${repparse::-9}
repparse=$(echo $repparse | sed "s/-/\//g")
url="https://www.russianliesaboutukraine.com/all/$repparse.html"

sleep 120

python3 twitter.py $api_key $api_secret $access_token $access_token_secret $bearer_token "$titleen" "$titleru" $url

bundle exec jekyll serve --livereload