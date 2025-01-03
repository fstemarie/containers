#! /bin/bash

# /config/notify.sh -e "finished" -k "%K" -n "%N" -l "%L" -g "%G" -f "%F" -r "%R" -c "%C" -z "%Z" -t "%T" -i "%I" -j "%J"

prep_size () {
  size=$1
  if [ $(bc <<< "scale=0; $size / 1024^0") -ge 1024 ]; then
    if [ $(bc <<< "scale=0; $size / 1024^1") -ge 1024 ]; then
      if [ $(bc <<< "scale=0; $size / 1024^2") -ge 1024 ]; then
        if [ $(bc <<< "scale=0; $size / 1024^3") -ge 1024 ]; then
          size=$(bc <<< "scale=2; $size / 1024^4")tb
        else
          size=$(bc <<< "scale=2; $size / 1024^3")gb
        fi
      else
        size=$(bc <<< "scale=2; $size / 1024^2")mb
      fi
    else
      size=$(bc <<< "scale=2; $size / 1024^1")kb
    fi
  else
    size="${size}b"
  fi
  echo $size
}

prep_size () {
  size=$1
  units=(kb mb gb tb)
  if [ $size -lt 1024 ]; then
    size="${size}b"
  else
    for pow in (1 2 3 4); do
      if [ $(bc <<< "scale=0; $size / 1024^$pow") -ge 1024 ]; then
        [ $pow -e 4 ] && size=$(bc <<< "scale=2; $size / 1024^4")${units[$pow]}
      else
        size=$(bc <<< "scale=2; $size / 1024^$pow")${units[$pow]}
        break
      fi
    done
  fi
  echo $size
}

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

size=$(prep_size $size)

json="
{
  \"server\":   \"qb.home\",
  \"event\":    \"$event\",
  \"id\":       \"$id\",
  \"name\":     \"$name\",
  \"category\": \"$category\",
  \"tags\":     \"$tags\",
  \"files\":    \"$files\",
  \"root\":     \"$root\",
  \"numfiles\": \"$numfiles\",
  \"size\":     \"$size\",
  \"tracker\":  \"$tracker\",
  \"hashv1\":   \"$hashv1\",
  \"hashv2\":   \"$hashv2\"
}"

curl -X POST \
  -H "Content-Type: application/json" \
  -d "$json" \
  http://nr/webhooks/raktar_qb

echo $json
