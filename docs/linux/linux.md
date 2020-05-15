# 基础命令

## 判断文件/文件夹/文本
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

#判断文本是否为空
if [ -z "$STRING" ]; then
    echo "STRING is empty"
else 
    echo "STRING is not empty"
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
## 查看linux版本
``` shell
lsb_release -a
```

## MySQL 给用户分配权限
```sql
grant  select,update,delete,insert,execute on learning_space_typx.*to learningtime_ro@"%"  identified by "123";
```

