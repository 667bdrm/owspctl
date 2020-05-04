meta:
  id: xsj_netviewer
  file-extension: xsj_netviewer
  endian: be
seq:
  - id: netviewer_packet
    type: netviewer_packet
    repeat: eos
    doc: >
        port 9000
        Xinshijia NetViewer_DN.exe application
        Tested with 16ch Xinshijia DN8416 h264 dvr
types:
  netviewer_packet:
    seq:
      - id: magic
        type: u2
        enum: protocols
      - id: command_code
        type: u2
        enum: command_codes
        doc: >
           2 bytes, first - packet type, second - packet parameters, 
           for stream data parameter - channel number
      - id: size
        type: u4
      - id: data
        type:
          switch-on: command_code
          cases:
            'command_codes::ptz': ptz_request
            'command_codes::search': search_request
            'command_codes::login_resp': login_response
            'command_codes::login': login_request
            'command_codes::unknown_x6101_req': generic_req
            'command_codes::disconnect_req': generic_req
            'command_codes::data_ch00': data_channel_resp
            'command_codes::data_ch01': data_channel_resp
            'command_codes::data_ch02': data_channel_resp
            'command_codes::data_ch03': data_channel_resp
            'command_codes::data_ch04': data_channel_resp
            'command_codes::data_ch05': data_channel_resp
            'command_codes::data_ch06': data_channel_resp
            'command_codes::data_ch07': data_channel_resp
            'command_codes::data_ch08': data_channel_resp
            'command_codes::data_ch09': data_channel_resp
            'command_codes::data_ch10': data_channel_resp
            'command_codes::data_ch11': data_channel_resp
            'command_codes::data_ch12': data_channel_resp
            'command_codes::data_ch13': data_channel_resp
            'command_codes::data_ch14': data_channel_resp
            'command_codes::data_ch15': data_channel_resp
            'command_codes::keep_alive': generic_req
            'command_codes::btn_archive_stop': generic_req
            'command_codes::unknown_x0315_req': generic_req
            'command_codes::get_settings_req': generic_req
            'command_codes::unknown_x0704_req': generic_req
            'command_codes::login_x02ff_req': login_request
            'command_codes::search_resp': generic_resp
            'command_codes::system_info': system_info
            'command_codes::get_settings_resp': netviewer_settings
            'command_codes::save_config': netviewer_settings
            _: generic_resp

      
  search_request:
    seq:
      - id: channel
        type: u4
      - id: unknown
        type: u4
      - id: time
        type: u4
      - id: unknown1
        type: u4
  
  ptz_request:
    seq:
      - id: unknown
        type: u4
      - id: unknown2
        type: u8
      - id: ptz_cmd_code
        type: u2
        enum: ptz_commands
      - id: channel
        type: u1
      - id: unknown3
        type: u1

  login_request:
    seq:
      - id: unknown
        size: 3
      - id: stream_id
        type: u1
        enum: streams
      - id: username
        size: 8
        type: strz
        encoding: ASCII
      - id: password
        type: strz
        size: 8
        encoding: ASCII
        
  
  login_response:
    seq:
      - id: response_code
        type: u2le
        enum: login_responses
      - id: unknown1
        type: u2
      - id: version2
        size: 4
      - id: unknown22
        type: u1
      - id: cpu_model
        type: u2
      - id: mainboard_model
        type: u2
      - id: unknown3
        type: u4
      - id: channel_count
        type: u1
      - id: audio_channel_count
        type: u1
      - id: unknown4
        size: 2
      - id: timestamp
        type: u4
        doc: maybe server time
      - id: unknown6
        size: 8
      - id: storage
        type: strz
        encoding: ASCII
        size: 7
      - id: unknown7
        size: 38
        
  system_info:
    seq:
      - id: version1
        size: 4
        doc: maybe min NetViewer client version
      - id: version2
        size: 4
        doc: maybe NetViewer client version
      - id: unknown3
        type: u1
      - id: cpu_model
        type: u2
      - id: mainboard_model
        type: u2
      - id: unknown4
        type: u4
      - id: channel_count
        type: u1
      - id: audio_channel_count
        type: u1
      - id: unknown5
        size: 2
      - id: timestamp
        type: u4
        doc: maybe hdd format date
      - id: unknown7
        size: 8
      - id: storage
        size: 7
        type: strz
        encoding: ASCII

  data_channel_resp:
    seq:
      - id: unknown
        type: u2
      - id: sequence
        type: u2
      - id: unknown_mask
        type: u4
      - id: frame_id
        type: u2
        doc: 0 - initial frame, 1 - next
      - id: unknown4
        type: u1
      - id: channel
        type: u1
      - id: magic
        type: u2
      - id: data
        type:
          switch-on: magic
          cases:
            0x5471: event_data
            _: generic_data
            
  event_data:
    seq:
      - id: command
        enum: command_codes
        type: u2
      - id: size
        type: u4be
      - id: unknown01
        size: 40
      - id: frame_index
        type: u1
      - id: channel
        type: u1
      - id: unknown02
        size: 5
      - id: timestamp
        type: u4le
      - id: unknown1
        size: 7
      - id: stream_size
        type: u4le
      - id: unknown2
        size: 54
      - id: h264_data
        size: _parent._parent.size - 144

  netviewer_settings:
    seq:
      - id: unknown
        size: 39
      - id: firmware_version
        size: 32
        type: strz
        encoding: ASCII
      - id: channel_settings
        type: channel_settings
        size: 540
        repeat: expr
        repeat-expr: 17
        doc: >
          last channel - all channel common settings
      - id: unknown2
        size: 57
      - id: ip_mode
        type: u1
        enum: ip_modes
      - id: server_port
        type: u2le
        doc: NetViewer port
      - id: mobile_port
        type: u2le
        doc: OWSP app port
      - id: web_port
        type: u2le
      - id: mac
        size: 6
      - id: ip
        type: u4
      - id: netmask
        type: u4
      - id: default_gateway
        type: u4
      - id: primary_dns
        type: u4
      - id: secondary_dns
        type: u4
      - id: unknown3
        size: 1749
      - id: ftp_server
        type: strz
        encoding: ASCII
        size: 30
      - id: unknown4
        size: 20
      - id: ftp_port
        type: u2le
      - id: ftp_username
        type: strz
        encoding: ASCII
        size: 30
      - id: unknown5
        size: 20
      - id: ftp_password
        type: strz
        encoding: ASCII
        size: 30
      - id: unknown6
        size: 479
        
  channel_settings:
    seq:
      - id: channel
        type: u1
      - id: title
        size: 8
        type: strz
        encoding: ASCII
      - id: unknown
        size: 17
      - id: ptz_protocol
        type: u1
        enum: ptz_protocols
      - id: ptz_address
        type: u1
      - id: unknown2
        size: 1
      - id: baudrate
        type: u1
        enum: baudrates
      - id: contrast
        type: u1
      - id: brightness
        type: u1
      - id: hue
        type: u1
      - id: saturation
        type: u1
      - id: sharpness
        type: u1
      - id: motion
        type: u1
        enum: on_off_switch
      - id: sensitivity
        type: u1
      - id: unknown3
        size: 3
      - id: motion_detection_matrix
        type: motion_detection_matrix
        size: 144
        doc: >
           matrix 22x18 bits
      - id: unknown4
        size: 144
        doc: >
           possible another matrix 22x18 bits
      - id: buzzer_time
        type: u1
      - id: alarm_time
        type: u1
      - id: unknown5
        type: u1
      - id: fps
        type: u1
      - id: sub_fps
        type: u1
      - id: quality
        type: u1
        enum: quality
        doc: video stream quality
      - id: audio
        type: u1
        enum: on_off_switch
      - id: record_mode
        type: u1
        enum: record_modes
      - id: unknown7
        size: 2
      - id: record_bitrate
        type: u1
        enum: record_bitrates
      - id: title_overlay
        type: u1
        enum: on_off_switch
      - id: time_overlay
        type: u1
        enum: on_off_switch
      - id: unknown8
        size: 1
      - id: post_rec_time
        type: u1
      - id: unknown9
        type: u1
      - id: record_schedule_matrix
        type: record_schedule_matrix
        size: 168
        doc: >
          matrix 24 x 7 (monday - first day)
      - id: unknown10
        size: 1
      - id: rot_time
        type: u1
      - id: unknown11
        size: 26
          
  motion_detection_row:
    seq:
      - id: detection_area
        type: u4
        doc: >
          bit field, each row has 22 square sectors; one bit per sector 
          0 - no detection in sector
          1 - detection in sector
          FF FF FF 3f - detectiob within all row sectors from left to right
      - id: unknown
        size: 4
        
  motion_detection_matrix:
    seq:
      - id: rows
        type: motion_detection_row
        repeat: expr
        repeat-expr: 18
        
  record_schedule_matrix:
    seq:
      - id: days
        type: record_schedule_day
        repeat: expr
        repeat-expr: 7
      
  record_schedule_day:
    seq:
      - id: record_hour_settings
        type: u1
        enum: record_schedule_settings
        repeat: expr
        repeat-expr: 24
        
  generic_data:
    seq:
      - id: data
        size: _parent._parent.size - 22
        
  generic_req:
    seq:
      - id: data
        size: _parent.size
        
  generic_resp:
    seq:
      - id: data
        size: _parent.size - 8
        doc: >
          size for req, size - 8 for resp
        
enums:
  baudrates:
    0x01: bps_50
    0x02: bps_75
    0x03: bps_110
    0x04: bps_134
    0x05: bps_150
    0x06: bps_200
    0x07: bps_300
    0x08: bps_600
    0x09: bps_1200
    0x0a: bps_1800
    0x0b: bps_2400
    0x0c: bps_4800
    0x0d: bps_9600
    0x0e: bps_19200
    0x0f: bps_38400
    0x10: bps_57600
    0x11: bps_115200
    0x12: bps_230400
    
  quality:
    0: low
    1: standard
    2: high
    3: highest
    
  on_off_switch:
    0: off
    1: on

  record_modes:
    0: off
    1: always
    2: motion
    3: sensor
    4: schedule
    
  record_schedule_settings:
    0x00: cancel
    0x01: always
    0x02: motion
    0x04: sensor
    
  record_bitrates:
    4: low
    5: standard
    6: high
    7: highest

  ptz_protocols:
    0: pelco_d
    1: pelcod1
    2: pelcod1_t
    3: pelcod_t
    4: pelcod_don
    5: pelcod_s1
    6: pelcod_s
    7: pelco_p
    8: pelcop1
    9: pelcop5
    10: pelcop_hk
    11: ad1641m
    12: admatrix
    13: banknote
    14: dh_cc440
    15: dh_matrix
    16: dh_sd1
    17: dh_sd2
    18: eptz
    19: haiyu
    20: hy
    21: lilin
    22: mercer_1
    23: panasonic
    24: pe5051k
    25: pelco_9750
    26: pelcoascii
    27: philips
    28: pih_717
    29: qt_2xxd
    30: rm110a
    31: sae
    32: samsung
    33: sanli
    34: santachi
    35: sharp
    36: sony
    37: wv_cs850i
    38: wv_cs850ii
    39: wv_cs950
    40: yaan
    41: general
    42: pelcod0

  ptz_commands:
    0x1001: audio_on
    0x1101: audio_off
    0x1104: unknown_x1104
    0x3101: left
    0x3201: right
    0x3301: up
    0x3401: down
    0x3501: zoom_in
    0x3601: zoom_out
    0x3701: focus_out
    0x3801: focus_in
    0x3901: stop
    0x4001: patrol
    
  ip_modes:
    1: static
    2: dhcp

  command_codes:
    0x0200: login
    0x0201: login_resp
    0x02ff: login_x02ff_req
    0x0301: ptz
    0x0315: unknown_x0315_req
    0x0602: search
    0x0704: disconnect_req
    0x0901: get_settings_resp
    0x0915: get_settings_req
    0x0a01: save_config
    0x1102: btn_archive_stop
    0x6101: unknown_x6101_req
    0x6200: data_ch00
    0x6201: data_ch01
    0x6202: data_ch02
    0x6203: data_ch03
    0x6204: data_ch04
    0x6205: data_ch05
    0x6206: data_ch06
    0x6207: data_ch07
    0x6208: data_ch08
    0x6209: data_ch09
    0x620a: data_ch10
    0x620b: data_ch11
    0x620c: data_ch12
    0x620d: data_ch13
    0x620e: data_ch14
    0x620f: data_ch15
    0x9171: btn_rec
    0x9172: btn_stop
    0xcbcb: keep_alive
    0xcc03: system_info
    0xee01: search_resp
    
  packet_types:
    0x02: login
    0x03: ptz
    0x06: search
    0x07: disconnect
    0x09: get_settings
    0x0a: save_settings
    0x11: btn_archive_stop
    0x61: unknown_x6101
    0x62: stream_data
    0x91: control
    0xcb: keep_alive
    0xcc: system_info
    0xee: search_results
    
  login_responses:
    0x0001: login_ok
    0x00fe: bad_password
    0x00ff: bad_username
    
  streams:
    0x00: main_stream
    0x01: sub_stream
    
  protocols:
    0x5471: proto_netviewer