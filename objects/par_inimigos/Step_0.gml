image_xscale = escala;
image_yscale = escala;
script_execute(state);
depth = -y;

if (vida <= 0) {
	// Evento Destroy ou quando o inimigo morrer
	remover_inimigo_por_id(global.current_sala, inimigo_id);

    // Definir uma base de XP e um multiplicador baseado na vida máxima do inimigo
    var base_xp = 10; // Valor fixo de XP
    var xp_multiplicador = 0.1; // Multiplicador para balancear o ganho de XP (ajustável conforme desejado)

    // Ganhar XP com base na vida do inimigo derrotado
    var xp_ganho = base_xp + (max_vida * xp_multiplicador);
    
    ganhar_xp(xp_ganho);

    // Destroi o inimigo
    instance_destroy();
}









