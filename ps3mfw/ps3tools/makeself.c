// Copyright 2010       Sven Peter <svenpeter@gmail.com>
// Licensed under the terms of the GNU GPL, version 2
// http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt

#include "tools.h"
#include "types.h"

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <limits.h>
#include <sys/stat.h>
#include <zlib.h>

#define	ALIGNMENT	0x20
#define	MAX_PHDR	255

static u8 *elf = NULL;
static u8 *self = NULL;

static enum sce_key type;

struct elf_hdr ehdr;
struct elf_phdr phdr[MAX_PHDR];
static int arch64;

static u8 sce_header[0x70];
static u8 info_header[0x20];
static u8 ctrl_header[0x70];
static u8 version_header[0x10];

static u8 *sec_header;
static u32 sec_header_size;

static u8 *meta_header;
static u32 meta_header_size;

static u64 header_size;
static u32 meta_offset;
static u64 elf_size;
static u64 compressed_size;
static u64 info_offset;
static u64 version_offset;
static u64 elf_offset;
static u64 phdr_offset;
static u64 shdr_offset;
static u64 sec_offset;
static u64 ctrl_offset;
static u64 version;
static u64 auth_id;
static u64 vendor_id;
static u16 sdk_type;

struct key ks;

static const char *elf_name = NULL;
static const char *self_name = NULL;
static int compression = 0;

static struct {
	u64 offset;
	u64 size;
	u8 *ptr;
	int compressed;
} phdr_map[MAX_PHDR];

static void get_type(const char *p)
{
	if (strncmp(p, "lv0", 4) == 0)
		type = KEY_LV0;
	else if (strncmp(p, "lv1", 4) == 0)
		type = KEY_LV1;
	else if (strncmp(p, "lv2", 4) == 0)
		type = KEY_LV2;
	else if (strncmp(p, "iso", 4) == 0)
		type = KEY_ISO;
	else if (strncmp(p, "app", 4) == 0)
		type = KEY_APP;
	else if (strncmp(p, "ldr", 4) == 0)
		type = KEY_LDR;
	else
		fail("invalid type: %s", p);
}

static void get_keys(const char *suffix)
{
	if (key_get(type, suffix, &ks) < 0)
		fail("key_get failed");

	if (ks.pub_avail < 0)
		fail("no public key available");

	if (ks.priv_avail < 0)
		fail("no private key available");

	if (ecdsa_set_curve(ks.ctype) < 0)
		fail("ecdsa_set_curve failed");

	ecdsa_set_pub(ks.pub);
	ecdsa_set_priv(ks.priv);
}

static void parse_elf(void)
{
	u32 i;

	arch64 = elf_read_hdr(elf, &ehdr);

	for (i = 0; i < ehdr.e_phnum; i++)
		elf_read_phdr(arch64, elf + ehdr.e_phoff + i * ehdr.e_phentsize, &phdr[i]);
}

static void build_sce_hdr(void)
{
	memset(sce_header, 0, sizeof sce_header);

	wbe32(sce_header + 0x00, 0x53434500);	// magic
	wbe32(sce_header + 0x04, 2);		// version
	wbe16(sce_header + 0x08, sdk_type);	// dunno, sdk type?
	wbe16(sce_header + 0x0a, 1);		// SCE header type; self
	wbe32(sce_header + 0x0c, meta_offset);
	wbe64(sce_header + 0x10, header_size);
	wbe64(sce_header + 0x18, round_up(elf_size, ALIGNMENT));
	wbe64(sce_header + 0x20, 3);		// dunno, has to be 3
	wbe64(sce_header + 0x28, info_offset);
	wbe64(sce_header + 0x30, elf_offset);
	wbe64(sce_header + 0x38, phdr_offset);
	wbe64(sce_header + 0x40, shdr_offset);
	wbe64(sce_header + 0x48, sec_offset);
	wbe64(sce_header + 0x50, version_offset);
	wbe64(sce_header + 0x58, ctrl_offset);
	wbe64(sce_header + 0x60, 0x70);		// ctrl size
}

static void build_version_hdr(void)
{
	memset(version_header, 0, sizeof version_header);
	wbe32(version_header, 1);
	wbe32(version_header + 0x08, 0x10);
}

static void build_info_hdr(void)
{
	u32 app_type;

	memset(info_header, 0, sizeof info_header);

	switch (type) {
		case KEY_LV0:
			app_type = 1;
			break;
		case KEY_LV1:
			app_type = 2;
			break;
		case KEY_LV2:
			app_type = 3;
			break;
		case KEY_APP:
			app_type = 4;
			break;
		case KEY_ISO:
			app_type = 5;
			break;
		case KEY_LDR:
			app_type = 6;
			break;
		default:
			fail("something that should never fail failed.");
	}

	wbe64(info_header + 0x00, auth_id);
	wbe32(info_header + 0x08, vendor_id);
	wbe32(info_header + 0x0c, app_type);
	wbe64(info_header + 0x10, version); // version 1.0.0
}

static void build_ctrl_hdr(void)
{
	memset(ctrl_header, 0, sizeof ctrl_header);

	wbe32(ctrl_header + 0x00, 1);		// type: control flags
	wbe32(ctrl_header + 0x04, 0x30);	// length
	// flags are all zero here

	wbe32(ctrl_header + 0x30, 2);		// type: digest
	wbe32(ctrl_header + 0x34, 0x40);	// length
}

static void build_sec_hdr(void)
{
	u32 i;
	u8 *ptr;

	sec_header_size = ehdr.e_phnum * 0x20;
	sec_header = malloc(sec_header_size);

	memset(sec_header, 0, sec_header_size);

	for (i = 0; i < ehdr.e_phnum; i++) {
		ptr = sec_header + i * 0x20;

		wbe64(ptr + 0x00, phdr_map[i].offset);
		wbe64(ptr + 0x08, phdr_map[i].size);

		if (phdr_map[i].compressed == 1)
			wbe32(ptr + 0x10, 2);
		else
			wbe32(ptr + 0x10, 1);

		wbe32(ptr + 0x14, 0);		// unknown
		wbe32(ptr + 0x18, 0);		// unknown

		if (phdr[i].p_type == 1)
			wbe32(ptr + 0x1c, 1);	// encrypted LOAD phdr
		else
			wbe32(ptr + 0x1c, 0);	// no loadable phdr
	}
}

static void meta_add_phdr(u8 *ptr, u32 i)
{
	wbe64(ptr + 0x00, phdr_map[i].offset);
	wbe64(ptr + 0x08, phdr_map[i].size);

	// unknown
	wbe32(ptr + 0x10, 2);
	wbe32(ptr + 0x14, i);		// phdr index maybe?
	wbe32(ptr + 0x18, 2);

	wbe32(ptr + 0x1c, i*8);		// sha index
	wbe32(ptr + 0x20, 1);		// not encpryted
	wbe32(ptr + 0x24, 0xffffffff);	// no key
	wbe32(ptr + 0x28, 0xffffffff);	// no iv
	wbe32(ptr + 0x2c, 1);		// not compressed
}

static void meta_add_load(u8 *ptr, u32 i)
{
	wbe64(ptr + 0x00, phdr_map[i].offset);
	wbe64(ptr + 0x08, phdr_map[i].size);

	// unknown
	wbe32(ptr + 0x10, 2);
	wbe32(ptr + 0x14, i);		// phdr index maybe?
	wbe32(ptr + 0x18, 2);

	wbe32(ptr + 0x1c, i*8);		// sha index
	wbe32(ptr + 0x20, 3);		// phdr is encrypted
	wbe32(ptr + 0x24, (i*8) + 6);	// key index
	wbe32(ptr + 0x28, (i*8) + 7);	// iv index

	if (phdr_map[i].compressed == 1)
		wbe32(ptr + 0x2c, 2);
	else
		wbe32(ptr + 0x2c, 1);
}

static void build_meta_hdr(void)
{
	u32 i;
	u8 *ptr;

	meta_header_size = 0x80 + ehdr.e_phnum * (0x30 + 0x20 + 0x60) + 0x30;
	meta_header = malloc(meta_header_size);
	memset(meta_header, 0, meta_header_size);

	ptr = meta_header + 0x20;

	// aes keys for meta encryption
	get_rand(ptr, 0x10);
	get_rand(ptr + 0x20, 0x10);
	ptr += 0x40;

	// area covered by the signature
	wbe64(ptr + 0x00, meta_offset + meta_header_size - 0x30);

	wbe32(ptr + 0x08, 1);
	wbe32(ptr + 0x0c, ehdr.e_phnum);	// number of encrypted headers
	wbe32(ptr + 0x10, ehdr.e_phnum * 8);	// number of keys/hashes required
	wbe32(ptr + 0x14, meta_header_size / 0x10);
	ptr += 0x20;

	// add encrypted phdr information
	for (i = 0; i < ehdr.e_phnum; i++) {
		if (phdr[i].p_type == 1)
			meta_add_load(ptr, i);
		else
			meta_add_phdr(ptr, i);

		ptr += 0x30;
	}

	// add keys/ivs and hmac keys
	get_rand(ptr, ehdr.e_phnum * 8 * 0x10);
}

static void calculate_hashes(void)
{
	u32 i;
	u8 *keys;

	keys = self + meta_offset + 0x80 + (0x30 * ehdr.e_phnum);

	for (i = 0; i < ehdr.e_phnum; i++) {
		memset(keys + (i * 8 * 0x10), 0, 0x20);
		sha1_hmac(keys + ((i * 8) + 2) * 0x10,
		          self + phdr_map[i].offset,
			  phdr_map[i].size,
			  keys + (i * 8) * 0x10
			 );
	}
}

static void build_hdr(void)
{
	memcpy(self, sce_header, sizeof sce_header);
	memcpy(self + info_offset, info_header, sizeof info_header);
	memcpy(self + version_offset, version_header, sizeof version_header);
	memcpy(self + ctrl_offset, ctrl_header, sizeof ctrl_header);
	memcpy(self + sec_offset, sec_header, sec_header_size);
	memcpy(self + phdr_offset, elf + ehdr.e_phoff, ehdr.e_phnum * ehdr.e_phentsize);
//	memcpy(self + shdr_offset, elf + ehdr.e_shoff, ehdr.e_shnum * ehdr.e_shentsize);
	memcpy(self + meta_offset, meta_header, meta_header_size);
	memcpy(self + elf_offset, elf, ehdr.e_ehsize);
}

static void write_elf(void)
{
	u32 i;

	if (compression) {
		for (i = 0; i < ehdr.e_phnum; i++) {
			memcpy(self + phdr_map[i].offset,
			       phdr_map[i].ptr,
			       phdr_map[i].size);
		}
		memcpy(self + shdr_offset, elf + ehdr.e_shoff, ehdr.e_shnum * ehdr.e_shentsize);
	} else {
		memcpy(self + header_size, elf, elf_size);
	}
}

static void compress_elf(void)
{
	u32 i;
	u64 offset;
	uLongf size_zlib;
	int res;
	u64 size_compressed;

	offset = header_size;

	for (i = 0; i < ehdr.e_phnum; i++) {
		phdr_map[i].offset = offset;
	
		if (phdr[i].p_type != 1) {
			phdr_map[i].ptr = elf + phdr[i].p_off;
			phdr_map[i].size = phdr[i].p_filesz;
			phdr_map[i].compressed = 0;
			offset = round_up(offset + phdr[i].p_filesz, 0x20);
			continue;
		}	

		size_compressed = compressBound(phdr[i].p_filesz);
		size_zlib = size_compressed;

		phdr_map[i].ptr = malloc(size_compressed);
		if (!phdr_map[i].ptr)
			fail("out of memory");

		res = compress(phdr_map[i].ptr, &size_zlib,
		               elf + phdr[i].p_off, phdr[i].p_filesz);

		if (size_zlib >= phdr[i].p_filesz) {
			free(phdr_map[i].ptr);
			phdr_map[i].ptr = elf + phdr[i].p_off;
			phdr_map[i].size = phdr[i].p_filesz;
			phdr_map[i].compressed = 0;
			offset = round_up(offset + phdr[i].p_filesz, ALIGNMENT);
		} else {
			phdr_map[i].ptr = realloc(phdr_map[i].ptr, size_zlib);
			if (phdr_map[i].ptr == NULL)
				fail("out of memory");

			phdr_map[i].size = size_zlib;
			phdr_map[i].compressed = 1;
			offset = round_up(offset + phdr_map[i].size, ALIGNMENT);
		}
	}

	compressed_size = phdr_map[i - 1].offset + phdr_map[i - 1].size;
	shdr_offset = compressed_size;
	compressed_size += ehdr.e_shentsize * ehdr.e_shnum;
}

static void fill_phdr_map(void)
{
	u32 i;

	memset(phdr_map, 0, sizeof phdr_map);

	for (i = 0; i < ehdr.e_phnum; i++) {
		phdr_map[i].offset = phdr[i].p_off + header_size;
		phdr_map[i].size = phdr[i].p_filesz;
		phdr_map[i].compressed = 0;
		phdr[i].ptr = NULL;
	}

	compressed_size = elf_size;
	shdr_offset = ehdr.e_shoff + header_size;
}

static void sign_hdr(void)
{
	u8 *r, *s;
	u8 hash[20];
	u64 sig_len;

	sig_len = be64(self + meta_offset + 0x60);
	r = self + sig_len;
	s = r + 21;

	sha1(self, sig_len, hash);

	ecdsa_sign(hash, r, s);
}

static u64 get_filesize(const char *path)
{
	struct stat st;

	stat(path, &st);

	return st.st_size;
}

static void get_version(const char *v)
{
	u8 *ptr;
	u32 i;
	u32 maj, min, rev;
	u32 tmp;

	i = 0;
	maj = min = rev = tmp = 0;
	ptr = (u8 *)v;
	while (*ptr) {
		if (i > 2) {
			fprintf(stderr, "WARNING: invalid sdk_version, using 1.0.0\n");
			version = 1ULL << 48;
			return;
		}

		if (*ptr == '.') {
			if (i == 0)
				maj = tmp;
			else if (i == 1)
				min = tmp;
			else if (i == 2)
				rev = tmp;
			i++;
			ptr++;
			tmp = 0;
			continue;
		}

		if (*ptr >= '0' && *ptr <= '9') {
			tmp <<= 4;
			tmp += *ptr - '0';
			ptr++;
			continue;
		}

		fprintf(stderr, "WARNING: invalid sdk_version, using 1.0.0\n");
		version = 1ULL << 48;
		return;
	}

	if (i == 2)
		rev = tmp;

	version  = ((u64)maj & 0xffff) << 48;
	version |= ((u64)min & 0xffff) << 32;
	version |= rev;
}

static void get_vendor(char *v)
{
	vendor_id = strtoull(v, NULL, 16);
}

static void get_auth(char *a)
{
	auth_id = strtoull(a, NULL, 16);
}

static void get_sdktype(char * t)
{
	sdk_type = strtoul(t, NULL, 10);
}

static void get_args(int argc, char *argv[])
{
	u32 i;

	if (argc != 9 && argc != 10)
		fail("usage: makeself [-c] [type] [version suffix] [version] [vendor id] [auth id] [sdk type] [elf] [self]");

	i = 1;

	if (argc == 10) {
		if (strcmp(argv[1], "-c") != 0)
			fail("invalid option: %s", argv[1]);
		compression = 1;
		i++;
	}

	get_type(argv[i++]);
	get_keys(argv[i++]);
	get_version(argv[i++]);
	get_vendor(argv[i++]);
	get_auth(argv[i++]);
	get_sdktype(argv[i++]);

	elf_name = argv[i++];
	self_name = argv[i++];

	if (compression) {
		if (type == KEY_ISO)
			fail("no compression support for isolated modules");
		if (type == KEY_LDR)
			fail("no compression support for secure loaders");
	}
}


int main(int argc, char *argv[])
{
	FILE *fp;
	u8 bfr[ALIGNMENT];

	get_args(argc, argv);

	elf_size = get_filesize(elf_name);
	elf = mmap_file(elf_name);

	parse_elf();

	meta_header_size = 0x80 + ehdr.e_phnum * (0x30 + 0x20 + 0x60) + 0x30;
	info_offset = 0x70;
	elf_offset = 0x90;
	phdr_offset = elf_offset + ehdr.e_ehsize;
	sec_offset = round_up(phdr_offset + ehdr.e_phentsize * ehdr.e_phnum, ALIGNMENT);
	version_offset = round_up(sec_offset + ehdr.e_phnum *  0x20, ALIGNMENT);
	ctrl_offset = round_up(version_offset + 0x10, ALIGNMENT);
	meta_offset = round_up(ctrl_offset + 0x70, ALIGNMENT);
	header_size = round_up(meta_offset + meta_header_size, 0x80);

	if (compression)
		compress_elf();
	else
		fill_phdr_map();
	
	build_sce_hdr();
	build_info_hdr();
	build_ctrl_hdr();
	build_sec_hdr();
	build_version_hdr();
	build_meta_hdr();

	self = malloc(header_size + elf_size);
	memset(self, 0, header_size + elf_size);

	build_hdr();
	write_elf();
	calculate_hashes();
	sign_hdr();

	sce_encrypt_data(self);
	sce_encrypt_header(self, &ks);

	fp = fopen(self_name, "wb");
	if (fp == NULL)
		fail("fopen(%s) failed", self_name);

	if (fwrite(self, header_size + compressed_size, 1, fp) != 1)
		fail("unable to write self");

	memset(bfr, 0, sizeof bfr);
	fwrite(bfr, round_up(compressed_size, ALIGNMENT) - compressed_size, 1, fp);

	fclose(fp);

	return 0;
}
