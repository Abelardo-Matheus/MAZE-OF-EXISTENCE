# Gera as tiras animadas dos projéteis (adaga, avião, pedrinha, pião). Requer Pillow.
import math, os
from PIL import Image, ImageDraw
OUT=os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'sprite_sheets', 'poderes_pets', 'animados'); os.makedirs(OUT,exist_ok=True)
S=32
def outline(im, col=(25,20,30,255)):
    px=im.load(); w,h=im.size; o=im.copy(); op=o.load()
    for y in range(h):
        for x in range(w):
            if px[x,y][3]==0:
                for dx,dy in ((1,0),(-1,0),(0,1),(0,-1)):
                    X,Y=x+dx,y+dy
                    if 0<=X<w and 0<=Y<h and px[X,Y][3]>=200 and px[X,Y][:3]!=col[:3]:
                        op[x,y]=col; break
    return o
def strip(frames,name):
    W=Image.new('RGBA',(S*len(frames),S),(0,0,0,0))
    for i,f in enumerate(frames): W.paste(f,(i*S,0))
    W.save(f'{OUT}/{name}_strip{len(frames)}.png'); return W
def canvas(): return Image.new('RGBA',(S,S),(0,0,0,0))

# ---------- ADAGA (aponta p/ direita, 8 frames: brilho correndo + rastro) ----------
def adaga(i):
    im=canvas(); d=ImageDraw.Draw(im)
    cy=16
    # rastro de vento atrás (pisca)
    for k,(x0,len_,a) in enumerate([(0,5,120),(2,4,90),(1,6,70)]):
        yy=cy-3+k*3; off=(i*2+k*3)%6
        d.line([(x0+off,yy),(x0+off+len_,yy)],fill=(220,235,255,a))
    # cabo
    d.rectangle([7,cy-1,11,cy+1],fill=(120,70,35,255)); d.point([(8,cy),(10,cy)],fill=(90,50,25,255))
    d.rectangle([5,cy-1,6,cy+1],fill=(230,180,60,255))   # pomo
    d.rectangle([12,cy-4,13,cy+4],fill=(235,190,60,255)) # guarda
    d.point([(12,cy-4),(13,cy+4)],fill=(255,230,120,255))
    # lâmina
    d.polygon([(14,cy-2),(26,cy-2),(30,cy),(26,cy+2),(14,cy+2)],fill=(200,210,225,255))
    d.line([(14,cy-1),(27,cy-1)],fill=(245,250,255,255))
    d.line([(14,cy+1),(27,cy+1)],fill=(150,160,180,255))
    # brilho que corre
    gx=14+(i*3)%17
    for dx in (-1,0,1):
        if 14<=gx+dx<=29: d.point((gx+dx,cy-1),fill=(255,255,255,255))
    if i in (3,4): d.point([(gx,cy-3),(gx,cy+3)],fill=(255,255,255,200))
    return outline(im)

# ---------- AVIÃO DE PAPEL (aponta p/ direita, 6 frames: asas batendo) ----------
def aviao(i):
    im=canvas(); d=ImageDraw.Draw(im)
    cy=16; flap=[0,1,2,3,2,1][i]
    nose=(29,cy)
    d.polygon([nose,(5,cy-6+flap),(10,cy)],fill=(250,250,245,255))        # asa de cima
    d.polygon([nose,(5,cy+6-flap),(10,cy)],fill=(215,220,230,255))        # asa de baixo
    d.polygon([nose,(9,cy),(13,cy+3)],fill=(180,190,205,255))             # quilha
    d.line([nose,(9,cy)],fill=(150,160,180,255))
    # listras azuis do caderno
    for x in (14,19,24):
        y=cy-int((29-x)*(6-flap)/24)+1
        d.point((x,y),fill=(120,160,230,255))
    # rastro
    for k in range(3):
        off=(i*2+k*4)%8
        d.point((2+off- k,cy-2+k*2),fill=(230,240,255,150))
    return outline(im)

# ---------- PEDRINHA (8 frames: rolando) ----------
def pedrinha(i):
    big=Image.new('RGBA',(S,S),(0,0,0,0)); d=ImageDraw.Draw(big)
    ang=math.radians(i*45)
    base=[(-6,-3),(-2,-6),(4,-5),(7,-1),(5,4),(0,6),(-5,4)]
    pts=[(16+x*math.cos(ang)-y*math.sin(ang),16+x*math.sin(ang)+y*math.cos(ang)) for x,y in base]
    d.polygon(pts,fill=(135,130,125,255))
    # sombreado: metade de baixo mais escura
    shade=[(16+x*math.cos(ang)-y*math.sin(ang),16+x*math.sin(ang)+y*math.cos(ang)) for x,y in [(-5,1),(5,1),(4,4),(0,5),(-4,3)]]
    d.polygon(shade,fill=(100,96,92,255))
    hx,hy=16+(-2)*math.cos(ang)-(-3)*math.sin(ang),16+(-2)*math.sin(ang)+(-3)*math.cos(ang)
    d.point([(round(hx),round(hy)),(round(hx)+1,round(hy))],fill=(200,195,190,255))
    sx,sy=16+3*math.cos(ang)-2*math.sin(ang),16+3*math.sin(ang)+2*math.cos(ang)
    d.point((round(sx),round(sy)),fill=(80,76,72,255))
    return outline(big)

# ---------- PIÃO (8 frames: girando, listras correndo, tremidinha) ----------
def piao(i):
    im=canvas(); d=ImageDraw.Draw(im)
    wob=[0,1,1,0,0,-1,-1,0][i]
    cx=16+wob; top=8
    cols=[(230,60,60),(250,200,40),(60,170,90),(60,120,230)]
    # corpo: cúpula em cima (y 9..14) e cone até a ponta (y 15..26)
    for y in range(9,27):
        if y<=14: half=round(11*max(0,1-((14-y)/5.6)**2)**0.5)
        else:     half=round(11*(26-y)/12)
        half=max(1,half)
        for x in range(cx-half,cx+half+1):
            band=((x-cx)+i*2)//3 % 4   # listras andam com o giro
            c=cols[band]
            lum=1.0-0.35*abs(x-cx)/max(1,half)
            if y>=21: lum*=0.85
            d.point((x,y),fill=(int(c[0]*lum),int(c[1]*lum),int(c[2]*lum),255))
    # faixa do meio clara
    for x in range(cx-10,cx+11): d.point((x,15),fill=(255,245,220,255))
    for x in range(cx-11,cx+12): d.point((x,14),fill=(255,255,255,255) if abs(x-cx)<10 else (220,220,220,255))
    # pino de cima
    d.rectangle([cx-1,top-2,cx+1,top+1],fill=(150,90,40,255)); d.point((cx,top-2),fill=(200,140,80,255))
    # ponta
    d.line([(cx,26),(cx,29)],fill=(110,110,120,255))
    # brilho
    d.point([(cx-6,11),(cx-5,11),(cx-6,12)],fill=(255,255,255,230))
    # linhas de giro
    if i%2==0:
        d.arc([cx-14,12,cx+14,20],200,250,fill=(255,255,255,170)); d.arc([cx-14,12,cx+14,20],290,340,fill=(255,255,255,170))
    else:
        d.arc([cx-14,13,cx+14,21],20,70,fill=(255,255,255,140)); d.arc([cx-14,13,cx+14,21],110,160,fill=(255,255,255,140))
    # poeirinha no chão
    d.point([(cx-3-(i%3),30),(cx+3+((i+1)%3),30)],fill=(210,200,180,160))
    return outline(im)

made={}
made['spr_adaga']=strip([adaga(i) for i in range(8)],'spr_adaga')
made['spr_aviao_papel']=strip([aviao(i) for i in range(6)],'spr_aviao_papel')
made['spr_pedrinha']=strip([pedrinha(i) for i in range(8)],'spr_pedrinha')
made['spr_piao']=strip([piao(i) for i in range(8)],'spr_piao')
# preview grande em fundo de grama
rows=list(made.items()); Z=4
P=Image.new('RGBA',(S*8*Z,S*Z*len(rows)),(70,130,60,255))
for r,(n,im) in enumerate(rows):
    big=im.resize((im.width*Z,S*Z),Image.NEAREST); P.paste(big,(0,r*S*Z),big)
P.save(os.path.join(OUT, '_preview.png'))
print(os.listdir(OUT))
