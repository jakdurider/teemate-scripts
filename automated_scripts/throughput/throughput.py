import subprocess
import time
import os
import sys

req = int(sys.argv[1])
native_or_gramine = sys.argv[2]
start = time.time()
processes=[]
start = time.time()
if native_or_gramine == "native" or req <= 64 :
    for _ in range(req):
        each_start = time.time()
        proc = subprocess.Popen(["wsk", "action", "invoke", 
        native_or_gramine, "-r", "-p", "sentence", "happy"])
        processes.append(proc)
        print(f'each_popen: {time.time() - each_start}')

    for proc in processes:
        proc.wait()

else :
    batch = 8
    batch_time = 1
    for _ in range(req + req // 8) :
        proc = subprocess.Popen(["wsk", "action", "invoke", native_or_gramine, "-r", "-p", "sentence", "happy"])
        processes.append(proc)
        time.sleep(batch_time)

    while True:
        success = 0
        for proc in processes:
            if proc.poll() is not None:
                success += 1
        print(f'success: {success}, time: {time.time() - start}\n')
        time.sleep(0.3)
        if success >= req:
            break

with open("/scripts/final_result/throughput.txt", 'a+') as f:
    f.write(f'req: {req}, time: {time.time() - start}\n')
  
for proc in processes:
    proc.kill()


