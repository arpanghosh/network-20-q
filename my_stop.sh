####################
#!/bin/bash

this_path=`pwd`
pids_path="$this_path/tmp/pids/*.pid"

for thin_pid in $pids_path
do
    echo "Stoping Thin Instance $thin_pid"
    thin stop -P $thin_pid
done
####################
