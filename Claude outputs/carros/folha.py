"""Folha de sprites (4 veículos x 16 frames) + GIF de prévia."""
import os
from PIL import Image, ImageDraw
from gen import VEICULOS, gerar
os.makedirs('saida', exist_ok=True)
dados = {n: gerar(n) for n in VEICULOS}
# folha única: cada linha = 1 veículo, 16 colunas (dir*4+passo), célula do tamanho do maior
cw = max(m['w'] for f, m in dados.values()); chh = max(m['h'] for f, m in dados.values())
folha = Image.new('RGBA', (cw * 16, chh * 4), (0, 0, 0, 0))
for j, (n, (fr, m)) in enumerate(dados.items()):
    for i, f in enumerate(fr):
        folha.alpha_composite(f, (i * cw + (cw - m['w']) // 2, j * chh + (chh - m['h'])))
    # folha individual de cada veículo (16 frames lado a lado)
    ind = Image.new('RGBA', (m['w'] * 16, m['h']), (0, 0, 0, 0))
    for i, f in enumerate(fr): ind.alpha_composite(f, (i * m['w'], 0))
    ind.save(f'saida/{n}_strip16.png')
folha.save('saida/carros_topdown_sheet.png')
# prévia com fundo de rua
bg = Image.new('RGBA', folha.size, (88, 90, 100, 255)); bg.alpha_composite(folha)
bg.convert('RGB').resize((folha.width // 3, folha.height // 3), Image.NEAREST).save('saida/previa_sheet.png')
# GIF: os 4 andando na direita e descendo
quadros = []
for p in range(8):
    q = Image.new('RGBA', (1500, 360), (88, 90, 100, 255))
    d = ImageDraw.Draw(q)
    for k in range(0, 1500, 60): d.rectangle([k, 300, k + 30, 306], fill=(240, 240, 230, 255))
    x = 20
    for n, (fr, m) in dados.items():
        f = fr[8 + p % 4]
        q.alpha_composite(f, (x + p * 6, 340 - m['yo']))
        x += m['w'] + 30
    quadros.append(q.convert('RGB'))
quadros[0].save('saida/previa_andando.gif', save_all=True, append_images=quadros[1:], duration=110, loop=0)
print(folha.size)
