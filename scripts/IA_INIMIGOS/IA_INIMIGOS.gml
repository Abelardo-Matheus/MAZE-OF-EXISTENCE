// feather disable GM2017
// ============================================================================
// IA DOS INIMIGOS (esqueletos, fantasmas, morcegos, cogumelos, ratos, olho)
// Todos sao filhos de obj_par_inimigos e chamam estas funcoes nos eventos:
//   Create  -> event_inherited(); inimigo_ia_criar(); ...atributos...; inimigo_ia_nivel();
//   Step    -> event_inherited(); inimigo_ia_step();
//   Draw    -> inimigo_ia_desenhar();
//   Alarm 0 -> inimigo_ia_alarme();     Alarm 1 -> inimigo_ia_fim_hit();
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
function inimigo_ia_mover(_h, _v) {
    if (atravessa) {
        x += _h;
        y += _v;
    } else {
        aplicar_movimento_com_colisao(_h, _v);
    }
}

/// @desc Se o jogador entrou na area, comeca a perseguir. Retorna true se viu.
function scr_ia_check_player() {
    if (!instance_exists(obj_player)) return false;
    if (point_distance(x, y, obj_player.x, obj_player.y) <= dist_aggro) {
        if (state != scr_ia_perseguir) alerta = 40; // mostra o "!" por 40 frames
        state = scr_ia_perseguir;
        return true;
    }
    return false;
}

function scr_ia_escolher_estado() {
    if (scr_ia_check_player()) exit;

    // Cogumelos ficam quietinhos disfarcados
    if (comportamento == "emboscada") {
        state = scr_ia_parado;
        exit;
    }

    if (choose(0, 1) == 0) {
        state = scr_ia_andar;
        dest_x = casa_x + irandom_range(-raio_patrulha, raio_patrulha);
        dest_y = casa_y + irandom_range(-raio_patrulha, raio_patrulha);
    } else {
        state = scr_ia_parado;
    }
}

function scr_ia_andar() {
    if (scr_ia_check_player()) exit;
    sprite_index = sprite_normal;
    image_speed = 1;
    if (point_distance(x, y, dest_x, dest_y) > veloc) {
        var _dir = point_direction(x, y, dest_x, dest_y);
        inimigo_ia_mover(lengthdir_x(veloc, _dir), lengthdir_y(veloc, _dir));
    } else {
        state = scr_ia_parado;
        alarm[0] = irandom_range(60, 120);
    }
}

function scr_ia_parado() {
    if (scr_ia_check_player()) exit;
    sprite_index = sprite_parado;
    image_speed = 1;
    hveloc = 0;
    vveloc = 0;
}

/// @desc Jogador fugiu: volta para a area de origem
function scr_ia_voltar() {
    if (scr_ia_check_player()) exit;
    sprite_index = sprite_normal;
    dest_x = casa_x;
    dest_y = casa_y;
    if (point_distance(x, y, casa_x, casa_y) > veloc * 2) {
        var _dir = point_direction(x, y, casa_x, casa_y);
        inimigo_ia_mover(lengthdir_x(veloc * 1.5, _dir), lengthdir_y(veloc * 1.5, _dir));
    } else {
        state = scr_ia_escolher_estado;
    }
}

function scr_ia_perseguir() {
    if (!instance_exists(obj_player)) {
        state = scr_ia_escolher_estado;
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
        state = scr_ia_voltar;
        exit;
    }

    switch (comportamento) {
        case "distancia":
            var _vel = 0;
            if (_dist > dist_tiro) _vel = veloc_perse;               // chega mais perto
            else if (_dist < dist_tiro * 0.6) _vel = -veloc_perse;   // recua
            inimigo_ia_mover(lengthdir_x(_vel, _dir), lengthdir_y(_vel, _dir));
            recarga_tiro--;
            if (recarga_tiro <= 0 && _dist <= dist_tiro * 1.3) {
                inimigo_ia_atirar(_dir);
                recarga_tiro = cadencia_tiro;
            }
            break;

        case "investida":
            if (investida_timer > 0) {
                // durante o bote: muito rapido, direcao travada
                investida_timer--;
                var _v = veloc_perse * 4;
                inimigo_ia_mover(lengthdir_x(_v, investida_dir), lengthdir_y(_v, investida_dir));
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
                    inimigo_ia_mover(lengthdir_x(veloc_perse, _dir), lengthdir_y(veloc_perse, _dir));
                }
            }
            break;

        case "erratico":
            var _d2 = _dir + sin(current_time * 0.008 + fase_voo) * 55;
            inimigo_ia_mover(lengthdir_x(veloc_perse, _d2), lengthdir_y(veloc_perse, _d2));
            break;

        default: // "perseguir" e "emboscada"
            inimigo_ia_mover(lengthdir_x(veloc_perse, _dir), lengthdir_y(veloc_perse, _dir));
            break;
    }
}

/// @desc Dispara um projetil (flecha/orbe) na direcao indicada
function inimigo_ia_atirar(_dir) {
    var _p = instance_create_depth(x, y - altura_tiro, depth - 1, obj_projetil_inimigo);
    _p.sprite_index = sprite_tiro;
    _p.direction = _dir;
    _p.image_angle = _dir;
    _p.dano = dano_tiro;
    _p.vel = vel_tiro;
    _p.gira = (sprite_tiro != spr_flecha_osso);
}


// ============================================================================
// EVENTOS COMPARTILHADOS
// ============================================================================

/// @desc Valores padrao (chamar no Create, logo depois do event_inherited)
function inimigo_ia_criar() {
    sprite_normal = sprite_index;
    sprite_parado = sprite_index;

    vida = 10;
    dano = 8;
    veloc = 0.6;          // velocidade andando a toa
    veloc_perse = 1.2;    // velocidade perseguindo
    escala = 1;

    // Area de deteccao
    dist_aggro = 220;     // jogador entrou nesse raio -> persegue
    dist_desaggro = 450;  // jogador passou desse raio -> desiste e volta
    casa_x = x;
    casa_y = y;
    raio_patrulha = 120;

    // Comportamento
    comportamento = "perseguir";
    atravessa = false;    // fantasmas e voadores ignoram paredes
    voa = false;          // muda a sombra e faz o corpo flutuar
    fase_voo = random(100);
    alerta = 0;           // contador do "!" quando ve o jogador

    // Tiro (comportamento "distancia")
    sprite_tiro = spr_flecha_osso;
    dist_tiro = 200;
    cadencia_tiro = 90;
    recarga_tiro = 60;
    dano_tiro = 8;
    vel_tiro = 4;
    altura_tiro = 20;

    // Investida
    investida_timer = 0;
    investida_dir = 0;
    recarga_investida = 90;

    // Extras
    roubo_vida = 0;       // 1 = cura 100% do dano causado
    transparencia = 1;    // fantasmas ficam meio transparentes
    sombra_largura = 30;

    state = scr_ia_escolher_estado;
    alarm[0] = 1;
}

/// @desc Aplica o nivel da area (vindo do spawn virtual) e o tamanho final (fim do Create)
function inimigo_ia_nivel() {
    var _lvl = 1;
    if (variable_instance_exists(id, "lvl") && is_real(lvl) && lvl > 0) _lvl = lvl;
    lvl_inimigo = _lvl;
    vida = round(vida * (1 + (_lvl - 1) * 0.5));
    max_vida = vida;
    dano = dano + (_lvl - 1) * 2;
    escala = escala * (1 + (_lvl - 1) * 0.08);
    image_xscale = escala;
    image_yscale = escala;
    sprite_index = sprite_parado;
}

/// @desc Step extra (depois do event_inherited)
function inimigo_ia_step() {
    if (!instance_exists(id)) exit;
    if (alerta > 0) alerta--;
    if (transparencia < 1) {
        image_alpha = transparencia + 0.15 * sin(current_time * 0.004 + fase_voo);
    }
}

/// @desc Alarm 0: troca de acao de tempos em tempos (e destrava o hit)
function inimigo_ia_alarme() {
    if (state != scr_ia_perseguir && state != scr_ia_voltar) {
        state = scr_ia_escolher_estado;
    }
    alarm[0] = irandom_range(120, 240);
}

/// @desc Alarm 1: fim do knockback, volta a pensar (e ja persegue quem bateu)
function inimigo_ia_fim_hit() {
    state = scr_ia_escolher_estado;
    hit = false;
    image_blend = c_white;
}

/// @desc Draw: sombra e corpo (flash branco no hit)
function inimigo_ia_desenhar() {
    var _esc = abs(image_xscale);
    var _sw = (sombra_largura * _esc) / 50;
    var _bob = voa ? sin(current_time * 0.005 + fase_voo) * 2 : 0;
    draw_sprite_ext(spr_sombra, 0, x, y, _sw * (voa ? 0.8 : 1), _sw * (voa ? 0.6 : 0.8), 0, c_white, voa ? 0.45 : 0.7);

    if (hit) gpu_set_fog(true, c_white, 0, 0);
    draw_sprite_ext(sprite_index, image_index, x, y + _bob, image_xscale, image_yscale, 0, image_blend, image_alpha);
    if (hit) gpu_set_fog(false, c_white, 0, 0);
    // "!" e barra de vida ficam em inimigo_desenhar_hud() (Draw End): sempre por cima dos móveis

}


/// @desc Draw End de todo inimigo (obj_par_inimigos): "!" de alerta e barra de vida.
///       Fica no Draw End para nunca ser coberto por móveis/paredes (que usam depth = -y).
function inimigo_desenhar_hud() {
    var _voa = variable_instance_exists(id, "voa") && voa;
    var _bob = (_voa && variable_instance_exists(id, "fase_voo")) ? sin(current_time * 0.005 + fase_voo) * 2 : 0;

    if (variable_instance_exists(id, "alerta") && alerta > 0) {
        var _ax = x;
        var _ay = bbox_top - 14 + _bob - min(4, (40 - alerta));
        draw_set_color(c_black);
        draw_rectangle(_ax - 3, _ay - 1, _ax + 3, _ay + 15, false);
        draw_set_color(c_yellow);
        draw_rectangle(_ax - 1, _ay, _ax + 1, _ay + 8, false);
        draw_rectangle(_ax - 1, _ay + 11, _ax + 1, _ay + 13, false);
        draw_set_color(c_white);
    }

    if (alarm[2] >= 0 && variable_instance_exists(id, "max_vida") && max_vida > 0) {
        var _hs = 3;
        var _w = sprite_get_width(spr_hud_vida_inimigo) * _hs;
        var _hx = x - _w / 2;
        var _hy = bbox_top - 10 + _bob;
        draw_sprite_ext(spr_hud_vida_inimigo, 0, _hx, _hy, _hs, _hs, 0, c_white, 1);
        draw_sprite_ext(spr_vida_, 0, _hx, _hy, max(0, vida / max_vida) * _hs, _hs, 0, c_white, 1);
    }
}
