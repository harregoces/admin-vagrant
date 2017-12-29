#!/usr/bin/env bash

echo "Provisioning virtual machine..."

export DEBIAN_FRONTEND=noninteractive

echo "Generating locales"
locale-gen en_IE.UTF-8 it_IT.UTF-8 es_ES.UTF-8 es_CO.UTF-8 > /dev/null 2>&1

echo "Installing basic requirements"
apt-get install -y python-software-properties > /dev/null 2>&1

# Repositories first, so we just have to apt-get update once
echo "Adding Percona repository"
wget https://repo.percona.com/apt/percona-release_0.1-4.$(lsb_release -sc)_all.deb > /dev/null 2>&1
dpkg -i percona-release_0.1-4.$(lsb_release -sc)_all.deb > /dev/null 2>&1
rm -rf percona-release_0.1-4.$(lsb_release -sc)_all.deb > /dev/null 2>&1

echo "Adding Node.js repository"
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash - > /dev/null 2>&1

echo "Adding Erlang repository"
curl -s http://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc | apt-key add - > /dev/null 2>&1
echo "deb http://packages.erlang-solutions.com/ubuntu precise contrib" > /etc/apt/sources.list.d/erlang.list

echo "Installing apt-fast"
bash -c "$(curl -sL https://git.io/vokNn)" > /dev/null 2>&1

echo "Upgrading the system"
# https://github.com/chef/bento/issues/661#issuecomment-248136601
apt-fast -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade > /dev/null 2>&1


echo "Installing utilities"
apt-fast install -y \
    htop vim curl git build-essential \
    python2.7 python3 python-setuptools python3-setuptools python-dateutil \
 > /dev/null 2>&1
easy_install pip > /dev/null 2>&1
easy_install3 pip > /dev/null 2>&1

# PHP stuff
echo "Installing PHP"
apt-fast install -y \
    automake autoconf libtool libssl-dev shtool libpcre3-dev \
    php7.0-common php7.0-dev php7.0-cli php7.0-fpm \
 > /dev/null 2>&1
(pecl upgrade -f apcu_bc-beta) > /dev/null 2>&1
apt-fast install -y \
    php-imap php-igbinary php-apcu php-imagick php-intl php-mbstring php-memcache php-pear php-http php-xdebug php-xml \
    php7.0-bcmath php7.0-cli php7.0-common php7.0-curl php7.0-dev php7.0-fpm php7.0-gd php7.0-intl php7.0-json \
    php7.0-mbstring php7.0-mcrypt php7.0-mysql php7.0-opcache php7.0-readline php7.0-soap php7.0-xml php7.0-zip \
 > /dev/null 2>&1


 echo "Configuring PHP"
 # php.ini
 cp /var/provision/config/php/php_php7.ini /etc/php/7.0/fpm/php.ini
 cp /var/provision/config/php/php_php7.ini /etc/php/7.0/cli/php.ini
 # opcache.ini
 cp /var/provision/config/php/ext/opcache.ini /etc/php/7.0/mods-available/
 # apcu.ini
 cp /var/provision/config/php/ext/apcu.ini /etc/php/7.0/mods-available/
 ln -sf /etc/php/7.0/mods-available/apcu.ini /etc/php/7.0/fpm/conf.d/20-apcu.ini
 # apcu_bc.ini
 cp /var/provision/config/php/ext/apcu_bc.ini /etc/php/7.0/mods-available/
 ln -sf /etc/php/7.0/mods-available/apcu_bc.ini /etc/php/7.0/fpm/conf.d/20-apcu_bc.ini
 # mysqli.ini
 cp /var/provision/config/php/ext/mysqli.ini /etc/php/7.0/mods-available/
 # memcache.ini
 cp /var/provision/config/php/ext/memcache.ini /etc/php/7.0/mods-available/

 #cp /var/provision/config/php/ext/xdebug.ini /etc/php/7.0/mods-available/

 # PHP-FPM
 cp /var/provision/config/php/www_php7.conf /etc/php/7.0/fpm/pool.d/www.conf

echo "Installing Composer"
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer > /dev/null 2>&1

# Nginx stuff
echo "Installing Nginx"
apt-fast install -y nginx > /dev/null 2>&1

echo "Configuring Nginx"
cp /var/provision/config/nginx/frontend_vhost /etc/nginx/sites-available/frontend_vhost
cp /var/provision/config/nginx/backend_vhost /etc/nginx/sites-available/backend_vhost

ln -s /etc/nginx/sites-available/frontend_vhost /etc/nginx/sites-enabled/
ln -s /etc/nginx/sites-available/backend_vhost /etc/nginx/sites-enabled/

rm -rf /etc/nginx/sites-enabled/default
rm -rf /etc/nginx/sites-available/default

echo "Restarting Nginx"
    service nginx restart > /dev/null 2>&1

# Node.js stuff
echo "Installing Node.js"
sudo apt-get install -y nodejs > /dev/null 2>&1
#npm install npm -g > /dev/null 2>&1
sudo apt-get install build-essential > /dev/null 2>&1


# DB stuff
if [ ! -f /var/log/dbinstalled ];
then
    echo "Installing Percona"
    sudo debconf-set-selections <<< 'percona-server-server-5.5 percona-server-server/root_password password 17959304'
    sudo debconf-set-selections <<< 'percona-server-server-5.5 percona-server-server/root_password_again password 17959304'

    sudo apt-get install -y percona-server-server-5.5 percona-server-client-5.5 > /dev/null 2>&1

    echo "CREATE USER 'unmentionable'@'%' IDENTIFIED BY 'chroNify'" | mysql -uroot -p17959304
    echo "CREATE USER 'unmentionable'@'localhost' IDENTIFIED BY 'chroNify'" | mysql -uroot -p17959304

    echo "CREATE DATABASE myproject" | mysql -uroot -p17959304

    echo "GRANT ALL ON myproject.* TO 'unmentionable'@'localhost'" | mysql -uroot -p17959304
    echo "GRANT ALL ON myproject.* TO 'unmentionable'@'%'" | mysql -uroot -p17959304

    echo "GRANT RELOAD ON *.* TO 'unmentionable'@'localhost'" | mysql -uroot -p17959304
    echo "GRANT RELOAD ON *.* TO 'unmentionable'@'%'" | mysql -uroot -p17959304

    echo "GRANT FILE ON *.* TO 'unmentionable'@'localhost'" | mysql -uroot -p17959304
    echo "GRANT FILE ON *.* TO 'unmentionable'@'%'" | mysql -uroot -p17959304

    echo "FLUSH PRIVILEGES" | mysql -uroot -p17959304

    sudo touch /var/log/dbinstalled
fi

#check if necesary run it always.
#echo "installing project dependencies via composer"
#cd /shared/development/code/
#composer global require laravel/installer > /dev/null 2>&1
#composer install > /dev/null 2>&1

#echo "Creating myproject tables"
#php artisan migrate

echo 'deb http://www.rabbitmq.com/debian/ testing main' | sudo tee /etc/apt/sources.list.d/rabbitmq.list
wget -O- https://www.rabbitmq.com/rabbitmq-release-signing-key.asc | sudo apt-key add -
sudo apt-get update
sudo apt-get install rabbitmq-server -y
service rabbitmq-server start
npm install @angular/cli


echo "Done";
echo "Micro sitio VM Ready!!!"