---
description: Executa o fluxo completo do projeto para uma tarefa (localizar no grafo, avaliar impacto, propor plano, executar passo a passo e atualizar o mapa)
argument-hint: <descrição da tarefa>
---

Tarefa solicitada: $ARGUMENTS

Siga o "Fluxo para tarefas complexas" definido em `CLAUDE.md`, nesta ordem, sem pular etapas:

1. **Localizar** — use o grafo (`graphify-out/GRAPH_REPORT.md`, seção Communities) para achar
   em qual sistema a tarefa cai e quais nós (objetos/scripts/funções) estão envolvidos.
2. **Impacto** — para cada função/objeto que vai mudar, rode `graphify explain "nome"`
   e liste tudo que depende dele (quem chama, quem herda, quem colide, quem cria).
   Use `graphify path "A" "B"` se precisar entender como dois pontos se conectam.
3. **Plano** — antes de editar qualquer coisa, me mostre:
   - arquivos e funções que vão mudar (com linha)
   - o que depende deles e pode quebrar
   - arquivos novos que eu preciso criar na IDE (lembrete: nunca crie .yy/.gml pelo terminal,
     peça para eu criar na IDE primeiro, conforme `CONVENTIONS.md`)
   - a ordem das etapas, cada uma pequena e testável no jogo

   Espere minha aprovação antes de executar.
4. **Executar** — uma etapa por vez. Leia só os trechos indicados pelo grafo (`src=`/`loc=`),
   não arquivos inteiros sem necessidade. Ao fim de cada etapa, diga o que testar no jogo.
5. **Atualizar o mapa** — ao final, rode `python tools/graphify_gml.py .`
   (NUNCA `graphify update`, `--update` ou `graphify hook install`) e confira com
   `graphify explain` que as ligações novas aparecem como esperado.
6. **Resumo** — feche com um resumo arquitetural curto do que mudou e como se conecta ao resto.

Se a tarefa envolver vários sistemas/comunidades, divida a investigação: um subagente por
sistema, cada um consultando o grafo, e junte os achados no plano antes de pedir aprovação.
