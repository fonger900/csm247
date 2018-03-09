#!/bin/sh
#
# PhongDD4 present
# Shell script for installing CSM247 portal site
#
message()
{
  TITLE="Cannot start CSM247's Installer"
  if [ -n "`which zenity`" ]; then
    zenity --error --title="$TITLE" --text="$1"
  elif [ -n "`which kdialog`" ]; then
    kdialog --error "$1" --title "$TITLE"
  elif [ -n "`which xmessage`" ]; then
    xmessage -center "ERROR: $TITLE: $1"
  elif [ -n "`which notify-send`" ]; then
    notify-send "ERROR: $TITLE: $1"
  else
    echo -e "ERROR: $1\n$TITLE"
  fi
}

USER=`who am i | awk '{print $1}'`
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

if [ -z "$SED" -o -z "$WHOAMI" -o -z "$UNAME" -o -z "$GREP" -o -z "$CUT" -o -z "$MKTEMP" -o -z "$RM" -o -z "$CAT" -o -z "$TR" ]; then
  message "Required tools are missing - check beginning of \"$0\" file for details."
  exit 1
fi

# ---------------------------------------------------------------------
# Check software installation
# ---------------------------------------------------------------------
echo "PROCESS: Checking software installation"

# Check if apache2 server has been installed
if [ -z "$APACHE2" ]; then
	message "Missing apache2 - Please install apache2."
  exit 1
else
  echo "Checking apache2: OK"
fi

# Check whether PHP installed
if [ -z "$PHP" ]; then
  message "PHP is not installed - Please install PHP 7.0"
  exit 1
fi

# Check PHP version
CHECK_PHP_VER=`php -v | egrep "7.0" `
if [ "$?" -ne "0" ]; then
  message "Please install php7.0 instead "
  exit 1
else
  echo "Checking PHP: OK"
fi

# Check whether package libapache2-mod-php7.0 is installed
CHECK_LIBAPACHE2_PHP=`dpkg -l | grep libapache2-mod-php7.0`
if [ "$?" -ne "0" ]; then
  message "Missing libapache2-mod-php7.0 package"
  exit 1
else
  echo "Checking libapache2-mod-php7.0 package: OK"
fi

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
fi
echo "Checking Composer: OK"

# ---------------------------------------------------------------------
# Check PHP modules
# ---------------------------------------------------------------------
echo "PROCESS: Checking PHP modules"

php -m | egrep "mbstring"
if [ "$?" -ne "0" ]; then
  message "Missing PHP mbstring module"
  exit 1
fi

php -m | egrep "json"
if [ "$?" -ne "0" ]; then
  message "Missing PHP json module"
  exit 1
fi

php -m | egrep "xml"
if [ "$?" -ne "0" ]; then
  message "Missing PHP xml module"
  exit 1
fi

php -m | egrep "PDO"
if [ "$?" -ne "0" ]; then
  message "Missing PHP PDO module"
  exit 1
fi

php -m | egrep "tokenizer"
if [ "$?" -ne "0" ]; then
  message "Missing PHP tokenizer module"
  exit 1
fi

php -m | egrep "ctype"
if [ "$?" -ne "0" ]; then
  message "Missing PHP ctype module"
  exit 1
fi

php -m | egrep "curl"
if [ "$?" -ne "0" ]; then
  message "Missing PHP curl module"
  exit 1
fi

echo "Checking PHP required modules: OK"

# ---------------------------------------------------------------------
# Checking Nodejs installation
# ---------------------------------------------------------------------

if [ -z "$NODEJS" ]; then
  echo "ERROR: Missing Nodejs"
  exit 1
fi

# Checking nodejs's version (8.9.4)
node -v | egrep "8.9.4" > /dev/null 2>&1
if [ "$?" -ne "0" ]; then
  echo "ERROR: Invalid Nodejs version! Please install Nodejs version 8.9.4"
  exit 1
fi
echo "Checking Nodejs's version (8.9.4): OK"

# Checking NPM
# NPM was shipped with Nodejs so that no need to check npm installation

# if [ -z "$YARN" ]; then
#   echo "ERROR: Missing Yarn"
#   exit 1
# fi

# ---------------------------------------------------------------------
# Copy project to /var/www
# ---------------------------------------------------------------------
# CSM247_PROJECT_DIR=`pwd`
# cp -r "$CSM247_PROJECT_DIR" /var/www/
# if [ "$?" -ne "0" ]; then
#   message "Copy project to /var/www/ failed!"
#   exit 1
# else
#   echo "Copy project to /var/www/ success!"
# fi

# ---------------------------------------------------------------------
# Set permission and ownerships
# ---------------------------------------------------------------------
echo "PROCESS: Set permissions and ownerships"

#assign user to owner of website


# assign webserver's user (www-data) as owner
CSM247_HOME_DIR=`pwd`
chown -R "$USER":www-data "$CSM247_HOME_DIR"
if [ "$?" -ne "0" ]; then
  message "Failed to set ownership for project"
  exit 1
fi

# set right permission for project's directories and files
find "$CSM247_HOME_DIR" -type f -exec chmod 664 {} \;
if [ "$?" -ne "0" ]; then
  message "Failed to set permission for files!"
  exit 1
fi

find "$CSM247_HOME_DIR" -type d -exec chmod 775 {} \;
if [ "$?" -ne "0" ]; then
  message "Failed to set permission for directories!"
  exit 1
fi

#give the webserver the right to read and write to storage and cache directory
chgrp -R www-data storage bootstrap/cache
if [ "$?" -ne "0" ]; then
  message "Failed to set ownership for storage/ and bootstrap/cache directory!"
  exit 1
fi
chmod -R ug+rwx storage bootstrap/cache
if [ "$?" -ne "0" ]; then
  message "Failed to set permissions for bootstrap/cache directory!"
  exit 1
fi

echo "Set permissions and ownerships: OK"

# ---------------------------------------------------------------------
# Configuring Apache2
# ---------------------------------------------------------------------
echo "PROCESS: Configuring Apache2"

#copy csm247's configuration file to sites-available directory 
cp csm247.conf /etc/apache2/sites-available/	
if [ "$?" -ne "0" ]; then
  message "Copy csm247's configuration file to sites-available directory failed!"
  exit 1
fi
echo "Copy csm247's configuration file to sites-available directory: OK"

#Add listening port to apache2 webserver
cat /etc/apache2/ports.conf | egrep "Listen 8000"
if [ "$?" -ne "0" ]; then
  sed -i "\$aListen 8000"  /etc/apache2/ports.conf
  if [ "$?" -ne "0" ]; then
    message "Add new listening port to webserver failed!"
    exit 1
  fi
  echo "Add new listening port (8000) to webserver: OK"
else
  echo "Project listening on port 8000"
fi  


a2ensite csm247.conf 	#enable csm247 site
a2enmod rewrite			#enable mode_rewrite to allow .htacess file takes effect

/etc/init.d/apache2 restart	#restart web server

echo "Installation finished!"
