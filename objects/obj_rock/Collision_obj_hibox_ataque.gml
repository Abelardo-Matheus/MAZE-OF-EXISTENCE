// feather disable GM2017
// Pedra: só quebra com PICARETA (scr_coleta). Picareta melhor = mais ferro, ouro e diamante.
var _f = coleta_golpe(other, "pedra");
if (_f <= 0) exit;
vida -= _f;
if (vida <= 0) coleta_quebrar("pedra");
