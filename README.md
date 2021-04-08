# Caelia

Some collection of scripts and stuff to continuously record video and then
clip&encode it to individual videos.

## Capture

Main idea is to continously record video from SDI/HDMI/NDI and split it to 30
second files for easy transfers.

`capture` script is run on the capture machines. Depending on the source it
requires bmdtools or special ffmpeg with NDI.

bmdtools: https://github.com/lu-zero/bmdtools, you need Decklink SDK to compile

Encoding is preferrably done using Nvidia hardware codec. H265 requires
GeForce 10 series or newer. Normal cards can do max 2 simultaneous encodings.
Note that with Nvidia you cannot force keyframes so the files will not be
exactly 30 seconds long.

## Transfer

Caelia Rails application is run on some central machine with a bit more
storage. Main idea is that files are `rsync`ed from capture machines to the
edit machine where they are cut and encoded to single videos.

Recording directory is hardcoded in app/jobs/scan_recordings_job.rb file. By
default it is `/mnt/asmvid/rec`. ScanRecordingsJob runs by default every
minute when Rails application is running. (Configured in
`config/que_schedule.yml`). All subfolders of the recording directory are
scanned for video files. The subfolder names show up in Caelia web ui as
"Recordings". ScanRecordingsJob also creates preview images for first frames
of video.

## Edit

After recordings are visible in Caelia you can go to any one of them and
start a new Vod by clicking on the image where you want to start. This will
automatically re-encode the video to low-quality h264 so it plays in the web
browser. Play the video to correct position and press the button. Then you
can add name to the video, save and click on 'Pick' for end position.
Similarly go to correct part, pick position and Set.

Recording view shows a green border on parts that have already been selected
as Vod.

## Encode

After start & end points have been set you can click 'Do VOD' on either
individual Vod page or in the vods listing. Caelia puts the jobs in the queue
so that only one simultaneous encode job is running.

Resulting .mp4 file is placed in the same root folder where the recordings are.

Encoding settings are hardcoded and editable in `app/models/vod.rb`.
Currently there is `add_ads = true` which adds intro/outro.mp4 files to all
vods. For example if you want to add event name in beginning of the video and
list of sponsors to the end.

## Upload

`youtube-upload` is used to automatically upload videos to Youtube. **NOTE:**
Youtube has severely limited automatic uploads since 2018 and current default
quota allows uploading of about one video per week so this is not usable
anymore.
