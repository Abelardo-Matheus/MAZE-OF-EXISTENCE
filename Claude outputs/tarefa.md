---
description: Faz uma tarefa complexa no Maze of Existence usando o mapa do graphify
argument-hint: <o que você quer fazer>
---

Tarefa: $ARGUMENTS

Siga o "Fluxo para tarefas complexas" do CLAUDE.md, usando o grafo em `graphify-out/`:

1. Localize os sistemas e nós envolvidos com `graphify query "..." --budget 1500`
   e `graphify explain`. Não leia arquivos .gml inteiros nesta fase.
2. Para cada função/objeto que vai mudar, liste o que depende dele (`graphify explain "nome" --all`).
3. Me apresente o plano (arquivos/funções com linha, riscos, arquivos novos para eu criar na IDE,
   etapas pequenas e testáveis) e PARE esperando minha aprovação.
4. Depois de aprovado, execute uma etapa por vez, lendo só os trechos que o grafo apontou,
   e diga o que testar no jogo ao fim de cada etapa.
5. No fim, rode `python tools/graphify_gml.py .`, confira as ligações novas e faça o resumo arquitetural.
