// Copyright 2010       Sven Peter <svenpeter@gmail.com>
// Licensed under the terms of the GNU GPL, version 2
// http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt

#include "tools.h"
#include "types.h"

#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/stat.h>

#ifdef WIN32
#define MKDIR(x,y) mkdir(x)
#else
#define MKDIR(x,y) mkdir(x,y)
#endif

u8 *pkg = NULL;
static u64 dec_size;
static u32 meta_offset;
static u32 n_sections;

static void unpack_content(const char *name)
{
	u8 *tmp;
	u8 *decompressed;
	u64 offset;
	u64 size;
	u64 size_real;

	tmp = pkg + meta_offset + 0x80 + 0x30 * 2;

	offset = be64(tmp);
	size = be64(tmp + 8);
	size_real = dec_size - 0x80;

	if (be32(tmp + 0x2c) == 0x2) {
		decompressed = malloc(size_real);
		memset(decompressed, 0xaa, size_real);

		decompress(pkg + offset, size, decompressed, size_real);

		memcpy_to_file(name, decompressed, size_real);
	} else {
		memcpy_to_file(name, pkg + offset, size);
	}
}

static void unpack_info(u32 i)
{
	u8 *tmp;
	u64 offset;
	u64 size;
	char path[256];

	tmp = pkg + meta_offset + 0x80 + 0x30 * i;

	snprintf(path, sizeof path, "info%d", i);

	offset = be64(tmp);
	size = be64(tmp + 8);

	if (size != 0x40)
		fail("weird info size: %08x", size);

	memcpy_to_file(path, pkg + offset, size);
}

static void unpack_pkg(void)
{
	unpack_info(0);
	unpack_info(1);
	unpack_content("content");
}

static void decrypt_pkg(void)
{
	u16 flags;
	u16 type;
	u32 hdr_len;
	struct keylist *k;

	flags    = be16(pkg + 0x08);
	type     = be16(pkg + 0x0a);
	hdr_len  = be64(pkg + 0x10);
	dec_size = be64(pkg + 0x18);

	if (type != 3)
		fail("no .pkg file");

	k = keys_get(KEY_PKG);

	if (k == NULL)
		fail("no key found");

	if (sce_decrypt_header(pkg, k) < 0)
		fail("header decryption failed");

	if (sce_decrypt_data(pkg) < 0)
		fail("data decryption failed");

	meta_offset = be32(pkg + 0x0c);
	n_sections  = be32(pkg + meta_offset + 0x60 + 0xc);

	if (n_sections != 3)
		fail("invalid section count: %d", n_sections);
}

int main(int argc, char *argv[])
{
	if (argc == 3) {
		pkg = mmap_file(argv[1]);

		MKDIR(argv[2], 0777);

		if (chdir(argv[2]) != 0)
			fail("chdir");

		decrypt_pkg();
		unpack_pkg();
	} else if (argc == 4) {
		if (strcmp(argv[1], "-s") != 0)
			fail("invalid option: %s", argv[1]);

		pkg = mmap_file(argv[2]);

		decrypt_pkg();
		unpack_content(argv[3]);
	} else {
		fail("usage: unpkg [-s] filename.pkg target");
	}


	return 0;
}
