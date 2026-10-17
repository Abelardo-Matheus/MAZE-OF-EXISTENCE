// feather disable GM2017
// Troca de acao de tempos em tempos (e destrava o estado de hit se precisar)
if (state != scr_novo_perseguir && state != scr_novo_voltar) {
    state = scr_novo_escolher_estado;
}
alarm[0] = irandom_range(120, 240);
