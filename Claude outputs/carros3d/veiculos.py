"""Modelos 3D (SDF) dos 4 veículos da cidade + pintura/detalhes de cada um.

Unidades = pixels do jogo. Modelo virado para +x (frente), y = lado esquerdo do carro, z = altura.
"""
import math
import numpy as np

# materiais
PAINT, CABIN, GLASS, TIRE, RIM, CHROME, HEADL, TAILL, DARK, WHITE, ACCENT, WAFFLE, SCOOP, CHERRY, AMBER, WOOD, RED, BLACK, GREEN = range(1, 20)


class Cena:
    def __init__(self):
        self.rows = []
        self.rodas = []          # (x, y, z, raio) para o giro da calota

    def add(self, tipo, mat, c, a=(0, 0, 0), r=0.0, op=0, k=0.0, bob=1, planos=()):
        row = np.zeros(28)
        row[0], row[1], row[2], row[3] = tipo, mat, op, k
        row[4:7] = c
        row[7:10] = a
        row[10] = r
        row[11] = bob
        for j, (n, q) in enumerate(planos):
            nn = np.array(n, float)
            nn /= np.linalg.norm(nn)
            row[12 + 4 * j:15 + 4 * j] = nn
            row[15 + 4 * j] = float(np.dot(np.array(q, float) - np.array(c, float), nn))   # plano passando pelo ponto q
        self.rows.append(row)

    # atalhos
    def caixa(self, mat, c, h, r, **kw): self.add(0, mat, c, h, r, **kw)
    def elip(self, mat, c, rr, **kw): self.add(1, mat, c, rr, **kw)
    def cilY(self, mat, c, rad, hw, r=0.0, **kw): self.add(2, mat, c, (rad, hw, 0), r, **kw)
    def cilZ(self, mat, c, rad, hh, r=0.0, **kw): self.add(6, mat, c, (rad, hh, 0), r, **kw)
    def cilX(self, mat, c, rad, hl, r=0.0, **kw): self.add(7, mat, c, (rad, hl, 0), r, **kw)
    def caps(self, mat, a, b, r, **kw): self.add(3, mat, a, b, r, **kw)
    def esf(self, mat, c, r, **kw): self.add(4, mat, c, (0, 0, 0), r, **kw)
    def cone(self, mat, ponta, h, rtopo, **kw): self.add(5, mat, ponta, (h, rtopo, 0), **kw)

    def roda(self, x, y, raio, hw, calota=0.6, aro_branco=False):
        """pneu + calota (a calota fica um pouco pra fora, só a face aparece)"""
        s = 1 if y > 0 else -1
        self.cilY(TIRE, (x, y, raio), raio, hw, 2.2, bob=0)
        self.cilY(RIM, (x, y + s * 0.6, raio), raio * calota, hw, 1.2, bob=0)
        self.rodas.append((x, y, raio, raio, aro_branco))

    def arco(self, x, y, raio, hw):
        """caixa de roda: tira um pedaço da carroceria em volta da roda"""
        self.cilY(PAINT, (x, y, raio), raio + 3.0, hw + 6, 1.0, op=2, k=2.5)

    def array(self):
        return np.array(self.rows)


# ---------------------------------------------------------------------------
def sedan():
    S = Cena()
    L2 = 78
    # carroceria baixa (capô e porta-malas levemente caídos)
    S.caixa(PAINT, (0, 0, 20), (L2, 33, 12), 10,
            planos=[((0.22, 0, 1), (56, 0, 31)), ((-0.22, 0, 1), (-60, 0, 31))])
    # para-lamas saltados
    for x in (50, -50):
        for y in (27, -27):
            S.elip(PAINT, (x, y, 21), (26, 8, 11), op=1, k=5)
    for x in (50, -50):
        for y in (31, -31):
            S.arco(x, y, 14, 6)
    # estufa de vidro (para-brisa e vidro traseiro inclinados, laterais caindo pra dentro)
    S.caixa(GLASS, (-6, 0, 40), (36, 27, 11), 4, op=1, k=2,
            planos=[((1, 0, 1.0), (27, 0, 30)), ((-1, 0, 1.25), (-40, 0, 30)),
                    ((0, 1, 0.38), (0, 26, 30)), ((0, -1, 0.38), (0, -26, 30))])
    # teto
    S.caixa(PAINT, (-9, 0, 50.5), (15.5, 18.5, 2.6), 2.4, op=1, k=1.2)
    # colunas A, B e C
    for s in (1, -1):
        S.caps(PAINT, (27, s * 25.5, 31), (6, s * 18.2, 50), 1.7)
        S.caps(BLACK, (-8, s * 25.8, 31), (-8, s * 18.6, 50), 1.2)
        S.caps(PAINT, (-38, s * 25, 31), (-23, s * 18, 50), 2.6)
    # para-choques, grade, faróis, lanternas
    S.caixa(DARK, (L2 + 1, 0, 13), (3, 31, 5), 2.5)
    S.caixa(DARK, (-L2 - 1, 0, 13), (3, 31, 5), 2.5)
    S.caixa(DARK, (L2, 0, 21), (2.2, 13, 3.5), 1.2)
    for y in (22, -22):
        S.caixa(HEADL, (L2 - 3, y, 24), (4.5, 8, 3.2), 2)
        S.caixa(TAILL, (-L2 + 1, y, 25), (3.5, 9, 3), 1.5)
    # retrovisores
    for y in (34, -34):
        S.caixa(PAINT, (24, y, 34), (3, 4.5, 2.6), 1.5)
    # aerofólio
    S.caixa(PAINT, (-69, 0, 38), (5, 30, 1.4), 1)
    for y in (20, -20):
        S.caixa(BLACK, (-68, y, 34), (1.5, 1.5, 4), 0.6)
    # escapamento duplo
    for y in (-14, -20):
        S.cilX(CHROME, (-L2 - 2, y, 9), 2.2, 3, 0.6)
    for x in (50, -50):
        for y in (31, -31):
            S.roda(x, y, 14, 5.5)
    return S


def fusca():
    S = Cena()
    S.elip(PAINT, (0, 0, 22), (66, 29, 16))
    S.caixa(PAINT, (0, 0, 15), (62, 26, 8), 6, op=1, k=8)
    # para-lamas redondos
    for x in (46, -46):
        for y in (25, -25):
            S.elip(PAINT, (x, y, 19), (22, 10, 14), op=1, k=6)
    for x in (46, -46):
        for y in (29, -29):
            S.arco(x, y, 13, 5)
    # cabine em domo
    S.elip(GLASS, (-6, 0, 30), (35, 24, 20), op=1, k=6, planos=[((0, 0, -1), (0, 0, 22))])
    S.elip(PAINT, (-8, 0, 30.3), (30.5, 24.8, 20.5), op=0, planos=[((0, 0, -1), (0, 0, 35.5))])  # teto
    for s in (1, -1):
        S.caps(PAINT, (22, s * 21, 30), (6, s * 16, 46), 1.8)      # coluna A
        S.caps(PAINT, (-8, s * 23.6, 30), (-8, s * 19, 46), 1.6)    # coluna B
        S.caps(PAINT, (-36, s * 18, 30), (-24, s * 14, 45), 3.2)    # coluna C
    # estribos
    for y in (31, -31):
        S.caixa(DARK, (0, y, 9), (24, 3, 1.5), 1)
    # faróis redondos em cima dos para-lamas da frente
    for y in (23, -23):
        S.esf(HEADL, (58, y, 27), 5.5)
        S.esf(TAILL, (-60, y, 25), 3.6)
    # para-choques cromados
    S.caps(CHROME, (69, -27, 11), (69, 27, 11), 2.6)
    S.caps(CHROME, (-69, -27, 11), (-69, 27, 11), 2.6)
    for y in (12, -12):
        S.caps(CHROME, (69, y, 9), (69, y, 15), 1.6)
        S.caps(CHROME, (-69, y, 9), (-69, y, 15), 1.6)
    # escapamento
    S.cilX(CHROME, (-71, -12, 9), 2, 3, 0.5)
    for x in (46, -46):
        for y in (28, -28):
            S.roda(x, y, 13, 5, calota=0.62, aro_branco=True)
    return S


def onibus():
    S = Cena()
    S.caixa(PAINT, (-12, 0, 54), (110, 38, 40), 7)
    S.caixa(PAINT, (106, 0, 33), (18, 34, 17), 8, op=1, k=5)          # capô
    S.caixa(BLACK, (124, 0, 18), (3, 37, 5), 2)                      # para-choque
    S.caixa(BLACK, (-123, 0, 18), (3, 39, 5), 2)
    S.caixa(DARK, (123, 0, 33), (2, 14, 8), 1.5)                     # grade
    for y in (25, -25):
        S.cilX(HEADL, (122, y, 34), 4.5, 1.6, 0.8)
        S.caixa(TAILL, (-122, y, 34), (1.5, 4, 6), 1)
    # escotilhas e luzes do teto
    for x in (-70, -5, 55):
        S.caixa(DARK, (x, 0, 93.5), (12.5, 15.5, 1.5), 1.0)
        S.caixa(WHITE, (x, 0, 94.5), (10.5, 13.5, 1.6), 1.0)
    for y in (26, 10, -10, -26):
        S.caixa(AMBER if abs(y) < 20 else RED, (96, y, 92), (2.5, 3.2, 2.5), 1.2)
        S.caixa(AMBER if abs(y) < 20 else RED, (-120, y, 92), (2.5, 3.2, 2.5), 1.2)
    # espelhos grandes
    for y in (44, -44):
        S.caps(BLACK, (98, y * 0.86, 66), (100, y, 66), 0.8)
        S.caixa(BLACK, (100, y, 64), (2, 2.5, 8), 1)
    # placa de PARE (lado esquerdo)
    S.cilY(RED, (70, 41, 64), 8, 0.8, 0.4)
    for x in (70, -75):
        for y in (34, -34):
            S.arco(x, y, 17, 7)
    for y in (34, -34):
        S.roda(70, y, 17, 6.5, calota=0.55)
        S.roda(-75, y, 17, 7.5, calota=0.55)
    S.cilX(CHROME, (-124, -20, 10), 2.5, 3, 0.5)
    return S


def van():
    S = Cena()
    S.caixa(PAINT, (-22, 0, 50), (68, 36, 37), 8)                     # baú
    S.caixa(PAINT, (56, 0, 31), (24, 35, 15), 8, op=1, k=4)           # cabine (parte de baixo)
    S.caixa(GLASS, (51, 0, 54), (21, 33, 10), 4, op=1, k=2,
            planos=[((1, 0, 0.8), (66, 0, 45)), ((0, 1, 0.25), (0, 33, 45)), ((0, -1, 0.25), (0, -33, 45))])
    S.caixa(PAINT, (47, 0, 63.5), (17, 31, 2.6), 2.2, op=1, k=1.5)   # teto da cabine
    for s in (1, -1):
        S.caps(PAINT, (66, s * 32, 45), (58, s * 29.5, 63), 2.0)       # coluna A
        S.caps(PAINT, (40, s * 33, 45), (40, s * 30.5, 63), 1.6)       # coluna B
    S.caixa(PAINT, (76, 0, 25), (14, 34, 11), 7, op=1, k=6)           # capô
    S.caixa(DARK, (90, 0, 13), (3, 34, 5), 2.5)
    S.caixa(DARK, (-91, 0, 13), (3, 36, 5), 2.5)
    for y in (24, -24):
        S.caixa(HEADL, (89, y, 25), (2.5, 6, 3.5), 1.5)
        S.caixa(TAILL, (-90, y, 30), (1.5, 4, 7), 1)
    # toldo listrado e balcão do lado direito (lado que aparece andando pra direita)
    S.caixa(ACCENT, (-22, -42, 76), (32, 7, 1.4), 1, planos=[((0, -0.35, 1), (-22, -42, 76.5))])
    S.caixa(WOOD, (-22, -38.5, 42), (30, 3, 1.4), 0.8)
    # casquinha gigante no teto
    S.cone(WAFFLE, (-22, 0, 86), 30, 13)
    S.esf(SCOOP, (-22, 0, 121), 15)
    for a in range(6):
        ang = a * math.pi / 3 + 0.3
        S.esf(SCOOP, (-22 + math.cos(ang) * 12, math.sin(ang) * 12, 112), 5.5, op=1, k=3)
    S.esf(CHERRY, (-22, 0, 138), 4.2)
    S.caps(GREEN, (-22, 0, 141), (-18, 3, 149), 0.8)
    for x in (-70, 20):
        S.caixa(WHITE, (x, 18, 88), (6, 6, 2), 1.5)
    # alto-falante na cabine
    S.cilX(WHITE, (60, 0, 66), 4, 6, 1)
    for x in (52, -60):
        for y in (34, -34):
            S.arco(x, y, 15, 6)
    for x in (52, -60):
        for y in (33, -33):
            S.roda(x, y, 15, 6, calota=0.58)
    S.cilX(CHROME, (-93, -18, 9), 2.2, 3, 0.5)
    return S


# ---------------------------------------------------------------------------
# DETALHES (pintura procedural) — devolvem cor base (N,3) e "tipo de luz" (N,)
# luz: 0 tinta, 1 vidro, 2 cromo, 3 fosco (pneu/plástico), 4 emissivo
# ---------------------------------------------------------------------------

def rgb(*c):
    return np.array(c, float)


def decorar(nome, matv, pos, nrm, spin, rodas):
    N = len(matv)
    cor = np.zeros((N, 3))
    luz = np.zeros(N, int)
    x, y, z = pos[:, 0], pos[:, 1], pos[:, 2]
    nx, ny, nz = nrm[:, 0], nrm[:, 1], nrm[:, 2]
    m = np.rint(matv).astype(int)

    pal = {
        "sedan":  dict(p=rgb(196, 30, 38), a=rgb(250, 248, 240)),
        "fusca":  dict(p=rgb(82, 156, 220), a=rgb(250, 248, 240)),
        "onibus": dict(p=rgb(252, 186, 22), a=rgb(30, 28, 32)),
        "van":    dict(p=rgb(246, 244, 238), a=rgb(238, 104, 152)),
    }[nome]
    P, A = pal["p"], pal["a"]

    def put(mask, c, l):
        cor[mask] = c
        luz[mask] = l

    put(m == PAINT, P, 0)
    put(m == ACCENT, A, 0)
    put(m == DARK, rgb(46, 44, 52), 3)
    put(m == BLACK, rgb(30, 28, 34), 3)
    put(m == CHROME, rgb(200, 204, 214), 2)
    put(m == WHITE, rgb(240, 238, 232), 0)
    put(m == HEADL, rgb(255, 250, 220), 4)
    put(m == TAILL, rgb(232, 40, 48), 4)
    put(m == AMBER, rgb(255, 170, 40), 4)
    put(m == RED, rgb(214, 36, 40), 0)
    put(m == GLASS, rgb(36, 56, 82), 1)
    put(m == WOOD, rgb(196, 142, 88), 0)
    put(m == GREEN, rgb(70, 150, 60), 0)
    put(m == SCOOP, rgb(255, 160, 196), 0)
    put(m == CHERRY, rgb(220, 24, 40), 0)
    # casquinha: trama de waffle
    w = m == WAFFLE
    ang = np.arctan2(y + 0.0, x + 22.0)
    waf = (np.sin(z * 0.9 + ang * 7) > 0.75) | (np.sin(z * 0.9 - ang * 7) > 0.75)
    put(w, rgb(222, 164, 92), 0)
    cor[w & waf] = rgb(176, 112, 56)
    # sorvete: gotinhas brancas de granulado
    sc = m == SCOOP
    gr = (np.sin(x * 2.1) * np.sin(y * 2.3) * np.sin(z * 1.9)) > 0.55
    cor[sc & gr] = rgb(255, 255, 255)
    cor[sc & ((np.sin(x * 1.7 + 1) * np.sin(y * 1.9) * np.sin(z * 2.2 + 2)) > 0.6)] = rgb(120, 200, 255)

    # ---------------- pneus e calotas (giram) ----------------
    t = m == TIRE
    r_ = m == RIM
    cor[t] = rgb(36, 34, 40); luz[t] = 3
    cor[r_] = rgb(206, 208, 218); luz[r_] = 2
    if rodas:
        rc = np.array([(rx, ry, rz) for rx, ry, rz, *_ in rodas])
        idx = np.argmin((x[:, None] - rc[None, :, 0]) ** 2 + (y[:, None] - rc[None, :, 1]) ** 2, axis=1)
        wx, wz = rc[idx, 0], rc[idx, 2]
        rad = np.array([rr for _, _, _, rr, _ in rodas])[idx]
        branco = np.array([b for *_, b in rodas])[idx]
        dx, dz = x - wx, z - wz
        rr = np.sqrt(dx * dx + dz * dz)
        th = np.arctan2(dz, dx) + spin
        # banda de rodagem: sulcos que andam com o giro
        sul = t & (np.abs(ny) < 0.6) & (np.sin(th * 18) > 0.4)
        cor[sul] = rgb(22, 20, 26)
        lat = t & (np.abs(ny) >= 0.6)
        cor[lat] = rgb(48, 46, 54)
        # faixa branca do fusca
        fb = lat & branco.astype(bool) & (rr > rad * 0.66) & (rr < rad * 0.84)
        cor[fb] = rgb(236, 234, 228)
        # calota: 5 raios
        cal = r_ & (np.abs(ny) > 0.5)
        fur = cal & (np.cos(th * 5) < -0.2) & (rr > rad * 0.22) & (rr < rad * 0.5)
        cor[fur] = rgb(52, 52, 62); luz[fur] = 3
        cubo = cal & (rr < rad * 0.16)
        cor[cubo] = rgb(150, 152, 166)
        # parafusos girando
        pf = cal & (np.abs(rr - rad * 0.3) < 1.0) & (np.cos(th * 5 + math.pi) > 0.92)
        cor[pf] = rgb(110, 112, 126)

    # ---------------- cabine: vidro x teto x colunas ----------------
    c = m == CABIN
    teto = c & (nz > 0.86)
    vid = c & ~teto
    put(teto, P, 0)
    put(vid, rgb(36, 56, 82), 1)

    if nome == "sedan":
        # faixas de corrida no capô/teto/porta-malas
        topo = (m == PAINT)
        fx = topo & (nz > 0.5) & ((np.abs(y - 8) < 3) | (np.abs(y + 8) < 3))
        cor[fx] = pal["a"]
        # linhas das portas, maçanetas, vinco lateral
        lado = (m == PAINT) & (np.abs(ny) > 0.65)
        cor[lado & ((np.abs(x - 26) < 0.6) | (np.abs(x + 4) < 0.6) | (np.abs(x + 36) < 0.6)) & (z > 12) & (z < 31)] = P * 0.55
        cor[lado & (np.abs(z - 27.5) < 0.9) & ((np.abs(x - 18) < 2.5) | (np.abs(x + 12) < 2.5))] = rgb(220, 222, 230)
        cor[lado & (np.abs(z - 19) < 0.5)] = P * 0.8
        cor[lado & (z < 11)] = P * 0.78
        # linha do capô e da tampa do porta-malas
        cor[(m == PAINT) & (nz > 0.5) & ((np.abs(x - 26) < 0.6) | (np.abs(x + 44) < 0.6))] = P * 0.6
        # placa
        cor[(m == DARK) & (np.abs(y) < 7) & (np.abs(x) > 77) & (z > 10) & (z < 16)] = rgb(240, 236, 220)
    if nome == "fusca":
        # grelha do motor atrás e linha do capô da frente
        top = (m == PAINT) & (nz > 0.45)
        cor[top & (x < -46) & (x > -60) & (np.abs(y) < 9) & (np.sin(x * 1.6) > 0.3)] = P * 0.55
        cor[top & (x > 32) & (np.abs(y) < 0.7)] = P * 0.65
        cor[(m == PAINT) & (np.abs(ny) > 0.65) & (np.abs(x - 16) < 0.6) & (z > 10)] = P * 0.6
        cor[(m == PAINT) & (np.abs(ny) > 0.65) & (np.abs(z - 22) < 0.9) & (np.abs(x - 10) < 2.5)] = rgb(220, 222, 230)
        # aro cromado dos faróis
        hd = m == HEADL
        fr = hd & (nx < 0.55)
        cor[fr] = rgb(210, 214, 224); luz[fr] = 2
        # emblema
        cor[(m == PAINT) & (x > 63) & (np.abs(y) < 3) & (np.abs(z - 20) < 3)] = rgb(220, 222, 230)
    if nome == "onibus":
        p = m == PAINT
        lado = p & (np.abs(ny) > 0.6)
        frente = p & (nx > 0.6) & (x > 90)
        tras = p & (nx < -0.6)
        # janelas laterais com colunas
        jan = lado & (z > 58) & (z < 84) & (x > -112) & (x < 84) & (np.mod(x + 112, 22) > 4)
        put(jan, rgb(36, 56, 82), 1)
        # porta (lado direito, perto da frente)
        porta = lado & (y < 0) & (x > 74) & (x < 92) & (z > 16) & (z < 84)
        put(porta & (np.abs(x - 83) > 1) & ((z > 46) | (np.abs(x - 83) > 4)), rgb(40, 60, 86), 1)
        # para-brisa e vidro traseiro
        put(frente & (z > 56) & (z < 86) & (np.abs(y) < 33) & (np.abs(y) > 1.2), rgb(36, 56, 82), 1)
        put(tras & (z > 58) & (z < 84) & (np.abs(y) < 14), rgb(36, 56, 82), 1)
        # faixas pretas
        fx = (lado | tras) & ((np.abs(z - 52) < 1.4) | (np.abs(z - 44) < 1.1) | (np.abs(z - 30) < 1.1))
        put(fx, rgb(28, 26, 30), 3)
        # teto branco
        put(p & (nz > 0.8) & (z > 88), rgb(246, 212, 116), 0)
        put(p & (nz > 0.8) & (z > 88) & ((np.abs(y) > 33) | (x > 92) | (x < -116)), rgb(30, 28, 32), 3)
        # letreiro ESCOLAR (faixa preta com "letras" amarelas) na frente e atrás do teto
        let = (frente | tras) & (z > 86) & (z < 93)
        put(let, rgb(30, 28, 32), 3)
        cor[let & (np.abs(y) < 22) & (np.sin(y * 1.5) > 0.2)] = P
        # placa de PARE: aro branco
        st = m == RED
        cor[st & (np.sqrt((x - 70) ** 2 + (z - 64) ** 2) > 6.5)] = rgb(250, 250, 250)
    if nome == "van":
        p = m == PAINT
        lado = p & (np.abs(ny) > 0.6)
        # faixa rosa ondulada e bolinhas menta no baú
        onda = lado & (np.abs(z - (30 + 3 * np.sin(x * 0.18))) < 3.2)
        cor[onda] = A
        bol = lado & (x < 40) & (z > 40) & (z < 84) & ((np.mod(x, 14) - 7) ** 2 + (np.mod(z, 14) - 7) ** 2 < 6)
        cor[bol] = rgb(130, 216, 196)
        # janela de venda (lado direito) com balcão
        jv = lado & (y < 0) & (x > -50) & (x < 6) & (z > 44) & (z < 70)
        put(jv, rgb(60, 40, 52), 3)
        put(jv & (z > 60) & (np.sin(x * 0.5) > 0.6), rgb(255, 214, 120), 4)   # luzinhas lá dentro
        # toldo listrado
        tl = m == ACCENT
        cor[tl & (np.mod(x + 54, 10) < 5)] = rgb(255, 255, 255)
        # porta da cabine e letreiro no teto da cabine
        cab = p & (x > 32) & (np.abs(ny) > 0.6)
        cor[cab & (np.abs(x - 40) < 0.6) & (z > 16)] = P * 0.6
        cor[cab & (np.abs(z - 36) < 0.9) & (np.abs(x - 48) < 2.5)] = rgb(200, 202, 210)
        cor[p & (nz > 0.8) & (x > 30) & (x < 64) & (z > 60)] = A
        borda_teto = p & (nz > 0.8) & (z > 84) & ((np.abs(y) > 30) | (x < -84) | (x > 40))
        cor[borda_teto] = A
        # portas traseiras
        tr = p & (nx < -0.6)
        cor[tr & (np.abs(y) < 0.7)] = P * 0.6
        put(tr & (z > 58) & (z < 76) & (np.abs(y) > 4) & (np.abs(y) < 26), rgb(40, 60, 86), 1)
        # letreiro em cima da cabine
    return cor, luz
