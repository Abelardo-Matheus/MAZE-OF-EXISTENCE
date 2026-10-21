from eng import *
import math

def _sword(a, blade, guard, grip, pommel, w=3.8, fuller=True, tip=(44, 4), base=(18, 32), shape='round'):
    m = a.beam(base, (tip[0] - 2.2, tip[1] + 2.2), w, w * .92) | a.poly([(tip[0] - 2.2 - w, tip[1] + 2.2 - w * .2), tip, (tip[0] - 2.2 + w * .2, tip[1] + 2.2 + w)])
    a.part(m, blade, bulge=.7, shape=shape, spec=True)
    if fuller:
        a.part(a.line([(base[0] + 2, base[1] - 2), (tip[0] - 5, tip[1] + 5)], 1), blade, shape='flat', lo=1, hi=2, ao=False)
    g = a.capsule((base[0] - 7, base[1] - 7), (base[0] + 6, base[1] + 6), 2.5)
    a.part(g, guard, bulge=1, spec=True)
    a.part(a.circle(base[0] - .5, base[1] - .5, 2.2), guard, bulge=1.2, lo=2)
    gr = a.capsule((base[0] - 2, base[1] + 2), (base[0] - 8, base[1] + 8), 1.8)
    a.part(gr, grip, bulge=.8)
    for i in range(3):
        x = base[0] - 3.5 - i * 1.8; y = base[1] + 3.5 + i * 1.8
        a.flat(a.line([(x - 1, y - 1), (x + 1, y + 1)], 1) & gr, ramp(grip)[0])
    a.part(a.circle(base[0] - 9.6, base[1] + 9.6, 2.5), pommel, bulge=1.2, spec=True)
    return m

def graveto():
    a = Art()
    m = a.capsule((9, 43), (38, 9), 1.9) | a.capsule((24, 25), (33, 24), 1.3) | a.capsule((17, 34), (13, 26), 1.1)
    a.part(m, '#8a5a32', bulge=.9)
    for t in (.2, .45, .7):
        x = 9 + 29 * t; y = 43 - 34 * t
        a.px(int(x), int(y), (70, 42, 22)); a.px(int(x) + 1, int(y), (170, 120, 70))
    leaf = a.poly([(33, 24), (38, 20), (42, 22), (38, 26)])
    a.part(leaf, '#5fbf3a', bulge=.6)
    a.part(a.poly([(13, 26), (9, 22), (12, 20), (15, 24)]), '#5fbf3a', bulge=.6)
    return a

def vassoura():
    a = Art()
    a.part(a.capsule((20, 31), (41, 5), 1.5), '#c0392b', bulge=.8)
    a.part(a.circle(41, 5, 2), '#2d2d3a')
    a.part(a.capsule((17, 33), (22, 28), 2.4), '#d4d4dc', bulge=.9, spec=True)
    head = a.poly([(15, 32), (21, 37), (14, 47), (4, 46), (3, 42)])
    a.part(head, '#e8b04a', bulge=.6)
    for k in range(7):
        a.flat(a.line([(17 - k * 1.2, 34 + k * .4), (5 + k * 1.6, 44 + k * .3)], 1) & head, (180, 120, 40))
    a.part(a.capsule((13, 34), (20, 40), 1), '#c0392b', bulge=.5, ao=False)
    return a

def espada_plastico():
    a = Art()
    _sword(a, '#5b8cff', '#ffcf2e', '#e74c3c', '#ffcf2e')
    a.pxs([(34, 13), (35, 12)], '#e8f0ff')
    return a

def espada_madeira():
    a = Art()
    m = _sword(a, '#b5793c', '#e0b13b', '#7b4326', '#e0b13b', fuller=False)
    for k in range(4):
        a.flat(a.line([(22 + k * 4.6, 27.5 - k * 5), (24 + k * 4.6, 26.8 - k * 5)], 1) & m, (140, 90, 48))
    a.px(30, 18, (90, 55, 30))
    return a

def espada_dourada():
    a = Art()
    _sword(a, '#ffc928', '#e74c3c', '#5a2d82', '#e74c3c')
    a.part(a.circle(18.5, 30.5, 1.4), '#4fc3f7', bulge=1.3, spec=True, ao=False)
    a.sparkle(42, 16); a.sparkle(30, 6, size=1)
    return a

def mata_fantasma():
    a = Art()
    _sword(a, '#9ff3e8', '#7e57c2', '#311b92', '#b388ff')
    for x, y in ((43, 18), (31, 5), (45, 10), (36, 22)):
        a.part(a.circle(x, y, .9), '#c8fff8', ao=False)
    a.part(a.circle(18.5, 30.5, 1.4), '#e0f7ff', bulge=1.3, spec=True, ao=False)
    return a

def regua():
    a = Art()
    m = a.beam((8, 41), (38, 9), 4.2)
    a.part(m, '#ffcb2e', shape='flat')
    a.inner_edge(m, (205, 140, 20), 'br')
    for i in range(1, 12):
        t = i / 12
        x = 8 + 30 * t; y = 41 - 32 * t
        L = 2.6 if i % 2 == 0 else 1.6
        a.flat(a.line([(x - 2.9, y - 2.7), (x - 2.9 + L * .7, y - 2.7 + L * .7)], 1), (95, 60, 20))
    a.part(a.circle(34, 13, 1.2), '#7a5414', ao=False)
    return a

def guarda_chuva():
    a = Art()
    a.part(a.capsule((24, 16), (24, 41), 1.3), '#6d4c41', bulge=.8)
    a.part(a.line([(24, 41), (24, 45), (21.5, 47.5), (18, 46), (18, 44)], 2.3), '#6d4c41', bulge=.6)
    dome = a.pie(24, 22, 18, 180, 360)
    for x in (10, 18, 30, 38):
        dome &= ~a.circle(x, 25.5, 4.6)
    dome &= ~a.circle(24, 25.5, 4.2)
    a.part(dome, '#ef4f4f', bulge=.7)
    for i, x0 in enumerate((14, 34)):
        seg = a.poly([(24, 4), (x0 - 5, 22), (x0 + 5, 22)]) & dome
        a.part(seg, '#ffe14d', bulge=.5, ao=False, keep=dome)
    for x in (14, 24, 34):
        a.flat(a.line([(24, 4), (x, 21)], 1) & dome, (150, 40, 40))
    a.part(a.capsule((24, 1.5), (24, 4.5), 1.2), '#6d4c41', bulge=.6)
    return a

def martelo():
    a = Art()
    a.part(a.capsule((12, 45), (29, 20), 2.1), '#ffcf2e', bulge=.8)
    for k in range(3):
        a.flat(a.line([(14 + k * 4.6, 39 - k * 6.6), (17 + k * 4.6, 40 - k * 6.6)], 1), (220, 150, 20))
    cx, cy = 31, 16.5
    u = (0.83, 0.56); v = (0.56, -0.83)
    P = lambda s, t: (cx + u[0] * s + v[0] * t, cy + u[1] * s + v[1] * t)
    head = a.poly([P(-12, -6.5), P(12, -6.5), P(12, 6.5), P(-12, 6.5)])
    a.part(head, '#ff4f5e', bulge=.9, spec=True)
    for s0 in (-12, 7):
        cap = a.poly([P(s0, -7.2), P(s0 + 5, -7.2), P(s0 + 5, 7.2), P(s0, 7.2)])
        a.part(cap, '#3f8cff', bulge=.9, spec=True)
    a.part(a.circle(cx, cy, 2), '#ffcf2e', bulge=1, ao=False)
    return a

def varinha():
    a = Art()
    a.part(a.capsule((11, 45), (29, 20), 1.7), '#5e35b1', bulge=.8)
    a.part(a.capsule((11, 45), (15, 39.5), 1.9), '#f5f5f5', bulge=.8)
    a.part(a.capsule((26, 24), (29, 20), 2), '#f5f5f5', bulge=.8)
    st = a.poly(star_pts(33, 15, 11, 4.8, rot=-80))
    a.part(st, '#ffd23f', bulge=.9, spec=True)
    a.part(a.poly(star_pts(33, 15, 5, 2.2, rot=-80)), '#fff3a0', bulge=.5, ao=False)
    for x, y, s in ((44, 30, 2), (19, 8, 1), (45, 6, 1), (39, 26, 1)):
        a.sparkle(x, y, '#fff7b0', s)
    return a

def espada_lapis():
    a = Art()
    body = a.beam((11, 38), (36, 13), 4.6)
    a.part(body, '#ffb21e', bulge=.7)
    for off in (-1.6, 1.6):
        a.flat(a.line([(11 + off, 38 + off), (36 + off, 13 + off)], 1) & body, (225, 140, 15))
    tipw = a.poly([(32.5, 9.5), (39.5, 16.5), (44, 4)])
    a.part(tipw, '#f1c48b', shape='flat')
    a.part(a.poly([(41.6, 7.5), (44, 4), (42.8, 9.1)]), '#2d2d3a', shape='flat')
    a.part(a.beam((9.5, 39.5), (12.5, 36.5), 4.9), '#c0c8d4', bulge=.8, spec=True)
    for k in (0, 1.5):
        a.flat(a.line([(7.8 + k, 37.8 + k), (11.2 + k, 41.2 + k)], 1) & a.beam((9.5, 39.5), (12.5, 36.5), 4.9), (130, 140, 155))
    a.part(a.capsule((5.5, 43.5), (8.5, 40.5), 4.4), '#ff8fa3', bulge=.9)
    return a

def bolhas():
    a = Art()
    a.part(a.rrect(9, 26, 31, 35, 3), '#29b6f6', bulge=.8, spec=True)
    a.part(a.poly([(13, 34), (21, 34), (18, 47), (10, 47)]), '#ff7043', bulge=.8)
    a.part(a.rect(30, 28, 35, 33), '#ffee58', bulge=.8)
    a.part(a.rrect(16, 22, 24, 26, 1), '#ffee58', bulge=.6)
    a.part(a.circle(21, 38, 2.4) & ~a.circle(21, 38, 1.1), '#ff7043', bulge=.5)
    for x, y, r in ((41, 22, 5.2), (33, 14, 3.6), (42, 9, 2.6), (37, 30, 1.8)):
        ring = a.circle(x, y, r) & ~a.circle(x, y, r - 1.1)
        a.part(ring, '#9be3ff', shape='flat', lo=3, ao=False)
        a.part(a.circle(x, y, r - 1.1), '#d8f5ff', shape='flat', lo=4, hi=5, ao=False, keep=a.circle(x - r * .35, y - r * .35, r * .35))
    return a

def espada_pirulito():
    a = Art()
    m = _sword(a, '#ffffff', '#7cf29c', '#ff8fa3', '#7cf29c', fuller=False)
    for k in range(0, 34, 5):
        band = a.beam((16 + k * .66, 34 - k * .74), (19 + k * .66, 37 - k * .74), 1.3) & m
        a.part(a.line([(14 + k * .62, 30 - k * .7), (24 + k * .62, 38 - k * .7)], 2.2) & m, '#ff4d6d', bulge=.4, ao=False)
    a.pxs([(35, 11), (36, 10)], '#ffffff')
    return a

# frame 5 e 6 não são usados pela database; ficam como cópias
ARMAS = [graveto, vassoura, espada_plastico, espada_madeira, espada_dourada, mata_fantasma, espada_dourada,
         mata_fantasma, regua, guarda_chuva, martelo, varinha, espada_lapis, bolhas, espada_pirulito]
