# CSS样式
## 隐藏滚动条
```css
Chrome,Safari
.editor-upload-simple::-webkit-scrollbar { width: 0 !important }
IE 10+
.editor-upload-simple { -ms-overflow-style: none; }
Firefox
.editor-upload-simple { overflow: -moz-scrollbars-none; }
```
