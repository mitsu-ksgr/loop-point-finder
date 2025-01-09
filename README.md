Loop point finder
=================

Find a frame that can be used as a loop point in a video
that looks like it could be looped.


## Installation (dev)

```sh
$ git clone git@github.com:mitsu-ksgr/loop-point-finder.git
```

### Requires
- numpy
- opencv
- ffmpeg (for helper scripts)

### venv
```sh
$ python -m venv venv
$ source ./venv/bin/activate
```

### pip install
```sh
$ pip install .
```


## How to use
```sh
# show help
$ python src/main.py -h

# Basic
$ python src/main.py video.mp4
Similar frame: 123

# With options
# -bs ... base frame
# -sf ... skip frames
# -st ... similarity-threshold"
$ python src/main.py -bs 0 -sf 3000 -st 0.995 video.mp4
Similar frame: 4567
```

### Trim video with frame index.
```sh
$ ./jig/trim-video.sh video.mp4 4567
```



