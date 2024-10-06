cd(@__DIR__)
using Pkg
Pkg.activate(".")
using Luxor
using QuantumEpisodicMemory: 𝕦

Drawing(6000, 400)
origin()

background(0, 0, 0, 0)
setopacity(0.85)
r = 175
arrowheadlength = 30
linewidth = 3

origin_point = Point(-1500, 15)

b1 = [1,0]
b1′ = [0,-1]

b2 = 𝕦(π/4) * b1
b2′ = 𝕦(π/4) * b1′

b3 = 𝕦(-.4) * b1


line1_end = Point(b1 * r...) + origin_point
line2_end = Point(b1′ * r...) + origin_point

line3_end = Point(b2 * r...) + origin_point
line4_end = Point(b2′ * r...) + origin_point

line5_end = Point(b3 * r...) + origin_point


# sethue((0.251, 0.388, 0.847))
sethue("black")
setline(5)
circle(Point(-1500, 10), r, action = :stroke)

#sethue((0.584, 0.345, 0.698))

# line 1
sethue((0.251, 0.388, 0.847))
arrow(origin_point, line1_end; linewidth, arrowheadlength)
# line 2
sethue((0.251, 0.388, 0.847))
arrow(origin_point, line2_end; linewidth, arrowheadlength)
strokepath()


# line 3
sethue((0.584, 0.345, 0.698))
arrow(origin_point, line3_end; linewidth, arrowheadlength)
# line 4
sethue((0.584, 0.345, 0.698))
arrow(origin_point, line4_end; linewidth, arrowheadlength)
strokepath()

# line 5
sethue((0.796, 0.235, 0.200))
arrow(origin_point, line5_end; linewidth, arrowheadlength)
strokepath()


# text
sethue("black")
fontsize(220)
text("Quantum Episodic Memory", Point(-1500+300, 70))

finish()
preview()
#end
