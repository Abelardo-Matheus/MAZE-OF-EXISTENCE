"""Engine v2 de pixel art: rampas com hue-shift, sombreamento volumétrico com dithering,
oclusão ambiente, contorno selout (colorido) e texturas."""
import colorsys, math
import numpy as np
from PIL import Image, ImageDraw
from scipy import ndimage

W, H = 49, 53
DARK = np.array([22, 14, 30], dtype=float)          # quase-preto arroxeado do contorno
BAYER = np.array([[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]) / 16.0
LIGHT = np.array([-0.62, -0.72, 0.62])              # luz vindo de cima-esquerda
LIGHT = LIGHT / np.linalg.norm(LIGHT)


def hx(c):
    if isinstance(c, str):
        c = c.lstrip('#'); return tuple(int(c[i:i + 2], 16) for i in (0, 2, 4))
    return tuple(c[:3])


WHITE = [(70, 72, 112), (112, 116, 162), (152, 157, 202), (192, 196, 230), (224, 227, 246), (250, 250, 255)]

def ramp(base, n=6, spread=1.0):
    """Rampa escuro->claro com hue shifting (sombra puxa p/ azul-roxo, luz p/ amarelo)."""
    r, g, b = [v / 255 for v in hx(base)]
    h, l, s = colorsys.rgb_to_hls(r, g, b)
    if n == 6 and (l > 0.9 or (l > 0.8 and s < 0.35)):   # brancos: rampa fria e pouco saturada, tingida pela cor base
        bc = np.array(hx(base), float)
        return [tuple(int(v) for v in np.array(w, float) * 0.8 + bc * 0.2 * (np.array(w).sum() / 765)) for w in WHITE]
    out = []
    mid = (n - 1) * 0.62                              # base fica um pouco acima do meio
    for i in range(n):
        k = (i - mid) / (n - 1) * spread               # -0.6 .. +0.4
        if k < 0:
            tgt = 0.70 if (h > 0.2 and h < 0.7) else 0.78   # azulado/roxo
            dh = ((tgt - h + 0.5) % 1 - 0.5) * (-k) * 0.22
            ll = l + k * l * 1.25
            ss = min(1, s + (-k) * 0.15)
        else:
            tgt = 0.13
            dh = ((tgt - h + 0.5) % 1 - 0.5) * k * 0.30
            ll = l + k * (1 - l) * 1.05
            ss = s * (1 - k * 0.35)
        rr, gg, bb = colorsys.hls_to_rgb((h + dh) % 1, max(0.03, min(0.97, ll)), max(0, min(1, ss)))
        out.append((int(rr * 255), int(gg * 255), int(bb * 255)))
    return out


def gray_ramp(base, n=6):
    return ramp(base, n)


class Art:
    def __init__(self):
        self.c = np.zeros((H, W, 3), dtype=float)
        self.al = np.zeros((H, W), dtype=bool)
        self.yy, self.xx = np.mgrid[0:H, 0:W]
        self.sub = 4  # supersampling dos polígonos

    # ---------------- máscaras ----------------
    def _m(self, fn):
        s = self.sub
        im = Image.new('L', (W * s, H * s), 0)
        fn(ImageDraw.Draw(im), s)
        im = im.resize((W, H), Image.BOX)
        return np.array(im) > 110

    def ellipse(self, cx, cy, rx, ry):
        return self._m(lambda d, s: d.ellipse([(cx - rx) * s, (cy - ry) * s, (cx + rx + 1) * s, (cy + ry + 1) * s], fill=255))

    def circle(self, cx, cy, r):
        return self.ellipse(cx, cy, r, r)

    def rect(self, x0, y0, x1, y1):
        m = np.zeros((H, W), bool)
        m[max(0, int(y0)):int(y1) + 1, max(0, int(x0)):int(x1) + 1] = True
        return m

    def rrect(self, x0, y0, x1, y1, r):
        return self._m(lambda d, s: d.rounded_rectangle([x0 * s, y0 * s, (x1 + 1) * s, (y1 + 1) * s], r * s, fill=255))

    def poly(self, pts):
        return self._m(lambda d, s: d.polygon([((x + .5) * s, (y + .5) * s) for x, y in pts], fill=255))

    def line(self, pts, w=1.0):
        return self._m(lambda d, s: d.line([((x + .5) * s, (y + .5) * s) for x, y in pts], fill=255, width=max(1, int(w * s)), joint='curve'))

    def pie(self, cx, cy, r, a0, a1):
        return self._m(lambda d, s: d.pieslice([(cx - r) * s, (cy - r) * s, (cx + r + 1) * s, (cy + r + 1) * s], a0, a1, fill=255))

    def capsule(self, p0, p1, r):
        """Bastão de raio r entre dois pontos (cabos, gravetos)."""
        m = self.line([p0, p1], r * 2)
        return m | self.circle(p0[0], p0[1], r - .3) | self.circle(p1[0], p1[1], r - .3)

    def beam(self, p0, p1, w0, w1=None):
        """Faixa reta com largura variável (lâminas)."""
        w1 = w0 if w1 is None else w1
        dx, dy = p1[0] - p0[0], p1[1] - p0[1]
        L = math.hypot(dx, dy); nx, ny = -dy / L, dx / L
        return self.poly([(p0[0] + nx * w0, p0[1] + ny * w0), (p1[0] + nx * w1, p1[1] + ny * w1),
                          (p1[0] - nx * w1, p1[1] - ny * w1), (p0[0] - nx * w0, p0[1] - ny * w0)])

    # ---------------- pintura ----------------
    def _shade_field(self, m, shape, bulge, light):
        if shape == 'flat':
            ys, xs = np.nonzero(m)
            if len(xs) == 0: return np.zeros((H, W))
            p = (self.xx - xs.mean()) * light[0] + (self.yy - ys.mean()) * light[1]
            rng = max(1, np.abs(p[m]).max())
            t = 0.55 - 0.22 * p / rng
            return t
        d = ndimage.distance_transform_edt(np.pad(m, 1))[1:-1, 1:-1]
        dm = max(1.0, d[m].max())
        u = np.clip(d / dm, 0, 1)
        h = np.sqrt(np.clip(1 - (1 - u) ** 2, 0, 1)) * dm * bulge
        gy, gx = np.gradient(ndimage.gaussian_filter(h, 0.8))
        n = np.dstack([-gx, -gy, np.ones_like(h)])
        n /= np.linalg.norm(n, axis=2, keepdims=True)
        L = np.array([light[0], light[1], LIGHT[2]]); L /= np.linalg.norm(L)
        t = np.clip((n @ L) * 0.5 + 0.5, 0, 1)
        # realce: estica o contraste
        t = np.clip((t - 0.30) / 0.62, 0, 1) ** 1.35
        return t

    def part(self, m, base, shape='round', bulge=1.0, n=6, dither=0.42, ao=True, spec=False,
             light=None, lo=0, hi=None, edge=None, ramp_=None, keep=None):
        """Pinta uma parte com volume. lo/hi limitam os índices da rampa usados."""
        if not m.any(): return m
        R = ramp_ or ramp(base, n)
        hi = len(R) - 2 if hi is None else hi
        light = LIGHT if light is None else light
        if ao:
            sh = np.zeros_like(m); sh[1:, 1:] = m[:-1, :-1]
            sh2 = np.zeros_like(m); sh2[2:, 1:] = m[:-2, :-1]
            occ = (sh | sh2) & ~m & self.al
            self.c[occ] = self.c[occ] * 0.72 + DARK * 0.10
        t = self._shade_field(m, shape, bulge, light)
        thr = BAYER[self.yy % 4, self.xx % 4]
        idx = lo + t * (hi - lo) + (thr - 0.5) * dither
        idx = np.clip(np.round(idx), lo, hi).astype(int)
        cols = np.array(R, dtype=float)
        tgt = m if keep is None else (m & keep)
        self.c[tgt] = cols[idx[tgt]]
        self.al |= tgt
        if spec:
            k = tgt & (t > 0.86)
            self.c[k] = cols[-1]
            k2 = tgt & (t > 0.97)
            self.c[k2] = np.minimum(255, cols[-1] * 0.4 + 255 * 0.6)
        if edge is not None and edge is not False:
            self.inner_edge(m, R[0] if edge is True else hx(edge))
        return m

    def flat(self, m, col):
        self.c[m] = hx(col); self.al |= m
        return m

    def inner_edge(self, m, col=None, sides='all'):
        """Linha interna onde a parte encosta em outra coisa (sel-out escuro)."""
        col = np.array(hx(col) if col is not None else (40, 26, 40), dtype=float)
        up = np.zeros_like(m); up[1:] = m[:-1]
        dn = np.zeros_like(m); dn[:-1] = m[1:]
        lf = np.zeros_like(m); lf[:, 1:] = m[:, :-1]
        rt = np.zeros_like(m); rt[:, :-1] = m[:, 1:]
        if sides == 'all': e = m & ~(up & dn & lf & rt)
        elif sides == 'br': e = m & ~(dn & rt)
        else: e = m & ~(up & lf)
        self.c[e] = col
        return e

    def tex_noise(self, m, amt=0.12, seed=1, density=0.25):
        rng = np.random.default_rng(seed)
        r = rng.random((H, W))
        k = m & (r < density)
        f = 1 + (rng.random((H, W)) - 0.5) * 2 * amt
        self.c[k] = np.clip(self.c[k] * f[k][:, None], 0, 255)

    def tint(self, m, col, a=0.5):
        self.c[m] = self.c[m] * (1 - a) + np.array(hx(col)) * a

    def darken(self, m, f=0.75):
        self.c[m] = self.c[m] * f + DARK * (1 - f) * 0.4

    def lighten(self, m, f=0.3):
        self.c[m] = self.c[m] * (1 - f) + 255 * f

    def px(self, x, y, col, a=1.0):
        if 0 <= x < W and 0 <= y < H:
            x, y = int(x), int(y)
            self.c[y, x] = self.c[y, x] * (1 - a) + np.array(hx(col)) * a if self.al[y, x] or a >= 1 else np.array(hx(col))
            self.al[y, x] = True

    def pxs(self, pts, col, a=1.0):
        for x, y in pts: self.px(x, y, col, a)

    def sparkle(self, x, y, col='#fffbe0', size=2):
        pts = [(x, y)] + [(x + i, y) for i in range(-size, size + 1) if i] + [(x, y + i) for i in range(-size, size + 1) if i]
        self.pxs(pts, col)

    def erase(self, m):
        self.al &= ~m

    def ground_shadow(self, cx, cy, rx, ry=None):
        pass  # itens de inventário não usam sombra no chão

    # ---------------- final ----------------
    def img(self, outline=True):
        c = self.c.copy(); al = self.al.copy()
        if outline:
            g = np.zeros_like(al)
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                g |= np.roll(np.roll(al, dy, 0), dx, 1)
            o = g & ~al
            # cor do contorno = vizinho mais escuro, bem escurecido (selout)
            nb = np.zeros((H, W, 3)); cnt = np.zeros((H, W))
            lum = c.sum(2)
            best = np.full((H, W), 1e9)
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                sc = np.roll(np.roll(c, dy, 0), dx, 1); sa = np.roll(np.roll(al, dy, 0), dx, 1)
                sl = np.roll(np.roll(lum, dy, 0), dx, 1)
                k = sa & (sl < best)
                nb[k] = sc[k]; best[k] = sl[k]
            # lados de baixo/direita do objeto = contorno mais escuro (luz de cima-esq.)
            below = np.roll(al, -1, 0) | np.roll(al, -1, 1)   # pixel de contorno cujo objeto está acima/esq?
            above = np.roll(al, 1, 0) | np.roll(al, 1, 1)
            dark_side = o & above & ~below
            col_o = nb * 0.28 + DARK * 0.72
            col_o[dark_side] = DARK
            c[o] = col_o[o]
            al = al | o
        out = np.zeros((H, W, 4), np.uint8)
        out[..., :3] = np.clip(c, 0, 255).astype(np.uint8)
        out[..., 3] = al * 255
        return Image.fromarray(out, 'RGBA')


def star_pts(cx, cy, r1, r2, n=5, rot=-90):
    return [(cx + (r1 if i % 2 == 0 else r2) * math.cos(math.radians(rot + i * 180 / n)),
             cy + (r1 if i % 2 == 0 else r2) * math.sin(math.radians(rot + i * 180 / n))) for i in range(n * 2)]
