#!/bin/bash

hostname=`hostname`

targetFile=""

target='jdk'

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
echo_msg=("export JAVA_HOME=$tarFilePath\n" "export JRE_HOME=$tarFilePath/jre\n" "export CLASS_PATH=$tarFilePath/lib:$tarFilePath/jre/lib\n" "export PATH=\$PAHT:$tarFilePath/bin:\$PATH\n")
echoMsg "${echo_msg[*]}" "\nadd to /etc/profile >> \n"

lines=("#path java\n""export JAVA_HOME=$tarFilePath\n""export JRE_HOME=$tarFilePath/jre\n""export CLASS_PATH=$tarFilePath/lib:$tarFilePath/jre/lib\n""export PATH=\$PAHT:$tarFilePath/bin:\$PATH\n")
echoFile "${lines[*]}"  "/etc/profile"

source /etc/profile
if [[ $? == 1 ]];
then
    echo -e "\n环境变量刷新失败 请自行刷新\n"
fi

echo -e "\n..................修改完毕............................."

#分发文件

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

        echo -e "\n..................分发完毕............................."
    fi
done
