// Copyright 2010       Sven Peter <svenpeter@gmail.com>
// Licensed under the terms of the GNU GPL, version 2
// http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <unistd.h>
#include "tools.h"

#ifdef WIN32
#define MKDIR(x,y) mkdir(x);
#else
#define MKDIR(x,y) mkdir(x,y)
#endif

static u8 *nor = NULL;

static void new_dir(const char *n)
{
	MKDIR(n, 0777);
	if (chdir(n) < 0)
		fail("chdir");
}

static void do_toc(u8 *ptr)
{
	u32 n_entries;
	u32 i;
	u8 *p;
	u8 *tmp;
	u64 size;
	char name[0x20];

	n_entries = be32(ptr + 0x04);
	p = ptr + 0x10;

	for(i = 0; i < n_entries; i++) {
		memcpy(name, p + 16, 0x20);

		if (strncmp(name, "asecure_loader", 0x20) == 0) {
			new_dir("asecure_loader");
			do_toc(ptr + be64(p));
			if (chdir("..") < 0)
				fail("chdir(..)");
		} else if (strncmp(name, "ros", 3) == 0) {
			new_dir(name);
			do_toc(ptr + be64(p) + 0x10);
			if (chdir("..") < 0)
				fail("chdir(..)");
		} else {
			tmp = ptr + be64(p);
			size = be64(p + 0x08);
			if (be32(tmp + 0x10) == 0x53434500) {
				tmp += 0x10;
				size -= 0x10;
			}

			memcpy_to_file(name, tmp, size);
		}
		p += 0x30;
	}
}

int main(int argc, char *argv[])
{
	if (argc != 3)
		fail("usage: norunpack dump.b directory");

	nor = mmap_file(argv[1]);

	new_dir(argv[2]);

	do_toc(nor + 0x400);

	return 0;
}
