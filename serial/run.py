import os
import subprocess

for filename in os.listdir("../../input"):
    # print filename
    # print(os.path.splitext(filename)[0])
    filename_clean = os.path.splitext(filename)[0]
    proc = subprocess.Popen(["./serial.o",filename_clean])
    proc.wait()
# proc = subprocess.Popen(["./serial.o","cit-HepPh_adj"])
# print (os.getcwd())
