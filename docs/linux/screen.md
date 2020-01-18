## 关闭一个已经detached会话
``` shell
screen -X -S seesion-id quit
```
## 创建一个会话
``` shell
screen -S yourname
```
## 查看当前会话列表
``` shell
screen -ls
```
## 回到这个指定的会话中
``` shell
screen -r yourname
```
## 远程detach某个session
``` shell
screen -d yourname
```
## 结束当前session并回到yourname这个session
``` shell
screen -d -r yourname
```
