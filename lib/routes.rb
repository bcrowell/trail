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
