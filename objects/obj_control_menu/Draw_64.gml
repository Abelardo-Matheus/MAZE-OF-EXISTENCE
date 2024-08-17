/// @description Insert description here
// You can write your code in this editor
draw_set_alpha(1);
draw_set_font(fnt_MENU);
draw_set_color(c_white);

draw_set_halign(fa_center);
draw_set_valign(fa_middle);

draw_text(970,323,"MAZE \nOF \nEXISTENCE");

if(option_list == 1){
	draw_set_color(c_white);
	draw_set_font(fnt_menu_op);
	if(option_selected = 0) draw_set_color(c_yellow)
	draw_text(room_width/2,room_height/2+60,"JOGAR");
	
	
	draw_set_color(c_white);
	if(option_selected = 1) draw_set_color(c_yellow)
	draw_text(room_width/2,room_height/2+150,"SAIR");
}





















