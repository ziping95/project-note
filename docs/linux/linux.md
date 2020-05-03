# 基础命令

## 判断文件/文件夹是否存在
```shell script
#文件夹不存在则创建
if [ ! -d "/data/" ];then
  mkdir /data
  else
  echo "文件夹已经存在"
fi

#文件存在则删除
if [ ! -f "/data/filename" ];then
  echo "文件不存在"
  else
  rm -f /data/filename
fi

#判断文件夹是否存在
if [ -d "/data/" ];then
  echo "文件夹存在"
  else
  echo "文件夹不存在"
fi

#判断文件是否存在
if [ -f "/data/filename" ];then
  echo "文件存在"
  else
  echo "文件不存在"
fi
```
## 后台运行jar包
``` shell
nohup java -jar studentService-1.0-SNAPSHOT.jar > temp.txt &
```
::: tip
&： 指在后台运行，nohup：是不挂断运行，即使退出终端依旧可以运行，但不是后台运行，所以退出当前进程后该进程就会被终止，所以需要添加 &
:::
## 查看后台执行的作业
``` shell
jobs
``` 
## 查看进程
``` shell
netstat -apn | grep 8080                        查看某一端口上的进程
ps -aux | grep PID                              查看某一进程详细信息
ps -ef | grep my_post | grep -v grep`           查询某一进程
```
## linux创建超链接
```
ln -s /www/htdocs/webapps/zyjy_cbs webapp
```
## 更改用户组和权限
``` shell
chgrp 用户名  文件名  -R
chown 用户名  文件名  -R
chown -R whaty.whaty
```
## 在文件中检索内容
``` shell
find . -name "\*.java" | xargs grep generateAndDownloadQrCode
```
## 查看磁盘大小
``` shell
df -H  系统路径大小
du -H  当前路径大小
```
## 打包 / 解包
``` shell
tar -zcvf 打包
tar -zxvf 解包
```
## 查看linux版本
``` shell
lsb_release -a
```

