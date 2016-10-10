// Modifyed by Xalalau Xubilozo.
// http://gmbrblog.blogspot.com.br/
// http://mrxalalau.blogspot.com.br/
// https://github.com/xalalau/GMod/tree/master/GMBR%20Spawnlist%20Generator
// 22/08/2015 (dd/mm/yyyy)
// Version 2
// Original: https://facepunch.com/showthread.php?t=1173875 - by SiPlus

/**
 *
 * GMBR SPAWNLIST GENERATOR
 * @author Xalalau Xubilozo

 */

#if defined(_WIN32)
#pragma warning(disable: 4996)
#define _CRT_SECURE_NO_WARNINGS
#include <direct.h>
#elif defined(__linux__)
#include <unistd.h>
#include <errno.h>
#endif
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

FILE *f_gma;

typedef struct {
	char *name;
	unsigned int size;
} addonfile;

char *ztstr(FILE *file, char *addonname) {
	// Get the infos in the gmas
	int size_path;
	char chr, *dest, aux[1024], aux2[1024];
	for (size_path = 1;; size_path++) {
		fread(&chr, 1, 1, file);
		if (chr == '\0')
			break;
	}
	fseek(file, -size_path, SEEK_CUR);
	dest = malloc(size_path);
	fread(dest, size_path, 1, file);
	if (addonname != NULL)
	{
		strncpy(aux, dest, size_path);
		aux[size_path - 1] = '\0';
		int i = 0, k;
		while (*addonname != '\0') {
			aux2[i++] = *(addonname++);
		}
		aux2[i++] = '/';
		for (k = 0; k <= size_path; k++) {
			aux2[i++] = aux[k];
		}
		dest = aux2;
	}
	return dest;
}

int main(const int argc, const char *argv[])
{
	FILE *in, *out;
	unsigned int filecnt = 0, filenum, i, j;
	char *addonname, *addondesc, *addonauthor;
	int curbyte, del;
	addonfile *addonfiles = NULL, *curfile;
	char line[1024];
	
	memset(line, 0, sizeof(line));

	// Open input file
	FILE *f_array = fopen(argv[2], "r");
	if (f_array == NULL) {
		fprintf(stderr, "Error opening input file %s\n", argv[2]);
		return -1;
	}

	// Open output file
	FILE *f_gma = fopen(argv[3], "w");
	if (f_gma == NULL) {
		fprintf(stderr, "Error creating output file %s\n", argv[3]);
		return -1;
	}

	// Open error file
	FILE *f_error = fopen(argv[4], "w");
	if (f_error == NULL) {
		fprintf(stderr, "Error creating error file %s\n", argv[4]);
		return -1;
	}

	// Title, usage info
	puts("GMADConvX by Xalalau | Based on GMADConv v2 by SiPlus");
	if (argc < 5) {
		fprintf(stderr, "Usage: gma_directory gma_array_file gma_files_array_file error_report_file\n");
		return -1;
	}

	// Begin
	while(fgets(line, 1024, f_array)) {
		line[strlen(line) - 1] = '\0';
		in = fopen(line, "rb");
		if (in == NULL)
		{
			fprintf(f_error, "Error opening gma file: %s\n", line);
			continue;
		}
		fread(&i, 4, 1, in);
		if (i != 0x44414d47)
		{
			fprintf(f_error, "Input file is not addon: %s\n", line);
			continue;
		}
		fseek(in, 18, SEEK_CUR); // Fixed: 17 to 18.
		addonname = ztstr(in, NULL);
		addondesc = ztstr(in, NULL);
		addonauthor = ztstr(in, NULL);
		fseek(in, 4, SEEK_CUR);
		for (;;)
		{
			fread(&filenum, 4, 1, in);
			if (filenum == 0)
				break;
			filecnt++;
			addonfiles = realloc(addonfiles, filecnt * sizeof(addonfile));
			curfile = &addonfiles[filecnt - 1];
			curfile->name = ztstr(in, addonname);
			strcat(curfile->name, "\n");
			fwrite(curfile->name, sizeof(char), strlen(curfile->name), f_gma);
			fread(&curfile->size, 4, 1, in);
			fseek(in, 8, SEEK_CUR);
		}
		if (addonfiles == NULL)
		{
			fprintf(f_error, "Addon is empty: %s\n", line);
			continue;
		}
	}

	// Part1: is error file empty? If yes, delete it.
    long savedOffset = ftell(f_error);
    fseek(f_error, 0, SEEK_END);
    del = ftell(f_error);

	// Close files
	fclose(f_gma);
	fclose(f_array);
	fclose(f_error);

	// Part2: is error file empty? If yes, delete it.
    if (del == 0) {
        remove(argv[4]);
    }

	return 0;
}
