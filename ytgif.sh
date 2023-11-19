#!/bin/bash
set -euo pipefail

URL=""
SKIP_DURATION="0"
PLAY_DURATION="0"
FPS=10
OVERWRITE="-y"
OUTPUT=""

Help()
{
    echo "Downloads a video from YouTube and converts some/all of it into a gif"
    echo
    echo "Syntax: ytgif [-h|i|s|t|f|n|o]"
    echo "Options:"
    echo "-h    Display the help menu"
    echo "-i    The input YouTube URL. Must be specified."
    echo "-s    The amount of time to skip from the beginning. If not"
    echo "      specified, will begin from the start of the video"
    echo "-t    The duration you wish to save. If not specified, continues"
    echo "      until the end of the video"
    echo "-f    The framerate (default 10)"
    echo "-n    Disables overwriting files if they exist."
    echo "-o    The output filename (without .gif). If not specified, names"
    echo "      the file \"output.gif\""
    echo
    echo "NOTE: If -n is not used, files will be overwritten if they exist."
}

while getopts "hi:s:t:f:o:" option
do
    case $option in
        h) # Display Help
            Help
            exit;;
        i) # Set the input URL
            URL="$OPTARG";;
        s) # Sets the skip duration
            SKIP_DURATION=$OPTARG;;
        t) # Sets the play duration
            PLAY_DURATION=$OPTARG;;
        f) # Sets the fps
            FPS=$OPTARG;;
        n) # Disables overwriting
            OVERWRITE="-n";;
        o) # Sets the output file name
            OUTPUT=$OPTARG;;
        \?) # Invalid Option
            echo "Error: Invalid option"
            Help
            exit;;
    esac
done

if [[ -z $URL ]]
then
    echo "No input URL specified. Exiting."
    exit
fi

if ! [[ $SKIP_DURATION =~ ^[0-9]+([.][0-9]+)?$ ]]
then
    echo "Input skip duration is not a number. Exiting."
    exit
fi

if ! [[ $PLAY_DURATION =~ ^[0-9]+([.][0-9]+)?$ ]]
then
    echo "Input play duration is not a number. Exiting."
    exit
fi

if ! [[ $FPS =~ ^[0-9]+$ ]]
then
    echo "Invalid input FPS. Exiting."
    exit
fi

if [[ -n $OUTPUT && ! ($OUTPUT =~ ^\S*[.](gif)$) ]]
then
    OUTPUT+=".gif"
elif [[ -z $OUTPUT ]]
then
    OUTPUT="output.gif";
fi

if [[ $(echo "$SKIP_DURATION <= 0" | bc -l) && $(echo "$PLAY_DURATION <= 0" | bc -l) ]]
then
    yt-dlp -f mp4 --no-playlist -o - $URL | ffmpeg $OVERWRITE -i - \
        -vf "fps=$FPS,scale=360:-1:flags=lanczos,split[s0][s1];
        [s0]palettegen[p];[s1][p]paletteuse" -loop 0 $OUTPUT;
elif [[ $(echo "$PLAY_DURATION <= 0" | bc -l) ]]
then
    yt-dlp -f mp4 --no-playlist -o - $URL | ffmpeg -ss $SKIP_DURATION \
        $OVERWRITE -i - \
        -vf "fps=$FPS,scale=360:-1:flags=lanczos,split[s0][s1];
        [s0]palettegen[p];[s1][p]paletteuse" -loop 0 $OUTPUT;
elif [[ $(echo "$SKIP_DURATION <= 0" | bc -l) ]]
then
    yt-dlp -f mp4 --no-playlist -o - $URL | ffmpeg -t $PLAY_DURATION $OVERWRITE\
        -i - \
        -vf "fps=$FPS,scale=360:-1:flags=lanczos,split[s0][s1];
        [s0]palettegen[p];[s1][p]paletteuse" -loop 0 $OUTPUT;
else
    yt-dlp -f mp4 --no-playlist -o - $URL | ffmpeg -ss $SKIP_DURATION \
        -t $PLAY_DURATION $OVERWRITE -i - \
        -vf "fps=$FPS,scale=360:-1:flags=lanczos,split[s0][s1];
        [s0]palettegen[p];[s1][p]paletteuse" -loop 0 $OUTPUT;
fi
