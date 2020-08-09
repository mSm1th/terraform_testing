


# set x used to write (or not) all exectued commands to the terminal. +x for no show - -x for show 
### set e for stopping on errros and return error message.
set +x
set e   
trap 'error_function $LINENO' ERR

error_function(){
    logger "[ERROR] Program stopped due to command returning a non-zero ret code - please check line $1."
    exit 1;
}

#logger function to log information on the script
logger(){
    DATE_TIME=$(date '+%d/%m/%Y -- %H:%M:%S')
    echo "$DATE_TIME $0: $1"
} 


logger "[START] Install dependencies ... "

