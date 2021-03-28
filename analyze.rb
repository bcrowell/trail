#!/bin/ruby

require 'json'
require 'csv'

require_relative "lib/routes"

def main()
  d = {}
  File.open('matches.json','r') { |f|
    d = JSON.parse(f.gets(nil))
  }

  # {"albert allen":{"wilson":1.4861111111111112,"baldy":1.8894444444444445},"amelie joffrin":{"wilson":1.4519444444444445,"baldy":1.9194444444444443},

  course_horiz,course_cf,course_gain = get_route_data("data/routes.csv")

  # uphill compared to flat
  errors = []
  d.keys.sort.each { |who|
    times = d[who]
    flat   = array_intersection(["pasadena","chesebro","into_the_wild"],times.keys)
    uphill = array_intersection(["baldy","broken_arrow"],times.keys)
    if flat.empty? or uphill.empty? then next end
    flat.each { |c1|
      uphill.each { |c2|
        t1,t2,d1,d2,err = cross_ratio(c1,c2,times,course_horiz,course_cf)
        print "#{pname(who)}       #{pcourse(c1)}=#{ptime(t1)}        #{pcourse(c2)}=#{ptime(t2)}          err=#{err}\n"
        errors.push(err)
      }
    }
  }
  median,mean_abs = stats(errors)
  print "median error=#{median}       mean abs err=#{mean_abs}\n"
end

def stats(x)
  return [median_value(x),mean_abs_value(x)]
end

def mean_abs_value(x)
  return (x.map {|u| u.abs}.sum)/x.length
end

def median_value(x) # https://stackoverflow.com/a/14859546
  return nil if x.empty?
  sorted = x.sort
  len = sorted.length
  (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0
end

def array_intersection(a1,a2)
  return a1 & a2 # https://stackoverflow.com/a/5678143
end

def cross_ratio(c1,c2,times,course_horiz,course_cf)
  t1 = times[c1]
  t2 = times[c2]
  d1 = course_horiz[c1]
  d2 = course_horiz[c2]
  cf1 = course_cf[c1]
  cf2 = course_cf[c2]
  e1 = energy(d1,cf1)
  e2 = energy(d2,cf2)
  err = 100.0*Math.log((t2/t1)*(e1/e2))
  return [t1,t2,d1,d2,err]
end

def energy(distance,climb_factor)
  # distance = horizontal distance in miles
  # climb_factor = fraction of effort due to climbing, expressed as a percentage
  # returns an energy in units of half-marathons
  d = distance/(13.109) # distance in units of half-marathons
  return d/(1-climb_factor/100.0)
end

def pname(name)
  return "%-20s" % [name]
end

def pcourse(course)
  return "%-13s" % [course]
end

def ptime(hrs)
  # convert a time in hours to a human-readable string
  h = hrs.to_i
  m = ((hrs-h)*60.0).round
  return "%2d:%02d" % [h,m]
end

def die(s)
  print s,"\n"
  exit(-1)
end

main()
