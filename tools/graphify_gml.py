"""
graphify_gml.py - gera o grafo do graphify para projetos GameMaker (GML + .yy).

O graphify nao entende GML sozinho. Este script le objetos, scripts, funcoes,
rooms e sprites do projeto, junta com os scripts Python (lidos pelo graphify)
e gera graphify-out/ com graph.html, graph.json e GRAPH_REPORT.md.

Uso (na pasta do projeto):
    pip install graphifyy
    python tools/graphify_gml.py .
"""
import json, re, sys
from pathlib import Path

def extract_gml(root):

    EVENT_TYPES = {0: "Create", 1: "Destroy", 2: "Alarm", 3: "Step", 4: "Collision", 5: "Keyboard",
                   6: "Mouse", 7: "Other", 8: "Draw", 9: "KeyPress", 10: "KeyRelease", 12: "CleanUp", 13: "Gesture"}

    nodes, edges = {}, []
    def slug(s): return re.sub(r"[^a-z0-9]+", "_", s.lower()).strip("_")
    def add_node(nid, label, src, loc=None, **kw):
        if nid not in nodes:
            nodes[nid] = dict(id=nid, label=label, file_type="code", source_file=src, source_location=loc, _origin="ast", **kw)
    def add_edge(s, t, rel, src, loc=None, ctx=None):
        edges.append(dict(source=s, target=t, relation=rel, context=ctx or rel, confidence="EXTRACTED",
                          confidence_score=1.0, source_file=src, source_location=loc, weight=1.0, _origin="ast"))
    def rel(p): return str(p.relative_to(root)).replace("\\", "/")
    def yy_name(text, key):
        m = re.search(r'"%s"\s*:\s*\{\s*"name"\s*:\s*"([^"]+)"' % key, text)
        return m.group(1) if m else None

    def strip_comments(code):
        code = re.sub(r"/\*.*?\*/", lambda m: "\n" * m.group(0).count("\n"), code, flags=re.S)
        code = re.sub(r"//[^\n]*", "", code)
        return re.sub(r'"(?:\\.|[^"\\\n])*"', '""', code)

    # ---- resources -------------------------------------------------------------
    objects, scripts, rooms, sprites = {}, {}, {}, set()
    for yy in root.glob("objects/*/*.yy"):
        objects[yy.parent.name.lower()] = yy
    for yy in root.glob("scripts/*/*.yy"):
        scripts[yy.parent.name.lower()] = yy
    for yy in root.glob("rooms/*/*.yy"):
        rooms[yy.parent.name.lower()] = yy
    for d in root.glob("sprites/*"):
        sprites.add(d.name.lower())
    obj_names = set(objects)

    for name, yy in objects.items():
        t = yy.read_text(encoding="utf-8", errors="replace")
        nid = "obj__" + slug(name)
        add_node(nid, yy.parent.name, rel(yy), "L1")
        p = yy_name(t, "parentObjectId")
        if p: add_edge(nid, "obj__" + slug(p), "inherits", rel(yy))
        s = yy_name(t, "spriteId")
        if s:
            add_node("spr__" + slug(s), s, rel(yy))
            add_edge(nid, "spr__" + slug(s), "uses_sprite", rel(yy))
        for c in re.findall(r'"collisionObjectId"\s*:\s*\{\s*"name"\s*:\s*"([^"]+)"', t):
            add_edge(nid, "obj__" + slug(c), "collides_with", rel(yy))

    for name, yy in rooms.items():
        t = yy.read_text(encoding="utf-8", errors="replace")
        nid = "room__" + slug(name)
        add_node(nid, "room " + yy.parent.name, rel(yy), "L1")
        for o in sorted(set(re.findall(r'"objectId"\s*:\s*\{\s*"name"\s*:\s*"([^"]+)"', t))):
            add_edge(nid, "obj__" + slug(o), "contains_instance", rel(yy))

    # ---- functions defined in scripts (global) ---------------------------------
    FUNC_DEF = re.compile(r"^\s*function\s+([A-Za-z_]\w*)\s*\(", re.M)
    func_defs = {}
    gml_files = list(root.glob("scripts/*/*.gml")) + list(root.glob("objects/*/*.gml"))
    for g in gml_files:
        code = strip_comments(g.read_text(encoding="utf-8", errors="replace"))
        for m in FUNC_DEF.finditer(code):
            fname = m.group(1)
            line = code.count("\n", 0, m.start()) + 1
            owner = ("scr__" if g.parts[-3] == "scripts" else "obj__") + slug(g.parent.name)
            fid = "fn__" + slug(fname)
            if fname.lower() not in func_defs:
                func_defs[fname.lower()] = fid
                add_node(fid, fname + "()", rel(g), f"L{line}", _callable=True)
                add_edge(owner, fid, "defines", rel(g), f"L{line}")

    for name, yy in scripts.items():
        add_node("scr__" + slug(name), yy.parent.name + ".gml", rel(yy), "L1")

    # ---- references inside code -----------------------------------------------
    IDENT = re.compile(r"\b([A-Za-z_]\w*)\b(\s*\()?")
    CREATE_FNS = {"instance_create_layer", "instance_create_depth", "instance_create"}
    for g in gml_files:
        src = rel(g)
        is_script = g.parts[-3] == "scripts"
        owner = ("scr__" if is_script else "obj__") + slug(g.parent.name)
        ev = g.stem  # e.g. Step_0
        code = strip_comments(g.read_text(encoding="utf-8", errors="replace"))
        # which function body we're in (for scripts) — approximate by nearest preceding def
        defs = [(m.start(), "fn__" + slug(m.group(1))) for m in FUNC_DEF.finditer(code)]
        seen = set()
        for m in IDENT.finditer(code):
            w, call = m.group(1), m.group(2)
            lw = w.lower()
            caller = owner
            for pos, fid in defs:
                if pos <= m.start(): caller = fid
            line = code.count("\n", 0, m.start()) + 1
            if call and lw in func_defs and func_defs[lw] != caller:
                key = (caller, func_defs[lw], "calls")
                if key not in seen:
                    seen.add(key); add_edge(caller, func_defs[lw], "calls", src, f"L{line}", ev)
            elif lw in obj_names and "obj__" + slug(lw) != owner:
                before = code[max(0, m.start() - 60):m.start()]
                r = "creates" if re.search(r"instance_create\w*\s*\([^;]*$", before) else "references"
                key = (caller, "obj__" + slug(lw), r)
                if key not in seen:
                    seen.add(key); add_edge(caller, "obj__" + slug(lw), r, src, f"L{line}", ev)
            elif lw in rooms and re.search(r"room_goto\s*\(\s*$", code[max(0, m.start() - 20):m.start()]):
                key = (caller, "room__" + slug(lw), "goes_to_room")
                if key not in seen:
                    seen.add(key); add_edge(caller, "room__" + slug(lw), "goes_to_room", src, f"L{line}", ev)

    # drop edges to unknown nodes (e.g. parent object deleted)
    edges = [e for e in edges if e["source"] in nodes and e["target"] in nodes]
    return {"nodes": list(nodes.values()), "edges": edges, "hyperedges": [], "input_tokens": 0, "output_tokens": 0}

def main():
    root = Path(sys.argv[1] if len(sys.argv) > 1 else ".").resolve()
    outdir = root / "graphify-out"
    outdir.mkdir(exist_ok=True)

    from graphify.detect import detect
    from graphify.extract import extract
    from graphify.build import build_from_json
    from graphify.cluster import cluster, score_all
    from graphify.analyze import god_nodes, surprising_connections, suggest_questions
    from graphify.report import generate
    from graphify.export import to_json, to_html

    gml = extract_gml(root)
    det = detect(root)
    py = [Path(p) for p in det["files"].get("code", []) if p.endswith(".py")]
    ast = extract(py, cache_root=root, root=root) if py else {"nodes": [], "edges": []}
    ex = {"nodes": gml["nodes"] + ast["nodes"], "edges": gml["edges"] + ast["edges"],
          "hyperedges": [], "input_tokens": 0, "output_tokens": 0}

    G = build_from_json(ex, root=str(root), directed=True)
    if G.number_of_nodes() == 0:
        sys.exit("Grafo vazio - nenhum objeto/script encontrado. Rode na pasta do projeto (onde fica o .yyp).")
    comms = cluster(G)
    coh = score_all(G, comms)
    # nome automatico de cada comunidade: o no mais conectado dela
    labels = {}
    for cid, members in comms.items():
        top = max(members, key=G.degree)
        labels[cid] = "em torno de " + str(G.nodes[top].get("label", top))
    gods = god_nodes(G)
    sur = surprising_connections(G, comms)
    q = suggest_questions(G, comms, labels)
    report = generate(G, comms, coh, labels, gods, sur, det, {"input": 0, "output": 0}, str(root), suggested_questions=q)
    (outdir / "GRAPH_REPORT.md").write_text(report, encoding="utf-8")
    if not to_json(G, comms, str(outdir / "graph.json"), community_labels=labels):
        print("Aviso: graph.json antigo tinha mais nos e nao foi sobrescrito. Apague graphify-out/graph.json e rode de novo.")
    to_html(G, comms, str(outdir / "graph.html"), community_labels=labels)
    print(f"Grafo: {G.number_of_nodes()} nos, {G.number_of_edges()} ligacoes, {len(comms)} comunidades")
    print(f"Pronto: abra {outdir / 'graph.html'} no navegador")


if __name__ == "__main__":
    main()
