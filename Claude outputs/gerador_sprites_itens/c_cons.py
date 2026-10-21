from eng import *
import math

def batata():
    a = Art()
    m = a.ellipse(24, 29, 15, 10.5) | a.ellipse(17, 27, 8, 9)
    a.part(m, '#c99a55', bulge=1.1)
    a.tex_noise(m, .12, seed=4, density=.35)
    for x, y in ((15, 24), (27, 22), (32, 31), (21, 34), (36, 26)):
        a.flat(a.ellipse(x, y, 1, .6), (120, 84, 40))
        a.px(x - 1, y - 1, (230, 195, 130))
    a.part(a.capsule((33, 18), (36, 15), .8), '#7cb342', bulge=.5)
    a.pxs([(14, 22), (15, 21), (16, 21)], '#f3dca5')
    return a

def maca():
    a = Art()
    body = a.circle(18.5, 29, 12) | a.circle(29.5, 29, 12) | a.ellipse(24, 34, 13, 9)
    body &= ~a.ellipse(24, 16.5, 3.5, 2.5)
    a.part(body, '#e3242b', bulge=1.2, spec=True)
    a.part(a.ellipse(24, 18.5, 3, 1.5), '#7a1016', shape='flat')
    a.part(a.capsule((24, 18), (26.5, 10), 1.2), '#7a4a26', bulge=.8)
    a.part(a.poly([(27, 12), (31, 8), (37, 7), (35, 12), (30, 14)]), '#4caf3c', bulge=.7)
    a.flat(a.line([(28, 12), (35, 8.5)], 1), (46, 110, 40))
    a.pxs([(15, 23), (16, 22), (15, 24)], '#ffe7e0')
    return a

def banana():
    a = Art()
    m = a.circle(25, 6, 34) & ~a.circle(27, -1, 33) & a.ellipse(24, 33, 19, 15)
    a.part(m, '#f7cf2b', bulge=1.3)
    rib = a.circle(25, 6, 31.5) & ~a.circle(25, 6, 30.6) & m
    a.flat(rib, (215, 160, 30))
    a.part(a.capsule((39.5, 29), (42, 21), 1.7), '#8bae3a', bulge=.6)
    a.part(a.circle(42.3, 20, 1.8), '#5d4a22')
    a.part(a.circle(7, 26.5, 1.8), '#4e3a1c')
    for x, y in ((20, 38), (31, 37), (14, 34), (36, 33)):
        a.px(x, y, (150, 100, 30))
    return a


def uva():
    a = Art()
    pos = [(18, 20), (25, 19), (32, 20), (15, 27), (22, 26.5), (29, 26.5), (35, 27.5), (18, 33), (25, 33), (32, 33.5), (21, 39.5), (28, 39.5), (24.5, 45)]
    for x, y in pos:
        a.part(a.circle(x, y, 4.2), '#8e44c9', bulge=1.3, spec=True)
    a.part(a.capsule((25, 15), (27, 8), 1.2), '#6d4a26')
    leaf = a.poly([(27, 11), (33, 6), (40, 8), (37, 14), (30, 15)])
    a.part(leaf, '#58b947', bulge=.7)
    a.flat(a.line([(29, 13), (37, 9)], 1), (50, 120, 45))
    a.part(a.line([(25, 9), (21, 7), (19, 9)], 1), '#6aa040', shape='flat', ao=False)
    return a

def vitamina():
    a = Art()
    glass = a.poly([(13, 9), (35, 9), (32, 46), (16, 46)])
    a.part(glass, '#cfe9f2', shape='flat', lo=2, hi=5)
    juice = a.poly([(14.2, 15), (33.8, 15), (31.6, 44), (16.4, 44)])
    a.part(juice, '#ff9f1a', bulge=.6)
    a.part(a.ellipse(24, 15, 9.8, 1.6), '#ffc65a', shape='flat')
    for x, y in ((19, 25), (27, 30), (22, 37), (29, 21)):
        a.part(a.circle(x, y, 1.1), '#ffe0a0', ao=False)
    a.flat(a.line([(16, 12), (18, 43)], 1), (245, 252, 255))
    a.flat(a.line([(17.5, 12), (19.2, 30)], 1), (230, 246, 252))
    a.part(a.ellipse(24, 9, 11, 1.6), '#e8f6fb', shape='flat', edge=(120, 160, 180))
    a.part(a.capsule((29, 4), (31, 20), 1.3), '#ff5d8f', bulge=.7)
    a.part(a.capsule((29, 4), (25, 2), 1.3), '#ff5d8f', bulge=.7)
    return a

def leite():
    a = Art()
    front = a.poly([(12, 18), (28, 18), (28, 47), (12, 47)])
    side = a.poly([(28, 18), (37, 14), (37, 42), (28, 47)])
    a.part(front, '#f6f8fb', shape='flat', lo=3, hi=5)
    a.part(side, '#d6dde8', shape='flat', lo=1, hi=3)
    a.part(a.poly([(12, 18), (20, 8), (28, 18)]), '#ffffff', shape='flat', lo=3, hi=5)
    a.part(a.poly([(20, 8), (29, 4), (37, 14), (28, 18)]), '#cfd8e6', shape='flat', lo=1, hi=3)
    a.part(a.rect(18, 5, 23, 8), '#e6ebf2', shape='flat')
    a.part(a.rect(12, 26, 28, 39), '#3b8fe0', shape='flat', lo=2, hi=4)
    a.part(a.poly([(28, 26), (37, 22), (37, 35), (28, 39)]), '#2a6fbf', shape='flat', lo=1, hi=3)
    drop = a.circle(20, 34, 3.2) | a.poly([(16.9, 33), (23.1, 33), (20, 27.5)])
    a.part(drop, '#ffffff', bulge=.8, lo=3, ao=False)
    for x, y in ((14, 21), (24, 43), (15, 44)):
        a.flat(a.ellipse(x, y, 1.6, 1.1), (40, 40, 52))
    a.inner_edge(front | side, (150, 160, 185), 'br')
    return a


def biscoito():
    a = Art()
    m = a.circle(24, 28, 14) & ~(a.circle(37, 18, 5.5) | a.circle(34, 14, 4))
    a.part(m, '#d9a05b', bulge=.9)
    a.tex_noise(m, .15, seed=7, density=.4)
    for x, y in ((18, 22), (27, 21), (24, 30), (16, 32), (31, 32), (25, 38), (33, 25), (19, 37)):
        a.part(a.ellipse(x, y, 1.9, 1.5), '#4e2c14', bulge=.8, ao=False)
    for x, y in ((14, 27), (22, 25), (29, 36)):
        a.px(x, y, (245, 215, 150))
    for x, y in ((36, 22), (33, 19), (38, 25)):
        a.px(x, y, (190, 130, 60))
    return a

def sanduiche():
    a = Art()
    top = a.poly([(7, 30), (23, 9), (41, 30)])
    a.part(a.poly([(7, 39), (41, 39), (41, 44), (7, 44)]), '#e9b866', bulge=.6)
    a.part(a.poly([(6, 35), (42, 35), (41, 39), (7, 39)]), '#6cc13a', bulge=.5)
    for x in range(8, 41, 5):
        a.part(a.circle(x, 36, 2.2), '#6cc13a', bulge=.5, ao=False)
    a.part(a.poly([(8, 32), (40, 32), (41, 35), (7, 35)]), '#e8423c', bulge=.5)
    a.part(a.poly([(8, 30), (41, 30), (42, 33), (6, 33)]), '#ffcc33', shape='flat')
    a.part(a.poly([(34, 30), (40, 30), (38, 35)]), '#ffcc33', shape='flat', ao=False)
    a.part(top, '#f0c879', bulge=.7)
    inner = a.poly([(10.5, 28.5), (23, 12.5), (37.5, 28.5)])
    a.part(inner, '#fbe9c4', shape='flat', lo=3, hi=5, ao=False)
    a.tex_noise(inner, .06, seed=2)
    return a

def pirulito():
    a = Art()
    a.part(a.capsule((24, 30), (24, 48), 1.4), '#f5f5f5', bulge=.7)
    disc = a.circle(24, 19, 13)
    a.part(disc, '#ff5d8f', bulge=.9)
    cols = ['#ffd23f', '#3ecf6b', '#4fc3f7', '#b388ff', '#ff5d8f']
    for i in range(60):
        ang = i * 0.42
        r = 1 + i * 0.19
        x = 24 + math.cos(ang) * r; y = 19 + math.sin(ang) * r
        a.part(a.circle(x, y, 1.3), cols[(i // 6) % 5], bulge=.6, ao=False, keep=disc)
    a.part(disc, '#ffffff', keep=disc & a.circle(18, 13, 3.5) & ~a.circle(19.5, 14.5, 3), ao=False, lo=5, hi=5)
    a.part(a.rect(20, 32, 28, 34), '#ff7aa2', shape='flat')
    return a

def chocolate():
    a = Art()
    cup = a.rrect(10, 18, 32, 45, 4)
    a.part(a.ellipse(36, 31, 6, 7) & ~a.ellipse(36, 31, 2.6, 3.6), '#e8453c', bulge=.9)
    a.part(cup, '#e8453c', bulge=.8)
    a.part(a.ellipse(21, 18.5, 11, 3.2), '#5a2e18', shape='flat', edge=(70, 30, 30))
    a.part(a.ellipse(17, 18, 3, 1.4) | a.ellipse(24, 17.5, 3.5, 1.5), '#fff6ea', shape='flat', ao=False)
    heart = a.circle(18.5, 29.5, 2.6) | a.circle(23.5, 29.5, 2.6) | a.poly([(15.6, 30.5), (26.4, 30.5), (21, 36)])
    a.part(heart, '#fff3f0', shape='flat', lo=3, hi=5, ao=False)
    for i, x in enumerate((15, 21, 27)):
        a.part(a.line([(x, 15), (x + 2, 12), (x, 9), (x + 2, 6)], 1.2), '#e9e2ec', shape='flat', ao=False, lo=4, hi=5)
    return a

def algodao():
    a = Art()
    a.part(a.poly([(21, 28), (27, 28), (25.5, 48), (22.5, 48)]), '#fff3a0', bulge=.6)
    for k in range(3):
        a.flat(a.line([(22, 33 + k * 5), (26.5, 31 + k * 5)], 1), (255, 140, 180))
    m = a.circle(17, 19, 8.5) | a.circle(28, 16, 9) | a.circle(23, 25, 9.5) | a.circle(32, 25, 7) | a.circle(14, 26, 6)
    a.part(m, '#ffb6d9', bulge=1.3)
    for x, y in ((13, 15), (24, 11), (34, 20), (19, 22)):
        a.part(a.circle(x, y, 2.2), '#ffd6ea', ao=False, keep=m)
    a.tex_noise(m, .08, seed=5)
    return a

def curativo():
    a = Art()
    m = a.capsule((10, 38), (38, 12), 6.5)
    a.part(m, '#f2b47a', bulge=.45)
    for t in (-0.42, -0.3, 0.3, 0.42):
        cx = 24 + t * 28; cy = 25 - t * 26
        for dx, dy in ((-2, -2), (2, 2), (0, 0)):
            a.px(int(cx + dx), int(cy + dy), (196, 125, 75))
    pad = a.poly([(17, 25), (24, 18), (31, 25), (24, 32)])
    a.part(pad, '#fde9d2', shape='flat', lo=3, hi=5, edge=(205, 150, 110))
    a.part(a.rect(23, 21, 25, 29) | a.rect(20, 24, 28, 26), '#ff3b5c', shape='flat', ao=False)
    return a


def pocao_coragem():
    a = Art()
    a.part(a.rect(21, 7, 27, 12), '#a8723c', bulge=.6)
    a.part(a.rect(19, 12, 29, 14), '#c89b6a', shape='flat')
    neck = a.rect(20, 14, 28, 20)
    a.part(neck, '#d7eef6', shape='flat', lo=2, hi=5)
    bulb = a.circle(24, 33, 14)
    a.part(bulb, '#d7eef6', bulge=1, lo=2)
    liq = a.circle(24, 33, 12) & ~a.rect(0, 0, 48, 26)
    a.part(liq, '#ff6a2c', bulge=1.2)
    a.part(a.ellipse(24, 26.5, 11.6, 1.5), '#ffab5a', shape='flat', ao=False)
    star = a.poly(star_pts(24, 35, 6, 2.7))
    a.part(star, '#ffe94d', bulge=.6, ao=False)
    for x, y in ((18, 39), (30, 31), (28, 41)):
        a.part(a.circle(x, y, .9), '#ffd0a0', ao=False)
    a.flat(a.line([(14, 29), (15, 36)], 1), (245, 252, 255))
    a.pxs([(16, 25), (17, 24)], '#ffffff')
    return a

def bala_goma():
    a = Art()
    def bear(cx, cy, c):
        m = a.circle(cx, cy - 7, 4.4) | a.ellipse(cx, cy + 3, 5.3, 6.5) | a.circle(cx - 3.5, cy - 10.5, 1.8) | a.circle(cx + 3.5, cy - 10.5, 1.8)
        m |= a.circle(cx - 5, cy - 1, 1.8) | a.circle(cx + 5, cy - 1, 1.8) | a.circle(cx - 3, cy + 9, 2) | a.circle(cx + 3, cy + 9, 2)
        a.part(m, c, bulge=1.1, spec=True)
        a.px(cx - 2, cy - 8, (40, 20, 30)); a.px(cx + 2, cy - 8, (40, 20, 30))
        a.flat(a.ellipse(cx, cy + 3, 2.6, 3), ramp(c)[4])
    bear(15, 30, '#ff4d4d')
    bear(33, 30, '#3fbf4f')
    bear(24, 34, '#ffbe1a')
    return a

CONS = [batata, maca, banana, uva, vitamina, leite, biscoito, sanduiche, pirulito, chocolate, algodao, curativo, pocao_coragem, bala_goma]
