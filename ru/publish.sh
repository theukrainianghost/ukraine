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
imagelink=""
titleen=""
titleru=""
titlefr=""
tags="#россия #украина #геноцид #нетвойне #StandWithUkraine #РоссияСмотри #RussiaInvadedUkraine #RussiaUkraineWar #RussianWarCrimes"


rep=$(LANG=C diff -qr ./_i18n/fr/_posts/ ./_i18n/en/_posts/  | grep -oP "^Only in \K.*")   
if [ -z "$rep" ]
then
    echo "rien à faire"
else
    rep=$(echo $rep | sed 's/: //')
    content=$(cat $rep)
    rm $rep
    repru=$(echo $rep | sed 's/fr/ru/')
    repen=$(echo $rep | sed 's/fr/en/')
    while IFS= read -r line
    do
       
      if [[ "$line" != *"<"* && "$line" != "" && "$line" != "---" 
       && "$line" != "layout: post" && "$line" != "title: \""* 
       && "$line" != "date: "* && "$line" != "categories: all" ]]; then
          textru=$(python3 -m deepl --auth-key=$token text --to=RU "$line")
          texten=$(python3 -m deepl --auth-key=$token text --to=EN-GB "$line")
          textfr=$line
      elif [[ "$line" == "title: \""* ]]; then
         titlefr=$(echo $line | grep  -Po 'title: "\K[^"]*')
         titleru=$(python3 -m deepl --auth-key=$token text --to=RU "$titlefr" | sed "s/\"//g")
         textru="title: \"$titleru\""
         titleen=$(python3 -m deepl --auth-key=$token text --to=EN-GB "$titlefr" | sed "s/\"//g")
         texten="title: \"$titleen\""
         textfr=$line
      elif [[ "$line" == "date: "* ]]; then
         date=$(echo $line | grep  -Po '(?<=date: ).*($)')
         dateheure=${dateheure::-1}
         newdateheure="$(date +"%Y-%m-%d %T") +0100"
         textru="date: $newdateheure"
         texten="date: $newdateheure"
         textfr="date: $newdateheure"
      elif [[ "$line" == "source : "* ]]; then
         texten=$line
         textru=$(echo "$line" | sed "s/source :/источник :/g")
         textfr=$line
      elif [[ "$line" == *"<img"* ]]; then
         imagelink=$(echo $line | grep  -Po '<img src="{{ site.baseurl }}/assets/images/\K[^"]*')
         textru=$line
         texten=$line
         textfr=$line
      elif [[ "$line" == *"video/mp4"* ]]; then
         videolink=$(echo $line | grep  -Po '<source src="{{ site.baseurl }}/assets/videos/\K[^"]*')
         textru=$line
         texten=$line
         textfr=$line
      elif [[ "$line" == *"<tags"* ]]; then
         tags=$(echo $line | grep  -Po '<tags values="\K[^"]*')
      else
         textru=$line
         texten=$line
         textfr=$line
      fi 
      echo "$textru" >> $repru
      echo "$texten" >> $repen
      echo "$textfr" >> $rep
      
    done < <(printf '%s\n' "$content") 
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
# rm -rf _config.yml
# cp _config.yml.docker _config.yml
# JEKYLL_ENV=production jekyll build
# sshpass -p "ukraine69@" ssh ukraine@192.168.0.189 "rm -rf /disk/save/containers/ukr/*"
# sshpass -p "ukraine69@" scp -r _site/* ukraine@192.168.0.189:/disk/save/containers/ukr
# sshpass -p "ukraine69@" ssh ukraine@192.168.0.189 "rm /disk/save/containers/ukr/publish.sh"

repparse=${rep:18}
repparse=${repparse::-9}
repparse=$(echo $repparse | sed "s/-/\//g")
url="https://www.russianliesaboutukraine.com/all/$repparse.html"
medialink=""
if [ -n "$imagelink" ]; then
    medialink="/home/srouaix/perso/ukraine/russianliesaboutukraine/assets/images/$imagelink"
fi

if [ -n "$videolink" ]; then
    medialink="/home/srouaix/perso/ukraine/russianliesaboutukraine/assets/videos/$videolink"
fi


url=$(twzer sh -b $url | grep  -Po '│ SHORT LINK: │ \K[^ |]*')

sleep 180

python3 twitter.py $api_key $api_secret $access_token $access_token_secret $bearer_token "$titlefr" "$titleen" "$titleru" "$url" "$tags" "$medialink"

bundle exec jekyll serve --livereload