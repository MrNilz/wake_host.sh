#!/bin/bash

listen_interface=$1
listen_dns=$2
host_mac=$3

# check for necessary commands
if ! type tcpdump &> /dev/null || ! type etherwake &> /dev/null || ! type logger &> /dev/null || ! type mkfifo &> /dev/null || ! type mktemp &> /dev/null || ! type wait &> /dev/null;
    then
    echo "Necessary dependency is missing. tcpdump, etherwake, logger, mkfifo, mktemp, wait are required - exiting"
    exit 1
fi

_term() { 
  # echo "Caught SIGTERM signal!" 
  # echo "Killing $TCPDUMP_PID $GREP_PID"
  kill -TERM "$TCPDUMP_PID"
  kill -TERM "$GREP_PID"
  # echo "Deleting $TCPDUMP_PIPE $GREP_PIPE" 
  rm $TCPDUMP_PIPE
  rm $GREP_PIPE
  logger -t WakeHost "Stopped watching for DNS call to $listen_dns"
}

trap _term SIGTERM

logger -t WakeHost "Start watching for DNS call to $listen_dns on interface $listen_interface and sending WOL to $host_mac"

# Create tcpdump process with a named pipe and store PID
TCPDUMP_PIPE=$(mktemp -u)
mkfifo $TCPDUMP_PIPE
tcpdump -nn -p -s0 -i "$listen_interface" port 53 >$TCPDUMP_PIPE 2>&1 & 
TCPDUMP_PID=$!

# Create grep process with a named pipe and store PID
GREP_PIPE=$(mktemp -u)
mkfifo $GREP_PIPE
grep --line-buffered "$listen_dns" <$TCPDUMP_PIPE >$GREP_PIPE & 
GREP_PID=$!

# Create pipemill process
while read line ; do 
  etherwake -i "$listen_interface" "$host_mac" & disown
  logger -t WakeHost "Captured DNS call to $listen_dns and sending WOL to $host_mac"
done <$GREP_PIPE 

# Wait for first process to terminate
wait "$TCPDUMP_PID"

