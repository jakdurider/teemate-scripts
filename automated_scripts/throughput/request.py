import os
import requests
import subprocess
import json
from multiprocessing import Process, Queue
import time
import sys

function_path = "/scripts/benchmarks/SeBS/dynamic-html.js"
ip = ["172.17.0.2","172.17.0.3","172.17.0.4","172.17.0.5"]

code = ""
with open(function_path, 'r') as f:
    code = f.read()

init_data = {"value":{"name":"gramine","binary":False,"main":"main","code":code,"env":{"__OW_DEADLINE":"1700371700224","__OW_ACTION_NAME":"/guest/gramine","__OW_ACTION_VERSION":"0.0.1","__OW_ACTIVATION_ID":"0c4d026aa5ab443e8d026aa5ab143e56","__OW_NAMESPACE":"guest","__OW_TRANSACTION_ID":"aqoyIJ5xUwvAYurgwipkFZTbs3uJPtpq"}}}

run_data = {"action_name":"/guest/gramine","action_version":"0.0.1","activation_id":"0c4d026aa5ab443e8d026aa5ab143e56","deadline":"1700371713979","namespace":"guest","transaction_id":"aqoyIJ5xUwvAYurgwipkFZTbs3uJPtpq","value":{"sentence":"I am happy"}}

headers = {'Content-type': 'application/json', 'Accept': 'text/plain'}

# function for post request
def post_request(args,master_num):
    post_response = requests.post(f"http://{ip[master_num]}:8080/run", data=json.dumps(run_data), headers=headers)
    return

# child container
container_id = 7
req = int(sys.argv[1])
processes = []

start = time.time()

for i in range(req) :
    master_num = (container_id + 1) % 4
    docker_command = f"docker run --rm --name=wsk0_{container_id}_guest_gramine -v /scripts:/scripts -v /scripts{master_num}:/scripts{master_num} -v /sharedVolume:/sharedVolume -v aesmd-socket:/var/run/aesmd --device /dev/sgx_enclave --device /dev/sgx_provision jakdurider/teemate_throughput_image"
    subprocess.Popen(docker_command.split(' '))

    p = Process(target = post_request, args = (1, master_num,))
    processes.append(p)
    p.start()

    container_id += 1

for proc in processes:
    proc.join()

with open("/scripts/final_result/throughput.txt", 'a+') as f:
    f.write(f'req: {req}, time: {time.time() - start}\n')

for proc in processes:
    proc.kill()
