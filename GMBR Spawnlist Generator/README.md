# GMBR SPAWNLIST GENERATOR

Gerador de spawnlists para o Garry's Mod ([Página oficial](http://gmbrblog.blogspot.com.br/2015/07/garrys-mod-brasil-spawnlist-generator.html)).

### Requisitos

- [Java](https://www.java.com/pt_BR/) (Testado na versão 1.8);
- [NetBeans](https://netbeans.org/);
- [CodeBlocks](http://www.codeblocks.org/downloads/26) (versão **mingw** - Windows apenas)

### Compilação GMBR Spawnlist Generator

Para compilar a parte Java do programa faça o seguinte:

- Abra o NetBeans;
- Coloque o conteúdo de "NetBeansProjects" deste repositório dentro da sua própria pasta de projetos;
- Abra a IDE, aperte Ctrl+Shift+O e carregue os arquivos;
- Aperte Shift+F11;
- O arquivo .jar executável irá aparecer dentro da pasta do projeto em "dist".

### Compilação GMadConVX

O GMadConVX dá suporte a leitura de arquivos GMA.

**Windows**

- Abra o CodeBlocks;
- Crie um novo "Pojeto de Console";
- Na árvore de arquivos, delete o "main.c" e adicione o "gmadconvx.c";
- Compile builds em release tanto de 32 quanto 64 bits. Os nomes padrões dos executáveis são "gmadconvx32.exe" e "gmadconvx64.exe".

**Linux**

Ponha a pasta do "GMadConvX" deste repositório em "/home/usuário", abra o terminal e digite:
```sh
$ cd GMadConvX 
$ gcc gmadconvx.c -o gmadconvx64
$ gcc gmadconvx.c -o gmadconvx32 -m32
```

### Organizando os arquivos para uso

Depois da compilar tudo, basta por os arquivos nos locais certos para poder utilizá-los:

- Crie uma pasta "GMBR Spanwlist Generator" e uma subpasta "GMBR Spawnlist Generator/bin";
- Ponha o GMBR_Spawnlist_GeneratorUI.jar em "GMRB Spawnlist Generator";
- Ponha os executáveis do GMadConvX em "GMBR Spawnlist Generator/bin".

Pronto! Clique no GMBR_Spawnlist_GeneratorUI.jar para rodar o programa.
