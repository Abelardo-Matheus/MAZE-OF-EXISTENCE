global.brocolis_vivo = true;
function scr_boss_escolher_atk() {
	 image_speed = 1;  
	randomize();
    if (alarm[0] <= 0) {
        // Escolhe aleatoriamente um dos cinco ataques
        var _ataque = choose(scr_boss_atk_cansado,scr_boss_atk_zero, scr_boss_atk_um, criar_ondas_de_choque, scr_boss_atk_tres, scr_boss_atk_quatro, scr_boss_atk_cinco);
        estado = _ataque;  // Define o estado atual do chefe como o ataque escolhido
        alarm[0] = 160;  
    }
	
}
function scr_boss_atk_cansado() {
    // Verifica se o estado cansado ainda não foi ativado
    if (!estado_cansado_ativo) {
        estado_cansado_ativo = true;  // Ativa o estado cansado
        speed = 0;  // O chefe não se move
        image_speed = 0.2;  // Velocidade lenta da animação do chefe, indicando cansaço
        alarm[4] = 100; 
		
    }
}



function scr_boss_atk_zero() {
   
    repeat(10){
		var _xx = irandom_range(x - 800, x + 800);
		var _yy = irandom_range(y - 800,y + 800);
		instance_create_layer(_xx, _yy, "instances", obj_ataque_boss);
	}
    estado = scr_boss_escolher_atk;
}

// Ataque 1: Investida corpo a corpo
function scr_boss_atk_um() {
    var dir = point_direction(x, y, obj_player.x, obj_player.y);  // Direção do jogador
    speed = global.speed_player - 3;  // Velocidade da investida
    direction = dir;  // Define a direção da investida
    image_speed = 1;  // Aumenta a velocidade da animação do chefe
	damage = 15;
	
	if(alarm[0] == 0){
		estado = scr_boss_parar_investida;
	}

	
}


// Função auxiliar para quando o chefe para após o ataque corpo a corpo
function scr_boss_parar_investida() {
    speed = 0;
	direction = 0;  // Define a direção da investida
    image_speed = 0.5;  // Volta a velocidade da animação ao normal
	estado = scr_boss_atk_cansado;  // Escolhe o próximo ataque

}

function criar_ondas_de_choque() {
    if (repete_contador == 0) {
        repete_contador = 3;  // Número de vezes que o ataque será repetido
        obj_boss_brocolis.onda = true;  // Inicializa a variável para ativar o ataque
        alarm[0] = irandom_range(60, 120);  // Define o primeiro intervalo (1 a 2 segundos)
    }

    // Se a variável 'onda' estiver true, cria as ondas
    if (obj_boss_brocolis.onda) {
		var dor = irandom_range(10,30);
        var num_ondas = dor;  // Número de ondas de choque
        var angulo_inicial = 0;  // Ângulo inicial

        for (var i = 0; i < num_ondas; i++) {
            var angulo = angulo_inicial + (i * (360 / num_ondas));  // Distribui as ondas em 360 graus

            // Criar a onda de choque (um tipo de projétil que se espalha ao redor)
            var onda = instance_create_layer(x, y, "instances", obj_projetil_boss);
            with (onda) {
                direction = angulo;  // Define a direção da onda de choque
                speed = 6;  // Velocidade da onda
                damage = 15;  // Dano causado pela onda
				
            }
        }

        // Desativar a variável 'onda' após a criação
        obj_boss_brocolis.onda = false;
    }

    // Define o próximo estado após terminar o ataque
    estado = scr_boss_escolher_atk;
}


function scr_boss_atk_tres() {
    // Inicializar o ataque e variáveis, caso ainda não tenha sido iniciado
    if (!ataque_ativo) {
        tiros_totais = irandom_range(3, 20);  // Número total de projéteis a serem disparados
        tiros_disparados = 0;  // Contador de projéteis disparados
        ataque_ativo = true;  // Indicar que o ataque está ativo
        alarm[5] = 10;  // Iniciar o primeiro disparo após 20 steps
    }
}

function scr_boss_atk_quatro() {
    var num_projeteis = irandom_range(20,40);  // Número de projéteis disparados
    var angulo_inicial = 0;  // Ângulo inicial para o primeiro projétil
    var velocidade_base = irandom(6);  // Velocidade base dos projéteis

    for (var i = 0; i < num_projeteis; i++) {
        var angulo = angulo_inicial + (i * (360 / num_projeteis));  // Distribui os projéteis igualmente em 360 graus

        // Criar o projétil e definir direção
        var proj = instance_create_layer(x, y, "instances", obj_projetil_boss);
        with (proj) {
            direction = angulo;  // Define a direção do projétil
            speed = velocidade_base + (i * 0.5);  // Aumenta a velocidade com base no índice do projétil
            damage = 15;  // Dano causado pelo projétil
        }
    }
    estado = scr_boss_escolher_atk;  // Volta a escolher outro ataque depois de terminar
}


// Ataque 5: Disparar um projétil que segue o jogador
function scr_boss_atk_cinco() {
    // Criar o projétil que segue o jogador
    var proj = instance_create_layer(x, y, "instances", obj_projetil_boss);
    with (proj) {
        speed = 4;  // Velocidade do projétil seguidor
        target = obj_player;  // O alvo do projétil é o jogador
        damage = 15;  // Dano causado pelo projétil
		seguidor = true;
		alarm[0] = 180;
		max_speed = 6;
    }
	 estado = scr_boss_escolher_atk;
}
