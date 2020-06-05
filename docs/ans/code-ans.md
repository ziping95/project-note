# 代码相关
## 查看动态代理生成的class文件
该设置用于输出cglib动态代理产生的类
```java
System.setProperty(DebuggingClassWriter.DEBUG_LOCATION_PROPERTY, "D:\\class");
```
该设置用于输出jdk动态代理产生的类（生成在项目根路径下）
```java
System.getProperties().put("sun.misc.ProxyGenerator.saveGeneratedFiles", "true");
```
## HttpServletResponse 设置字节编码无效
```java
httpServletResponse.setContentType("text/html;charset=UTF-8");
或
httpServletResponse.setCharacterEncoding("UTF-8");
```
设置编码必须在`response.getWriter()`之前，才能生效

## chrome浏览器关闭跨域检测

打开快捷方式属性后，在目标栏后面加上--disable-web-security --user-data-dir=C:\Users\wzp\Desktop\123

注意新版chrome必须要指定`user-data-dir`否则无效

看到如下提示即生效


