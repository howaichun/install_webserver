#!/bin/bash
# 安装PHP版本
# 
# 切换到下载包目录
cd $PACKDIR
echo "Installing ${PHPVERSION} *****************"
sleep 1

wget -c --tries=3 http://cn2.php.net/distributions/${PHPVERSION}.tar.bz2
if [ $? != 0 ]; then
	echo "Download ${PHPVERSION}.tar.gz failed!" && exit
if;
# 删除原有的PHP代码
rm -rf ${PHPVERSION}
# 解压源码包
tar zxf ${PHPVERSION}.tar.bz2
# 切换到源码目录
cd ${PHPVERSION}
./configure 
 --prefix=${PHPDIR}
 --with-config-file-path=${PHPCONFIGDIR} \
 --enable-fpm \
 --with-fpm-user=www \
 --with-fpm-group=www \
 --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd \
 --with-iconv-dir --with-freetype-dir \
 --with-jpeg-dir \
 --with-png-dir \
 --with-zlib \
 --with-libxml-dir=/usr \
 --enable-xml\
 --enable-discard-path \
 --enable-magic-quotes \
 --enable-safe-mode \
 --enable-bcmath \
 --enable-shmop \
 --enable-sysvsem \
 --enable-inline-optimization \
 --with-curl --enable-mbregex \
 --enable-fastcgi \
 --enable-fpm \
 --enable-force-cgi-redirect \
 --enable-mbstring --with-mcrypt --enable-ftp --with-gd \
 --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl  \
 --enable-sockets --with-xmlrpc --enable-zip --enable-soap \
 --without-pear --with-gettext --with-mime-magic >> /tmp/php_install.log

[ $? != 0 ] && echo "configure 错误，安装失败！" && exit
make  >> /tmp/php_install.log
[ $? != 0 ] && echo "make 错误，安装失败！" && exit
make install  >> /tmp/php_install.log
[ $? != 0 ] && echo "make install 错误，安装失败！" && exit

# 使用/opt/php目录作为php命令的软链接，以后直接在/opt/php目录中查找php命令
rm -rf ${PHPBIN}
ln -s ${PHPDIR} ${PHPBIN}
ln -s ${PHPBIN} /usr/local/php
ln -s /usr/local/php/bin/* /usr/sbin/

# 创建php.ini的配置文件
cp php.ini-production ${PHPCONFIGDIR}/php.ini

# 安装PHP的redis扩展
if [ ${install_redis} ]; then
	# 切换到包下载目录
	cd ${PACKDIR}
	if [ ! -f "redis.zip" ]; then
	    wget -c https://github.com/nicolasff/phpredis/archive/master.zip -O redis.zip
	fi;
	rm -rf phpredis-master
	unzip redis.zip
	cd phpredis-master
	/usr/local/bin/phpize
	./configure --with-php-config=/usr/bin/php-config
	make && make install
	# 修改PHP的php.ini 匹配到the dl() 然后插入一行 extension="redis.so"
	sed -i '/the dl()/i\
	extension = "redis.so"' ${PHPCONFIGDIR}/php.ini
if;

# 安装PHP的YAF扩展
if [ ${install_yaf} ]; then
	# 切换到包下载目录
	cd ${PACKDIR}
	wget -c --tries=3 https://github.com/laruence/php-yaf
	cd php-yaf
	/usr/local/bin/phpize
	./configure --with-php-config=/usr/bin/php-config
	make -j4 && make install

	# 修改配置文件
	sed -i '/the dl()/i\
	extension = "yaf.so"' ${PHPCONFIGDIR}/php.ini
if;

#安装xhprof
if [ ${install_xhprof} ]; then
	cd ${PACKDIR}
	if [ ! -f "xhprof.zip" ]; then
	    wget -c http://jh.59.hk:8888/soft/xhprof-0.9.4.tgz -O xhprof.zip
	fi;
	rm -rf xhprof-master
	unzip xhprof.zip
	cd xhprof-master/extension
	/usr/local/bin/phpize 
	./configure --with-php-config=/usr/bin/php-config
	make && make install
if;



