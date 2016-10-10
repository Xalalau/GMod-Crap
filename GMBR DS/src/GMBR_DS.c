#include "GMBR_DS.h"

typedef struct {
  char secao1[7];
  char secao2[9];
  char secao3[7];
  char secao4[8];
} cfgini;

cfgini cfg;

int telaInicial(no *contents, no *parametros, char dir_base[], char steamcmd_tudo[], char temp[], int quant_livrarias, char livrarias[quant_livrarias][MAX_CHAR_DIR]) {
  // Apresentacao, menu e tela de exibicao das configuracoes carregadas
  // Retorna a opcao da pessoa

  int i, h, num=6, j[num], ruim, escolha;
  char *prt;
  no *temp2;

  // Elimina o lixo do array
  for (i=0; i<=num; i++)
    j[i] = -1;

  while (1) {
    CLRSCR;
    h = 1;
    printf("__.d8888b.__888b_____d888_888888b.___8888888b._______8888888b.___.d8888b.\n");
    printf("_d88P__Y88b_8888b___d8888_888___88b__888___Y88b______888___Y88b_d88P__Y88b\n");
    printf("_888____888_88888b.d88888_888__d88P__888____888______888____888_Y88b.\n");
    printf("_888________888Y88888P888_8888888K.__888___d88P______888____888___Y888b.\n");
    printf("_888__88888_888_Y888P_888_888___Y88b_8888888P8_______888____888_______Y88b.\n");
    printf("_888____888_888__Y8P__888_888____888_888_T88b________888____888+_______888\n");
    printf("_Y88b__d88P_888___8___888_888___d88P_888__T88b_______888__.d88P_Y88b__d88P\n");
    printf("__Y8888P88__888_______888_8888888P8__888___T88b______8888888P_____Y8888P\n");
    printf("\n");
    printf("Garry's Mod Brasil Dedicated Server - GMBR DS\n");
    printf("Feito por Xalalau - Garry s Mod Brasil, GMBR\n");
    printf("http://www.gmbrblog.blogspot.com.br/\n");
    printf("http://mrxalalau.blogspot.com.br/\n");
    printf("____________________________________________________________________[v2.7]\n");
    printf("\n");

    /* MENU PRINCIPAL
     *
     * Opcao tipo:
     * (A) E exibida ou nao de acordo com a configuracoes dos contents;
     * (B) Nao e exibida se o sv de GMod estiver desinstalado.
     *
     * Escolhas de 1 a 6:
     *
     * 1 - definicoes
     * 2 - gmod
     * 3 - contents (A)
     * 4 - gmod e contents (A)
     * 5 - ligar sv (B)
     * 6 - montar contents (A)(B)
     *
     * Como elas sao listadas no menu de acordo com as configuracoes, fiz um array de 6 casas (j[num])
     * e guardei a numeraco que vai aparecer para cada uma. Depois do usuario fazer a escolha,
     * eu converto ela para os numeros acima e o programa sabe o que fazer.
     *
    */

    printf("%d: Ver as configuracoes carregadas...\n", h);
    j[0] = h++;
    printf("%d: Instalar/atualizar o servidor de GMod...\n", h);
    j[1] = h++;
    temp2 = contents;
    while ((*temp2).proxima_secao != NULL) {
      if (strcmp(ini_buscar(temp2, "opcao", (*temp2).secao), "1") == 0) {
        printf("%d: Instalar/atualizar os contents...\n", h);
        j[2] = h++;
        printf("%d: Instalar/atualizar o servidor de GMod e os contents...\n", h);
        j[3] = h++;
        break;
      }
      temp2 = (*temp2).proxima_secao;
    }
    if (geral_verificarExistencia(ini_buscar(parametros, "arq_srcds", cfg.secao2)) == 1) {
      printf("%d: Iniciar o servidor...\n", h);
      j[4] = h++;
      printf("%d: Forcar montagem de contents...\n", h);
      j[5] = h++;
    }
    printf("0: Sair...\n");
    printf("\n");
    printf("Escolha: ");
    scanf("%s", temp);

    // Converte o string para int
    escolha = strtol(temp, &prt, 10);

    // Se houver lixo na entrada, reinicia o menu
    if (strcmp(prt, "") != 0)
      continue;

    // Converte a entrada para um numero fixo de opcao (ver no menu acima: j[numero fixo])
    ruim = 1;
    for (i=0; i<=num; i++)
      if (j[i] == escolha) {
        escolha = i + 1;
        ruim = 0;
        break;
      }

    // Se a opcao nao tiver sido convertida no passo anterior ou nao for 0, reinicia o menu
    if ((ruim == 1) && (escolha != 0))
      continue;

    // Exibicao das configuracoes
    if (escolha == 1) {
      CLRSCR;
      printf("______________________________________________________________________________\n");
      printf("\n");
      printf("CONFIGURACOES CARREGADAS:\n");
      printf("\n");
      printf("\n");
      printf("Pasta base:\n");
      for (i = 0; i < strlen(dir_base) - 1; i++)
        printf("%c", dir_base[i]);
      printf("\n\nPasta do servidor de GMod:\n%s\n\n",ini_buscar(parametros, "pasta_servidor", cfg.secao1));
      printf("Pasta dos contents:\n%s\n\n",ini_buscar(parametros, "pasta_contents", cfg.secao1));
      printf("Pasta do Steam:\n%s\n\n", ini_buscar(parametros, "pasta_steam", cfg.secao1));
      printf("Pasta do SteamCMD:\n%s\n\n", ini_buscar(parametros, "pasta_steamcmd", cfg.secao1));
      if (quant_livrarias > 0) {
        printf("Pastas de livrarias:\n");
        for (i = 0; i < quant_livrarias; i++)
          printf("[%d] %s\n", i + 1, livrarias[i]);
      printf("\n");
      }
      printf("Link de download do SteamCMD:\n%s\n\n", ini_buscar(parametros, "download_steamcmd", cfg.secao3));
      printf("Arquivo executavel do SteamCMD:\n%s\n\n",steamcmd_tudo);
      printf("Arquivo executavel do SRCDS:\n%s\n\n", ini_buscar(parametros, "arq_srcds", cfg.secao2));
      printf("Comando para iniciar o servidor:\n'%s' %s\n\n", ini_buscar(parametros, "arq_srcds", cfg.secao2), ini_buscar(parametros, "comando_servidor", cfg.secao4));
      printf("Informacoes do GMod e contents:\n\n");
      printf("[%s]\n", ini_buscar(parametros, "jogo_nome", cfg.secao3));
      printf("  pasta = %s\n", ini_buscar(parametros, "pasta_servidor", cfg.secao1));
      printf("  id = %s\n", ini_buscar(parametros, "jogo_id", cfg.secao3));
      temp2 = contents;
      while ((*temp2).proxima_secao != NULL) {
        if (strcmp(ini_buscar(temp2, "opcao", (*temp2).secao), "3") != 0) {
          printf("\n");
          if (strcmp(ini_buscar(temp2, "opcao", (*temp2).secao), "1") == 0) {
            printf("[%s]\n", (*temp2).secao);
            printf("  pasta = %s\n", ini_buscar(temp2, "pasta", (*temp2).secao));
            printf("  login = %s\n", ini_buscar(temp2, "login", (*temp2).secao));
            printf("  id    = %s\n", ini_buscar(temp2, "id", (*temp2).secao));
            printf("  opcao = %s\n", ini_buscar(temp2, "opcao", (*temp2).secao));
          } else if (strcmp(ini_buscar(temp2, "opcao", (*temp2).secao), "2") == 0) {
            printf("[%s]\n", (*temp2).secao);
            printf("  steam = %s\n", ini_buscar(temp2, "steam", (*temp2).secao));
            printf("  opcao = %s\n", ini_buscar(temp2, "opcao", (*temp2).secao));
          }
        }
        temp2 = (*temp2).proxima_secao;
      }
      printf("\n");
      printf("______________________________________________________________________________\n");
      printf("\n");
      printf("\n");
      geral_pausar();
      continue;
    // Quebra do menu para processamento de opcoes validas
    } else if ((escolha == 0) ||
              (escolha == 2) ||
              (escolha == 3) ||
              (escolha == 4) ||
              (escolha == 5) ||
              (escolha == 6)) {
      return escolha;
    }
    // Se chegar aqui, reentrada no loop
  }
}

int buscarLivrarias(char arquivo[], int quant_max_livrarias, char livrarias[quant_max_livrarias][MAX_CHAR_DIR], int *quant_livrarias) {
  // Le o arquivo de livrarias de jogos do Steam
  // 1 = Carregou as pastas, 2 = Erro ao abrir o arquivo, 3 = Excedeu o limite maximo de livrarias do GMBR DS

  FILE *fp;
  int i = 0, k = 0;
  char c, caracteres[MAX_CHAR_DIR];
  char *prt;

  fp = fopen(arquivo, "r");

  // Verifica se houve erro ao abrir o arquivo
  if (fp == NULL)
    return 2;

  /*
  Resumo desse While:
  Busco por uma aspa e leio os caracteres até achar outra aspa.
  - Se for um número, leio o proximo valor entre aspas.
  - Se nao for, procuro a proxima linha.
  */
  while ((c = getc(fp)) != EOF) {
    // busco a primeira aspa
    if (c == '"') {
      while ((c = fgetc(fp)) != EOF) {
        // Capturo os caracteres em um array ate achar outra aspa
        if (c != '"')
          caracteres[k++] = c;
        // Verifico se o array contem um numero
        else {
          caracteres[k] = '\0';
          // Se nao for um numero: busco o fim de linha, zero o K e continuo em busca de outro caso valido
          if (strtol(caracteres, &prt, 10) == 0)
            while ((c = fgetc(fp)) != EOF) {
              if (c == '\n') {
                k = 0;
                break;
              }
            }
          // Se for um numero: guardo o valor entre as proximas aspas, pois e uma pasta de livraria do Steam
          else {
            k = 0;
            while ((c = fgetc(fp)) != EOF) {
              if (c == '"') {
                while ((c = fgetc(fp)) != EOF) {
                  if (c != '"')
                    caracteres[k++] = c;
                  else {
                    caracteres[k] = '\0';
                    k = 0;
                    // Verifica o limite de livrarias do GMBR DS antes de guarda-la
                    if (i <= quant_max_livrarias) {
                      strcpy(livrarias[i++], caracteres);
                      break;
                    } else
                      return 3;
                  }
                }
                break;
              }
            }
          }
          break;
        }
      }
    }
  }

  fclose(fp);

  *quant_livrarias = i;

  return 1;
}

void ajustarVariaveis(char dir_base[], char temp[], char steamcmd_tudo[], char steam_falha[], no *parametros, no *contents) {
  // Ajusta as informacoes que foram carregadas dos arquivos de configuracoes

  no* temp2 = contents;

  // Redefine o caminho para a pasta base se ela estiver alterada nas configuracoes
  if ((strcmp(ini_buscar(parametros, "pasta_base", cfg.secao1), "")) != 0)
    strcpy(dir_base, strcat(strcpy(temp, ini_buscar(parametros, "pasta_base", cfg.secao1)), BARRA));
  // Define o caminho da pasta dos contents
  if (geral_existeCharXNaStringY(BARRA[0], ini_buscar(parametros, "pasta_contents", cfg.secao1)) == 0) {
    strcat(strcpy(temp, dir_base), ini_buscar(parametros, "pasta_contents", cfg.secao1));
    ini_alterar_valor(parametros, "pasta_contents", cfg.secao1, temp);
  }
  // Define o caminho da pasta do SteamCMD
  if (geral_existeCharXNaStringY(BARRA[0], ini_buscar(parametros, "pasta_steamcmd", cfg.secao1)) == 0) {
    strcat(strcpy(temp, dir_base), ini_buscar(parametros, "pasta_steamcmd", cfg.secao1));
    ini_alterar_valor(parametros, "pasta_steamcmd", cfg.secao1, temp);
  }
  // Define o caminho para a pasta do servidor de GMod
  if (geral_existeCharXNaStringY(BARRA[0], ini_buscar(parametros, "pasta_servidor", cfg.secao1)) == 0) {
    strcat(strcpy(temp, dir_base), ini_buscar(parametros, "pasta_servidor", cfg.secao1));
    ini_alterar_valor(parametros, "pasta_servidor", cfg.secao1, temp);
  }
  // Define os caminhos das pastas dos contents
  while ((*temp2).proxima_secao != NULL) {
    if (strcmp(ini_buscar(temp2, "opcao", (*temp2).secao), "1") == 0) {
      strcat(strcat(strcpy(temp, ini_buscar(parametros, "pasta_contents", cfg.secao1)), BARRA), ini_buscar(temp2, "pasta", (*temp2).secao));
      ini_alterar_valor(temp2, "pasta", (*temp2).secao, temp);
    }
    temp2 = (*temp2).proxima_secao;
  }
  // Define o caminho para o arquivo steamcmd.exe
  strcpy(steamcmd_tudo, strcat(strcat(strcpy(temp, ini_buscar(parametros, "pasta_steamcmd", cfg.secao1)), BARRA), ini_buscar(parametros, "arq_steamcmd", cfg.secao2)));
  // Define o caminho para o srcds_run.exe
  strcpy(temp, strcat(strcat(strcpy(temp, ini_buscar(parametros, "pasta_servidor", cfg.secao1)), BARRA), ini_buscar(parametros, "arq_srcds", cfg.secao2)));
  ini_alterar_valor(parametros, "arq_srcds", cfg.secao2, temp);
  // Define o caminho para o arquivo de livrarias
  if (strcmp(ini_buscar(parametros, "pasta_steam", cfg.secao1), steam_falha) != 0) {
    if (strcmp(SISTEMA,"Linux") == 0) {
      strcat(strcat(strcat(strcat(strcpy(temp, ini_buscar(parametros, "pasta_steam", cfg.secao1)), BARRA), "steam/steamapps"), BARRA), "libraryfolders.vdf");
      ini_alterar_valor(parametros, "arq_livrarias", cfg.secao2, temp);
    } else if (strcmp(SISTEMA,"Windows") == 0) {
      strcat(strcat(strcat(strcat(strcpy(temp, ini_buscar(parametros, "pasta_steam", cfg.secao1)), BARRA), "steamapps"), BARRA), "libraryfolders.vdf");
      ini_alterar_valor(parametros, "arq_livrarias", cfg.secao2, temp);
    }
  }

  // Define o correto valor de login do SteamCDM em cada membro de "contents.ini"
  temp2 = contents;
  while ((*temp2).proxima_secao != NULL) {
    if (strcmp(ini_buscar(temp2, "login", (*temp2).secao), "Anonimo") == 0)
      ini_alterar_valor(temp2, "login", (*temp2).secao, "anonymous");
    else if (strcmp(ini_buscar(temp2, "login", (*temp2).secao), "Usuario") == 0)
      ini_alterar_valor(temp2, "login", (*temp2).secao, ini_buscar(parametros, "login_steam", cfg.secao3));
    else
      ini_alterar_valor(temp2, "login", (*temp2).secao, "Indisponivel");
    temp2 = (*temp2).proxima_secao;
  }
}

int verificarContents(char temp[], char steam_falha[], no *contents, no *parametros, int quant_livrarias, char livrarias[quant_livrarias][MAX_CHAR_DIR]) {
  // Verifica se os contents estao presentes no caminho informado
  // 0 = leitura bem sucedida,
  // -1 = pasta do content nao encontrada,
  // 100 = nenhum content foi configurado para 2,
  // 101 = A pasta do Steam nao esta configurada e ha contents do tipo 2.

  int j, existem_contents_tipo_2 = 0;
  char aux[MAX_CHAR_DIR];

  while ((*contents).proxima_secao != NULL) {
    if (strcmp(ini_buscar(contents, "opcao", (*contents).secao), "2") == 0) {
      // Avisa que pelo menos 1 content esta configurado com opcao 2
      if (existem_contents_tipo_2 == 0)
        existem_contents_tipo_2 = 1;
      // Verifica se "Caminho do content" e um endereco completo
      if (geral_verificarExistencia(ini_buscar(contents, "steam", (*contents).secao)) == 2) {
        // Verifica se a pasta do Steam esta configurada
        if (strcmp(ini_buscar(parametros, "pasta_steam", cfg.secao1), steam_falha) == 0)
          return 101;
        // Verifica se existe "Steam + Caminho content"
        else if (geral_verificarExistencia(strcat(strcpy(aux, ini_buscar(parametros, "pasta_steam", cfg.secao1)), ini_buscar(contents, "steam", (*contents).secao))) == 1)
          ini_alterar_valor(contents, "steam", (*contents).secao, aux);
        // Verifica se existe "Steam + BARRA + Caminho content"
        else if (geral_verificarExistencia(strcat(strcat(strcpy(aux, ini_buscar(parametros, "pasta_steam", cfg.secao1)), BARRA), ini_buscar(contents, "steam", (*contents).secao))) == 1)
          ini_alterar_valor(contents, "steam", (*contents).secao, aux);
        else
          for (j = 0; j < quant_livrarias; j++) {
            // Verifica se existe "livraria + Caminho content"
            if ((geral_verificarExistencia(strcat(strcpy(aux, livrarias[j]), ini_buscar(contents, "steam", (*contents).secao)))) == 1)
              ini_alterar_valor(contents, "steam", (*contents).secao, aux);
            // Verifica se existe "livraria + BARRA + Caminho content"
            else if ((geral_verificarExistencia(strcat(strcat(strcpy(aux, livrarias[j]), BARRA), ini_buscar(contents, "steam", (*contents).secao)))) == 1)
              ini_alterar_valor(contents, "steam", (*contents).secao, aux);
          }
        // Se o content ainda nao for valido, retorno o numero dele indicando erro
        if (geral_verificarExistencia(ini_buscar(contents, "steam", (*contents).secao)) == 2) {
          strcpy(temp, (*contents).secao);
          return -1;
        }
      }
    }
    contents = (*contents).proxima_secao;
  }
  if (existem_contents_tipo_2 == 1)
    return 0;
  else if (existem_contents_tipo_2 == 0)
    return 100;
}

int encontrarSteam(no *parametros, char temp[]) {
  // Tenta encontrar a pasta do Steam para o usuario
  // 1 = Encontrado, 2 = Nao encontrado

  if (strcmp(SISTEMA,"Linux") == 0) {
    struct passwd *pw;
    const char *homedir;
    DPADRAO(pw);
    DPADRAO2(pw, homedir);
    if (geral_verificarExistencia(strcat(strcat(strcat(strcat(strcpy(temp, homedir), BARRA), ".steam"), BARRA), ini_buscar(parametros, "arq_steam", cfg.secao2))) == 1) {
      strcpy(ini_buscar(parametros, "pasta_steam", cfg.secao1), strcat(strcat(strcpy(temp, homedir), BARRA), ".steam"));
      return 1;
    }
  } else if (strcmp(SISTEMA,"Windows") == 0) {
    char unidade[5][3] = {"C:", "D:", "E:", "F:", "G:"};
    char pasta[5][36] = {"\\Steam", "\\Program Files (x86)\\Steam", "\\Program Files\\Steam", "\\Arquivos de Programas (x86)\\Steam", "\\Arquivos de Programas\\Steam"};
    int i,k;

    for (i=0; i<=3; i++)
      for (k=0; k<=4; k++)
        if (geral_verificarExistencia(strcat(strcat(strcat(strcpy(temp, unidade[i]), pasta[k]), BARRA), ini_buscar(parametros, "arq_steam", cfg.secao2))) == 1) {
          strcpy(ini_buscar(parametros, "pasta_steam", cfg.secao1), strcat(strcpy(temp, unidade[i]), pasta[k]));
          return 1;
        }
  }
  return 2;
}

int instalarSteamCMD(no *parametros, char temp[], char steamcmd_tudo[]) {
  // Instala o SteamCMD
  // 1 = OK, 2 = Erro no download, 3 = Erro na extracao

  char *partes, *parte_certa, arquivo[30], s[2]="/";

  // Verifica se existe o executavel do SteamCMD
  if (geral_verificarExistencia(steamcmd_tudo) == 2) {
    // Preciso do nome do arquivo comprimido
    //-----------------------------------------
    // Copio para temp o link de download (para nao perde-lo no passo seguinte)
    strcpy(temp, ini_buscar(parametros, "download_steamcmd", cfg.secao3));
    // Explodo temp nas barras
    partes = strtok(temp, s);
    // Rodo o loop ate apontar para o nome do arquivo e salvo em parte_certa (partes sai nulo daqui)
    while(partes != NULL) {
      parte_certa = partes;
      partes = strtok(NULL, s);
    }
    // Tenho o nome do arquivo pronto
    strcpy(arquivo, parte_certa);
    //-----------------------------------------
    // Define o caminho do arquivo por completo
    strcat(strcat(strcpy(temp, ini_buscar(parametros, "pasta_steamcmd", cfg.secao1)), BARRA), arquivo);
    // Remove algum download antigo do SteamCMD que possa existir
    if (geral_verificarExistencia(temp) == 1)
      remove(temp);
    // Faz o download do SteamCMD
    if (strcmp(SISTEMA,"Linux") == 0)
      strcpy(temp, "wget ");
    else if (strcmp(SISTEMA,"Windows") == 0)
      strcpy(temp, "bin\\wget ");
    strcat(strcat(strcat(strcat(temp, ini_buscar(parametros, "download_steamcmd", cfg.secao3)), " -P \""), ini_buscar(parametros, "pasta_steamcmd", cfg.secao1)), "\"");
    if ((system(temp)) != 0)
      return 2;
    // Extrai o download (Considero o SteamCMD como instalado agora)
    if (strcmp(SISTEMA,"Linux") == 0)
      strcat(strcat(strcat(strcat(strcat(strcat(strcat(strcat(strcpy(temp, "tar -xvzf \""), ini_buscar(parametros, "pasta_steamcmd", cfg.secao1)), BARRA), arquivo), "\""), " -C "), "\""), ini_buscar(parametros, "pasta_steamcmd", cfg.secao1)), "\"");
    else if (strcmp(SISTEMA,"Windows") == 0)
      strcat(strcat(strcat(strcat(strcat(strcat(strcat(strcat(strcpy(temp, "bin\\unzip.exe \""), ini_buscar(parametros, "pasta_steamcmd", cfg.secao1)), BARRA), arquivo), "\""), " -d "), "\""), ini_buscar(parametros, "pasta_steamcmd", cfg.secao1)), "\"");
    if ((system(temp)) != 0)
      return 3;
  }
  return 1;
 }

int instalacaoAtualizacaoSV(no *entrada, no *parametros, char temp[], char temp2[], char secao[]) {
  // Instala o GMod e os contents
  // 1 = Instalacao bem sucedida,
  // 2 = Nao e um content do tipo disponivel para downlaod,
  // 3 = A instalação requer login no Steam,
  // 4 = Erro

  char parte[12], pasta[MAX_CHAR_DIR], id[MAX_CHAR_SECAO];
  
  // GMod
  if (ini_buscar(entrada, "login", (*entrada).secao) == NULL) {
    // Ajeita a variavel login
    strcpy(temp2, "anonymous");
    // Ajeita a variavel da pasta
    strcpy(pasta, ini_buscar(entrada, "pasta_servidor", cfg.secao1));
    // Ajeita a variavel de id
    strcpy(id, ini_buscar(entrada, "jogo_id", cfg.secao3));
  // Contents
  } else {
    // Busca a secao certa
    while ((*entrada).proxima_secao != NULL) {
      if (strcmp((*entrada).secao, secao) == 0)
        break;
      entrada = (*entrada).proxima_secao;
    }
    // Ajeita a variavel login
    if (strcmp(ini_buscar(entrada, "login", (*entrada).secao), "Indisponivel") == 0)
      return 2;
    else if (strcmp(ini_buscar(entrada, "login", (*entrada).secao), "Usuario") == 0)
      return 3;
    else
    strcpy(temp2, ini_buscar(entrada, "login", (*entrada).secao));
    // Mensagem para pessoas que precisarem logar no SteamCMD
    if (strcmp(temp2, "anonymous") != 0)
      printf("[GMBR DS] Esteja logado no Steam com a mesma conta do GMBR DS para baixar este content\n");
    // Ajeita a variavel da pasta
    strcpy(pasta, ini_buscar(entrada, "pasta", (*entrada).secao));
    // Ajeita a variavel de id
    strcpy(id, ini_buscar(entrada, "id", (*entrada).secao));
  }
  // Acerta um pedaco do comando do servidor
  if (strcmp(SISTEMA,"Linux") == 0)
    strcpy(parte, "\" && ./");
  else if (strcmp(SISTEMA,"Windows") == 0)
    strcpy(parte, "\" & ");
  // Faz o comando por inteiro
  strcat(strcat(strcat(strcat(strcat(strcat(strcat(strcat(strcat(strcat(strcat(strcat(strcpy(temp, "cd \""), ini_buscar(parametros, "pasta_steamcmd", cfg.secao1)), parte), ini_buscar(parametros, "arq_steamcmd", cfg.secao2)), " +login "), temp2), " +force_install_dir "), "\""), pasta), "\""), " +app_update "), id), " validate +quit");
  // Mostra o comando
  printf("[GMBR DS] %s\n\n", temp);
  // Roda o comando
  if ((system(temp)) != 0)
    return 4;
  return 1;
}

int montarContents(no* contents, char temp[]) {
  // Escreve as informacoes dos contents no GMod conforme o escolhido para que eles sejam montados ao abrir o servidor
  // 1 = OK, 2 = Arquivo nao existe, 3 = Erro ao abrir o arquivo

  FILE *fp;

  memset(temp,0,strlen(temp)); // Elimina um lixo maluco aleatorio da variavel
  strcat(strcat(strcat(strcat(strcat(strcat(strcpy(temp, ini_buscar(contents, "pasta", (*contents).secao)), BARRA), "garrysmod"), BARRA), "cfg"), BARRA), "mount.cfg");

  if (geral_verificarExistencia(temp) == 2)
    return 2;
  else {
    remove(temp);
    fp = fopen(temp, "w");
    // Verifica se houve erro ao abrir o arquivo
    if (fp == NULL)
      return 3;
    fprintf(fp, "\"mountcfg\"%s{%s", PULO, PULO);
    while ((*contents).proxima_secao != NULL) {
      if (strcmp(ini_buscar(contents, "opcao", (*contents).secao), "1") == 0)
        fprintf(fp, "\t\"%s\" \"%s\"%s", (*contents).secao, ini_buscar(contents, "pasta", (*contents).secao), PULO);
      else if (strcmp(ini_buscar(contents, "opcao", (*contents).secao), "2") == 0)
        fprintf(fp, "\t\"%s\" \"%s\"%s", (*contents).secao, ini_buscar(contents, "steam", (*contents).secao), PULO);
      contents = (*contents).proxima_secao;
    }
    fprintf(fp, "}");
  }

  fclose(fp);

  return 1;
}

void ligarServer(no *parametros, char temp[]) {
  // Abre o servidor de GMod
  if (strcmp(SISTEMA,"Linux") == 0) {
    strcpy(temp, strcat(strcat(strcat(strcat(strcpy(temp, "\""), ini_buscar(parametros, "arq_srcds", cfg.secao2)), "\""), " "), ini_buscar(parametros, "comando_servidor", cfg.secao4)));
    system(temp);
  } else if (strcmp(SISTEMA,"Windows") == 0)
    ShellExecute(NULL, "open", ini_buscar(parametros, "arq_srcds", cfg.secao2), ini_buscar(parametros, "comando_servidor", cfg.secao4), NULL, SW_SHOWDEFAULT);
}

int main() {
  // Funcao principal
  // 0 = bem sucedida, -1 = mal sucedida

  int quant_livrarias, quant_max_livrarias = 4, i, j, retorno, escolha = -1;
  char dir_base[MAX_CHAR_DIR], temp[MAX_CHAR_PARAMETRO_VALOR], temp2[MAX_CHAR_PARAMETRO_VALOR], steamcmd_tudo[MAX_CHAR_DIR], steam_falha[] = "NAO ENCONTRADA!", livrarias[quant_max_livrarias][MAX_CHAR_DIR];
  no *contents, *contentsAux, *parametros;

  strcpy(cfg.secao1, "Pastas");
  strcpy(cfg.secao2, "Arquivos");
  strcpy(cfg.secao3, "Outros");
  strcpy(cfg.secao4, "Comando");

  /*
    * --------------------------------------------------------------------------------
    * REFINAMENTO DAS INFORMACOES DOS ARQUIVOS DE CONFIGURACAO
    * --------------------------------------------------------------------------------
  */

  CLRSCR;

  // Define o diretorio base como o corrente por padrão (Pode ser definido no arquivo de configuracao - funcao ajustarVariaveis())
  if ((retorno = geral_pegarPastaCorrente(dir_base)) == 1) {
    printf("[GMBR DS] Diretorio corrente obtido\n");
  } else if (retorno == 2) {
    printf("\n[GMBR DS]----------------------------------------------------------------\n");
    printf("# ERRO AO LER O CAMINHO DA PASTA CORRENTE #\n");
    printf("-------------------------------------------------------------------------\n\n");
    geral_pausar();
    return -1;
  }

  // Carrega as informacoes do arquivo cfg.ini
  if ((retorno = geral_verificarExistencia(strcat(strcat(strcat(strcpy(temp, dir_base),"cfg"), BARRA),"cfg.ini"))) != 2) {
    if ((parametros = ini_ler(temp)) != NULL) {
      printf("[GMBR DS] Arquivo cfg.ini carregado\n");
    } else {
      printf("\n[GMBR DS]--------------------------------------------------------------\n");
      printf("ERRO AO CARREGAR AS OPCOES DO ARQUIVO '%s'!\n", temp);
      printf("VERIFIQUE SE TODOS OS PARAMETROS ESTAO PRESENTES E BEM FORMATADOS\n");
      printf("-----------------------------------------------------------------------\n\n");
      geral_pausar();
      return -1;
    }
  } else if (retorno == 2) {
    printf("\n[GMBR DS]--------------------------------------------------------------\n");
    printf("NAO FOI POSSIVEL CARREGAR O ARQUIVO '%s'!\n", temp);
    printf("1) VERIFIQUE SE ELE ESTA PRESENTE NA PASTA 'CFG'\n");
    printf("2) VERIFIQUE SE TODOS OS PARAMETROS ESTAO PRESENTES E BEM FORMATADOS\n");
    printf("-----------------------------------------------------------------------\n\n");
    geral_pausar();
    return -1;
  }

  // Carrega as informacoes do arquivo contents.ini
  if ((retorno = geral_verificarExistencia(strcat(strcat(strcat(strcpy(temp, dir_base), "cfg"), BARRA),"contents.ini"))) == 1) {
    if ((contents = ini_ler(temp)) != NULL) {
      printf("[GMBR DS] Arquivo contents.ini carregado\n");
    } else {
      printf("\n[GMBR DS]--------------------------------------------------------------\n");
      printf("ERRO AO CARREGAR O ARQUIVO '%s'\n", temp);
      printf("-----------------------------------------------------------------------\n\n");
      geral_pausar();
      return -1;
    }
  } else if (retorno == 2) {
    printf("\n[GMBR DS]--------------------------------------------------------------\n");
    printf("NAO FOI POSSIVEL CARREGAR O ARQUIVO '%s'\n", temp);
    printf("-----------------------------------------------------------------------\n\n");
    geral_pausar();
    return -1;
  }

  // Busca/Verifica/Salva o caminho para a pasta do Steam (Pode ser definido no arquivo de configuracao)
  if (strcmp(ini_buscar(parametros, "pasta_steam", cfg.secao1),"") == 0) {
    if ((retorno = encontrarSteam(parametros, temp)) == 1) {
      printf("[GMBR DS] Pasta do Steam localizada\n");
    } else if (retorno == 2) {
      ini_alterar_valor(parametros, "pasta_steam", cfg.secao1, steam_falha);
    }
  } else {
    if ((retorno = geral_verificarExistencia(strcat(strcat(strcpy(temp, ini_buscar(parametros, "pasta_steam", cfg.secao1)), BARRA), ini_buscar(parametros, "arq_steam", cfg.secao2)))) == 1) {
      printf("[GMBR DS] A pasta do Steam foi localizada\n");
    } else if (retorno == 2) {
      printf("\n[GMBR DS]--------------------------------------------------------------\n");
      printf("A PASTA DO STEAM '%s' E INVALIDA:\n", ini_buscar(parametros, "pasta_steam", cfg.secao1));
      printf("-----------------------------------------------------------------------\n\n");
      geral_pausar();
      return -1;
    }
  }

  // Ajusto a maioria das variaveis para seus valores completos
  ajustarVariaveis(dir_base, temp, steamcmd_tudo, steam_falha, parametros, contents);
  printf("[GMBR DS] Variaveis reajustadas\n");

  // Busca/Salva caminhos de livrarias de jogos do Steam
  if (strcmp(ini_buscar(parametros, "pasta_steam", cfg.secao1), steam_falha) != 0) {
    if ((retorno = buscarLivrarias(ini_buscar(parametros, "arq_livrarias", cfg.secao2), quant_max_livrarias, livrarias, &quant_livrarias)) == 1) {
      printf("[GMBR DS] Livrarias de contents do Steam carregadas\n");
    } else if (retorno == 2) {
      printf("\n[GMBR DS]--------------------------------------------------------------\n");
      printf("ERRO AO ABRIR O ARQUIVO DE LIVRARIAS DO STEAM!\n");
      printf("'%s'\n", ini_buscar(parametros, "arq_livrarias", cfg.secao2));
      printf("-----------------------------------------------------------------------\n\n");
      geral_pausar();
      return -1;
    } else {
      printf("\n[GMBR DS]--------------------------------------------------------------\n");
      printf("O NUMERO DE LIVRARIAS DO STEAM EXCEDEU O LIMITE DO GMBR DS, QUE E %d!\n", quant_max_livrarias + 1);
      printf("POR FAVOR, CONTACTE ALGUM MEMBRO DO GMBR PARA QUE ESSE LIMITE SEJA AUMENTADO\n");
      printf("OU TENTE RECOMPILAR O PROJETO VOCE MESMO. TER MENOS LIVRARIAS TAMBEM E UMA\n");
      printf("OPCAO.\n");
      printf("-----------------------------------------------------------------------\n\n");
      geral_pausar();
      return -1;
    }
  }

  // Verifica se os contents marcados com opcao 2 estao validos para uso e acerta seus caminhos caso necessario
  if ((retorno = verificarContents(temp, steam_falha, contents, parametros, quant_livrarias, livrarias)) == 0) {
    printf("[GMBR DS] Os contents com opcao 2 sao validos\n");
  } else if (retorno == 100) {
    printf("[GMBR DS] Nao ha contents com opcao 2\n");
  } else if (retorno == 101) {
    printf("\n[GMBR DS]--------------------------------------------------------------\n");
    printf("O GMBR DS NAO FOI CAPAZ DE ENCONTRAR A PASTA DO STEAM AUTOMATICMENTE!\n");
    printf("PARA PODER USAR SEUS CONTENTS QUE FORAM MARCADOS COM A OPCAO 2, INSIRA-A\n");
    printf("NO ARQUIVO 'CFG.INI' !OU! ESCREVA O ENDERECO DE DIRETORIO COMPLETO DELES\n");
    printf("EM 'CONTENTS.TXT'.\n");
    printf("-----------------------------------------------------------------------\n\n");
    geral_pausar();
    return -1;
  } else {
    printf("\n[GMBR DS]--------------------------------------------------------------\n");
    printf("A PASTA DO CONTENT '%s' E INVALIDA!\n", temp);
    printf("CHEQUE SE ELA EXISTE EM STEAMAPPS OU SE VOCE ESCREVEU CORRETAMENTE:\n");
    printf("'%s'\n", ini_buscar(contents, "steam", temp));
    printf("-----------------------------------------------------------------------\n\n");
    geral_pausar();
    return -1;
  }

  /*
   * --------------------------------------------------------------------------------
   * INICIO DOS PROCEDIMENTOS
   * --------------------------------------------------------------------------------
  */

  while (1) {
    // Apresentacao, menu e tela de exibicao das configuracoes carregadas
    escolha = telaInicial(contents, parametros, dir_base, steamcmd_tudo, temp, quant_livrarias, livrarias);
    printf("\n");

    // Preparativos básicos
    if ((escolha == 2) || (escolha == 3) || (escolha == 4)) {
      // Pastas necessarias
      for (j=1;j<=3;j++) {
        // Pasta base
        if (j == 1)
          strcpy(temp2, dir_base);
        // Pasta do SteamCMD
        else if (j == 2)
          strcpy(temp2, ini_buscar(parametros, "pasta_steamcmd", cfg.secao1));
        // Pasta do GMod
        else if (j == 3)
          strcpy(temp2, ini_buscar(parametros, "pasta_servidor", cfg.secao1));
        if ((i = geral_criarPasta(temp2)) == 1)
          printf("[GMBR DS] Nova pasta: '%s'\n", temp2);
        else if (i == 2)
          break;
      }

      // Pastas de contents
      if (((escolha == 3) || (escolha == 4)) && (i != 2)) {
        contentsAux = contents;
        j = 0;
        while ((*contentsAux).proxima_secao != NULL) {
          // Pasta base dos contents
          if (j == 0) {
            strcpy(temp2, ini_buscar(parametros, "pasta_contents", cfg.secao1));
            if ((i = geral_criarPasta(temp2)) == 1)
              printf("[GMBR DS] Nova pasta: '%s'\n", temp2);
            else if (i == 2)
              break;
          }
          // Pasta de cada content
          if (strcmp(ini_buscar(contentsAux, "opcao", (*contentsAux).secao), "1") == 0) {
            strcpy(temp2, ini_buscar(contentsAux, "pasta", (*contentsAux).secao));
            if ((i = geral_criarPasta(temp2)) == 1)
              printf("[GMBR DS] Nova pasta: '%s'\n", temp2);
            else if (i == 2)
              break;
          }
          j++;
          contentsAux = (*contentsAux).proxima_secao;
        }
      }

      // Mensagem de erro geral da criacao de pastas
      if (i == 2) {
        printf("\n[GMBR DS]--------------------------------------------------------------\n");
        printf("ERRO AO CRIAR PASTA '%s'\n", temp);
        printf("-----------------------------------------------------------------------\n");
        geral_pausar();
        return -1;
      }

      // Instala o SteamCMD
      if (geral_verificarExistencia(steamcmd_tudo) == 2)
        printf("\n[GMBR DS] Baixando SteamCMD em '%s'...\n\n", ini_buscar(parametros, "pasta_steamcmd", cfg.secao1));
      if ((retorno = instalarSteamCMD(parametros, temp, steamcmd_tudo)) == 1) {
        printf("\n[GMBR DS] O SteamCMD esta instalado\n\n");
      } else if (retorno == 2) {
        printf("\n[GMBR DS]--------------------------------------------------------------\n");
        printf("ERRO AO BAIXAR O STEAMCMD\n");
        printf("O LINK DE DOWNLOAD ESTA FUNCIONANDO?\n");
        if (strcmp(SISTEMA,"Windows") == 0)
          printf("O PROGRAMA WGET.EXE ESTA NA PASTA CFG?\n");
        printf("-----------------------------------------------------------------------\n\n");
        geral_pausar();
        return -1;
      } else if (retorno == 3) {
        printf("\n[GMBR DS]--------------------------------------------------------------\n");
        printf("ERRO AO EXTRAIR O STEAMCMD\n");
        if (strcmp(SISTEMA,"Windows") == 0)
          printf("O PROGRAMA UNZIP.EXE ESTA NA PASTA CFG?\n");
        printf("-----------------------------------------------------------------------\n\n");
        geral_pausar();
        return -1;
      }

      // Zero i para usar em erros novamente nas próximas etapas
      i = 0;
    }

    // Instalacao/Atualizacao do servidor de GMod
    if ((escolha == 2) || (escolha == 4)) {
      printf("[GMBR DS] Instalando/atualizando '%s'...\n", ini_buscar(parametros, "jogo_nome", cfg.secao3));
      if ((retorno = instalacaoAtualizacaoSV(parametros, parametros, temp, temp2, cfg.secao1)) == 4) {
        strcpy(temp, (*contents).secao);
        i = retorno;
        break;
      }
    }

    // Instalacao/Atualizacao dos contents com opcao em 1
    if ((escolha == 3) || ((escolha == 4) && (i == 1))) {
        contentsAux = contents;
        while ((*contentsAux).proxima_secao != NULL) {
        if (strcmp(ini_buscar(contentsAux, "opcao", (*contentsAux).secao), "1") == 0) {
          printf("\n[GMBR DS] Instalando/atualizando '%s'...\n", (*contentsAux).secao);
          if ((retorno = instalacaoAtualizacaoSV(contents, parametros, temp, temp2, (*contentsAux).secao)) != 1) {
            strcpy(temp, (*contentsAux).secao);
            i = retorno;
            break;
          }
        }
        contentsAux = (*contentsAux).proxima_secao;
      }
    }

    // Mensagens de erro da instalacao do servidor e contents
    if ((escolha == 2) || (escolha == 3) || (escolha == 4)) {
      if (i == 4) {
        printf("\n[GMBR DS] Erro! Verifique o output do SteamCMD e as informacoes no arquivo contents.ini\n");
      } else if (i == 3) {
        printf("[GMBR DS] Este content requer login para ser baixado! Configure no cfg.ini\n");
      } else if (i == 2) {
        printf("[GMBR DS] Este content nao esta disponivel para download! Reconfigure-o no contents.ini\n");
      }
      escolha = -1;
    }

    // Montagem de contents
    if ((escolha == 2) || (escolha == 3) || (escolha == 4) || (escolha == 6)) {
      if ((retorno = montarContents(contents, temp)) == 1) {
        printf("\n[GMBR DS] Contents montados (%s)\n", temp);
      } else if (retorno == 2) {
        printf("\n[GMBR DS]--------------------------------------------------------------\n");
        printf("NAO FOI POSSIVEL MONTAR OS CONTENTS! ARQUIVO NAO ENCONTRADO:\n");
        printf("'%s'\n", temp);
        printf("-----------------------------------------------------------------------\n\n");
        geral_pausar();
        return -1;
      } else if (retorno == 3) {
        printf("\n[GMBR DS]--------------------------------------------------------------\n");
        printf("NAO FOI POSSIVEL MONTAR OS CONTENTS! ERRO AO ABRIR O ARQUIVO:\n");
        printf("'%s'\n", temp);
        printf("-----------------------------------------------------------------------\n\n");
        geral_pausar();
        return -1;
      }
    }

    // Ligar o servidor
    if (escolha == 5) {
      CLRSCR;
      printf("[GMBR DS] Ligando o servidor\n");
      printf("[GMBR DS] %s %s\n\n", ini_buscar(parametros, "arq_srcds", cfg.secao2), ini_buscar(parametros, "comando_servidor", cfg.secao4));
      ligarServer(parametros, temp);
      if (strcmp(SISTEMA,"Windows") == 0)
        exit(0);
    }

    if (escolha == 0) {
      // Tchau
      printf("\n");
      printf("888888 888888 888888 888888 888888 888888 888888 888888 888888\n");
      printf("[GMBR DS] Programa finalizado.\n");
      printf("\n");
      ini_limpar(parametros);
      ini_limpar(contents);
      exit(0);
    }

    printf("\n");
    printf("888888 888888 888888 888888 888888 888888 888888 888888 888888\n");
    printf("[GMBR DS] Opcao finalizada.\n");
    geral_pausar();

    escolha = -1;
  }
}
