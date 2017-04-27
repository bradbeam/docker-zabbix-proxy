#!/bin/bash

usage () {
    echo "usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  OPTIONAL:"
    echo "    -m, --monit          Command to pass to Monit {start|stop|restart|shell|status|summary}. Default: run"
}

# http://stackoverflow.com/a/14203146/3236644
while [[ $# > 0 ]]
do
  key="$1"

  case $key in
      -m|--monit)
          MONIT_CMD="$2"
          shift #past argument
      ;;
      *)
          echo "ERROR: unrecognized option(s)"
          usage
          exit 1
      ;;
  esac
  shift # past argument or value
done

# Default to "run" if none was provided
if [ -z "$MONIT_CMD" ]; then
    MONIT_CMD="run"
fi

# Start Zabbix proxy with monit
# https://github.com/berngp/docker-zabbix/blob/master/scripts/entrypoint.sh
_cmd="/usr/bin/monit -d 10 -l /dev/stdout -Ic /etc/monit/monitrc"
_shell="/bin/bash"

case "$MONIT_CMD" in
  run)
    echo "Running Monit... "
    exec /usr/bin/monit -d 10 -Ic /etc/monit/monitrc
    ;;
  stop)
    $_cmd stop all
    RETVAL=$?
    ;;
  restart)
    $_cmd restart all
    RETVAL=$?
    ;;
  shell)
    $_shell
    RETVAL=$?
    ;;
  status)
    $_cmd status all
    RETVAL=$?
    ;;
  summary)
    $_cmd summary
    RETVAL=$?
    ;;
  *)
    echo $"Usage: $0 {start|stop|restart|shell|status|summary}"
    RETVAL=1
esac
