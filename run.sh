#!/bin/bash
# Go to the working directory
cd "$(dirname $0)"

# Create variables for work dir, log dir and log file
WORKDIR="$(pwd -P)"
LOGDIR="$WORKDIR/log"
LOG="$LOGDIR/log.txt"

# Check if it is debug or release
if [[ "$WORKDIR" == *"evelop"* ]]
then	SCHEME=debug
else	SCHEME=release
fi

# Create log directory if it does not exists
mkdir -p "$LOGDIR"

# Remember the current environment for future analysis
env > "$LOGDIR/env.txt"

# Print the scheme
echo WORKDIR: "$WORKDIR" >> "$LOG" 2>&1
echo SCHEME: $SCHEME >> "$LOG" 2>&1

# Replace port 8888 with 80
# cat Sources/Server/Main/main.swift | sed "s/onPort: 8888/onPort: 80/" > main.swift.new
# mv -f main.swift.new Sources/Server/Main/main.swift >> "$LOG" 2>&1

# Stop running server 
killall Server >> "$LOG" 2>&1

# Run it again with old codebase
.build/$SCHEME/Server >> "$LOG" 2>&1 &

# Compile new codebase
swift package clean
swift build -c $SCHEME >> "$LOG" 2>&1

# Stop running server again
killall Server >> "$LOG" 2>&1

# Run the server with new codebase
.build/$SCHEME/Server >> "$LOG" 2>&1 &
