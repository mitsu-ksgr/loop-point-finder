import os

import cv2
import numpy as np



def _calc_histogram(frame):
    """
    Calculate the histogram of a frame.
    """
    # Convert the frame to grayscale.
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

    # Calculate the histogram.
    hist = cv2.calcHist([gray], [0], None, [256], [0, 256])

    # Normalize the histogram.
    cv2.normalize(hist, hist)

    return hist



class LoopPointFinder:
    """
    Find the loop point in the video.
    """

    def __init__(
            self,
            video_path: str,
            base_frame: int = 0,
            skip_frames: int = 0,
            similarity_threshold: float = 0.95,
            is_debug: bool = False,
            ):
        self.video_path = video_path
        self.base_frame_idx = base_frame
        self.sim_thr = similarity_threshold
        self.skip_frames = skip_frames
        self.is_debug = is_debug


    def search(self) -> tuple[bool, str, int]:
        if self.is_debug:
            print(f"LPF: {self.video_path}")

        cap = cv2.VideoCapture(self.video_path)

        # Load first frame.
        f_idx = 0
        ret, base_frame = cap.read()
        if not ret:
            cap.release()
            return False, f"Error: Failed to read video: {self.video_path}", -1

        # Skip to base frame.
        if self.base_frame_idx >= 1:
            for i in range(self.base_frame_idx - 1):
                f_idx += 1
                ret, f = cap.read()
                if not ret:
                    cap.release()
                    return False, f"Error: Failed to read base frame: BaseFrameIndex={self.base_frame_idx}, LastLoadFrameIndex={f_idx}", -1

            # Store base frame.
            f_idx += 1
            ret, base_frame = cap.read()
            if not ret:
                cap.release()
                return False, f"Error: Failed to read base frame: BaseFrameIndex={self.base_frame_idx}, LastLoadFrameIndex={f_idx}", -1

        base_hist = _calc_histogram(base_frame)

        # Search similar frame.
        skip_frame_idx = self.base_frame_idx + self.skip_frames
        found_idx = -1
        while True:
            f_idx += 1
            f_idx_s = str(f_idx).zfill(5)

            # Get next frame
            ret, frame = cap.read()
            if not ret:
                break # End of video.

            # Skip?
            if f_idx <= skip_frame_idx:
                if self.is_debug:
                    print(f"LPF#search: Frame{f_idx_s} - skipped.")
                continue

            # Compare
            hist = _calc_histogram(frame)
            sim = cv2.compareHist(base_hist, hist, cv2.HISTCMP_CORREL)
            if self.is_debug:
                print(f"LPF#search: Frame{f_idx_s} = {sim}")

            if sim >= self.sim_thr:
                found_idx = f_idx
                break
            # end while.


        if self.is_debug:
            if found_idx == -1:
                print(f"LPF#search: No similar frame found. (Thr={self.sim_thr})")
            else:
                print(f"LPF#search: Similar frame found! Frame{found_idx}.")

        return True, "", found_idx


