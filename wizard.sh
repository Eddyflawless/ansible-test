#!/bin/bash

#ssh-keygen -t ed25519 -C "key default" 
#alias sshadd='eval $(ssh-agent) && ssh-add'

key_dir="$HOME/.ssh"


function script_manual() {
    exit
}

function file_exist() {

    if [[ ! -f "$key_dir/$1" ]]; then
        return 1
    fi

    return 0
}


function run_ssh_agent(){ 
    eval $(ssh-agent)
}

function generate_key() {

    key_name=unset
    comment=""
    gen_type="rsa"

    usage="Usage: $0 <key-name> <key-type> [comment] eg: $0 my_id rsa 'some-comment'"

    if [[ -z "$1" ]]; then
        echo "Please specify the key name"
        echo  $usage
        exit
    fi

    key_name="-f $key_dir/$1"

    if [[ -n "$2" ]]; then
        gen_type="$2"
    fi

    if [[ -n "$3" ]]; then
        comment="-C $3"
    fi

    ssh-keygen -t $gen_type $key_name $comment
    echo "Public and private key generated inot $key_dir"

}

function get_pub_id(){

    usage="Usage: $0 <absolute-path-to-key> eg: $0 /Users/s3ms/.ssh/id_ednode "
    id_key=$1

    if [[ -z "$1" ]]; then
        echo "Kindly specify the absolute path to id_key"
        echo $usage
        exit
    fi

    #check if key exists
    if [[ $(file_exist $id_key) -eq 1 ]]; then
        echo "$key doesnot exist in $key_dir"
        echo $usage
        exit
    fi

    #cat $key_dir"/$id_key.pub" 
    cat $id_key
    
}

function copy_id_to_host() {

    usage="Usage: $0 <key_name> <host> [passphrase] eg: $0 id_ednode 3.120.10.4"
   
    if [[ "$1" == "--help" || "$1" == "-h" || "$1" == "help" ]]; then
        echo $usage
        exit
    fi

    id_key=$1
    host=$2
    host_password=$3
  

    if [[ $id_key != *.pub ]]; then
        echo "$id_key must be a public key type"
        echo $usage
        exit
    fi

    echo "$1 | $2 | $(file_exist $id_key) "

    #check if key exists

    if [[ ! -f "$key_dir/$id_key" ]]; then
        echo "$id_key doesnot exist in $key_dir"
        echo $usage
        exit
    fi


    if [[ -z "$host" ]]; then
        echo "Ip of host cannot be empty"
        echo $usage
        exit

    fi

    ssh-add <<EOF
    $host_password
EOF

    ssh-copy-id -i "$key_dir/$id_key" $host <<EOF
$host_password
EOF

echo "done"

}

command_str=""

if [[ -z "$1" ]]; then
    script_manual
    exit
fi

command -v $1 > /dev/null || die "$command doesnot exist"

for x in "$@"; do
    command_str=$command_str" $x"
done

eval "$command_str" 

# /Users/mac/.ssh/id_ednode 