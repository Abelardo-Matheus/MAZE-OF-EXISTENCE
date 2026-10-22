// feather disable GM2017
// Montinho de terra: só sai com PÁ (scr_coleta).
var _f = coleta_golpe(other, "terra");
if (_f <= 0) exit;
vida -= _f;
if (vida <= 0) coleta_quebrar("terra");
