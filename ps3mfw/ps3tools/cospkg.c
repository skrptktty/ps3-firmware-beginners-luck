// Copyright 2010       Sven Peter <svenpeter@gmail.com>
// Licensed under the terms of the GNU GPL, version 2
// http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt

#include "tools.h"
#include "types.h"

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <dirent.h>
#include <sys/stat.h>
#define	MAX_FILES	255

#define COS_FILE_SIZE	7340000


struct pkg_file {
	char name[0x20];
	u8 *ptr;
	u64 size;
	u64 offset;
};

static u8 *hdr = NULL;
static u32 hdr_size = 0;

static u32 n_files = 0;
static struct pkg_file files[MAX_FILES];

static void get_files(const char *d)
{
	DIR *dir;
	struct dirent *de;
	struct stat st;
	char path[256];
	u32 i;
	u64 offset;

	dir = opendir(d);
	if (dir == NULL)
		fail("opendir");

	offset = 0;
	i = 0;
	while ((de = readdir(dir))) {
		if (n_files == MAX_FILES)
			fail("file overflow. increase MAX_FILES");

		if (strcmp(de->d_name, ".") == 0)
			continue;

		if (strcmp(de->d_name, "..") == 0)
			continue;

		if (strlen(de->d_name) > 0x20)
			fail("name too long: %s", de->d_name);

		snprintf(path, sizeof path, "%s/%s", d, de->d_name);

		memset(&files[i], 0, sizeof(*files));
		strncpy(files[i].name, de->d_name, 0x19);

		if (stat(path, &st) < 0)
			fail("cannot stat %s", path);

		if (!S_ISREG(st.st_mode))
			fail("not a file: %s", de->d_name);

		files[i].size = st.st_size;

		files[i].ptr = mmap_file(path);
		if (files[i].ptr == NULL)
			fail("unable to mmap %s", path);

		files[i].offset = offset;
		offset = round_up(offset + files[i].size, 0x20);

		i++;
		n_files++;
	}
}

static void build_hdr(void)
{
	u8 *p;
	u32 i;
	u64 file_size;

	file_size = files[n_files - 1].offset + files[n_files - 1].size;
	hdr_size = 0x10 + n_files * 0x30;

        if ((hdr_size + file_size) > COS_FILE_SIZE)
          fail ("Too many files, size must be under %d but it is %d",
              COS_FILE_SIZE, hdr_size + file_size);

	hdr =  malloc(hdr_size);

	if (hdr == NULL)
		fail("out of memory");

	memset(hdr, 0, hdr_size);
	p = hdr;

	wbe32(p + 0x00, 1);	// magic
	wbe32(p + 0x04, n_files);
	wbe64(p + 0x08, COS_FILE_SIZE);
	p += 0x10;

	for (i = 0; i < n_files; i++) {
		wbe64(p + 0x00, files[i].offset + hdr_size);
		wbe64(p + 0x08, files[i].size);
		strncpy((char *)(p + 0x10), files[i].name, 0x20);
		p += 0x30;
	}
}

static void write_pkg(const char *n)
{
	FILE *fp;
	u32 i;

	fp = fopen(n, "wb");
	if (fp == NULL)
		fail("fopen(%s) failed", n);

	fwrite(hdr, hdr_size, 1, fp);

	for (i = 0; i < n_files; i++) {
		fseek(fp, files[i].offset + hdr_size, SEEK_SET);
		fwrite(files[i].ptr, files[i].size, 1, fp);
	}

        fseek (fp, COS_FILE_SIZE-1, SEEK_SET);
        fwrite("", 1, 1, fp);

	fclose(fp);
}

int main(int argc, char *argv[])
{
	if (argc != 3)
		fail("usage: cospkg cos.pkg dir");

	get_files(argv[2]);
	build_hdr();
	write_pkg(argv[1]);

	return 0;
}
