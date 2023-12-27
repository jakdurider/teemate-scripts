import os
import requests
import subprocess
import json
from multiprocessing import Process, Queue
import time
import sys

docker_command0 = "docker run --rm --name=wsk0_3_guest_gramine -v /scripts:/scripts -v /sharedVolume:/sharedVolume -v aesmd-socket:/var/run/aesmd --device /dev/sgx_enclave --device /dev/sgx_provision jakdurider/teemate_throughput_image"
docker_command1 = "docker run --rm --name=wsk0_4_guest_gramine -v /scripts:/scripts -v /sharedVolume:/sharedVolume -v aesmd-socket:/var/run/aesmd --device /dev/sgx_enclave --device /dev/sgx_provision jakdurider/teemate_throughput_image"
docker_command2 = "docker run --rm --name=wsk0_5_guest_gramine -v /scripts:/scripts -v /sharedVolume:/sharedVolume -v aesmd-socket:/var/run/aesmd --device /dev/sgx_enclave --device /dev/sgx_provision jakdurider/teemate_throughput_image"
docker_command3 = "docker run --rm --name=wsk0_6_guest_gramine -v /scripts:/scripts -v /sharedVolume:/sharedVolume -v aesmd-socket:/var/run/aesmd --device /dev/sgx_enclave --device /dev/sgx_provision jakdurider/teemate_throughput_image"

subprocess.Popen(docker_command0.split(' '))
time.sleep(3)
subprocess.Popen(docker_command1.split(' '))
time.sleep(3)
subprocess.Popen(docker_command2.split(' '))
time.sleep(3)
subprocess.Popen(docker_command3.split(' '))
time.sleep(30)

# master container
function_path = "/scripts/benchmarks/SeBS/dynamic-html.js"
ip = ["172.17.0.2","172.17.0.3","172.17.0.4","172.17.0.5"]

code = ""
with open(function_path, 'r') as f:
    code = f.read()

init_data = {"value":{"name":"gramine","binary":False,"main":"main","code":code,"env":{"__OW_DEADLINE":"1700371700224","__OW_ACTION_NAME":"/guest/gramine","__OW_ACTION_VERSION":"0.0.1","__OW_ACTIVATION_ID":"0c4d026aa5ab443e8d026aa5ab143e56","__OW_NAMESPACE":"guest","__OW_TRANSACTION_ID":"aqoyIJ5xUwvAYurgwipkFZTbs3uJPtpq"}}}

run_data = {"action_name":"/guest/gramine","action_version":"0.0.1","activation_id":"0c4d026aa5ab443e8d026aa5ab143e56","deadline":"1700371713979","namespace":"guest","transaction_id":"aqoyIJ5xUwvAYurgwipkFZTbs3uJPtpq","value":{"sentence":"I am happy"}}

for ip_addr in ip:
    headers = {'Content-type': 'application/json', 'Accept': 'text/plain'}
    response = requests.post(f"http://{ip_addr}:8080/init", data=json.dumps(init_data), headers=headers)
    print(response.status_code)
    print(response.json())
    response = requests.post(f"http://{ip_addr}:8080/run", data=json.dumps(run_data), headers=headers)
    print(response.status_code)
    print(response.json())
