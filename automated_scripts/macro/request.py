import os
import requests
import subprocess
import json
from multiprocessing import Process, Queue
import time
import sys

command = "wsk action invoke native -r" 

def request(args):
    start_time = time.time()
    os.system(command)
    end_time = time.time()
    with open('latency.txt', 'a+') as f_latency:
        f_latency.write(f"{end_time - start_time}\n")
    

with open('space.txt', 'r') as f:
    for line in f:
        space = float(line)
        print(space)
        p = Process(target = request, args = (1,))
        p.start()
        time.sleep(space) 
