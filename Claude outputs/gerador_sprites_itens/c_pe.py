from eng import *

def _sneaker(a, col, sole='#f4f4f4', lace='#ffffff', toe=None, y=0):
    up = a.poly([(7, 28 + y), (18, 21 + y), (24, 22 + y), (29, 28 + y), (38, 31 + y), (43, 36 + y), (43, 39 + y), (7, 39 + y)])
    a.part(up, col, bulge=.9)
    a.part(a.poly([(17, 21 + y), (22, 19 + y), (26, 22 + y), (21, 25 + y)]), col, bulge=.6, lo=1)
    if toe:
        a.part(a.poly([(33, 30 + y), (39, 32 + y), (43, 36 + y), (43, 39 + y), (33, 39 + y)]), toe, bulge=.8)
    a.part(a.rrect(6, 38 + y, 44, 43 + y, 2), sole, bulge=.6)
    a.part(a.line([(7, 41 + y), (43, 41 + y)], 1), sole, shape='flat', lo=1, hi=1, ao=False)
    for k in range(3):
        x = 22 + k * 3.5
        a.part(a.line([(x, 25 + y + k * 1.2), (x + 3, 27 + y + k * 1.2)], 1), lace, shape='flat', lo=4, hi=4, ao=False)
        a.part(a.line([(x, 27 + y + k * 1.2), (x + 3, 25 + y + k * 1.2)], 1), lace, shape='flat', lo=3, hi=3, ao=False)
    return up

def sapato_velho():
    a = Art()
    shaft = a.rrect(10, 9, 26, 34, 2)
    a.part(shaft, '#9a5a2c', bulge=.8)
    foot = a.poly([(10, 30), (26, 30), (36, 33), (41, 37), (41, 42), (10, 42)])
    a.part(foot, '#9a5a2c', bulge=.9)
    a.tex_noise(shaft | foot, .1, seed=13)
    a.part(a.rect(9, 41, 42, 45), '#4a2c1a', shape='flat')
    a.part(a.rect(10, 9, 26, 13), '#c8874b', shape='flat', edge=(110, 64, 32))
    for yy in range(16, 31, 4):
        a.flat(a.line([(19, yy), (25, yy + 2)], 1), (240, 220, 180))
        a.flat(a.line([(19, yy + 2), (25, yy)], 1), (220, 200, 160))
    a.part(a.ellipse(36, 37, 4, 3), '#b8743a', spec=True)
    a.part(a.rect(12, 36, 15, 38), '#6b3d1e', shape='flat', ao=False)   # remendo
    a.pxs([(12, 36), (15, 38), (12, 38), (15, 36)], '#e0c090')
    return a

def tenis_rasgado():
    a = Art()
    up = _sneaker(a, '#8f2c35', sole='#e8e4dc', lace='#f0f0f0')
    a.erase(a.ellipse(14, 33, 2.5, 1.6) & up)
    a.part(a.ellipse(14, 33, 2.5, 1.6), '#f2c9a0', bulge=.6, ao=False)
    a.flat(a.line([(30, 33), (33, 35), (31, 36)], 1), (60, 20, 25))
    a.px(9, 44, (230, 220, 210)); a.px(40, 44, (230, 220, 210))
    return a

def patins():
    a = Art()
    up = a.poly([(10, 9), (26, 9), (27, 26), (37, 28), (42, 32), (42, 37), (10, 37)])
    a.part(up, '#ff5a5a', bulge=.9)
    a.part(a.rect(10, 9, 26, 13), '#ffe14d', bulge=.6, edge=(180, 140, 20))
    for yy in range(16, 28, 4):
        a.flat(a.line([(18, yy), (25, yy + 2)], 1), (255, 255, 255))
    a.part(a.rect(9, 36, 43, 39), '#4fc3f7', bulge=.6)
    for x in (13, 21, 29, 37):
        a.part(a.circle(x, 43, 3.6), '#ffcf2e', bulge=1.2, spec=True)
        a.part(a.circle(x, 43, 1.2), '#7a5a14', ao=False)
    return a

def skate():
    a = Art()
    deck = a.rrect(4, 26, 44, 31, 2.5)
    a.part(deck, '#3f9e5a', bulge=.8)
    a.part(a.rect(6, 26, 42, 27), '#2d2d3a', shape='flat', ao=False)
    for x in (14, 22, 30):
        a.part(a.poly(star_pts(x, 29, 2, 1)), '#ffe14d', shape='flat', ao=False)
    for x in (12, 36):
        a.part(a.rect(x - 3, 31, x + 3, 34), '#b0bec5', bulge=.6)
        for dx in (-3, 3):
            a.part(a.circle(x + dx, 37, 3), '#e84a5f', bulge=1.2, spec=True)
            a.part(a.circle(x + dx, 37, 1), '#ffe0e4', ao=False)
    return a

def tenis_corrida():
    a = Art()
    up = _sneaker(a, '#e83b3b', sole='#ffffff', toe='#ffffff')
    swoosh = a.poly([(12, 34), (26, 31), (36, 27), (27, 34), (14, 36)])
    a.part(swoosh, '#ffd23f', bulge=.5, ao=False)
    a.part(a.line([(7, 40), (43, 40)], 1), '#3f8cff', shape='flat', ao=False)
    return a

def sapato_social():
    a = Art()
    m = a.poly([(7, 32), (14, 26), (26, 26), (36, 29), (43, 34), (43, 38), (7, 38)])
    a.part(m, '#3d3550', bulge=1.1, spec=True)
    a.part(a.poly([(14, 27), (24, 27), (21, 31), (16, 31)]), '#4a3f5a', bulge=.6, ao=False)
    a.part(a.line([(16, 28), (22, 28)], 1), '#c9c0d6', shape='flat', ao=False)
    a.part(a.rect(6, 37, 44, 41), '#5a3a22', bulge=.5)
    a.part(a.rect(7, 38, 15, 44), '#3a2414', bulge=.5)
    for x in range(26, 42, 3):
        a.px(x, 32 + (x - 26) * .2, (90, 80, 110))
    return a

def _sock(a, col, cuff='#ffffff'):
    m = a.poly([(15, 12), (29, 12), (29, 33), (38, 36), (40, 41), (37, 46), (26, 46), (16, 40)])
    a.part(m, col, bulge=1)
    a.part(a.rrect(14, 9, 30, 15, 2), cuff, bulge=.8)
    for x in range(16, 30, 2):
        a.px(x, 14, ramp(cuff)[2] if cuff != '#ffffff' else (190, 194, 228))
    a.part(a.ellipse(36, 42, 4.5, 4), cuff, bulge=1, keep=m)
    a.part(a.ellipse(18, 40, 3, 4) & m, cuff, bulge=1)
    return m

def meias_novas():
    a = Art()
    m = _sock(a, '#e53935')
    for yy in (20, 26):
        a.part(a.rect(15, yy, 29, yy + 2) & m, '#ffffff', bulge=.5, ao=False)
    return a

def meias_sorte():
    a = Art()
    m = _sock(a, '#ffc21a')
    a.part(a.poly(star_pts(22, 25, 4.5, 2)), '#3f8cff', bulge=.6, ao=False)
    a.part(a.circle(30, 37, 1.5), '#3f8cff', ao=False)
    a.part(a.circle(18, 32, 1.2), '#3f8cff', ao=False)
    return a

def pantufa():
    a = Art()
    a.part(a.ellipse(23, 36, 17, 9), '#f8bbd0', bulge=1)
    a.part(a.ellipse(14, 20, 3.6, 10), '#f8bbd0', bulge=1)
    a.part(a.ellipse(22, 19, 3.6, 10), '#f8bbd0', bulge=1)
    a.part(a.ellipse(14, 21, 1.4, 7), '#ff7aa8', bulge=.6, ao=False)
    a.part(a.ellipse(22, 20, 1.4, 7), '#ff7aa8', bulge=.6, ao=False)
    a.part(a.circle(18, 32, 7), '#ffffff', bulge=1)
    a.pxs([(15, 31), (21, 31), (15, 30), (21, 30)], (40, 30, 50))
    a.part(a.ellipse(18, 34, 1.4, 1), '#ff4f8b', ao=False)
    a.pxs([(12, 35), (24, 35)], (255, 170, 200))
    a.part(a.rrect(6, 42, 40, 45, 1), '#b0285e', bulge=.5)
    a.part(a.circle(39, 34, 2.6), '#ffffff', bulge=1)
    return a

def galocha():
    a = Art()
    m = a.poly([(15, 9), (31, 9), (31, 33), (40, 35), (42, 39), (42, 44), (13, 44), (13, 11)])
    a.part(m, '#ffd326', bulge=1, spec=True)
    a.part(a.rrect(13, 8, 32, 13, 2), '#ffae00', bulge=.7)
    a.part(a.rect(12, 41, 43, 45), '#5d3a26', bulge=.5)
    for x in range(14, 43, 3):
        a.px(x, 44, (40, 24, 16))
    a.part(a.circle(21, 25, 3.4), '#ff6a3d', bulge=1, spec=True, ao=False)
    a.part(a.circle(27, 32, 2), '#ff6a3d', bulge=1, ao=False)
    return a

def tenis_luz():
    a = Art()
    _sneaker(a, '#7e57c2', sole='#ffffff')
    for i, c in enumerate(('#ff5252', '#ffee58', '#69f0ae', '#40c4ff')):
        a.part(a.rect(10 + i * 8, 39, 14 + i * 8, 41), c, bulge=.8, spec=True, ao=False)
    a.part(a.poly(star_pts(15, 32, 3, 1.4)), '#ffee58', shape='flat', ao=False)
    for x, yy in ((9, 47), (25, 48), (40, 47)):
        a.sparkle(x, yy, '#fff59d', 1)
    return a

def mola():
    a = Art()
    m = a.poly([(10, 15), (24, 11), (28, 17), (40, 21), (42, 28), (10, 28)])
    a.part(m, '#ef4b4b', bulge=1, spec=True)
    a.part(a.rect(9, 27, 43, 30), '#3a3a48', bulge=.5)
    for i in range(5):
        yy = 32 + i * 2.6
        a.part(a.ellipse(25, yy, 9.5, 1.4), '#d5dde6', bulge=1, spec=True)
    a.part(a.rrect(13, 44, 37, 47, 1), '#3a3a48', bulge=.5)
    for k in range(3):
        a.px(20 + k * 3, 19 - k * .5, (255, 220, 220))
    return a

PE = [sapato_velho, tenis_rasgado, patins, skate, tenis_corrida, sapato_social, meias_novas, meias_sorte, pantufa, galocha, tenis_luz, mola]
