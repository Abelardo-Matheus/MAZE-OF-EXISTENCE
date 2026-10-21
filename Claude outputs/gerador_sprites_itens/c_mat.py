from eng import *
import math

# ---------------- MATERIAIS (0..14) ----------------

def madeira():
    a = Art()
    side = a.poly([(6, 34), (30, 13), (40, 23), (16, 44)]) | a.circle(11, 39, 7.2)
    a.part(side, '#8a5530', bulge=1.1)
    for i in range(5):
        y0 = 28 + i * 3
        a.flat(a.line([(10 + i * 2.2, y0 + 6), (32 + i * 2, y0 - 14)], 1) & side, (100, 58, 32))
    a.tex_noise(side, .18, seed=3)
    end = a.ellipse(35, 18, 7, 7.5)
    a.part(end, '#d9a868', shape='flat')
    for r in (5.2, 3.2, 1.4):
        a.inner_edge(a.ellipse(35, 18, r, r * 1.05), (170, 115, 62))
    a.inner_edge(end, (110, 64, 34))
    a.part(a.poly([(17, 22), (21, 19), (22, 24)]), '#7a4a26', bulge=.6)
    a.part(a.ellipse(9, 37, 2, 1.5), '#5a3418', ao=False)
    return a

def pedra():
    a = Art()
    m = a.poly([(8, 36), (11, 23), (19, 14), (31, 13), (39, 20), (42, 33), (37, 43), (16, 44)])
    a.part(m, '#9aa0a8', bulge=1.1, spec=True)
    for pts in ([(19, 14), (22, 25), (13, 33)], [(22, 25), (34, 28), (39, 20)], [(34, 28), (30, 43)]):
        a.flat(a.line(pts, 1) & m, (95, 98, 112))
    a.tex_noise(m, .1, seed=6, density=.3)
    for x, y in ((25, 19), (15, 28), (33, 35)):
        a.px(x, y, (220, 225, 232))
    a.part(a.ellipse(27, 37, 3, 2), '#7fb069', bulge=.6, ao=False)   # musgo
    return a

def erva():
    a = Art()
    stems = [((24, 44), (15, 15)), ((24, 44), (24, 9)), ((24, 44), (33, 14)), ((24, 44), (39, 25)), ((24, 44), (9, 25))]
    for p0, p1 in stems:
        a.part(a.line([p0, p1], 1.4), '#3f7f30', shape='flat')
    for p0, p1 in stems:
        for t in (0.45, 0.62, 0.8, 0.96):
            x = p0[0] + (p1[0] - p0[0]) * t; y = p0[1] + (p1[1] - p0[1]) * t
            for side in (-1, 1):
                a.part(a.ellipse(x + side * 3.2, y - 1, 2.6, 1.5), '#5fbf3a', bulge=.8, ao=False)
    for p0, p1 in stems:
        a.part(a.circle(p1[0], p1[1], 2.4), '#e53950', bulge=1.2, spec=True)
    a.part(a.rect(20, 34, 28, 37), '#c99556', bulge=.6)
    a.part(a.line([(21, 35), (17, 40)], 1), '#c99556', shape='flat', ao=False)
    a.part(a.line([(27, 35), (31, 40)], 1), '#c99556', shape='flat', ao=False)
    return a

def frasco():
    a = Art()
    a.part(a.rect(21, 4, 27, 10), '#a8723c', bulge=.7)
    a.part(a.rect(19, 10, 29, 12), '#c9d7e0', bulge=.5)
    a.part(a.rect(20, 12, 28, 21), '#cfeaf5', shape='flat', lo=2, hi=4)
    bulb = a.circle(24, 34, 13.5)
    a.part(bulb, '#cfeaf5', bulge=1, lo=1, hi=4)
    a.part(a.circle(24, 34, 10.5) & ~a.rect(0, 0, 48, 36), '#9fd8ee', bulge=.8, lo=1, hi=3, ao=False)
    a.flat(a.line([(15, 28), (15, 38)], 1), (250, 255, 255))
    a.flat(a.line([(16.5, 25), (17.5, 23.5)], 1), (250, 255, 255))
    a.flat(a.line([(22, 14), (22, 20)], 1), (240, 252, 255))
    a.part(a.circle(29, 39, 1), '#ffffff', ao=False)
    return a

def ferro():
    a = Art()
    top = a.poly([(12, 22), (32, 14), (42, 20), (22, 28)])
    front = a.poly([(12, 22), (22, 28), (22, 36), (8, 30)])
    side = a.poly([(22, 28), (42, 20), (42, 28), (22, 36)])
    a.part(side, '#6e7685', shape='flat')
    a.part(front, '#8a93a3', shape='flat')
    a.part(top, '#b8c0cc', shape='flat', spec=True)
    a.inner_edge(top, (90, 96, 110), 'br')
    a.part(a.line([(17, 22), (33, 16)], 1), '#dfe5ee', shape='flat', ao=False, lo=5, hi=5)
    a.tex_noise(front | side, .08, seed=8)
    top2 = a.poly([(10, 36), (26, 30), (34, 34), (18, 40)])
    a.part(a.poly([(10, 36), (18, 40), (18, 45), (8, 41)]), '#8a93a3', shape='flat')
    a.part(a.poly([(18, 40), (34, 34), (34, 39), (18, 45)]), '#6e7685', shape='flat')
    a.part(top2, '#b8c0cc', shape='flat')
    return a

def couro():
    a = Art()
    roll = a.rrect(9, 20, 40, 38, 8)
    a.part(roll, '#8a4b24', bulge=.9)
    a.tex_noise(roll, .1, seed=12, density=.3)
    end = a.ellipse(12, 29, 5.5, 9)
    a.part(end, '#b06a3c', shape='flat')
    for r in (4, 2.4, 1):
        a.inner_edge(a.ellipse(12, 29, r * .62, r), (125, 68, 34))
    a.inner_edge(end, (90, 46, 22))
    for x in (24, 32):
        a.part(a.rect(x, 19, x + 3, 39), '#d9a35a', bulge=.6)
        a.part(a.rrect(x - 1, 27, x + 4, 31, 1), '#c0c8d4', bulge=.8, spec=True, ao=False)
    a.part(a.capsule((35, 37), (43, 44), 1.3), '#d9a35a', bulge=.5)
    for x in range(16, 39, 3):
        a.px(x, 21, (170, 100, 55))
    return a

def ouro():
    a = Art()
    def bar(dx, dy):
        top = a.poly([(12 + dx, 22 + dy), (30 + dx, 15 + dy), (40 + dx, 20 + dy), (22 + dx, 27 + dy)])
        a.part(a.poly([(22 + dx, 27 + dy), (40 + dx, 20 + dy), (41 + dx, 27 + dy), (23 + dx, 34 + dy)]), '#d08a0a', shape='flat')
        a.part(a.poly([(12 + dx, 22 + dy), (22 + dx, 27 + dy), (23 + dx, 34 + dy), (9 + dx, 29 + dy)]), '#e8a512', shape='flat')
        a.part(top, '#ffd23f', shape='flat', spec=True)
        a.part(a.line([(17 + dx, 22 + dy), (31 + dx, 17 + dy)], 1), '#fff3b0', shape='flat', ao=False, lo=5, hi=5)
    bar(-1, 12)
    bar(3, 0)
    a.sparkle(40, 13); a.sparkle(10, 22, size=1)
    return a

def novelo():
    a = Art()
    ball = a.circle(23, 28, 14)
    a.part(ball, '#ff6fa8', bulge=1.2)
    for k in range(-14, 16, 4):
        a.part(a.line([(8, 31 + k), (38, 20 + k)], 1.2) & ball, '#ff6fa8', shape='flat', lo=1, hi=1, ao=False)
    for k in range(-12, 14, 5):
        a.part(a.line([(12 + k, 15), (19 + k, 41)], 1) & ball, '#ff6fa8', shape='flat', lo=4, hi=4, ao=False, keep=ball & a.circle(19, 23, 10))
    a.part(a.line([(34, 38), (39, 42), (37, 46), (42, 48)], 1.6), '#ff6fa8', shape='flat', lo=3, hi=3)
    a.part(a.capsule((32, 10), (40, 18), 1.2), '#d9d9e0', bulge=.6)
    a.part(a.circle(31, 9, 1.6), '#a8572e', bulge=1)
    return a

def botao():
    a = Art()
    a.part(a.circle(24, 27, 14), '#3fa7ef', bulge=1.1, spec=True)
    a.part(a.circle(24, 27, 10), '#3fa7ef', shape='flat', lo=1, hi=3, ao=False)
    a.inner_edge(a.circle(24, 27, 10), ramp('#3fa7ef')[0])
    for x, y in ((21, 24), (27, 24), (21, 30), (27, 30)):
        a.part(a.circle(x, y, 1.7), '#16325a', shape='flat', ao=False)
        a.px(x - 1, y - 1, (10, 20, 40))
    a.part(a.line([(21, 24), (27, 30)], 1) | a.line([(27, 24), (21, 30)], 1), '#ffe14d', shape='flat', ao=False)
    return a

def giz():
    a = Art()
    cols = ['#ff4d4d', '#ffcf2e', '#3ecf6b', '#3f8cff']
    for i, c in enumerate(cols):
        x = 10 + i * 7; y = 12 + (i % 2) * 4
        body = a.rect(x, y + 6, x + 5, 45)
        a.part(body, c, bulge=.8)
        a.part(a.poly([(x, y + 6), (x + 2.5, y), (x + 5, y + 6)]), c, bulge=.8)
        a.part(a.rect(x, y + 15, x + 5, y + 23), '#fafafa', bulge=.7, ao=False)
        a.part(a.rect(x + 1, y + 17, x + 4, y + 21), c, shape='flat', lo=2, hi=3, ao=False)
        a.inner_edge(body | a.poly([(x, y + 6), (x + 2.5, y), (x + 5, y + 6)]), ramp(c)[0])
    return a

def gude():
    a = Art()
    for (x, y, r, c, sw) in ((17, 32, 9, '#7fd6ff', '#ff4f7b'), (31, 23, 8, '#b388ff', '#ffe14d'), (32, 38, 6.5, '#7cf29c', '#1e7d3a')):
        m = a.circle(x, y, r)
        a.part(m, c, bulge=1.2, lo=1)
        a.part(a.line([(x - r * .6, y + r * .2), (x, y - r * .3), (x + r * .6, y + r * .1)], max(1.5, r * .3)) & m, sw, bulge=.6, ao=False)
        a.part(a.circle(x - r * .4, y - r * .4, r * .25), '#ffffff', shape='flat', ao=False, lo=5, hi=5)
    return a

def pena():
    a = Art()
    m = a.poly([(35, 7), (41, 11), (38, 25), (28, 37), (17, 42), (14, 39), (20, 27), (29, 14)])
    a.part(m, '#fff6d8', bulge=.9, ramp_=ramp('#f5e6c0'), hi=5)
    for t in range(1, 9):
        x = 38 - t * 2.7; y = 9 + t * 3.6
        a.flat(a.line([(x, y), (x - 4, y - 1)], 1) & m, (225, 205, 160))
        a.flat(a.line([(x, y), (x + 3, y + 2.5)], 1) & m, (235, 220, 180))
    a.part(a.poly([(35, 7), (41, 11), (39, 17), (33, 13)]), '#ffa8c8', bulge=.6, ao=False)
    a.part(a.line([(39, 9), (12, 46)], 1.1), '#c19a64', shape='flat', ao=False)
    return a

def po_estrela():
    a = Art()
    bag = a.poly([(13, 24), (35, 24), (40, 45), (8, 45)]) | a.ellipse(24, 45, 16, 2)
    a.part(bag, '#8e5bd6', bulge=.9)
    a.part(a.poly([(16, 17), (32, 17), (30, 24), (18, 24)]), '#7444c0', bulge=.8)
    a.part(a.ellipse(24, 17, 8, 2), '#3a2060', shape='flat')
    a.part(a.capsule((15, 24), (33, 24), 1.3), '#ffd23f', bulge=.8, spec=True)
    a.part(a.poly(star_pts(24, 35, 7, 3)), '#ffe14d', bulge=.7, spec=True, ao=False)
    for x, y, s in ((12, 11, 2), (36, 12, 2), (24, 7, 1), (19, 13, 1)):
        a.sparkle(x, y, '#fff59d', s)
    a.part(a.circle(28, 15, 1.3), '#ffe14d', ao=False)
    a.part(a.circle(20, 14, 1), '#b388ff', ao=False)
    return a

def pilha():
    a = Art()
    a.part(a.rrect(15, 14, 33, 45, 3), '#2b2b36', bulge=1, spec=True)
    a.part(a.rrect(15, 14, 33, 26, 3), '#ff9800', bulge=1, spec=True)
    a.part(a.rect(15, 24, 33, 26), '#ff9800', shape='flat', lo=1, hi=1, ao=False)
    a.part(a.rrect(20, 9, 28, 14, 1), '#c9d1da', bulge=1, spec=True)
    a.part(a.rect(23, 31, 25, 40) | a.rect(20, 34, 28, 36), '#ffd23f', shape='flat', ao=False)
    a.part(a.rect(20, 42, 28, 43), '#56566a', shape='flat', ao=False)
    return a

def papel():
    a = Art()
    for (dx, dy, c) in ((0, 0, '#5ec8ff'), (3, 4, '#ffd23f'), (6, 8, '#ff6fa8')):
        m = a.poly([(10 + dx, 16 + dy), (31 + dx, 10 + dy), (36 + dx, 33 + dy), (15 + dx, 39 + dy)])
        a.part(m, c, shape='flat')
        a.inner_edge(m, ramp(c)[1], 'br')
    a.part(a.poly([(34, 39), (42, 37), (37, 44)]), '#ffe0ef', shape='flat', ao=False)
    for k in range(3):
        a.flat(a.line([(22 + k * 2, 28 + k * 4), (32 + k * 2, 25 + k * 4)], 1), (255, 160, 200))
    return a

# ---------------- ADESIVOS (15..24) ----------------

def _sticker(bg, icon):
    a = Art()
    a.part(a.circle(24, 26, 16), '#ffffff', bulge=.8, ramp_=WHITE, hi=5)
    disc = a.circle(24, 26, 13)
    a.flat(disc, bg)
    a.darken(disc & ~a.circle(23, 25, 12), 0.82)
    a.lighten(disc & a.circle(18, 20, 6) & ~a.circle(21, 23, 7), 0.35)
    icon(a)
    peel = a.poly([(33, 37), (40, 36), (38, 42)])
    a.part(peel, '#dfe3ee', bulge=.5, ramp_=WHITE, ao=True)
    a.flat(a.line([(33, 37), (38, 42)], 1), (160, 165, 190))
    return a

def heart(a, cx, cy, s):
    return a.circle(cx - s * .5, cy - s * .2, s * .58) | a.circle(cx + s * .5, cy - s * .2, s * .58) | a.poly([(cx - s * 1.06, cy), (cx + s * 1.06, cy), (cx, cy + s * 1.15)])

def ad_coracao():
    return _sticker('#ffd1dc', lambda a: a.part(heart(a, 24, 25, 8), '#ff3b5c', bulge=1.1, spec=True))

def ad_estrela():
    return _sticker('#fff1b8', lambda a: a.part(a.poly(star_pts(24, 26.5, 10.5, 4.6)), '#ffc400', bulge=.8, spec=True))

def ad_forca():
    def ic(a):
        a.part(a.rect(15, 24, 33, 28), '#a8b0bc', bulge=.8, spec=True)
        for x in (11, 31):
            a.part(a.rrect(x, 18, x + 6, 34, 1.5), '#3a3a48', bulge=.9, spec=True)
    return _sticker('#ffccbc', ic)

def ad_escudo():
    def ic(a):
        sh = a.poly([(15, 15), (33, 15), (33, 26), (24, 38), (15, 26)])
        a.part(sh, '#3f8cff', bulge=.8, spec=True)
        a.part(a.rect(23, 18, 25, 33) | a.rect(18, 22, 30, 24), '#ffffff', shape='flat', ao=False, keep=sh)
    return _sticker('#d6ecff', ic)

def ad_raio():
    return _sticker('#fff59d', lambda a: a.part(a.poly([(28, 13), (16, 29), (23, 29), (19, 40), (32, 23), (25, 23)]), '#ffa000', bulge=.7, spec=True))

def ad_vampiro():
    def ic(a):
        mouth = a.pie(24, 21, 11, 0, 180)
        a.part(mouth, '#8e1b3a', bulge=.8)
        a.part(a.ellipse(24, 29, 6, 2.2), '#ff6f91', bulge=.8, ao=False)
        for x in (17, 27):
            a.part(a.poly([(x, 22), (x + 4, 22), (x + 2, 29)]), '#ffffff', bulge=.6, ao=False)
        a.part(a.rect(13, 21, 35, 22), '#4a0c20', shape='flat', ao=False)
    return _sticker('#e1bee7', ic)

def ad_nuvem():
    def ic(a):
        m = a.circle(18, 28, 5.2) | a.circle(25, 23, 7) | a.circle(31, 28, 5) | a.rect(16, 28, 33, 33)
        a.part(m, '#ffffff', bulge=1, hi=5)
    return _sticker('#b3e5fc', ic)

def ad_urso():
    def ic(a):
        for x in (16, 32):
            a.part(a.circle(x, 17, 3.8), '#a1662f', bulge=1)
            a.part(a.circle(x, 17, 1.8), '#e6c19c', ao=False)
        a.part(a.circle(24, 26, 9.5), '#a1662f', bulge=1.1)
        a.part(a.ellipse(24, 30, 4.5, 3.4), '#e6c19c', bulge=.8, ao=False)
        a.part(a.ellipse(24, 28.5, 1.8, 1.2), '#2a1a12', ao=False)
        a.pxs([(20, 24), (28, 24), (20, 23), (28, 23)], (30, 20, 20))
    return _sticker('#ffe0b2', ic)

def ad_fantasma():
    def ic(a):
        m = a.circle(24, 23, 8.5) | a.rect(15.5, 23, 32.5, 34)
        for x in (17.5, 24, 30.5):
            m &= ~a.poly([(x - 2.2, 35), (x, 31), (x + 2.2, 35)])
        a.part(m, '#ffffff', bulge=1, hi=5)
        a.part(a.ellipse(21, 22, 1.4, 2.2) | a.ellipse(27, 22, 1.4, 2.2), '#2a2240', shape='flat', ao=False)
        a.part(a.ellipse(24, 27.5, 2, 1.6), '#2a2240', shape='flat', ao=False)
    return _sticker('#c5cae9', ic)

def ad_bum():
    def ic(a):
        a.part(a.poly(star_pts(24, 26, 11.5, 6, n=8)), '#ff7043', bulge=.8)
        a.part(a.poly(star_pts(24, 26, 6.5, 3.4, n=8)), '#ffee58', bulge=.6, ao=False)
    return _sticker('#ffe0b2', ic)

MAT = [madeira, pedra, erva, frasco, ferro, couro, ouro, novelo, botao, giz, gude, pena, po_estrela, pilha, papel,
       ad_coracao, ad_estrela, ad_forca, ad_escudo, ad_raio, ad_vampiro, ad_nuvem, ad_urso, ad_fantasma, ad_bum]
