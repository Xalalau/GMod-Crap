# Variaveis
DSVERSION=v2.7

BLDDIR = build
LIBDIR = lib
RESDIR = res
SRCDIR = src
BINDIR = ${BLDDIR}/bin
OBJDIR = ${BLDDIR}/obj
ZIPDIR = ${BLDDIR}/zip
CFGDIR = ${RESDIR}/cfg
ICODIR = ${RESDIR}/icon
EXEDIR = ${RESDIR}/windows_exes
XALDIR = ${LIBDIR}/Xalateca

WRAPPER=comp-wrapper

ifeq ($(SYSTEM),)
	SYSTEM=Linux
endif
ifeq ($(SYSTEM),Linux)
	CC64=gcc
	CC32=gcc
	FLAG32=-m32
	OBJDIR64 = ${OBJDIR}/obj64Lin
	OBJDIR32 = ${OBJDIR}/obj32Lin
	WGET=
	UZIP=
	EXT=
else
	ifeq ($(SYSTEM),Windows)
		CC64=x86_64-w64-mingw32-gcc
		CC32=i686-w64-mingw32-gcc
		CCRES64=x86_64-w64-mingw32-windres
		CCRES32=i686-w64-mingw32-windres
		FLAG32=
		OBJDIR64 = ${OBJDIR}/obj64Win
		OBJDIR32 = ${OBJDIR}/obj32Win
		WGET=${EXEDIR}/wget.exe
		UZIP=${EXEDIR}/unzip.exe
		EXT=.exe
		RESOURCE = ${ICODIR}/gmbrds-res.rc
		O_RESOURCE = gmbrds-res.o
		O_RESOURCE_64 = ${OBJDIR64}/${O_RESOURCE}
		O_RESOURCE_32 = ${OBJDIR32}/${O_RESOURCE}
	else
$(error "Entrada SYSTEM invalida")
	endif
endif

WRAPPER_CHECK := $(shell command -v comp-wrapper 2> /dev/null)
APT_CHECK := $(shell command -v apt 2> /dev/null)
GIT_CHECK := $(shell command -v git 2> /dev/null)
MINGW_CHECK := $(shell command -v ${CC32} 2> /dev/null)

SRC_GMBRDS = ${SRCDIR}/GMBR_DS.c
LIB_GERAL = ${XALDIR}/C/Geral/src/geral.c
LIB_INIZATOR = ${XALDIR}/C/Inizator/src/inizator.c

O_GERAL = geral.o
O_INIZATOR = inizator.o
O_GMBRDS = GMBR_DS.o

O_GERAL_64 = ${OBJDIR64}/${O_GERAL}
O_INIZATOR_64 = ${OBJDIR64}/${O_INIZATOR}
O_GMBRDS_64 = ${OBJDIR64}/${O_GMBRDS}
O_GERAL_32 = ${OBJDIR32}/${O_GERAL}
O_INIZATOR_32 = ${OBJDIR32}/${O_INIZATOR}
O_GMBRDS_32 = ${OBJDIR32}/${O_GMBRDS}

DS64 = ${BINDIR}/GMBR_DS_64bits${EXT}
DS32 = ${BINDIR}/GMBR_DS_32bits${EXT}

# Chamadas principais
GMBR_DS_ZIP:
	$(MAKE) -C ./ MAKE_ZIP SYSTEM=Linux
	$(MAKE) -C ./ MAKE_ZIP SYSTEM=Windows
GMBR_DS_64: MINGW COMPWRAPPER ${O_GERAL_64} ${O_INIZATOR_64} ${O_GMBRDS_64} ${O_RESOURCE_64}
	${WRAPPER} ${CC64} ${O_GERAL_64} ${O_INIZATOR_64} ${O_GMBRDS_64} ${O_RESOURCE_64} -o ${DS64}
GMBR_DS_32: MINGW COMPWRAPPER ${O_GERAL_32} ${O_INIZATOR_32} ${O_GMBRDS_32} ${O_RESOURCE_32}
	${WRAPPER} ${CC32} ${O_GERAL_32} ${O_INIZATOR_32} ${O_GMBRDS_32} ${O_RESOURCE_32} -o ${DS32} ${FLAG32}
clean:
	rm -r ${BLDDIR}

# Chamadas secundarias
MAKE_ZIP: GMBR_DS_32 GMBR_DS_64
	mkdir -p Servidor/cfg
ifeq ($(SYSTEM),Windows)
	mkdir Servidor/bin
	cp ${WGET} ${UZIP} Servidor/bin;
	cp ${DS64} Servidor/GMBR_DS_64.exe
	cp ${DS32} Servidor/GMBR_DS_32.exe
else
ifeq ($(SYSTEM),Linux)
	cp ${DS64} Servidor
	cp ${DS32} Servidor
endif
endif
	cp ${CFGDIR}/cfg${SYSTEM}.ini Servidor/cfg/cfg.ini
	cp ${CFGDIR}/contents${SYSTEM}.ini Servidor/cfg/contents.ini
	cp ${RESDIR}/LEIAME.txt Servidor
	if [ ! -d ${ZIPDIR} ]; then mkdir ${ZIPDIR}; fi
	zip -r ${SYSTEM}_GMBR_DS_${DSVERSION}.zip Servidor
	rm -r Servidor
	mv ${SYSTEM}_GMBR_DS_${DSVERSION}.zip ${ZIPDIR}
${O_RESOURCE_64}: ${RESOURCE}
	${WRAPPER} ${CCRES64} ${RESOURCE} -O coff -o ${O_RESOURCE_64}
${O_RESOURCE_32}: ${RESOURCE}
	${WRAPPER} ${CCRES32} ${RESOURCE} -O coff -o ${O_RESOURCE_32}
${O_GERAL_64}: ${LIB_GERAL}
	${WRAPPER} ${CC64} ${OBJDIR64} -c ${LIB_GERAL}
${O_INIZATOR_64}: ${LIB_INIZATOR}
	${WRAPPER} ${CC64} ${OBJDIR64} -c ${LIB_INIZATOR}
${O_GMBRDS_64}: ${SRC_GMBRDS}
	${WRAPPER} ${CC64} ${OBJDIR64} -c ${SRC_GMBRDS}
${O_GERAL_32}: ${LIB_GERAL}
	${WRAPPER} ${CC32} ${OBJDIR32} -c ${LIB_GERAL} ${FLAG32}
${O_INIZATOR_32}: ${LIB_INIZATOR}
	${WRAPPER} ${CC32} ${OBJDIR32} -c ${LIB_INIZATOR} ${FLAG32}
${O_GMBRDS_32}: ${SRC_GMBRDS}
	${WRAPPER} ${CC32} ${OBJDIR32} -c ${SRC_GMBRDS} ${FLAG32}

# Instalacao de requisitos
MINGW:
ifeq ($(SYSTEM),Windows)
ifndef MINGW_CHECK
ifndef APT_CHECK
	$(error "\nInstale o \"mingw-w64\" para poder usar esse makefile!\n")
endif
	echo "Necessário instalar \"mingw-w64\" para compilar binários de Windows..."
	sudo apt install mingw-w64
endif
endif
COMPWRAPPER:
ifeq "$(wildcard $(XALDIR) )" ""
ifndef GIT_CHECK
ifndef APT_CHECK
	$(error "\nInstale o Git para poder usar esse makefile!\n")
endif
	echo "Necessário instalar \"Git\"..."
	sudo apt install git
endif
	git clone https://github.com/xalalau/Xalateca.git ${XALDIR};
endif
ifndef WRAPPER_CHECK
	echo "Instalando script \"comp-wrapper\"..."
	sudo cp '${XALDIR}/Bash/comp-wrapper/src/comp-wrapper' /usr/bin
	sudo chmod +x /usr/bin/comp-wrapper
endif
	
