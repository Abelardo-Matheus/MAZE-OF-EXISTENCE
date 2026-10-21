"""Grava os 16 frames renderizados (saida/frames.pkl) nos sprites spr_cid_* do projeto.
Reaproveita os UUIDs de frame do .yy atual e atualiza tamanho/origem/bbox."""
import os, re, sys, uuid, pickle
from PIL import Image
SRC, DST = sys.argv[1], sys.argv[2]
dados = pickle.load(open('saida/frames.pkl', 'rb'))
for nome, (fb, m) in dados.items():
    frames = [Image.frombytes('RGBA', (m['w'], m['h']), b) for b in fb]
    yy = open(f'{SRC}/{nome}/{nome}.yy', encoding='utf-8').read()
    nl = '\r\n' if '\r\n' in yy else '\n'
    yy = yy.replace('\r\n', '\n')
    ids = re.findall(r'\{"resourceType":"GMSpriteFrame","resourceVersion":"1\.1","name":"([0-9a-f-]+)",\},', yy)
    camada = re.search(r'"layers": \[\s*\{"resourceType":"GMImageLayer","resourceVersion":"1\.0","name":"([0-9a-f-]+)"', yy).group(1)
    assert len(ids) == 16, (nome, len(ids))
    os.makedirs(f'{DST}/{nome}', exist_ok=True)
    for i, f in enumerate(frames):
        f.save(f'{DST}/{nome}/{ids[i]}.png')
        os.makedirs(f'{DST}/{nome}/layers/{ids[i]}', exist_ok=True)
        f.save(f'{DST}/{nome}/layers/{ids[i]}/{camada}.png')
    xo, yo = m['xo'], m['yo']
    rep = {'width': m['w'], 'height': m['h'], 'xorigin': xo, 'yorigin': yo,
           'bbox_left': xo - m['meio'] // 2, 'bbox_right': xo + m['meio'] // 2,
           'bbox_top': yo - 36, 'bbox_bottom': yo}
    for k, v in rep.items():
        yy, n = re.subn(rf'"{k}": -?\d+,', f'"{k}": {v},', yy)
        assert n >= 1, (nome, k)
    open(f'{DST}/{nome}/{nome}.yy', 'w', encoding='utf-8', newline='').write(yy.replace('\n', nl))
    print(nome, m)
