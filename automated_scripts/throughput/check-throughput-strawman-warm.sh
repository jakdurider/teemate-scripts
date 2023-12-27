#!/bin/bash

set -e

ITER=25

container_creation_start_file="/scripts/result/container_creation_start_time.txt"
container_creation_end_file="/scripts/result/container_creation_end_time.txt"
final_throughput_file="/scripts/final_result/throughput.txt"

workloads=(
#    "own_benchmark/auth.js"    
#    "own_benchmark/face-detection.js"    
#    "own_benchmark/sentiment-analysis.js"    
#    "own_benchmark/wav-decoder.js"    
#    "SeBS/dynamic-html.js"
#    "SeBS/sleep.js"
    "SeBS/uploader.js"
#    "Sunspider/access-binary-trees.js"    
#    "Sunspider/crypto-md5.js"    
#    "Sunspider/regexp-dna.js"    
#    "Sunspider/crypto-aes.js"    
#    "Sunspider/math-partial-sums.js"    
#    "Sunspider/string-validate-input.js"    
)

iter_num=(
    1
    2
    4
    8
    16
    32
    64
)


rm -f $final_throughput_file
install -m 666 /dev/null $final_throughput_file

for i in "${workloads[@]}"
do
    echo "" >> $final_throughput_file 
    echo $i >> $final_throughput_file 
    echo "" >> $final_throughput_file 
    
    # run OpenWhisk
    cd ~/openwhisk
    ./run.sh &
    sleep 60
    cd /scripts/benchmarks
    wsk action create native --docker jakdurider/strawman_test_image $i -m 128 -t 30000000

    cd /scripts/automated_scripts/throughput
    python throughput.py 64 native
   
    for iter in "${iter_num[@]}"
    do
    
        # prepare temporary files
        install -m 666 /dev/null $container_creation_start_file
        install -m 666 /dev/null $container_creation_end_file
    
        cd /scripts/automated_scripts/throughput
        python throughput.py $iter native

        # aggregate temporary results

        # remove temporary results
        rm -f $container_creation_start_file
        rm -f $container_creation_end_file
    done
    pkill -9 -ef openwhisk
done
