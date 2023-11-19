# ytgif
Downloads a video from YouTube and converts some/all of it into a gif

# Requirements
1. yt-dlp
    * Any version should in theory work, but I haven't actually tested any versions other than 2023.11.16, so ymmv
2. ffmpeg
    * You should have this already if you've installed yt-dlp, but if you don't then the program won't work

# Usage
ytgif [-h|i|s|t|f|n|o]
    -h      Displays the help menu
    -i      The input YouTube URL. Must be specified
    -s      The amount of time to skip from the beginning. If not specified, will begin from the start of the video
    -t      The duration you wish to save. If not specified, continues until the end of the video
    -f      The framerate (default 10)
    -n      Disables overwriting files if they exist
    -o      The output filename (without .gif). If not specified, names the file "output.gif"

NOTE: If -n is not used, files will be overwritten if they exist.
