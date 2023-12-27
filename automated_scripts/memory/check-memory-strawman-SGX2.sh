#!/bin/bash

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

final_memory_file="/scripts/final_result/memory.txt"

runtime_start_signal_file="/scripts/result/runtime_start"
runtime_end_signal_file="/scripts/result/runtime_end"

node_initialize_end_file="/scripts/result/node_initialize_end.txt"

workloads=(
    "own_benchmark/useless.js"    
#    "own_benchmark/auth.js"    
#    "own_benchmark/face-detection.js"    
#    "own_benchmark/sentiment-analysis.js"    
#    "own_benchmark/wav-decoder.js"    
#    "SeBS/dynamic-html.js"
#    "SeBS/sleep.js"
#    "SeBS/uploader.js"
#    "Sunspider/access-binary-trees.js"    
#    "Sunspider/crypto-md5.js"    
#    "Sunspider/regexp-dna.js"    
#    "Sunspider/crypto-aes.js"    
#    "Sunspider/math-partial-sums.js"    
#    "Sunspider/string-validate-input.js"    
)

test_num=(
    1
#    2
#    4
#    8
#    16
#    32
#    64
)

rm -f $final_memory_file
install -m 666 /dev/null $final_memory_file

for i in "${workloads[@]}"
do
    echo "" >> $final_memory_file 
    echo $i >> $final_memory_file 
    echo "" >> $final_memory_file 

    # run OpenWhisk
    cd ~/openwhisk
    ./run.sh &
    sleep 40

    # prepare temporary files
    install -m 666 /dev/null $container_creation_start_file
    install -m 666 /dev/null $container_creation_end_file
    install -m 666 /dev/null $enclave_aliasing_file
    install -m 666 /dev/null $runtime_init_gramine_file
    install -m 666 /dev/null $runtime_init_worker_file
    install -m 666 /dev/null $latency_exec_file
    install -m 666 /dev/null $enclave_creation_runtime_file
    install -m 666 /dev/null $enclave_creation_exec_file
    install -m 666 /dev/null $runtime_start_signal_file
    install -m 666 /dev/null $runtime_end_signal_file

    cd /scripts/benchmarks
    wsk action create native --docker jakdurider/strawman_test_image $i -m 256 -t 3000000

    for num in "${test_num[@]}"
    do
        echo "" >> $final_memory_file 
        echo $num >> $final_memory_file 
        echo "" >> $final_memory_file 
        for ((test=1;test<=$num;++test))
        do
            # run worker container
            wsk action invoke native -r -p sentence "I am happy" &
        done
        ./../automated_scripts/memory/sgx_stat $final_memory_file &
        
        sleep 60

        pkill -9 -ef sgx_stat

        docker stop $(docker ps -a --format '{{.Names}}' --filter name='wsk*')
        docker rm $(docker ps -a --format '{{.Names}}' --filter name='wsk*')
    done
    pkill -9 -ef openwhisk
done

