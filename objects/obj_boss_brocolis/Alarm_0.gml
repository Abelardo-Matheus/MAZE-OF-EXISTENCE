if (repete_contador > 0) {
    // Se houver mais repetições, habilita a criação de ondas
    onda = true;
    criar_ondas_de_choque();  // Cria as ondas
    repete_contador--;  // Decrementa o contador

    if (repete_contador > 0) {
        // Se ainda houver repetições restantes, define o próximo alarm
        alarm[0] = irandom_range(60, 120);  // Define o próximo intervalo (1 a 2 segundos)
    }
}
