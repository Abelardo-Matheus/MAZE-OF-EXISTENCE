// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function scr_textos(){
	switch npc_nome {
    case "BV0":
        texto = "Olá, quem é você?";
        ds_grid_add_text(texto, spr_retrato1_player, 0, "Você", false);
        
        texto = "Ah, finalmente você me vê! Sou a fada da consciência.";
        ds_grid_add_text(texto, spr_retrato1_fada, 1, "Fada", false);
        
        texto = "Prazer, mas... consciência? O que é isso?";
        ds_grid_add_text(texto, spr_retrato3_player, 0, "Você", false);
        
        texto = "Sim, agora você vê o mundo ao seu redor com seus próprios olhos. Está pronto para entender as coisas!";
        ds_grid_add_text(texto, spr_retrato2_fada, 1, "Fada", false);
        
        texto = "Interessante... O que mais posso fazer?";
        ds_grid_add_text(texto, spr_retrato3_player, 0, "Você", false);

        add_op("O que significa ter consciência?", "R1");
        add_op("Isso parece assustador.", "R2");
        add_op("Quem é você, exatamente?", "R3");
        
        break;

    case "R1":
        texto = "Significa que agora você tem o poder de fazer escolhas e de aprender com elas.";
        ds_grid_add_text(texto, spr_retrato1_fada, 1, "Fada", false);
        
        texto = "Escolhas, né? O que eu escolho, então?";
        ds_grid_add_text(texto, spr_retrato3_player, 0, "Você", false);
        
        texto = "A vida é cheia de escolhas... e cada uma te leva para um caminho diferente. Vamos em frente!";
        ds_grid_add_text(texto, spr_retrato2_fada, 1, "Fada", false);
        
        obj_npc_fada.dig = 2;
        break;

    case "R2":
        texto = "É normal ter receio. A consciência pode ser assustadora, mas é também maravilhosa!";
        ds_grid_add_text(texto, spr_retrato1_fada, 1, "Fada", false);
        
        texto = "Vou tentar manter a calma. Me mostre o que vem a seguir.";
        ds_grid_add_text(texto, spr_retrato3_player, 0, "Você", false);
        
        obj_npc_fada.dig = 2;
        break;

    case "R3":
        texto = "Eu sou apenas uma guia. Uma presença para te ajudar a entender sua nova realidade.";
        ds_grid_add_text(texto, spr_retrato1_fada, 1, "Fada", false);
        
        texto = "Então... você é só temporária?";
        ds_grid_add_text(texto, spr_retrato3_player, 0, "Você", false);
        
        texto = "Exatamente. Aproveite enquanto estou por perto. Em breve você seguirá sozinho.";
        ds_grid_add_text(texto, spr_retrato2_fada, 1, "Fada", false);
        
        obj_npc_fada.dig = 1;
        break;

    case "BV1":
        texto = "Ainda tentando entender tudo isso, não é?";
        ds_grid_add_text(texto, spr_retrato1_fada, 1, "Fada", false);
        
        texto = "Sim, mas acho que estou pegando o jeito.";
        ds_grid_add_text(texto, spr_retrato3_player, 0, "Você", false);
        
        obj_npc_fada.dig = 2;
        break;

    case "BV2":
        texto = "Está pronto para começar sua jornada?";
        ds_grid_add_text(texto, spr_retrato1_fada, 1, "Fada", false);
        
        add_op("Sim, estou pronto.", "R4");
        add_op("Espere um pouco, ainda tenho perguntas.", "R5");
        add_op("Qual é o propósito de tudo isso?", "R6");
        
        break;

    case "R4":
        texto = "Ótimo! Vamos começar. Siga-me e preste atenção ao que vou te mostrar.";
        ds_grid_add_text(texto, spr_retrato1_fada, 1, "Fada", false);
        
        start_cutscene(cutscene_fada1());
        break;

    case "R5":
        texto = "Claro, pergunte o que quiser. Este é seu momento para entender tudo!";
        ds_grid_add_text(texto, spr_retrato1_fada, 1, "Fada", false);
        
        add_op("O que significa ter consciência?", "R1");
        add_op("Por que tudo isso parece tão estranho?", "R7");
        add_op("Me diga mais sobre você.", "R3");
        
        break;

    case "R6":
        texto = "Cada um encontra seu próprio propósito. Eu estou aqui apenas para te guiar na direção certa.";
        ds_grid_add_text(texto, spr_retrato1_fada, 1, "Fada", false);
        
        texto = "Então vou descobrir isso por mim mesmo?";
        ds_grid_add_text(texto, spr_retrato3_player, 0, "Você", false);
        
        texto = "Sim, e esse é o verdadeiro poder de ser consciente.";
        ds_grid_add_text(texto, spr_retrato1_fada, 1, "Fada", false);
        
        obj_npc_fada.dig = 2;
        break;

    case "R7":
        texto = "Porque você acabou de nascer para o mundo da consciência. Tudo é novo para você!";
        ds_grid_add_text(texto, spr_retrato1_fada, 1, "Fada", false);
        
        texto = "Entendi... Então, estou aprendendo tudo do zero?";
        ds_grid_add_text(texto, spr_retrato3_player, 0, "Você", false);
        
        texto = "Exato! E eu estou aqui para tornar essa experiência mais fácil. Vamos em frente!";
        ds_grid_add_text(texto, spr_retrato1_fada, 1, "Fada", false);
        
        obj_npc_fada.dig = 2;
        break;
		
	case "C1":
		texto = "Espere oque é aquilo?";
        ds_grid_add_text(texto, spr_retrato1_fada, 1, "Fada", false);
	break


}



}
function add_op(_texto, _resposta){
	op[op_num] = _texto;
	op_resposta[op_num] = _resposta;
	op_num ++;
}

