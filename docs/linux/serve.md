## 一、修改为阿里yum源
1. 首先备份系统自带yum源配置文件/etc/yum.repos.d/CentOS-Base.repo
   * mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
2. 查看CentOS系统版本
   * lsb_release -a
3. 下载ailiyun的yum源配置文件到/etc/yum.repos.d/
   * wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
4. 运行yum makecache生成缓存
   * yum makecache
5. 这时候再更新系统就会看到以下mirrors.aliyun.com信息
   * yum -y updat 等待完成

## 二、安装MySQL
1. 将`mysql57-community-release-el7-10.noarch.rpm`文件放到任意文件夹
2. 执行`yum -y install mysql57-community-release-el7-10.noarch.rpm`
3. 执行`yum -y install mysql-community-server` 等到开始下载文件时候终止掉
4. 进入`/var/cache/yum/x86_64/7/mysql57-community/packages/`下删除全部东西
   * `cd /var/cache/yum/x86_64/7/mysql57-community/packages/`
   * `rm -rf ./*`
5. 将文件传到刚才的文件夹
6. 执行`yum -y install mysql-community-server`
7. 启动MySQL服务,继续在命令行输入`systemctl start mysqld`
8. 检查mysql的启动状态`systemctl status mysqld`
9. 设置开机启动
   * `systemctl enable mysqld`
   * `systemctl daemon-reload`
10. 获取临时密码`grep 'temporary password' /var/log/mysqld.log`
11. 登录数据库并修改密码
    * `mysql -uroot -p`
    * `set password for 'root'@'localhost'=password('whaty!@#123');`
12. 如果提示密码不符合当前策略，解决办法
    * 输入`set global validate_password_policy=0;`
13. 允许远程连接MySQL
    * 进入数据库`use mysql`
    * 查看用户`select user,host from user;`
    * 更改root用户`update user set host = '%' where user = 'root';`
    * 刷新权限`flush privileges;`

## 三、安装jdk
1. 查看服务器有无自带jdk `rpm -qa | grep java`

2. 然后通过`rpm -e --nodeps`后面跟系统自带的jdk名，这个命令来删除系统自带的jdk

3. 解压压缩包`tar -zxvf jdk-8u201-linux-x64.tar.gz`

4. 配置环境`vim /etc/profile`在最后添加，注意改home路径

   ``` shell
   export JAVA_HOME=/usr/local/software/jdk1.8.0_201
   export CLASSPATH=.:$JAVA_HOME/jre/lib/rt.jar:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
   export PATH=$PATH:$JAVA_HOME/bin
   ```

5. 刷新配置`. /etc/profile`  点和/之间有个空格，然后`java -version`查看

## 四、安装Redis
1. 由于redis是c语言编写，所以安装gcc
   * 先安装gcc`yum install gcc gcc-c++ autoconf automake`
   * 再安装make编译工具 `yum -y install gcc automake autoconf libtool make`
   
2. 解压`tar -zxvf redis-5.0.3.tar.gz` 

3. 进入redis目录`cd redis-5.0.3`

4. 编译`make`

5. 安装`make PREFIX=/usr/local/redis install`

6. 拷贝redis.conf到安装目录`cp redis.conf /usr/local/redis`

7. 进入`cd /usr/local/redis`目录

8. 修改`redis.conf`文件
   * 后台启动，`daemonize yes`
   * 绑定端口，port 6379 默认是6379 需要安全组开放端口
   * 将protected-mode模式修改为no 允许远程访问
   * 绑定IP，bind 0.0.0.0
   * 指定持久化方式，appendonly yes
   * 指定数据存放路径，dir /usr/local/redis/log rdb存放的路径
   * requirepass whaty!@#123 设置密码
   
9. 启动redis`./bin/redis-server ./redis.conf`

10. 查看是否启动成功：`ps aux | grep redis`

11. 进入客户端`./bin/redis-cli --raw` 处理中文乱码问题

## 五、安装nginx
1. 一键安装所有依赖`yum -y install gcc zlib zlib-devel pcre-devel openssl openssl-devel`
2. 解压
3. 进入文件夹`cd /usr/local/nginx`
4. 执行命令`./configure`
5. 执行make命令`make`
6. 执行`make install`命令
7. 配置`nginx.conf`
8. 启动nginx `/usr/local/nginx/sbin/nginx -s reload`

## 六、安装Tomcat

1. 解压`tar -zxvf apache-tomcat-9.0.14.tar.gz`
2. 进入tomcat下的bin目录后,启动tomcat`./catalina.sh start`

## 七、安装Docker

1. 安装依赖包

   * `sudo yum install -y yum-utils device-mapper-persistent-data lvm2`

2. 设置阿里云镜像

   * `sudo yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo`

3. 安装Docker-CE

   * 重建 Yum 缓存`yum clean all`  `yum makecache`
   * 安装 Docker-CE ，请执行一下命令进行安装 `sudo yum install docker-ce`

4. 启动Docker-CE

   * `sudo systemctl enable docker`
   * `sudo systemctl start docker`

5. ***[可选]*** 为Docker 建立用户组

   ::: tip
   docker 命令与 Docker 引擎通讯之间通过 UnixSocket ，但是能够有权限访问 UnixSocket 的用户只有 root 和 docker 用户组的用户才能够进行访问，所以我们需要建立一个 docker 用户组，并且将需要访问 docker 的用户添加到这一个用户组当中来。
   :::	

   1. 建立 Docker 用户组`sudo groupadd docker`
   2. 添加当前用户到docker组`sudo usermod -aG docker $USER`
   
6. 镜像加速配置

   ::: tip
   这里使用的是 [阿里云提供的镜像加速](https://cr.console.aliyun.com/#/accelerator) ，登录并且设置密码之后在左侧的 **Docker Hub 镜像站点** 可以找到专属加速器地址，复制下来。然后在/etc/docker目录下创建daemon.json文件
   :::

   ```
   sudo mkdir -p /etc/docker
   sudo tee /etc/docker/daemon.json <<-'EOF'
   {
     "registry-mirrors": ["https://sr6fslfm.mirror.aliyuncs.com"]
   }
   EOF
   ```
   * 之后重新加载配置，并且重启 Docker 服务`systemctl daemon-reload`  `systemctl restart docker`

7. 配置 Docker 容器与镜像

   * 拉取`docker pull centos:7.6.1810`
   * 下载完后查看是否成功`docker images`
   * 启动镜像`docker run -d -i -t -p 80:80 --name web_config centos:7.6.1810 /bin/bash`
   
8. 备注：

   * 为了使容器支持systemctl命令需要在启动容器时候加上`--privileged -e "container=docker"` 并且最后面的命令改为`/usr/sbin/init`

## 八、安装VIM

1. 检查是否已经存在vim包

   * `rpm -qa|grep vim` 如果已安装则显示

     > ```shell
     > vim-minimal-7.4.629-6.el7.x86_64
     > vim-filesystem-7.4.629-6.el7.x86_64
     > vim-enhanced-7.4.629-6.el7.x86_64
     > vim-common-7.4.629-6.el7.x86_64
     > vim-X11-7.4.629-6.el7.x86_64
     > ```

2. 安装

   * 如果缺少了其中某个，比如说： vim-enhanced这个包少了，则执行：`yum -y install vim-enhanced`
   * 如果上面三个包一个都没有显示，则直接输入命令：`yum -y install vim*`

3. 备注：

   * 支持中文修改文件 `vim /etc/vimrc` 在文件后添加如下配置

     > ```shell
     > set fileencodings=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936
     > set termencoding=utf-8
     > set encoding=utf-8
     > ```
