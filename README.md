### hadoop集群组件脚本



目前主要完成的是下面一些的几个脚本，下面那几个我没学，`hive and mysql`是我太懒了，不想写了 . 如果有想写的，可以根据前面几个脚本去写。

开发环境说明

​	系统：`centos7`

执行所需环境

 	1. 每台机器的`hostname`,在后面执行脚本分发的时候需要指定
 	2. 每台机器的`/etc/hosts`的映射文件修改
 	3. `ssh` 保证主节点无需密码访问从节点

目录

 - 压缩文件和脚本所在文件

   ![](https://github.com/MGboyNew/hadoop-shell-script/blob/main/images/%E7%9B%AE%E5%BD%951.png)

- 压缩文件和脚本所在目录

  ![](https://github.com/MGboyNew/hadoop-shell-script/blob/main/images/%E7%9B%AE%E5%BD%952.png)

  说明：

  	1.  脚本是在当前和他一起的这个目录下找指定压缩包的，所以会在一个目录下。
  	2.  在分发的时候，要注意被分发的从节点上应该有同样的目录。就像我两个从节点的目录下都有/software目录(从节点的/software是空的，要分发后才有)
  	3. `software`我会将脚本和`*gz`文件都放在这里。安装后也是在这里。如果你建议目录结构，你可以在安装后删除就好了。

参数说明

 - `-n`
   	- 文件解压后的文件名
 - `-s`
   	- 需要分发到的从节点
 - `-h help`
    - 查看帮助

格式

```bash
./install_*.sh -n 文件名 -s 从节点主机名 -s 从节点主机名  # 当前节点安装并指定文件名并且分发
./install_*.sh -n 文件名 # 当前节点安装并指定文件名
./install_*.sh # 当前节点安装使用默认的文件名
./install_*.sh -s 从节点主机名 -s 从节点主机名 # 当前节点安装并使用默认文件名并且分发
./install_*.sh -h help # 查看帮助文档
```

脚本使用

- `java`

  ```
  ./install_java.sh -n java -s slave1 -s slave2
  ```

  在当前机器上安装`jdk`并且命名为`java`，在最后将安装好的`java`分发到从节点`slave1`和`slave2`中

- ...

  其他同上原理

任务工单

- [x] java
- [x] zookeeper
- [x] hadoop
- [x] scala
- [x] spark
- [ ] mysql
- [ ] hive
- [ ] flume
- [ ] sqoop
- [ ] kafka

聊一下

   ​	在很久以前就想写这些个脚本了，毕竟在老师上课时就`Hadoop`伪分布式安装就讲了好多周(具体忘了)，反正到最后也班上大部分同学也都没学会自己装。其实我反正觉得老师讲的和蜗牛一样，可能大多同学都太懒了，都不愿去学习这个，可能这就是大专生的现状吧 .(本人大专)。

   ​	临近毕业了，大部分同学都出去实习了，虽然行行出状元，但是又有几个状元 。对于一般人无非也是那么几个出路，还是多读书吧。

   ​	上面脚本主要是因为要参加比赛`<<第二届全国电信和互联网行业职业技能竞赛大数据分析师赛项——线上选拔赛通知>>`. 同时也是为了积攒一些经验。

   ​	太焦虑了，明年就毕业了，只能靠今年的两个一类比赛了(免试)，上面那个比赛估计也只是会参加选拔赛(没时间), 不知道软件杯在湖南省可以免试吗, 好像在其他省都可以保研,免试的，好歹也是个国赛(一类)，湖南省好像不认可(如果有知道的可以聊一下)。

   ​	有点后悔学大数据了(如果是专科生大数据找的工作也太难了)，应该做软件开发的。在后续也会写点前端和后端的项目。

感谢[小康](https://www.xiaokang.cool/#/README) ,脚本中的配置大多源于此。
