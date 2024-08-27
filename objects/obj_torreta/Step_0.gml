/// @description Insert description here
// You can write your code in this editor



    // Obtém a posição do obj_sperm
    var alvo_x = obj_SPERM.x;
    var alvo_y = obj_SPERM.y;
    
    // Direção do inimigo para o obj_sperm
    var direcao = point_direction(x, y, alvo_x, alvo_y);
    
    // Ajustar a rotação do inimigo para a direção calculada
    image_angle = direcao -180;  // Subtrai 90 graus para alinhar o "frente" do retângulo corretamente




if(tiro == true){
var tiros = instance_create_layer(x,y,"instances",obj_tiro);
with(tiros){
	direction =  direcao ;
}
tiro = false;
}











