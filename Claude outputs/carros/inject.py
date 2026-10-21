"""Grava os 16 frames de cada veículo nos sprites do projeto (mesmo nome de recurso).
Reaproveita os 8 UUIDs de frame que já existem e cria 8 novos; atualiza o .yy
(tamanho, origem, bbox do pé, lista de frames e keyframes da sequência)."""
import os, re, sys, uuid
from gen import VEICULOS, gerar

SRC = sys.argv[1]   # pasta com os .yy originais (sprites/<nome>/<nome>.yy)
DST = sys.argv[2]   # saída espelhando sprites/
for nome in VEICULOS:
    fr, m = gerar(nome)
    yy = open(f'{SRC}/{nome}/{nome}.yy', encoding='utf-8').read()
    nl = '\r\n' if '\r\n' in yy else '\n'
    yy = yy.replace('\r\n', '\n')
    antigos = re.findall(r'\{"resourceType":"GMSpriteFrame","resourceVersion":"1\.1","name":"([0-9a-f-]+)",\},', yy)
    camada = re.search(r'"layers": \[\s*\{"resourceType":"GMImageLayer","resourceVersion":"1\.0","name":"([0-9a-f-]+)"', yy).group(1)
    ids = antigos[:16] + [str(uuid.uuid4()) for _ in range(16 - len(antigos[:16]))]
    os.makedirs(f'{DST}/{nome}', exist_ok=True)
    for i, f in enumerate(fr):
        f.save(f'{DST}/{nome}/{ids[i]}.png')
        os.makedirs(f'{DST}/{nome}/layers/{ids[i]}', exist_ok=True)
        f.save(f'{DST}/{nome}/layers/{ids[i]}/{camada}.png')
    # frames
    lin_fr = ''.join(f'    {{"resourceType":"GMSpriteFrame","resourceVersion":"1.1","name":"{i}",}},\n' for i in ids)
    yy = re.sub(r'("frames": \[\n)(.*?)(  \],)', lambda mm: mm.group(1) + lin_fr + mm.group(3), yy, count=1, flags=re.S)
    # keyframes
    kf = ''.join(
        f'            {{"resourceType":"Keyframe<SpriteFrameKeyframe>","resourceVersion":"1.0","Channels":{{"0":{{"resourceType":"SpriteFrameKeyframe","resourceVersion":"1.0","Id":{{"name":"{fid}","path":"sprites/{nome}/{nome}.yy",}},}},}},"Disabled":false,"id":"{uuid.uuid4()}","IsCreationKey":false,"Key":{k}.0,"Length":1.0,"Stretch":false,}},\n'
        for k, fid in enumerate(ids))
    yy = re.sub(r'("Keyframes":\[\n)(.*?)(          \],\},"modifiers")', lambda mm: mm.group(1) + kf + mm.group(3), yy, count=1, flags=re.S)
    yy = re.sub(r'"length": [\d.]+,', '"length": 16.0,', yy, count=1)
    # tamanho / origem / bbox do pé
    xo, yo = m['xo'], m['yo']
    rep = {'width': m['w'], 'height': m['h'], 'xorigin': xo, 'yorigin': yo,
           'bbox_left': xo - m['larg'] // 2, 'bbox_right': xo + m['larg'] // 2 - 1,
           'bbox_top': yo - 36, 'bbox_bottom': yo}
    for k, v in rep.items():
        yy, n = re.subn(rf'"{k}": -?\d+,', f'"{k}": {v},', yy)
        assert n >= 1, (nome, k)
    assert yy.count('"GMSpriteFrame"') == 16 and yy.count('Keyframe<SpriteFrameKeyframe>') == 16, nome
    open(f'{DST}/{nome}/{nome}.yy', 'w', encoding='utf-8', newline='').write(yy.replace('\n', nl))
    print(nome, len(antigos), '->', len(ids), m)
