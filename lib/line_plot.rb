def make_line_plot(data,opt)
  opt = {
    'max'=>60.0, # scale goes from -max to max
    'tick_interval'=>10.0,
    'w'=>132, # width in millimeters
    'fill_black'=>false,
    'r'=>0.73
  }.merge(opt)
  w = opt['w']
  r = opt['r']
  max = opt['max']
  tick_interval = opt['tick_interval']
  y0 = 10.0
  if opt['fill_black'] then fill = '#000000;' else fill = 'none' end
  template = <<-"SVG"
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
  <svg
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   width="210mm"
   height="297mm"
   viewBox="0 0 210 297"
   id="svg8">
   __CIRCLES__
   __TICKS__
    <path
       style="opacity:1;stroke:#000000;stroke-width:0.176"
       d="M 0,#{y0} H #{w}"/>
  </svg>
  SVG
  circle_template = <<-"CIRCLE"
    <circle
       style="opacity:1;fill:#{fill};stroke:#000000;stroke-width:0.24694444"
       cx="__X__"
       cy="#{y0}"
       r="#{r}" />
  CIRCLE
  tick_template = <<-"TICK"
    <path
       style="opacity:1;stroke:#000000;stroke-width:0.176"
       d="M __X__,__Y1__ V __Y2__"/>
  TICK
  circles = ''
  data.each { |x|
    if x<-max or x>max then next end
    circles = circles + circle_template.gsub(/__X__/) {line_plot_scaling(x,max,w)}
  }
  template.gsub!(/__CIRCLES__/,circles)
  ticks = ''
  ntick = (max/tick_interval).to_i+2
  (-ntick).upto(ntick) { |j|
    x = tick_interval*j
    if x<-max or x>max then next end
    h=0.5*r
    if j==0 then h=3*r end
    if j!=0 and j%2==0 then h=r end
    s = line_plot_scaling(x,max,w)
    t = tick_template.clone
    t.gsub!(/__X__/) {s}
    t.gsub!(/__Y1__/) {y0+h}
    t.gsub!(/__Y2__/) {y0-h}
    ticks = ticks + t
  }
  template.gsub!(/__TICKS__/,ticks)
  return template
end

def line_plot_scaling(x,max,w)
  return (x/max+1.0)*0.5*w
end
