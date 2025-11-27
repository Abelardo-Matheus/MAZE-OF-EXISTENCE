/// @desc Central de Diálogos do Jogo
/// [O QUE]: Define o conteúdo de todos os diálogos baseado no nome do NPC/Estado.
/// [COMO] : Usa um switch para selecionar o bloco de texto e adiciona linhas à grid de diálogo.

function scr_dialogs()
{
    // Limpa opções anteriores
    op_num = 0; 
	
	
    switch (npc_nome) 
    {
		
		
        // ============================================================
        // NPC: VENDEDORA MISTERIOSA
        // ============================================================
        
        case "Primeiro_encontro":
            dialog_add("Vendedora", spr_retrato1_moca, 0, 
                "*Ajeitando o chapéu* Bem-vindo à minha lojinha, aventureiro! Trouxe mercadorias diretamente das terras do leste!");
            
            dialog_add("Você", spr_retrato3_player, 1, 
                "Sua loja parece... diferente das outras");
            
            dialog_add("Vendedora", spr_retrato2_moca, 0, 
                "*Sorri misteriosamente* Isso porque meu estoque é tão único quanto meus clientes!");
            
            dialog_option("O que tem de especial hoje?", "V1");
            dialog_option("Seus preços são justos?", "V2");
            dialog_option("De onde vem essas mercadorias?", "V3");
            break;

        case "Segundo_encontro":
            dialog_add("Vendedora", spr_retrato2_moca, 0, 
                "*Acenando animadamente* Olá de novo! Trouxe coisas que brilham até no escuro... literalmente!");
            
            dialog_add("Você", spr_retrato2_player, 1, 
                "Não sei se devo confiar...");
            
            dialog_add("Vendedora", spr_retrato1_moca, 0, 
                "*Inclina a cabeça* Confiança se conquista, e eu estou aqui pra isso!");
            
            dialog_option("Mostre-me suas armas", "V4");
            dialog_option("Preciso de proteção", "V5");
            dialog_option("Tem algo... ilícito?", "V6");
            break;

        case "Depois_de_compra":
            dialog_add("Vendedora", spr_retrato3_moca, 0, 
                "*Abanando a mão* Essa peça vai servir bem para você... se souber usar direito!");
            
            dialog_add("Você", spr_retrato1_player, 1, 
                "Isso soou como uma ameaça...");
            
            dialog_add("Vendedora", spr_retrato2_moca, 0, 
                "*Rindo* Apenas um conselho profissional! Volte quando precisar de mais... conselhos!");
            
            dialog_option("Na verdade quero ver mais", "V7");
            dialog_option("Quanto me cobrou a mais?", "V8");
            dialog_option("Até logo", "V9");
            break;

        case "Adeus":
            dialog_add("Vendedora", spr_retrato3_moca, 0, 
                "*Levantando a sombrinha* Que os ventos te levem a tesouros... mas não esqueça de quem te fornece os melhores!");
            
            dialog_add("Você", spr_retrato3_player, 1, 
                "Você é... peculiar");
            
            dialog_add("Vendedora", spr_retrato2_moca, 0, 
                "*Sorrindo maliciosamente* Peculiar é elogio no meu ramo! Até a próxima, cliente!");
            break;

        // --- Respostas da Vendedora ---
        case "V1":
            dialog_add("Vendedora", spr_retrato3_moca, 0, 
                "*Abaixando a voz* Para você... tenho esse artefato que brilha sob a lua cheia. Interessado?");
            par_npc_vendedor_um.abrir_venda = true;
            break;

        case "V2":
            dialog_add("Vendedora", spr_retrato1_moca, 0, 
                "*Franze a testa* Meus preços? Cada moeda reflete o sangue, suor e... bem, principalmente o suor que gastei pra conseguir!");
            par_npc_vendedor_um.abrir_venda = true;
            break;

        case "V3":
            dialog_add("Vendedora", spr_retrato3_moca, 0, 
                "*Gira a sombrinha* Ah, isso é segredo do ofício... mas digamos que conheço rotas pouco convencionais!");
            par_npc_vendedor_um.abrir_venda = true;
            break;


        // ============================================================
        // NPC: FADA DA CONSCIÊNCIA
        // ============================================================

        case "BV0": // Introdução
            dialog_add("Você", spr_retrato1_player, 0, 
                "Olá, quem é você?");
            
            dialog_add("Fada", spr_retrato1_fada, 1, 
                "Ah, finalmente você me vê! Sou a fada da consciência.");
            
            dialog_add("Você", spr_retrato3_player, 0, 
                "Prazer, mas... consciência? O que é isso?");
            
            dialog_add("Fada", spr_retrato2_fada, 1, 
                "Sim, agora você vê o mundo ao seu redor com seus próprios olhos. Está pronto para entender as coisas!");
            
            dialog_add("Você", spr_retrato3_player, 0, 
                "Interessante... O que mais posso fazer?");

            dialog_option("O que significa ter consciência?", "R1");
            dialog_option("Isso parece assustador.", "R2");
            dialog_option("Quem é você, exatamente?", "R3");
            break;

        case "R1":
            dialog_add("Fada", spr_retrato1_fada, 1, 
                "Significa que agora você tem o poder de fazer escolhas e de aprender com elas.");
            
            dialog_add("Você", spr_retrato3_player, 0, 
                "Escolhas, né? O que eu escolho, então?");
            
            dialog_add("Fada", spr_retrato2_fada, 1, 
                "A vida é cheia de escolhas... e cada uma te leva para um caminho diferente. Vamos em frente!");
            
            obj_npc_fada.dig = 2;
            break;

        case "R2":
            dialog_add("Fada", spr_retrato1_fada, 1, 
                "É normal ter receio. A consciência pode ser assustadora, mas é também maravilhosa!");
            
            dialog_add("Você", spr_retrato3_player, 0, 
                "Vou tentar manter a calma. Me mostre o que vem a seguir.");
            
            obj_npc_fada.dig = 2;
            break;

        case "R3":
            dialog_add("Fada", spr_retrato1_fada, 1, 
                "Eu sou apenas uma guia. Uma presença para te ajudar a entender sua nova realidade.");
            
            dialog_add("Você", spr_retrato3_player, 0, 
                "Então... você é só temporária?");
            
            dialog_add("Fada", spr_retrato2_fada, 1, 
                "Exatamente. Aproveite enquanto estou por perto. Em breve você seguirá sozinho.");
            
            obj_npc_fada.dig = 1;
            break;

        case "BV1":
            dialog_add("Fada", spr_retrato1_fada, 1, 
                "Ainda tentando entender tudo isso, não é?");
            
            dialog_add("Você", spr_retrato3_player, 0, 
                "Sim, mas acho que estou pegando o jeito.");
            
            obj_npc_fada.dig = 2;
            break;

        case "BV2":
            dialog_add("Fada", spr_retrato1_fada, 1, 
                "Está pronto para começar sua jornada?");
            
            dialog_option("Sim, estou pronto.", "R4");
            dialog_option("Espere um pouco, ainda tenho perguntas.", "R5");
            dialog_option("Qual é o propósito de tudo isso?", "R6");
            break;

        case "R4": // INICIA CUTSCENE DA FADA
            dialog_add("Fada", spr_retrato1_fada, 1, 
                "Ótimo! Vamos começar. Siga-me e preste atenção ao que vou te mostrar.");
            
            // Usando o novo Builder de Cutscene que criamos
            cutscene_fada1(); 
            break;

        case "R5":
            dialog_add("Fada", spr_retrato1_fada, 1, 
                "Claro, pergunte o que quiser. Este é seu momento para entender tudo!");
            
            dialog_option("O que significa ter consciência?", "R1");
            dialog_option("Por que tudo isso parece tão estranho?", "R7");
            dialog_option("Me diga mais sobre você.", "R3");
            break;

        case "R6":
            dialog_add("Fada", spr_retrato1_fada, 1, 
                "Cada um encontra seu próprio propósito. Eu estou aqui apenas para te guiar na direção certa.");
            
            dialog_add("Você", spr_retrato3_player, 0, 
                "Então vou descobrir isso por mim mesmo?");
            
            dialog_add("Fada", spr_retrato1_fada, 1, 
                "Sim, e esse é o verdadeiro poder de ser consciente.");
            
            obj_npc_fada.dig = 2;
            break;

        case "R7":
            dialog_add("Fada", spr_retrato1_fada, 1, 
                "Porque você acabou de nascer para o mundo da consciência. Tudo é novo para você!");
            
            dialog_add("Você", spr_retrato3_player, 0, 
                "Entendi... Então, estou aprendendo tudo do zero?");
            
            dialog_add("Fada", spr_retrato1_fada, 1, 
                "Exato! E eu estou aqui para tornar essa experiência mais fácil. Vamos em frente!");
            
            obj_npc_fada.dig = 2;
            break;
            
        case "C1":
            dialog_add("Fada", spr_retrato1_fada, 1, 
                "Espere o que é aquilo?");
            break;
   // --- SEGURANÇA CONTRA ERRO ---
        default:
            // Se o nome não for encontrado, mostra isso para te avisar
            dialog_add("Sistema", spr_retrato1_player, 0, "Erro: Diálogo '" + string(npc_nome) + "' não encontrado no script.");
            break;
    } // Fim do switch
}

// ============================================================
// FUNÇÕES AUXILIARES (HELPERS)
// ============================================================

/// @desc Adiciona uma linha de diálogo.
/// @param _name Nome do Personagem
/// @param _portrait Sprite do Retrato
/// @param _side Lado do Retrato (0=Esq, 1=Dir)
/// @param _text O texto da fala
/// @desc Wrapper simplificado para escrever diálogos mais rápido.
function dialog_add(_name, _portrait, _side, _text)
{
    // Chama a função principal passando os argumentos na ordem correta
    // O último argumento 'false' indica que NÃO é uma linha de opção, é fala normal.
    ds_grid_add_text(_text, _portrait, _side, _name, false);
}
/// @desc Adiciona uma opção de resposta.
function dialog_option(_text, _response_id)
{
    op[op_num] = _text;
    op_resposta[op_num] = _response_id;
    op_num++;
}