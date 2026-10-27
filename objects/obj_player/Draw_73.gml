// feather disable GM2017
/// @desc Arma e botão de interação acima da cabeça (Draw End: nunca ficam atrás de móveis)
// Bolinha de estamina ao lado do player (VIDA.gml)
desenha_estamina_bolinha();

// Giro da espada / chuva de flechas / "Nv X!" dos itens (scr_passivas_itens)
item_fx_desenhar();

// 3. Arma (Sobre a cabeça)
if (desenha_arma) 
{
    // Ícone do item ativo da hotbar (some aos poucos depois de trocar)
    var _hd = hotbar_ativo_db();
    if (!is_undefined(_hd) && sprite_exists(_hd.spr)) {
        var _he = 0.55;
        draw_sprite_ext(_hd.spr, _hd.img, x - sprite_get_width(_hd.spr) * _he / 2 + sprite_get_xoffset(_hd.spr) * _he,
                        y - 62 - sprite_get_height(_hd.spr) * _he + sprite_get_yoffset(_hd.spr) * _he, _he, _he, 0, c_white, dir_alfa);
    }
}

// 4. Botão de Interação (Prompt) — com texto do alvo (scr_interacao); senão o botão antigo
if (!interacao_desenhar_prompt() && desenha_botao) 
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
