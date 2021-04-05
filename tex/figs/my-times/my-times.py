import matplotlib
import csv

matplotlib.use('SVG')
import matplotlib.pyplot as plt
import numpy as np
import copy
import subprocess

matplotlib.rcParams.update({'font.size': 14})

half_marathon_in_km = 21.1 # kilometers

with open('./sm_half_ratios.py') as f: exec(f.read())
sm_half_ratios = [x * (10.0/half_marathon_in_km) for x in sm_half_ratios]

griffith_park_actual_d = 28.5
griffith_park_equiv_d = 32.0
#...28.5 km is my measured distance; divide by 1-.11 for CF of 11%
with open('./griffith_half_ratios.py') as f: exec(f.read())
griffith_half_ratios = [x * (griffith_park_actual_d/half_marathon_in_km) for x in griffith_half_ratios]

mi_to_km = 1.609344

dc = 13.1*mi_to_km # critical distance, in km; set it to a half marathon
# vm = 1.0/6.62 # speed in miles per minute; my best at mile
vm = 13.1/(60*1.64694444444444) # my best at half marathon
outfile = "my-times.svg"

x_min = 1.0 # distance in km
x_max = 30.0*mi_to_km

draft = True
if draft:
  dx = 1
else:
  dx = 0.25
x = np.arange(x_min, x_max, dx)
y = copy.copy(x)
y_cameron = copy.copy(x)

def kappa(d,dc):
  result = subprocess.check_output(["/home/bcrowell/Documents/research/trail/lib/compute_endurance.rb",str(d),str(dc)])
  return float(result)

def cameron(d_km):
  # http://run-down.com/statistics/calcs_explained.php
  # http://www.cs.uml.edu/~phoffman/cammod.html
  # input in km, output in m/s
  A,B,C,p = [13.49681,0.000030363,835.7114,0.7905]
  d = d_km*1000.0
  return A-B*d+C*d**-p

for j in range(len(x)):
  y[j] = kappa(x[j],dc)/kappa(half_marathon_in_km,dc)
  y_cameron[j] = cameron(x[j])/cameron(half_marathon_in_km)

fig, ax = plt.subplots()
width = 132.0/25.4 # 132 mm->inches (PLOS column size)
fig.set_size_inches(width,width)

ax.set_xscale("log")
ax.set_yscale("log")
ax.set_ylim(0.5,1.2)
#ax.set_xticks(np.arange(x_min, x_max, 0.2) , minor=True)
ax.grid(which='both',axis='both')
lines = ax.plot(x, y)
plt.setp(lines, color='black', linewidth=1.0)

lines = ax.plot(x, y_cameron)
plt.setp(lines, color='red', linewidth=1.0)

x_real = []
y_real = []
j = 0
with open('pr.csv') as csvfile:
  myreader = csv.reader(csvfile, delimiter=',')
  for row in myreader:
    j = j+1
    if j>1: # skip header line
      d = float(row[0]) # equivalent distance in miles
      if d>=x_min:
        t = float(row[1]) # minutes
        v = d/t
        x_real.append(d*mi_to_km)
        y_real.append(v/vm)

print(x_real)
print(y_real)
ax.plot(x_real, y_real, 'o', color='tab:gray',markersize=3)

scale_widths = 0.33
ax.violinplot(sm_half_ratios,positions=[10.1],widths=[scale_widths*10.1],showextrema=True,
                  showmeans=False,
                  showmedians=True)
ax.violinplot(griffith_half_ratios,positions=[griffith_park_equiv_d],widths=[scale_widths*griffith_park_equiv_d],showextrema=True,
                  showmeans=False,
                  showmedians=True)

ax.set(xlabel='equivalent distance (km)', ylabel='speed (relative units)')
ax.grid()

fig.savefig(outfile)
print(f'wrote output file {outfile}')
plt.show()


