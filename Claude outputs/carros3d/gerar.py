"""Renderiza os 4 veículos (16 frames cada: dir*4 + passo) vistos de cima em 3D.

dir: 0 baixo, 1 esquerda, 2 direita, 3 cima.  Câmera ortográfica inclinada TILT graus da vertical
(vê o teto e um pouco da lateral que fica virada pra baixo da tela).
Origem do sprite = ponto do chão na borda de baixo (sul) do veículo, no meio.
"""
import math
import sys
import numpy as np
from PIL import Image
from rm import render
import veiculos as V

TILT = math.radians(34)
SS = 3
LUZ = np.array([-0.38, 0.40, 0.83]); LUZ /= np.linalg.norm(LUZ)
VIEW = np.array([0.0, -math.sin(TILT), math.cos(TILT)])
BOB = [0.0, 0.8, 1.3, 0.8]                 # carroceria sobe/desce
YAW = {0: -math.pi / 2, 1: math.pi, 2: 0.0, 3: math.pi / 2}
OUT = np.array([26, 20, 34], float)

MODELOS = {
    # nome do sprite: (função, comprimento, largura, altura máx, escapamento (x, y, z))
    "spr_cid_carro_vermelho": (V.sedan,  "sedan",  160, 72, 64,  (-82, -17, 9)),
    "spr_cid_fusca_azul":     (V.fusca,  "fusca",  142, 66, 52,  (-73, -12, 9)),
    "spr_cid_onibus_escolar": (V.onibus, "onibus", 252, 90, 100, (-128, -20, 10)),
    "spr_cid_sorveteria":     (V.van,    "van",    186, 88, 152, (-96, -18, 9)),
}


def medidas(L, W, H):
    st, ct = math.sin(TILT), math.cos(TILT)
    cw = int(max(L, W) + 2 * (H * 0.5 + 14))
    topo = int(max(L, W) * ct + H * st + 8)
    sombra = int(H * 0.45 * ct + 10)
    ch = topo + sombra
    return cw, ch, cw // 2, topo


def sombrear(nome, kind, mat, pos, nrm, nrw, sha, ao, spin, rodas, u_scr, v_scr):
    car = kind == 1
    N = int(car.sum())
    rgba = np.zeros(kind.shape + (4,))
    if N:
        base, luz = V.decorar(nome, mat[car], pos[car], nrm[car], spin, rodas)
        n = nrw[car].astype(float)
        s = sha[car][:, None]
        a = ao[car][:, None]
        dif = np.clip(n @ LUZ, 0, 1)[:, None]
        hv = LUZ + VIEW; hv /= np.linalg.norm(hv)
        nh = np.clip(n @ hv, 0, 1)[:, None]
        nv = np.clip(n @ VIEW, 0, 1)[:, None]
        amb = (0.36 + 0.24 * n[:, 2:3]) * a
        col = np.zeros((N, 3))
        L_ = luz[:, None]
        # tinta / fosco
        brilho = np.where(L_ == 3, 0.07, 0.5)
        exp_ = np.where(L_ == 3, 12, 70)
        tinta = base * (amb + 0.74 * dif * s) + 255 * brilho * (nh ** exp_) * s + 40 * (1 - nv) ** 3
        col = tinta
        # vidro: reflexo do céu + risco de luz
        r = 2 * (n @ VIEW)[:, None] * n - VIEW
        ceu = np.array([70, 100, 140]) + (np.array([205, 232, 250]) - np.array([70, 100, 140])) * np.clip(r[:, 2:3] * 0.9, 0, 1)
        risco = ((np.sin((u_scr[car] + v_scr[car]) * 0.22) > 0.86) * 55.0)[:, None]
        vidro = base * (0.45 + 0.35 * a) + ceu * 0.42 * (0.6 + 0.4 * s) + risco + 255 * (nh ** 140) * s
        col = np.where(L_ == 1, vidro, col)
        # cromo: ambiente forte
        env = np.array([60, 62, 74]) + (np.array([245, 246, 252]) - np.array([60, 62, 74])) * np.clip(0.5 + 0.5 * r[:, 2:3] - 0.25 * r[:, 1:2], 0, 1)
        cromo = env * (0.55 + 0.45 * s) * a + 255 * (nh ** 50) * s
        col = np.where(L_ == 2, cromo, col)
        # emissivo
        emis = base * (0.9 + 0.1 * dif) + 120 * (nh ** 30)
        col = np.where(L_ == 4, emis, col)
        rgba[car, :3] = np.clip(col, 0, 255)
        rgba[car, 3] = 1.0
    chao = kind == 2
    if chao.any():
        som = (1 - sha[chao]) * 0.42 + (1 - ao[chao]) * 0.45
        rgba[chao, :3] = [16, 12, 28]
        rgba[chao, 3] = np.clip(som, 0, 0.62)
    return rgba


def reduzir(rgba, ss):
    h, w = rgba.shape[0] // ss, rgba.shape[1] // ss
    x = rgba.reshape(h, ss, w, ss, 4)
    a = x[..., 3]
    pre = (x[..., :3] * a[..., None]).sum(axis=(1, 3))
    asum = a.sum(axis=(1, 3))
    out = np.zeros((h, w, 4))
    ok = asum > 0
    out[ok, :3] = pre[ok] / asum[ok][:, None]
    out[..., 3] = asum / (ss * ss)
    return out


def fumaca(img, pts):
    """fumaça do escapamento (bolinhas macias)"""
    h, w = img.shape[:2]
    yy, xx = np.mgrid[0:h, 0:w]
    for (cx, cy, r, a) in pts:
        d = np.sqrt((xx - cx) ** 2 + (yy - cy) ** 2)
        m = np.clip((r - d) / 1.2, 0, 1) * a
        if m.max() <= 0:
            continue
        luz = np.clip(0.75 + 0.25 * (cy - yy) / max(r, 1), 0.55, 1.0)
        cor = np.stack([214 * luz + 20, 212 * luz + 18, 224 * luz + 20], -1)
        ao_ = img[..., 3]
        na = m + ao_ * (1 - m)
        img[..., :3] = np.where(na[..., None] > 0, (cor * m[..., None] + img[..., :3] * (ao_ * (1 - m))[..., None]) / np.maximum(na, 1e-6)[..., None], img[..., :3])
        img[..., 3] = na


def frame(sprite, d, f):
    fn, nome, L, W, H, esc = MODELOS[sprite]
    cena = fn()
    P = cena.array()
    cw, ch, ox, oy = medidas(L, W, H)
    offy = (W / 2) if d in (1, 2) else (L / 2)
    yaw = YAW[d]
    spin = -f * (2 * math.pi / 20)            # 1 sulco do pneu / 1/4 de raio por passo
    if d == 1:
        spin = -spin
    out = render(P, cw, ch, SS, float(ox), float(oy), TILT, yaw, offy, BOB[f],
                 float(LUZ[0]), float(LUZ[1]), float(LUZ[2]))
    kind, mat, pos, nrm, nrw, sha, ao = out
    jj, ii = np.mgrid[0:ch * SS, 0:cw * SS]
    u_scr, v_scr = ii / SS, jj / SS
    hi = sombrear(nome, kind, mat, pos, nrm, nrw, sha, ao, spin if d != 1 else -spin, cena.rodas, u_scr, v_scr)
    # só o carro (sem sombra) para o contorno
    so_carro = (kind == 1).astype(float)
    img = reduzir(hi, SS)
    mc = so_carro.reshape(ch, SS, cw, SS).mean(axis=(1, 3))

    # fumaça atrás do escapamento (desenhada antes do carro: passa por trás)
    ex, ey, ez = esc
    cy_, sy_ = math.cos(yaw), math.sin(yaw)
    pts = []
    for k, (dist, r, a) in enumerate([(3, 2.2, 0.75), (9, 3.2, 0.6), (16, 4.2, 0.4), (24, 5.0, 0.18)]):
        kk = (k + f) % 4                       # a fumaça vai andando pra trás a cada passo
        dist, r, a = [(3, 2.2, 0.75), (9, 3.2, 0.6), (16, 4.2, 0.4), (24, 5.0, 0.18)][kk]
        mx, my, mz = ex - dist, ey, ez + kk * 2.0
        wx = cy_ * mx - sy_ * my
        wy = sy_ * mx + cy_ * my + offy
        u = wx
        v = wy * math.cos(TILT) + mz * math.sin(TILT)
        pts.append((ox + u, oy - v, r, a))
    camada_fum = np.zeros_like(img)
    fumaca(camada_fum, pts)
    # composição: sombra/fundo -> fumaça -> carro
    sombra = img.copy(); sombra[..., 3] = np.where(mc > 0, img[..., 3] * (1 - mc), img[..., 3])
    carro = img.copy(); carro[..., 3] = mc
    res = sombra
    for lay in (camada_fum, carro):
        a = lay[..., 3:4]
        na = a + res[..., 3:4] * (1 - a)
        res = np.concatenate([np.where(na > 0, (lay[..., :3] * a + res[..., :3] * res[..., 3:4] * (1 - a)) / np.maximum(na, 1e-6), 0), na], -1)

    # contorno escuro de 1px em volta do carro (lê melhor no chão)
    m = mc > 0.45
    viz = np.zeros_like(m)
    viz[1:] |= m[:-1]; viz[:-1] |= m[1:]; viz[:, 1:] |= m[:, :-1]; viz[:, :-1] |= m[:, 1:]
    borda = viz & ~m
    a = 0.85
    res[borda, :3] = OUT * a + res[borda, :3] * (1 - a) * res[borda, 3:4] if False else OUT
    res[borda, 3] = np.maximum(res[borda, 3], 0.85)
    # borda interna levemente escurecida (dá volume)
    dentro = m & ~(np.roll(m, 1, 0) & np.roll(m, -1, 0) & np.roll(m, 1, 1) & np.roll(m, -1, 1))
    res[dentro, :3] *= 0.82
    im = Image.fromarray(np.clip(np.round(np.concatenate([res[..., :3], res[..., 3:] * 255], -1)), 0, 255).astype(np.uint8), "RGBA")
    return im, dict(w=cw, h=ch, xo=ox, yo=oy)


def gerar(sprite):
    frames = []
    for d in range(4):
        for f in range(4):
            im, meta = frame(sprite, d, f)
            frames.append(im)
    return frames, meta


if __name__ == "__main__":
    import time
    s = sys.argv[1] if len(sys.argv) > 1 else "spr_cid_carro_vermelho"
    t = time.time()
    ims = [frame(s, d, 0)[0] for d in range(4)]
    print("tempo", time.time() - t)
    w = sum(i.width for i in ims); h = max(i.height for i in ims)
    o = Image.new("RGBA", (w, h), (92, 94, 102, 255))
    x = 0
    for i in ims:
        o.alpha_composite(i, (x, 0)); x += i.width
    o.save(f"teste_{s}.png")
