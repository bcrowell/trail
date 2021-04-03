#!/bin/ruby

require 'json'
require 'csv'

require_relative "lib/routes"
require_relative "lib/endurance"
require_relative "lib/line_plot"
require_relative "lib/stat"

$use_mean = false # if set to false, then use median

def main()
  d = {}
  File.open('matches.json','r') { |f|
    d = JSON.parse(f.gets(nil))
  }

  # {"albert allen":{"wilson":1.4861111111111112,"baldy":1.8894444444444445},"amelie joffrin":{"wilson":1.4519444444444445,"baldy":1.9194444444444443},

  course_horiz,course_cf,course_gain,course_cf_r = get_route_data("data/routes.csv")

  data = [d,course_horiz,course_cf,course_gain,course_cf_r]

  m = {"endurance"=>[0.4,13.1]}
  hockey = {'hockey'=>6.0}
  rec = {'rec'=>1}

  all = course_horiz.keys
  ultra_flat = ["irvine_half"]
  flat = ["pasadena","chesebro","into_the_wild","irvine_half"]
  uphill = ["baldy","broken_arrow"]
  downhill = ["big_bear","canyon_city"]
  not_very_flat = ["wilson","into_the_wild","big_bear","baldy","broken_arrow","griffith_park_30k","chesebro"]

  tex = ""
  scatt = "scatt/" # prefix for filenames of scatterplot files

  if true then
  # --- Hockey is poor for steep uphill; this is because minetti is curved, not linear. This is mainly a comparison with baldy, only one VK point.
  #     I checked the mapping of Baldy pretty carefully, see notes in meki. Gain is just slightly more than the elevation gain from manker
  #     to the summit (1.8%, or 72'), which makes sense. There is a 500 m steep downhill section at the start, which is mapped accurately.
  compare_hockey("flat / uphill",flat,uphill,data,m,hockey,tex,[scatt,"fu"],{})

  # --- Both Minetti and hockey predict wilson times that are about 20% too short. I suspect this is safety and etiquette at work.
  compare_hockey("flat / wilson",flat,["wilson"],data,m,hockey,tex,[scatt,"fw"],{})

  # ----- Good comparison of flattish with downhill. Hockey much better than Minetti. I suspect this is because of the extreme amount
  #       of eccentric work on quads, also possibly TFLs. Nice big sample.
  compare_hockey("flattish / downhill",flat,["big_bear"],data,m,hockey,tex,[scatt,"fd"],{})

  # ----- Ultra-flat versus nearly flat, seem to clearly show that hockey is wrong in this limit, although the sample is small.
  compare_hockey("ultra-flat / nearly flat",        ultra_flat,["pasadena"],data,m,hockey,tex,[scatt,"uf"],{})
  end

  if false then
  compare_rec("flat / uphill",flat,uphill,data,m,rec,tex,[scatt,"fu"],{})
  compare_rec("flat / wilson",flat,["wilson"],data,m,rec,tex,[scatt,"fw"],{})
  compare_rec("flattish / downhill",flat,["big_bear"],data,m,rec,tex,[scatt,"fd"],{})
  compare_rec("ultra-flat / nearly flat",        ultra_flat,["pasadena"],data,m,rec,tex,[scatt,"uf"],{})
  end

  # ----- test endurance correction; small sample size, but does seem to improve results
  if false then
    do_stats("short / 30k",                      ["pasadena","wilson"],["griffith_park_30k"],data,{},tex,[scatt,"en"],{})
    do_stats("short / 30k, endurance correction",["pasadena","wilson"],["griffith_park_30k"],data,m,tex,[scatt,"en"],{})
  end

  do_time_ratios("ultra-flat / nearly flat",        ultra_flat,["pasadena"],data,{})

  print tex
end

def describe_list_with_mnemonics(courses)
  return courses.map {|c| mnemonic(c)}.join(',')
end

def compare_hockey(title,courses1,courses2,data,model,hockey,tex,scatt,opt)
  print "comparing Minetti with hockey, #{title}\n"
  tex.replace(tex+title+", "+describe_list_with_mnemonics(courses1)+" / "+describe_list_with_mnemonics(courses2)+"\n")
  do_stats("  Minetti",courses1,courses2,data,model,tex,[scatt[0],scatt[1]+'_m'],{},opt)
  do_stats("  hockey ",courses1,courses2,data,model.merge(hockey),tex,[scatt[0],scatt[1]+'_h'],{'fill_black'=>true},opt)
end

def compare_rec(title,courses1,courses2,data,model,rec,tex,scatt,opt)
  print "comparing Minetti with recreational parameters, #{title}\n"
  tex.replace(tex+title+", "+describe_list_with_mnemonics(courses1)+" / "+describe_list_with_mnemonics(courses2)+"\n")
  do_stats("  Minetti",courses1,courses2,data,model,tex,[scatt[0],scatt[1]+'_m'],{},opt)
  do_stats("  rec    ",courses1,courses2,data,model.merge(rec),tex,[scatt[0],scatt[1]+'_h'],{'fill_black'=>true},opt)
end

def do_stats(title,courses1,courses2,data,model,tex,scatt,line_plot_opt,opt)
  d,course_horiz,course_cf,course_gain,course_cf_r = data
  if opt.has_key?('max_time') then special_max_time=opt['max_time'] else special_max_time=999999.9 end
  if model.has_key?('rec') then cf=course_cf_r else cf=course_cf end
  print "#{title}, err>0 means 1st is slow in reality\n"
  errors = []
  n = 0
  d.keys.sort.each { |who|
    times = d[who]
    flat   = array_intersection(courses1,times.keys)
    uphill = array_intersection(courses2,times.keys)
    if flat.empty? or uphill.empty? then next end
    flat.each { |c1|
      uphill.each { |c2|
        t1,t2,d1,d2,err,e2e1,endurance_corr = cross_ratio(c1,c2,times,course_horiz,cf,course_gain,model)
        if t1>special_max_time or t2>special_max_time or t1>max_time(c1) or t2>max_time(c2) then next end
        n = n+1
        print "    #{pname(who)}       #{pcourse(c1)}=#{ptime(t1)}        #{pcourse(c2)}=#{ptime(t2)}          err=#{pf(err,5,1)}",
                   "             e2/e1=#{pf(e2e1,4,2)}   endurance=#{pf(endurance_corr,4,2)}\n"
        errors.push(err)
      }
    }
  }
  median,mean_abs,spread,kurtosis = stats(errors)
  mean = mean_value(errors)
  if $use_mean then center=mean else center=median end
  print "      mean/median error=#{pf(center,5,1)}       mean abs err=#{pf(mean_abs,5,1)}      spread=#{pf(spread,5,1)}         n=#{n}\n"
  tex.replace(tex+"#{title}   mean/median error=#{pf(center,5,1)}       mean abs err=#{pf(mean_abs,5,1)}      spread=#{pf(spread,5,1)}         n=#{n}\n")
  File.open(scatt[0]+scatt[1]+".svg",'w') { |f|
    f.print make_line_plot(errors,line_plot_opt)
  }
end

def do_time_ratios(title,courses1,courses2,data,opt)
  d,course_horiz,course_cf,course_gain,course_cf_r = data
  if opt.has_key?('max_time') then special_max_time=opt['max_time'] else special_max_time=999999.9 end
  print "#{title}, ratio>1 means 1st is slow\n"
  ratios = []
  n = 0
  d.keys.sort.each { |who|
    times = d[who]
    flat   = array_intersection(courses1,times.keys)
    uphill = array_intersection(courses2,times.keys)
    if flat.empty? or uphill.empty? then next end
    flat.each { |c1|
      uphill.each { |c2|
        n = n+1
        t1 = times[c1]
        t2 = times[c2]
        if t1>special_max_time or t2>special_max_time or t1>max_time(c1) or t2>max_time(c2) then next end
        ratios.push(t1/t2)
      }
    }
  }
  median,mean_abs,spread,kurtosis = stats(ratios)
  print "      median ratio=#{pf(median,8,4)}            sd=#{pf(spread,8,4)}         n=#{n}\n"
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

def spread_value(a)
  return sd_value(a)
  # median absolute difference from the median
  # ... this behaves well when tails are fat and there's plenty of data, but produces weird results with small n
  # return median_abs_dev_value(x)
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
