#
#  Copyright (C),2019-2020,System Monitor Bash Script
#  @author:IvanSmoot
#  @date:2019.6.21
#  @versison:1.3.0
#
#  使用本软件需安装zenity组件：apt-get install zenity
#  如需使用邮件功能，需安装配置msmtp和mutt，参考https://www.cnblogs.com/suhaha/p/8655033.html
#

#定义主界面接口
function Main_Interface(){   

#获取当前日期和时间
time=$(date "+%Y-%m-%d %H:%M:%S")
#将用户名、时间和操作行为写入日志文件
echo `whoami` "${time} enter main interface" >> System_Monitor.log

#Zenity选择界面
ans=$(zenity --list --title "Shell系统监控" --text "请选择监控项" --radiolist --column "选择" --column "选项" TRUE 磁盘 FALSE CPU FALSE 内存 FALSE 将全部信息导入文件查看 --width=800 --height=600);

#用户选择磁盘
if [ "$ans" == "磁盘" ]; then
 
#磁盘界面接口
(Disk_Interface;)&
#主界面接口循环，让用户不在此直接退出程序
Main_Interface;

#磁盘if结束
fi 

#用户选择CPU
if [ "$ans" == "CPU" ]; then 

#CPU界面接口
CPU_Interface;
#主界面接口循环，让用户不在此直接退出程序
Main_Interface;

#CPU if结束
fi 

#用户选择内存
if [ "$ans" == "内存" ]; then 

#内存界面接口
Memory_Interface; 
#主界面接口循环，让用户不在此直接退出程序
Main_Interface;

#内存if结束
fi 

#用户选择将全部信息导入文件查看
if [ "$ans" == "将全部信息导入文件查看" ]; then
 
#文件界面接口
(File_Interface;)&
#主界面接口循环，让用户不在此直接退出程序
Main_Interface;
#文件if结束
fi

#主界面接口定义结束
} 

#定义磁盘接口
function Disk_Interface(){

#获取当前日期和时间
time=$(date "+%Y-%m-%d %H:%M:%S")
#将用户名、时间和操作行为写入日志文件
echo `whoami` "${time} enter disk interface" >> System_Monitor.log

#磁盘已使用大小
Disk_Used=$(df -m | gawk '{used+=$3} END{printf "%.2f",used/1024}')
#磁盘总大小
Disk_TotalSpace=$(df -m | gawk '{totalSpace+=$2} END{printf "%.2f",totalSpace/1024}')
#磁盘使用率
Disk_Percent=`echo "scale=2;$Disk_Used*100/$Disk_TotalSpace" | bc`

#磁盘预警
if [ `expr $Disk_Percent \> 10` -eq 1 ];then 
#磁盘预警写入文件
echo "disk used ${Disk_Percent}% , warning!" >>System_Monitor.log 
Disk_Warning=磁盘使用率过高，请及时清理！
#Zenity磁盘警告界面
zenity --warning --text "磁盘使用率过高，请及时清理！" --width=500 --height=300  
else
Disk_Warning=未达到预警值
fi

#Zenity磁盘信息界面
zenity --info --title "磁盘信息查看" --text "磁盘使用量为：$Disk_Used G\n磁盘总量为：$Disk_TotalSpace G\n磁盘使用率：$Disk_Percent %\n磁盘预警：$Disk_Warning" --width=500 --height=300

#磁盘接口定义结束
}

#定义CPU接口
function CPU_Interface(){  

#获取当前日期和时间
time=$(date "+%Y-%m-%d %H:%M:%S")
#将用户名、时间和操作行为写入日志文件
echo `whoami` "${time} enter CPU interface" >> System_Monitor.log

#Zenity选择界面
ans=$(zenity --list --title "CPU监控" --text "请选择监控项" --radiolist --column "选择" --column "选项" TRUE CPU基本信息 FALSE CPU占比 --width=800 --height=600);

#用户选择CPU基本信息
if [ "$ans" == "CPU基本信息" ]; then
#进入CPU基本信息接口
(CPU_Information_Interface;)&
#CPU接口循环，让用户不在此直接退出程序
CPU_Interface; 

#CPU基本信息if结束
fi 

#用户选择CPU占比
if [ "$ans" == "CPU占比" ]; then 
#进入CPU占比接口
(CPU_Used_Interface;)&
#CPU接口循环，让用户不在此直接退出程序
CPU_Interface; 

#CPU占比if结束
fi 

#CPU接口定义结束
} 

#定义CPU基本信息接口
function CPU_Information_Interface(){
#获取当前日期和时间
time=$(date "+%Y-%m-%d %H:%M:%S")
#将用户名、时间和操作行为写入日志文件
echo `whoami` "${time} enter CPU base information interface" >> System_Monitor.log

#CPU名称
CPU_Name=$(cat /proc/cpuinfo | grep name | cut -f2 -d:)
#CPU个数
CPU_Num=$(cat /proc/cpuinfo| grep "physical id"| sort| uniq| wc -l)
#单个CPU核心数
CPU_Core_Each_Num=$(cat /proc/cpuinfo| grep "cpu cores"| cut -f2 -d:)
#CPU总核心数
CPU_Core_Total_Num=$(cat /proc/cpuinfo | grep processor | wc -l)
#CPU中断次数
CPU_Interrupt_Num=`vmstat|awk '{x=$11;}END{printf ("%d",x)}'`
#CPU上下文切换次数
CPU_Context_Switching_Num=`vmstat|awk '{x=$12;}END{printf("%d",x)}'`
#CPU使用率
CPU_Used_Percent=`ps aux|awk '{x+=$3;}END{printf ("%.2f",x)}'`

#CPU预警
if [ `expr $CPU_Used_Percent \> 10` -eq 1 ];then 
#CPU预警写入文件
echo "CPU used ${CPU_Used_Percent}% , warning!" >>System_Monitor.log 
CPU_Warning=CPU使用率过高，请注意！
#ZenityCPU警告界面
zenity --warning --text "CPU使用率过高，请注意！" --width=500 --height=300 
else
CPU_Warning=未达到预警值
fi

#ZenityCPU信息界面
zenity --info --title "CPU使用情况" --text "CPU型号：$CPU_Name\nCPU个数：$CPU_Num\n单个CPU核心数：$CPU_Core_Each_Num\nCPU总核心数：$CPU_Core_Total_Num\nCPU中断次数：$CPU_Interrupt_Num\nCPU上下文切换次数：$CPU_Context_Switching_Num\nCPU使用率：$CPU_Used_Percent%\nCPU预警：$CPU_Warning" --width=500 --height=300

#CPU基本信息接口定义结束
}

#定义CPU占比接口
function CPU_Used_Interface(){
#获取当前日期和时间
time=$(date "+%Y-%m-%d %H:%M:%S")
#将用户名、时间和操作行为写入日志文件
echo `whoami` "${time} enter CPU used interface" >> System_Monitor.log

#将CPU占比数据转化为整型，作为参数传给Zenity的进度条窗口，动态显示当前CPU的占比
declare -i i=`ps aux|awk '{x+=$3;}END{printf ("%d",x+0.5)}'`; while [ $i != 101 ]; do sleep 1; echo $i; i=`ps aux|awk '{x+=$3;}END{printf ("%d",x+0.5)}'`;done | zenity --progress --title="CPU占比" --text="CPU动态使用率" --width=500 --height=300

#CPU占比接口定义结束
}

#定义内存接口
function Memory_Interface(){ 

#获取当前日期和时间
time=$(date "+%Y-%m-%d %H:%M:%S")
#将用户名、时间和操作行为写入日志文件
echo `whoami` "${time} enter memory interface" >> System_Monitor.log

#Zenity选择界面
ans=$(zenity --list --title "内存监控" --text "请选择监控项" --radiolist --column "选择" --column "选项" TRUE 内存基本信息 FALSE 内存占比 --width=800 --height=600);

#用户选择内存基本信息
if [ "$ans" == "内存基本信息" ]; then 
#进入内存基本信息接口
(Memory_Information_Interface;)&
#内存接口循环，让用户不在此直接退出程序
Memory_Interface; 
#内存基本信息if结束
fi 

#用户选择内存占比
if [ "$ans" == "内存占比" ]; then 
#进入内存占比接口
(Memory_Used_Interface;)&
#内存接口循环，让用户不在此直接退出程序
Memory_Interface; 

#内存占比if结束
fi 

#内存接口定义结束
}

#定义内存基本信息接口（）
function Memory_Information_Interface(){
#获取当前日期和时间
time=$(date "+%Y-%m-%d %H:%M:%S")
#将用户名、时间和操作行为写入日志文件
echo `whoami` "${time} enter memory base information interface" >> System_Monitor.log

#内存总大小
Memory_Total=$(cat /proc/meminfo| grep MemTotal | cut -f2 -d:|sed 's/kB//g')
#内存总大小数据处理，保留两位小数并转换为以G为大小单位
Memory_Total_cal=$(echo "scale=2;$Memory_Total/1048576"|bc)
#内存剩余量
Memory_Free=$(cat /proc/meminfo| grep MemFree | cut -f2 -d:|sed 's/kB//g')
#内存剩余量数据处理，保留两位小数并转换为以G为大小单位
Memory_Free_Cal=$(echo "scale=2;$Memory_Free/1048576"|bc)
#操作系统已使用量
System_Used=$(cat /proc/meminfo| grep Slab | cut -f2 -d:|sed 's/kB//g')
#操作系统已使用量数据处理，保留两位小数并转换为以M为大小单位
System_Used_Cal=$(echo "scale=2;$System_Used/1024"|bc)
#交换空间总大小
Swap_Total=$(cat /proc/meminfo| grep SwapTotal | cut -f2 -d:|sed 's/kB//g')
#交换空间总大小数据处理，保留两位小数并转换为以G为大小单位
Swap_Total_Cal=$(echo "scale=2;$Swap_Total/1048576"|bc)
#内存使用率
Memory_Used_Percent=`free -m|awk '{x+=$3;}END{printf ("%.2f",(x*100/$2))}'`

#内存预警
if [ `expr $Memory_Used_Percent \> 20` -eq 1 ];then 
#内存预警写入文件
echo "memory used ${Memory_Used_Percent}% , warning!" >>System_Monitor.log 
Memory_Warning=CPU使用率过高，请注意！
#Zenity内存警告界面
zenity --warning --text "内存使用率过高，请注意！" --width=500 --height=300 
else
Memory_Warning=未达到预警值
fi

#Zenity内存信息界面
zenity --info --title "内存使用情况" --text "内存总大小：$Memory_Total_cal G\n内存可用大小：$Memory_Free_Cal G\n内存占比：$Memory_Used_Percent%\n操作系统占用内存：$System_Used_Cal M\n交换分区总大小：$Swap_Total_Cal G\n内存预警：$Memory_Warning" --width=500 --height=300

#存基本信息接口定义结束
}

#定义内存占比接口
function Memory_Used_Interface(){
#获取当前日期和时间
time=$(date "+%Y-%m-%d %H:%M:%S")
#将用户名、时间和操作行为写入日志文件
echo `whoami` "${time} enter memory used interface" >> System_Monitor.log

#将内存占比数据转化为整型，作为参数传给Zenity的进度条窗口，动态显示当前内存的占比
declare -i i=`free -m|awk '{x+=$3;}END{printf ("%d",(x*100/$2)+0.5)}'`; while [ $i != 101 ]; do sleep 1; echo $i; i=`free -m|awk '{x+=$3;}END{printf ("%d",(x*100/$2)+0.5)}'`;done | zenity --progress --title="内存占比" --text="内存动态使用率" --width=500 --height=300

#内存占比接口定义结束
}

#定义文件接口
function File_Interface(){

#获取当前日期和时间
time=$(date "+%Y-%m-%d %H:%M:%S")
#将用户名、时间和操作行为写入日志文件
echo `whoami` "${time} enter file interface" >> System_Monitor.log

#获取全部信息
#磁盘已使用大小
Disk_Used=$(df -m | sed '1d;/ /!N;s/\n//;s/ \+/ /;' | gawk '{used+=$3} END{printf "%.2f",used/1024}')
#磁盘总大小
Disk_TotalSpace=$(df -m | sed '1d;/ /!N;s/\n//;s/ \+/ /;' | gawk '{totalSpace+=$2} END{printf "%.2f",totalSpace/1024}')
#磁盘使用率
Disk_Percent=`echo "scale=2;$Disk_Used*100/$Disk_TotalSpace" | bc`
#CPU名称
CPU_Name=$(cat /proc/cpuinfo | grep name | cut -f2 -d:)
#CPU个数
CPU_Num=$(cat /proc/cpuinfo| grep "physical id"| sort| uniq| wc -l)
#单个CPU核心数
CPU_Core_Each_Num=$(cat /proc/cpuinfo| grep "cpu cores"| cut -f2 -d:)
#CPU总核心数
CPU_Core_Total_Num=$(cat /proc/cpuinfo | grep processor | wc -l)
#CPU中断次数
CPU_Interrupt_Num=`vmstat|awk '{x=$11;}END{printf ("%d",x)}'`
#CPU上下文切换次数
CPU_Context_Switching_Num=`vmstat|awk '{x=$12;}END{printf("%d",x)}'`
#CPU使用率
CPU_Used_Percent=`ps aux|awk '{x+=$3;}END{printf ("%.2f",x)}'`
#内存总大小
Memory_Total=$(cat /proc/meminfo| grep MemTotal | cut -f2 -d:|sed 's/kB//g')
#内存总大小数据处理，保留两位小数并转换为以G为大小单位
Memory_Total_cal=$(echo "scale=2;$Memory_Total/1048576"|bc)
#内存剩余量
Memory_Free=$(cat /proc/meminfo| grep MemFree | cut -f2 -d:|sed 's/kB//g')
#内存剩余量数据处理，保留两位小数并转换为以G为大小单位
Memory_Free_Cal=$(echo "scale=2;$Memory_Free/1048576"|bc)
#操作系统已使用量
System_Used=$(cat /proc/meminfo| grep Slab | cut -f2 -d:|sed 's/kB//g')
#操作系统已使用量数据处理，保留两位小数并转换为以M为大小单位
System_Used_Cal=$(echo "scale=2;$System_Used/1024"|bc)
#交换空间总大小
Swap_Total=$(cat /proc/meminfo| grep SwapTotal | cut -f2 -d:|sed 's/kB//g')
#交换空间总大小数据处理，保留两位小数并转换为以G为大小单位
Swap_Total_Cal=$(echo "scale=2;$Swap_Total/1048576"|bc)
#内存使用率
Memory_Used_Percent=`free -m|awk '{x+=$3;}END{printf ("%.2f",(x*100/$2))}'`

#获取当前日期和时间
time=$(date "+%Y-%m-%d %H:%M:%S")
#将用户名、时间和操作行为写入文件
echo "导入用户："`whoami` "导入时间：${time}" >> Information.txt
#将全部信息写入文件
echo "磁盘已使用大小：${Disk_Used}G" >>Information.txt
echo "磁盘总大小：${Disk_TotalSpace}G" >>Information.txt
echo "磁盘使用率：${Disk_Percent}%" >>Information.txt
echo "CPU名称：${CPU_Name}" >>Information.txt
echo "CPU个数：${CPU_Num}" >>Information.txt
echo "单个CPU核心数：${CPU_Core_Each_Num}" >>Information.txt
echo "CPU总核心数：${CPU_Core_Total_Num}" >>Information.txt
echo "CPU中断次数：${CPU_Interrupt_Num}" >>Information.txt
echo "CPU上下文切换次数：${CPU_Context_Switching_Num}" >>Information.txt
echo "CPU使用率：${CPU_Used_Percent}%" >>Information.txt
echo "内存总大小：${Memory_Total_cal}G" >>Information.txt
echo "内存剩余量：${Memory_Free_Cal}G" >>Information.txt
echo "操作系统已使用量：${System_Used_Cal}M" >>Information.txt
echo "交换空间总大小：${Swap_Total_Cal}G" >>Information.txt
echo "内存使用率：${Memory_Used_Percent}%" >>Information.txt

user_email=$(zenity --entry --title "将文件发送至您的邮箱" --text "请输入您的邮箱：" --entry-text "@163.com" --width=500 --height=300); 

echo  "这是您刚刚在DeepIn中导出的系统监控文件，请查收！"|mutt -s "Linux系统监控文件"  $user_email -a ./Information.txt

#Zenity邮件发送信息界面
zenity --info --title "邮件发送" --text "请注意查收邮件！" --width=500 --height=300

#文件接口定义结束
}

#执行主界面接口
Main_Interface; 