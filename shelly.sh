directory() {
  DIR=$1
  MODE=$2
  OWNER=$3
  GROUP=$4
  if [ "x$DIR" == "x" ]
  then
    echo "No directory specified"
    return 1
  fi
  if [ "x$MODE" == "x" ]
  then
    echo "No mode specified"
    return 1
  fi
  if [ "x$OWNER" == "x" ]
  then
    echo "No owner specified"
    return 1
  fi
  if [ "x$GROUP" == "x" ]
  then
    echo "No group specified"
    return 1
  fi

  if [ ! -d $DIR ]
  then
    mkdir $DIR
    echo "Created directory: $DIR"
  fi
  chmod $MODE $DIR
  chown $OWNER:$GROUP $DIR
}

file() {
  SRC=$1
  DEST=$2
  MODE=$3
  OWNER=$4
  GROUP=$5
  if [ "x$SRC" == "x" ]
  then
    echo "No source file specified"
    return 1
  fi
  if [ "x$DEST" == "x" ]
  then
    echo "No destination file specified"
    return 1
  fi
  if [ "x$MODE" == "x" ]
  then
    echo "No mode specified"
    return 1
  fi
  if [ "x$OWNER" == "x" ]
  then
    echo "No owner specified"
    return 1
  fi
  if [ "x$GROUP" == "x" ]
  then
    echo "No group specified"
    return 1
  fi
  if [ ! -e $SRC ]
  then
    echo "Source file '$SRC' does not exist"
    return 1
  fi
  if [ ! -e $DEST ] || [ "x$(diff -q $SRC $DEST)" != "x" ]
  then
    cp $SRC $DEST
    echo "Copied $SRC to $DEST"
  fi
  chmod $MODE $DEST
  chown $OWNER:$GROUP $DEST
}

template_file() {
  SRC=$1
  shift
  DEST=$1
  shift
  MODE=$1
  shift
  OWNER=$1
  shift
  GROUP=$1
  shift
  VARS=$@
  if [ "x$SRC" == "x" ]
  then
    echo "No source file specified"
    return 1
  fi
  if [ "x$DEST" == "x" ]
  then
    echo "No destination file specified"
    return 1
  fi
  if [ "x$MODE" == "x" ]
  then
    echo "No mode specified"
    return 1
  fi
  if [ "x$OWNER" == "x" ]
  then
    echo "No owner specified"
    return 1
  fi
  if [ "x$GROUP" == "x" ]
  then
    echo "No group specified"
    return 1
  fi
  if [ ! -e $SRC ]
  then
    echo "Template file '$SRC' does not exist"
    return 1
  fi
  if [ "x$VARS" == "x" ]
  then
    file $SRC $DEST $MODE $OWNER $GROUP
  else 
    TMP_FILE=$SRC.evaluated
    export $VARS
    cat $SRC | envsubst > $TMP_FILE
    file $TMP_FILE $DEST $MODE $OWNER $GROUP
  fi
}  

symlink() {
  SRC=$1
  DEST=$2
  if [ "x$SRC" == "x" ]
  then
    echo "No source specified"
    return 1
  fi
  if [ "x$DEST" == "x" ]
  then
    echo "No destination specified"
    return 1
  fi
  if [ ! -e $DEST ]
  then
    ln -s $SRC $DEST
    echo "Symlinked $SRC to $DEST"
  fi
}

git_repo() {
  REPO=$1
  DEST=$2
  MODE=$3
  OWNER=$4
  GROUP=$5
  if [ "x$REPO" == "x" ]
  then
    echo "No git repo specified"
    return 1
  fi
  if [ "x$DEST" == "x" ]
  then
    echo "No destination directory specified"
    return 1
  fi
  if [ "x$MODE" == "x" ]
  then
    echo "No mode specified"
    return 1
  fi
  if [ "x$OWNER" == "x" ]
  then
    echo "No owner specified"
    return 1
  fi
  if [ "x$GROUP" == "x" ]
  then
    echo "No group specified"
    return 1
  fi

  if [ -e $DEST ]
  then
    GIT_DIR=$DEST/.git
    if [ ! -e $GIT_DIR ]
    then
      echo "Directory '$DEST' already exists and is not a git repo"
      return 1
    fi
    git --git-dir $DEST/.git pull
  else
    git clone $REPO $DEST
  fi
  chmod $MODE $DEST
  chown $OWNER:$GROUP $DEST
}

python_egg() {
  EGGS=$@
  if [ "x$EGGS" == "x" ]
  then
    echo "No egg(s) specified"
    return 1
  fi
  easy_install $EGGS
}

python_virtualenv() {
  DEST=$1
  shift
  MODE=$1
  shift
  OWNER=$1
  shift
  GROUP=$1
  shift
  OPTIONS=$@
  if [ "x$DEST" == "x" ]
  then
    echo "No virtualenv directory specified"
    return 1
  fi
  if [ "x$MODE" == "x" ]
  then
    echo "No mode specified"
    return 1
  fi
  if [ "x$OWNER" == "x" ]
  then
    echo "No owner specified"
    return 1
  fi
  if [ "x$GROUP" == "x" ]
  then
    echo "No group specified"
    return 1
  fi

  if [ ! -e $DEST ]
  then
    virtualenv $OPTIONS $DEST
  fi
  chmod -R $MODE $DEST
  chown -R $OWNER:$GROUP $DEST
}

python_virtualenv_egg() {
  VIRTUALENV_DIR=$1
  shift
  EGGS=$@
  if [ "x$VIRTUALENV_DIR" == "x" ]
  then
    echo "No virtualenv directory specified"
    return 1
  fi
  if [ "x$EGGS" == "x" ]
  then
    echo "No egg(s) specified"
    return 1
  fi


  EASY_INSTALL=$VIRTUALENV_DIR/bin/easy_install
  if [ -e $EASY_INSTALL ]
  then
    $EASY_INSTALL $EGGS
  else
    echo "Could not find easy_install in '$VIRTUALENV_DIR' virtualenv"
    return 1
  fi
}


