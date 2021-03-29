#!/bin/ruby

require 'json'
require 'csv'

require_relative "lib/routes"
require_relative "lib/endurance"

def main()
  d = {}
  File.open('matches.json','r') { |f|
    d = JSON.parse(f.gets(nil))
  }

  # {"albert allen":{"wilson":1.4861111111111112,"baldy":1.8894444444444445},"amelie joffrin":{"wilson":1.4519444444444445,"baldy":1.9194444444444443},

  course_horiz,course_cf,course_gain = get_route_data("data/routes.csv")

  data = [d,course_horiz,course_cf]

  #do_stats("flat / uphill",["pasadena","chesebro","into_the_wild"],["baldy","broken_arrow"],data,{})
  #do_stats("up-down / uphill",["wilson"],["baldy","broken_arrow"],data,{})
  #do_stats("short / 30k",["pasadena","wilson"],["griffith_park_30k"],data,{})
  do_stats("short / 30k, endurance correction",["pasadena","wilson"],["griffith_park_30k"],data,{"endurance"=>[0.5,13.1]})
  do_stats("short / 30k, endurance correction",["pasadena","wilson"],["griffith_park_30k"],data,{"endurance"=>[0.5,10.1]})
end

def do_stats(title,courses1,courses2,data,model)
  d,course_horiz,course_cf = data
  print "#{title}, err>0 means 2nd is slow in reality\n"
  errors = []
  d.keys.sort.each { |who|
    times = d[who]
    flat   = array_intersection(courses1,times.keys)
    uphill = array_intersection(courses2,times.keys)
    if flat.empty? or uphill.empty? then next end
    flat.each { |c1|
      uphill.each { |c2|
        t1,t2,d1,d2,err = cross_ratio(c1,c2,times,course_horiz,course_cf,model)
        print "  #{pname(who)}       #{pcourse(c1)}=#{ptime(t1)}        #{pcourse(c2)}=#{ptime(t2)}          err=#{err}\n"
        errors.push(err)
      }
    }
  }
  median,mean_abs = stats(errors)
  print "  median error=#{median}       mean abs err=#{mean_abs}\n"
end

def cross_ratio(c1,c2,times,course_horiz,course_cf,model)
  t1 = times[c1]
  t2 = times[c2]
  d1 = course_horiz[c1] # miles
  d2 = course_horiz[c2]
  cf1 = course_cf[c1]
  cf2 = course_cf[c2]
  e1 = energy(d1,cf1)
  e2 = energy(d2,cf2)
  corr = 1.0
  if model.has_key?("endurance") then
    beta = model['endurance'][0]
    dc = model['endurance'][1]
    corr = endurance_corr_2(e1,beta,dc)/endurance_corr_2(e2,beta,dc)
  end
  err = 100.0*Math.log((t2/t1)*(e1/e2)*corr)
  return [t1,t2,d1,d2,err]
end

def energy(distance,climb_factor)
  # distance = horizontal distance in miles
  # climb_factor = fraction of effort due to climbing, expressed as a percentage
  # returns an energy in units of equivalent miles
  return distance/(1-climb_factor/100.0)
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
