# This function is used to update the current dir's git softwares.
gppull()
{(
    CURDIR=$(pwd)
    for dname in `ls .|grep -vEe '(mylib|glibc)'`; do
        cd $dname && git pull 
        cd $CURDIR
    done
)}

# This function use git clone from github.com
github()
{(
    PRO="$@"
    git clone https://github.com/$PRO
    return $?
)}

#This function is used to backup
backup()
{(
    if [[ $# -lt 2 ]]; then
        echo "Useage: backup backup-name backup-directory"
        return 1
    fi
    BFILE=$1
    shift 
    BDIR=$@

    tar jcvf /samba/backup/${BFILE}-$(date +%Y%m%d).tar.bz2 ${BDIR}

    return $?
)}
# Some functions for tmux
tma()
{(
    if [[ $# -gt 1 ]]; then
        echo "Too more arguments."
        echo "Usage: tma [session-name]"
        return 1
    fi
    [[ $# -eq 1 ]] && SENAME="-t $1"

    tmux attach-session $SENAME

    return $?
)}

tmd()
{(
    if [[ $# -gt 2 ]]; then
        echo "Too more arguments."
        echo "Usage: tmd [window-name] [session-name]"
        return 1
    fi

    WINNAME=${1:-Coding}
    SESNAME=${2:-Dev}
    tmux new-session -s ${SESNAME} -n ${WINNAME} -c ~/exer -d \; split-window -c ~/doc -h -d \; attach

    return $?
)}
tmm()
{(
    if [[ $# -gt 2 ]]; then
        echo "Too more arguments."
        echo "Usage: tmm [window-name] [session-name]"
        return 1
    fi

    WINNAME=${1:-Mutt}
    SESNAME=${2:-Com}
    tmux new-session -s ${SESNAME} -n ${WINNAME} -c ~/.mutt/attach/ -d 'mutt' \; \
        new-window -n Offlineimap -c ~/.mail/hotmail 'offlineimap' \; attach

    return $?
)}

# A function quickly markdown something.
mark()
{(
    HELP="
    Usage: mark [opt] [date]\n
    -d  date        Open or create a specified date mark file.\n
    -h              Print help message.\n
    "
    #Get current date time.
    Year=`date +%Y`
    Month=`date +%m`
    Day=`date +%d`
    
    [[ $# -gt 2 ]] && { echo -ne "Argument error.\n"; echo -ne $HELP; return 1; }

    #Atgument and parameter parsing

    OPTIND=1
    while getopts "d:h" OPTION; do
        case $OPTION in
            # Confirm that $OPTARG is a datetime number
            d)  [[ $OPTARG =~ ^[0-9]{8}$ ]] || \
                [[ $OPTARG =~ ^[0-9]{1,4}$ ]] || \
                { echo "$OPTARG invalid."; return 1; }

                # Strip prefix '0'
                while [[ $OPTARG =~ ^0+ ]]; do
                    [[ $OPTARG -eq 0 ]] && \
                        { echo "$OPTARG not a datetime."; return 1; }
                    OPTARG=${OPTARG/0/}
                done

                [[ $OPTARG -gt 10000 ]] && \
                    Year=$(($OPTARG / 10000)) && \
                    OPTARG=$(($OPTARG % 10000))
                [[ $OPTARG -gt 100 ]] && \
                    Month=$(($OPTARG / 100)) && \
                    [[ $Month -lt 10 ]] && \
                    Month="0$Month"
                Day=$(($OPTARG % 100)) && \
                    [[ $Day -lt 10 ]] && \
                    Day="0$Day"
                ;;
            h)  echo -ne $HELP && return 0 ;;
            ?)  echo -ne $HELP && return 2 ;;
        esac
    done

    Dir="$MARK_DIR/${Year}/${Month}"

    [[ -e $Dir ]] || mkdir -p $Dir && vim ${Dir}/$Year$Month$Day.md
)}

# A function quickly write a post
post()
{(
    HELP="
    Usage: post post-name\n
    "

    #Get current date time.
    year=`date +%Y`
    month=`date +%m`
    day=`date +%d`

    [[ $# -ne 1 ]] && { echo -ne "Argument error.\n"; echo -ne $HELP; return 1; }

    #Atgument and parameter parsing
    dir=$POST_DIR
    post_name=$1
    full_post_name=$year-$month-$day-$post_name.md

    [[ -e $dir ]] || mkdir -p $dir && vi $dir/$full_post_name
)}

# tagit: tag a file.
tagit()
{(
    HELP="
    Usage: tagit [opt] [file]\n
    -a  tagname     Add a tag class.\n
    -d  tagname     Delete a tag from a file.\n
    -D  tagname     Delete a tag class.\n
    -t  tagname     Tag file with tagname.\n
    -T  tagname     Add a tag class and tag file with tagname.\n
    -l  tagname     List a tag class' files.\n
    -L  filename    List files tags.\n
    -n  tagname     Use with -l to lits tag class' file and numbers.\n
    -h              Print help message.\n
    "
    # OPTS' numbers
    BASE_NUM=0
    ADD_CLS=$((BASE_NUM++))
    DEL_TAG=$((BASE_NUM++))
    DEL_CLS=$((BASE_NUM++))
    ADD_TAG=$((BASE_NUM++))
    ADD_CLS_TAG=$((BASE_NUM++))
    LST_FLS=$((BASE_NUM++))
    LST_TAG=$((BASE_NUM++))
    NUM_FLS=$((BASE_NUM++))

    TAG_HOME=$TAG_DIR
    TAGS=()
    FILES=()
    LAST_OPT=$LST_TAG
    TAG_OPT=$LST_TAG
    TAG_CMD=(
    'mkdir -p $TAG_HOME/$TAG'
    'rm -rf $TAG_HOME/$TAG/$FILE_NAME'
    'rm -rf $TAG_HOME/$TAG'
    'ln -s $FULL_PATH_FILE $TAG_HOME/$TAG/$FILE_NAME'
    'mkdir -p $TAG_HOME/$TAG && ln -s $FULL_PATH_FILE $TAG_HOME/$TAG/$FILE_NAME'
    'echo $TAG && ls $TAG_HOME/$TAG'
    'TAG=`ls $TAG_HOME/*/$FILE_NAME` && TAG=`dirname $TAG` && basename -a $TAG'
    'NUM=(`ls $TAG_HOME/$TAG`) && echo $TAG ${#NUM[@]}'
    )
    
    OPTIND=1
    while getopts "a:d:D:t:T:l:n:Lh" OPTION; do
        case $OPTION in
            a)  TAG_OPT=$ADD_CLS ;;
            d)  TAG_OPT=$DEL_TAG ;;
            D)  TAG_OPT=$DEL_CLS ;;
            t)  TAG_OPT=$ADD_TAG ;;
            T)  TAG_OPT=$ADD_CLS_TAG ;;
            l)  TAG_OPT=$LST_FLS ;;
            L)  TAG_OPT=$LST_TAG ;;
            n)  TAG_OPT=$NUM_FLS ;;
            h)  echo -ne $HELP && return 0 ;;
            ?)  echo -ne $HELP && return 2 ;;
        esac

        # Return when encoutner different opts.
        if [[ $TAG_OPT -ne $LAST_OPT && $LAST_OPT -ne $LST_TAG ]]; then
            echo "Different options!"
            return 6
        fi
        TAGS+=($OPTARG)
        LAST_OPT=$TAG_OPT
    done

    # Number all tags' files if cmd without argument.
    if [[ $# -eq 0 ]]; then
        for TAG in `ls $TAG_HOME`; do
            eval "${TAG_CMD[$NUM_FLS]}"
        done
        return 0;
    fi

    shift $((OPTIND - 1))
    FILES=($@)

    if [[ $TAG_OPT -eq $DEL_TAG || $TAG_OPT -eq $ADD_TAG \
        || $TAG_OPT -eq $ADD_CLS_TAG || $TAG_OPT -eq $LST_TAG ]]; then
        for FILE in ${FILES[@]}; do
            FULL_PATH_FILE=`realpath $FILE`
            FILE_NAME=`basename $FILE`
            for TAG in ${TAGS[@]}; do
                eval "${TAG_CMD[$TAG_OPT]}"
            done
            if [[ $TAG_OPT -eq $LST_TAG ]]; then
                echo "$FILE_NAME:"
                eval "${TAG_CMD[$TAG_OPT]}"
            fi
        done
    else
        for TAG in ${TAGS[@]}; do
            eval "${TAG_CMD[$TAG_OPT]}"
        done
    fi
)}

# Convert the file from cp936 to utf-8.
convfile()
{(
    if [[ $# -ne 1 ]]; then
        echo "Usage: $0 file"
        return 1
    fi

    #Convert encodings and subsititue the \n to none.
    iconv -s -f cp936 -t utf-8 $1 -o $1-tmp && \
        sed -ri 's///g' $1-tmp && \
        rm -rf $1 && \
        mv $1-tmp $1

    return $?
)}

# Use the vim to convert the file encoding and format.
vconv()
{(
    CUR=`pwd`
    SRCDIR=$1
    SRC=`find ${SRCDIR:-$CUR} -type f -a \( -iregex .*\\.h$ -o -iregex .*\\.c$ -o -iregex .*\\.hpp$ -o -regex .*\\.cpp$ \)`

    for NAME in $SRC; do
        vim --noplugin -E -c "set fileencoding=utf-8|set fileformat=unix|wq" $NAME 1>/dev/null
    done
)}

# maketags(): use ctags to generate the tags file
maketag()
{(
    CUR=`pwd`
    SRCDIR=$1
    DESDIR=$2

    #Get the src file list
    find ${SRCDIR:-$CUR} -type f -a \( -iregex .*\\.h$ -o -iregex .*\\.c$ \) >/tmp/tmptags
    #start to make tags
    ctags -R --sort=no \
        --c-kinds=+c+d+e+f+g-l+m+n+p+s+t+u+v+x \
        --fields=+a-f+i+k-K+l-m+n-s+S+z+t \
        --extra=+q-f \
        --languages=c \
        -L /tmp/tmptags \
        -o ${DESDIR:-$CUR}/tags
    rv=$?
    rm -rf /tmp/tmptags
    return $rv
)}

# maketags(): use ctags to generate the tags file
maketags()
{(
    CUR=`pwd`
    SRCDIR=$1
    DESDIR=$2

    #Get the src file list
    find ${SRCDIR:-$CUR} -type f -a \( -iregex .*\\.cpp$ -o -iregex .*\\.h$ -o -iregex .*\\.c$ -o -iregex .*\\.hpp$ \) >/tmp/tmptags
    #start to make tags
    ctags -R --sort=no \
        --c++-kinds=+c+d+e+f+g-l+m+n+p+s+t+u+v+x \
        --fields=+a-f+i+k-K+l-m+n+s+S+z+t \
        --extra=+q-f \
        --languages=c++ \
        -L /tmp/tmptags \
        -o ${DESDIR:-$CUR}/tags
    rv=$?
    rm -rf /tmp/tmptags
    return $rv
)}

#lydump():Use lynx to dump the website
lydump()
{(
    SITE=$1
    CHAR=$2

    if [[ -z $SITE ]]; then
        echo "You must specify a website link."
        return 1
    fi

    lynx -dump -display_charset=${CHAR:-utf-8} $SITE

    return $?
)}

#Man(): Read the manual by vim
Man()
{(
    if [[ $# -gt 2 || $# -eq 0 ]]; then
        echo "Man [1-8] page"
        return 1
    fi

    MARG=$@
    export ManFromShell=1
    vim -c "Man $MARG" -c "bw 1|set tabstop=8|retab"
    rv=$?
    unset ManFromShell
    return $rv
)}

#Vi(): vim MCU source files.
Vi()
{(
        export VISDCC=1
        vim "$@"
        rv=$?
        unset VISDCC
        return $rv
)}

#Rewrite the cd cmd which can show me the oldpwd->pwd info
cd()
{
    builtin cd "$@"
    es=$?
    [[ $es -eq 0 ]] && echo "$OLDPWD -> $PWD" >&2
    return $es
}

#mysmbadd(): SMB user add.
mysmbadd()
{(
    if [[ $# -ne 1 ]]; then
        echo "mysmbadd smbuser"
        return 1
    fi

    #Add the system user for smb user
    echo "Add user to system: $1 ..." && \
    sudo useradd -m -G mysmb $1 && \
    echo "Add password for $1..." && \
    sudo passwd $1 && \
    echo "Add smb user: $1 ..." && \
    sudo pdbedit -a -u $1 && \
    echo "Finished."
    return 0
)}

#mysmbdel(): Delete smb user.
mysmbdel()
{(
    if [[ $# -ne 1 ]]; then
        echo "mysmbdel smbuser"
        return 1
    fi

    echo "Delete smb user: $1" && \
    sudo pdbedit -x -u $1 && \
    echo "Delete system user: $1" && \
    sudo userdel -r $1 && \
    echo "Finished."

    return 0
)}

# function for ruby jekyll blog server to up and down
jekill()
{
    pkill -f jekyll
}

jekyup()
{
    jekill
    (cd /samba/project/git/ishbguy.github.io && jekyll serve -B)
}

weather()
{(
    [[ $# -ne 1 ]] && { echo "weather city"; exit 1; }
    curl http://wttr.in/"$1"
)}

pip_upgrade() {
    for pkg in $(pip list --outdate --format legacy | awk '{print $1}'); do
        sudo pip install --upgrade "${pkg}"
    done
}
