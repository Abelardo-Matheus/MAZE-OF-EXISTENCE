
draw_sprite_ext(spr_sombra,0,x,y+20,0.8,0.8,0,c_white,1);
draw_self();


	
if (alarm[3] > 0){
	if(image_alpha >=1){
		dano_alfa = -0.05;
	}else if(image_alpha <= 0){
		dano_alfa = 0.05;
	}
	image_alpha += dano_alfa;
}else{
	image_alpha = 1;
}


if (desenha_arma) {
    if (global.armamento == 0) {
        draw_sprite_ext(spr_arma, 0, x, y - 60, 1, 1, 0, c_white, dir_alfa);
    } else if (global.armamento == 1) {
        draw_sprite_ext(spr_arma, 1, x, y - 60, 1, 1, 0, c_white, dir_alfa);
    }
}


// Verifica se o jogador está próximo de alguma estrutura
if (proximo_de_estrutura) {
    desenha_botao = true; // Ativa o botão se estiver próximo de uma estrutura
} else {
    desenha_botao = false; // Desativa o botão se não estiver próximo de nenhuma estrutura
}



// Step Event (ou onde você controla a lógica do piscar)
if (piscando_timer > 0) {
    piscando_timer--;  // Diminui o temporizador a cada frame
} else {
    piscando_alpha = 1 - piscando_alpha;  // Alterna entre 1 e 0 para piscar
    piscando_timer = 20;  // Reseta o temporizador
}

// Draw Event (onde você desenha o botão piscando)
if (desenha_botao) {
    draw_set_font(fnt_status);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_sprite_ext(spr_botoes, 1, x, y - 60, 0.6, 0.6, 0, c_white, piscando_alpha);  // Usa piscando_alpha para controlar a opacidade
}


// Reseta a variável para o próximo passo
proximo_de_estrutura = false;



if(distance_to_object(par_npc_vendedor_um) <= 100 ){
	if(keyboard_check_pressed(ord("P"))and !global.dialogo){
		andar = true;
		var _npc = instance_nearest(x, y, par_npc_vendedor_um);
		var _dialogo = instance_create_layer(x , y, "Instances_dialogo", obj_dialogo);
		_dialogo.npc_nome = _npc.nome;
	}
	
}







