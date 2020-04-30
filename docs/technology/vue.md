# Vue
## 常用API
 * 页面渲染后执行
 ```js
this.$nextTick(() => {
    this.$refs.myTree.setCurrentKey('4')
})
```

* 获取元素属性

`this.$refs.catalog.offsetWidth`


* 获取屏幕属性

`document.documentElement.clientHeight`

* 获取当前元素位置或四边距离

`dom.getBoundingClientRect()`

* 调用父组件传入的方法

`this.$emit('queryBatch')`

* 获取父组件

`this.$parent.handleSteps(this.book.activateType)`

* 监听键盘事件

`window.addEventListener('keydown', this.keyDown)`

* 子组件接收父组件参数
```js
props: {
      book: {
        type: Object,
        default: function () {
          return {
            id: '',
            img: '',
            activateType: 'all'
          }
        }
      }}
```


* 全局绑定js对象，在`main.js`中加入，调用`this.$common`
```javascript
Vue.prototype.$common = common
```

## 点击事件执行两次问题
通常使用`@click.stop`阻止冒泡即可，但如果自定义的点击事件事件是在`<a><a/>`这种自身就带有点击事件的元素上，应该使用`@click.prevent`来阻止自身行为
