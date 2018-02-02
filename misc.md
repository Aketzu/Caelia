
# Timelapse generation

 (echo "ffconcat version 1.0"; (for f in $(find $(pwd)); do echo "file" $f; done | grep JPG | sort)) > timelapse.ffcat

 ffmpeg -r 30 -safe 0 -i timelapse.ffcat -vf crop=3000:1688:0:100,scale=1920:1080 -vcodec libx264 -preset slow -an -x264opts crf=18 -y timelapse-ke.mp4
                                                              ^ vary crop position
