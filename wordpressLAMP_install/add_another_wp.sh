#!/bin/bash
#set working directory to the location of this script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR
#Get variables and user input
clear
echo "  ==============================================================="
echo "  |      WELCOME TO THE ADD-ANOTHER-WP WORDPRESS INSTALLER      |"
echo "  |                                                             |"
echo "  |  This installer is meant for MULTI-DOMAIN SERVERS ONLY and  |"
echo "  |  will install a new WordPress site at a new domain on your  |"
echo "  |  multi-domain server. You must add the domain first, unless |"
echo "  |  this is being installed at a sub-folder of a domain.       |"
echo "  |                                                             |"
echo "  |            Installer will begin in 15 seconds               |"
echo "  |                                                             |"
echo "  ==============================================================="
echo ""
sleep 15
echo "What is the domain?"
echo "Enter WITHOUT the www (e.g. yourdomain.com):"
read domain
echo ""
echo "Enter the MySQL Root Password (from your initial install notes)"
echo "MySql Root Password:"
read rootpass
echo ""
export domain
export rootpass
[ "$passlength" == "" ] && passlength=32
export wppass=$(tr -dc A-Za-z0-9_ < /dev/urandom | head -c ${passlength} | xargs)
[ "$namelength" == "" ] && namelength=6
export wpdb="wp_db_"$(tr -dc A-Za-z0-9_ < /dev/urandom | head -c ${namelength} | xargs)
export wpuser="wp_us_"$(tr -dc A-Za-z0-9_ < /dev/urandom | head -c ${namelength} | xargs)
#Begin operations
echo ""
echo "Thank you. Beginning WordPress server configuration!"
echo ""
echo "Downloading and unpacking latest WordPress and config DB..."
echo ""
echo ""
sleep 3
sudo apt --yes -qq expect
sudo -E ./add_db_wp.sh
cd /tmp
curl -O https://wordpress.org/latest.tar.gz
curl -O https://wordpress.org/latest.tar.gz.md5
md5latestraw=`md5sum -b latest.tar.gz`
md5latest=${md5latestraw/% *latest.tar.gz/}
md5compare=`cat latest.tar.gz.md5`
if [ "$md5compare" == "$md5latest" ];then
     echo "Checksum matched using MD5!  Continuing..."
else
     echo "WordPress checksum did not match! Exiting..."
     echo ""
     echo "Please report this in the Verus discord"
     exit
fi
tar xzvf latest.tar.gz
clear
echo "Configuring WordPress files, folders, permissions, and config..."
echo ""
echo ""
sleep 6
touch /tmp/wordpress/.htaccess
cp /tmp/wordpress/wp-config-sample.php /tmp/wordpress/wp-config.php
mkdir /tmp/wordpress/wp-content/upgrade
sudo cp -a /tmp/wordpress/. /var/www/$domain/html
sudo perl -pi -e "s/database_name_here/$wpdb/g" /var/www/$domain/html/wp-config.php
sudo perl -pi -e "s/username_here/$wpuser/g" /var/www/$domain/html/wp-config.php
sudo perl -pi -e "s/password_here/$wppass/g" /var/www/$domain/html/wp-config.php
sudo perl -i -pe'
  BEGIN {
    @chars = ("a" .. "z", "A" .. "Z", 0 .. 9);
    push @chars, split //, "!@#$%^&*()-_ []{}<>~\`+=,.;:/?|";
    sub salt { join "", map $chars[ rand @chars ], 1 .. 64 }
  }
  s/put your unique phrase here/salt()/ge
' /var/www/$domain/html/wp-config.php
sudo chown -R www-data:www-data /var/www/$domain/html
sudo find /var/www/$domain/html/ -type d -exec chmod 750 {} \;
sudo find /var/www/$domain/html/ -type f -exec chmod 640 {} \;
clear
echo "Cleaning up..."
echo ""
echo ""
sleep 3
sudo apt -y -qq purge expect
sudo rm /tmp/latest.tar.gz
sudo rm /tmp/wordpress -r
clear
echo ""
echo ""
echo "====================================="
echo "=           IMPORTANT!              ="
echo "=  Below are your new credentials   ="
echo "=  and details. Write down these    ="
echo "=  details down in a secure place   ="
echo "====================================="
echo "                                     "
echo "     Server & WordPress Data:        "
echo "  ---------------------------------  "
echo "                                     "
echo "  WordPress DB Name: "$wpdb
echo "  WordPress DB User: "$wpuser
echo "  WordPress DB Pass: "$wppass
echo "                                     "
echo "  ---------------------------------  "
echo "====================================="
echo ""