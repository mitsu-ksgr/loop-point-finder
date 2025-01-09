import argparse
import os
import sys

from lpf import LoopPointFinder



def err(message: str):
    sys.stderr.write(message + "\n")
    sys.exit(1)


def parse_args():
    p = argparse.ArgumentParser(
        description = "Find the loop point in the video."
    )

    # Arguments
    p.add_argument("video_path", help="Path to the video file.")
    p.add_argument("-d", "--debug", action="store_true", help="Enable debug mode.")
    p.add_argument("-bf", "--base-frame", type=int, default=0, help="The base frame index.")
    p.add_argument("-sf", "--skip-frames", type=int, default=60, help="The number of frames to skip from the base frame.")
    p.add_argument("-st", "--similarity-threshold", type=float, default=0.95, help="The similarity threshold.")

    return p.parse_args()


def main(args):
    if args.debug:
        print(f"Video Path: {args.video_path}")
        print("")
        print("* Params")
        print(f"Base frame index      : {args.base_frame}")
        print(f"Skip frames           : {args.skip_frames}")
        print(f"Similarity Threashold : {args.similarity_threshold}")
        print("")

    if os.path.isfile(args.video_path):
        pass
    else:
        err(f"Error: file not found: {args.video_path}.")

    finder = LoopPointFinder(
        args.video_path,
        args.base_frame,
        args.skip_frames,
        args.similarity_threshold,
        args.debug)

    ret, msg, idx = finder.search()
    if ret:
        pass
    else:
        err(msg)

    if idx == -1:
        print(f"No similar frame found.")
    else:
        print(f"Similar frame: {idx}")


if __name__ == "__main__":
    args = parse_args()
    main(args)


