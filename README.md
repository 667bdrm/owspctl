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

Example:

$ owspctl.pl --user admin --pass test --port 15961 --host 192.168.0.1 --command video --of test.h264 --frames 30 --channel 0

$ ffmpeg -i test.h264  -frames 1 -ss 0.5 -f image2 -qscale:v 2 test_%03d.jpg


nvserver.pl -  This tool emulates NetViewer_Dn.exe XSJ DVR control app server (default tcp port 9000) for testing dvr control app or develop alternative version

Usage: ./nvserver.pl --user test --port 9000

Connect original app to 127.0.0.1:9000, use any login/password pair


## Tested hardware

XSJ DN8416 16ch H264 DVR (SHENZHEN Xinshijia Technologies CO., LTD., HiSilicon Hi3520A, firmware version 8416_v1.0_121122 rootfs_dn8316_v0402 az5bixg.0309.0.4.1.30326)

## Help needed

If you have NetViewer app compatible NVR, firmware dump, source code, know someone who sell it, please let me know. My last device died after years of operation and research so I have no equipment to continue development that tool.


## Author and License

Copyright (C) 2018-2020 667bdrm
Dual licensed under GNU General Public License 2 and commercial license
Commercial license available by request



