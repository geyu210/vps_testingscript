#!/usr/bin/env bash

# 变量定义（用于输出格式化，如果不需要可以去掉）
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
SKYBLUE='\033[0;36m'
PLAIN='\033[0m'

# 测试硬盘速度的函数
io_test() {
    (LANG=C dd if=/dev/zero of=test_file_$$ bs=512K count=$1 conv=fdatasync && rm -f test_file_$$ ) 2>&1 | awk -F, '{io=$NF} END { print io}' | sed 's/^[ \t]*//;s/[ \t]*$//'
}

# 此函数用于确定测试使用的空间大小
freedisk() {
    freespace=$( df -m . | awk 'NR==2 {print $4}' )
    if [[ $freespace == "" ]]; then
        freespace=$( df -m . | awk 'NR==3 {print $3}' )
    fi
    if [[ $freespace -gt 1024 ]]; then
        printf "%s" $((1024*2))
    elif [[ $freespace -gt 512 ]]; then
        printf "%s" $((512*2))
    elif [[ $freespace -gt 256 ]]; then
        printf "%s" $((256*2))
    elif [[ $freespace -gt 128 ]]; then
        printf "%s" $((128*2))
    else
        printf "1"
    fi
}

# 计算和输出硬盘速度的函数
print_io() {
    writemb=$(freedisk)
    writemb_size="$(( writemb / 2 ))MB"
    if [[ $writemb_size == "1024MB" ]]; then
        writemb_size="1.0GB"
    fi

    if [[ $writemb != "1" ]]; then
        echo -n " I/O Speed( $writemb_size )   : "
        io1=$( io_test $writemb )
        echo -e "${YELLOW}$io1${PLAIN}"
        echo -n " I/O Speed( $writemb_size )   : "
        io2=$( io_test $writemb )
        echo -e "${YELLOW}$io2${PLAIN}"
        echo -n " I/O Speed( $writemb_size )   : "
        io3=$( io_test $writemb )
        echo -e "${YELLOW}$io3${PLAIN}"
        # 计算平均值
        ioraw1=$( echo $io1 | awk 'NR==1 {print $1}' )
        ioraw2=$( echo $io2 | awk 'NR==1 {print $1}' )
        ioraw3=$( echo $io3 | awk 'NR==1 {print $1}' )
        ioall=$( awk 'BEGIN{print '$ioraw1' + '$ioraw2' + '$ioraw3'}' )
        ioavg=$( awk 'BEGIN{printf "%.1f", '$ioall' / 3}' )
        echo -e " Average I/O Speed    : ${YELLOW}$ioavg MB/s${PLAIN}"
    else
        echo -e " ${RED}Not enough space!${PLAIN}"
    fi
}

# 调用函数以执行测试
print_io
