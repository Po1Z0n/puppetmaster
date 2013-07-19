# Class: samba::server
#
# Samba server.
#
# For all main options, see the smb.conf(5) and samba(7) man pages.
# For the SELinux related options, see smbd_selinux(8).
#
# Sample Usage :
# include samba::server
#
class samba::server (
# Main smb.conf options
  $workgroup = 'Ownet',
  $server_string = 'Samba Server Version %v',
  $netbios_name = 'OWNET',
  $interfaces = [],
  $hosts_allow = [],
  $log_file = '/var/log/samba/log.%m',
  $max_log_size = '10000',
  $domain_master = false,
  $domain_logons = false,
  $local_master = undef,
  $security = 'share',
  $map_to_guest = undef,
  $os_level = undef,
  $preferred_master = undef,
  $extra_global_options = [],
  $shares = {
    'Data' => [
      'comment = Data',
      'path = /data',
      'browseable = yes',
      'writable = yes',
      'guest ok = yes',
      'available = yes',
    ],
  },
# SELinux options
  $selinux_enable_home_dirs = false,
  $selinux_export_all_rw = false
) inherits ::samba::params {

# Main package and service
  package { 'samba': ensure => installed }
  service { $samba::params::service:
    enable => true,
    ensure => running,
    hasstatus => true,
    subscribe => File['/etc/samba/smb.conf'],
  }

  file { '/etc/samba/smb.conf':
    require => Package['samba'],
    content => template('samba/smb.conf.erb'),
  }

# SELinux options
  if $::selinux {
    Selboolean { persistent => true }
    if $selinux_enable_home_dirs {
      selboolean { 'samba_enable_home_dirs': value => 'on' }
    }
    if $selinux_export_all_rw {
      selboolean { 'samba_export_all_rw': value => 'on' }
    }
  }

}
