// ==========================================
// EVENTO CREATE - Roda apenas 1 vez!
// ==========================================

// 1. Array de SPRITES (muito mais leve que array de objetos)
var _sprites_casas = [spr_casa, spr_casa2, spr_casa3, spr_casa4]; // Coloque o nome dos seus sprites aqui!

// 2. A Mágica Determinística
var _indice_fixo = abs(seed) mod array_length(_sprites_casas);

// 3. Muda a aparência da casa para sempre
sprite_index = _sprites_casas[_indice_fixo];

// Se as casas tiverem tamanhos de colisão diferentes, o GameMaker 
// atualiza a máscara de colisão automaticamente quando você muda o sprite_index!