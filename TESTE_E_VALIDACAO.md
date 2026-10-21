# 🧪 GUIA DE TESTES E VALIDAÇÃO

**Data:** 01/09/2026  
**Arquivos Corrigidos:** 2  
**Testes Recomendados:** 8

---

## ✅ TESTES CRÍTICOS (Fazer Primeiro)

### Teste 1: Sistema de Raridade de Drop ⭐ URGENTE
**Arquivo Corrigido:** `inventario.gml`  
**Bug Corrigido:** Lógica invertida de raridade

**Como Testar:**
1. Criar um item com raridade 50
2. Chamar `criar_drop_especifico(x, y, "nome_item", 1, 50)`
3. Rodar 100 vezes e contar: deve dropar ~50 vezes

**Antes da Correção:**
```
- Raridade 50 = 50% de NÃO dropar (invertido!)
- Raridade 20 = 80% de NÃO dropar (muito raro)
```

**Depois da Correção:**
```
- Raridade 50 = 50% de dropar (correto!)
- Raridade 20 = 20% de NÃO dropar (comum)
```

**Script de Teste:**
```gml
function test_raridade() {
    var _drops = 0;
    var _total = 100;
    
    for (var _i = 0; _i < _total; _i++) {
        random_seed(current_time + _i);
        criar_drop_especifico(100, 100, "Poção", 1, 50);
        // Contar items criados na sala
    }
    
    show_debug_message("Taxa de drop: " + string(_drops/_total*100) + "%");
    // Esperado: ~50%
}
```

---

### Teste 2: Sistema de Stats do Player ⭐ URGENTE
**Arquivo Corrigido:** `inventario.gml`  
**Bug Corrigido:** Stats acumulam indefinidamente

**Como Testar:**
1. Equipar uma arma (+10 dano)
2. Chamar `recalculate_player_stats()`
3. Verificar `global.ataque` (deve ser 10)
4. Desequipar a arma
5. Chamar `recalculate_player_stats()`
6. Verificar `global.ataque` (deve ser 0, NÃO 10 novamente!)

**Antes da Correção:**
```
Ataque inicial: 0
Equipar arma (+10): 10 ✅
Desequipar arma: 10 ❌ (BUG! Deveria ser 0)
Chamar recalculate novamente: 20 ❌ (Acumula!)
```

**Depois da Correção:**
```
Ataque inicial: 0
Equipar arma (+10): 10 ✅
Desequipar arma: 0 ✅ (Correto!)
Chamar recalculate novamente: 0 ✅ (Sem acúmulo)
```

**Script de Teste:**
```gml
function test_stats_reset() {
    global.ataque = 0;
    global.armadura_bebe = 0;
    global.speed_player = 0;
    
    show_debug_message("Antes: ATK=" + string(global.ataque));
    
    // Simular equipar arma
    global.grid_itens[# INFOS.DANO, 18] = 10;
    recalculate_player_stats();
    
    show_debug_message("Com arma: ATK=" + string(global.ataque)); // Deve ser 10
    
    // Simular desequipar
    global.grid_itens[# INFOS.DANO, 18] = -1;
    recalculate_player_stats();
    
    show_debug_message("Sem arma: ATK=" + string(global.ataque)); // Deve ser 0
}
```

---

### Teste 3: Validação de Entrada Inventário
**Arquivo Corrigido:** `inventario.gml`  
**Bug Corrigido:** Falta validação

**Como Testar:**
1. Chamar `inventory_remove_item(item_id, -5)`
2. Não deve fazer nada (retorna false)
3. Chamar `inventory_remove_item(item_id, 0)`
4. Não deve fazer nada (retorna false)
5. Chamar `inventory_remove_item(item_id, 5)`
6. Deve remover corretamente (retorna true/false dependendo)

**Script de Teste:**
```gml
function test_inventory_validation() {
    var _item = 1;
    
    // Teste 1: Quantidade negativa
    if (inventory_remove_item(_item, -5)) {
        show_debug_message("ERRO: Permitiu quantidade negativa!");
    } else {
        show_debug_message("OK: Rejeitou quantidade negativa ✅");
    }
    
    // Teste 2: Quantidade zero
    if (inventory_remove_item(_item, 0)) {
        show_debug_message("ERRO: Permitiu quantidade zero!");
    } else {
        show_debug_message("OK: Rejeitou quantidade zero ✅");
    }
}
```

---

## 🟡 TESTES IMPORTANTES

### Teste 4: Função com Parâmetro Agora Utilizado
**Arquivo Corrigido:** `spr_fase_criation.gml`  
**Correção:** `gerar_inimigos_e_itens_para_o_nivel()` agora usa `_level`

**Como Testar:**
1. Chamar `gerar_inimigos_e_itens_para_o_nivel(salas, 1)`
2. Verificar: 1 inimigo criado, 3 itens criados
3. Chamar `gerar_inimigos_e_itens_para_o_nivel(salas, 5)`
4. Verificar: 5 inimigos criados, 7 itens criados

**Antes:**
```
Sempre 3 inimigos (hardcoded), qualquer level ❌
```

**Depois:**
```
Inimigos = 1 + level ✅
Itens = 2 + level ✅
```

---

### Teste 5: Funções Removidas Não Causam Erro
**Arquivo Corrigido:** `spr_fase_criation.gml`  
**Remoção:** 3 funções não utilizadas

**Como Testar:**
1. Compilar o projeto
2. Não deve haver erro "Function not found"
3. Executar o jogo normalmente
4. Verificar que geração de salas funciona

**Verificação:**
```
Procurar por chamadas a:
  - create_pontos_em_salas_aleatorias()
  - cria_salas_e_objetos()
  - sala_tuto()
  
Se encontrar: não deveria estar usando!
```

---

## 🟢 TESTES OPCIONAIS

### Teste 6: Código Sem Linhas Redundantes
**Arquivo Corrigido:** `inventario.gml`  
**Limpeza:** Removidas 3 linhas redundantes

**Verificação:**
```gml
// Removidas estas linhas redundantes:
_inst.prof = _inst.depth;
_inst.profundidade = _inst.depth;
_inst.ind = _grid[# INFOS.IMAGE_IND, _slot];
_inst.image_index = _grid[# INFOS.IMAGE_IND, _slot];

// Mantém apenas:
_inst.depth = -_pos_y;
_inst.image_index = _grid[# INFOS.IMAGE_IND, _slot];
```

**Teste:** Não deve haver diferença visual de funcionamento

---

### Teste 7: Arrays Melhor Documentados
**Arquivo Corrigido:** `spr_fase_criation.gml`  
**Documentação:** Arrays agora têm @desc

**Verificação:**
Passar o mouse nos arrays no editor, deve aparecer descrição:
```gml
/// @desc Armazena as salas do jardim para evitar crashes
global.sala_jardim = [];
```

---

### Teste 8: Compatibilidade Geral
**Verificação:** Arquivo compile sem warnings adicionais

```
Checklist:
□ Nenhum erro de compilação novo
□ Nenhum warning novo
□ Jogo inicia normalmente
□ Sem memory leaks visíveis
□ Performance similar ou melhor
```

---

## 📋 CHECKLIST DE VALIDAÇÃO

Marque conforme testa:

### Testes Críticos:
- [ ] **Teste 1:** Raridade de drop ~50% com valor 50
- [ ] **Teste 2:** Stats resetam corretamente
- [ ] **Teste 3:** Validação rejeita entradas inválidas

### Testes Importantes:
- [ ] **Teste 4:** Parâmetro _level é utilizado
- [ ] **Teste 5:** Nenhum erro "Function not found"

### Testes Opcionais:
- [ ] **Teste 6:** Sem mudança visual
- [ ] **Teste 7:** Documentação aparece
- [ ] **Teste 8:** Compatibilidade mantida

---

## 🐛 Se Algo Quebrar

### Erro: "Function not found - create_pontos_em_salas_aleatorias"
**Solução:** Essa função foi removida. Use `recriar_pontos_na_sala_atual()` no lugar.

### Erro: "Invalid argument for function inventory_remove_item"
**Solução:** Agora valida entrada. Verifique se está passando quantidade > 0.

### Bug: Items não dropam
**Solução:** Raridade foi corrigida. Raridade 50 = 50% de dropar (não 50% de não dropar).

### Bug: Stats aumentam muito
**Solução:** Stats agora resetam antes de recalcular. Equipar/desequipar deve funcionar corretamente.

---

## 📞 SUPORTE

Se encontrar problemas:

1. **Verifique os backups:**
   - `inventario_BACKUP.gml`
   - `spr_fase_criation_BACKUP.gml`

2. **Rolagem para anterior:**
   Usar Git para comparar mudanças:
   ```bash
   git diff scripts/inventario/inventario.gml
   git diff scripts/spr_fase_criation/spr_fase_criation.gml
   ```

3. **Restaurar se necessário:**
   ```bash
   git checkout scripts/inventario/inventario.gml
   ```

---

## ✨ Resultado Esperado

Após passar em todos os testes:
- ✅ Sistema de drop funciona corretamente
- ✅ Stats de player funcionam corretamente
- ✅ Inventário valida entradas
- ✅ Dificuldade escala com level
- ✅ Código mais limpo e manutenível
- ✅ 36 linhas de código não utilizado removidas
- ✅ 3 bugs críticos corrigidos

---

**Status:** Pronto para testes  
**Prioridade:** ALTA  
**Tempo Estimado:** 30-60 minutos

