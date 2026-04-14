vida -= 10;
show_debug_message(vida);
quantis = choose(1, 2, 3, 4, 5, 6); // Vai dropar de 1 a 3 itens

// --- ATIVA OS EFEITOS VISUAIS ---
tempo_piscar = 8;   // Quantidade de frames que vai ficar piscando
tempo_balancar = 15; // Quantidade de frames que vai ficar balançando
// --------------------------------

if (vida <= 0) {
    
    // Rola um "dado" de 1 a 100
    var _sorteio = irandom_range(1, 100);
    
    if (_sorteio <= 10) { 
        // Caiu 1 (1% de chance): Sorte grande! Dropa Ferro.
        criar_drop_especifico(x, y, "Barra de Ferro", quantis, 0); // Lembre de usar o nome exato do item na sua database!
    } else { 
        // Caiu de 2 a 100 (99% de chance): Drop comum. Dropa Pedra.
        criar_drop_especifico(x, y, "Pedra", quantis, 0);
    }
    
    instance_destroy();
}