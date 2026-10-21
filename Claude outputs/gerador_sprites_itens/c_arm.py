from eng import *

def _shirt(a, col, collar=True, bulge=.6):
    m = a.poly([(15, 11), (33, 11), (42, 18), (38, 26), (34, 23), (34, 45), (14, 45), (14, 23), (10, 26), (6, 18)])
    a.part(m, col, bulge=bulge)
    a.flat(a.line([(14, 23), (14.5, 44)], 1), ramp(col)[1])
    a.flat(a.line([(34, 23), (33.5, 44)], 1), ramp(col)[1])
    if collar:
        a.erase(a.ellipse(24, 10, 5, 3.5))
    return m

def cobertor():
    a = Art()
    m = a.poly([(7, 14), (40, 11), (43, 41), (36, 45), (10, 44)])
    a.part(m, '#4f9be6', bulge=.8)
    for gx in range(0, 6):
        for gy in range(0, 6):
            if (gx + gy) % 2 == 0:
                sq = a.rect(8 + gx * 6, 13 + gy * 6, 13 + gx * 6, 18 + gy * 6) & m
                a.tint(sq, '#ffffff', 0.25)
    for gx in range(1, 6):
        a.flat(a.line([(8 + gx * 6, 13), (8 + gx * 6, 44)], 1) & m & a.rect(0, 0, 48, 48), (60, 110, 190))
    a.erase(a.rect(0, 0, 48, 0))
    fold = a.poly([(30, 36), (43, 33), (43, 41), (36, 45)])
    a.part(fold, '#ffcf4d', bulge=.7)
    for k in range(5):
        a.px(31 + k * 2, 37 - k * .6, (255, 245, 200))
    return a

def papelao():
    a = Art()
    body = a.rect(13, 12, 35, 45)
    a.part(body, '#c99556', shape='flat')
    a.part(a.rect(13, 12, 35, 16), '#e2b67a', shape='flat', edge=(150, 105, 55))
    for x0 in (8, 35):
        a.part(a.rect(x0, 15, x0 + 5, 28), '#b0793f', shape='flat', edge=(120, 80, 40))
    a.part(a.rect(16, 21, 32, 23), '#a8763e', shape='flat', ao=False)
    a.flat(a.line([(19, 30), (29, 40)], 1) | a.line([(29, 30), (19, 40)], 1), (110, 75, 40))
    a.part(a.rect(16, 42, 32, 44), '#e8d8b0', shape='flat', ao=False)
    for x in range(17, 32, 3):
        a.px(x, 43, (180, 150, 100))
    a.tex_noise(body, .06, seed=11)
    a.inner_edge(body, (120, 82, 42), 'br')
    return a

def toalha():
    a = Art()
    for i, (y, c) in enumerate(((33, '#38c6d9'), (24, '#ffae42'), (15, '#f0629a'))):
        m = a.rrect(8, y, 40, y + 10, 4)
        a.part(m, c, bulge=.7)
        a.part(a.rect(11, y + 3, 37, y + 4), c, shape='flat', lo=4, hi=5, ao=False, keep=m)
        a.part(a.rect(11, y + 6, 37, y + 6), c, shape='flat', lo=1, hi=1, ao=False, keep=m)
        for x in range(10, 39, 2):
            a.px(x, y + 9, ramp(c)[2])
    return a

def capa_chuva():
    a = Art()
    m = a.poly([(17, 13), (31, 13), (42, 45), (6, 45)])
    a.part(m, '#ffe23a', bulge=.6)
    for x0, x1 in ((16, 11), (24, 24), (32, 37)):
        a.flat(a.line([(x0 + (24 - x0) * .4, 18), (x1, 44)], 1) & m, (215, 170, 20))
    a.part(a.ellipse(24, 14, 9, 7), '#fdd226', bulge=.9)
    a.part(a.ellipse(24, 15, 4.5, 3.5), '#5d3a26', shape='flat')
    for y in (23, 30, 37):
        a.part(a.circle(24, y, 1.8), '#1e88e5', bulge=1.2, spec=True, ao=False)
    a.part(a.rect(7, 43, 41, 45) & m, '#e6b800', shape='flat', ao=False)
    return a

def casaco():
    a = Art()
    m = _shirt(a, '#23a596', bulge=.8)
    for y in (20, 27, 34, 41):
        a.part(a.line([(14, y), (34, y)], 1) & m, '#23a596', shape='flat', lo=1, hi=1, ao=False)
    a.part(a.rect(23, 13, 25, 45), '#0f5e55', shape='flat')
    for y in (18, 25, 32, 39):
        a.px(24, y, (220, 220, 220))
    hood = a.ellipse(24, 11, 9, 4) & ~a.ellipse(24, 10, 5, 3)
    a.part(hood, '#f2f2ec', bulge=1)
    a.part(a.rect(14, 42, 34, 45) & m, '#e8e8e0', bulge=.6)
    return a

def travesseiro():
    a = Art()
    m = a.rrect(8, 14, 40, 42, 8)
    a.part(m, '#f6f6ff', bulge=1.1, ramp_=WHITE, hi=5)
    for x, y in ((8, 14), (40, 14), (8, 42), (40, 42)):
        a.part(a.circle(x, y, 3), '#e6e8ff', bulge=1, ramp_=WHITE, hi=5)
    a.part(a.line([(14, 28), (34, 28)], 1), '#c5cae9', shape='flat', ao=False)
    a.part(a.circle(24, 28, 4.5), '#8f9ae8', bulge=1.2, spec=True)
    for x, y in ((14, 19), (34, 37), (34, 19), (14, 37)):
        a.px(x, y, (190, 195, 235))
    return a

def super_capa():
    a = Art()
    m = a.poly([(16, 12), (32, 12), (43, 45), (34, 41), (24, 45), (14, 41), (5, 45)])
    a.part(m, '#e53935', bulge=.6)
    for x0, x1 in ((19, 12), (24, 24), (29, 36)):
        a.flat(a.line([(x0, 16), (x1, 42)], 1) & m, (160, 30, 40))
    a.part(a.rrect(13, 9, 35, 14, 2), '#ffcf2e', bulge=.8)
    a.part(a.circle(14, 11.5, 2.6), '#ffcf2e', bulge=1.2, spec=True)
    a.part(a.circle(34, 11.5, 2.6), '#ffcf2e', bulge=1.2, spec=True)
    emb = a.poly([(24, 18), (32, 23), (24, 34), (16, 23)])
    a.part(emb, '#ffcf2e', bulge=.6)
    a.part(a.poly(star_pts(24, 24.5, 4.2, 1.8)), '#e53935', shape='flat', ao=False)
    return a

def pijama_dino():
    a = Art()
    m = _shirt(a, '#5fbf5f', bulge=.8)
    a.part(a.rrect(18, 23, 30, 43, 4), '#d4ecae', bulge=.6)
    for y in (27, 31, 35, 39):
        a.flat(a.line([(19, y), (29, y)], 1), (170, 205, 130))
    for y in (13, 19, 25, 31):
        a.part(a.poly([(34, y), (41, y + 3), (34, y + 6)]), '#ff9f2e', bulge=.6)
    for x in (17, 27):
        a.part(a.poly([(x, 13), (x + 3, 7), (x + 6, 13)]), '#ff9f2e', bulge=.6)
    for x, y in ((16, 30), (16, 37), (32, 41)):
        a.part(a.circle(x, y, 1.2), '#3f9a45', ao=False)
    return a

def cavaleiro():
    a = Art()
    m = _shirt(a, '#9fb2c0', bulge=.9)
    a.tex_noise(m, .05, seed=9)
    a.part(a.rect(18, 12, 30, 45), '#c9d6e0', bulge=.7, spec=True)
    shield = a.poly([(19, 19), (29, 19), (29, 29), (24, 36), (19, 29)])
    a.part(shield, '#1e6fd9', bulge=.7)
    a.part(a.rect(23, 20, 25, 33) | a.rect(20, 24, 28, 26), '#ffcf2e', shape='flat', ao=False, keep=shield)
    for x in (10, 38):
        a.part(a.circle(x, 21, 3.4), '#7f93a3', bulge=1.2, spec=True)
    for y in range(15, 45, 6):
        a.px(19, y, (230, 240, 245)); a.px(29, y, (110, 125, 140))
    a.part(a.rect(14, 41, 34, 45) & m, '#6f5232', bulge=.5)
    a.part(a.rect(22, 41, 26, 45), '#ffcf2e', bulge=.8, spec=True, ao=False)
    return a

def astronauta():
    a = Art()
    m = _shirt(a, '#eef1f4', bulge=.8)
    a.part(a.rrect(17, 23, 31, 34, 2), '#8796a6', bulge=.6)
    for i, c in enumerate(('#ff5252', '#ffee58', '#69f0ae')):
        a.part(a.rect(19 + i * 4, 26, 21 + i * 4, 29), c, bulge=.8, ao=False)
    a.part(a.rect(19, 31, 29, 32), '#2d3a4a', shape='flat', ao=False)
    a.part(a.rect(14, 38, 34, 41) & m, '#ff7a3d', bulge=.6)
    a.part(a.circle(30, 17, 2.4), '#3f8cff', bulge=1.2, spec=True)
    a.part(a.rect(16, 15, 21, 18), '#ff5252', shape='flat', ao=False)
    a.part(a.rect(8, 22, 12, 24) & m, '#ff7a3d', shape='flat', ao=False)
    a.part(a.rect(36, 22, 40, 24) & m, '#ff7a3d', shape='flat', ao=False)
    return a

ARMADURAS = [cobertor, papelao, toalha, capa_chuva, casaco, travesseiro, super_capa, pijama_dino, cavaleiro, astronauta]
