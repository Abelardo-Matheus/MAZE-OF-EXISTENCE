"""Raymarcher de SDF (numba) para renderizar os veículos em 3D vistos de cima.

A cena é uma lista de primitivas (linhas de um array float64):
  col 0 tipo, 1 material, 2 op, 3 k, 4-6 c, 7-9 a, 10 r, 11 bob(0/1),
  12-23: até 3 planos de corte (nx, ny, nz, off)  -> d = max(d, dot(p, n) - off)  (n = 0 -> sem plano)
tipos: 0 caixa arredondada | 1 elipsoide | 2 cilindro eixo Y | 3 cápsula | 4 esfera
       5 cone vertical (ponta pra baixo) | 6 cilindro eixo Z | 7 cilindro eixo X
op: 0 união | 1 união suave (k) | 2 subtração suave (k)
"""
import math
import numpy as np
from numba import njit, prange

NCOL = 28


@njit(cache=True, fastmath=True)
def _len3(x, y, z):
    return math.sqrt(x * x + y * y + z * z)


@njit(cache=True, fastmath=True)
def prim_d(P, i, px, py, pz, bob):
    t = int(P[i, 0])
    cx, cy, cz = P[i, 4], P[i, 5], P[i, 6]
    if P[i, 11] > 0.5:
        cz += bob
    x, y, z = px - cx, py - cy, pz - cz
    a0, a1, a2, r = P[i, 7], P[i, 8], P[i, 9], P[i, 10]
    if t == 0:
        qx = abs(x) - a0 + r
        qy = abs(y) - a1 + r
        qz = abs(z) - a2 + r
        d = _len3(max(qx, 0.0), max(qy, 0.0), max(qz, 0.0)) + min(max(qx, max(qy, qz)), 0.0) - r
    elif t == 1:
        k0 = _len3(x / a0, y / a1, z / a2)
        k1 = _len3(x / (a0 * a0), y / (a1 * a1), z / (a2 * a2))
        d = k0 * (k0 - 1.0) / max(k1, 1e-6)
    elif t == 2 or t == 6 or t == 7:
        if t == 2:
            rad = math.sqrt(x * x + z * z); ax = abs(y)
        elif t == 6:
            rad = math.sqrt(x * x + y * y); ax = abs(z)
        else:
            rad = math.sqrt(y * y + z * z); ax = abs(x)
        dx = rad - a0 + r
        dy = ax - a1 + r
        d = min(max(dx, dy), 0.0) + math.sqrt(max(dx, 0.0) ** 2 + max(dy, 0.0) ** 2) - r
    elif t == 3:
        bx, by, bz = P[i, 7] - P[i, 4], P[i, 8] - P[i, 5], P[i, 9] - P[i, 6]
        hh = (x * bx + y * by + z * bz) / max(bx * bx + by * by + bz * bz, 1e-9)
        hh = min(max(hh, 0.0), 1.0)
        d = _len3(x - bx * hh, y - by * hh, z - bz * hh) - r
    elif t == 4:
        d = _len3(x, y, z) - r
    else:  # cone: ponta em c, abre para cima até altura a0 com raio a1
        q = math.sqrt(x * x + y * y)
        h = a0
        rr = a1
        # cone (ponta embaixo) limitado entre z=0 e z=h
        ang = math.atan2(rr, h)
        s, c = math.sin(ang), math.cos(ang)
        dside = q * c - z * s
        d = max(dside, max(-z, z - h))
    # planos de corte
    for j in range(4):
        o = 12 + j * 4
        nx, ny, nz = P[i, o], P[i, o + 1], P[i, o + 2]
        if nx != 0.0 or ny != 0.0 or nz != 0.0:
            d = max(d, x * nx + y * ny + z * nz - P[i, o + 3])
    return d


@njit(cache=True, fastmath=True)
def scene(P, px, py, pz, bob):
    d = 1e9
    mat = 0.0
    for i in range(P.shape[0]):
        di = prim_d(P, i, px, py, pz, bob)
        op = int(P[i, 2])
        k = P[i, 3]
        if op == 0:
            if di < d:
                d = di
                mat = P[i, 1]
        elif op == 1:
            h = min(max(0.5 + 0.5 * (d - di) / k, 0.0), 1.0)
            nd = d * (1 - h) + di * h - k * h * (1 - h)
            if di < d:
                mat = P[i, 1]
            d = nd
        else:
            h = min(max(0.5 - 0.5 * (d + di) / k, 0.0), 1.0)
            d = d * (1 - h) + (-di) * h + k * h * (1 - h)
    return d, mat


@njit(cache=True, fastmath=True)
def sdf(P, x, y, z, bob):
    return scene(P, x, y, z, bob)[0]


@njit(parallel=True, cache=True, fastmath=True)
def render(P, W, H, SS, ox, oy, tilt, yaw, offy, bob, Lx, Ly, Lz):
    """devolve buffers (H*SS, W*SS): tipo (0 nada, 1 carro, 2 chão), mat, pos modelo (3), normal modelo (3),
    normal mundo (3), sombra, ao"""
    HH, WW = H * SS, W * SS
    kind = np.zeros((HH, WW), np.int32)
    mat = np.zeros((HH, WW), np.float32)
    pos = np.zeros((HH, WW, 3), np.float32)
    nrm = np.zeros((HH, WW, 3), np.float32)
    nrw = np.zeros((HH, WW, 3), np.float32)
    sha = np.ones((HH, WW), np.float32)
    aoo = np.ones((HH, WW), np.float32)
    st, ct = math.sin(tilt), math.cos(tilt)
    fx, fy, fz = 0.0, st, -ct          # direção da câmera
    ux, uy, uz = 0.0, ct, st           # "cima" da tela
    cyw, syw = math.cos(yaw), math.sin(yaw)
    for j in prange(HH):
        for i in range(WW):
            u = (i + 0.5) / SS - ox
            v = oy - (j + 0.5) / SS
            # origem do raio bem acima/atrás
            Ox = u
            Oy = v * uy - fy * 600.0
            Oz = v * uz - fz * 600.0
            tt = 0.0
            hit = 0
            for _ in range(260):
                wx, wy, wz = Ox + fx * tt, Oy + fy * tt, Oz + fz * tt
                if wz < -2.0:
                    break
                mx = cyw * wx + syw * (wy - offy)
                my = -syw * wx + cyw * (wy - offy)
                d = sdf(P, mx, my, wz, bob)
                dg = wz
                if dg < d and dg < 0.02:
                    hit = 2
                    break
                if d < 0.015:
                    hit = 1
                    break
                tt += max(min(d, dg), 0.02) * 0.9
                if tt > 1400.0:
                    break
            if hit == 0:
                continue
            wx, wy, wz = Ox + fx * tt, Oy + fy * tt, Oz + fz * tt
            mx = cyw * wx + syw * (wy - offy)
            my = -syw * wx + cyw * (wy - offy)
            kind[j, i] = hit
            if hit == 1:
                dd, mm = scene(P, mx, my, wz, bob)
                mat[j, i] = mm
                e = 0.05
                nx = sdf(P, mx + e, my, wz, bob) - sdf(P, mx - e, my, wz, bob)
                ny = sdf(P, mx, my + e, wz, bob) - sdf(P, mx, my - e, wz, bob)
                nz = sdf(P, mx, my, wz + e, bob) - sdf(P, mx, my, wz - e, bob)
                ln = _len3(nx, ny, nz) + 1e-9
                nx /= ln; ny /= ln; nz /= ln
                pos[j, i, 0] = mx; pos[j, i, 1] = my; pos[j, i, 2] = wz
                nrm[j, i, 0] = nx; nrm[j, i, 1] = ny; nrm[j, i, 2] = nz
                # normal no mundo
                nrw[j, i, 0] = cyw * nx - syw * ny
                nrw[j, i, 1] = syw * nx + cyw * ny
                nrw[j, i, 2] = nz
                # AO
                ao = 0.0
                sc = 1.0
                for k in range(1, 6):
                    h = 1.2 * k
                    dk = sdf(P, mx + nx * h, my + ny * h, wz + nz * h, bob)
                    ao += (h - dk) * sc
                    sc *= 0.6
                aoo[j, i] = max(0.0, min(1.0, 1.0 - 0.09 * ao))
                sx, sy, sz = mx + nx * 0.3, my + ny * 0.3, wz + nz * 0.3
            else:
                sx, sy, sz = mx, my, 0.05
                # contato com o chão (oclusão)
                dk = sdf(P, mx, my, 1.5, bob)
                aoo[j, i] = max(0.0, min(1.0, 0.35 + dk / 9.0))
            # sombra suave na direção da luz (luz em coordenadas do modelo)
            lmx = cyw * Lx + syw * Ly
            lmy = -syw * Lx + cyw * Ly
            res = 1.0
            ts = 0.4
            for _ in range(70):
                dk = sdf(P, sx + lmx * ts, sy + lmy * ts, sz + Lz * ts, bob)
                if dk < 0.01:
                    res = 0.0
                    break
                res = min(res, 9.0 * dk / ts)
                ts += max(dk, 0.3)
                if ts > 260.0:
                    break
            sha[j, i] = max(0.0, res)
    return kind, mat, pos, nrm, nrw, sha, aoo
