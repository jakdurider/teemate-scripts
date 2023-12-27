from numpy import random

# scale = 1 / lambda
x_list = random.exponential(scale=1, size = 10000)

with open('space.txt', 'w+') as f:
    for x in x_list:
        f.write(str(x) + '\n')
