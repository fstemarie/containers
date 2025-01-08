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

json="
{
  \"server\":     \"qb.home\",
  \"event\":      \"$event\",
  \"id\":         \"$id\",
  \"name\":       \"$name\",
  \"category\":   \"$category\",
  \"tags\":       \"$tags\",
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
  http://nr/webhooks/raktar_qb
