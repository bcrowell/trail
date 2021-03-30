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

  data = [d,course_horiz,course_cf,course_gain]

  m = {"endurance"=>[0.4,13.1]}
  hockey = {'hockey'=>6.0}

  flat = ["pasadena","chesebro","into_the_wild"]
  uphill = ["baldy","broken_arrow"]
  downhill = ["big_bear","canyon_city"]
  not_very_flat = ["wilson","into_the_wild","big_bear","baldy","broken_arrow","griffith_park_30k","chesebro"]

  #do_stats("very flat / hilly",["pasadena"],not_very_flat,data,m)
  #do_stats("very flat / hilly, hockey",["pasadena"],not_very_flat,data,m.merge(hockey))

  # Sample size is only 4, not enough to tell much:
  # do_stats("flat / wilson",        flat,["wilson"],data,m)
  # do_stats("flat / wilson, hockey",flat,["wilson"],data,m.merge(hockey))

  # ----- Good comparison of flattish with downhill, seems to show minetti is better than hockey. Results very similar if
  #       I only use Pasadena.
  if true then
    do_stats("flattish / downhill",        flat,["big_bear"],data,m)
    do_stats("flattish / downhill, hockey",flat,["big_bear"],data,m.merge(hockey))
  end

  # --- another downhill race, but less extreme, actually has quite a bit of gain as well
  if false then
    do_stats("flattish / downhill",        flat,["canyon_city"],data,m)
    do_stats("flattish / downhill, hockey",flat,["canyon_city"],data,m.merge(hockey))
  end

  # ----- Seems to show hockey about the same as minetti or even slightly better.
  if false then
    do_stats("flat / uphill",        flat,uphill,data,m)
    do_stats("flat / uphill, hockey",flat,uphill,data,m.merge(hockey))
  end

  #do_stats("flat / downhill",flat,["big_bear"],data,m)
  #do_stats("up-down / uphill",["wilson"],["baldy","broken_arrow"],data,m)

  # ----- test endurance correction; small sample size, but does seem to improve results
  if false then
    do_stats("short / 30k",                      ["pasadena","wilson"],["griffith_park_30k"],data,{})
    do_stats("short / 30k, endurance correction",["pasadena","wilson"],["griffith_park_30k"],data,m)
  end
end

def do_stats(title,courses1,courses2,data,model)
  d,course_horiz,course_cf,course_gain = data
  print "#{title}, err>0 means 1st is slow in reality\n"
  errors = []
  d.keys.sort.each { |who|
    times = d[who]
    flat   = array_intersection(courses1,times.keys)
    uphill = array_intersection(courses2,times.keys)
    if flat.empty? or uphill.empty? then next end
    flat.each { |c1|
      uphill.each { |c2|
        t1,t2,d1,d2,err,e2e1,endurance_corr = cross_ratio(c1,c2,times,course_horiz,course_cf,course_gain,model)
        print "  #{pname(who)}       #{pcourse(c1)}=#{ptime(t1)}        #{pcourse(c2)}=#{ptime(t2)}          err=#{pf(err,5,1)}",
                   "             e2/e1=#{pf(e2e1,4,2)}   endurance=#{pf(endurance_corr,4,2)}\n"
        errors.push(err)
      }
    }
  }
  median,mean_abs = stats(errors)
  print "  median error=#{median}       mean abs err=#{mean_abs}\n"
end

def cross_ratio(c1,c2,times,course_horiz,course_cf,course_gain,model)
  t1 = times[c1]
  t2 = times[c2]
  d1 = course_horiz[c1] # miles
  d2 = course_horiz[c2]
  cf1 = course_cf[c1]
  cf2 = course_cf[c2]
  g1 = course_gain[c1]
  g2 = course_gain[c2]
  e1 = energy(d1,cf1,g1,model)
  e2 = energy(d2,cf2,g2,model)
  corr = 1.0
  if model.has_key?("endurance") then
    beta = model['endurance'][0]
    dc = model['endurance'][1]
    corr = endurance_corr(e2,beta,dc,{})/endurance_corr(e1,beta,dc,model) # ratio of time corrections
    #print "corr=#{corr}\n"
  end
  err = 100.0*Math.log((t1/t2)*(e2/e1)*corr)
  return [t1,t2,d1,d2,err,e2/e1,corr]
end

def energy(distance,climb_factor,gain,model)
  # distance = horizontal distance in miles
  # climb_factor = fraction of effort due to climbing, expressed as a percentage
  # returns an energy in units of equivalent miles
  if model.has_key?("hockey") then
    gain_miles = gain/5280.0 # gain in units of miles
    rel_gain = gain_miles/distance
    cg = model["hockey"]
    f = 1+cg*rel_gain
  else
    f = 1/(1-climb_factor/100.0)
  end
  # print "  energy corr=#{f},  distance=#{distance}     gain=#{gain} #{model}\n" # qwe
  return distance*f
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

def pf(x,m,n)
  return "%#{m}.#{n}f" % [x]
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
