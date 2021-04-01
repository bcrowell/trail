import matplotlib

matplotlib.use('SVG')
import matplotlib.pyplot as plt
import numpy as np
import copy
import subprocess

#----------------------
draft = False
minetti_r = 0
#----------------------



mi_to_km = 1.609344

dc = 13.1*mi_to_km # critical distance, in km; set it to a half marathon
vm = 1.0/6.5 # speed in miles per minute
outfile = "minetti.svg"

x_min = -0.4
x_max = 0.4

if draft:
  dx = 0.1
else:
  dx = 0.01
x = np.arange(x_min, x_max, dx)
y = copy.copy(x)
y_hockey = copy.copy(x)

def minetti(i):
  result = subprocess.check_output(["/home/bcrowell/Documents/research/trail/lib/compute_minetti.rb",str(i),str(minetti_r)])
  return float(result)

c0 = minetti(0)
cg = 6.0

for j in range(len(x)):
  y[j] = minetti(x[j])
  xx = x[j]
  if xx<0.0:
    y_hockey[j] = c0
  else:
    y_hockey[j] = c0*(1+cg*xx)

fig, ax = plt.subplots()
width = 132.0/25.4 # 132 mm->inches (PLOS column size)
fig.set_size_inches(width,width)

ax.set_ylim(0.0,18)
ax.grid(which='both',axis='both')

lines = ax.plot(x, y)
plt.setp(lines, color='black', linewidth=1.0)

lines = ax.plot(x, y_hockey, dashes=[6, 2])
plt.setp(lines, color='black', linewidth=1.0)

ax.set(xlabel='slope i', ylabel='cost of running, C (J/kg-m)')
ax.grid()

fig.savefig(outfile)
print(f'wrote output file {outfile}')
plt.show()


