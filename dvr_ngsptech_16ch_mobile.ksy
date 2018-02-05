meta:
  id: owsp
  file-extension: owsp
  endian: le

seq:
  - id: owsp_packet
    type: owsp_packet
    repeat: eos
    doc: >
        port 15961
        CPlayer+ android application
        16ch H264 DVR "NGSPtech"
types:
  owsp_packet:
    seq:
      - id: size
        type: u4be
      - id: seq
        type: u4
      - id: tlv_packets
        type: tlv_packets
        size: size - 4
        
  tlv_packets:
    seq:
      - id: tlv_packet
        type: tlv_packet
        repeat: eos
        
  tlv_packet:
    seq:
      - id: tlv_type
        type: u2
        enum: tlv_types
      - id: size
        type: u2
      - id: data
        size: size
        type: 
          switch-on: tlv_type
          cases:
            'tlv_types::version_request': version_info
            'tlv_types::login_request': login_request
            'tlv_types::dvsinfo_request': dvsinfo_request
            'tlv_types::channel_request': channel_request
            'tlv_types::channel_response': channel_response
            'tlv_types::stream_format_info_1': streamdata_format
            'tlv_types::stream_format_info_2': streamdata_format
            'tlv_types::stream_format_info_3': streamdata_format
            'tlv_types::video_frame_info': video_frame_info
            'tlv_types::ptz_control_request': ptz_control_request
            'tlv_types::ptz_control_response': ptz_control_response
            'tlv_types::audio_info_request': audio_info_request
            _: tlv_generic_binary
 
  dvsinfo_request:
    seq:
      - id: company_identity
        size: 16
        type: str
        encoding: ASCII
      - id: equipment_identity
        doc: mac address
        size: 16
      - id: equipment_name
        size: 16
        type: str
        encoding: ASCII
      - id: equipment_version
        size: 16
        type: str
        encoding: ASCII
  
  channel_request:
    seq:
      - id: device_id
        type: u4
      - id: source_channel
        type: u1
      - id: destination_channel
        type: u1
      - id: reserve
        type: u2
        
  channel_response:
    seq:
      - id: result
        type: u2
      - id: current_channel
        type: u1
      - id: reserve
        type: u1
        
  streamdata_format:
    seq:
      - id: video_channel
        type: u1
      - id: audio_channel
        type: u1
      - id: data_type
        type: u1
      - id: reserve
        type: u1
      - id: codec_id
        type: u4
        enum: codecs
      - id: video_bitrate
        type: u4
      - id: width
        type: u2
      - id: height
        type: u2
      - id: frame_rate
        type: u1
      - id: color_depth
        type: u1
      - id: videoframe_interval
        type: u1
      - id: video_reserve
        type: u1
      - id: samples_per_second
        type: u4
      - id: audio_bitrate
        type: u4
      - id: wave_format
        type: u2
      - id: channel_number
        type: u2
      - id: block_align
        type: u2
      - id: bits_per_sample
        type: u2
      - id: audioframe_interval
        type: u2
      - id: audio_reserve
        type: u2
        
  video_frame_info:
    seq:
      - id: channel_id
        type: u1
      - id: reserve
        type: u1
      - id: checksum
        type: u2
      - id: frame_index
        type: u4
      - id: time
        type: u4
  
  tlv_generic_binary:
    seq:
      - id: data
        size: _parent.size
        
  version_info:
    seq:
      - id: version_major
        type: u2
      - id: version_minor
        type: u2
        
  add_channel_stream_request:
    seq:
      - id: channel_mask
        type: u4 # or u2?
      - id: data_type
        type: u1
      - id: reserve
        type: u1
        
  add_channel_stream_respone:
    seq:
      - id: result
        type: u2
      - id: current_channel_mask
        type: u4
      - id: reserve
        type: u4
        
  alarm_push_config:
    seq:
      - id: device_id
        type: u4
      - id: server_url
        type: str
        size: 256
        encoding: ASCII
      - id: server_ip
        type: u4
      - id: server_port
        type: u2
      - id: enable
        type: u1
      - id: reserve
        type: u1
  
  ptz_control_request:
    seq:
      - id: device_id
        type: u4
      - id: channel
        type: u1
      - id: cmd_code
        type: u1
        enum: cmd_codes
      - id: size
        type: u2
  
  ptz_control_response:
    seq:
     - id: result
       type: u2
     - id: reserve
       type: u2
  
  audio_info_request:
    seq:
      - id: channel_id
        type: u1
      - id: reserve
        type: u1
      - id: checksum
        type: u2
      - id: time
        type: u4
  
  alarm_control:
    seq:
      - id: device_id
        type: u4
      - id: channel
        type: u1
      - id: command
        type: u1
      - id: mode
        type: u1
      - id: reserve
        type: u1
        
  alarm_control_response:
    seq:
      - id: result
        type: u2
      - id: reserve
        type: u2
        
  login_request:
    seq:
      - id: username
        size: 32
        type: str
        encoding: ASCII
      - id: password
        size: 16
        type: str
        encoding: ASCII
      - id: device_id
        type: u4
      - id: flag
        type: u1
      - id: channel
        type: u1
      - id: reserved
        size: 2
      
  login_response:
    seq:
      - id: result
        type: u2
      - id: reserve
        type: u2
        
  
  search_file_request:
    seq:
      - id: device_id
        type: u4
      - id: channel_mask
        type: u4
      - id: sm_microsecond
        type: u4
      - id: sm_year
        type: u4
      - id: sm_month
        type: u4
      - id: sm_day
        type: u4
      - id: sm_hour
        type: u4
      - id: sm_minute
        type: u4
      - id: sm_second
        type: u4
      - id: em_microsecond
        type: u4
      - id: em_year
        type: u4
      - id: em_month
        type: u4
      - id: em_day
        type: u4
      - id: em_hour
        type: u4
      - id: em_minute
        type: u4
      - id: em_second
        type: u4
      - id: record_type_mask
        type: u4
      - id: index
        type: u4
      - id: count
        type: u4
      - id: reserve
        type: u4
  
  search_file_response:
    seq:
      - id: result
        type: u1
      - id: count
        type: u1
      - id: reserve
        type: u1
        
  system_request:
    seq:
      - id: device_id
        type: u4
      - id: device_name
        type: str
        encoding: ASCII
        size: 32
      - id: hd_overwrite
        type: u1
      - id: video_format
        type: u1
      - id: language
        type: u1
      - id: date_format
        type: u1
      - id: time_format
        type: u1
      - id: reserve
        size: 3
  
enums:
  tlv_types:
    0x0027: version_2_request
    0x0028: version_request
    0x0029: login_request
    0x002a: login_response
    0x002c: streamdata_request
    0x002f: stopstreamdata_request
    0x0033: ptz_control_request
    0x0034: ptz_control_response
    0x0040: channel_request
    0x0041: channel_response
    0x0046: dvsinfo_request
    0x0061: audio_info_request
    0x0062: audio_data
    0x0063: video_frame_info
    0x0064: video_iframe_info
    0x0066: video_pframe_info
    0x0068: video_iframe_data
    0x0070: video_pframe_data
    0x0074: video_iframe_data_1
    0x0076: video_pframe_data_1
    0x00c7: stream_format_info_1
    0x00c8: stream_format_info_2
    0x00c9: stream_format_info_3 
    0x012d: config_cameracolor
    0x0132: record_request
    0x0133: config_videoencode
    0x0134: audioencode
    0x0135: config_network
    0x0137: system_config
    0x0139: config_alarmpush
    0x014b: talk_request
    0x014d: searchrecord_request
    0x0150: playrecord_request
    0x0155: alarmcontrol
    
  config_types:
    0x0191: config_cameracolor
    0x019b: config_record
    0x019d: config_videoencode
    0x019f: config_audioencode
    0x01a1: config_network
    0x01a5: config_system
    
  codecs:
    0x34363248: h264
  
  trans_err_code:
    0x00: err_none
    0x10: err_unknown
    0x11: err_conn
    0x12: err_network
    0x13: err_user_pass
    0x14: err_check_mode_fail
    0x15: err_frame_info
    0x16: err_chan_switch

  trans_state:
    0x0: trans_state_err
    0x1: trans_state_wait
    0x2: trans_state_unconn
    0x3: trans_state_run
    0x4: err_old_version
    0x5: change_channel_succ

  cmd_codes:
    0x0: stop
    0x5: zoom_out
    0x6: zoom_in
    0x7: focus_inc
    0x8: focus_dec
    0x9: direct_up
    0xa: direct_down
    0xb: direct_left
    0xc: direct_right
    0xd: aperture_dec
    0xe: aperture_inc
    
    
        