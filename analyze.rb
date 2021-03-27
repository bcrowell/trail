#!/bin/ruby


require 'json'
require 'csv'

def main()
  d = {}
  File.open('matches.json','r') { |f|
    d = JSON.parse(f.gets(nil))
  }

  # {"albert allen":{"wilson":1.4861111111111112,"baldy":1.8894444444444445},"amelie joffrin":{"wilson":1.4519444444444445,"baldy":1.9194444444444443},

  course_horiz = {} # horizontal miles
  course_cf = {} # climb factor
  x = CSV.read("data/routes.csv")
  x.each { |row|
    name,horiz_v,cf_v = row
    course_horiz[name] = horiz_v.to_f
    course_cf[name] = cf_v.to_f
    #print "#{name}: #{horiz_v} mi horizontally, CF=#{cf_v}\n"
  }

  # uphill compared to up-down
  d.keys.sort.each { |who|
    times = d[who]
    flat   = array_intersection(["pasadena","chesebro","into_the_wild"],times.keys)
    uphill = array_intersection(["baldy","broken_arrow"],times.keys)
    if flat.empty? or uphill.empty? then next end
    print "#{who} #{flat} #{uphill}\n"
  }
end

def die(s)
  print s,"\n"
  exit(-1)
end

def array_intersection(a1,a2)
  return a1 & a2 # https://stackoverflow.com/a/5678143
end

main()
