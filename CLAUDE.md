# Maze of Existence — instruções para o Claude

Projeto GameMaker (GML). Siga também as regras de `CONVENTIONS.md`
(principalmente: nunca criar arquivos .yy/.gml novos pelo terminal — peça para eu criar na IDE).

## graphify (mapa do código)
O mapa do projeto fica em `graphify-out/` (graph.json + GRAPH_REPORT.md).
- Antes de responder perguntas sobre o código ou planejar mudanças, consulte o grafo
  em vez de ler arquivos inteiros:
  - `graphify explain "nome"` — quem chama/usa algo (use `--all` se precisar de tudo)
  - `graphify path "A" "B"` — como duas coisas se ligam
  - `graphify query "pergunta" --budget 1500` — perguntas amplas
- Use o `src=` / `loc=` do grafo para abrir só o arquivo e o trecho necessários.
- Nomes no grafo: objetos `obj_x`, funções `nome()`, scripts `arquivo.gml`, rooms `room Nome`.
  Relações: calls, defines, creates, references, inherits, collides_with,
  uses_sprite, contains_instance, goes_to_room.
- O graphify não lê GML sozinho. Para atualizar o grafo, rode
  `python tools/graphify_gml.py .` — NUNCA `graphify update`, `--update`
  ou `graphify hook install` (eles apagariam a parte do GML).
- Se o grafo parecer desatualizado (algo que existe no código não aparece), rode o comando acima antes de continuar.

## Fluxo para tarefas complexas
Para qualquer tarefa que mexa em mais de um arquivo ou sistema, siga estas etapas em ordem:

1. **Localizar** — use o grafo para achar os nós envolvidos. Comece pelo
   `GRAPH_REPORT.md` (seção Communities) para ver em qual sistema a tarefa cai.
2. **Impacto** — para cada função/objeto que vai mudar, rode `graphify explain`
   e liste tudo que depende dele (quem chama, quem herda, quem colide, quem cria).
3. **Plano** — me mostre, antes de editar qualquer coisa:
   - arquivos e funções que vão mudar (com linha)
   - o que depende deles e pode quebrar
   - arquivos novos que eu preciso criar na IDE
   - ordem das etapas, cada uma pequena e testável no jogo
   Espere minha aprovação.
4. **Executar** — uma etapa por vez. Leia só os trechos indicados pelo grafo.
   Ao fim de cada etapa diga o que testar no jogo.
5. **Atualizar o mapa** — no fim, rode `python tools/graphify_gml.py .` e confira
   com `graphify explain` que as ligações novas aparecem como esperado.
6. **Resumo** — resumo arquitetural curto do que mudou e como se conecta ao resto.

Para tarefas muito grandes (vários sistemas), divida a investigação: um subagente
por sistema/comunidade, cada um usando o grafo, e junte os achados no plano.
