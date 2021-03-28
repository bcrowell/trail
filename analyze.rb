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
  d.keys.sort.each { |who|
    times = d[who]
    flat   = array_intersection(["pasadena","chesebro","into_the_wild"],times.keys)
    uphill = array_intersection(["baldy","broken_arrow"],times.keys)
    if flat.empty? or uphill.empty? then next end
    flat.each { |f|
      uphill.each { |u|
        tf = times[f]
        tu = times[u]
        df = course_horiz[f]
        du = course_horiz[u]
        cf_f = course_cf[f]
        cf_u = course_cf[u]
        ef = energy(df,cf_f)
        eu = energy(du,cf_u)
        err = 100.0*Math.log((tu/tf)*(ef/eu))
        print "#{who} #{f}=#{tf} #{u}=#{tu} err=#{err}\n"
      }
    }
  }
end

def energy(distance,climb_factor)
  # distance = horizontal distance in miles
  # climb_factor = fraction of effort due to climbing, expressed as a percentage
  # returns an energy in units of half-marathons
  d = distance/(13.109) # distance in units of half-marathons
  return d/(1-climb_factor/100.0)
end

def die(s)
  print s,"\n"
  exit(-1)
end

def array_intersection(a1,a2)
  return a1 & a2 # https://stackoverflow.com/a/5678143
end

main()
