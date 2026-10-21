import sys, importlib
from PIL import Image
sys.path.insert(0, '/home/claude/art2')
S = '/tmp/claude-0/-home-claude/3460b883-ae29-52b8-89f7-e956675b4249/scratchpad'

def sheet(fns, name, z=5, bg=(92, 78, 66)):
    n = len(fns); cols = min(n, 8); rows = (n + cols - 1) // cols
    sh = Image.new('RGBA', (49 * z * cols, 53 * z * rows), bg + (255,))
    for i, f in enumerate(fns):
        sh.alpha_composite(f().img().resize((49 * z, 53 * z), Image.NEAREST), ((i % cols) * 49 * z, (i // cols) * 53 * z))
    sh.save(f'{S}/{name}.png')

if __name__ == '__main__':
    mod = importlib.import_module(sys.argv[1])
    for attr in sys.argv[2:]:
        lst = getattr(mod, attr)
        sheet(lst, attr)
