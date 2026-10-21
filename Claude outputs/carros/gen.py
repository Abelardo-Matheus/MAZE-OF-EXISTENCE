"""Gerador dos carros top-down da cidade (Maze of Existence).

Pixel art desenhada em baixa resolução e ampliada 3x (mesma escala das casas da cidade).
Vista de cima levemente inclinada (3/4): o teto/capô aparecem de cima e o lado virado
para o sul (para baixo na tela) aparece numa faixa embaixo, com as rodas.

Cada veículo tem 16 frames = dir * 4 + passo   (dir 0 baixo, 1 esquerda, 2 direita, 3 cima)
Animação de andar (4 passos): calota/banda da roda girando, carroceria balançando 1px,
fumacinha saindo do escapamento.

Uso:  python gen.py            -> imprime as medidas
      (prev.py monta as prévias, inject.py grava nos sprites do projeto)
"""
import math
from PIL import Image

ESC = 3
OUT = (34, 24, 38)          # contorno
FRAMES = 4
BOB = [0, 0, -1, 0]         # balanço da carroceria por passo
PUFF_D = [1, 3, 5, 7]       # distância da fumaça (px baixa res.)
PUFF_R = [1, 2, 2, 1]
PUFF_A = [200, 160, 110, 55]


def ramp(c, k=0.24):
    """3 tons (claro, base, escuro) com hue shift: luz puxa pro amarelo, sombra pro roxo"""
    hi = tuple(min(255, int(v + (255 - v) * k + 10)) for v in c)
    lo = tuple(max(0, int(v * (1 - k * 1.25))) for v in c)
    hi = (min(255, hi[0] + 6), min(255, hi[1] + 4), max(0, hi[2] - 4))
    lo = (max(0, lo[0] - 8), max(0, lo[1] - 4), min(255, lo[2] + 12))
    return [hi, tuple(c), lo]


VIDRO = [(196, 236, 248), (78, 128, 176), (44, 70, 112)]
FAROL = [(255, 255, 236), (255, 236, 150), (214, 170, 70)]
LANT = [(255, 132, 120), (222, 42, 46), (146, 20, 36)]
PARA = [(236, 236, 242), (176, 178, 190), (112, 114, 130)]
PNEU = [(92, 88, 102), (52, 48, 60), (28, 26, 34)]
CALOTA = [(244, 244, 248), (190, 192, 204), (122, 124, 140)]
ESCURO = [(70, 62, 78), (46, 40, 54), (30, 26, 36)]
BRANCO = [(255, 255, 255), (240, 238, 232), (206, 200, 196)]

VEICULOS = {
    # L comprimento, W largura (vista de cima), S altura da lateral, r raio da roda (px baixa res.)
    "spr_cid_carro_vermelho": dict(
        L=50, W=22, S=10, r=4, rc=4, corpo=(212, 50, 48), teto=(228, 74, 66), listra=(250, 244, 232),
        tipo="sedan",
        seg=[(0.00, 0.04, "pr"), (0.04, 0.20, "mala"), (0.20, 0.31, "vt"), (0.31, 0.57, "teto"),
             (0.57, 0.71, "pb"), (0.71, 0.96, "capo"), (0.96, 1.0, "pf")],
        rodas=[0.20, 0.79]),
    "spr_cid_fusca_azul": dict(
        L=44, W=22, S=10, r=4, rc=7, corpo=(80, 150, 220), teto=(140, 198, 244), listra=None,
        tipo="fusca",
        seg=[(0.00, 0.05, "pr"), (0.05, 0.24, "mala"), (0.24, 0.33, "vt"), (0.33, 0.58, "teto"),
             (0.58, 0.69, "pb"), (0.69, 0.95, "capo"), (0.95, 1.0, "pf")],
        rodas=[0.21, 0.77]),
    "spr_cid_onibus_escolar": dict(
        L=76, W=25, S=13, r=5, rc=3, corpo=(248, 190, 36), teto=(252, 214, 96), listra=(42, 36, 44),
        tipo="onibus",
        seg=[(0.00, 0.02, "pr"), (0.02, 0.81, "teto"), (0.81, 0.87, "pb"), (0.87, 0.98, "capo"), (0.98, 1.0, "pf")],
        rodas=[0.19, 0.79]),
    "spr_cid_sorveteria": dict(
        L=56, W=24, S=13, r=5, rc=4, corpo=(246, 242, 234), teto=(255, 218, 230), listra=(240, 118, 164),
        tipo="van",
        seg=[(0.00, 0.03, "pr"), (0.03, 0.70, "teto"), (0.70, 0.81, "pb"), (0.81, 0.97, "capo"), (0.97, 1.0, "pf")],
        rodas=[0.20, 0.80]),
}


# ---------------------------------------------------------------------------
# PLANTA (vista de cima, carro virado para a DIREITA)
#   u: 0 = traseira ... L-1 = frente     v: 0 = lado esquerdo do carro (topo da tela) ... W-1
# ---------------------------------------------------------------------------

def seg_de(sp, u):
    f = (u + 0.5) / sp["L"]
    for a, b, k in sp["seg"]:
        if a <= f < b:
            return k
    return sp["seg"][-1][2]


def seg_lim(sp, k):
    us = [u for u in range(sp["L"]) if seg_de(sp, u) == k]
    return (us[0], us[-1]) if us else (None, None)


def recuo(sp, u):
    """carroceria afina um pouco nas pontas (capô e porta-malas)"""
    f = (u + 0.5) / sp["L"]
    if sp["tipo"] in ("onibus",):
        return 0
    if f < 0.07 or f > 0.93:
        return 1
    return 0


def dentro(sp, u, v):
    L, W, rc = sp["L"], sp["W"], sp["rc"]
    if u < 0 or u >= L:
        return False
    a = recuo(sp, u)
    if v < a or v > W - 1 - a:
        return False
    cu = min(max(u, rc), L - 1 - rc)
    cv = min(max(v, rc), W - 1 - rc)
    if sp["tipo"] == "fusca":
        return ((u - cu) / (rc + 0.5)) ** 2 + ((v - cv) / (rc - 1.5)) ** 2 <= 1.0
    return (u - cu) ** 2 + (v - cv) ** 2 <= (rc + 0.45) ** 2


def planta(sp):
    """dict (u, v) -> (ramp, tom fixo ou None)"""
    L, W, tipo = sp["L"], sp["W"], sp["tipo"]
    corpo, teto = ramp(sp["corpo"]), ramp(sp["teto"], 0.18)
    lis = ramp(sp["listra"], 0.12) if sp["listra"] else None
    m = {}
    vt0, vt1 = seg_lim(sp, "vt")
    pb0, pb1 = seg_lim(sp, "pb")
    te0, te1 = seg_lim(sp, "teto")
    for u in range(L):
        for v in range(W):
            if not dentro(sp, u, v):
                continue
            k = seg_de(sp, u)
            borda = not all(dentro(sp, u + a, v + b) for a, b in ((1, 0), (-1, 0), (0, 1), (0, -1)))
            mat = (corpo, None)
            if k in ("pr", "pf"):
                mat = (PARA, None)
            elif k == "pb":
                # para-brisa em trapézio: mais estreito do lado do teto
                t = (pb1 - u) / max(1, pb1 - pb0)          # 0 na frente do vidro, 1 junto do teto
                ins = 2 + round(t * (1 if tipo != "onibus" else 0))
                if ins <= v <= W - 1 - ins:
                    mat = (VIDRO, None)
            elif k == "vt":
                t = (u - vt0) / max(1, vt1 - vt0)
                ins = 2 + round(t)
                if ins <= v <= W - 1 - ins:
                    mat = (VIDRO, None)
            elif k == "teto":
                ins = 3 if tipo in ("sedan", "fusca") else 2
                if ins <= v <= W - 1 - ins:
                    mat = (teto, None)
                    if tipo == "fusca":
                        uc, a = (te0 + te1) / 2, (te1 - te0) / 2 + 1.2
                        if ((u - uc) / a) ** 2 + ((v - (W - 1) / 2) / (W / 2 - 2.6)) ** 2 > 1:
                            mat = (corpo, None)
            if borda and k not in ("pr", "pf"):
                mat = (corpo, None)
            # vinco central no capô (luz)
            if k == "capo" and tipo in ("sedan", "fusca") and v == W // 2 and not borda:
                mat = (corpo, 0)
            # listras de corrida no sedan
            if tipo == "sedan" and k in ("capo", "teto", "mala") and v in (W // 2 - 3, W // 2 - 2, W // 2 + 1, W // 2 + 2) and not borda:
                mat = (lis, None)
            m[(u, v)] = mat

    # faróis (frente) e lanternas (trás)
    for v in list(range(2, 5)) + list(range(W - 5, W - 2)):
        for u in (L - 3, L - 2):
            if (u, v) in m and seg_de(sp, u) != "pb":
                m[(u, v)] = (FAROL, None)
        for u in (1, 2):
            if (u, v) in m:
                m[(u, v)] = (LANT, None)
    # retrovisores
    if pb0 is not None:
        ur = pb0 + 1
        m[(ur, -1)] = (corpo if tipo != "onibus" else ESCURO, None)
        m[(ur, W)] = (corpo if tipo != "onibus" else ESCURO, None)
    if tipo == "onibus":
        # escotilhas no teto + luzes de alerta âmbar/vermelhas nos cantos
        for c in (0.22, 0.52, 0.80):
            uc = int(te0 + (te1 - te0) * c)
            for du in range(-2, 3):
                for dv in range(-3, 3):
                    m[(uc + du, W // 2 + dv)] = (BRANCO, 2 if (du == 2 or dv == 2) else 1)
        for u, cor in ((te1 - 1, (255, 150, 40)), (te0 + 1, (230, 50, 40))):
            for v in (2, 3, W - 4, W - 3):
                m[(u, v)] = (ramp(cor), None)
        # faixa preta na borda do teto
        for u in range(te0, te1 + 1):
            m[(u, 1)] = (lis, None)
            m[(u, W - 2)] = (lis, None)
    if tipo == "van":
        for u in range(te0, te1 + 1):
            for v in (2, W - 3):
                m[(u, v)] = (lis, None)
        for v in range(2, W - 2):
            m[(te0, v)] = (lis, None)
            m[(te1, v)] = (lis, None)
    return m


# ---------------------------------------------------------------------------
# COMPOSIÇÃO
# ---------------------------------------------------------------------------

def grade(cw, ch):
    return [[None] * cw for _ in range(ch)]


def sombrear(ch_):
    """luz de cima/esquerda: borda de cima clara, borda de baixo/direita escura; vidro com reflexo"""
    h, w = len(ch_), len(ch_[0])
    res = grade(w, h)
    for y in range(h):
        for x in range(w):
            c = ch_[y][x]
            if c is None:
                continue
            rmp, tom = c
            if tom is not None:
                res[y][x] = rmp[tom]
                continue
            cima = ch_[y - 1][x] if y > 0 else None
            baixo = ch_[y + 1][x] if y < h - 1 else None
            esq = ch_[y][x - 1] if x > 0 else None
            dirr = ch_[y][x + 1] if x < w - 1 else None
            t = 1
            if rmp is VIDRO:
                # dois riscos de reflexo na diagonal
                q = (x - y) % 11
                t = 0 if q in (0, 1, 4) else 1
                if baixo is None or baixo[0] is not VIDRO or dirr is None or dirr[0] is not VIDRO:
                    t = 2 if t == 1 else t
                res[y][x] = rmp[t]
                continue
            if cima is None or cima[0] is not rmp or esq is None:
                t = 0
            if baixo is None or dirr is None:
                t = 2
            res[y][x] = rmp[t]
    return res


def roda_lado(rodas, cx, cy, r, f, cw, ch):
    """roda vista de lado (pneu + calota com 2 raios girando)"""
    for yy in range(cy - r, cy + r + 1):
        for xx in range(cx - r, cx + r + 1):
            dd = (xx - cx) ** 2 + (yy - cy) ** 2
            if dd <= (r + 0.35) ** 2 and 0 <= xx < cw and 0 <= yy < ch:
                rodas[yy][xx] = (PNEU, 0 if (dd >= (r - 0.6) ** 2 and yy < cy - r + 2) else (1 if dd < (r - 1) ** 2 else 2))
    rc = r - 2
    for yy in range(cy - rc, cy + rc + 1):
        for xx in range(cx - rc, cx + rc + 1):
            dd = (xx - cx) ** 2 + (yy - cy) ** 2
            if dd <= rc * rc + 0.5:
                rodas[yy][xx] = (CALOTA, 0 if (xx < cx and yy < cy) else (2 if (xx > cx and yy > cy) else 1))
    # raios: giram 45° por passo
    ang = f * math.pi / 4
    for s in (0, math.pi):
        for t in (1, rc):
            xx = cx + round(math.cos(ang + s) * t)
            yy = cy + round(math.sin(ang + s) * t)
            rodas[yy][xx] = (PNEU, 2)
    rodas[cy][cx] = (CALOTA, 0)


def desenhar_lowres(sp, d, f):
    """frame em baixa resolução + (cw, ch, oy)"""
    if d == 1:
        im, meta = desenhar_lowres(sp, 2, f)
        return im.transpose(Image.FLIP_LEFT_RIGHT), meta

    L, W, S, r, tipo = sp["L"], sp["W"], sp["S"], sp["r"], sp["tipo"]
    topo_extra = 18 if tipo == "van" else 8
    cw = L + 18
    ch = L + S + topo_extra + 8
    oy = ch - 5                        # linha do chão (origem do sprite)
    corpo = ramp(sp["corpo"])
    lis = ramp(sp["listra"], 0.12) if sp["listra"] else None
    bob = BOB[f]
    horiz = d == 2

    car = grade(cw, ch)      # carroceria (balança)
    rodas = grade(cw, ch)    # rodas (presas no chão)
    m = planta(sp)

    pw, ph = (L, W + 2) if horiz else (W + 2, L)
    x0 = (cw - pw) // 2
    base = oy - (r // 2) - 1           # última linha da carroceria (as rodas descem até o chão)
    ys = base - S + 1                  # primeira linha da faixa lateral
    y0 = ys - ph                       # topo da planta

    def put(X, Y, mat):
        Y += bob
        if 0 <= X < cw and 0 <= Y < ch:
            car[Y][X] = mat

    # ---------- planta ----------
    for (u, v), mat in m.items():
        vv = v + 1
        if horiz:
            sx, sy = u, vv
        elif d == 0:
            sx, sy = (W + 1) - vv, u
        else:
            sx, sy = vv, (L - 1) - u
        put(x0 + sx, y0 + sy, mat)

    # ---------- faixa do lado sul ----------
    if horiz:
        lado = ramp(tuple(int(c * 0.86) for c in sp["corpo"]))
        vt0, _ = seg_lim(sp, "vt")
        _, pb1 = seg_lim(sp, "pb")
        te0, te1 = seg_lim(sp, "teto")
        g0 = vt0 if vt0 is not None else te0          # janelas: do vidro traseiro ao para-brisa
        g1 = pb1 if pb1 is not None else te1
        cols = [u for u in range(L) if any((u, v) in m for v in range(W))]
        meio_b = (g0 + g1) // 2
        for u in cols:
            fr = (u + 0.5) / L
            for s in range(S):
                ponta = (u in (cols[0], cols[-1]))
                if ponta and s >= S - 2:
                    continue
                mat = (lado, None)
                jan = False
                if tipo in ("sedan", "fusca"):
                    jan = 1 <= s <= 3 and g0 + 1 <= u <= g1 - 1 and abs(u - meio_b) > 0
                    if s == 0:
                        mat = (corpo, 0)                     # linha de cintura (luz)
                    if s == 5 and g0 - 2 <= u <= g1 + 3:
                        mat = (lado, 2)                      # vinco
                    if s >= 4 and u in (meio_b, g1 + 1) :
                        mat = (lado, 2)                      # costura das portas
                    if s == 6 and u in (meio_b - 3, g1 - 2):
                        mat = (BRANCO, 1)                    # maçanetas
                elif tipo == "onibus":
                    jan = 1 <= s <= 4 and g0 + 1 <= u <= g1 and (u - g0) % 6 not in (0,)
                    if s == 0:
                        mat = (corpo, 0)
                    if s in (6, 9):
                        mat = (lis, None)
                    if s == 7 and (u - g0) % 12 == 3:
                        mat = (corpo, 0)
                elif tipo == "van":
                    jan = 1 <= s <= 4 and g1 - 6 <= u <= g1        # janela da cabine
                    if s == 0:
                        mat = (corpo, 0)
                    if 0.28 <= fr <= 0.58:                            # balcão de venda com toldo
                        if s <= 2:
                            mat = (lis if (u // 2) % 2 == 0 else BRANCO, 1 if s < 2 else 2)
                        elif 3 <= s <= 6:
                            jan = True
                        elif s == 7:
                            mat = (ramp((214, 160, 100)), 0)          # balcão
                    if s == S - 4:
                        mat = (lis, None)
                if jan:
                    mat = (VIDRO, None)
                if s == S - 1:
                    mat = (lado, 2)
                if u <= cols[0] + 1 and 2 <= s <= 4:
                    mat = (LANT, None)
                if u >= cols[-1] - 1 and 2 <= s <= 4:
                    mat = (FAROL, None)
                if (u == cols[0] or u == cols[-1]) and s >= S - 4:
                    mat = (PARA, None)
                put(x0 + u, ys + s, mat)
        # caixa de roda escura + roda por cima (roda do lado de cá aparece inteira)
        for fr in sp["rodas"]:
            cx = x0 + int(L * fr)
            cy = oy - r
            for yy in range(cy - r - 2, cy + 1):
                for xx in range(cx - r - 1, cx + r + 2):
                    if (xx - cx) ** 2 + (yy - cy) ** 2 <= (r + 1.6) ** 2 and car[yy][xx] is not None:
                        car[yy][xx] = (ESCURO, 2)
            roda_lado(rodas, cx, cy, r, f, cw, ch)
    else:
        frente = d == 0
        lado = ramp(tuple(int(c * 0.86) for c in sp["corpo"]))
        for v in range(1, pw - 1):
            for s in range(S):
                if v in (1, pw - 2) and s >= S - 2:
                    continue
                mat = (lado, None)
                cen = abs(v - (pw - 1) / 2)
                if s == 0:
                    mat = (corpo, 0)
                if frente:
                    if tipo == "onibus" and 1 <= s <= 4 and 2 <= v <= pw - 3:
                        mat = (VIDRO, None)                          # para-brisa do ônibus
                    if tipo == "van" and 1 <= s <= 3 and 3 <= v <= pw - 4:
                        mat = (VIDRO, None)
                    hl = S - 6
                    if hl <= s <= hl + 1 and (v <= 4 or v >= pw - 5):
                        mat = (FAROL, None)
                    if hl <= s <= hl + 1 and cen <= pw / 2 - 7:
                        mat = (ESCURO, 1 if v % 2 else 2)            # grade
                else:
                    if tipo == "onibus" and 1 <= s <= 5 and cen < 3:
                        mat = (VIDRO, None)                          # porta de emergência
                    if tipo == "van" and 1 <= s <= 4 and 3 <= v <= pw - 4 and cen >= 1:
                        mat = (VIDRO, None)                          # portas traseiras
                    hl = S - 6
                    if hl <= s <= hl + 1 and (v <= 3 or v >= pw - 4):
                        mat = (LANT, None)
                if lis is not None and tipo in ("onibus", "van") and s == S - 4:
                    mat = (lis, None)
                if s >= S - 2:
                    mat = (PARA, None)
                if s == S - 4 and cen <= 2 and tipo != "onibus":
                    mat = (BRANCO, 1)                                # placa
                put(x0 + v, ys + s, mat)
        # pneus: banda dos dois lados da planta + pneus embaixo nos cantos
        for fr in sp["rodas"]:
            uu = int(L * fr)
            sy = (L - 1 - uu) if d == 3 else uu
            for X in (x0 - 1, x0 + pw):
                for k in range(-r, r):
                    Y = y0 + sy + k
                    rodas[Y][X] = (PNEU, 2 if (k + f) % 2 else 0)
        for X in list(range(x0, x0 + 3)) + list(range(x0 + pw - 3, x0 + pw)):
            for Y in range(base - 1, oy + 1):
                rodas[Y][X] = (PNEU, 2 if (Y + f) % 2 else 1)

    # ---------- casquinha gigante no teto da van ----------
    if tipo == "van":
        tm = tuple(sp["teto"])
        pts = [(X, Y) for Y in range(ch) for X in range(cw) if car[Y][X] is not None and car[Y][X][0][1] == tm]
        if pts:
            cx = round(sum(p[0] for p in pts) / len(pts))
            cy = round(sum(p[1] for p in pts) / len(pts)) + 3
            casc = ramp((222, 160, 90), 0.2)
            bola = ramp((255, 150, 190), 0.2)
            for k in range(8):
                hw = k // 2
                for xx in range(cx - hw - 1, cx + hw + 1):
                    car[cy - k][xx] = (casc, 2 if (xx + k) % 3 == 0 else (0 if xx < cx - 1 else 1))
            for yy in range(cy - 15, cy - 6):
                for xx in range(cx - 6, cx + 6):
                    if (xx - cx + 0.5) ** 2 + ((yy - (cy - 10.5)) * 1.1) ** 2 <= 24:
                        car[yy][xx] = (bola, None)
            for xx in (cx - 5, cx - 2, cx + 3):
                car[cy - 7][xx] = (bola, 1)
            car[cy - 16][cx] = (LANT, 1); car[cy - 16][cx - 1] = (LANT, 0); car[cy - 15][cx] = (LANT, 2)
            car[cy - 17][cx + 1] = (ramp((70, 150, 70)), 2)

    # ---------- composição ----------
    cor = sombrear(car)
    rcor = sombrear(rodas)
    img = Image.new("RGBA", (cw, ch), (0, 0, 0, 0))
    px = img.load()

    # sombra no chão (elipse achatada embaixo do veículo)
    xs = [X for Y in range(ch) for X in range(cw) if car[Y][X] is not None]
    sx0, sx1 = min(xs), max(xs)
    sy1 = oy + 1
    sy0 = (y0 + ph // 2) if not horiz else (ys - 2)
    for Y in range(sy0, sy1 + 1):
        for X in range(sx0 - 1, sx1 + 3):
            nx = (X - (sx0 + sx1 + 2) / 2) / ((sx1 - sx0) / 2 + 2)
            ny = (Y - (sy0 + sy1) / 2) / ((sy1 - sy0) / 2 + 1)
            if nx * nx + ny * ny <= 1 and 0 <= X < cw:
                px[X, Y] = (20, 12, 30, 80)

    # fumaça do escapamento
    rr = PUFF_R[f]
    if d == 2:
        fx, fy = x0 - PUFF_D[f] - 1, oy - 3 - (PUFF_D[f] // 3)
    elif d == 0:
        fx, fy = x0 + 4 - PUFF_D[f] // 3, y0 - PUFF_D[f] + bob
    else:  # d == 3: sai pra baixo, na frente do jogador
        fx, fy = x0 + 3 - PUFF_D[f] // 2, oy - 1 + min(PUFF_D[f] // 2, 2)
    for yy in range(fy - rr, fy + rr + 1):
        for xx in range(fx - rr, fx + rr + 1):
            if (xx - fx) ** 2 + (yy - fy) ** 2 <= rr * rr + 0.6 and 0 <= xx < cw and 0 <= yy < ch:
                px[xx, yy] = (232, 228, 236, PUFF_A[f]) if (yy < fy or xx < fx) else (186, 182, 198, PUFF_A[f])

    camada = grade(cw, ch)
    for Y in range(ch):
        for X in range(cw):
            if horiz:
                c = rcor[Y][X] if rodas[Y][X] is not None else cor[Y][X]       # roda na frente
            else:
                c = cor[Y][X] if car[Y][X] is not None else rcor[Y][X]         # carroceria na frente
            camada[Y][X] = c
    for Y in range(ch):
        for X in range(cw):
            if camada[Y][X] is not None:
                continue
            if any(0 <= a < cw and 0 <= b < ch and camada[b][a] is not None
                   for a, b in ((X + 1, Y), (X - 1, Y), (X, Y + 1), (X, Y - 1))):
                px[X, Y] = OUT + (255,)
    for Y in range(ch):
        for X in range(cw):
            if camada[Y][X] is not None:
                px[X, Y] = camada[Y][X] + (255,)
    return img, (cw, ch, oy)


def gerar(nome):
    """16 frames já em 3x + medidas para o .yy"""
    sp = VEICULOS[nome]
    frames = []
    for d in range(4):
        for f in range(FRAMES):
            im, (cw, ch, oy) = desenhar_lowres(sp, d, f)
            frames.append(im.resize((cw * ESC, ch * ESC), Image.NEAREST))
    cw, ch, oy = desenhar_lowres(sp, 0, 0)[1]
    L, W, S = sp["L"], sp["W"], sp["S"]
    meta = dict(
        w=cw * ESC, h=ch * ESC, xo=(cw // 2) * ESC, yo=oy * ESC,
        meio=L * ESC // 2,                 # meio comprimento visto de lado (px)
        comp=(L + S) * ESC,                # comprimento visto de cima (subindo/descendo)
        larg=(W + 2) * ESC,
        alto_h=(sp["r"] // 2 + S + W + 2) * ESC,   # altura na tela andando de lado
        alto_v=(sp["r"] // 2 + S + L) * ESC,       # altura na tela subindo/descendo
    )
    return frames, meta


if __name__ == "__main__":
    for nome in VEICULOS:
        print(nome, gerar(nome)[1])
