# owspctl

owspctl is an open source cross-platform tool and framework to control China H264 NVR
using native binary mobile interface communication CPlayer+  compatible protocol (default port 15961)
(https://play.google.com/store/apps/details?id=cplayerAdd.com) called internally OWSP

## Usage

owspctl.pl --user username --pass password --host 192.168.0.1 --port 15961 --command <command> [--of <video output file>] [ --frames <number of frames> ]

supported commands:

|command | description |
|--|--|
video | download h264 video stream data (could be decoded by ffmpeg)
get_config_system | display system settings
get_config_network | display network settings

## Tested hardware

NGSPtech 16ch NVR (probably HiSilicon Hi3511)

## Author and License

Copyright (C) 2018 667bdrm
Dual licensed under GNU General Public License 2 and commercial license
Commercial license available by request



