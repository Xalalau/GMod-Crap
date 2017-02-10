# GARRY'S MOD BRASIL DEDICATED SERVER

Programa para instalação de servidores dedicados de Garry's Mod ([Página oficial](http://gmbrblog.blogspot.com.br/2012/07/garrys-mod-brasil-dedicated-server-gmbr.html)).

### COMPILAÇÃO


**LINUX** (Ubuntu)

Primeiramente, clone o repositório e entre na pasta do projeto:

```sh
$ git clone https://github.com/xalalau/GMod.git
$ cd ~/GMod/GMBR\ DS/
````

Agora nós temos uma série de opções para escolher. Veja as combinações para de comando para o makefile:

```sh
$ make ENTRADA
````

ENTRADA:
- "GMBR_DS_64 ENTRADA2"  = Gerará o executável de 64 bits;
- "GMBR_DS_32 ENTRADA2"  = Gerará o executável de 32 bits;
- "GMBR_DS_ZIP"          = Gerará os arquivos zip finais de Windows (32/64) e Linux (64/32);
- "clean"                = Removerá a pasta Build.

ENTRADA2:
- SYSTEM=Windows
- SYSTEM=Linux

Nota: A omissão da ENTRADA2 fará o make criar um executável de Linux por padrão.

Um exemplo:

```sh
$ make GMBR_DS_64
````

**WINDOWS**

Eu uso o CodeBlocks para compilar C no Windows, fica assim:

- [Baixe o código do GMBR DS](https://github.com/xalalau/GMod/archive/master.zip) e extraia ele em um local qualquer (Vamos usar **C:\GMBR-DS**);
- Crie a pasta lib na pasta do GMBR DS (**C:\GMBR-DS\lib**);
- Baixe a [Xalateca](https://github.com/xalalau/Xalateca) e a extraia na pasta "lib" do GMBR DS (**C:\GMBR-DS\lib\Xalateca**);
- Baixe e instale o [CodeBlocks](http://www.codeblocks.org/downloads/26) versão **mingw**;
- Abra o CodeBlocks e crie um novo **Pojeto de Console**;
- Passe o "Build target" do projeto para **Release** e cheque nas configurações se o GCC está configurado para **32 bits**;
- Na árvore de arquivos, delete o "main.c" e mande inlcuir recursivamente os arquivos do GMBR DS (a partir de **C:\GMBR-DS**). Marque para inclusão apenas os arquivos importantes (todos os **.c** e o **.rc**) e clique em aceitar;
- Na árvore de arquivos, abra o GMBR_DS.c;
- Mande compilar;
- Pronto! O executável vai aparecer na pasta **release** do seu projeto.

