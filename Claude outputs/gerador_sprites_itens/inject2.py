import sys, re, os, json
sys.path.insert(0, '/home/claude/art2')
from c_cons import CONS
from c_armas import ARMAS
from c_arm import ARMADURAS
from c_pe import PE
from c_mat import MAT
W = '/home/claude/work/sprites'; O = '/mnt/user-data/outputs/MAZE2'
plan = {'spr_itens_craft': MAT, 'spr_itens_invent_consumiveis': CONS, 'spr_itens_invent_passivo_armas': ARMAS,
        'spr_itens_invent_passivo_armadura': ARMADURAS, 'spr_itens_invent_passivo_pe': PE}
files = []
for spr, fns in plan.items():
    t = open(f'{W}/{spr}/{spr}.yy', encoding='utf-8').read()
    frames = re.findall(r'\{"resourceType":"GMSpriteFrame","resourceVersion":"1\.1","name":"([0-9a-f-]+)",\}', t)
    layer = re.search(r'"layers": \[\s*\{"resourceType":"GMImageLayer","resourceVersion":"1\.0","name":"([0-9a-f-]+)"', t).group(1)
    assert len(frames) == len(fns), (spr, len(frames), len(fns))
    for fid, fn in zip(frames, fns):
        im = fn().img()
        for rel in (f'sprites/{spr}/{fid}.png', f'sprites/{spr}/layers/{fid}/{layer}.png'):
            for root in (W[:-8], O):
                os.makedirs(os.path.dirname(f'{root}/{rel}'), exist_ok=True)
                im.save(f'{root}/{rel}')
            files.append(rel)
    print(spr, len(frames))
ent = [{'stagedPath': f'{O}/{r}', 'devicePath': 'C:\\GitHub\\MAZE-OF-EXISTENCE\\' + r.replace('/', '\\')} for r in files]
for i in range(0, len(ent), 50):
    json.dump(ent[i:i + 50], open(f'/home/claude/art2/commit_{i // 50}.json', 'w'))
print(len(ent))
