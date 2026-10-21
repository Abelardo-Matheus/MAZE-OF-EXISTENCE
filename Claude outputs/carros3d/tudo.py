"""Gera os 64 frames, folhas de prévia e mede o que o obj_carro_cidade precisa."""
import math, os, pickle
import numpy as np
from PIL import Image, ImageDraw
import gerar as G
os.makedirs('saida', exist_ok=True)
res = {}
for nome, (fn, tipo, L, W, H, esc) in G.MODELOS.items():
    frames, meta = G.gerar(nome)
    ct = math.cos(G.TILT)
    def topo(im):
        a = np.array(im)[..., 3]
        rows = np.where((a > 200).any(axis=1))[0]
        return meta['yo'] - rows.min()
    meta.update(meio=int(round(L / 2)), comp=int(round(L * ct)), larg=int(round(W * ct)),
                alto_h=int(max(topo(frames[i]) for i in range(4, 12))),
                alto_v=int(max(topo(frames[i]) for i in list(range(0, 4)) + list(range(12, 16)))))
    res[nome] = (frames, meta)
    strip = Image.new('RGBA', (meta['w'] * 16, meta['h']))
    for i, f in enumerate(frames): strip.paste(f, (i * meta['w'], 0))
    strip.save(f'saida/{nome}_strip16.png')
    print(nome, meta, flush=True)
pickle.dump({k: ([f.tobytes() for f in v[0]], v[1]) for k, v in res.items()}, open('saida/frames.pkl', 'wb'))
# folha geral
cw = max(m['w'] for f, m in res.values()); chh = max(m['h'] for f, m in res.values())
folha = Image.new('RGBA', (cw * 16, chh * 4))
for j, (n, (fr, m)) in enumerate(res.items()):
    for i, f in enumerate(fr):
        folha.alpha_composite(f, (i * cw + (cw - m['w']) // 2, j * chh + (chh - m['h'])))
folha.save('saida/carros_topdown_3d_sheet.png')
# prévia: rua com os 4 andando (direita) e uma fila (baixo)
quadros = []
for p in range(8):
    q = Image.new('RGBA', (1300, 560), (84, 86, 96, 255))
    d = ImageDraw.Draw(q)
    d.rectangle([0, 0, 1300, 70], fill=(170, 166, 156, 255)); d.rectangle([0, 330, 1300, 560], fill=(170, 166, 156, 255))
    for k in range(0, 1300, 70): d.rectangle([k + (p * 4) % 70 * 0, 196, k + 36, 202], fill=(236, 232, 214, 255))
    x = 20
    for n, (fr, m) in res.items():
        f = fr[8 + p % 4]
        q.alpha_composite(f, (x - m['xo'] + m['w'] // 2 - m['w'] // 2, 190 - m['yo']))
        x += m['meio'] * 2 + 40
    quadros.append(q.convert('RGB'))
quadros[0].save('saida/previa_andando.gif', save_all=True, append_images=quadros[1:], duration=110, loop=0)
# prévia estática 4 direções
lin = []
for n, (fr, m) in res.items():
    im = Image.new('RGBA', (m['w'] * 4, m['h']), (84, 86, 96, 255))
    for i, k in enumerate((0, 4, 8, 12)): im.alpha_composite(fr[k], (i * m['w'], 0))
    lin.append(im)
W = max(i.width for i in lin); H = sum(i.height for i in lin)
pv = Image.new('RGBA', (W, H), (84, 86, 96, 255)); y = 0
for i in lin: pv.alpha_composite(i, (0, y)); y += i.height
pv.convert('RGB').save('saida/previa_direcoes.png')
