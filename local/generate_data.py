#!/bin/python3
import sys
import numpy as np
np.random.seed(200527)
means=[[1, 2],[-3,-5]]
stds=[[2, 0.5],[1,1]]
size=[1000, 2]
frame_size=1
data=np.concatenate((np.random.normal(means[0],stds[0],size), np.random.normal(means[1],stds[1],size)))
output=open(sys.argv[1],'w')
for i in range(0, data.shape[0]):
    if i%frame_size == 0:
        output.write("%08d [\n" %(i/frame_size))
    if i%frame_size == frame_size-1:
        output.write("\t%d %d ]\n" %(data[i,0],data[i,1]))
    else:
        output.write("\t%d %d\n" %(data[i,0],data[i,1]))
output.flush()
output.close()
