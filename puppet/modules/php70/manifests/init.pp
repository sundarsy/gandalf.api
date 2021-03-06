class php70(
  $user = 'www-data',
  $group = 'www-data',
  $error_repotring = 'E_ALL & ~E_DEPRECATED & ~E_STRICT'
) {

  include apt
  include pear

  apt::ppa { 'ppa:ondrej/php': }

  exec { "apt-get update":
    command => "/usr/bin/apt-get update",
    require => Apt::Ppa['ppa:ondrej/php']
  }->

  exec { "apt-get install packages":
    command => "/usr/bin/apt-get install php7.0-fpm php7.0-cli php7.0-mcrypt php7.0-curl php7.0-dev php-pear libsasl2-dev php7.0-mbstring php7.0-gd php7.0-xml zip unzip -y --force-yes",
    require => Exec['apt-get update']
  } ->

  pear::package { "mongodb":
    repository => "pecl.php.net",
    require => Exec['apt-get install packages']
  }
#  exec { "install mongodb":
#    command => "/usr/bin/pecl install mongodb",
#    require => Exec['apt-get install packages']
#  }

  file { "/etc/php/7.0/fpm/pool.d/www.conf":
    path    => "/etc/php/7.0/fpm/pool.d/www.conf",
    content => template('php70/php-fpm-www.conf.erb'),
    require => Exec['apt-get install packages'],
    notify  => Service["php7.0-fpm"]
  }
  file { "/etc/php/7.0/fpm/php.ini":
    path    => "/etc/php/7.0/fpm/php.ini",
    content => template('php70/php-fpm.ini.erb'),
    require => Exec['apt-get install packages'],
    notify  => Service["php7.0-fpm"]
  }

  file { "/etc/php/7.0/fpm/php-fpm.conf":
    path    => "/etc/php/7.0/fpm/php-fpm.conf",
    content => template('php70/php-fpm.conf.erb'),
    require => Exec['apt-get install packages'],
    notify  => Service["php7.0-fpm"]
  }

  file { "mongodb_fpm":
    path    => "/etc/php/7.0/fpm/conf.d/20-mongodb.ini",
    content => "
    extension=mongodb.so
    ",
    require => Pear::Package["mongodb"],
    notify  => Service["php7.0-fpm"]
  }

  file { "mongodb_cli":
    path    => "/etc/php/7.0/cli/conf.d/20-mongodb.ini",
    content => "
    extension=mongodb.so
    ",
    require => Pear::Package["mongodb"],
    notify  => Service["php7.0-fpm"]
  }

  file { "mongodb_mods":
    path    => "/etc/php/7.0/mods-available/mongodb.ini",
    content => "
    extension=mongodb.so
    ",
    require => Pear::Package["mongodb"],
    notify  => Service["php7.0-fpm"]
  }

  file { ["/usr/local/openssl/", "/usr/local/openssl/include/", "/usr/local/openssl/include/openssl/", "/usr/local/openssl/lib/"]:
    ensure => "directory",
    owner  => "root",
    group  => "root",
    mode   => 755
  } ->
  file { '/usr/local/openssl/include/openssl/evp.h':
    ensure => 'link',
    target => '/usr/include/openssl/evp.h',
  } ->
  file { '/usr/local/openssl/lib/libssl.a':
    ensure => 'link',
    target => '/usr/lib/x86_64-linux-gnu/libssl.a',
  } ->
  file { '/usr/local/openssl/lib/libssl.so':
    ensure => 'link',
    target => '/usr/lib/x86_64-linux-gnu/libssl.so',
  }



  service { 'php7.0-fpm':
    ensure  => 'running',
    enable  => true,
    require => Exec['apt-get install packages']
  }
}
