from PIL import Image
from gen import VEICULOS, gerar
rows=[]
for nome in VEICULOS:
    fr,m=gerar(nome); w,h=m['w'],m['h']
    sel=[fr[i] for i in (0,4,8,12)]+[fr[8+i] for i in range(4)]
    im=Image.new('RGB',(w*8,h),(96,96,104))
    for i,f in enumerate(sel): im.paste(f,(i*w,0),f)
    im.save('p_'+nome+'.png'); print(nome,m)
