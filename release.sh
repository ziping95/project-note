#!/bin/bash

cd ../
mkdir vue-temp
cd project-note
mv node_module docs/.vuepress/dist/* -t ../vue-temp
