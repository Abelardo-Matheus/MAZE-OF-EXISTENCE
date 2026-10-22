// feather disable GM2017
// Árvore: só quebra com MACHADO (scr_coleta). Espada e outras ferramentas só fazem balançar.
var _f = coleta_golpe(other, "arvore");
if (_f <= 0) exit;
vida -= _f;
if (vida <= 0) coleta_quebrar("arvore");
