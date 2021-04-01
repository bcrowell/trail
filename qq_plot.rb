#!/bin/ruby

require 'json'
require 'csv'

require_relative "lib/routes"
require_relative "lib/endurance"
require_relative "lib/line_plot"
require_relative "lib/cumulative_distributions"
require_relative "lib/stat"

$outfile = "qq.csv"

def main()
  d = {}
  File.open('matches.json','r') { |f|
    d = JSON.parse(f.gets(nil))
  }

  #   # {"albert allen":{"wilson":1.4861111111111112,"baldy":1.8894444444444445},"amelie joffrin":{"wilson":1.4519444444444445,"baldy":1.9194444444444443},

  do_log = false
  do_uniform = false # for testing purposes, to make sure I understand interpretation; generates uniformly distributed data
  do_normal = false # if false, then we do Student's t
  nu = 2 # order for Student's t
  w = 1.61 # rescale data by this arbitrary factor; necessary for nu<3 because s.d. is theoretically undefined

  # Use the following code to find sample sizes for different combos, uncomment print statement at the bottom.
  combos = {}
  d.keys.sort.each { |who|
    times = d[who]
    if times.keys.length<2 then next end
    courses = times.keys.sort
    courses.each { |c1|
      courses.each { |c2|
        if c1>=c2 then next end
        cc = "#{c1},#{c2}"
        if combos.has_key?(cc) then combos[cc]+=1 else combos[cc]=1 end
      }
    }
    t1 = times[courses[0]]
    t2 = times[courses[1]]
  }
  #print combos,"\n"

  # "big_bear,canyon_city" = 295
  c1 = "big_bear"
  c2 = "canyon_city"
  x = []
  d.keys.sort.each { |who|
    times = d[who]
    if not (times.has_key?(c1) and times.has_key?(c2)) then next end
    t1 = times[c1]
    t2 = times[c2]
    if do_uniform then
      x.push(Random.rand())
      next
    end
    if do_log then
      x.push(Math::log(t1/t2))
    else
      x.push(t1/t2)
    end
  }
  n = x.length
  median,mean,sd = stats(x)
  print c1," ",c2," n=",n,"    median, mean, sd, kurtosis=",stats(x),"\n"

  max_diff = 0
  File.open($outfile,'w') { |f|
    i = 0
    x.sort.each { |r|
      q = (i+0.5)/n.to_f
      i = i+1
      z = (r-mean)/sd
      if do_normal then
        cum = normal_cum(z)
      else
       
        if nu<=2 then
          t = z*w
        else
          t = z*Math::sqrt(nu.to_f/(nu-2))
        end
        cum = student_t_cum(t,nu)
      end
      if (q-cum).abs>max_diff then max_diff = (q-cum).abs end
      f.print "#{r},#{q},#{cum},#{q-cum}\n"
    }
  }
  print "do_log,do_uniform,do_normal,nu = ",[do_log,do_uniform,do_normal,nu],"\n"
  if nu<=2 then print "w=#{w}\n" end
  print "max_diff=#{max_diff}\n"
  print "wrote #{$outfile}\n"
end


def pf(x,m,n)
  return "%#{m}.#{n}f" % [x]
end

def ptime(hrs)
  # convert a time in hours to a human-readable string
  h = hrs.to_i
  m = ((hrs-h)*60.0).round
  return "%2d:%02d" % [h,m]
end

def die(s)
  $stderr.print s,"\n"
  exit(-1)
end

main()
