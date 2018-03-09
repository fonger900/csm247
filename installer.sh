#!/bin/sh
#
# PhongDD4 present
# Shell script for installing CSM247 portal site
#

# Color code
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color
YELLOW='\033[0;33m'
BPURBLE='\033[1;35m'
CYAN='\033[0;36m'

# ---------------------------------------------------------------------
# Functions for coloring command's standard output
# ---------------------------------------------------------------------

# Function for coloring success messages as green
success()
{
  echo -ne "[ ${GREEN}ok${NC} ] $1\n"
}

# Function for coloring error messages as red
error()
{
  TITLE="Cannot start CSM247's Installer"
  if [ -n "`which zenity`" ]; then
    zenity --error --title="$TITLE" --text="$1"
  elif [ -n "`which kdialog`" ]; then
    kdialog --error "$1" --title "$TITLE"
  elif [ -n "`which xerror`" ]; then
    xerror -center "ERROR: $TITLE: $1"
  elif [ -n "`which notify-send`" ]; then
    notify-send "ERROR: $TITLE: $1"
  else
    echo -e "${RED}ERROR${NC}: $1\n$TITLE"
  fi
}

# Function for coloring step of process's messages as yellow
process()
{
  echo -ne "[....] $1\r"
}

# ---------------------------------------------------------------------
# Variables for checking builtin command's existence
# ---------------------------------------------------------------------

USER=`who | awk '{print $1}'`
UNAME=`which uname`
GREP=`which egrep`
GREP_OPTIONS=""
CUT=`which cut`
READLINK=`which readlink`
XARGS=`which xargs`
DIRNAME=`which dirname`
MKTEMP=`which mktemp`
RM=`which rm`
CAT=`which cat`
TR=`which tr`
WHOAMI=`which whoami`
APACHE2=`which apache2`
PHP=`which php`
SED=`which sed`
COMPOSER=`which composer`
NODEJS=`which nodejs`
YARN=`which yarn`
MYSQL=`which mysql`

if [ -z "$SED" -o -z "$WHOAMI" -o -z "$UNAME" -o -z "$GREP" -o -z "$CUT" -o -z "$MKTEMP" -o -z "$RM" -o -z "$CAT" -o -z "$TR" ]; then
  error "Required tools are missing - check beginning of \"$0\" file for details."
  exit 1
fi

# ---------------------------------------------------------------------
# Check software installation
# ---------------------------------------------------------------------
process "Checking apache2"

# Check if apache2 server has been installed
if [ -z "$APACHE2" ]; then
	error "Missing apache2 - Please install apache2."
  echo "Start installing Apache2"
  apt-get install apache2 -y
  if [ "$?" -ne "0" ]; then
    error "Failed to install apache2!"
    exit 1
  fi
  #exit 1
else
  success "Checking apache2"
fi

# Check whether PHP installed
if [ -z "$PHP" ]; then
  error "PHP is not installed - Please install PHP 7.0"
  echo "Start installing php7.0"
  apt-get install php7.0 -y
  if [ "$?" -ne "0" ]; then
    error "Failed to install php7.0!"
    exit 1
  fi
  #exit 1
fi

# Check PHP version
CHECK_PHP_VER=`php -v | egrep "7.0" `
if [ "$?" -ne "0" ]; then
  error "Please install php7.0 instead "
  exit 1
else
  success "Checking php7.0"
fi

# Check whether package libapache2-mod-php7.0 is installed
CHECK_LIBAPACHE2_PHP=`dpkg -l | grep libapache2-mod-php7.0`
if [ "$?" -ne "0" ]; then
  error "Missing libapache2-mod-php7.0 package"
  echo "Start installing libapache2-mod-php7.0"
  apt-get install libapache2-mod-php7.0 -y
  if [ "$?" -ne "0" ]; then
    error "Failed to install libapache2-mod-php7.0!"
    exit 1
  fi
  #exit 1
else
  success "Checking libapache2-mod-php7.0 package"
fi

# ---------------------------------------------------------------------
# Check PHP modules
# ---------------------------------------------------------------------
COMMAND_OUTPUT=`php -m | egrep "mbstring"`
if [ "$?" -ne "0" ]; then
  error "Missing PHP mbstring module"
  echo "Start installing php7.0-mbstring."
  apt-get install php-mbstring -y
  if [ "$?" -ne "0" ]; then
    error "Failed to installing php-mbstring."
    exit 1
  fi
fi

COMMAND_OUTPUT=`php -m | egrep "json"`
if [ "$?" -ne "0" ]; then
  error "Missing PHP json module"
  echo "Start installing php7.0-json."
  apt-get install php7.0-json -y
  if [ "$?" -ne "0" ]; then
    error "Failed to installing php7.0-json."
    exit 1
  fi
fi

COMMAND_OUTPUT=`php -m | egrep "xml"`
if [ "$?" -ne "0" ]; then
  error "Missing PHP xml module"
  echo "Start installing php7.0-xml."
  apt-get install php7.0-xml -y
  if [ "$?" -ne "0" ]; then
    error "Failed to installing php7.0-xml."
    exit 1
  fi
fi

COMMAND_OUTPUT=`php -m | egrep "PDO"`
if [ "$?" -ne "0" ]; then
  error "Missing PHP PDO module"
  exit 1
fi

COMMAND_OUTPUT=`php -m | egrep "tokenizer"`
if [ "$?" -ne "0" ]; then
  error "Missing PHP tokenizer module"
  exit 1
fi

COMMAND_OUTPUT=`php -m | egrep "ctype"`
if [ "$?" -ne "0" ]; then
  error "Missing PHP ctype module"
  exit 1
fi

COMMAND_OUTPUT=`php -m | egrep "curl"`
if [ "$?" -ne "0" ]; then
  error "Missing PHP curl module"
  echo "Start installing php7.0-curl."
  apt-get install php7.0-curl -y
  if [ "$?" -ne "0" ]; then
    error "Failed to installing php7.0-curl."
    exit 1
  fi
fi

success "Checking PHP required modules"

# Check composer installation
if [ -z "$COMPOSER" ]; then
  echo -e "WARN: Missing composer\n Start Dowloading Composer"
  # Composer Installer
  php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
  php -r "if (hash_file('SHA384', 'composer-setup.php') === \
  '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') \
  { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
  php composer-setup.php
  php -r "unlink('composer-setup.php');"
  #--------------------
  cp composer.phar /usr/bin/composer
  if [ "$?" -ne "0" ]; then
    error "Failed to install composer.phar!"
    exit 1
  fi
fi
success "Checking Composer"


# ---------------------------------------------------------------------
# Checking Nodejs installation
# ---------------------------------------------------------------------
if [ -z "$NODEJS" ]; then
  error "Missing Nodejs"
  process "Start installing Nodejs 8.9.4"
  cp nodesource.list /etc/apt/sources.list.d/
  curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
  apt-get update > /dev/null 2>&1
  apt-get install nodejs -y > /dev/null 2>&1
  if [ "$?" -ne "0" ]; then
    error "Failed to install NodeJs!"
    exit 1
  fi
fi

# Checking nodejs's version (8.9.4)
node -v | egrep "8" > /dev/null 2>&1
if [ "$?" -ne "0" ]; then
  error "Invalid Nodejs version! Please install Nodejs version 8.9.4"
  exit 1
fi
success "Checking Nodejs's version (8.9.4)"

# Checking NPM
# NPM was shipped with Nodejs so that no need to check npm installation

# if [ -z "$YARN" ]; then
#   echo "ERROR: Missing Yarn"
#   exit 1
# fi

# ---------------------------------------------------------------------
# Checking Mysql installation
# ---------------------------------------------------------------------
if [ -z "$MYSQL" ]; then
  error "Missing Mysql."
  process "Start installing mysql."
  apt-get install mysql-server -y
  if [ "$?" -ne "0" ]; then
    error "Failed to install Mysql!"
    exit 1
  fi
fi
success "Checking Mysql"

# ---------------------------------------------------------------------
# Setup database
# ---------------------------------------------------------------------
process "Setting up database."
echo "create database csm247;" | mysql -u root -proot > /dev/null 2>&1
echo "grant all privileges on csm247.* to csm247@'%' identified by 'csc@123a';"| mysql -u root -proot > /dev/null 2>&1
#cat Incident* | mysql -u root -proot csm247 > /dev/null 2>&1
php artisan migrate > /dev/null 2>&1
php artisan db:seed > /dev/null 2>&1
if [ "$?" -ne "0" ]; then
  error "Failed to setting up database!"
  exit 1
fi
success "Setting up database"

# ---------------------------------------------------------------------
# Copy project to /var/www
# ---------------------------------------------------------------------
# CSM247_PROJECT_DIR=`pwd`
# cp -r "$CSM247_PROJECT_DIR" /var/www/
# if [ "$?" -ne "0" ]; then
#   error "Copy project to /var/www/ failed!"
#   exit 1
# else
#   echo "Copy project to /var/www/ success!"
# fi

# ---------------------------------------------------------------------
# Set permission and ownerships
# ---------------------------------------------------------------------
process "Setting permissions and ownerships"

#assign user to owner of website

if [ -z "$USER" ]; then
	error "User not exist"
	exit 1
fi

# assign webserver's user (www-data) as owner
CSM247_HOME_DIR=`pwd`
chown -R "$USER":www-data "$CSM247_HOME_DIR"
if [ "$?" -ne "0" ]; then
  error "Failed to set ownership for project"
  exit 1
fi

# set right permission for project's directories and files
find "$CSM247_HOME_DIR" -type f -exec chmod 664 {} \;
if [ "$?" -ne "0" ]; then
  error "Failed to set permission for files!"
  exit 1
fi

find "$CSM247_HOME_DIR" -type d -exec chmod 775 {} \;
if [ "$?" -ne "0" ]; then
  error "Failed to set permission for directories!"
  exit 1
fi

#give the webserver the right to read and write to storage and cache directory
chgrp -R www-data storage bootstrap/cache
if [ "$?" -ne "0" ]; then
  error "Failed to set ownership for storage/ and bootstrap/cache directory!"
  exit 1
fi
chmod -R ug+rwx storage bootstrap/cache
if [ "$?" -ne "0" ]; then
  error "Failed to set permissions for bootstrap/cache directory!"
  exit 1
fi

success "Setting permissions and ownerships"
# ---------------------------------------------------------------------
# Install project's dependencies and Javascript's packages
# ---------------------------------------------------------------------

# Install Javascript's packages
process "Installing Javascript's packages"
sudo -u "$USER" npm install > /dev/null 2>&1
if [ "$?" -ne "0" ]; then
  error "Failed to install Javascript's packages!"
  exit 1
fi
success "Installing Javascript's packages"

# Install project's dependencies
process "Installing dependencies"
sudo -u "$USER" composer install > /dev/null 2>&1
if [ "$?" -ne "0" ]; then
  error "Failed to install dependencies!"
  exit 1
fi
success "Installing dependencies"


# ---------------------------------------------------------------------
# Configuring Apache2
# ---------------------------------------------------------------------
process "Configuring Apache2"

#copy csm247's configuration file to sites-available directory 
cp csm247.conf /etc/apache2/sites-available/	
if [ "$?" -ne "0" ]; then
  error "Copy csm247's configuration file to sites-available directory failed!"
  exit 1
fi
#success "Copy csm247's configuration file to sites-available directory"

#Add listening port to apache2 webserver
cat /etc/apache2/ports.conf | egrep "Listen 8000" > /dev/null 2>&1
if [ "$?" -ne "0" ]; then
  sed -i "\$aListen 8000"  /etc/apache2/ports.conf
  if [ "$?" -ne "0" ]; then
    error "Add new listening port to webserver failed!"
    exit 1
  fi
  #success "Add new listening port (port 8000) to webserver"
fi  
success "Configuring Apache2"

a2ensite csm247.conf 	> /dev/null 2>&1 #enable csm247 site
a2enmod rewrite			> /dev/null 2>&1 #enable mode_rewrite to allow .htacess file takes effect

/etc/init.d/apache2 restart	#restart web server

echo -e "${GREEN}Installation finished!"
