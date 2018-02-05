#!/usr/bin/perl

# owspctl
#
# owspctl is an open source cross-platform tool and framework to control China H264 NVR
# using native binary mobile interface communication CPlayer+  compatible protocol (default port 15961)
# (https://play.google.com/store/apps/details?id=cplayerAdd.com) called internally OWSP
#
## Usage
#
# owspctl.pl --user username --pass password --host 192.168.0.1 --port 15961 --command <command> [--of <video output file>] [ --frames <number of frames> ]
#
# supported commands:

# video - download h264 video stream data (could be decoded by ffmpeg)
# get_config_system - display system settings
# get_config_network - display network settings
#
## Tested hardware
#
# NGSPtech 16ch NVR (probably HiSilicon Hi3511)
#
## Author and License

# Copyright (C) 2018 667bdrm
# Dual licensed under GNU General Public License 2 and commercial license
# Commercial license available by request


package Owsp;




use Module::Load::Conditional qw[can_load check_install requires];

my $use_list = {
 'IO::Socket'        => undef,
 'IO::Socket::INET'  => undef,
 'Time::Local'       => undef,
 'Data::Dumper'      => undef,
 'Time::Piece'   => undef,
 'Time::Local'   => undef,
 'Socket' => undef,
};

if (!can_load( modules => $use_list, autoload => true )) {
  die('Failed to load required one of modules: ' . join(', ', keys %{$use_list}));
}

use constant {
    TLV_T_ALARM_CONTROL_REQ => 0x0155,
    TLV_T_ALARM_CONTROL_RSP => 0x0156,
    TLV_T_ALARM_PUSH_CONFIG_GET_REQ => 0x01a7,
    TLV_T_ALARM_PUSH_CONFIG_GET_RSP => 0x01a8,
    TLV_T_ALARM_PUSH_SET_REQ => 0x0139,
    TLV_T_AUDIO_DATA => 0x0062,
    TLV_T_AUDIO_ENCODE_CONFIG_GET_REQ => 0x019f,
    TLV_T_AUDIO_ENCODE_CONFIG_GET_RSP => 0x01a0,
    TLV_T_AUDIO_ENCODE_CONFIG_SET_REQ => 0x0134,
    TLV_T_AUDIO_INFO => 0x0061,
    TLV_T_CAMERA_COLOR_CONFIG_GET_REQ => 0x0191,
    TLV_T_CAMERA_COLOR_CONFIG_GET_RSP => 0x0192,
    TLV_T_CAMERA_COLOR_CONFIG_SET_REQ => 0x012d,
    TLV_T_CHANNEL_VIDEO_REQ => 0x0160,
    TLV_T_CHANNEL_VIDEO_RSP => 0x0161,
    TLV_T_CONFIG_SET_RSP => 0x0138,
    TLV_T_CONTROL_REQ => 0x0033,
    TLV_T_CONTROL_RSP => 0x0034,
    TLV_T_DDNS_INFO_REQ => 0x004b,
    TLV_T_DDNS_INFO_RSP => 0x004c,
    TLV_T_DEVICE_INFO => 0x0046,
    TLV_T_DEVICE_INFO_RSP => 0x0047,
    TLV_T_DOWNLOAD_RECORD_REQ => 0x0152,
    TLV_T_DOWNLOAD_RECORD_RSP => 0x0153,
    TLV_T_EMAIL_CONFIG_GET_REQ => 0x01a3,
    TLV_T_EMAIL_CONFIG_GET_RSP => 0x01a4,
    TLV_T_EMAIL_CONFIG_SET_REQ => 0x0136,
    TLV_T_FILE_INFO => 0x014f,
    TLV_T_HIDE_DETECT_CONFIG_GET_REQ => 0x0195,
    TLV_T_HIDE_DETECT_CONFIG_GET_RSP => 0x0196,
    TLV_T_HIDE_DETECT_CONFIG_SET_REQ => 0x012f,
    TLV_T_KEEP_ALIVE_REQ => 0x0031,
    TLV_T_KEEP_ALIVE_RSP => 0x0039,
    TLV_T_LOGIN_REQ => 0x0029,
    TLV_T_LOGIN_RSP => 0x002a,
    TLV_T_LOSS_DETECT_CONFIG_GET_REQ => 0x0197,
    TLV_T_LOSS_DETECT_CONFIG_GET_RSP => 0x0198,
    TLV_T_LOSS_DETECT_CONFIG_SET_REQ => 0x0130,
    TLV_T_MOBILE_INFO_REQ => 0x0048,
    TLV_T_MOBILE_INFO_RSP => 0x0049,
    TLV_T_MOTION_DETECT_CONFIG_GET_REQ => 0x0193,
    TLV_T_MOTION_DETECT_CONFIG_GET_RSP => 0x0194,
    TLV_T_MOTION_DETECT_CONFIG_SET_REQ => 0x012e,
    TLV_T_NETWORK_CONFIG_GET_REQ => 0x01a1,
    TLV_T_NETWORK_CONFIG_GET_RSP => 0x01a2,
    TLV_T_NETWORK_CONFIG_SET_REQ => 0x0135,
    TLV_T_PLAY_RECORD_REQ => 0x0150,
    TLV_T_PLAY_RECORD_RSP => 0x0151,
    TLV_T_PTZ_PRESETS_REQ => 0x0157,
    TLV_T_PTZ_PRESETS_RSP => 0x0158,
    TLV_T_PTZ_PRESET_INFO => 0x0159,
    TLV_T_PTZ_TOURS_REQ => 0x015a,
    TLV_T_PTZ_TOURS_RSP => 0x015b,
    TLV_T_PTZ_TOUR_INFO => 0x015c,
    TLV_T_PTZ_TOUR_POINT_INFO => 0x015d,
    TLV_T_RECORD_CONFIG_GET_REQ => 0x019b,
    TLV_T_RECORD_CONFIG_GET_RSP => 0x019c,
    TLV_T_RECORD_CONFIG_SET_REQ => 0x0132,
    TLV_T_RECORD_EOF => 0x0162,
    TLV_T_SEARCH_FILE_REQ => 0x014d,
    TLV_T_SEARCH_FILE_RSP => 0x014e,
    TLV_T_SENSOR_ALARM_CONFIG_GET_REQ => 0x0199,
    TLV_T_SENSOR_ALARM_CONFIG_GET_RSP => 0x019a,
    TLV_T_SENSOR_ALARM_CONFIG_SET_REQ => 0x0131,
    TLV_T_STOP_STREAM_DATA_REQ => 0x002f,
    TLV_T_STOP_STREAM_DATA_RSP => 0x0030,
    TLV_T_STREAM_DATA_REQ => 0x002c,
    TLV_T_STREAM_DATA_RSP => 0x002d,
    TLV_T_STREAM_FILE_END_INFO => 0xffff,
    TLV_T_STREAM_FILE_INDEX_INFO => 0x00d5,
    TLV_T_STREAM_FILE_INFO => 0x00d6,
    TLV_T_STREAM_FORMAT_INFO => 0x00cb,
    TLV_T_STREAM_FORMAT_INFO2 => 0x00c7,
    TLV_T_STREAM_FORMAT_INFO3 => 0x00c8,
    TLV_T_SUSPEND_CHANNEL_REQ => 0x0042,
    TLV_T_SUSPEND_CHANNEL_RSP => 0x0043,
    TLV_T_SWITCH_CHANNEL_GROUP_REQ => 0x015e,
    TLV_T_SWITCH_CHANNEL_GROUP_RSP => 0x015f,
    TLV_T_SWITCH_CHANNEL_REQ => 0x0040,
    TLV_T_SWITCH_CHANNEL_RSP => 0x0041,
    TLV_T_SYSTEM_CONFIG_GET_REQ => 0x01a5,
    TLV_T_SYSTEM_CONFIG_GET_RSP => 0x01a6,
    TLV_T_SYSTEM_CONFIG_SET_REQ => 0x0137,
    TLV_T_TALK_REQ => 0x014b,
    TLV_T_TALK_RSP => 0x014c,
    TLV_T_VERSION_INFO => 0x0028,
    TLV_T_VERSION_INFO_RSP => 0x0027,
    TLV_T_VIDEO_ENCODE_CONFIG_GET_REQ => 0x019d,
    TLV_T_VIDEO_ENCODE_CONFIG_GET_RSP => 0x019e,
    TLV_T_VIDEO_ENCODE_CONFIG_SET_REQ => 0x0133,
    TLV_T_VIDEO_FRAME_INFO => 0x0063,
    TLV_T_VIDEO_FRAME_INFO_EX => 0x0066,
    TLV_T_VIDEO_IFRAME_DATA => 0x0064,
    TLV_T_VIDEO_PFRAME_DATA => 0x0065,
    _RESPONSECODE_CONFIG_ERROR => 0x000d,
    _RESPONSECODE_DEVICE_HAS_EXIST => 0x0007,
    _RESPONSECODE_DEVICE_OFFLINE => 0x0006,
    _RESPONSECODE_DEVICE_OVERLOAD => 0x0008,
    _RESPONSECODE_GET_DATA_FAIL => 0x0015,
    _RESPONSECODE_INVALID_CHANNLE => 0x0009,
    _RESPONSECODE_MAX_USER_ERROR => 0x0005,
    _RESPONSECODE_MEMORY_ERROR => 0x0011,
    _RESPONSECODE_NOT_START_ENCODE => 0x000b,
    _RESPONSECODE_NOT_SUPPORT_TALK => 0x000e,
    _RESPONSECODE_NOW_EXITING => 0x0014,
    _RESPONSECODE_NO_USER_ERROR => 0x0013,
    _RESPONSECODE_OVER_INDEX_ERROR => 0x0010,
    _RESPONSECODE_PDA_VERSION_ERROR => 0x0004,
    _RESPONSECODE_PROTOCOL_ERROR => 0x000a,
    _RESPONSECODE_QUERY_ERROR => 0x0012,
    _RESPONSECODE_RIGHT_ERROR => 0x0016,
    _RESPONSECODE_SUCC => 0x0001,
    _RESPONSECODE_TASK_DISPOSE_ERROR => 0x000c,
    _RESPONSECODE_TIME_ERROR => 0x000f,
    _RESPONSECODE_USER_PWD_ERROR => 0x0002,
    
    IPMODE_PPPOE   => 0x20,
    IPMODE_STATIC  => 0x40,
    IPMODE_DHCP    => 0x60,
    IPMODE_UNKNOWN => 0x80,


    BITRATE_25G    => 0x20,
    BITRATE_275G   => 0x40,
    BITRATE_3G     => 0x60,
    BITRATE_WIFI   => 0x80,

};

sub new {
  my $classname = shift;
  my $self = {};
  bless($self, $classname);
  $self->_init(@_);
  return $self;
}

sub DESTROY {
  my $self = shift;
}

sub disconnect {
 my $self = shift;
 $self->{socket}->close();
}

sub _init {
  my $self = shift;
  $self->{host}	= "";
  $self->{port}	= 0;
  $self->{user}	= ""; 
  $self->{password}	= ""; 
  $self->{socket} = undef;
  $self->{sid} = 0;  
  $self->{lastcommand} = undef;
  $self->{sequence} = 0;

  if (@_) {
   my %extra = @_;
   @$self{keys %extra} = values %extra;
  } 

}

package Owsp::LoginRequest;

sub new {
  my $classname = shift;
  my $self = {};
  bless($self, $classname);
  $self->_init(@_);
  return $self;
}

sub _init {
  my $self = shift;

    $self->{type} = 0x29;
    $self->{size} = 56;
    $self->{username} = '';
    $self->{password} = '';
    $self->{device_id} = 0;
    $self->{flag} = 0;
    $self->{channel} = 0;
    $self->{reserved} = 0;
    $self->{pkt_data} = undef;
	

  if (@_) {
   my %extra = @_;
   @$self{keys %extra} = values %extra;
  } 

}

sub username {
    my ($self, $username) = @_;
	$self->{username} = $username if defined($username);
    return $self->{username};
}

sub password {
    my ($self, $password) = @_;
	$self->{password} = $password if defined($password);
    return $self->{password};
}

sub device_id {
    my ($self, $device_id) = @_;
    $self->{device_id} = $device_id if defined($device_id);
    return $self->{device_id};
}

sub flag {
    my ($self, $flag) = @_;
	$self->{flag} = $flag if defined($flag);
    return $self->{flag};
}

sub channel {
    my ($self, $channel) = @_;
	$self->{channel} = $channel if defined($channel);
    return $self->{channel};
}

sub reserved {
    my ($self) = @_;
    return $self->{reserved};
}

sub encode {
    my ($self) = @_;
	
	$self->{pkt_data} = pack('ssZ32Z16ICCs', $self->{type}, $self->{size}, $self->{username},  $self->{password},  $self->{device_id},  $self->{flag},  $self->{channel}, $self->{reserved});
	$self->{size} = length($self->{pkt_data});
	
	return $self->{pkt_data};
}

sub decode {
   my ($self, $pkt_data) = @_;
   
  ($self->{type}, $self->{size}, $self->{username},  $self->{password},  $self->{device_id},  $self->{flag},  $self->{channel}, $self->{reserved}) = unpack('ssZ32Z16ICCs', $self->{pkt_data});
}

sub size  {
   my ($self) = @_;
   return $self->{size} + 4;
}


package Owsp::LoginResponse;

our @ISA = "Owsp::Generic";

sub new {
  my $classname = shift;
  my $self = {};
  bless($self, $classname);
  $self->_init(@_);
  return $self;
}

sub _init {
  my $self = shift;

    $self->{type} = 0x2a;
	$self->{size} = 4;
    $self->{result} = 0;
    $self->{reserve} = 0;
	$self->{pkt_data} = undef;
	

  if (@_) {
   my %extra = @_;
   @$self{keys %extra} = values %extra;
  } 

}

sub result {
    my ($self, $result) = @_;
	$self->{result} = $result if defined($result);
    return $self->{result};
}

sub reserve {
    my ($self, $reserve) = @_;
	$self->{reserve} = $reserve if defined($reserve);
    return $self->{reserve};
}

sub encode {
    my ($self) = @_;
	
	$self->{pkt_data} = pack('ssss', $self->{type}, $self->{size}, $self->{result},  $self->{reserve});
	$self->{size} = length($self->{pkt_data});
	
	return $self->{pkt_data};
}

sub decode {
   my ($self, $pkt_data) = @_;
   
  ($self->{type}, $self->{size}, $self->{result},  $self->{reserve}) = unpack('ssss', $self->{pkt_data});
}


sub dump {
  my $self=shift;
  my $ref=$self->SUPER::dump();
  print "Login result: ";
  if ($self->{result} == Owsp::_RESPONSECODE_SUCC) {
    print "success\n";
  } elsif ($self->{result} == Owsp::_RESPONSECODE_USER_PWD_ERROR) {
    print "bad user/pass\n";
  } else {
    print "unknown\n";
  }
}

sub size  {
   my ($self) = @_;
   return $self->{size} + 4;
}


package Owsp::Generic;
use Socket;

sub new {
  my $classname = shift;
  my $self = {};
  bless($self, $classname);
  $self->_init(@_);
  return $self;
}

sub _init {
  my $self = shift;

    $self->{type} = 0;
    $self->{size} = 4;
    $self->{pkt_data} = undef;
    $self->{video_file} = 'dump.h264';

  if (@_) {
   my %extra = @_;
   @$self{keys %extra} = values %extra;
  } 

}

sub decode_ip {
  my ($self, $value) = @_;
  
  return inet_ntoa(pack('N', $value));
}


sub encode_ip {
  my ($self, $value) = @_;
  
  return unpack('N',inet_aton($value));
}

sub pack_mac {
  my ($self, $value) = @_;
  
  my @mac_bytes = split('\:', $value);

  
  return pack('C6', map(hex, @mac_bytes));
}

sub unpack_mac {
  my ($self, $value) = @_;
  
  my @mac_bytes = unpack('C6', $value);
  
  my @final_bytes = map { sprintf("%02x", $_) } @mac_bytes;
  
  return join(':', @final_bytes);
}

sub encode {
    my ($self) = @_;
	
    #$self->{pkt_data} = pack('ssC*', $self->{type}, $self->{size}, $self->{version_major},  $self->{version_minor});
    #$self->{size} = length($self->{pkt_data});
	
    return $self->{pkt_data};
}

sub decode {
   my ($self, $pkt_data) = @_;
   
   my @data;
   
  ($self->{type}, $self->{size}, @data) = unpack('ssC*', $self->{pkt_data});
  
  print "Unparsed binary data: \n";
  foreach my $item (@data) {
    print sprintf("0x%02x ", $item);
  }
  print "\n";
}



sub dump {
  my $self = shift;
  
  foreach my $key (sort keys %{$self}) {
    if ($key ne 'pkt_data') {
      print sprintf("%s = %s\n", $key, $self->{$key});
    }
  }

}

sub format_timestamp {
    my $self = shift;
   
    my $timestamp = $_[0];
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($timestamp);
   
    return sprintf("%02d.%02d.%4d %02d:%02d:%02d",$mday,$mon+1,$year+1900,$hour,$min,$sec);
}

package Owsp::VersionInfo;

our @ISA = "Owsp::Generic";

sub new {
  my $classname = shift;
  my $self = {};
  bless($self, $classname);
  $self->_init(@_);
  return $self;
}

sub _init {
  my $self = shift;

    $self->{type} = 0x28;
	$self->{size} = 4;
    $self->{version_major} = 0;
    $self->{version_minor} = 0;
	$self->{pkt_data} = undef;
	

  if (@_) {
   my %extra = @_;
   @$self{keys %extra} = values %extra;
  } 

}

sub version_major {
    my ($self, $version_major) = @_;
	$self->{version_major} = $version_major if defined($version_major);
    return $self->{version_major};
}

sub version_minor {
    my ($self, $version_minor) = @_;
	$self->{version_minor} = $version_minor if defined($version_minor);
    return $self->{version_minor};
}

sub encode {
    my ($self) = @_;
	
	$self->{pkt_data} = pack('ssss', $self->{type}, $self->{size}, $self->{version_major},  $self->{version_minor});
	$self->{size} = length($self->{pkt_data});
	
	return $self->{pkt_data};
}

sub decode {
   my ($self, $pkt_data) = @_;
   
  ($self->{type}, $self->{size}, $self->{version_major},  $self->{version_minor}) = unpack('ssss', $self->{pkt_data});
}


sub size  {
   my ($self) = @_;
   return $self->{size} + 4;
}

package Owsp::DvsinfoRequest;

our @ISA = 'Owsp::Generic';

sub new {
  my $classname = shift;
  my $self = {};
  bless($self, $classname);
  $self->_init(@_);
  return $self;
}


sub _init {
  my $self = shift;

    $self->{type} = 0x46;
    $self->{size} = 64;
    $self->{company_identity} = '';
    $self->{equipment_identity} = 0;
    $self->{equipment_name} = '';
    $self->{equipment_version} = '';

    $self->{pkt_data} = undef;
	

  if (@_) {
   my %extra = @_;
   @$self{keys %extra} = values %extra;
  } 

}

sub company_identity {
    my ($self, $value) = @_;
    $self->{company_identity} = $value if defined($value);
    return $self->{company_identity};
}

sub equipment_identity {
    my ($self, $value) = @_;
    $self->{equipment_identity} = $value if defined($value);
    return $self->{equipment_identity};
}

sub equipment_name {
    my ($self, $value) = @_;
    $self->{equipment_name} = $value if defined($value);
    return $self->{equipment_name};
}

sub equipment_version {
    my ($self, $value) = @_;
    $self->{equipment_version} = $value if defined($value);
    return $self->{equipment_version};
}

sub encode {
    my ($self) = @_;
	
	$self->{pkt_data} = pack('ssZ16Z16Z16Z16', $self->{type}, $self->{size}, $self->{company_identity},  $self->{equipment_identity}, $self->{equipment_name}, $self->{equipment_version});
	$self->{size} = length($self->{pkt_data});
	
	return $self->{pkt_data};
}

sub decode {
   my ($self, $pkt_data) = @_;
   my $pkt_data = IO::String->new($self->{pkt_data});
   
   my $tmp;
   my $tmp1;
   
   $pkt_data->sysread($tmp, 20);
   $pkt_data->sysread($tmp, 16);
   
   my @eq_id = unpack('C16', $tmp);
   
   print "equipment_identity:\n";
   
   foreach my $byte (@eq_id) {
     print sprintf("0x%02x ", $byte);
   }
   
   print "\n";
   
   ($self->{type}, $self->{size}, $self->{company_identity},  $self->{equipment_identity}, $self->{equipment_name}, $self->{equipment_version}) = unpack('ssZ16Z16Z16Z16', $self->{pkt_data});
}


package Owsp::StreamdataFormat;

our @ISA = 'Owsp::Generic';

sub new {
  my $classname = shift;
  my $self = {};
  bless($self, $classname);
  $self->_init(@_);
  return $self;
}


sub _init {
  my $self = shift;

    $self->{type} = 0xc8;
    $self->{size} = 40;
    $self->{video_channel} = 0;
    $self->{audio_channel} = 0;
    $self->{data_type} = 0;
    $self->{reserve} = 0;
    $self->{codec_id} = 0;
    $self->{video_bitrate} = 0;
    $self->{width} = 0;
    $self->{height} = 0;
    $self->{frame_rate} = 0;
    $self->{color_depth} = 0;
    $self->{videoframe_interval} = 0;
    $self->{video_reserve} = 0;
    $self->{samples_per_second} = 0;
    $self->{audio_bitrate} = 0;
    $self->{wave_format} = 0;
    $self->{channel_number} = 0;
    $self->{block_align} = 0;
    $self->{bits_per_sample} = 0;
    $self->{audioframe_interval} = 0;
    $self->{audio_reserve} = 0;

    $self->{pkt_data} = undef;
	

  if (@_) {
   my %extra = @_;
   @$self{keys %extra} = values %extra;
  } 

}


sub video_channel {
    my ($self, $value) = @_;
    $self->{video_channel} = $value if defined($value);
    return $self->{video_channel};
}

sub audio_channel {
    my ($self, $value) = @_;
    $self->{audio_channel} = $value if defined($value);
    return $self->{audio_channel};
}

sub data_type {
    my ($self, $value) = @_;
    $self->{data_type} = $value if defined($value);
    return $self->{data_type};
}

sub reserve {
    my ($self, $value) = @_;
    $self->{reserve} = $value if defined($value);
    return $self->{reserve};
}

sub codec_id {
    my ($self, $value) = @_;
    $self->{codec_id} = $value if defined($value);
    return $self->{codec_id};
}

sub video_bitrate {
    my ($self, $value) = @_;
    $self->{video_bitrate} = $value if defined($value);
    return $self->{video_bitrate};
}

sub width {
    my ($self, $value) = @_;
    $self->{width} = $value if defined($value);
    return $self->{width};
}

sub height {
    my ($self, $value) = @_;
    $self->{height} = $value if defined($value);
    return $self->{height};
}

sub frame_rate {
    my ($self, $value) = @_;
    $self->{frame_rate} = $value if defined($value);
    return $self->{frame_rate};
}

sub color_depth {
    my ($self, $value) = @_;
    $self->{color_depth} = $value if defined($value);
    return $self->{color_depth};
}

sub videoframe_interval {
    my ($self, $value) = @_;
    $self->{videoframe_interval} = $value if defined($value);
    return $self->{videoframe_interval};
}

sub video_reserve {
    my ($self, $value) = @_;
    $self->{video_reserve} = $value if defined($value);
    return $self->{video_reserve};
}

sub samples_per_second {
    my ($self, $value) = @_;
    $self->{samples_per_second} = $value if defined($value);
    return $self->{samples_per_second};
}

sub audio_bitrate {
    my ($self, $value) = @_;
    $self->{audio_bitrate} = $value if defined($value);
    return $self->{audio_bitrate};
}

sub wave_format {
    my ($self, $value) = @_;
    $self->{wave_format} = $value if defined($value);
    return $self->{wave_format};
}

sub channel_number {
    my ($self, $value) = @_;
    $self->{channel_number} = $value if defined($value);
    return $self->{channel_number};
}

sub block_align {
    my ($self, $value) = @_;
    $self->{block_align} = $value if defined($value);
    return $self->{block_align};
}

sub bits_per_sample {
    my ($self, $value) = @_;
    $self->{bits_per_sample} = $value if defined($value);
    return $self->{bits_per_sample};
}

sub audioframe_interval {
    my ($self, $value) = @_;
    $self->{audioframe_interval} = $value if defined($value);
    return $self->{audioframe_interval};
}

sub audio_reserve {
    my ($self, $value) = @_;
    $self->{audio_reserve} = $value if defined($value);
    return $self->{audio_reserve};
}

sub encode {
    my ($self) = @_;
	
	$self->{pkt_data} = pack('ssCCCCIIssCCCCIIssssss', $self->{type}, $self->{size}, $self->{video_channel}, $self->{audio_channel}, $self->{data_type}, $self->{reserve}, $self->{codec_id}, $self->{video_bitrate}, $self->{width}, $self->{height}, $self->{frame_rate}, $self->{color_depth}, $self->{videoframe_interval}, $self->{video_reserve}, $self->{samples_per_second}, $self->{audio_bitrate}, $self->{wave_format}, $self->{channel_number}, $self->{block_align}, $self->{bits_per_sample}, $self->{audioframe_interval}, $self->{audio_reserve});
	
	
	
	$self->{size} = length($self->{pkt_data});
	
	return $self->{pkt_data};
}

sub decode {
   my ($self, $pkt_data) = @_;

  ($self->{type}, $self->{size}, $self->{video_channel}, $self->{audio_channel}, $self->{data_type}, $self->{reserve}, $self->{codec_id}, $self->{video_bitrate}, $self->{width}, $self->{height}, $self->{frame_rate}, $self->{color_depth}, $self->{videoframe_interval}, $self->{video_reserve}, $self->{samples_per_second}, $self->{audio_bitrate}, $self->{wave_format}, $self->{channel_number}, $self->{block_align}, $self->{bits_per_sample}, $self->{audioframe_interval}, $self->{audio_reserve}) = unpack('ssCCCCIIssCCCCIIssssss', $self->{pkt_data});
}


package Owsp::ChannelResponse;

our @ISA = 'Owsp::Generic';

sub new {
  my $classname = shift;
  my $self = {};
  bless($self, $classname);
  $self->_init(@_);
  return $self;
}


sub _init {
  my $self = shift;

    $self->{type} = 0x41;
    $self->{size} = 4;
    $self->{result} = 0;
    $self->{current_channel} = 0;
    $self->{reserve} = 0;

    $self->{pkt_data} = undef;
	

  if (@_) {
   my %extra = @_;
   @$self{keys %extra} = values %extra;
  } 

}



sub result {
    my ($self, $value) = @_;
    $self->{result} = $value if defined($value);
    return $self->{result};
}

sub current_channel {
    my ($self) = @_;
    $self->{current_channel} = $value if defined($value);
    return $self->{current_channel};
}

sub reserve {
    my ($self, $value) = @_;
    $self->{reserve} = $value if defined($value);
    return $self->{reserve};
}


sub encode {
    my ($self) = @_;
	
	$self->{pkt_data} = pack('sssCC', $self->{type}, $self->{size}, $self->{result},  $self->{current_channel}, $self->{reserve});
	$self->{size} = length($self->{pkt_data});
	
	return $self->{pkt_data};
}

sub decode {
   my ($self, $pkt_data) = @_;
   
  ($self->{type}, $self->{size}, $self->{result},  $self->{current_channel}, $self->{reserve}) = unpack('sssCC', $self->{pkt_data});
}

sub dump {
  my $self=shift;
  my $ref=$self->SUPER::dump();
  print "Channel result: ";
  if ($self->{result} == 1) {
    print "success\n";
  } elsif ($self->{result} == 5) {
    print "no such channel\n";
  } else {
    print "unknown\n";
  }
}


package Owsp::VideoFrameInfo;

our @ISA = 'Owsp::Generic';

sub new {
  my $classname = shift;
  my $self = {};
  bless($self, $classname);
  $self->_init(@_);
  return $self;
}


sub _init {
  my $self = shift;

    $self->{type} = 0x63;
    $self->{size} = 12;
    $self->{channel_id} = 0;
    $self->{reserve} = 0;
    $self->{checksum} = 0;
    $self->{frame_index} = 0;
    $self->{time} = 0;

    $self->{pkt_data} = undef;
	

  if (@_) {
   my %extra = @_;
   @$self{keys %extra} = values %extra;
  } 

}

sub channel_id {
    my ($self, $value) = @_;
    $self->{channel_id} = $value if defined($value);
    return $self->{channel_id};
}

sub reserve {
    my ($self, $value) = @_;
    $self->{reserve} = $value if defined($value);
    return $self->{reserve};
}

sub checksum {
    my ($self, $value) = @_;
    $self->{checksum} = $value if defined($value);
    return $self->{checksum};
}

sub frame_index {
    my ($self, $value) = @_;
    $self->{frame_index} = $value if defined($value);
    return $self->{frame_index};
}

sub time {
    my ($self, $value) = @_;
    $self->{time} = $value if defined($value);
    return $self->{time};
}


sub encode {
    my ($self) = @_;
	
	$self->{pkt_data} = pack('ssCCsIV', $self->{type}, $self->{size}, $self->{channel_id},  $self->{reserve}, $self->{checksum}, $self->{frame_index}, $self->{time});
	$self->{size} = length($self->{pkt_data});
	
	return $self->{pkt_data};
}

sub decode {
   my ($self, $pkt_data) = @_;
   
  ($self->{type}, $self->{size}, $self->{channel_id},  $self->{reserve}, $self->{checksum}, $self->{frame_index}, $self->{time}) = unpack('ssCCsIV', $self->{pkt_data});
}

sub dump {
  my $self=shift;
  my $ref=$self->SUPER::dump();

  print sprintf("Time: %s\n", $self->format_timestamp($self->{time}));

}


package Owsp::VideoIFrameInfo;

our @ISA = 'Owsp::Generic';

sub new {
  my $classname = shift;
  my $self = {};
  bless($self, $classname);
  $self->_init(@_);
  return $self;
}


sub _init {
  my $self = shift;

    $self->{type} = Owsp::TLV_T_VIDEO_IFRAME_DATA;
    $self->{size} = 0;
    $self->{pkt_data} = undef;
    $self->{iframe} = undef;

  if (@_) {
   my %extra = @_;
   @$self{keys %extra} = values %extra;
  } 

}



sub encode {
    my ($self) = @_;
	
    $self->{size} = length($self->{pkt_data});
	
    return $self->{pkt_data};
}

sub decode {
  my ($self, $pkt_data) = @_;

  
  my $pkt = IO::String->new($self->{pkt_data});
  
  my $data;
  
  $pkt->sysread($data, 4);
  
  ($self->{type}, $self->{size}) = unpack('ss', $data);
  
  $pkt->sysread($data, $self->{size});
  
  $self->{iframe} = $data;
  
  my $timestamp = time();
  
  open(IFRAME, ">> ".$self->{video_file});
  print IFRAME $data;
  close(IFRAME);
  
}

sub dump {
  my $self=shift;
}

package Owsp::SystemRequest;

our @ISA = 'Owsp::Generic';

sub new {
  my $classname = shift;
  my $self = {};
  bless($self, $classname);
  $self->_init(@_);
  return $self;
}


sub _init {
  my $self = shift;

    $self->{type} = Owsp::TLV_T_SYSTEM_CONFIG_GET_REQ;
    $self->{size} = 44;
    
    $self->{device_id} = 0;
    $self->{device_name} = '';
    $self->{hd_overwrite} = 1;
    # 0: "PAL", 1: "NTSC", 2: "SCEAM"
    $self->{video_format} = 2;
    # 0: Simplified Chinese   1: English
    $self->{language} = 1;
    # 0: "YYMMDD", 1: "MMDDYY", 2: "DDMMYY"
    $self->{date_format} = 2;
    # 0: 12 1: 24
    $self->{time_format} = 1;
    $self->{reserve} = 0;
    
    $self->{pkt_data} = undef;


  if (@_) {
   my %extra = @_;
   @$self{keys %extra} = values %extra;
  } 

}

sub device_id {
    my ($self, $value) = @_;
    $self->{device_id} = $value if defined($value);
    return $self->{device_id};
}

sub device_name {
    my ($self, $value) = @_;
    $self->{device_name} = $value if defined($value);
    return $self->{device_name};
}

sub hd_overwrite {
    my ($self, $value) = @_;
    $self->{hd_overwrite} = $value if defined($value);
    return $self->{hd_overwrite};
}

sub video_format {
    my ($self, $value) = @_;
    $self->{video_format} = $value if defined($value);
    return $self->{video_format};
}

sub language {
    my ($self, $value) = @_;
    $self->{language} = $value if defined($value);
    return $self->{language};
}

sub date_format {
    my ($self, $value) = @_;
    $self->{date_format} = $value if defined($value);
    return $self->{date_format};
}

sub time_format {
    my ($self, $value) = @_;
    $self->{time_format} = $value if defined($value);
    return $self->{time_format};
}

sub reserve {
    my ($self, $value) = @_;
    $self->{reserve} = $value if defined($value);
    return $self->{reserve};
}


sub encode {
    my ($self) = @_;
	
	$self->{pkt_data} = pack('ssIZ32CCCCCC3', $self->{type}, $self->{size}, $self->{device_id},  $self->{device_name}, $self->{hd_overwrite}, $self->{video_format}, $self->{language}, $self->{date_format}, $self->{time_format}, $self->{reserve});
	$self->{size} = length($self->{pkt_data});
	
	return $self->{pkt_data};
}

sub decode {
   my ($self, $pkt_data) = @_;
   
   my $pkt = IO::String->new($self->{pkt_data});
   
   #41
   
   my $data;
   
   $pkt->sysread($data, 41);
   
  ($self->{type}, $self->{size}, $self->{device_id},  $self->{device_name}, $self->{hd_overwrite}, $self->{video_format}, $self->{language}, $self->{date_format}, $self->{time_format}) = unpack('ssIZ32CCCCC', $data);
  
  $pkt->sysread($data, 3);
  
  $self->{reserve} = $data;
}


package Owsp::NetworkConfig;

our @ISA = 'Owsp::Generic';

sub new {
  my $classname = shift;
  my $self = {};
  bless($self, $classname);
  $self->_init(@_);
  return $self;
}


sub _init {
  my $self = shift;

    $self->{type} = Owsp::TLV_T_NETWORK_CONFIG_GET_RSP;
    $self->{size} = 72;
    $self->{device_id} = 0;
    $self->{host_ip} = 0;
    $self->{host_name} = '';
    $self->{gateway} = 0;
    $self->{dns_server} = 0;
    $self->{dns_server2} = 0;
    $self->{subnet_mask} = 0;
    $self->{tcp_port} = 0;
    $self->{udp_port} = 0;
    $self->{http_port} = 0;
    $self->{mobile_port} = 0;
    $self->{mac} = 0;
    $self->{bitrate} = 0;
    # 0: pppoe 1: static 2: dhcp
    #or 32: pppoe 64: static 96: dhcp 128: unknown
    $self->{ip_mode} = 0;
    $self->{pkt_data} = undef;
	

  if (@_) {
   my %extra = @_;
   @$self{keys %extra} = values %extra;
  } 

}



sub host_ip {
    my ($self, $value) = @_;
    $self->{host_ip} = $value if defined($value);
    return $self->{host_ip};
}



sub encode {
    my ($self) = @_;
    my $data;
    $data = pack('ssINZ32NNNNssss', $self->{type}, $self->{size}, $self->{device_id}, $self->encode_ip($self->{host_ip}), $self->{host_name}, $self->encode_ip($self->{gateway}), $self->encode_ip($self->{dns_server}), $self->encode_ip($self->{dns_server2}),  $self->encode_ip($self->{subnet_mask}), $self->{tcp_port}, $self->{udp_port}, $self->{http_port}, $self->{mobile_port});
    
    $data .= $self->pack_mac($self->{mac});
    
    $data .= pack('CC', $self->{bitrate}, $self->{ip_mode});
    
    $self->{pkt_data} = $data;
    
    $self->{size} = length($self->{pkt_data});
    
    return $self->{pkt_data};
}

sub decode {
   my ($self, $pkt_data) = @_;
   
   my $pkt = IO::String->new($self->{pkt_data});
   
   #41
   
   my ($data, $host_ip, $gateway, $dns_server, $dns_server2, $subnet_mask);
   $pkt->sysread($data, 68);
   
   my $host_ip;
   
  ($self->{type}, $self->{size}, $self->{device_id}, $host_ip, $self->{host_name}, $gateway, $dns_server, $dns_server2,  $subnet_mask, $self->{tcp_port}, $self->{udp_port}, $self->{http_port}, $self->{mobile_port}) = unpack('ssINZ32NNNNssss', $data);
  
  $self->{host_ip} = $self->decode_ip($host_ip);
  $self->{gateway} = $self->decode_ip($gateway);
  $self->{dns_server} = $self->decode_ip($dns_server);
  $self->{dns_server2} = $self->decode_ip($dns_server2);
  $self->{subnet_mask} = $self->decode_ip($subnet_mask);
  
  $pkt->sysread($data, 6);
  
  $self->{mac} = $self->unpack_mac($data);
  
  $pkt->sysread($data, 2);
  
  ($self->{bitrate}, $self->{ip_mode}) = unpack('CC', $data);
  
  
}

sub dump {
  my $self=shift;
  my $ref=$self->SUPER::dump();

  #print sprintf("host_ip: %s\n", $self->decode_ip($self->{host_ip}));

}



package Owsp::PacketContainer;

sub new {
  my $classname = shift;
  my $self = {};
  bless($self, $classname);
  $self->_init(@_);
  return $self;
}

sub _init {
  my $self = shift;

  $self->{size} = 0;
  $self->{sequence} = 0;
  $self->{data} = undef;
  $self->{container_data} = undef;
  $self->{video_file} = 'dump.h264';
  
  my @arr;
  
  $self->{packets} = @arr;
  
  $self->{decode_table} = {
        0x29 => 'Owsp::LoginRequest',
  	0x2a => 'Owsp::LoginResponse',
  	0x28 => 'Owsp::VersionInfo',
  	0x46 => 'Owsp::DvsinfoRequest',
  	0xc8 => 'Owsp::StreamdataFormat',
  	0x41 => 'Owsp::ChannelResponse',
  	0x63 => 'Owsp::VideoFrameInfo',
  	Owsp::TLV_T_VIDEO_IFRAME_DATA => 'Owsp::VideoIFrameInfo', # iframe1
  	0x66 => 'Owsp::VideoIFrameInfo', # pframe1
  	0x74 => 'Owsp::VideoIFrameInfo', # iframe2
  	0x76 => 'Owsp::VideoIFrameInfo', # pframe2
  	Owsp::TLV_T_SYSTEM_CONFIG_GET_REQ => 'Owsp::SystemRequest',
  	Owsp::TLV_T_SYSTEM_CONFIG_GET_RSP => 'Owsp::SystemRequest',
  	Owsp::TLV_T_NETWORK_CONFIG_GET_RSP => 'Owsp::NetworkConfig',
  	#0x138 => 'Owsp::ConfigResponse',
  };
	

  if (@_) {
   my %extra = @_;
   @$self{keys %extra} = values %extra;
  } 
  
  $self->{size} = length($self->{container_data}) + 4;
}

sub size {
    my ($self) = @_;
	$self->{size} = length($self->{container_data}) + 4;
    return $self->{size};
}
 
sub sequence {
    my ($self, $sequence) = @_;
	$self->{sequence} = $sequence if defined($sequence);
    return $self->{sequence};
}

sub video_file {
    my ($self, $value) = @_;
    $self->{video_file} = $value if (defined($value) && $value ne '');
    return $self->{video_file};
}



sub encode {
    my ($self) = @_;
	
    $self->{data} = pack('NI', $self->{size}, $self->{sequence}) . $self->{container_data};
	
    return $self->{data};
}


sub from_socket {
  my ($self, $socket, $video_file) = @_;
  
  my $data;
  
  $socket->recv($data, 8);

  my ($size, $sequence) = unpack('NI', $data);

  print sprintf("recv: size = %d seq = %d\n\n", $size, $sequence);
  
  $socket->recv($data, $size);
  
  my $container = $self->new(size => $size, sequence => $sequence, container_data => $data);
  
  $container->video_file($video_file);
  
  return $container;
  
}


sub decode_packets {
  my ($self) = @_;
  
  my $counter = $self->{size};
  
  my $container_data = IO::String->new($self->{container_data});
  
  my @packets;

  print "Container packets:\n\n";
  
  while ($counter > 0) {
    my ($header, $data);
  	$container_data->sysread($header, 4);
	
	$counter -= 4;
	
	my ($type, $size) = unpack('ss', $header);
	
	$container_data->sysread($data, $size);
	$counter -= $size;

	my $decoder = $self->{decode_table}{$type};
	
	if (!defined($decoder)) {
	  $decoder = "Owsp::Generic";
	  print sprintf("TLV type = %d (0x%x)\n", $type, $type);
	  open(OUT2, sprintf("> owsp-0x%x.dat", $type));
	  print OUT2 $data;
	  close(OUT2);
	}

	if (defined($decoder)) {
	
                print "Decoder: $decoder\n";
	
		my $pkt = $decoder->new(pkt_data => $header.$data, video_file => $self->{video_file});
		$pkt->decode();
		push(@packets, $pkt);
		
		$pkt->dump();
		
		print "\n";
	
	}
	


  }
  

  $self->{packets} = \@packets;
	
	#print sprintf("Packets: %d\n", $#packets); 
	

  
  my @packets = @{$self->{packets}};
	
  print sprintf("Packets: %d\n", $#packets+1); 
	
}



package main;

#push(@INC, "./");

use IO::Socket;
use IO::Socket::INET;
use IO::String;
use Time::Local;
use Getopt::Long;
use Pod::Usage;
use Data::Dumper;


my $cfgFile = "";
my $cfgUser = "";
my $cfgPass = "";
my $cfgHost = "";
my $cfgPort = "";
my $cfgCmd = "video";
my $cfgFrames = 1;
my $cfgChannel = 0;


my $help = 0;

my  $result = GetOptions (
 "help|h" => \$help,
 "outputfile|of|o=s" => \$cfgFile,
 "user|u=s" => \$cfgUser,
 "pass|p=s" => \$cfgPass,
 "host|hst=s" => \$cfgHost,
 "port|prt=s" => \$cfgPort,
 "frames|f=s" => \$cfgFrames,
 "command|cmd|c=s" => \$cfgCmd,
 "channel|cnl=s" => \$cfgChannel,
);
 
  
pod2usage(1) if ($help);


if (!($cfgHost or $cfgPort or $cfgUser)) {
	print STDERR "You must set user, host and port!\n";
	exit(0);
}
my $socket = IO::Socket::INET->new(
   PeerAddr => $cfgHost,
   PeerPort => $cfgPort,
   Proto => 'tcp',
   Timeout => 10000, 
   Type => SOCK_STREAM, 
   Blocking => 1 
) or die "Error at line " . __LINE__. ": $!\n";


print "Connecting: host = $cfgHost port = $cfgPort\n";

 
my $dvr = Owsp->new(host => $cfgHost, port => $cfgPort, user => $cfgUser, password => $cfgPass, socket => $socket);

my $pkt = Owsp::LoginRequest->new(username => $cfgUser, password => $cfgPass, device_id => 1, channel => $cfgChannel);

my $command_pkt;


my $limit = 10;

if ($cfgCmd eq 'video') {
  $limit = $cfgFrames;
}

if ($cfgCmd eq 'get_config_system') {
  $command_pkt = Owsp::SystemRequest->new(type => Owsp::TLV_T_SYSTEM_CONFIG_GET_REQ);
  $limit = 3;
} elsif ($cfgCmd eq 'get_config_network') {
  $command_pkt = Owsp::NetworkConfig->new(type => Owsp::TLV_T_NETWORK_CONFIG_GET_REQ);
  $limit = 3;
} else {
  $command_pkt = Owsp::VersionInfo->new(version_major => 3, version_minor => 7);
}

my $sequence = 1;

my $container = Owsp::PacketContainer->new(sequence => $sequence, container_data => $command_pkt->encode().$pkt->encode());


open(OUT, ">request.dat");
print OUT $container->encode();
close(OUT);

my $login_data = $container->encode();

$socket->send($login_data);




while ($sequence < $limit) {

  my $rcontainer =  Owsp::PacketContainer->from_socket($socket, $cfgFile);

  print sprintf("Response container size = %d sequence = %d\n\n", $rcontainer->size, $rcontainer->sequence);

  $sequence += 1;


  $rcontainer->decode_packets();

  #open(OUT, sprintf(">test-%d-resp.dat", $sequence));
  #print OUT $rcontainer->{container_data};
  #close(OUT);

}




$dvr->disconnect();

1;