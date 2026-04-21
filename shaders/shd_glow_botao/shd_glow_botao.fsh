// Aba: shd_glow.fsh
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_glow_size;    // Tamanho do brilho em pixels
uniform vec3  u_glow_color;   // Cor do brilho
uniform float u_pixel_w;      // Largura de 1 pixel da textura
uniform float u_pixel_h;      // Altura de 1 pixel da textura

void main()
{
    // Lê a cor original do pixel atual
    vec4 cor_base = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
    
    // Se o pixel faz parte do botão (é sólido), desenha normal
    if (cor_base.a > 0.0) {
        gl_FragColor = cor_base;
    } 
    // Se o pixel for transparente, vamos calcular o brilho!
    else {
        float alpha_acumulado = 0.0;
        float amostras = 16.0; // Lemos 16 direções diferentes para ficar redondo
        
        // Fazemos dois anéis de busca (um longe e um perto) para criar o degradê
        for(float i = 0.0; i < amostras; i++) {
            float rad = (i / amostras) * 6.28318; // 6.28 = 360 graus
            
            // Procura num anel mais distante (Borda externa do brilho)
            vec2 offset_longe = vec2(cos(rad) * u_pixel_w * u_glow_size, sin(rad) * u_pixel_h * u_glow_size);
            alpha_acumulado += texture2D( gm_BaseTexture, v_vTexcoord + offset_longe ).a;
            
            // Procura num anel mais perto (Núcleo do brilho)
            vec2 offset_perto = vec2(cos(rad) * u_pixel_w * (u_glow_size * 0.5), sin(rad) * u_pixel_h * (u_glow_size * 0.5));
            alpha_acumulado += texture2D( gm_BaseTexture, v_vTexcoord + offset_perto ).a;
        }
        
        // Divide o total lido por 32 (16 direções * 2 anéis) para tirar a média
        float alpha_final = alpha_acumulado / 32.0;
        
        // Multiplica por 3.0 para o núcleo do brilho ficar mais forte e vivo
        alpha_final = clamp(alpha_final * 3.0, 0.0, 1.0);
        
        // Se calculamos que deve ter brilho aqui, pintamos com a cor!
        if (alpha_final > 0.01) {
            gl_FragColor = vec4(u_glow_color, alpha_final);
        } else {
            gl_FragColor = cor_base; // Continua transparente
        }
    }
}