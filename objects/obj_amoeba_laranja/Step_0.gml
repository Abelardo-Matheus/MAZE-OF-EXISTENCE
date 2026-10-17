// feather disable GM2016
// feather disable GM2017

event_inherited();

// Divide em 3 amebas menores ao morrer.
// Correção: o repeat sem chaves só repetia a criação (os ajustes iam só para a última),
// e "vida/2" usava a vida já <= 0, então as filhas nasciam mortas.
if (vida <= 0) {
    // 20 = vida do Create (o max_vida herdado do pai ficou em 10)
    var _vida_filha = max(1, max(max_vida, 20) / 2);
    repeat (3) {
        var _int = instance_create_layer(x + random_range(-12, 12), y + random_range(-12, 12), "instances", obj_amoeba);
        _int.vida = _vida_filha;
        _int.max_vida = _vida_filha;
        _int.escala = max(0.4, escala - 0.5);
        _int.dano = dano / 2;
    }
}
