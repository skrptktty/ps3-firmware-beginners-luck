// Copyright 2010       Sven Peter <svenpeter@gmail.com>
// Licensed under the terms of the GNU GPL, version 2
// http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt

#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <unistd.h>
#include <string.h>

#include "tools.h"

#define	MAX_FILES	10

static FILE *fp;
static u8 pup_hmac[0x40];
static u8 hdr[0x30 + 0x40 * MAX_FILES + 0x20];
static u64 n_files;
static u64 data_size;
static u64 build = 0xfa11;

static struct {
	u8 *ptr;
	u64 id;
	u64 len;
	u64 offset;
} files[MAX_FILES];

static struct id2name_tbl t_names[] = {
	{0x100, "version.txt"},
	{0x101, "license.xml"},
	{0x102, "promo_flags.txt"},
	{0x103, "update_flags.txt"},
	{0x104, "patch_build.txt"},
	{0x200, "ps3swu.self"},
	{0x201, "vsh.tar"},
	{0x202, "dots.txt"},
	{0x203, "patch_data.pkg"},
	{0x300, "update_files.tar"},
        {0x501, "spkg_hdr.tar"},
	{0x601, "ps3swu2.self"},
	{0, NULL}
};


static void find_files(void)
{
	struct id2name_tbl *t;
	struct stat st;
	u64 offset;
	u32 i;

	n_files = 0;
	data_size = 0;

	t = t_names;
	while(t->name != NULL) {
		if (stat(t->name, &st) >= 0) {
			files[n_files].id = t->id;
			files[n_files].ptr = mmap_file(t->name);
			files[n_files].len = st.st_size;
			data_size += files[n_files].len;
			n_files++;
		}
		t++;
	}

	offset = 0x50 + 0x40 * n_files;
	for (i = 0; i < n_files; i++) {
		files[i].offset = offset;
		offset += files[i].len;
	}
}

static void calc_hmac(u8 *ptr, u64 len, u8 *hmac)
{
	memset(hmac, 0, 0x20);
	sha1_hmac(pup_hmac, ptr, len, hmac);
}

static void build_header(void)
{
	u32 i;

	memset(hdr, 0, sizeof hdr);
	memcpy(hdr, "SCEUF\0\0\0", 8);

	wbe64(hdr + 0x08, 1);
	wbe64(hdr + 0x10, build);
	wbe64(hdr + 0x18, n_files);
	wbe64(hdr + 0x20, 0x50 + n_files * 0x40);
	wbe64(hdr + 0x28, data_size);

	for (i = 0; i < n_files; i++) {
		wbe64(hdr + 0x30 + 0x20 * i + 0x00, files[i].id);
		wbe64(hdr + 0x30 + 0x20 * i + 0x08, files[i].offset);
		wbe64(hdr + 0x30 + 0x20 * i + 0x10, files[i].len);
		wbe64(hdr + 0x30 + 0x20 * i + 0x18, 0);

		wbe64(hdr + 0x30 + 0x20 * n_files + 0x20 * i, i);
		calc_hmac(files[i].ptr, files[i].len,
		          hdr + 0x30 + 0x20 * n_files + 0x20 * i + 0x08);
	}

	calc_hmac(hdr, 0x30 + 0x40 * n_files,
	          hdr + 0x30 + 0x40 * n_files);
}

static void write_pup(void)
{
	u32 i;

	fseek(fp, 0, SEEK_SET);
	fwrite(hdr, 0x50 + 0x40 * n_files, 1, fp);

	for (i = 0; i < n_files; i++) {
		fseek(fp, files[i].offset, SEEK_SET);
		fwrite(files[i].ptr, files[i].len, 1, fp);
	}
}

int main(int argc, char *argv[])
{
	if (argc < 3)
		fail("usage: puppack filename.pup directory [build number]");

	if (argc == 4)
		build = atoi(argv[3]);

	if (key_get_simple("pup-hmac", pup_hmac, sizeof pup_hmac) < 0)
		fail("pup hmac key not available");

	fp = fopen(argv[1], "wb");
	if (fp == NULL)
		fail("fopen(%s)", argv[1]);

	if (chdir(argv[2]) < 0)
		fail("chdir(%s)", argv[1]);

	find_files();
	build_header();
	write_pup();

	fclose(fp);

	return 0;
}

