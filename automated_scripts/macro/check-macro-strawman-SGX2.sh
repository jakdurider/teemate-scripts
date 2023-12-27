#!/bin/bash

container_creation_start_file="/scripts/result/container_creation_start_time.txt"
container_creation_end_file="/scripts/result/container_creation_end_time.txt"
final_throughput_file="/scripts/final_result/throughput.txt"
latency_file="latency.txt"
memory_file="memory.txt"

workloads=(
#    "own_benchmark/auth.js"    
#    "own_benchmark/face-detection.js"    
#    "own_benchmark/sentiment-analysis.js"    
#    "own_benchmark/wav-decoder.js"    
    "SeBS/dynamic-html.js"
#    "SeBS/sleep.js"
#    "SeBS/uploader.js"
#    "Sunspider/access-binary-trees.js"    
#    "Sunspider/crypto-md5.js"    
#    "Sunspider/regexp-dna.js"    
#    "Sunspider/crypto-aes.js"    
#    "Sunspider/math-partial-sums.js"    
#    "Sunspider/string-validate-input.js"    
)

iter_num=(
    1
#    2
#    4
#    8
#    16
#    32
#    64
)


rm -f $final_throughput_file
install -m 666 /dev/null $final_throughput_file

for i in "${workloads[@]}"
do
    rm -f $memory_file
    rm -f $latency_file
    install -m 666 /dev/null $memory_file
    install -m 666 /dev/null $latency_file
    
    # run OpenWhisk
    cd ~/openwhisk
    ./run.sh &
    sleep 30
   
    # run master container
    cd /scripts/benchmarks
    wsk action create native --docker jakdurider/strawman_test_image $i -m 256 -t 3000000
    wsk action invoke native -r -p sentence "I am happy"
    install -m 666 /dev/null $container_creation_start_file
    install -m 666 /dev/null $container_creation_end_file

    cd /scripts/automated_scripts/macro
    python request.py &
    ./sgx_stat memory.txt &

    # aggregate temporary results

    # remove temporary results
    rm -f $container_creation_start_file
    rm -f $container_creation_end_file
    sleep 600
    pkill -9 -ef openwhisk
    pkill -9 -ef request.py
    pkill -9 -ef sgx_stat
done
