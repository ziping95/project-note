# 集合

## Map
Java中，一般耳熟能详的Map通常有这么几类（`HashMap`、`Hashtable`、`LinkedHashMap`、`TreeMap`）

他们之间的关系如下图所示

![](../.vuepress/public/img/collection/map-extends.png)
这几类Map的特点
* `HashMap` 用的最多，允许一个key为`null`，无序，非线程安全，在需要线程安全的场景下需要使用`Collections`的`synchronizedMap`方法或者`ConcurrentHashMap`类
* `ConcurrentHashMap` 线程安全，支持高并发，高吞吐量的map，内部实现采用分段锁技术
* `LinkedHashMap`有序的Map，是`HashMap`的一个子类，记录了插入的顺序，在使用`Iterator`遍历时，会按照插入顺序进行输出
* `TreeMap` 实现了`SortedMap`接口，也是有序的，默认按照字典序排序，也可以自定义比较器进行排序
* `Hashtable` 被弃用的类，功能和`HashMap`相似，线程安全，但性能比较差，因为同一时间只有一个线程可以执行写操作，没有遵循驼峰命名

这里就重点总结HashMap相关的内容

### HashMap 存储结构
`HashMap`在`JDK7`中仅仅是数组+链表，而在`JDK8`中的存储结构优化为了数组+链表+红黑树

![](../.vuepress/public/img/collection/red-black-tree.png)
这样做的目的是如果在`key`很多的情况下，大量的数据由于哈希碰撞，聚集在同一个下标的元素上，这时链表的查询效率会退化成O(n)

`HashMap`存储数据时，是先计算`key`的哈希值，然后和数组长度-1相与（在`JDK7`中是进行取模运算）得到的值必定为数组中某一个下标的值，因此将该`key`放入这个数组所对应的链表中

这里用`JDK8`举例，看一下`put`方法时是如何处理的，在`put`方法中，最终调用了`putVal`方法

```java
final V putVal(int hash, K key, V value, boolean onlyIfAbsent,boolean evict) {
    Node<K,V>[] tab; Node<K,V> p; int n, i;
    // 对数组初始化，默认数组初始化长度为16
    if ((tab = table) == null || (n = tab.length) == 0)
        n = (tab = resize()).length;
    // Hash值和数组长度减一相与后，判断对应下标的数组元素中是否为空，如果为空则直接新建一个节点放入数组中
    if ((p = tab[i = (n - 1) & hash]) == null)
        tab[i] = newNode(hash, key, value, null);
    else {
        Node<K,V> e; K k;
        // 如果对应下标元素中已经存在节点，则判断这个节点中的key和当前key是否一致
        // 如果一致，则把旧节点赋予e，后续直接对节点e的value进行覆盖操作即可
        if (p.hash == hash && ((k = p.key) == key || (key != null && key.equals(k))))
            e = p;
        // 判断当前链表是否已经转换为红黑树，如果是，则进行红黑树插入值处理
        else if (p instanceof TreeNode)
            e = ((TreeNode<K,V>)p).putTreeVal(this, tab, hash, key, value);
        else {
            // 当链表中的头元素中的key不匹配时，进入到这里，遍历链表
            for (int binCount = 0; ; ++binCount) {
                // 判断当前链表节点的next元素是否为空，如果为空，则直接新建节点放入next即可
                if ((e = p.next) == null) {
                    p.next = newNode(hash, key, value, null);
                    // 判断链表长度是否超过8，若是则将链表转换为红黑树
                    if (binCount >= TREEIFY_THRESHOLD - 1) // -1 for 1st
                        treeifyBin(tab, hash);
                    break;
                }
                // 若next节点不为空，则判断next节点的key是否和当前key相同
                // 如果相同，退出循环，后续进行覆盖value操作
                if (e.hash == hash && ((k = e.key) == key || (key != null && key.equals(k))))
                    break;
                // 如果next节点的key不一致，则将next节点赋予当前节点，继续遍历
                p = e;
            }
        }
        // 如果通过以上逻辑发现有相同的key，则在这里进行value值的覆盖，并返回旧数据
        if (e != null) { // existing mapping for key
            V oldValue = e.value;
            if (!onlyIfAbsent || oldValue == null)
                e.value = value;
            afterNodeAccess(e);
            return oldValue;
        }
    }
    ++modCount;
    // 判断数组元素数量是否超过长度*负载因子，是否需要扩容
    if (++size > threshold)
        resize();
    afterNodeInsertion(evict);
    return null;
}
```
从以上代码中可以看出，在`JD8`中插入数据时采用的是尾插法，同时在代码中我们可以看到`modCount`属性，这个属性记录的是当前容器对象被修改的次数，用于快速失败机制，所有非线程安全地集合类都存在该属性

::: tip Fail-Fast 策略
我们知道 java.util.HashMap 不是线程安全的，因此如果在使用迭代器的过程中有其他线程修改了map，那么将抛出ConcurrentModificationException，这就是所谓fail-fast策略。

这一策略在源码中的实现是通过 modCount 属性。modCount 顾名思义就是修改次数，对HashMap 内容的修改都将增加这个值。
在迭代器初始化过程中会将这个值赋给迭代器的 expectedModCount。
在迭代过程中，不断判断 modCount 跟 expectedModCount 是否相等，如果不相等就表示已经有其他线程修改了 Map，立刻抛出 ConcurrentModificationException 异常。
注意， modCount 声明为 volatile，以保证线程之间修改的可见性。
:::


