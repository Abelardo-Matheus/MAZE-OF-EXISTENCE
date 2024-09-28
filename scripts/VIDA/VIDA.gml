function desenha_barra_vida() {
      
   
   var _scala = 4;
   var _guia = display_get_gui_height();
   var _spra = sprite_get_height(spr_barra_vida) * _scala;
   var _hud = _guia - _spra;   

    var pos_x = 0; // Posição X da barra
    var pos_y = 100; // Posição Y da barra
    var largura_barra = sprite_get_width(spr_barra_vida) * _scala;
    var altura_barra = sprite_get_height(spr_barra_vida) * _scala;
	
	var pos_stamina = pos_y + 48;
	
	var _vida = global.vida;
	var _max_vida = global.vida_max;
	var _stamina = global.estamina;
	var _max_estamina = global.max_estamina;
	var _xp = global.xp;
	var _max_xp = global.max_xp;
   
     // Verificar se o player está tocando a área da barra (mesmo parcialmente)
    var alfa = 1; // Alpha normal
    if (point_in_rectangle(global.current_player.x, global.current_player.y, pos_x - largura_barra , pos_y - altura_barra+120, pos_x + largura_barra , pos_y + altura_barra-50)) {
        alfa = 0.3; // Player está na posição da barra, reduzir alpha
    }
	  draw_sprite_ext(spr_hud_barra_xp, 0, 0 ,pos_stamina+35, (_xp/_max_xp)*0.8,2, 0 ,c_white,alfa);
	draw_sprite_ext(spr_hud_xp, 0, 0 ,pos_stamina+35, 0.8,2, 0 ,c_white,alfa);
	 draw_sprite_ext(spr_vida, 0, 0 ,pos_y,(_vida/_max_vida)*_scala,_scala, 0 ,c_white,alfa);
   
   draw_sprite_ext(spr_stamina, 0, 0 ,pos_stamina, (_stamina/_max_estamina)*_scala,_scala, 0 ,c_white,alfa);
	
   draw_sprite_ext(spr_barra_vida, 0, 0 ,pos_y, _scala,_scala, 0 ,c_white,alfa);
   
   
	
	draw_set_alpha(1);
   
   

}
