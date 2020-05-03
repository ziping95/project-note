#!/bin/bash

temp="vue-temp"
currentFolder="project-note"
branchName="release"

# -e遇到未正确执行的命令立刻退出
# -u 遇到未定义的变量，报错（但是不会退出）
set -e -u

cd ../
#文件夹不存在则创建
if [ ! -d "./${temp}" ];then
  echo "创建临时文件夹"
  mkdir ${temp}
  else
  echo "已存在临时文件夹，清空临时文件夹"
  rm -rf ./${temp}/*
fi

cd ${currentFolder}
cp -r node_modules docs/.vuepress/dist -t ../${temp}
mv ../${temp}/dist/* ../${temp}
rm -rf ../${temp}/docs

commit=$(git status -s)
if [ ! -n "${commit}" ];then
    echo "已全部提交，继续执行"
else
	echo "当前分支有未提交文件，请先提交后再执行脚本"
	exit
fi

git checkout ${branchName}
ls | xargs rm -rf

mv ../${temp}/* ./
nowData="`date +%Y-%m-%d` 发布"
echo ${nowData}
git add -A
git commit -m ${nowData}
git push

git checkout master


