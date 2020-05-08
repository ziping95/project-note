# 多线程
### 目录
----------
* [锁](#锁)
    * [同步关键字（synchronized）](#synchronized（同步关键字）)
    * [可重入锁（reentrantlock）](#reentrantlock（可重入锁）)
    * [读写锁（readwritelock）](#readwritelock（读写锁）)
    * [信号量（Semaphore）](#semaphore（信号量）)
    * [计数器（CountDownLatch）](#countdownlatch（计数器）)
    * [栅栏（CyclicBarrier）](#cyclicbarrier（栅栏）)
* [线程通信](#线程通信)
    * [stop（强制终止—被弃用）](#stop（强制终止—被弃用）)
    * [suspend和resume（被弃用）](#suspend和resume（被弃用）)
    * [wait和notify](#wait和notify)
    * [park和unpark](#park和unpark)
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

### synchronized（同步关键字）

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

### ReentrantLock（可重入锁）

`ReentrantLock`是`Lock`接口的一个实现类，具有独享，可重入特性，并且支持公平锁、非公平锁两种模式

在使用时，通过`lock.lock()`加锁，通过`lock.unlock()`解锁。

值得注意的是，在加锁的同时，会修改锁内的一个计数标志位，记录当前获取锁的次数，如果执行了两次`lock.lock()`，则对应的计数为2，且在释放锁时，也必须进行两次`lock.unlock()`解锁，否则其他线程依旧拿不到这把锁

另外，如果线程在获取锁的时候被阻塞住了，并且我们想手动中断这个被阻塞的线程，则必须使用`lock.lockInterruptibly()`来争抢锁，否则无法中断线程

`ReentrantLock`内部通过调用`sync.lock()`方法实现，Sync继承自`AbstractQueuedSynchronizer`（抽象队列同步器简称`AQS`）类，该类体现了设计模式中的模板方法，对锁的关键步骤进行了抽象，比如加锁，解锁，将线程放入链表中，其中尝试加锁，尝试解锁由具体的子类复写实现

在`JDK`提供多种锁的实现中，均用到了这个类，先来看一下`Sync`的子类`NonfairSync`（非公平锁）对`lock`方法的实现

```java
final void lock() {
    // 这里先尝试进行CAS操作修改锁的标志位
    // 如果修改成功，则将当前线程赋予exclusiveOwnerThread属性，记录当前哪个线程获得了这把锁
    if (compareAndSetState(0, 1))
        setExclusiveOwnerThread(Thread.currentThread());
    else
    // 修改失败，为了保证可重入性，会尝试获取锁
        acquire(1);
}
```
在`acquire`方法中做了两次尝试，其方法分别是调用复写的`tryAcquire()`方法和将当前线程放入链表并阻塞的方法`acquireQueued()`
```java
public final void acquire(int arg) {
    if (!tryAcquire(arg) &&
        acquireQueued(addWaiter(Node.EXCLUSIVE), arg))
        selfInterrupt();
}
```
在`tryAcquire()`方法中调用了`nonfairTryAcquire()`方法，这个方法保证了可重入性
```java
final boolean nonfairTryAcquire(int acquires) {
    // 先获取当前线程
    final Thread current = Thread.currentThread();
    int c = getState();
    // 如果当前线程无锁，则尝试CAS操作修改标志位，成功则保存当前线程为锁持有者
    if (c == 0) {
        if (compareAndSetState(0, acquires)) {
            setExclusiveOwnerThread(current);
            return true;
        }
    }
    // 如果这把锁已经有持有者了，则判断当前线程是否是锁的持有者。
    // 如果是，则累加标志位。
    else if (current == getExclusiveOwnerThread()) {
        int nextc = c + acquires;
        if (nextc < 0) // overflow
            throw new Error("Maximum lock count exceeded");
        setState(nextc);
        return true;
    }
    // 以上判断都不是则获取锁失败
    return false;
}
```
我们可以看到，在重入锁的时候会对锁的标志位进行累加，这也验证了`lock()`和`unlock()`必须成对出现，否则会进入死循环

执行完该方法后，如果没有获取到锁，则调用`acquireQueued()`尝试将当前线程放入队列中并阻塞等待

```java
final boolean acquireQueued(final Node node, int arg) {
    boolean failed = true;
    try {
        boolean interrupted = false;
        for (;;) {
            // 自旋判断链表中的前一节点是否为头节点，如果是，则再尝试获取一次锁
            // 如果获取到了则返回
            final Node p = node.predecessor();
            if (p == head && tryAcquire(arg)) {
                setHead(node);
                p.next = null; // help GC
                failed = false;
                return interrupted;
            }
            // 如果依旧没获取到则将线程放入当前节点并阻塞
            if (shouldParkAfterFailedAcquire(p, node) &&
                parkAndCheckInterrupt())
                interrupted = true;
        }
    } finally {
        if (failed)
            cancelAcquire(node);
    }
}
```
这里通过`LockSupport.park(this)`方式阻塞，具体代码不展示了，下面看一下解锁`unlock()`方法是如何实现的

在代码中可以看到，同样调用了`AQS`类中的方法，只不过解锁改为了`release()`方法，在该方法中调用了子类复写的`tryRelease()`方法

```java
protected final boolean tryRelease(int releases) {
    // 先计算释放后的标志位
    int c = getState() - releases;
    // 判断解锁的进程是否是锁持有者
    if (Thread.currentThread() != getExclusiveOwnerThread())
        throw new IllegalMonitorStateException();
    boolean free = false;
    // 如果标志位为0，说明没有任何一个线程持有这把锁了，因此将持有者属性设为null
    if (c == 0) {
        free = true;
        setExclusiveOwnerThread(null);
    }
    // 如果不是0，说明这个锁有重入的线程，因此仅仅减少一层锁，但该锁的线程持有者依旧不变
    setState(c);
    return free;
}
```
由上可知，当锁完全释放后，该方法返回一个true，程序返回到`release()`方法中继续执行，去通知后面的线程唤醒并执行
```java
public final boolean release(int arg) {
    if (tryRelease(arg)) {
        Node h = head;
        // 当锁释放后，判断链表中是否还有其他线程，如果有则通过unparkh唤醒下一个节点的线程
        if (h != null && h.waitStatus != 0)
            unparkSuccessor(h);
        return true;
    }
    return false;
}
```

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
注意`await()`会释放锁

### ReadWriteLock（读写锁）

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

### Semaphore（信号量）

`Semaphore`多用来接口限流，通过给线程发放凭证来保证同一资源被访问次数，其实就是一种共享锁的一种体现，使用起来很简单

```java
Semaphore semaphore = new Semaphore(5);
semaphore.acquire();
// todo: do something
semaphore.release();
```
整体来说先**获取令牌 --> 执行逻辑 --> 释放令牌**，其中实现也和`AQS`类相关，先来看一下获取令牌的操作原理

在调用`acquire()`方法时，实际就是调用了`Sync`类的`acquireSharedInterruptibly(1)`方法，上面我们写过，`Sync`继承自`AbstractQueuedSynchronizer`类

在`acquireSharedInterruptibly`方法中，开始尝试获取信号量

```java
public final void acquireSharedInterruptibly(int arg) throws InterruptedException {
    if (Thread.interrupted())
        throw new InterruptedException();
    // 尝试获取信号量，如果信号量不足时，尝试将当前线程阻塞住
    if (tryAcquireShared(arg) < 0)
        doAcquireSharedInterruptibly(arg);
}
```
通过调用子类复写的`tryAcquireShared`方法，最终调用`nonfairTryAcquireShared`方法，在该方法中先计算出来如果发放令牌后，信号量的剩余量

如果小于0，则不进行CAS操作，并返回
```java
final int nonfairTryAcquireShared(int acquires) {
    // 自旋判断
    for (;;) {
        // 先获取当前剩余信号量
        int available = getState();
        // 计算发放后的剩余信号量
        int remaining = available - acquires;
        // 当信号量不足或CAS操作成功时返回剩余信号量
        if (remaining < 0 ||
            compareAndSetState(available, remaining))
            return remaining;
    }
}
```
代码返回`acquireSharedInterruptibly`方法继续执行，如果返回的剩余信号量小于零，则说明无信号量可用，则调用`doAcquireSharedInterruptibly`方法将当前线程阻塞住

在这个方法中阻塞逻辑和上面独享锁的`acquireQueued()`方法逻辑相似，依旧是先判断上一个节点是否是头节点，如果是则重新尝试获取信号量，否则将当前线程加入链表中阻塞，只不过链表的节点属性变为了`Node.SHARED`（共享锁）
```java
private void doAcquireSharedInterruptibly(int arg) throws InterruptedException {
    final Node node = addWaiter(Node.SHARED);
    boolean failed = true;
    try {
        for (;;) {
            // 获取上一个节点
            final Node p = node.predecessor();
            // 判断是否是头节点
            if (p == head) {
                // 重新尝试获取信号量
                int r = tryAcquireShared(arg);
                if (r >= 0) {
                    // 获取到后，将节点设置为头节点，并返回
                    setHeadAndPropagate(node, r);
                    p.next = null; // help GC
                    failed = false;
                    return;
                }
            }
            // 如果不是头节点或者没获取到信号量，则调用下面方法进行阻塞线程
            if (shouldParkAfterFailedAcquire(p, node) &&
                parkAndCheckInterrupt())
                throw new InterruptedException();
        }
    } finally {
        if (failed)
            cancelAcquire(node);
    }
}
```
在这个方法中阻塞线程依旧采用的是`pack`/`unpack`机制，下面看一下，释放信号量是如何实现的
```java
public final boolean releaseShared(int arg) {
    // 先尝试释放，如果成功则唤醒后面阻塞的线程重新获取信号量
    if (tryReleaseShared(arg)) {
        doReleaseShared();
        return true;
    }
    return false;
}
```
其中在`tryReleaseShared()`方法是需要在子类中进行复写，具体实现逻辑和之前的`ReentrantLock`相似，依旧是通过判断标志位，进行`CAS`操作来实现的
```java
protected final boolean tryReleaseShared(int releases) {
    for (;;) {
        // 获取当前信号量
        int current = getState();
        // 释放后的信号量
        int next = current + releases;
        if (next < current) // overflow
            throw new Error("Maximum permit count exceeded");
        // CAS操作成功后返回
        if (compareAndSetState(current, next))
            return true;
    }
}
```
该方法执行完后返回，`releaseShared`方法调用`doReleaseShared`来唤醒后面的线程

### CountDownLatch（计数器）

`AQS`另一个重要应用就是在`CountDownLatch`中

应用场景为：主线程开启了多个线程执行任务，并且主线程需要等所有子线程执行完任务后在，再继续执行后面的逻辑，可以使用如下代码

```java
CountDownLatch countDownLatch = new CountDownLatch(5);
// todo: 通知子线程执行任务
// 主线程 调用await方法进行阻塞，当count为0时，自行唤醒主线程
countDownLatch.await();
// 各个子线程执行完后调用countDown()方法进行减一
countDownLatch.countDown();
```

其实现原理与信号量相同，都是通过调用`AQS`中的`acquireSharedInterruptibly` / `releaseShared`方法，进行阻塞和释放

通过`CountDownLatch`复写的`tryAcquireShared`方法，来判断当前计数是否为零
```java
protected int tryAcquireShared(int acquires) {
    return (getState() == 0) ? 1 : -1;
}
```
不是零的话返回-1 然后在`acquireSharedInterruptibly`方法中判断`tryAcquireShared`返回值，如果小于零则阻塞当前线程

在子线程在调用`countDown()`时，实际做了一次释放资源的操作，这个操作同样通过一层层调用，最终调用到`CountDownLatch`复写的`tryReleaseShared`方法

```java
protected boolean tryReleaseShared(int releases) {
    // 循环判断
    for (;;) {
        int c = getState();
        // 如果为0后，返回false，可以理解为抛异常
        if (c == 0)
            return false;
        int nextc = c-1;
        // 通过CAS修改状态位，如果是0返回true，用于后续判断唤醒线程使用
        if (compareAndSetState(c, nextc))
            return nextc == 0;
    }
}
```
执行完以上方法后调用`doReleaseShared`唤醒主线程

### CyclicBarrier（栅栏）

这个应用场景和`CountDownLatch`相反，通常用来多个线程并发执行

比如想要批量执行SQL，一次性执行5条SQL，那么前四个线程会将SQL缓存起来，并阻塞，当第五个线程来的时候，同时唤醒前四个线程，并执行，可以看下面的例子

```java
public static void main(String[] args) {
        // 当线程满了后，执行的回调逻辑
        Runnable action = new Runnable() {
            @Override
            public void run() {
                // todo: 批量执行SQL
                System.out.println("批量执行了SQL");
            }
        };
        CyclicBarrier cyclicBarrier = new CyclicBarrier(5,action);
        Runnable task = new Runnable() {
            @Override
            public void run() {
                try {
                    // todo：将SQL缓存起来
                    Thread.sleep(1000);
                    System.out.println("生成SQL完成");
                    cyclicBarrier.await();
                } catch (InterruptedException | BrokenBarrierException e) {
                    e.printStackTrace();
                }
            }
        };
        for (int i = 0; i < 5; i++) {
            Thread thread = new Thread(task);
            thread.start();
        }
    }
```
下面看下其原理实现，在调用`await()`方法后会在其内部调用一个`dowait()`方法，该方法是`CyclicBarrier`的核心逻辑，我们可以分为两部份来看

首先看线程满了之后，执行回调的部分，在该方法内部，会先判断当前还可以阻塞的线程数，如果为0时，则开始调用`CyclicBarrier`初始化时，传入的`Runnable`

```java
int index = --count;
// 判断是否还有阻塞线程的名额
if (index == 0) {  // tripped
    boolean ranAction = false;
    try {
        final Runnable command = barrierCommand;
        // 如果线程已满，则开始调用Runnable
        if (command != null)
            command.run();
        ranAction = true;
        // Runnable执行完成后，唤醒当前批次阻塞的所有线程，并开始下一轮的初始化复赋值（count重新赋值）
        nextGeneration();
        return 0;
    } finally {
        if (!ranAction)
            breakBarrier();
    }
}
```
唤醒当前批次所阻塞的线程操作在`nextGeneration`方法中，在这个方法中不但唤醒了线程，并且对下一轮的属性进行了赋值
```java
private void nextGeneration() {
    // 唤醒本轮所有线程
    trip.signalAll();
    // 开启下一轮
    count = parties;
    generation = new Generation();
}
```
在`CyclicBarrier`这个类中，我们可以看到`trip`其实就是一个`Condition`
```java
/** The lock for guarding barrier entry */
private final ReentrantLock lock = new ReentrantLock();
/** Condition to wait on until tripped */
private final Condition trip = lock.newCondition();
```
而`signalAll`这个接口方法是由`AbstractQueuedSynchronizer`的内部类`ConditionObject`实现的。

同样阻塞的线程被保存到一个链表中，通过遍历链表来唤醒线程，这里的唤醒线程同样通过`LockSupport.unpark()`方式实现
```java
private void doSignalAll(Node first) {
    lastWaiter = firstWaiter = null;
    do {
        Node next = first.nextWaiter;
        first.nextWaiter = null;
        transferForSignal(first);
        first = next;
    } while (first != null);
}
```
以上就是`CyclicBarrier`控制并发执行的主流程，而对于线程未满的情况，将线程阻塞住的流程，就相对简单了
```java
for (;;) {
    try {
        if (!timed)
            // 如果未指定超时时间，则使用Condition接口的await()方法将线程阻塞住
            trip.await();
        else if (nanos > 0L)
            nanos = trip.awaitNanos(nanos);
        } catch (InterruptedException ie) {
        // todo: do something
        }
    } finally {
        lock.unlock();
    }
```

## 线程通信

Java中线程之间的通信一般有`stop`、`suspend` / `resume`、`wait` / `notify`、`park` / `unpark`

### Stop（强制终止—被弃用） 

* `stop()`是过时的，不建议使用
* `stop()`是一种强制中断，并不关心当前线程状态和代码执行逻辑，一但调用，则立即终止，如果在有锁的情况下，也不会释放锁，造成死锁
* `stop()`会破坏代码的原子性逻辑，因为调用时，我们并不清楚线程执行到那行逻辑，有可能会造成数据不一致

### suspend和resume（被弃用）

线程通过调用`suspend()`方法阻塞，通过调用`resume()`唤醒

需要注意的是这种方式也容易造成死锁，造成死锁的情况有两种
* 如果在同步代码中调用`suspend()` / `resume()`方法，线程在阻塞时并不会释放对象锁，导致无法执行`resume()`
* 如果调用`resume()`在`suspend()`方法之前，同样会造成死锁

例如以下两种代码，均会造成**死锁**
```java
public void suspendAndResume() throws InterruptedException {
    Object o = new Object();
    Thread thread = new Thread(() -> {
        int i = 0;
        synchronized (o) {
            System.out.println("开始休眠");
            Thread.currentThread().suspend();
        }
    });
    thread.start();
    Thread.sleep(2000);
    System.out.println("即将唤醒子线程");
    // 由于suspend方法不会释放锁，因此代码到这里就会死锁
    synchronized (o) {
        thread.resume();
    }
}
```
针对这种死锁的情况，推荐使用`wait` / `notify` 方式，这种方式会在阻塞时自动释放锁

第二种**死锁**情况，是由于在调用`suspend()`方法前已经调用了`resume()`方法
```java
public void suspendAndResume() throws InterruptedException {
    Object o = new Object();
    Thread thread = new Thread(() -> {
        try {
            System.out.println("开始休眠");
            Thread.sleep(3000);
            System.out.println("准备调用suspend()");
            Thread.currentThread().suspend();
            System.out.println("唤醒了");
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    });
    thread.start();
    Thread.sleep(1000);
    System.out.println("准备调用resume()");
    // 这里由于有限调用了resume(),因此当线程一旦调用suspend()方法后，在本代码中就无法唤醒了
    thread.resume();
}
```
针对由于这种方式引起的死锁，推荐使用`park` \ `unpark`机制阻塞线程

### wait和notify

`wait`和`notify`方式是基于对象监视器来进行线程阻塞的，在调用`wait()`方法后，会将线程放入该对象的等待队列中，并且会主动放弃资源（锁）。当调用`notify()`方法时，会将一个线程从等待队列中拿出来，重新进行资源的争抢

由于`wait`和`notify`会对对象头中的锁标志位进行修改，因此他们必须在同步代码块中使用。

::: tip wait和sleep的区别
1. 所属类不同`wait`是来自`Object`类，而`sleep`来自`Thread`类
2. `wait`是基于对象监视器实现的，且必须在同步代码块中使用，会自动释放锁，而`sleep`可以在任意处使用，但不会释放锁
:::

值得注意的是，虽然`wait()`方法会自动释放锁，但对代码的执行顺序还是有要求的，`notify()`方法必须在`wait()`后执行，否则会造成死锁，下面是**死锁**示例

```java
public void waitAndNotify() throws InterruptedException {
    // 这种方式对唤醒的调用顺序有要求
    Thread thread = new Thread(() -> {
        int i = 0;
        System.out.println("线程开始执行run方法");
        try {
            Thread.sleep(3000);
            synchronized (this) {
                System.out.println("子线程开始休眠");
                // 由于主线程先执行了notify()方法，因此在这里会造成死锁
                this.wait();
                System.out.println("子线程被唤醒");
            }
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    });
    thread.start();
    Thread.sleep(1000);
    synchronized (this) {
        this.notify();
        System.out.println("主线程唤醒子线程");
    }
}
```
::: warning 伪唤醒
代码中不应该用if判断是否应该进入等待状态，原因是处于等待状态的线程可能会因为CPU、操作系统调度等底层原因造成伪唤醒。

因此官方建议在循环中检查等待条件，例如
`
while(判断等待条件) { 
    // todo: 线程等待 
}
`
:::

上面的代码展示了`wait`和`notify`方式由于调用顺序问题造成死锁的情况，为了弥补这种问题，`JDK`提供了另外一种机制`park` \ `unpark`

### park和unpark

