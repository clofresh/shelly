shelly(1)
=========

NAME
----
shelly - A simple bash library to aid in configuration management

SYNOPSIS
--------
`user` <var>name</var> [<var>option0</var> [<var>option1</var> [...]]] 

`directory` <var>dest</var> <var>mode</var> <var>owner</var> <var>group</var> 

`file` <var>src</var> <var>dest</var> <var>mode</var> <var>owner</var> <var>group</var> 

`template_file` <var>src</var> <var>dest</var> <var>mode</var> <var>owner</var> <var>group</var>  [<var>keyval0</var> [<var>keyval1</var> [...]]] 

`symlink` <var>src</var> <var>dest</var> 

`git_repo` <var>repo_url</var> <var>dest</var> <var>mode</var> <var>owner</var> <var>group</var> 

`python_egg` <var>egg0</var> [<var>egg1</var> [<var>egg2</var> [...]]] 

`python_virtualenv` <var>dest</var> <var>mode</var> <var>owner</var> <var>group</var> [<var>option0</var> [<var>option1</var> [...]]] 

`python_virtualenv_egg` <var>virtalenv_dest</var> <var>egg0</var> [<var>egg1</var> [<var>egg2</var> [...]]] 


DESCRIPTION
-----------
Function calls to idempotently configure system files and directories. Basically taking the good ideas, like file templating and idempotency, from more complicated configuration management systems and simplifying them enough to work as a standalone library of shell commands instead of a monolithic framework that eventually just calls shell commands.

EXAMPLES
--------
A script to set up a supervised Flask app.

    $ cat > run.sh
    #!/bin/bash

    source shelly.sh

    ROOT_USER=root
    ROOT_GROUP=root
    SUPERVISOR_DIR=/etc/supervisor
    SUPERVISOR_CONFD_DIR=$SUPERVISOR_DIR/conf.d
    directory $SUPERVISOR_DIR 755 $ROOT_USER $ROOT_GROUP
    directory $SUPERVISOR_CONFD_DIR 755 $ROOT_USER $ROOT_GROUP
    directory /usr/local/var 755 $ROOT_USER $ROOT_GROUP

    python_egg supervisor

    APP_USER=web
    APP_GROUP=web
    APP_DIR=/usr/local/my_app
    APP_LOG_DIR=/usr/local/var/log
    APP_LOG=$APP_LOG_DIR/my_app.log
    VIRTUALENV_DIR=$APP_DIR/python
    APP_SRC_DIR=$APP_DIR/src

    user $APP_USER --system --no-create-home --disabled-password
    directory $APP_DIR 755 $APP_USER $APP_GROUP
    directory $APP_LOG_DIR 775 $ROOT_USER $APP_GROUP
    python_virtualenv $VIRTUALENV_DIR 755 $APP_USER $APP_GROUP
    python_virtualenv_egg $VIRTUALENV_DIR flask

    git_repo test \
      $APP_SRC_DIR \
      755 \
      $APP_USER \
      $APP_GROUP

    template_file supervisor-my-app.conf \
      $SUPERVISOR_DIR/supervisor-my-app.conf \
      644 \
      $ROOT_USER \
      $ROOT_GROUP \
      APP_NAME=my_app \
      APP_HOME=$APP_SRC_DIR \
      APP_USER=$APP_USER \
      VIRTUALENV_DIR=$VIRTUALENV_DIR \
      APP_LOG=$APP_LOG


    $ cat > supervisor-my-app.conf
    [program:$APP_NAME]
    directory=$APP_HOME
    user=$APP_USER
    command=$VIRTUALENV_DIR/bin/python $APP_HOME/my_app.py
    autostart=true
    autorestart=true
    redirect_stderr=true
    stdout_logfile=$APP_LOG

Running sudo ./run.sh will set up the application and have the same end state
regardless of how many times you run the script. This is what we mean by
idempotent. If you wish to ensure that the configuration stays put, similar to other config management systems, you could set up a simple cronjob to run the
script periodically.



[shelly(1)]: shelly.1.html
