// feather disable GM2017
if (!visible) exit; // dormindo fora da tela (scr_desempenho -> desempenho_cull)
// (não herda o Step do par_objetos: aquele liga "solid" e o montinho não bloqueia ninguém)
depth = -y;
if (tempo_piscar > 0) { tempo_piscar--; image_blend = c_red; } else image_blend = c_white;
if (tempo_balancar > 0) {
    tempo_balancar--;
    image_yscale = escala * (1 + sin(tempo_balancar) * 0.08);
} else {
    image_yscale = escala;
}
