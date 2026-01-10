#!/usr/bin/env bash

# get arguments into variable
arguments="$@"

# Get last argument as output path
output_path="${@: -1}"

# create regex pattern to split up arguments
pattern='(.*) -vcodec libx264 (.*)'

# do pattern search
if [[ "$arguments" =~ $pattern ]];then
  # construct new command from (.*) parts (BASH_REMATCH)
  command_str="/usr/local/bin/ffmpeg-real -hwaccel cuda -hwaccel_output_format cuda ${BASH_REMATCH[1]} -y -acodec libfdk_aac -c:v libx264 -threads 4 -f mp4 -movflags faststart -max_muxing_queue_size 1024 -map_metadata -1 -q:a 5 -vf scale_npp=w=1920:h=1080:interp_algo=super,hwdownload,format=nv12 -preset veryfast -maxrate:v 522240 -bufsize:v 522240 -bf 16 -r 30 -g:v 60 -gpu 0 ${output_path}"

  # execute new command
  $command_str
else
  # just execute ffmpeg with arguments if the pattern wasn't found
  /usr/local/bin/ffmpeg-real $@
fi
