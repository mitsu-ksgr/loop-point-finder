#!/usr/bin/env bash
#
# Trim video.
#
set -eu

readonly SCRIPT_NAME=$(basename $0)

readonly DEFAULT_ENCODE_FLAG_VIDEO="libx264"
readonly DEFAULT_ENCODE_FLAG_AUDIO="aac"


#------------------------------------------------------------------------------
# Utils
#------------------------------------------------------------------------------
usage() {
    cat << __EOS__
Usage:
    ${SCRIPT_NAME} [OPTIONS] INPUT_VIDEO_PATH FRAME_INDEX [OUTPUT_PATH]

OPTIONS:
    -h  Show help.
    -c  Copy the stream from input to output without re-encoding.
    -s  Specify the start frame. default is 0.

OUTPUT_PATH:
    Specify the output path.
    default path is "{input_video_path}-loop.{input_video_ext}".

__EOS__
}

err() {
    echo -e "$@" 1>&2
    usage
    exit 1
}

check_ffmpeg() {
    if command -v "ffmpeg" >/dev/null 2>&1; then
        : #OK
    else
        err "Error: ffmpeg is not installed."
    fi
}



#------------------------------------------------------------------------------
# Options
#------------------------------------------------------------------------------
OPT_START_FRAME="00.00"
OPT_COPY="false"

parse_args() {
    while getopts hcs:t: flag; do
        case "${flag}" in
            h )
                usage
                exit 0
                ;;

            c )
                OPT_COPY="true"
                ;;

            s )
                OPT_START_FRAME="${OPTARG}"
                ;;
        esac
    done
}


#------------------------------------------------------------------------------
# Main process
#------------------------------------------------------------------------------
get_fps() {
    local readonly video_path="${1:-}"
    local readonly fps=$(
        ffprobe -v error \
            -select_streams v:0 \
            -show_entries stream=r_frame_rate \
            -of default=noprint_wrappers=1:nokey=1 \
            "${video_path}" |
            cut -f 1 -d '/'
    )
    echo "${fps}"
}

frame2sec() {
    local readonly frame="${1:-}"
    local readonly fps="${2:-}"
    local readonly sec=$(echo "scale=2; ${frame} / ${fps}" | bc)
    printf "%.2f\n" "${sec}"
}

make_output_path() {
    local readonly input_path="${1:-}"
    local readonly base="${input_path%.*}"
    local readonly ext="${input_path##*.}"
    echo "${base}-loop.${ext}"
}

main() {
    check_ffmpeg

    parse_args $@
    shift `expr $OPTIND - 1`

    # Positional args.
    local readonly video_path="${1:-}"
    local readonly frame_idx="${2:-}"
    local output_path="${3:-}"
    if [ -z "${output_path}" ]; then
        output_path=$(make_output_path "${video_path}")
    fi
    readonly output_path

    # Validation
    if [ ! -f "${video_path}" ]; then
        err "Error: Video file not found: ${video_path}"
    fi

    if [ "${frame_idx}" == "" ]; then
        err "Error: Cut frame index is not found."
    fi

    # Params
    local readonly fps=$(get_fps "${video_path}")
    local readonly ss=$(frame2sec "${OPT_START_FRAME}" "${fps}")
    local readonly to=$(frame2sec "${frame_idx}" "${fps}")

    # Debug
    #echo "Video Path  : ${video_path}"
    #echo "Output Path : ${output_path}"
    #echo "Frame Index : ${frame_idx}"
    #echo "Video FPS   : ${fps}"
    #echo "Opt - Copy  : ${OPT_COPY}"
    #echo "Opt - SS    : ${OPT_START_FRAME}"
    #echo "Trim range  : ${ss} ~ ${to}"

    # Flags
    local c_video="${DEFAULT_ENCODE_FLAG_VIDEO}"
    local c_audio="${DEFAULT_ENCODE_FLAG_AUDIO}"
    if [ "${OPT_COPY}" == "true" ]; then
        c_video="copy"
        c_audio="copy"
    fi
    readonly c_video
    readonly c_audio

    # Trim
    ffmpeg -i "${video_path}" \
        -ss "${ss}" -to "${to}" \
        -c:v "${c_video}" -c:a "${c_audio}" \
        "${output_path}"

    echo "Succeeded: ${output_path}"
}


main $@
exit 0

