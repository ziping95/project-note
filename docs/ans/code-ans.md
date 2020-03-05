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
