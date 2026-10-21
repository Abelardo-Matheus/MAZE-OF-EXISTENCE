// feather disable GM2017
/// @desc Arma e botão de interação acima da cabeça (Draw End: nunca ficam atrás de móveis)
// 3. Arma (Sobre a cabeça)
if (desenha_arma) 
{
    // Otimização: Usamos 'global.armamento' direto no subimg (indice da imagem),
    // já que 0 é espada e 1 é arco nos dois lugares.
    draw_sprite_ext(spr_arma, global.armamento, x, y - 60, 1, 1, 0, c_white, dir_alfa);
}

// 4. Botão de Interação (Prompt)
if (desenha_botao) 
{
    // Configurações de texto
    draw_set_font(fnt_status);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    
    // Desenha o botão usando o alpha calculado no Step
    // botao_frame: 0 = E (escada do porão), 1 = F (móveis). Quem pede o botão escolhe a tecla.
    var _frame_botao = variable_instance_exists(id, "botao_frame") ? botao_frame : 1;
    draw_sprite_ext(spr_botoes, _frame_botao, x, y - 60, 0.6, 0.6, 0, c_white, piscando_alpha);
    
    // Boa prática: Resetar cor/alinhamento para não afetar outros desenhos
    draw_set_color(c_white);
}
botao_frame = 1; // volta para F; a escada troca para E no End Step de cada frame

// 5. Pegada no grid + baú transparente sendo posicionado (itens_geral.gml -> colocar_bau_desenhar)
if (global.colocando_bau.ativo) colocar_bau_desenhar();
