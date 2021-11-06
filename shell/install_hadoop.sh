#!/bin/bash


hostname=`hostname`


target="hadoop"

targetFile=""

index=0

dirname=$target

while getopts ":s:n:h:" args
do
    case $args in
        "s")
            echo ".............................即将分发文件值$OPTARG............................."
            hostnames[$index]=$OPTARG
            index=$((index+1))
            ;;
        "n")
            echo ".............................指定安装文件夹至$OPTARG............................."
            dirname=$OPTARG
            ;;
        "h")
            echo "通过-s指定一个从节点,如：./*.sh -s slave1"
            echo "通过-n指定解压后的文件名"
            exit 1
            ;;
        "?")
            echo "..........................未知参数 ${OPTARG}.........................."
            exit 1
            ;;
    esac
done

# ========================= 函数定义区域 =========================
function isExists(){
        for file in $(ls .);
        do
        if [[ $file == $1* ]] && [[ $file == *.gz ]];
                then
            targetFile=$file 
            return 0
                fi
        done
    return 1
}

function tarFile(){
    mkdir $2
    echo -e "\n...................解压$1...............................\n"
    tar -zxf $1 -C $2 --strip-components 1
    if (( $? == 1));
    then
        return 1
    fi
    echo -e "\n...................解压完毕...............................\n"
    return 0
}

function echoMsg(){
    arr=$1
    for i in "${arr[@]}";
    do
        echo -e $2 $i
    done
}

function echoFile(){
    arr=$1
    for i in "${arr[@]}";
    do
        echo -e $i >> $2
    done
}

# ========================= 函数定义区域 =========================

isExists $target #  函数执行

if (( $? == 1 ));
then
    echo "文件夹中不存在${target}压缩文件"
    exit 1
fi

if [ -d "${dirname}" ];
then
    echo -e "\n..........................文件已经存在.........................."
    echo -e "................................................................"
    echo -e "...................删除 or -n参数指定新的文件...................\n"
    exit 1
fi


tarFile $targetFile $dirname
if (( $? == 1 ));
then
    echo "文件解压失败"
    exit 1
fi

tarFilePath=`pwd`\/$dirname


echo -e "\n..................修改配置文件(/etc/profile)............................."
echo_msg=("path hadoop\n" "export HADOOOP_HOME=$tarFilePath\n" "export PATH=\$PAHT:$tarFilePath/bin:$tarFilePath/sbin:\$PATH\n" "")
echoMsg "${echo_msg[*]}" "\nadd to /etc/profile >> \n"

lines=("#path hadoop\n""export HADOOOP_HOME=$tarFilePath\n""export PATH=\$PAHT:$tarFilePath/bin:$tarFilePath/sbin:\$PATH\n" "")
echoFile "${lines[*]}"  "/etc/profile"

source /etc/profile
if [[ $? == 1 ]];
then
    echo -e "\n环境变量刷新失败 请自行刷新\n"
fi

tarFilePath=`pwd`\/hadoop

echo "...............................修改配置文件${tarFilePath}..............................."
sed -i "s#JAVA_HOME=.*#JAVA_HOME=${JAVA_HOME}#" ${tarFilePath}/etc/hadoop/hadoop-env.sh
sed -i "s#HADOOP_CONF_DIR=.*#HADOOP_CONF_DIR=${tarFilePath}/etc/hadoop#" ${tarFilePath}/etc/hadoop/hadoop-env.sh

#echo "================修改配置文件${tarFilePath}/etc/hadoop/core-site.xml=================="
sed -i '$d' ${tarFilePath}/etc/hadoop/core-site.xml
sed -i '$d' ${tarFilePath}/etc/hadoop/core-site.xml
sed -i '$d' ${tarFilePath}/etc/hadoop/core-site.xml
content="
\n<configuration>\n
\n        <property>\n
\n            <name>fs.defaultFS</name>\n
\n            <value>hdfs://master:9000</value>\n
\n        </property>  \n
\n        <property>\n
\n            <name>hadoop.tmp.dir</name>\n
\n            <value>${tarFilePath}/tmp</value>\n
\n        </property>\n
\n        <property>\n
\n            <name>io.file.buffer.size</name>\n
\n            <value>4096</value>\n
\n        </property>\n
\n</configuration>\n
"
echo -e $content >> ${tarFilePath}/etc/hadoop/core-site.xml

#echo "================修改配置文件${tarFilePath}/etc/hadoop/hdfs-site.xml=================="
sed -i '$d' ${tarFilePath}/etc/hadoop/hdfs-site.xml
sed -i '$d' ${tarFilePath}/etc/hadoop/hdfs-site.xml
sed -i '$d' ${tarFilePath}/etc/hadoop/hdfs-site.xml
content="
\n<configuration>\n
\n        <property>\n
\n           <!--数据块默认大小128M-->\n
\n           <name>dfs.block.size</name>\n
\n           <value>134217728</value>\n
\n        </property>\n
\n        <property>\n
\n            <!--副本数量，不配置的话默认为3-->\n
\n            <name>dfs.replication</name> \n
\n            <value>3</value>\n
\n        </property>\n
\n        <property>\n
\n            <!--定点检查--> \n
\n            <name>fs.checkpoint.dir</name>\n
\n            <value>${tarFilePath}/checkpoint/dfs/cname</value>\n
\n        </property>\n
\n        <property>\n
\n            <!--namenode节点数据（元数据）的存放位置-->\n
\n            <name>dfs.name.dir</name> \n
\n            <value>${tarFilePath}/dfs/namenode_data</value>\n
\n        </property>\n
\n        <property>\n
\n            <!--datanode节点数据（元数据）的存放位置-->\n
\n            <name>dfs.data.dir</name> \n
\n            <value>${tarFilePath}/dfs/datanode_data</value>\n
\n        </property>\n
\n        <property>\n
\n            <!--指定secondarynamenode的web地址-->\n
\n            <name>dfs.namenode.secondary.http-address</name> \n
\n            <value>slave1:50090</value>\n
\n        </property>\n
\n        <property>\n
\n            <!--hdfs文件操作权限,false为不验证-->\n
\n            <name>dfs.permissions</name> \n
\n            <value>false</value>\n
\n        </property>\n
\n</configuration>\n
"
echo -e $content >> ${tarFilePath}/etc/hadoop/hdfs-site.xml

#echo "================修改配置文件${tarFilePath}/etc/hadoop/yarn-site.xml=================="
sed -i '$d' ${tarFilePath}/etc/hadoop/yarn-site.xml
sed -i '$d' ${tarFilePath}/etc/hadoop/yarn-site.xml
sed -i '$d' ${tarFilePath}/etc/hadoop/yarn-site.xml
content="
\n        <property>
\n            <name>yarn.resourcemanager.hostname</name>
\n            <value>master</value>
\n        </property>
\n        <property>
\n            <name>yarn.resourcemanager.address</name>
\n            <value>master:8032</value>
\n        </property>
\n        <property>
\n            <name>yarn.resourcemanager.webapp.address</name>
\n            <value>master:8088</value>
\n        </property>
\n        <property>
\n            <name>yarn.resourcemanager.scheduler.address</name>
\n            <value>master:8030</value>
\n        </property>
\n        <property>
\n            <name>yarn.resourcemanager.resource-tracker.address</name>
\n            <value>master:8031</value>
\n        </property>
\n        <property>
\n            <name>yarn.resourcemanager.admin.address</name>
\n            <value>master:8033</value>
\n        </property>
\n        <property>
\n            <name>yarn.nodemanager.aux-services</name>
\n            <value>mapreduce_shuffle</value>
\n        </property>
\n        <property>
\n            <name>yarn.log-aggregation-enable</name>
\n            <value>true</value>
\n        </property>
\n        <property>
\n            <name>yarn.log-aggregation.retain-seconds</name>
\n            <value>604800</value>
\n        </property>
\n</configuration>
"
echo -e $content >> ${tarFilePath}/etc/hadoop/yarn-site.xml

#echo "================修改配置文件${tarFilePath}/etc/hadoop/mapred-site.xml================"
cp ${tarFilePath}/etc/hadoop/mapred-site.xml.template ${tarFilePath}/etc/hadoop/mapred-site.xml
sed -i '$d' ${tarFilePath}/etc/hadoop/mapred-site.xml
sed -i '$d' ${tarFilePath}/etc/hadoop/mapred-site.xml
sed -i '$d' ${tarFilePath}/etc/hadoop/mapred-site.xml
content="
\n<configuration>
\n        <property>  
\n            <!--指定mapreduce运行在yarn上-->
\n            <name>mapreduce.framework.name</name> 
\n            <value>yarn</value>
\n        </property>
\n        <property>
\n            <!--配置任务历史服务器IPC-->
\n            <name>mapreduce.jobhistory.address</name>
\n            <value>master:10020</value>
\n        </property>
\n        <property>
\n            <!--配置任务历史服务器web-UI地址-->
\n            <name>mapreduce.jobhistory.webapp.address</name>
\n            <value>master:19888</value>
\n        </property>
\n</configuration>
"
echo -e $content >> ${tarFilePath}/etc/hadoop/mapred-site.xml

#echo "================修改配置文件${tarFilePath}/etc/hadoop/master=================="
echo master >> ${tarFilePath}/etc/hadoop/master

#echo "================修改配置文件${tarFilePath}/etc/hadoop/slaves=================="
sed -i '$d' ${tarFilePath}/etc/hadoop/slaves
echo master >> ${tarFilePath}/etc/hadoop/slaves 
echo slave1 >> ${tarFilePath}/etc/hadoop/slaves 
#修改完毕
#echo "================配置文件修改完毕=================="

for host in ${hostnames[*]};
do
    if [ -n "$host" ];
    then
        ssh $host "source /etc/profile"
        if [[ $? == 255 ]];
        then
            echo "....................未找到指定的节点........................."
            rm -rf $tarFilePath
            exit 1
        fi
        echo -e "\n..................分发文件${tarFilePath} 至${host}............................."

        scp -q -r $tarFilePath root@$host:$tarFilePath
        scp -q /etc/profile root@$host:/etc/profile
        ssh $host "source /etc/profile"

        echo -e "\n..................分发完毕.............................\n"
    fi
done


#=============================修改从节点 完毕=========================

echo -e "\n..................格式化.............................\n"
hdfs  namenode -format
echo -e "\n..................格式化完毕.............................\n"

echo -e "\n..................启动集群.............................\n"
start-all.sh
echo -e "\n..................启动完毕.............................\n"


