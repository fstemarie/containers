#! /bin/bash

# /config/notify.sh -e "added" -k "%K" -n "%N" -l "%L" -g "%G" -f "%F" -r "%R" -c "%C" -z "%Z" -t "%T" -i "%I" -j "%J"
# /config/notify.sh -e "finished" -k "%K" -n "%N" -l "%L" -g "%G" -f "%F" -r "%R" -c "%C" -z "%Z" -t "%T" -i "%I" -j "%J"

while getopts "e:k:n:l:g:f:r:c:z:t:i:j:-" opt; do
  [ "$opt" = "e" ] && event=$OPTARG
  [ "$opt" = "k" ] && id=$OPTARG
  [ "$opt" = "n" ] && name=$OPTARG
  [ "$opt" = "l" ] && category=$OPTARG
  [ "$opt" = "g" ] && tags=$OPTARG
  [ "$opt" = "f" ] && files=$OPTARG
  [ "$opt" = "r" ] && root=$OPTARG
  [ "$opt" = "c" ] && numfiles=$OPTARG
  [ "$opt" = "z" ] && size=$OPTARG
  [ "$opt" = "t" ] && tracker=$OPTARG
  [ "$opt" = "i" ] && hashv1=$OPTARG
  [ "$opt" = "j" ] && hashv2=$OPTARG
done

tags=$(echo $tags | tr -d " " | tr "," " ")
tags=($tags)

if [ "${category[@]: -2}" = "_m" ]; then
    tags+=("michelle_1978")
    [ $category = "movies_m" ] && category="movies"
    [ $category = "tvshows_m" ] && category="tvshows"

    curl \
        --header "Content-Type: application/x-www-form-urlencoded" \
        --data "category=${category}&hashes=${hashv1}" \
        http://localhost/api/v2/torrents/setCategory

    curl \
        --header "Content-Type: application/x-www-form-urlencoded" \
        --data "tags=michelle_1978&hashes=${hashv1}" \
        http://localhost/api/v2/torrents/addTags
fi

if [ ${#tags[@]} -lt 1 ]; then
    tags_json = ""
else
    tags_json="\"${tags[0]}\""
    for tag in "${tags[@]:1}"
    do
        tags_json="${tags_json}, \"$tag\""
    done
fi


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

curl -X POST \
  -H "Content-Type: application/json" \
  -d "$json" \
  http://nr/wh/qb
