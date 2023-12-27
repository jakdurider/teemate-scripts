#!/bin/bash

set -e

ITER=25

container_creation_start_file="/scripts/result/container_creation_start_time.txt"
container_creation_end_file="/scripts/result/container_creation_end_time.txt"
enclave_aliasing_file="/scripts/result/enclave_aliasing_time.txt"
enclave_creation_file="/scripts/result/enclave_creation_time.txt"
enclave_creation_runtime_file="/scripts/result/enclave_creation_time_runtime.txt"
enclave_creation_exec_file="/scripts/result/enclave_creation_time_exec.txt"
runtime_init_gramine_file="/scripts/result/runtime_init_time_gramine.txt"
runtime_init_worker_file="/scripts/result/runtime_init_time_worker.txt"
latency_exec_file="/scripts/result/latency_exec_time.txt"
final_latency_file="/scripts/final_result/latency.txt"

runtime_end_signal_file="/scripts/result/runtime_end"

node_initialize_end_file="/scripts/result/node_initialize_end.txt"

workloads=(
    "own_benchmark/auth.js"    
    "own_benchmark/face-detection.js"    
    "own_benchmark/sentiment-analysis.js"    
    "own_benchmark/wav-decoder.js"    
    "SeBS/dynamic-html.js"
    "SeBS/sleep.js"
    "SeBS/uploader.js"
    "Sunspider/access-binary-trees.js"    
    "Sunspider/crypto-md5.js"    
    "Sunspider/regexp-dna.js"    
    "Sunspider/crypto-aes.js"    
    "Sunspider/math-partial-sums.js"    
    "Sunspider/string-validate-input.js"    
)

rm -f $final_latency_file
install -m 666 /dev/null $final_latency_file

# Native
for i in "${workloads[@]}"
do
    echo "" >> $final_latency_file 
    echo $i >> $final_latency_file 
    echo "" >> $final_latency_file 

    # run OpenWhisk
    cd ~/openwhisk
    ./run.sh &
    sleep 40
   
    # run master container
    cd /scripts/benchmarks
    wsk action create native --docker jakdurider/strawman_test_image $i

    for ((test=1;test<=$ITER;++test))
    do
        # prepare temporary files
        install -m 666 /dev/null $container_creation_start_file
        install -m 666 /dev/null $container_creation_end_file
        install -m 666 /dev/null $enclave_creation_file
        install -m 666 /dev/null $node_initialize_end_file
        install -m 666 /dev/null $latency_exec_file
        install -m 666 /dev/null $runtime_end_signal_file
        
        # run worker container
        wsk action invoke native -r -p sentence "I am happy"
        
        # aggregate temporary results
        cat $latency_exec_file >> $final_latency_file

        # remove temporary results
        rm -f $container_creation_start_file
        rm -f $container_creation_end_file
        rm -f $enclave_creation_file
        rm -f $node_initialize_end_file
        rm -f $latency_exec_file
        rm -f $runtime_end_signal_file
    done
    pkill -9 -ef openwhisk
done

<<comment
# TEEMATE-LATENCY
rm -f $final_latency_file
install -m 666 /dev/null $final_latency_file

for i in "${workloads[@]}"
do
    echo "" >> $final_latency_file 
    echo $i >> $final_latency_file 
    echo "" >> $final_latency_file 

    # run OpenWhisk
    cd ~/openwhisk
    ./run.sh &
    sleep 20
   
    # run master container
    cd /scripts/benchmarks
    wsk action create gramine --docker jakdurider/teemate_test_image $i -m 4096 -t 3000000
    wsk action invoke gramine -r -p sentence "I am happy" 
    sleep 15
    docker unpause wsk0_3_guest_gramine

    for ((test=1;test<=$ITER;++test))
    do
        # prepare temporary files
        install -m 666 /dev/null $container_creation_start_file
        install -m 666 /dev/null $container_creation_end_file
        install -m 666 /dev/null $enclave_aliasing_file
        install -m 666 /dev/null $runtime_init_gramine_file
        install -m 666 /dev/null $runtime_init_worker_file
        install -m 666 /dev/null $latency_exec_file
        
        # run worker container
        echo "container creation start: $(date +%s%3N)" >> $container_creation_start_file
        wsk action invoke gramine -r -p sentence "I am happy"
        
        # aggregate temporary results
        cat $container_creation_start_file >> $final_latency_file
        cat $container_creation_end_file >> $final_latency_file
        cat $enclave_aliasing_file >> $final_latency_file
        cat $runtime_init_gramine_file >> $final_latency_file
        cat $runtime_init_worker_file >> $final_latency_file
        cat $latency_exec_file >> $final_latency_file

        # remove temporary results
        rm -f $container_creation_start_file
        rm -f $container_creation_end_file
        rm -f $enclave_aliasing_file
        rm -f $runtime_init_gramine_file
        rm -f $runtime_init_worker_file
        rm -f $latency_exec_file
    done
    pkill -9 -ef openwhisk
done

comment
