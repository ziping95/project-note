#!/bin/bash

npm run docs:build

currentFolder="project-note"
targetDirName="release-note"

# -e遇到未正确执行的命令立刻退出
# -u 遇到未定义的变量，报错（但是不会退出）
set -e -u

cd ../${targetDirName}
ls | grep -v ".git" | grep -v "index.html" | xargs rm -rf

cd ../${currentFolder}
cp -r node_modules docs/.vuepress/dist -t ../${targetDirName}

cd ../${targetDirName}
mv ./dist/* ./
rm -rf ./dist

nowData="`date "+%Y-%m-%d %H:%M"` 发布"
echo ${nowData}
git add .
git commit -m "${nowData}"
git push


