# owspctl

owspctl is an open source cross-platform tool and framework to control Xinshijia H264 DVR over
owsp compatible protocol (CPlayer+, default port 15961, https://play.google.com/store/apps/details?id=cplayerAdd.com - not available now, mirror https://archive.org/details/cplayerAdd.com)

## Usage

owspctl.pl --user username --pass password --host 192.168.0.1 --port 15961 --command command [--of video_output_file ] [ --frames number_of_frames ]

supported commands:

|command | description |
|--|--|
video | download h264 video stream data (could be decoded by ffmpeg)
get_config_system | display system settings
get_config_network | display network settings

## Tested hardware

XSJ DN8416 16ch H264 DVR (SHENZHEN Xinshijia Technologies CO., LTD., HiSilicon Hi3520A,firmware version az5bixg.0309.0.4.1.30326)

## Author and License

Copyright (C) 2018 667bdrm
Dual licensed under GNU General Public License 2 and commercial license
Commercial license available by request



