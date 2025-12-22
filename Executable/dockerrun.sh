#!/usr/bin/env bash
image_version=v2.0
while getopts :p:m:i:u: opts; do
    case $opts in
        p) path=$OPTARG ;; # path of bytecode
        ?) printf "Usage: %s [-p bytecode_realpath]" $0;;
    esac
done

path_check()
{
    if [ ! -f "$1" ]; then
        printf "%s not exist.\n" $1
        return 0
    fi
    return 1
}

if [ ! -z "$path" ]; then
    path_check $path
    exist=`echo $?`
    absolute_path=$(realpath $path)
    absolute_dir_path=$(dirname $absolute_path)
    file_name=$(basename $path)
    if [ $exist = "1" ]; then
        bytecode_dir="/crypto_scout/bytecode"
        docker run -v ${absolute_dir_path}:${bytecode_dir} -e OPTION=p -e BYTECODE_DIR=${bytecode_dir} -e BYTECODE_FILE_NAME=${file_name} --rm crypto_scout:${image_version}
    else
        exit 2
    fi
fi
exit 0