def normal_cum(x)
  return 0.5*(1+Math::erf((x)/(Math::sqrt(2.0))))
end

def student_t_cum(t,order)
  # https://en.wikipedia.org/wiki/Student%27s_t-distribution#Special_cases
  if order==2 then
   # Tested that this gives a good QQ plot with artificially generated values.
   return 0.5+(1/(2.0*Math::sqrt(2.0)))*t/Math::sqrt(1+t**2/2.0)
  end
  if order==3 then
    is3 = 1/Math::sqrt(3.0)
    return 0.5+(1/Math::PI)*((is3*t/(1+t**2/3))+Math::atan(is3*t))
  end
  if order==4 then
    return 0.5+(3.0/8.0)*(t/Math::sqrt(1+t**2/4.0))*(1-(1/12.0)*(t**2/(1+t**2/4)))
  end
  die("undefined order")
end
