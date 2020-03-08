# 设计模式

## 观察者模式

<p style="text-indent:2em">
观察者模式，是面相接口编程的思想，是一种松耦合的体现，首先定义一个接口类，定义出公共行为sayHi
</p>

```java
public interface Behavior {
    void sayHi(String str);
}
```
然后定义多个观察者实现该接口，在实际开发中就是实现各自的业务逻辑，这里只展示一个
```java
public class ObserverA implements Behavior{
    @Override
    public void sayHi(String str) {
        System.out.println(str + "，这里是观察者1号");
    }
}
```
然后在定义一个被观察者，保证被观察者中可以持有所有观察者对象的list，在调用时可以依据业务逻辑遍历对象调用方法
```java
public class Subject {

    private List<Behavior> list = new ArrayList<>();

    public void addObserver(Behavior behavior) {
        list.add(behavior);
    }

    public void sayHi(String str) {
        list.forEach(item -> item.sayHi(str));
    }
}
```
测试代码
```java
public static void main(String[] args) {
        Subject subject = new Subject();
        subject.addObserver(new ObserverA());
        subject.addObserver(new ObserverB());
        subject.addObserver(new ObserverC());
        subject.addObserver(new ObserverD());

        // 通知
        subject.sayHi("大家好");
    }
```
```
大家好，这里是观察者1号
大家好，这里是观察者2号
大家好，这里是观察者3号
大家好，这里是观察者4号
```
当然开发时我们还是更多的借用Spring依赖注入的概念，来实现自动注入，我们可以将每个观察者注册成bean，在类中加上`@Component`，然后在
被观察者中使用依赖注入,以下两种方式均可
```java
    @Autowired
    private List<Behavior> list;
```
```java
    @Autowired
    public void setList(List<Behavior> list) {
        this.list = list;
    }
```
在Spring中的事件发布机制也是基于此，从`publishEvent(applicationEvent)`中debug源码后发现，Spring中通过层层过滤找到符合的监听器通过for循环调用
```java
	@Override
	public void multicastEvent(final ApplicationEvent event, @Nullable ResolvableType eventType) {
		ResolvableType type = (eventType != null ? eventType : resolveDefaultEventType(event));
		Executor executor = getTaskExecutor();
		for (ApplicationListener<?> listener : getApplicationListeners(event, type)) {
			if (executor != null) {
			    // 异步调用
				executor.execute(() -> invokeListener(listener, event));
			}
			else {
			    // 同步调用
				invokeListener(listener, event);
			}
		}
	}
```
在往下debug时发现`invokeListener(listener, event)`方法下调用了`doInvokeListener(listener,event)`方法，
而该方法中调用了`onApplicationEvent(event)`，该方法就是必须要实现的监听器接口中的方法
```java
public interface ApplicationListener<E extends ApplicationEvent> extends EventListener {
	/**
	 * Handle an application event.
	 * @param event the event to respond to
	 */
	void onApplicationEvent(E event);
}

```

## 装饰者模式
<p style="text-indent:2em">
先来想一个场景，现在开了一个奶茶店，奶茶可以随意添加配料，配料有椰果，珍珠，布丁，根据不同的组合价格不同，这时候如果我要依据用户选择的组合来制作奶和计算价格
代码应该怎么写？一堆if else？太难看了，写一个基类为奶茶，然后每种配料写一个子类，然后椰果+珍珠再写一个子类？这样子类太多，然而用装饰者模式就可以很好的解决这个问题
</p>
<p style="text-indent:2em">
装饰者模式就是在不改变原有对象的情况下，将新功能添加在原对象上面（扩展对象），这种模式比类之间的继承更具有弹性，可自由扩展功能，代码实现如下
</p>

先抽象一个奶茶的接口，该接口有两个方法，一个是算钱，一个是获取名称
```java
public interface TeaWithMilk {
    public String getName();
    public BigDecimal getCost();
}
```
然后写一个牛奶类当做基础类，并实现接口（以下所有类均实现接口）
```java
public class Milk implements TeaWithMilk{

    private String name = "牛奶";
    
    private BigDecimal cost = new BigDecimal(5.00);
    
    public String getName(){ return this.name; }
    
    public BigDecimal getCost() { return this.cost; }
    
}
```
然后写一个椰果类，并且在该类中持有牛奶类对象（其他配料类就不写了，与椰果类相同）
```java
public class Coco implements TeaWithMilk {

    private TeaWithMilk teaWithMilk;

    private String name = "椰果";

    private BigDecimal cost = new BigDecimal(1.50);

    @Override
    public String getName() { return teaWithMilk.getName() + " + " + this.name; }

    @Override
    public BigDecimal getCost() { return teaWithMilk.getCost().add(this.cost); }

    public Coco(TeaWithMilk teaWithMilk) { this.teaWithMilk = teaWithMilk; }
}
```
在使用的时候，可以通过new对象的方式自由组合顺序和配料，测试代码如下
```java
public static void main(String[] args) {

        // 制作一杯椰果+布丁+珍珠的奶茶
        Coco coco = new Coco(new Milk());                   // 加椰果
        Pudding pudding = new Pudding(coco);                // 加布丁
        TeaWithMilk teaWithMilk = new Pearl(pudding);       // 加珍珠
        System.out.println(teaWithMilk.getName() + "价格为：" + teaWithMilk.getCost().setScale(2,RoundingMode.DOWN));

        // 制作一杯双份椰果+单份布丁的奶茶
        Coco coco1 = new Coco(new Milk());                  // 加椰果
        Coco coco2 = new Coco(coco1);                       // 加椰果
        TeaWithMilk teaWithMilk1 = new Pudding(coco2);      // 加布丁
        System.out.println(teaWithMilk1.getName() + "价格为：" + teaWithMilk1.getCost().setScale(2,RoundingMode.DOWN));
        
}
```
通过装饰者模式就可以在不更改牛奶类的情况下，添加很多口味并且可以自由组合
```
牛奶 + 椰果 + 布丁 + 珍珠价格为：9.50
牛奶 + 椰果 + 椰果 + 布丁价格为：10.00
```

## 代理模式
>部分搬运自[CSDN](https://blog.csdn.net/flyfeifei66/article/details/81481222#cglib%E5%8A%A8%E6%80%81%E4%BB%A3%E7%90%86)

<p style="text-indent:2em">指对象A通过持有对象B，可以替代B的功能。通常持有方式为B实现了一个接口，A也会去实现相同的接口。但A不是真正的实现类，只是负责调用B的方法，但它可以增强B，在调用B的方法前后都做些其他的事情。Spring AOP就是基于动态代理</p>
<p style="text-indent:2em">类A写死持有B，就是B的静态代理。如果A代理的对象是不确定的，就是动态代理。动态代理目前有两种常见的实现，JDK动态代理和CGLIB动态代理。</p>

* ### JDK动态代理

<p style="text-indent:2em">
jdk动态代理是jre提供给我们的类库，可以直接使用，不依赖第三方。使用jdk的动态代理的要求是被代理类必须有对应实现的接口
</p>

<p style="text-indent:2em">
假设有这样一个场景，一个厨师想开饭店，但他不可能身兼数职，因此他请了两个人，帮他收银和送菜
</p>

```java
public interface Chef {
    void cook();
}
```
然后再有一个类实现该接口
```java 
public class A implements Chef{

    @Override
    public void cook() {
        System.out.println("正在做饭……");
    }
}
```
顾客进店后需要先点餐，然后付款，做完菜后还需要送菜，但他不是代理类，原因是它没有实现我们的厨师接口，无法对外服务

```java
public class CookingMasterBoyProxy implements InvocationHandler {

    // 目标类，也就是被代理对象
    private Object target;

    public void setTarget(Object target) {
        this.target = target;
    }

    @Override
    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {

        // 这里可以做增强
        System.out.println("点餐……");

        Object result = method.invoke(target, args);

        System.out.println("送餐……");

        return result;
    }

    // 生成代理类（该方法写在任意处均可，通常放在工厂类中）
    public Object CreatProxyedObj() {
        return Proxy.newProxyInstance(target.getClass().getClassLoader(), target.getClass().getInterfaces(), this);
    }
}
```

上述例子中，方法CreatProxyedObj返回的对象才是我们的代理类，它需要三个参数，前两个参数的意思是在同一个classloader下通过接口创建出一个对象，该对象需要一个属性，也就是第三个参数，它是一个InvocationHandler。
::: tip 步骤
1. new一个目标对象
2. new一个InvocationHandler，将目标对象set进去
3. 通过CreatProxyedObj创建代理对象，强转为目标对象的接口类型即可使用，实际上生成的代理对象实现了目标接口。
:::

```java
public static void main(String[] args) {

    CookingMasterBoyProxy cookingMasterBoyProxy = new CookingMasterBoyProxy();
    
    CookingMasterBoy cookingMasterBoy = new CookingMasterBoy();
    
    cookingMasterBoyProxy.setTarget(cookingMasterBoy);
    
    Chef chef =  (Chef) cookingMasterBoyProxy.CreatProxyedObj();
    
    chef.cook();
    
}
```
Proxy（jdk类库提供）根据B的接口生成一个实现类，我们成为C，它就是动态代理类（该类型是 $Proxy+数字 的“新的类型”）。
>生成过程是：由于拿到了接口，便可以获知接口的所有信息（主要是方法的定义），也就能声明一个新的类型去实现该接口的所有方法。

这些方法显然都是“虚”的，它调用另一个对象的方法。当然这个被调用的对象不能是对象B，如果是对象B，我们就没法增强了，等于饶了一圈又回来了。

所以它调用的是B的包装类，这个包装类需要我们来实现，它必须实现InvocationHandler，这个接口里面有个方法，它是Target的所有方法的调用入口（invoke）

通过反编译生成后的代码查看。Proxy创造的C是自己（Proxy）的子类，且实现了B的接口
```java
public final class $Proxy0 extends Proxy implements Chef
```

所以可以认为creatProxyedObj返回的对象为代理对象，该对象中持有InvocationHandler对象,调用InvocationHandler对象中的invoke方法，而InvocationHandler对象中又有target对象，通过反编译查看生成的class文件，可看到下面方法
```java
public $Proxy0(InvocationHandler var1) throws  {
        super(var1);
    }
```
而生成类的为Proxy的子类，调用父类的构造函方法，我们点进去看发现父类中的构造方法为
```java
protected Proxy(InvocationHandler h) {
        Objects.requireNonNull(h);
        this.h = h;
    }
```
因此可以证明自动生成的类的实例对象中持有InvocationHandler

一个方法代码如下
```java
public final void cook() throws  {
        try {
            super.h.invoke(this, m3, (Object[])null);
        } catch (RuntimeException | Error var2) {
            throw var2;
        } catch (Throwable var3) {
            throw new UndeclaredThrowableException(var3);
        }
    }
```
可以看到，C中的方法全部通过调用h实现，其中h就是InvocationHandler，是我们在生成C时传递的第三个参数。留心看到C在invoke时把自己this传递了过去，
InvocationHandler的invoke的第一个方法也就是我们的动态代理实例类，业务上有需要就可以使用它。（所以不要在invoke方法里把请求分发给第一个参数，否则很明显就死循环了）
C类中有B中所有方法的成员变量
```java
private static Method m1;
private static Method m3;
private static Method m4;
private static Method m2;
private static Method m0;
```
这些变量在static静态代码块初始化，这些变量是在调用invocationhander时必要的入参
```java
static {
        try {
            m1 = Class.forName("java.lang.Object").getMethod("equals", Class.forName("java.lang.Object"));
            m2 = Class.forName("java.lang.Object").getMethod("toString");
            m3 = Class.forName("com.wzp.module.user.test.Chef").getMethod("cook");
            m0 = Class.forName("java.lang.Object").getMethod("hashCode");
        } catch (NoSuchMethodException var2) {
            throw new NoSuchMethodError(var2.getMessage());
        } catch (ClassNotFoundException var3) {
            throw new NoClassDefFoundError(var3.getMessage());
        }
}
```
* ### CGLIB动态代理
<p style="text-indent:2em">代理的关键是一个类能替代另一个类提供相同效果的服务，因此怎么获得被代理对象的方法是关键，java中有两种方式可以获得方法，一是通过实现相同接口，二是继承父类，而jdk的代理就是采取第一种方案，而cglib方式代理则采取第二种方案</p>

```java
public class CglibProxy implements MethodInterceptor {
    
    // 该处代码可以将动态代理生成的class文件，存放在你指定的路径下，方便反编译查看内容
    static {
        System.setProperty(DebuggingClassWriter.DEBUG_LOCATION_PROPERTY, "D:\\class");
    }

    // 根据一个类型产生代理类，此方法不要求一定放在MethodInterceptor中
    public Object CreatProxyedObj(Class<?> clazz) {
        Enhancer enhancer = new Enhancer();
        enhancer.setSuperclass(clazz);
        enhancer.setCallback(this);
        return enhancer.create();
    }

    @Override
    public Object intercept(Object o, Method method, Object[] objects, MethodProxy methodProxy) throws Throwable {
        System.out.println("开始执行cglib代理增强方法");
        return methodProxy.invokeSuper(o,objects);
    }
}
```
cglib 通过生成一个继承TestCglib的代理类，这个类中由四部分组成（复写的父类方法，新生成的每个方法的cglib代理方法，统一的增强方法），这个类中有一个MethodInterceptor对象，在上述代码中CreatProxyedObj传入的this,该对象就包含了增强方法
在代理类中构建“CGLIB”+“$父类方法名$”的方法，该方法的实现就是super.方法名，用于调用真正的方法逻辑

这里的intercept一共四个参数，第一个参数就是当前的代理对象，上面代码的this，第二个参数是被拦截的方法，第三个参数是方法的参数，第四个参数是代理方法，也就是“CGLIB”+“$父类方法名$”这个方法
在intercept中需要调用methodProxy.invokeSuper(o,objects)而不是method.invoke，原因显而易见，因为在生成的代理类中全部重写了父类方法，并且将重写的方法作为代理类方法的入口，如果在intercept中调用的话，会死循环

```java
public class TestCglib {

    public void sayHello(String s) {
        System.out.println("hello world, hello " + s);
    }
}
```
下面是测试代码
```java
CglibProxy cglibProxy = new CglibProxy();
TestCglib testCglib = (TestCglib) cglibProxy.CreatProxyedObj(TestCglib.class);
testCglib.sayHello("cglib代理");
```
另外我们可以通过一个[小技巧](/ans/code-ans.html#%E6%9F%A5%E7%9C%8B%E5%8A%A8%E6%80%81%E4%BB%A3%E7%90%86%E7%94%9F%E6%88%90%E7%9A%84class%E6%96%87%E4%BB%B6)查看代理生成的class文件
我们可以看到生成的类是TestCglib的子类
```java
public class TestCglib$$EnhancerByCGLIB$$94104789 extends TestCglib implements Factory
```
并且复写了全部共有方法（包括equals等方法）
```java
public final void sayHello(String var1) {
        MethodInterceptor var10000 = this.CGLIB$CALLBACK_0;
        if (this.CGLIB$CALLBACK_0 == null) {
            CGLIB$BIND_CALLBACKS(this);
            var10000 = this.CGLIB$CALLBACK_0;
        }

        if (var10000 != null) {
            var10000.intercept(this, CGLIB$sayHello$0$Method, new Object[]{var1}, CGLIB$sayHello$0$Proxy);
        } else {
            super.sayHello(var1);
        }
    }
```
其中this.CGLIB$CALLBACK_0这个属性其实就是统一的增强方法的对象，在下面代码可以看到被强转为MethodInterceptor类型
```java
public void setCallback(int var1, Callback var2) {
        switch(var1) {
        case 0:
            this.CGLIB$CALLBACK_0 = (MethodInterceptor)var2;
        default:
        }
    }
```

## 单例模式
<p style="text-indent:2em">单例模式是设计模式中最为简单的一种，即整个程序仅拥有一个实例，一般有三个</p>

::: tip 特点
1. 类构造器私有
2. 持有自己类型的私有属性
3. 对外提供获取实例的静态方法
:::
<p style="text-indent:2em">单例模式有几种写法</p>

* #### 懒汉式（线程不安全）
```java
public class Singleton {
    private static Singleton instance;
    private Singleton (){
    }
    public static Singleton getInstance() {
        if (instance == null) {
            instance = new Singleton();
        }
        return instance;
    }
}
```

* #### 饿汉式（线程安全）
由于在类初始化时就加载对象了，容易产生垃圾
```java
public class Singleton {
    private static Singleton instance = new Singleton();
    private Singleton() {
    }
    public static Singleton getInstance() {
        return instance;
    }
}
```

* #### 双重校验模式（线程安全）

这里如果只校验一次，会造成两个线程都判断为空，线程阻塞后会生成多个对象，并且为了防止jvm进行指令的重排序对多线程造成影响，因此`singleton`使用关键字
`volatile`修饰


```java
public class Singleton {
    
    private volatile static Singleton singleton;

    private Singleton() {
    }

    public static Singleton getSingleton() {
        if (singleton == null) {
            synchronized (Singleton.class) {
                if (singleton == null) {
                    singleton = new Singleton();
                }
            }
        }
        return singleton;
    }
}
```

* #### 静态内部类的方式（线程安全）

在第一次获取对象时，jvm初始化`SingletonInner`内部类，并且仅初始化一次，推荐使用这种方式

```java
public class Singleton {

    private Singleton() {
    }

    public static Singleton getInstance() {
        return SingletonInner.instance;
    }

    private static class SingletonInner {
        private static final Singleton instance = new Singleton();
    }

```

* #### 使用枚举类方式（线程安全）
枚举类在任何时候都是单例的，并且创建时是线程安全的
```java
public enum EnumSingleton {
    INSTANCE;

    public EnumSingleton getInstance() {
        return INSTANCE;
    }

    public void sayHi() {
        System.out.println("hello world");
    }
}
```

以上是单例模式常见的几种写法，但还存在一个问题，在反序列化时，怎么保证对象唯一呢，先看下问题
```java
public static void main(String[] args) throws IOException, ClassNotFoundException {

        Singleton a = Singleton.getInstance();

        FileOutputStream fos = new FileOutputStream("D:\\a.txt");
        ObjectOutputStream oos = new ObjectOutputStream(fos);
        oos.writeObject(a);
        oos.close();
        fos.close();

        ObjectInputStream ois = new ObjectInputStream(new FileInputStream("D:\\a.txt"));
        Singleton readObject =  (Singleton) ois.readObject();

        System.out.println(a);
        System.out.println(readObject);

    }
```
控制台打印的结果
```
com.wzp.module.user.test.Singleton@6e8cf4c6
com.wzp.module.user.test.Singleton@12edcd21
```
解决办法为加上readResolve()方法
>反序列化时，如果定义了readResolve()则直接返回此方法指定的对象。而不需要单独再创建新对象
```java
private Object readResolve() throws ObjectStreamException {
        return SingletonInner.instance;
}
```

## 工厂模式
<p style="text-indent:2em">工厂模式主要分为，简单工厂模式，工厂模式和抽象工厂模式。</p>

<p style="text-indent:2em">
简单工厂用的最少，因为完全不符合开放封闭原则，所以用的最少，几乎不用。
工厂模式和抽象工厂模式，大体上相同，但针对的场景不同，工厂模式是针对单一产品的，比如某个品牌的电脑（整体），而抽象工厂模式针对产品族，比如，各个品牌的电脑工厂
不仅可以生产自己的主机，也可以生产自己的显示器，键盘等，然后组合成电脑
</p>

>抽象工厂模式就是工厂模式的扩展，本质上没区别，工厂模式相比于抽象工厂模式更加遵循开放封闭原则，但在复杂场景下会多出许多不必要的类

* ### 简单工厂模式
首先定义一个Computer接口，这就是工厂生产出来的最终产品
```java
public interface Computer {
    String getComputerName();    
}
```
定义`DellComputer`和`LenovoComputer`实现类，实现上面的接口，这里只放一个
```java
public class DellComputer implements Computer {
    @Override
    public String getComputerName() {
        return "戴尔电脑";
    }
}
```
然后创建一个工厂类`ComputerFactory`该类中有一个生产产品的静态方法`getComputer`
```java
public class ComputerFactory {

    public static Computer getComputer(String brand) {
        switch (brand) {
            case "Dell":
                return new DellComputer();
            case "Lenovo":
                return new LenovoComputer();
        }
        return () -> "华硕电脑";
    }

}
```
使用时，直接调用`getComputer`方法并指定需要的品牌，即可
```java
public static void main(String[] args) {
        Computer computer = ComputerFactory.getComputer("Dell");
        System.out.println(computer.getComputerName());
}
```
如果我们现在再加一个苹果品牌，我们就要就修改静态方法，增加一种品牌的判断，不符合开放封闭原则

* ### 工厂模式
<p style="text-indent:2em">
为了增强简单工厂模式的扩展能力，所以我们抽象出来一个工厂接口，然后各个品牌的工厂去实现这个工厂接口，每个工厂只负责生产自己品牌的电脑
</p>

先定义一个电脑工厂接口`ComputerFactory`其中有一个`getComputer`方法用来生产电脑
```java
public interface ComputerFactory {
    Computer getComputer();
}
```
分别定义戴尔工厂`DellFactory`和联想工厂`LenovoFactory`，每个工厂只负责生产自己品牌的电脑
```java
public class DellFactory implements ComputerFactory {
    @Override
    public Computer getComputer() {
        return new DellComputer();
    }
}
```
调用方法如下，`new` 一个品牌工厂出来，用这个工厂生产的电脑，就是该品牌的电脑
```java
public static void main(String[] args) {
        ComputerFactory computerFactory = new DellFactory();
        Computer computer = computerFactory.getComputer();
        System.out.println(computer.getComputerName());
}
```
<p style="text-indent:2em">
通过工厂模式，我们去除了简单工厂模式中工厂方法中的品牌参数，不再需要判断参数来确定生产品牌，现在我们new完工厂对象后，所生产的品牌就已经确定了
如果这时候我们需要加一个新品牌，我们只需要新创建一个工厂类实现ComputerFactory接口，使用的时候new这个工厂对象就可以了
</p>

* ### 抽象工厂模式

<p style="text-indent:2em">
现在细化工厂产品，每一个工厂不光可以生产电脑，也可以生产鼠标，键盘等产品，现在应该怎么扩展，共两种办法
</p>

* 使用工厂模式，创建鼠标产品接口，然后再创建对应鼠标的工厂接口，然后各个品牌的鼠标工厂实现工厂接口，生产键盘则再走一遍该流程
* 使用抽象工厂模式，同样创建鼠标接口，然后在已有的工厂接口中添加在生产鼠标方法，在各个品牌工厂中增加生产鼠标的方法实现

<p style="text-indent:2em">
以上两种方法各有优缺点，工厂模式完全遵循了开放封闭原则，但因此多了很多不必要的工厂接口和对应实现类，降低了代码的可读性，而抽象工厂模式则在扩展新产品时，
需要修改很多工厂实现类，违反了开放封闭原则，实际开发中选择哪种模式根据业务场景选择，下面是抽象工厂的实现方法
</p>

现在增加键盘产品，首先创建一个键盘产品接口`keyboard`

```java
public interface Keyboard {
    String getKeyboardName();    
}
```

分别创建戴尔`DellKeyboard`和联想`LenovoKeyboard`键盘产品实现类
```java
public class DellKeyboard implements Keyboard {
    @Override
    public String getKeyboardName() {
        return "戴尔键盘";
    }
}
```
然后在工厂接口中增加生产键盘方法，这里将电脑工厂概念换成了品牌工厂的概念
```java
public interface BrandFactory {
    Computer getComputer();
    Keyboard getKeyboard();
}
```
然后在各个品牌工厂中增加生产键盘的方法实现
```java
    @Override
    public Keyboard getKeyboard() {
        return new DellKeyboard();
    }
```
最后调用方式和工厂模式相同
```java
public static void main(String[] args) {
        BrandFactory brandFactory = new DellFactory();
        Computer computer = brandFactory.getComputer();
        Keyboard keyboard = brandFactory.getKeyboard();
        System.out.println(computer.getComputerName());
        System.out.println(keyboard.getKeyboardName());
}
```
## 建造者模式
<p style="text-indent:2em">
建造者模式主要用于复杂对象的构建，如果创建一个对象时需要传入很多个参数，并且构建这个对象的过程是规律的，则可以考虑使用建造者模式。
</p>

::: tip 建造者模式和抽象工厂模式的区别
建造者模式和抽象工厂模式同样属于创造类设计模式，同样封装了对象的构建过程，但抽象工厂生产的产品为产品族，属于一系列的产品（例如上面例子中的戴尔品牌下的各种产品）。而建造者模式重点为组装过程（逻辑），可以理解为使用工厂模式生产零件，建造者模式负责组装
:::

* ### 传统建造者模式

传统建造者模式共分为四个角色

* Product: 最终要创建的产品
* Builder：建造者类的接口，定义了一些制造行为，其中包括`builder()`方法，用于获取最终生产的产品
* BuilderImpl：建造者的实现类（可以有多个实现类，例如本例子中`GameComputerBuilder`和`WorkComputerBuilder`）
* Director：指挥者，负责具体的构建逻辑，`Builder`只负责准备零件，真正的组装逻辑由`Director`负责，以此来实现构建行为的解耦

下面看下具体实现方式

先定义一个具体产品`Computer`，这就是本例中最终生产的产品，省略了`getting`和`setting`方法
```java
public class Computer {
    private String cpu;
    private String displayCard;
    private String ram;
    private String disk;
}
```

定义生产者接口`ComputerBuilder`

```java
public interface ComputerBuilder {
    // 装CPU
    void installCPU();
    // 装显卡
    void installDisplayCard();
    // 装内存
    void installRAM();
    // 装硬盘
    void installDisk();
    // 返回最终产品
    Computer builder();
}
```

上述接口的具体实现这里只展示`GameComputerBuilder`
```java
public class GameComputerBuilder implements ComputerBuilder {

    private Computer computer;
    
    public GameComputerBuilder() {
        this.computer = new Computer();
    }

    @Override
    public void installCPU() {
        computer.setCpu("i7");
    }
    
    // 省略其他接口方法
    ·····
}
```
定义一个指挥者`ComputerDirector`，这里可以自定义构建逻辑
```java
public class ComputerDirector {
    // 这里代表了建造逻辑
    public void construct(ComputerBuilder computerBuilder) {
        computerBuilder.installCPU();
        computerBuilder.installDisk();
        computerBuilder.installRAM();
        computerBuilder.installDisplayCard();
    }
}
```

至此所需要的角色全部定义完成，调用方式如下
```java
public static void main(String[] args) {
        // 创建一个建造者
        ComputerBuilder computerBuilder = new GameComputerBuilder();
        // 创建一个领导者
        ComputerDirector director = new ComputerDirector();
        // 领导者指挥建造者构建产品
        director.construct(computerBuilder);
        // 获取最终产品
        Computer computer = computerBuilder.builder();
}
```

* ### 简化版建造者模式（使用调用链方式）

<p style="text-indent:2em">
这种方式主要是通过在产品内部定义一个静态类Builder，并使内部类的属性和产品类属性保持一致，调用内部类设置属性方法时，返回该内部类本身，通过调用链设置完参数后，调用build方法，将build属性传递给产品类，并返回最终产品对象，
这里的产品类更像是一个产品模板，通过build自定义调用，来构建同类但有差异的产品
</p>

下面是具体实现（省略部分`getting`和`setting`方法）。构建时，通过自定义的`Computer(Builder builder)`构造方法，将`builder`对象转换为`computer`对象

```java
public class Computer {

    private String cpu;
    private String displayCard;
    private String ram;
    private String disk;

    public Computer(Builder builder){
        this.cpu = builder.getCpu();
        this.displayCard = builder.getDisplayCard();
        this.ram = builder.getRam();
        this.disk = builder.getDisk();
    }

    // 内部静态类
    public static class Builder {
        private String cpu;
        private String displayCard;
        private String ram;
        private String disk;

        public Builder setCpu(String cpu) {
            this.cpu = cpu;
            return this;
        }
        
        // getting and setting
        ······
    }
}
```
调用方式如下
```java
public static void main(String[] args) {
        Computer computer = new Builder()
                            .setCpu("I7")
                            .setDisk("512G-SSD")
                            .setDisplayCard("RTX2080")
                            .setRam("32G")
                            .build();
}
```

## 适配器模式
<p style="text-indent:2em">
适配器模式，是为了将两个不相关的类或接口联系起来，通过调用Adapter类目标方法，间接调用源接口方法，适配器模式有三种实现方式：类的适配器模式、对象的适配器模式、接口的适配器模式。
</p>

<p style="text-indent:2em">
假设有这样一个场景，现在有一个type-C接口的手机需要充电，但现在只有Micro-usb接口的线，这时候我们就需要一个转换头将Micro-usb转换为type-C接口
</p>

定义一个手机类，包含充电方法
```java
public class Phone {
    public void charge() {
        System.out.println("开始使用type-C接口接收电流...");
    }
}
```
定义一个`Micro-usb`接口
```java
public interface MicroUsb {
    // 充电接口
    void charge();
}
```

* ### 类的适配器模式

::: tip 适用场景
如果希望一个类转换为满足另一个接口的类时，使用该方式，本例中就是将`Phone`的子类`adapter`转换为满足`MicroUsb`接口的类
:::

定义一个适配器`Adapter`，继承`Phone`类并实现了`MicroUsb`接口
```java
public class Adapter extends Phone implements MicroUsb {
    @Override
    public void output() {
        System.out.println("使用Micro-usb接口输出电流...");
        System.out.println("将Micro-usb转换为Type-C");

        // 转换为Type-C后，可以给手机充电了（这里间接的把phone类转换成了MicroUsb接口的实现类）
        super.charge();
    }
}
```
最终调用如下
```java
public static void main(String[] args) {
        MicroUsb microUsb = new Adapter();
        // 开始输出电流
        microUsb.output();
}
```
结果如下
```
使用Micro-usb接口输出电流...
将Micro-usb转换为Type-C
开始使用type-C接口接收电流...
```

* ### 对象的适配器模式

::: tip 对象的适配器模式适用场景
当希望将一个对象转换为满足另一个新接口的实例对象时，使用该方式，在新接口的实例对象中，调用源类对象中的方法。本例中`MicroUsb`的实现类通过持有`phone`对象，调用`charge`方法
:::

同样定义一个适配器`Adapter`，实现`MicroUsb`接口，并通过构造方法持有`phone`对象
```java
public class Adapter implements MicroUsb {

    private Phone phone;

    public Adapter(Phone phone) {
        this.phone = phone;
    }

    @Override
    public void output() {
        System.out.println("使用Micro-usb接口输出电流...");
        System.out.println("将Micro-usb转换为Type-C");

        // 转换为Type-C后，可以给手机充电了（这里间接的把phone类转换成了MicroUsb接口的实现类）
        phone.charge();
    }
}
```
调用如下
```java
public static void main(String[] args) {
    MicroUsb microUsb = new Adapter(new Phone());
    // 开始输出电流
    microUsb.output();
}
```

* ### 接口的适配器模式

::: tip 接口的适配器模式适用场景
当不希望实现一个接口中所有的方法时，可以创建一个抽象类Adapter，用空方法实现所有的接口方法，我们在使用的时候继承这个抽象类，并复写我们需要的方法即可
:::

具体实现很简单，这里就不写了

## 策略模式
<p style="text-indent:2em">
策略模式属于行为模式之一，本质上对一系列算法进行封装，根据不同情况进行调用，通常策略模式由三部分构成
</p>

* 封装类：通过持有策略接口的实例对象，对策略进行二次封装，防止外部直接对策略进行调用
* 策略接口：定义了策略行为方法
* 策略实现：实现了具体策略方法

先定义一个策略接口`EncryptStrategy`
```java
public interface EncryptStrategy {
    String encrypt(String str);
}
```
定义一个实现类实现策略接口
```java
public class MD5Strategy implements EncryptStrategy{
    @Override
    public String encrypt(String str) {
        return DigestUtils.md5DigestAsHex(str.getBytes(StandardCharsets.UTF_8));
    }
}
```
定义一个封装类，并通过构造方法持有`EncryptStrategy`对象
```java
public class StrategyContext {

    private EncryptStrategy encryptStrategy;

    public StrategyContext(EncryptStrategy encryptStrategy){
        this.encryptStrategy = encryptStrategy;
    }

    public String encrypt(String str) {
        return encryptStrategy.encrypt(str);
    }
}
```
调用如下
```java
public static void main(String[] args) {
        
        // 传入具体的策略对象
        StrategyContext context = new StrategyContext(new MD5Strategy());
        String s = context.encrypt("123456");
        System.out.println(s);
}
```
在实际开发中，可以借用`Spring`容器的概念，将所有算法注册成`Bean`，在`StrategyContext`中注入，以此降低对象的数量，同时为了遵循`开放封闭原则`，可以做如下改动：

在`EncryptStrategy`接口中加入`encryptName`方法
```java
String encryptName();
```
在对应实现类中实现该方法
```java
@Override
public String encryptName() {
    return "MD5";
}
```
在`StrategyContext`中，通过`@Autowired`将`List<EncryptStrategy>`注入进来，遍历对象，将每一个策略对象，以策略名字为key，放入map中。
```java
@Component
public class StrategyContext {

    private Map<String,EncryptStrategy> encryptStrategyMap = new HashMap<>();

    @Autowired
    public void setEncryptStrategyMap(List<EncryptStrategy> encryptStrategyList) {
        encryptStrategyList.forEach(encryptStrategy -> this.encryptStrategyMap.put(encryptStrategy.encryptName(),encryptStrategy));
    }
    
    // 通过策略名称调用对应对象的行为方法
    public String encrypt(String encryptName, String str) {
        return this.encryptStrategyMap.get(encryptName).encrypt(str);
    }
}
```
调用如下
```java
String s = strategy.encrypt("MD5","123456");
```

