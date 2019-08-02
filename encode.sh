#!/usr/bin/zsh

input=$(find /mnt/asmvid/incoming -not -type d| sort -R | tail -1)
if [ -z "$input" ]; then
    echo "Nothing to do"
      exit 0
fi

s1=$(stat -c%s "$input")
sleep 5
s2=$(stat -c%s "$input")
if [ "$s1" != "$s2" ]; then
    echo "File size is not stable, $input"
      exit 0
fi

proc=/mnt/asmvid/processing
dest=/mnt/asmvid/transcoded

output=$(basename "$input" .mov).mp4
tmpfile=$(tempfile).mp4

procfile=$proc/$(basename "$input")
mv $input $procfile

#ffmpeg -y -i "$procfile" -vcodec libx264 -preset slow -acodec aac -pix_fmt yuv420p -x264opts level=4.1:crf=19:ref=4:me=umh -ab 192k "$tmpfile"
ffmpeg -y -i "$procfile" -vf "scale=iw*2:ih*2" -sws_flags neighbor -pix_fmt yuv420p -vcodec hevc_nvenc -preset slow -profile:v main -acodec aac -level 5.1 -rc vbr -b:v 30m -rc-lookahead 60  -ab 192k "$tmpfile"

mp4file --optimize "$tmpfile"
mv "$tmpfile" "$dest/$output"
