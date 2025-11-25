/// @desc Renderização do Jogador e Interface
/// [O QUE]: Desenha a sombra, o sprite do jogador, a arma atual e o botão de interação.
/// [COMO] :
/// 1. Desenha sombra fixa abaixo do player.
/// 2. Desenha o próprio player (draw_self).
/// 3. Se 'desenha_arma' for true, desenha o sprite da arma correspondente ao 'global.armamento'.
/// 4. Se 'desenha_botao' for true, desenha o ícone piscando acima da cabeça.

// 1. Sombra
draw_sprite_ext(spr_sombra, 0, x, y + 20, 0.8, 0.8, 0, c_white, 1);

// 2. Player4
draw_self();

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
    draw_sprite_ext(spr_botoes, 1, x, y - 60, 0.6, 0.6, 0, c_white, piscando_alpha);
    
    // Boa prática: Resetar cor/alinhamento para não afetar outros desenhos
    draw_set_color(c_white);
}