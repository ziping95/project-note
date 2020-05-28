# 服务器相关
## Nginx 请求路径结尾不带 '/' 重定向问题
例如访问`/note`路径，如果没有note文件的情况下，会自动301重定向到`/note/`路径，重新请求，如果这时候依旧匹配不到`nginx.conf`中的规则，则报404响应
## Tomcat 指定jdk版本
在catalina.sh文件和setclasspath.sh文件开头的空白处加上如下两句：
```shell
export JAVA_HOME=/usr/local/java/jdk1.7.0_18
export JRE_HOME=/usr/local/java/jdk1.7.0_18/jre
```
## request.getScheme()获取到的始终是http
1. 检查nginx配置中是否有以下这句
```
proxy_set_header  X-Forwarded-Proto $thescheme;
```
2. 检查tomcat中是否有以下标签
```
<Valve className="org.apache.catalina.valves.RemoteIpValve"
               remoteIpHeader="X-Forwarded-For"
               protocolHeader="X-Forwarded-Proto"
               protocolHeaderHttpsValue="https"/>
```
