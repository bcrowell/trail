def get_route_data(csv_file)
  course_horiz = {} # horizontal miles
  course_cf = {} # climb factor, %
  course_gain = {} # gain in feet
  x = CSV.read(csv_file)
  header = true
  x.each { |row|
    if header then header=false; next end
    if row.length==0 then next end
    name,horiz_v,cf_v,gain_v = row
    course_horiz[name] = horiz_v.to_f
    course_cf[name] = cf_v.to_f
    course_gain[name] = gain_v.to_f
    #print "#{name}: #{horiz_v} mi horizontally, CF=#{cf_v}\n"
  }
  return [course_horiz,course_cf,course_gain]
end

def mnemonic(label)
  return {
    "wilson"                =>'W',
    "baldy"                 =>'B',
    "broken_arrow"          =>'V',
    "pasadena"              =>'P',
    "chesebro"              =>'C',
    "into_the_wild"         =>'H',
    "griffith_park_30k"     =>'G',
    "big_bear"              =>'X',
    "canyon_city"           =>'Y',
    "irvine_half"           =>'I'
  }[label]
end
