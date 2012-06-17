// Copyright 2010       Sven Peter <svenpeter@gmail.com>
// Licensed under the terms of the GNU GPL, version 2
// http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt

#include "tools.h"
#include "types.h"

#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <stdlib.h>

#define	MAX_SECTIONS	255

static u8 *self = NULL;
static u8 *elf = NULL;
static FILE *out = NULL;

static u64 info_offset;
static u32 key_ver;
static u64 phdr_offset;
static u64 shdr_offset;
static u64 sec_offset;
static u64 ver_offset;
static u64 version;
static u64 elf_offset;
static u64 meta_offset;
static u64 header_len;
static u64 filesize;
static u32 arch64;
static u32 n_sections;

static struct elf_hdr ehdr;

static u32 app_type;

static struct {
	u32 offset;
	u32 size;
	u32 compressed;
	u32 size_uncompressed;
	u32 elf_offset;
} self_sections[MAX_SECTIONS];

static void read_header(void)
{
	key_ver =    be16(self + 0x08);
	meta_offset = be32(self + 0x0c);
	header_len =  be64(self + 0x10);
	filesize =    be64(self + 0x18);
	info_offset = be64(self + 0x28);
	elf_offset =  be64(self + 0x30);
	phdr_offset = be64(self + 0x38) - elf_offset;
	shdr_offset = be64(self + 0x40) - elf_offset;
	sec_offset =  be64(self + 0x48);
	ver_offset =  be64(self + 0x50);

	version =   be64(self + info_offset + 0x10);
	app_type =    be32(self + info_offset + 0x0c);

	elf = self + elf_offset;
	arch64 = elf_read_hdr(elf, &ehdr);
}

struct self_sec {
	u32 idx;
	u64 offset;
	u64 size;
	u32 compressed;
	u32 encrypted;
	u64 next;
};

static void read_section(u32 i, struct self_sec *sec)
{
	u8 *ptr;

	ptr = self + sec_offset + i*0x20;

	sec->idx = i;
	sec->offset     = be64(ptr + 0x00);
	sec->size       = be64(ptr + 0x08);
	sec->compressed = be32(ptr + 0x10) == 2 ? 1 : 0;
	sec->encrypted  = be32(ptr + 0x1c);
	sec->next       = be64(ptr + 0x20);
}

static int qsort_compare(const void *a, const void *b)
{
	const struct self_sec *sa, *sb;
	sa = a;
	sb = b;

	if (sa->offset > sb->offset)
		return 1;
	else if(sa->offset < sb->offset)
		return -1;
	else
		return 0;
}

static void read_sections(void)
{
	struct self_sec s[MAX_SECTIONS];
	struct elf_phdr p;
	u32 i;
	u32 j;
	u32 n_secs;
	u32 self_offset, elf_offset;

	memset(s, 0, sizeof s);
	for (i = 0, j = 0; i < ehdr.e_phnum; i++) {
		read_section(i, &s[j]);
		if (s[j].compressed)
			j++;
	}

	n_secs = j;
	qsort(s, n_secs, sizeof(*s), qsort_compare);

	elf_offset = 0;
	self_offset = header_len;
	j = 0;
	i = 0;
	while (elf_offset < filesize) {
		if (i == n_secs) {
			self_sections[j].offset = self_offset;
			self_sections[j].size = filesize - elf_offset;
			self_sections[j].compressed = 0;
			self_sections[j].size_uncompressed = filesize - elf_offset;
			self_sections[j].elf_offset = elf_offset;
			elf_offset = filesize;
		} else if (self_offset == s[i].offset) {
			self_sections[j].offset = self_offset;
			self_sections[j].size = s[i].size;
			self_sections[j].compressed = 1;
			elf_read_phdr(arch64, elf + phdr_offset +
					(ehdr.e_phentsize * s[i].idx), &p);
			self_sections[j].size_uncompressed = p.p_filesz;
			self_sections[j].elf_offset = p.p_off;

			elf_offset = p.p_off + p.p_filesz;
			self_offset = s[i].next;
			i++;
		} else {
			elf_read_phdr(arch64, elf + phdr_offset +
					(ehdr.e_phentsize * s[i].idx), &p);
			self_sections[j].offset = self_offset;
			self_sections[j].size = p.p_off - elf_offset;
			self_sections[j].compressed = 0;
			self_sections[j].size_uncompressed = self_sections[j].size;
			self_sections[j].elf_offset = elf_offset;

			elf_offset += self_sections[j].size;
			self_offset += s[i].offset - self_offset;
		}
		j++;
	}

	n_sections = j;
}

static void write_elf(void)
{
	u32 i;
	u8 *bfr;
	u32 size;
	u32 offset = 0;

	for (i = 0; i < n_sections; i++) {
		fseek(out, self_sections[i].elf_offset, SEEK_SET);
		offset = self_sections[i].elf_offset;
		if (self_sections[i].compressed) {
			size = self_sections[i].size_uncompressed;

			bfr = malloc(size);
			if (bfr == NULL)
				fail("failed to allocate %d bytes", size);

			offset += size;

			printf("compressed self_sections[i].offset 0x%x self_sections[i].size 0x%x\n",
				self_sections[i].offset,self_sections[i].size);


			decompress(self + self_sections[i].offset,
			           self_sections[i].size,
				   bfr, size);
			fwrite(bfr, size, 1, out);
			free(bfr);
		} else {
			bfr = self + self_sections[i].offset;
			size = self_sections[i].size;
			offset += size;

			fwrite(bfr, size, 1, out);
		}
	}
}

static void remove_shnames(u64 shdr_offset, u16 n_shdr, u64 shstrtab_offset, u32 strtab_size)
{
	u16 i;
	u32 size;
	struct elf_shdr s;

	if (arch64)
		size = 0x40;
	else
		size = 0x28;

	for (i = 0; i < n_shdr; i++) {
		elf_read_shdr(arch64, elf + shdr_offset + i * size, &s);

		s.sh_name = 0;
		if (s.sh_type == 3) {
			s.sh_offset = shstrtab_offset;
			s.sh_size = strtab_size;
		}

		elf_write_shdr(arch64, elf + shdr_offset + i * size, &s);
	}
}

static void check_elf(void)
{
	u8 bfr[0x48];
	u64 elf_offset;
	u64 phdr_offset;
	u64 shdr_offset;
	u64 phdr_offset_new;
	u64 shdr_offset_new;
	u64 shstrtab_offset;
	u16 n_phdr;
	u16 n_shdr;
	const char shstrtab[] = ".unknown\0\0";
	const char elf_magic[4] = {0x7f, 'E', 'L', 'F'};

	fseek(out, 0, SEEK_SET);
	fread(bfr, 4, 1, out);

	if (memcmp(bfr, elf_magic, sizeof elf_magic) == 0)
		return;

	elf_offset =  be64(self + 0x30);
	phdr_offset = be64(self + 0x38) - elf_offset;
	shdr_offset = be64(self + 0x40) - elf_offset;

	if (arch64) {
		fseek(out, 0x48, SEEK_SET);
		phdr_offset_new = 0x48;

		fseek(out, 0, SEEK_END);
		shdr_offset_new = ftell(out);

		n_phdr = be16(elf + 0x38);
		n_shdr = be16(elf + 0x3c);
		shstrtab_offset = shdr_offset_new + n_shdr * 0x40;

		remove_shnames(shdr_offset, n_shdr, shstrtab_offset, sizeof shstrtab);

		fseek(out, phdr_offset_new, SEEK_SET);
		fwrite(elf + phdr_offset, 0x38, n_phdr, out);

		fseek(out, shdr_offset_new, SEEK_SET);
		fwrite(elf + shdr_offset, 0x40, n_shdr, out);

		wbe64(elf + 0x20, phdr_offset_new);
		wbe64(elf + 0x28, shdr_offset_new);

		fseek(out, SEEK_SET, 0);
		fwrite(elf, 0x48, 1, out);

		fseek(out, shstrtab_offset, SEEK_SET);
		fwrite(shstrtab, sizeof shstrtab, 1, out);
	} else {
		fseek(out, 0x34, SEEK_SET);
		phdr_offset_new = 0x34;
		fseek(out, 0, SEEK_END);
		shdr_offset_new = ftell(out);

		n_phdr = be16(elf + 0x2c);
		n_shdr = be16(elf + 0x30);
		shstrtab_offset = shdr_offset_new + n_shdr * 0x40;

		remove_shnames(shdr_offset, n_shdr, shstrtab_offset, sizeof shstrtab);

		fseek(out, phdr_offset_new, SEEK_SET);
		fwrite(elf + phdr_offset, 0x20, n_phdr, out);

		fseek(out, shdr_offset_new, SEEK_SET);
		fwrite(elf + shdr_offset, 0x28, n_shdr, out);

		wbe32(elf + 0x1c, phdr_offset_new);
		wbe32(elf + 0x20, shdr_offset_new);

		fseek(out, SEEK_SET, 0);
		fwrite(elf, 0x34, 1, out);

		fseek(out, shstrtab_offset, SEEK_SET);
		fwrite(shstrtab, sizeof shstrtab, 1, out);
	}
}

static struct keylist *self_load_keys(void)
{
	enum sce_key id;

	switch (app_type) {
		case 1:
			id = KEY_LV0;
			break;
	 	case 2:
			id = KEY_LV1;
			break;
		case 3:
			id = KEY_LV2;
			break;
		case 4:
			id = KEY_APP;
			break;
		case 5:
			id = KEY_ISO;
			break;
		case 6:
			id = KEY_LDR;
			break;
        case 8:
            id = KEY_NPDRM;
            break;
		default:
			fail("invalid type: %08x", app_type);
	}

	return keys_get(id);
}

static void self_decrypt(void)
{
	struct keylist *klist;

	klist = self_load_keys();
	if (klist == NULL)
		fail("no key found");

    if (sce_remove_npdrm(self, klist) < 0)
        fail("self_remove_npdrm failed");

	if (sce_decrypt_header(self, klist) < 0)
		fail("self_decrypt_header failed");

	if (sce_decrypt_data(self) < 0)
		fail("self_decrypt_data failed");
}

int main(int argc, char *argv[])
{
	if (argc != 3)
		fail("usage: unself in.self out.elf");

	self = mmap_file(argv[1]);

	if (be32(self) != 0x53434500)
		fail("not a SELF");

	read_header();
	read_sections();

	if (key_ver != 0x8000)
		self_decrypt();

	out = fopen(argv[2], "wb+");

	write_elf();
	check_elf();

	fclose(out);

	return 0;
}
