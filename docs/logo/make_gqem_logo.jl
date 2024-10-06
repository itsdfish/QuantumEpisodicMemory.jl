cd(@__DIR__)
using Pkg
Pkg.activate(".")
using Luxor

Drawing()
origin()

background(0, 0, 0, 0)
setopacity(0.85)
setopacity(0.85)
r = 20
stem_1u = Point(100, -80)
stem_1d = Point(100, 80)

stem_2u = Point(80, -60)
stem_2d = Point(80, 60)

origin_point = Point(-100, 0)
line1_end = stem_1u + origin_point
line2_end = stem_1d + origin_point

sethue((0.251, 0.388, 0.847))
circle(line1_end + Point(r - 0, -r + 10), r, action = :fill)
sethue("black")
circle(line1_end + Point(r - 1, -r + 10), r, action = :stroke)

sethue((0.584, 0.345, 0.698))
circle(line2_end + Point(r - 1, r - 10), r, action = :fill)
sethue("black")
circle(line2_end + Point(r - 1, r - 10), r, action = :stroke)

# line 1
line(origin_point, line1_end)
# line 2
line(origin_point, line2_end)
strokepath()

# line 3
line3_start = line1_end + Point(40, -15)
line3_end = line3_start + stem_2u
line(line3_start, line3_end)
strokepath()

sethue((0.796, 0.235, 0.200))
circle(line3_end + Point(r - 1, r - 20), r, action = :fill)
sethue("black")
circle(line3_end + Point(r - 1, r - 20), r, action = :stroke)

# line 4
line4_start = line1_end + Point(40, -15)
line4_end = line4_start + stem_2d
line(line4_start, line4_end)
strokepath()

sethue((0.220, 0.596, 0.200))
circle(line4_end + Point(r - 1, r - 20), r, action = :fill)
sethue("black")
circle(line4_end + Point(r - 1, r - 20), r, action = :stroke)

# line 5
line5_start = line2_end + Point(40, 15)
line5_end = line5_start + stem_2u
line(line5_start, line5_end)
strokepath()

sethue((0.796, 0.235, 0.200))
circle(line5_end + Point(r - 1, r - 20), r, action = :fill)
sethue("black")
circle(line5_end + Point(r - 1, r - 20), r, action = :stroke)

# line 6
line6_start = line2_end + Point(40, 15)
line6_end = line6_start + stem_2d
line(line6_start, line6_end)
strokepath()

sethue((0.220, 0.596, 0.200))
circle(line6_end + Point(r - 1, r - 20), r, action = :fill)
sethue("black")
circle(line6_end + Point(r - 1, r - 20), r, action = :stroke)
finish()
preview()
#end
