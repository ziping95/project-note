# 多线程

## 锁

由于多个线程对同一个对象进行写操作，其必然出现资源争抢，引发线程安全问题，而锁就是为了解决这种问题而诞生的，java中如下几种锁

>* 自旋锁：为了不放弃CPU执行事件，循环使用`CAS`技术对数据更新，直至成功，使用`while(true)`方式循环`CAS`操作为自旋锁的典型实现
>* 悲观锁：在执行前假定会发生冲突，所以从读取数据开始就对行为上锁，参考`synchronized`关键字
>* 乐观锁：提出了版本的概念，在读取数据时，会将当前数据版本号一并读出来，每次写时候会对版本进行修改，其他线程写的时候，会先判断当前版本号和读取时是否一致，一致才会进行写入
>* 独享锁（写）：给资源加上写锁，线程可以修改资源，其他线程不能再加锁，`synchronized`也属于这种
>* 共享锁（读）：给资源加上读锁，其他线程也只能加读锁，不能加写锁
>* 可重入锁、不可重入锁：线程拿到一把锁后，可以自由进入同一把锁所同步的其他代码，`synchronized`属于可重入锁
>* 公平锁、非公平锁：争抢锁的顺序，按照先来后到的顺序

Java中有几种重要的锁实现方式：`synchronized`，`ReentrantLock`，`ReentrantReadWriteLock`

### 同步关键字`synchronized`

这属于java中最基本的线程通信机制，基于对象监视器实现，上面介绍过属于可重入，独享，悲观锁类型，在使用时，可用于方法（静态/非静态），同步代码块，同时由于`Happens-Before`规则的存在，`synchronized`也可以用来保证可见性

::: warning 锁失效问题
`synchronized`在非静态方法上，监视器所监视的对象为当前对象`this`，因此如果多个线程是通过不同对象调用该方法时，同步作用失效。静态方法由于是监视类对象，因此不存在该问题
:::

在`synchronized`关键字中，有一种场景为`锁粗化`，意思为，如果一段代码被频繁调用执行，而这段代码中有两个以上的`synchronized`并且对象锁是同一个时，在`JIT`判断是否属于热点代码，若是，则会将两个锁合并为一个使用。
例如下代码
::: tip Java代码执行过程
1. 源代码经javac编译成字节码，class文件
2. 程序字节码经过`JIT`环境变量进行判断，是否属于“热点代码”（多次调用的方法，或循环等），若是，走JIT编译为具体硬件处理器（如sparc、intel）机器码，若不是，则直接由解释器解释执行
3. 操作系统及类库调用
:::
```java
public void add() {
    synchronized (this) {
        i++;
    }
    synchronized (this) {
        i++;
    }
}
```
如果`JIT`判断出以上代码在项目中存在多次调用，会自动将以上代码优化为
```java
synchronized (this) {
     i++;
     i++;
}
```
还有一种情况为`锁消除`，同样属于`JIT`优化后的结果，我们都知道`StringBuffer`是线程安全的，其`append`方式就是使用了`synchronized`修饰
```java
public void append() {
        StringBuffer stringBuffer = new StringBuffer();
        stringBuffer.append("1");
        stringBuffer.append("2");
        stringBuffer.append("3");
}
```
由于这段代码使用的是局部变量，不会存在线程安全问题，因此`JIT`会在编译期将其内部的`synchronized`关键字消除

`synchronized`实际会修改对象头中的一个标志位来表明当前对象状态，其加锁过程会经历 **偏向锁-->轻量级锁（CAS操作修改标志位）-->重量级锁（Monitor监视器）**，偏向锁可以在启动时通过参数关闭

偏向锁，仅仅是第一次有用（实际就是无锁，因为没有出现资源争抢），只要当前对象出现过争抢资源时，就会变成轻量级锁。

轻量级锁，通过不断的自旋判断当前对象是否有锁，若没锁，则绑定当前线程（加锁），如果有锁就会不断的自旋进行`CAS`，但自旋会消耗过多的性能，达到一定次数后，该对象会升级成重量级锁，进入阻塞

### ReentrantLock

`ReentrantLock`是`Lock`接口的一个实现类，具有独享，可重入特性，并且支持公平锁、非公平锁两种模式

在使用时，通过`lock.lock()`加锁，通过`lock.unlock()`解锁。

值得注意的是，在加锁的同时，会修改锁内的一个计数标志位，记录当前获取锁的次数，如果执行了两次`lock.lock()`，则对应的计数为2，且在释放锁时，也必须进行两次`lock.unlock()`解锁，否则其他线程依旧拿不到这把锁

另外，如果线程在获取锁的时候被阻塞住了，并且我们想手动中断这个被阻塞的线程，则必须使用`lock.lockInterruptibly()`来争抢锁，否则无法中断线程

`Condition`是`ReentrantLock`中的一个功能点，其作用是配合`Lock`使用可以达到`wait`/`notify`相同的作用，并且可以更加精确地控制唤醒某个具体线程（底层是`park`/`unPark`机制）。

假设现在有个容器，并且有两个线程，分别是生产者线程和消费者线程，当容器里没东西的时候消费者线程则进入阻塞等待，当生产者生产完东西时，唤醒消费者线程进行消费，反之当容器满的时候生产者阻塞，当有空余位置时，消费者唤醒生产者去继续生产
```java
private final static Lock lock = new ReentrantLock();
// 生产者对应的条件
private final static Condition producerCondition = lock.newCondition();
// 消费者对应的条件
private final static Condition consumerCondition = lock.newCondition();

// 消费者如果发现容器空了，则进入对应的条件阻塞
consumerCondition.await();
// 生产者生产完东西放入容器后，唤醒消费者消费
consumerCondition.signal();
// 生产者发现容器满了，则进入对应的条件阻塞
producerCondition.await();
// 消费者消费完，通知生产者继续生产
producerCondition.signal();
```

### ReadWriteLock 

`ReadWriteLock`是一个读写锁的接口，其典型实现为`ReentrantReadWriteLock`，读写锁实际是维护一对关联锁，一个只用于读操作，一个用于写操作，读锁是一个共享锁，可以由多个线程同时持有，而写锁是排他锁

当所有的读操作完成时，才会进行加写锁操作。适用于读取比写入多的场景，例如：缓存

在读写锁中有一个`锁降级`的概念，指把写锁降级为读锁。把持住当前拥有的写锁同时，再获取到读锁，随后释放写锁的过程。

我们可以看到在`ReentrantReadWriteLock`中，同时维护了读锁和写锁
```java
/** Inner class providing readlock */
private final ReentrantReadWriteLock.ReadLock readerLock;
/** Inner class providing writelock */
private final ReentrantReadWriteLock.WriteLock writerLock;
```


