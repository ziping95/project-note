module.exports = {
    title: 'Ziping',  // 设置网站标题
    description: 'note',
    base: '/note/',
    themeConfig: {
        displayAllHeaders: false, // 显示所有页面的标题链接 默认false
        smoothScroll: true,
        nav: [ // 添加导航栏
            {text: '日常命令', link: '/linux/linux'},
            {text: '技术沉淀', link: '/technology/java'},
            {text: '问题总结', link: '/ans/serve-ans'},
            {
                text: '工具', items: [
                    {text: 'Json格式化', link: 'https://www.json.cn/'},
                    {text: 'Vue官网', link: 'https://element.eleme.cn/#/zh-CN'},
                    {text: '时间戳转换', link: 'https://tool.lu/timestamp/'},
                    {text: 'Unicode编码转换', link: 'http://tool.chinaz.com/tools/unicode.aspx'},
                    {text: '二维码生成', link: 'https://cli.im/'},
                    {text: 'Arthas文档', link: 'https://alibaba.github.io/arthas/install-detail.html'},
                    {text: '大小写转换', link: 'https://www.iamwawa.cn/daxiaoxie.html'},
                    {text: '文本差异对比', link: 'http://www.jq22.com/textDifference'},
                    {text: 'Github', link: 'https://github.com/ziping95'}

                ]
            }
        ],
        // sidebar: [
        //     ['/linux','一、Linux 命令'],
        //     ['/screen','二、Screen 命令']
        // ],
        sidebar: {
            '/linux/': [
                {
                    title: 'Linux',                         // 菜单名
                    collapsable: false,                     // 收起目录 默认false
                    children: [                             // 子菜单
                        ['/linux/linux', '基础命令'],
                        ['/linux/screen', 'Screen'],
                        ['/linux/other', '其他命令']
                    ]
                }, {
                    title: '服务器安装',                         // 菜单名
                    collapsable: false,                     // 收起目录 默认false
                    children: [                             // 子菜单
                        ['/linux/serve', '步骤文档']
                    ]
                }
            ],
            '/technology/': [
                {
                    title: '技术沉淀',
                    collapsable: false,                     // 收起目录 默认false
                    children: [                             // 子菜单
                        ['/technology/java','java基础']
                    ]
                }
            ],
            '/ans/': [
                {
                    title: '问题总结',
                    collapsable: false,                     // 收起目录 默认false
                    children: [                             // 子菜单
                        ['/ans/serve-ans','服务器相关'],
                        ['/ans/git-ans','git相关']
                    ]
                }
            ]
        },
        extraWatchFiles: [
            './config.js' // 使用相对路径
            // '/path/to/bar.js'   // 使用绝对路径
        ],
        sidebarDepth: 2
    }
};
