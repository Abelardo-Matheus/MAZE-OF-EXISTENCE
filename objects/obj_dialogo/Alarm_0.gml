if(initialized = true){
if(char_index < string_length(text_grid[# DialogInfo.TEXT, page])){
	var _snd = choose(snd_fala,snd_fala2,snd_fala3);
	audio_play_sound(_snd,1,0);
	char_index ++;
	alarm[0] = 1;
}
}




















