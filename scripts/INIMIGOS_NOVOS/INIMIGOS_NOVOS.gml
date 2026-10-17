// feather disable GM2017
// ============================================================================
// IA DOS INIMIGOS NOVOS (filhos de par_inimigos_novos)
// ----------------------------------------------------------------------------
// Todos seguem o mesmo ciclo:
//   patrulha perto da "casa" (onde nasceram)  ->  jogador entra na area
//   (dist_aggro)  ->  persegue  ->  jogador foge para longe (dist_desaggro)
//   ->  volta para casa.
// A variavel "comportamento" muda so o jeito de perseguir:
//   "perseguir"  : vai reto no jogador
//   "distancia"  : mantem distancia e atira (arqueiro, olho)
//   "investida"  : prepara e da um bote rapido (fantasma vermelho, rato gigante)
//   "erratico"   : voa em zigue-zague (morcegos)
//   "emboscada"  : fica parado disfarcado ate o jogador chegar perto (cogumelos)
// ============================================================================

/// @desc Move respeitando paredes (ou atravessando, para fantasmas/voadores)
function inimigo_novo_mover(_h, _v) {
    if (atravessa) {
        x += _h;
        y += _v;
    } else {
        aplicar_movimento_com_colisao(_h, _v);
    }
}

/// @desc Se o jogador entrou na area, comeca a perseguir. Retorna true se viu.
function scr_novo_check_player() {
    if (!instance_exists(obj_player)) return false;
    if (point_distance(x, y, obj_player.x, obj_player.y) <= dist_aggro) {
        if (state != scr_novo_perseguir) alerta = 40; // mostra o "!" por 40 frames
        state = scr_novo_perseguir;
        return true;
    }
    return false;
}

function scr_novo_escolher_estado() {
    if (scr_novo_check_player()) exit;

    // Cogumelos ficam quietinhos disfarcados
    if (comportamento == "emboscada") {
        state = scr_novo_parado;
        exit;
    }

    if (choose(0, 1) == 0) {
        state = scr_novo_andar;
        dest_x = casa_x + irandom_range(-raio_patrulha, raio_patrulha);
        dest_y = casa_y + irandom_range(-raio_patrulha, raio_patrulha);
    } else {
        state = scr_novo_parado;
    }
}

function scr_novo_andar() {
    if (scr_novo_check_player()) exit;
    sprite_index = sprite_normal;
    image_speed = 1;
    if (point_distance(x, y, dest_x, dest_y) > veloc) {
        var _dir = point_direction(x, y, dest_x, dest_y);
        inimigo_novo_mover(lengthdir_x(veloc, _dir), lengthdir_y(veloc, _dir));
    } else {
        state = scr_novo_parado;
        alarm[0] = irandom_range(60, 120);
    }
}

function scr_novo_parado() {
    if (scr_novo_check_player()) exit;
    sprite_index = sprite_parado;
    image_speed = 1;
    hveloc = 0;
    vveloc = 0;
}

/// @desc Jogador fugiu: volta para a area de origem
function scr_novo_voltar() {
    if (scr_novo_check_player()) exit;
    sprite_index = sprite_normal;
    dest_x = casa_x;
    dest_y = casa_y;
    if (point_distance(x, y, casa_x, casa_y) > veloc * 2) {
        var _dir = point_direction(x, y, casa_x, casa_y);
        inimigo_novo_mover(lengthdir_x(veloc * 1.5, _dir), lengthdir_y(veloc * 1.5, _dir));
    } else {
        state = scr_novo_escolher_estado;
    }
}

function scr_novo_perseguir() {
    if (!instance_exists(obj_player)) {
        state = scr_novo_escolher_estado;
        exit;
    }
    sprite_index = sprite_normal;
    image_speed = 1.2;

    var _px = obj_player.x;
    var _py = obj_player.y;
    var _dist = point_distance(x, y, _px, _py);
    var _dir = point_direction(x, y, _px, _py);
    dest_x = _px;
    dest_y = _py;

    if (_dist >= dist_desaggro) {
        investida_timer = 0;
        state = scr_novo_voltar;
        exit;
    }

    switch (comportamento) {
        case "distancia":
            var _vel = 0;
            if (_dist > dist_tiro) _vel = veloc_perse;               // chega mais perto
            else if (_dist < dist_tiro * 0.6) _vel = -veloc_perse;   // recua
            inimigo_novo_mover(lengthdir_x(_vel, _dir), lengthdir_y(_vel, _dir));
            recarga_tiro--;
            if (recarga_tiro <= 0 && _dist <= dist_tiro * 1.3) {
                inimigo_novo_atirar(_dir);
                recarga_tiro = cadencia_tiro;
            }
            break;

        case "investida":
            if (investida_timer > 0) {
                // durante o bote: muito rapido, direcao travada
                investida_timer--;
                var _v = veloc_perse * 4;
                inimigo_novo_mover(lengthdir_x(_v, investida_dir), lengthdir_y(_v, investida_dir));
            } else {
                recarga_investida--;
                if (recarga_investida <= 0) {
                    investida_dir = _dir;
                    investida_timer = 16;
                    recarga_investida = irandom_range(100, 140);
                } else if (recarga_investida <= 25 && _dist < 260) {
                    // preparando: para e treme (aviso para o jogador)
                    x += random_range(-1, 1);
                } else {
                    inimigo_novo_mover(lengthdir_x(veloc_perse, _dir), lengthdir_y(veloc_perse, _dir));
                }
            }
            break;

        case "erratico":
            var _d2 = _dir + sin(current_time * 0.008 + fase_voo) * 55;
            inimigo_novo_mover(lengthdir_x(veloc_perse, _d2), lengthdir_y(veloc_perse, _d2));
            break;

        default: // "perseguir" e "emboscada"
            inimigo_novo_mover(lengthdir_x(veloc_perse, _dir), lengthdir_y(veloc_perse, _dir));
            break;
    }
}

/// @desc Dispara um projetil (flecha/orbe) na direcao indicada
function inimigo_novo_atirar(_dir) {
    var _p = instance_create_depth(x, y - altura_tiro, depth - 1, obj_projetil_inimigo);
    _p.sprite_index = sprite_tiro;
    _p.direction = _dir;
    _p.image_angle = _dir;
    _p.dano = dano_tiro;
    _p.vel = vel_tiro;
    _p.gira = (sprite_tiro != spr_flecha_osso);
}
