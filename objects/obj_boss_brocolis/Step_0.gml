script_execute(estado);
if(vida <=0){
	global.brocolis_vivo = false;
	ganhar_xp(1000);
	instance_destroy();
	resetar_fase_por_level();
}














