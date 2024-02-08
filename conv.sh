#!/bin/bash

#./convert.sh "/mnt/c/Users/luked/Music/FORGOTTEN/FANTASIA 2024 [Full Mixtape]"

album_name="$2"
album_artist="$3"
get_song_title(){
    local file_string="$1"                      # get first parameter
    file_string=$(basename "$file_string" .wav) # removes directory and file extension leaving just the file name
    file_string="${file_string:3}"              # removes track number
    #file_string="${file_string%%(*)}"           # cuts off everything after the last occurence of '(' to remove the "(feat. ...)""
    file_string=$(echo "$file_string" | cut -d'(' -f1 | sed 's/ *$//')
    echo $file_string
}

get_track_number(){
    local file_string="$1"                      # get first parameter
    file_string=$(basename "$file_string") # removes directory leaving just the file name
    file_string="${file_string:0:2}" # keeps only the first two characters
    file_string="${file_string#0}" # removes leading zero
    echo $file_string

}

get_artist(){
    local file_string="$1"                      # get first parameter
    file_string=$(basename "$file_string") # removes directory leaving just the file name
    local features=$(echo "$file_string" | sed -n 's/.*feat. //p')
    if [ -n "$features" ]; then
        local artist=$(echo "$features" | cut -d')' -f1)
        echo "$artist"
    else # if no features in file name, set artist as album artist
        echo "$album_artist"
    fi
}
# get inputs as parameters
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <input_folder> <album_name> <album_artist>"
    exit 1
fi
# check if the given input_folder exists
input_folder="$1"
if [ ! -d "$input_folder" ]; then
    echo "Error: Input folder not found: $input_folder"
    exit 1
fi

# designate the folder for the reformatted music to go into.
output_folder="$input_folder/av4Files"
mkdir -p "$output_folder" # make folder if it doesnt already exist


for input_file in "$input_folder"/*.{wav,mp3}; do
    if [ -f "$input_file" ]; then
        output_file="$output_folder/$(basename "${input_file%.*}.m4a")"

        title=$(get_song_title "$input_file")

        artist=$(get_artist "$input_file")
        track_number=$(get_track_number "$input_file")

        ffmpeg -nostdin -i "$input_file" -c:a aac -b:a 320k -strict -2 \
            -metadata track="$track_number" \
            -metadata title="$title" \
            -metadata artist="$artist" \
            -metadata album_artist="$album_artist" \
            -metadata album="$album_name" \
            -metadata compilation=1 "$output_file"

        echo "Converted: $input_file"
    fi
done

echo "Conversion complete. M4A files are in: $output_folder"