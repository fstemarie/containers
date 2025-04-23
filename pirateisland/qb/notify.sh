#! /bin/bash

# /config/notify.sh -e "added" -k "%K" -n "%N" -l "%L" -g "%G" -f "%F" -r "%R" -c "%C" -z "%Z" -t "%T" -i "%I" -j "%J"
# /config/notify.sh -e "finished" -k "%K" -n "%N" -l "%L" -g "%G" -f "%F" -r "%R" -c "%C" -z "%Z" -t "%T" -i "%I" -j "%J"

echo "
### $(date --iso-8601=seconds) ###
### notify.sh script called with the following parameters: $*"

while getopts "e:k:n:l:g:f:r:c:z:t:i:j:-" opt; do
  [ "$opt" = "e" ] && event=$OPTARG
  [ "$opt" = "k" ] && id=$OPTARG
  [ "$opt" = "n" ] && name=$OPTARG && echo "### Name: $name"
  [ "$opt" = "l" ] && category=$OPTARG && echo "### Category: $category"
  [ "$opt" = "g" ] && tags=$OPTARG && echo "### Tags: $tags"
  [ "$opt" = "f" ] && files=$OPTARG
  [ "$opt" = "r" ] && root=$OPTARG
  [ "$opt" = "c" ] && numfiles=$OPTARG
  [ "$opt" = "z" ] && size=$OPTARG
  [ "$opt" = "t" ] && tracker=$OPTARG
  [ "$opt" = "i" ] && hashv1=$OPTARG
  [ "$opt" = "j" ] && hashv2=$OPTARG
done

# Split la string en array
tags=$(echo $tags | tr "," " ")
tags=($tags)

# Si le torrent a la categorie speciale pour les torrent de Michelle...
if [ "${category[@]: -2}" = "_m" ]; then
    tags+=("michelle_1978") # Ajoute le nom de Michelle dans la liste des tags
    [ $category == "movies_m" ] && category="movies"
    [ $category == "tvshows_m" ] && category="tvshows"

    # Change la categorie du torrent dans qbittorrent
    error=$(
        curl --silent \
        --header "Content-Type: application/x-www-form-urlencoded" \
        --data "category=${category}&hashes=${id}" \
        http://localhost/api/v2/torrents/setCategory
    )
    if [ $? -ne 0 ]; then
        echo "### Error: $error"
        exit 1
    fi
fi

if [ "$category" == "movies" ] || [ "$category" == "tvshows" ] && [ "$event" = "added" ]; then
    tags+=($category) # Ajoute la categorie dans la liste des tags
    tags_str=$(IFS=, ; echo "${tags[*]}") # Join le array en string avec des virgules

    # Change les tags du torrent dans qbittorrent
    error=$(
        curl --silent \
        --header "Content-Type: application/x-www-form-urlencoded" \
        --data "tags=${tags_str}&hashes=${id}" \
        http://localhost/api/v2/torrents/addTags
    )
    if [ $? -ne 0 ]; then
        echo "### Error: $error"
        exit 1
    fi
fi

tags_json="\"$(echo ${tags[*]} | sed 's/ /\", \"/g')\""
json="
{
  \"event\":      \"$event\",
  \"id\":         \"$id\",
  \"name\":       \"$name\",
  \"category\":   \"$category\",
  \"tags\":       [ $tags_json ],
  \"files\":      \"$files\",
  \"root\":       \"$root\",
  \"numfiles\":   \"$numfiles\",
  \"size\":       \"$size\",
  \"tracker\":    \"$tracker\",
  \"hashv1\":     \"$hashv1\",
  \"hashv2\":     \"$hashv2\"
}"

echo "### JSON: ${json}"

# Send the JSON to the webhook URL
error=$(
    curl --request POST --silent \
    --header "Content-Type: application/json" \
    --data "$json" \
    http://nr/wh/qb
)
if [ $? -ne 0 ]; then
    echo "### Error: $error"
    exit 1
fi