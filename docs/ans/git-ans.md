## 首次提交被拒绝
如果刚创建的git仓库首次提交被拒绝，一般是因为远程仓库有修改过`README.md`导致本地的提交记录和远程仓库的记录完全不相同，git会认为你写错了远程仓库地址，这时候只需要在执行`git pull`时候告诉git你没写错地址即可
``` git
git pull origin master --allow-unrelated-histories
```
