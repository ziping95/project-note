#!/bin/bash

temp="vue-temp"
currentFolder="project-note"
branchName="release"


cd ../
#文件夹不存在则创建
if [ ! -d "./${temp}" ];then
  mkdir ${temp}
  else
  echo "删除文件夹"
  rm -rf ./${temp}
  mkdir ${temp}
fi

cd ${currentFolder}
cp -r node_modules/* docs/.vuepress/dist/* -t ../${temp}

commit=$(git status -s)
if [ ! -n "${commit}" ];then
    echo "已全部提交，继续执行"
else
	echo "当前分支有未提交文件，请先提交后再执行脚本"
	exit
fi

git checkout ${branchName}

rm -rf !(.git|.gitignore)

mv ../${temp}/* ./
nowData="`date +%Y-%m-%d` 发布"
echo ${nowData}
#git add -A
#git commit -m ${nowData}
#git push

#git checkout master


