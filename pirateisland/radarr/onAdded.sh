#!/bin/bash

# radarr_movie_addmethod=Manual
# radarr_movie_genres=Horror|Thriller
# radarr_movie_imdbid=tt34493926
# radarr_applicationurl=
# radarr_instancename=Radarr
# radarr_movie_year=2025
# radarr_movie_tags=1 - francois|jellyseerr
# radarr_movie_path=/emerald/video/movies/Rob1n (2025)
# radarr_movie_originallanguage=eng
# radarr_eventtype=MovieAdded
# radarr_movie_tmdbid=1443260
# radarr_movie_id=1614
# radarr_movie_title=Rob1n

radarr_url="https://radarr.sole-altair.ts.net";
api_key="056c0075bcf443069b7e33b8d9b7165a";

echo "Radarr Environment Variables:"
env | grep -E '^radarr_' | while read -r line; do
    echo "$line"
done

if [ "$radarr_eventtype" = "Test" ]; then
    curl --request GET --silent \
        --header "Authorization: Bearer tk_b30ig2jeoae9g15df6y6sa1lj62z4" \
        --data '{
            "topic": "pirate_qnyrFjBaHidCWzwy",
            "title": "Radarr -> onAdded.sh",
            "message": "A test event has occured",
            "tags": ["test_tube", "radarr", "test"],
            "priority": 2
        }' \
        "https://ntfy.sh"
elif [ "$radarr_eventtype" = "MovieAdded" ]; then
    # Get current movie info
    # movie_json=$(
    #     curl --request GET --silent \
    #         --header "X-Api-Key: $api_key" \
    #         --header "Content-Type: application/json" \
    #         "$radarr_url/api/v3/movie/$radarr_movie_id"
    # )

    # Replace tags as needed
    # updated_json=$(echo "$movie_json" | jq '
    #     .tags |= map(
    #         if . == "1 - francois" then "francois"
    #         elif . == "2 - michelle" then "michelle"
    #         else .
    #         end
    #     )
    # ')

    # Update movie with new tags
    # curl --request PUT --silent \
    #     --header "X-Api-Key: $api_key" \
    #     --header "Content-Type: application/json" \
    #     --data "$updated_json" \
    #     "$radarr_url/api/v3/movie/$radarr_movie_id"

    # echo "Tags updated for movie ID $radarr_movie_id"
fi