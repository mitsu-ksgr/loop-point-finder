#!/usr/bin/env bash
#
# Print FPS of the video.
#
set -eu

readonly video_path="${1:-}"

err() {
    echo -e "$@" 1>&2
    exit 1
}

if [ "${video_path}" == "" ]; then
    err "Error: video-path is not specified."
fi

if [ ! -f "${video_path}" ]; then
    err "Error: Video file not found: ${video_path}"
fi

if command -v "ffprobe" >/dev/null 2>&1; then
    : # OK
else
    err "Error: ffprobe is not available. Please install ffmpeg."
fi


ffprobe -v error \
    -select_streams v:0 \
    -show_entries stream=r_frame_rate \
    -of default=noprint_wrappers=1:nokey=1 \
    "${video_path}"


