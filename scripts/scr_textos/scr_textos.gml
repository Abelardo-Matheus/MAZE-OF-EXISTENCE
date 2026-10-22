// feather disable GM2017
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
            obj_par_npc_vendedor_um.abrir_venda = true;
            break;

        case "V2":
            dialog_add("Vendedora", spr_retrato1_moca, 0, 
                "*Franze a testa* Meus preços? Cada moeda reflete o sangue, suor e... bem, principalmente o suor que gastei pra conseguir!");
            obj_par_npc_vendedor_um.abrir_venda = true;
            break;

        case "V3":
            dialog_add("Vendedora", spr_retrato3_moca, 0, 
                "*Gira a sombrinha* Ah, isso é segredo do ofício... mas digamos que conheço rotas pouco convencionais!");
            obj_par_npc_vendedor_um.abrir_venda = true;
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

        // ============================================================
        // TUTORIAL MECÂNICAS
        // ============================================================
        case "Tuto_Move":
            dialog_add("Fada", spr_retrato1_fada, 1, "Bem-vindo ao Labirinto da Existência! Esta é a sua casa. Use WASD ou as setas para andar.");
            dialog_add("Fada", spr_retrato2_fada, 1, "Aperte E para passar as falas. No canto de cima ficam sua VIDA, SANIDADE e a barra de XP.");
            break;
        case "Tuto_Run":
            dialog_add("Fada", spr_retrato1_fada, 1, "Isso! Agora segure SHIFT enquanto anda para CORRER.");
            dialog_add("Fada", spr_retrato2_fada, 1, "Correr gasta ESTAMINA. Ela volta sozinha quando você para de correr, então use com calma.");
            break;
        case "Tuto_Interact":
            dialog_add("Fada", spr_retrato1_fada, 1, "Muito bem! Venha até a sala e fale comigo: chegue perto e aperte F.");
            dialog_add("Fada", spr_retrato2_fada, 1, "O F também serve para abrir armários e baús que você encontrar pelo mundo.");
            break;
        case "Tuto_Pronto":
            dialog_add("Fada", spr_retrato1_fada, 1, "Quando estiver pronto para aprender a lutar, fale comigo de novo (F) e diga que está pronto.");
            break;
        case "Tuto_Combat":
            dialog_add("Fada", spr_retrato1_fada, 1, "Cuidado! Uma Amoeba! Clique com o botão ESQUERDO do mouse para atacar com sua espada.");
            dialog_add("Fada", spr_retrato2_fada, 1, "Você ataca na direção do mouse. Inimigos que encostam em você tiram vida.");
            break;
        case "Tuto_Dash":
            dialog_add("Fada", spr_retrato1_fada, 1, "Agora o DASH: clique com o botão DIREITO do mouse para dar um impulso rápido na direção do mouse.");
            dialog_add("Fada", spr_retrato2_fada, 1, "O dash gasta estamina. Use para fugir quando os inimigos te cercarem!");
            break;
        case "Tuto_Weapon":
            dialog_add("Fada", spr_retrato1_fada, 1, "Você também tem um ARCO! Gire a roda do mouse para trocar entre espada e arco.");
            dialog_add("Fada", spr_retrato2_fada, 1, "Com o arco, segure o botão esquerdo para mirar e solte para atirar de longe.");
            break;
        case "Tuto_XP":
            dialog_add("Fada", spr_retrato1_fada, 1, "Destranquei a PORTA DUPLA no fim do corredor: a sala de brinquedos está aberta!");
            dialog_add("Fada", spr_retrato2_fada, 1, "Inimigos derrotados soltam CRISTAIS DE XP. Pegue os cristais que deixei lá para encher a barra de XP.");
            dialog_add("Fada", spr_retrato1_fada, 1, "Quando a barra enche você SOBE DE NÍVEL: o jogo pausa e mostra cartas de poderes. Escolha uma clicando nela!");
            break;
        case "Tuto_Cartas":
            dialog_add("Fada", spr_retrato1_fada, 1, "Ótima escolha! Existem dois tipos de cartas:");
            dialog_add("Fada", spr_retrato2_fada, 1, "ATIVOS atacam sozinhos sempre que um inimigo chega perto. PASSIVOS melhoram TODOS os seus poderes (área, dano, recarga...).");
            dialog_add("Fada", spr_retrato1_fada, 1, "Você pode ter 4 ativos e 4 passivos diferentes. Depois disso, as cartas só melhoram o que você já tem.");
            dialog_add("Fada", spr_retrato2_fada, 1, "Não gostou das cartas? O botão SORTEAR DE NOVO troca todas, mas só pode ser usado 3 vezes por partida.");
            dialog_add("Fada", spr_retrato1_fada, 1, "E os PETS (sapo, gato, cachorro...) são especiais: você só pode escolher UM, mas ele se multiplica quando sobe de nível!");
            break;
        case "Tuto_Cartas_Presente":
            dialog_add("Fada", spr_retrato1_fada, 1, "Você escolheu um PASSIVO! Eles melhoram todos os seus poderes, mas sozinhos não atacam...");
            dialog_add("Fada", spr_retrato2_fada, 1, "Tome, um ESTILINGUE de presente para o treino! Poderes ATIVOS como ele atacam sozinhos quando um inimigo chega perto.");
            dialog_add("Fada", spr_retrato1_fada, 1, "Você pode ter 4 ativos e 4 passivos diferentes. Depois disso, as cartas só melhoram o que você já tem.");
            dialog_add("Fada", spr_retrato2_fada, 1, "Não gostou das cartas? O botão SORTEAR DE NOVO troca todas, mas só pode ser usado 3 vezes por partida.");
            dialog_add("Fada", spr_retrato1_fada, 1, "E os PETS (sapo, gato, cachorro...) são especiais: você só pode escolher UM, mas ele se multiplica quando sobe de nível!");
            break;
        case "Tuto_Auto":
            dialog_add("Fada", spr_retrato1_fada, 1, "Hora do treino! Algumas amoebas vão aparecer.");
            dialog_add("Fada", spr_retrato2_fada, 1, "Seus poderes atacam sozinhos quando um inimigo chega perto. Ande, desvie e deixe eles trabalharem!");
            break;
        case "Tuto_Resumo":
            dialog_add("Fada", spr_retrato1_fada, 1, "Incrível! Você está pronto. Só mais algumas dicas antes de partir:");
            dialog_add("Fada", spr_retrato2_fada, 1, "Lá fora o dia passa. Quando a NOITE chega, uma HORDA de inimigos aparece. Fique forte durante o dia!");
            dialog_add("Fada", spr_retrato1_fada, 1, "Aperte I (ou TAB) para abrir o INVENTÁRIO e equipar o que encontrar em baús e armários.");
            dialog_add("Fada", spr_retrato2_fada, 1, "Quebre árvores e pedras para conseguir materiais. Com eles você CRAFTA itens no inventário.");
            dialog_add("Fada", spr_retrato1_fada, 1, "Quando quiser começar a aventura, fale comigo (F).");
            break;
        case "Tuto_End":
            dialog_add("Fada", spr_retrato1_fada, 1, "Você está pronto. Deseja sair do tutorial e enfrentar o mundo real agora?");
            dialog_option("Sim, ir para fora.", "Sair_Tutorial");
            dialog_option("Ainda não.", "Ficar_Tutorial");
            break;

        case "Sair_Tutorial":
            // Prepara a transição para a Fase Vamp (zera XP/nível ganhos no tutorial)
            tutorial_resetar_progresso();
            global.fase = 1;
            global.map_vamp = true;

            
            // Destrói o diálogo (o Step do obj_dialogo para logo depois) e libera o jogador
            global.dialogo = false;
            instance_destroy(); 
            if (room_exists(Fase_vamp)) {
                room_goto(Fase_vamp);
            }
            break;

        case "Ficar_Tutorial":
            dialog_add("Fada", spr_retrato1_fada, 1, "Tudo bem, estarei aqui quando você decidir partir.");
            break;

        case "Tuto_Combat_Win":
            dialog_add("Fada", spr_retrato1_fada, 1, "Excelente! Você a derrotou com facilidade.");
            dialog_add("Fada", spr_retrato2_fada, 1, "Mas nem tudo pode ser resolvido com força bruta. No labirinto, saber quando fugir é tão importante quanto saber atacar.");
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