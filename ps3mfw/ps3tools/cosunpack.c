// Copyright 2010       Sven Peter <svenpeter@gmail.com>
// Copyright 2011       glevand <geoffrey.levand@mail.ru>
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

static u8 *cos = NULL;

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

		tmp = ptr + be64(p);
		size = be64(p + 0x08);

		memcpy_to_file(name, tmp, size);

		p += 0x30;
	}
}

int main(int argc, char *argv[])
{
	if (argc != 3)
		fail("usage: cosunpack dump.b directory");

	cos = mmap_file(argv[1]);

	new_dir(argv[2]);

	do_toc(cos);

	return 0;
}
