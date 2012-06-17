// Copyright 2010       Sven Peter <svenpeter@gmail.com>
// Licensed under the terms of the GNU GPL, version 2
// http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt

//
// Thanks to xorloser for his selftool!
// (see xorloser.com)
//


#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "tools.h"

static u8 *self;
static u8 *elf;

static struct elf_hdr ehdr;

static int arch64;
static u32 meta_offset;
static u64 elf_offset;
static u64 header_len;
static u64 phdr_offset;
static u64 shdr_offset;
static u64 filesize;
static u32 vendorid;
static u64 authid;
static u64 app_version;
static u32 app_type;
static u16 sdk_type;
static u64 info_offset;
static u64 sec_offset;
static u64 ver_info;
static u64 ctrl_offset;
static u64 ctrl_size;

static int decrypted = -1;

struct id2name_tbl t_sdk_type[] = {
	{0, "Retail (Type 0)"},
	{1, "Retail"},
	{2, "Retail (Type 1)"},
	{3, "Unknown SDK3"},
	{4, "Retail >=3.40"},
	{5, "Unknown SDK5"},
	{6, "Unknown SDK6"},
	{7, "Retail >=3.50"},
	{8, "Unknown SDK8"},
	{9, "Unknown SDK9"},
	{10, "Retail >=3.55"},
	{11, "Unknown SDK11"},
	{12, "Unknown SDK12"},
	{13, "Retail >=3.56"},
	{14, "Unknown SDK14"},
	{15, "Unknown SDK15"},
	{16, "Retail >=3.60"},
	{17, "Unknown SDK17"},
	{18, "Unknown SDK18"},
	{19, "Retail >=3.65"},
	{20, "Unknown SDK20"},
	{21, "Unknown SDK21"},
	{22, "Retail >=3.70"},
	{23, "Unknown SDK23"},
	{24, "Unknown SDK24"},
	{0x8000, "Devkit"},
	{0, NULL}
};

struct id2name_tbl t_app_type[] = {
	{1, "level 0"},
	{2, "level 1"},
	{3, "level 2"},
	{4, "application"},
	{5, "isolated SPU module"},
	{6, "secure loader"},
	{8, "NP-DRM application"},
	{0, NULL}
};

static struct id2name_tbl t_shdr_type[] = {
	{0, "NULL"},
	{1, "PROGBITS"},
	{2, "SYMTAB"},
	{3, "STRTAB"},
	{4, "RELA"},
	{5, "HASH"},
	{6, "DYNAMIC"},
	{7, "NOTE"},
	{8, "NOBITS"},
	{9, "REL"},
	{10, "SHLIB"},
	{11, "DYNSYM"},
	{12, NULL},
};

static struct id2name_tbl t_elf_type[] = {
	{ET_NONE, "None"},
	{ET_REL, "Relocatable file"},
	{ET_EXEC, "Executable file"},
	{ET_DYN, "Shared object file"},
	{ET_CORE, "Core file"},
	{0, NULL}
};

static struct id2name_tbl t_elf_machine[] = {
	{20, "PowerPC"},
	{21, "PowerPC64"},
	{23, "SPE"},
	{0, NULL}
};


static struct id2name_tbl t_phdr_type[] = {
	{0, "NULL"},
	{1, "LOAD"},
	{2, "DYN"},
	{3, "INTPR"},
	{4, "NOTE"},
	{5, "SHLIB"},
	{6, "PHDR"},
	{0, NULL}
};

static struct id2name_tbl t_compressed[] = {
	{1, "[NO ]"},
	{2, "[YES]"},
	{0, NULL}
};

static struct id2name_tbl t_encrypted[] = {
	{0, "[N/A]"},
	{1, "[YES]"},
	{2, "[NO ]"},
	{0, NULL}
};

static void parse_self(void)
{
	sdk_type =    be16(self + 0x08);
	meta_offset = be32(self + 0x0c);
	header_len =  be64(self + 0x10);
	filesize =    be64(self + 0x18);
	info_offset = be64(self + 0x28);
	elf_offset =  be64(self + 0x30);
	phdr_offset = be64(self + 0x38) - elf_offset;
	shdr_offset = be64(self + 0x40) - elf_offset;
	sec_offset =  be64(self + 0x48);
	ver_info =    be64(self + 0x50);
	ctrl_offset = be64(self + 0x58);
	ctrl_size =   be64(self + 0x60);

	vendorid =    be32(self + info_offset + 0x08);
	authid =      be64(self + info_offset + 0x00);
	app_type =    be32(self + info_offset + 0x0c);
	app_version = be64(self + info_offset + 0x10);

	elf = self + elf_offset;
	arch64 = elf_read_hdr(elf, &ehdr);
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

static void decrypt_header(void)
{
	struct keylist *klist;

	klist = self_load_keys();
	if (klist == NULL)
		return;

    sce_remove_npdrm(self, klist);
    decrypted = sce_decrypt_header(self, klist);
	free(klist->keys);
	free(klist);
}


static const char *get_auth_type(void)
{
	return "Unknown";
}

static void show_self_header(void)
{
	printf("SELF header\n");
	printf("  elf #1 offset:  %08x_%08x\n", (u32)(elf_offset>>32), (u32)elf_offset);
	printf("  header len:     %08x_%08x\n", (u32)(header_len>>32), (u32)header_len);
	printf("  meta offset:    %08x_%08x\n", 0, meta_offset);
	printf("  phdr offset:    %08x_%08x\n", (u32)(phdr_offset>>32), (u32)phdr_offset);
	printf("  shdr offset:    %08x_%08x\n", (u32)(shdr_offset>>32), (u32)shdr_offset);
	printf("  file size:      %08x_%08x\n", (u32)(filesize>>32), (u32)filesize);
	printf("  auth id:        %08x_%08x (%s)\n", (u32)(authid>>32), (u32)authid, get_auth_type());
	printf("  vendor id:      %08x\n", vendorid);
	printf("  info offset:    %08x_%08x\n", (u32)(info_offset >> 32), (u32)info_offset);
	printf("  sinfo offset:   %08x_%08x\n", (u32)(sec_offset >> 32), (u32)sec_offset);	
	printf("  version offset: %08x_%08x\n", (u32)(ver_info >> 32), (u32)ver_info);
	printf("  control info:   %08x_%08x (%08x_%08x bytes)\n",
	         (u32)(ctrl_offset >> 32), (u32)ctrl_offset,
	         (u32)(ctrl_size >> 32), (u32)ctrl_size);

	printf("  app version:    %x.%x.%x\n", (u16)(app_version >> 48), (u16)(app_version >> 32), (u32)app_version);
	printf("  SDK type:       %s\n", id2name(sdk_type, t_sdk_type, "unknown"));
	printf("  app type:       %s\n", id2name(app_type, t_app_type, "unknown"));


	printf("\n");
}

static void show_ctrl(void)
{
	u32 i, j;
	u32 type, length;

	printf("Control info\n");

	for (i = 0; i < ctrl_size; ) {
		type = be32(self + ctrl_offset + i);
		length = be32(self + ctrl_offset + i + 0x04);
		switch (type) {
			case 1:
				if (length == 0x30) {
					printf("  control flags:\n    ");
					print_hash(self + ctrl_offset + i + 0x10, 0x10);
					printf("\n");
					break;
				}
			case 2:
				if (length == 0x40) {
					printf("  file digest:\n    ");
					print_hash(self + ctrl_offset + i + 0x10, 0x14);
					printf("\n    ");
					print_hash(self + ctrl_offset + i + 0x24, 0x14);
					printf("\n");
					break;
				}
				if (length == 0x30) {
					printf("  file digest:\n    ");
					print_hash(self + ctrl_offset + i + 0x10, 0x14);
					printf("\n");
					break;
				}
			case 3:
				if (length == 0x90) {

					char id[0x31];
					memset(id, 0, 0x31);
					memcpy(id, self + ctrl_offset + i + 0x20, 0x30);

					printf("  NPDRM info:\n");
					printf("    magic: %08x\n", be32(self + ctrl_offset + i + 0x10));
					printf("    unk0 : %08x\n", be32(self + ctrl_offset + i + 0x14));
					printf("    unk1 : %08x\n", be32(self + ctrl_offset + i + 0x18));
					printf("    unk2 : %08x\n", be32(self + ctrl_offset + i + 0x1c));
					printf("    content_id: %s\n", id);
					printf("    digest:    ");
					print_hash(self + ctrl_offset + i + 0x50, 0x10);
					printf("\n    invdigest: ");
					print_hash(self + ctrl_offset + i + 0x60, 0x10);
					printf("\n    xordigest: ");
					print_hash(self + ctrl_offset + i + 0x70, 0x10);
					printf("\n");
					break;
				}
			default:
				printf("  unknown:\n");
				for(j = 0; j < length; j++) {
					if ((j % 16) == 0)
						printf("   ");
					printf(" %02x", be8(self + ctrl_offset + i + j));
					if ((j % 16) == 15 || (j == length - 1))
						printf("\n");
				}
				break;
		}
		i += length;
	}
	printf("\n");
}

static void show_sinfo(void)
{
	u32 i;
	u64 offset, size;
	u32 compressed, encrypted;
	u32 unk1, unk2;

	printf("Section header\n");

	printf("    offset             size              compressed unk1"
	       "     unk2     encrypted\n");

	for (i = 0; i < ehdr.e_phnum; i++) {
		offset = be64(self + sec_offset + i*0x20 + 0x00);
		size = be64(self + sec_offset + i*0x20 + 0x08);
		compressed = be32(self + sec_offset + i*0x20 + 0x10);
		unk1 = be32(self + sec_offset + i*0x20 + 0x14);
		unk2 = be32(self + sec_offset + i*0x20 + 0x18);
		encrypted = be32(self + sec_offset + i*0x20 + 0x1c);
		printf("    %08x_%08x  %08x_%08x %s      %08x %08x %s\n",
				(u32)(offset >> 32), (u32)offset,
				(u32)(size >> 32), (u32)size,
				id2name(compressed, t_compressed, "[???]"),
				unk1, unk2,
				id2name(encrypted, t_encrypted, "[???]")
				);
	}

	printf("\n");
}

static void show_meta(void)
{
	u32 meta_len;
	u32 meta_n_hdr;
	u32 meta_n_keys;
	u32 i;
	u64 offset, size;
	u8 *tmp;

	printf("Encrypted Metadata\n");

	if (sdk_type == 0x8000) {
		printf("  no encrypted metadata in fselfs.\n\n");
		return;
	}

	if (decrypted < 0) {
		printf("  unable to decrypt metadata\n\n");
		return;
	}

	meta_len = be32(self + meta_offset + 0x60 + 0x4);
	meta_n_hdr = be32(self + meta_offset + 0x60 + 0xc);
	meta_n_keys = be32(self + meta_offset + 0x60 + 0x10);

	printf("  Key:           ");
	print_hash(self + meta_offset + 0x20, 0x10);
	printf("\n");

	printf("  IV :           ");
	print_hash(self + meta_offset + 0x40, 0x10);
	printf("\n");

	printf("  Signature end   %08x\n", meta_len);
	printf("  Sections        %d\n", meta_n_hdr);
	printf("  Keys            %d\n", meta_n_keys);
	printf("\n");

	printf("  Sections\n");
	printf("    Offset            Length            Key IV  SHA1 Type\n");
	for (i = 0; i < meta_n_hdr; i++) {
		tmp = self + meta_offset + 0x80 + 0x30*i;
		offset = be64(tmp);
		size = be64(tmp + 8);
		printf("    %08x_%08x %08x_%08x %03d %03d %03d  %4d\n",
		       (u32)(offset >> 32), (u32)offset, (u32)(size >> 32), (u32)size,
		       be32(tmp + 0x24), be32(tmp + 0x28), be32(tmp + 0x1c), be32(tmp + 0x10));
	}
	printf("\n");

	printf("  Keys\n");
	printf("    Idx  Data\n");
	tmp = self + meta_offset + 0x80 + 0x30*meta_n_hdr;
	for (i = 0; i < meta_n_keys; i++) {
		printf("    %03d ", i);
		print_hash(tmp + i*0x10, 0x10);
		printf("\n");
	}
	printf("\n");

	printf("\n");

}

static void show_elf_header(void)
{
	printf("ELF header\n");

	printf("  type:                                 %s\n", id2name(ehdr.e_type, t_elf_type, "unknown"));
	printf("  machine:                              %s\n", id2name(ehdr.e_machine, t_elf_machine, "unknown"));
	printf("  version:                              %d\n", ehdr.e_version);

	if (arch64) {
		printf("  phdr offset:                          %08x_%08x\n",
				(u32)(ehdr.e_phoff>>32), (u32)ehdr.e_phoff);  
		printf("  shdr offset:                          %08x_%08x\n",
				(u32)(ehdr.e_phoff>>32), (u32)ehdr.e_shoff);  
		printf("  entry:                                %08x_%08x\n",
				(u32)(ehdr.e_entry>>32), (u32)ehdr.e_entry);  
	} else {
		printf("  phdr offset:                          %08x\n",
				(u32)ehdr.e_phoff);  
		printf("  shdr offset:                          %08x\n",
				(u32)ehdr.e_shoff);  
		printf("  entry:                                %08x\n",
				(u32)ehdr.e_entry);  
	}

	printf("  flags:                                %08x\n", ehdr.e_flags);
	printf("  header size:                          %08x\n", ehdr.e_ehsize);
	printf("  program header size:                  %08x\n",
			ehdr.e_phentsize);
	printf("  program headers:                      %d\n", ehdr.e_phnum);
	printf("  section header size:                  %08x\n",
			ehdr.e_shentsize);
	printf("  section headers:                      %d\n", ehdr.e_shnum);
	printf("  section header string table index:    %d\n", ehdr.e_shtrndx);

	printf("\n");
}

static void get_flags(u32 flags, char *ptr)
{
	memset(ptr, '-', 3);
	ptr[3] = 0;

	if (flags & 4)
		ptr[0] = 'r';
	if (flags & 2)
		ptr[1] = 'w';
	if (flags & 1)
		ptr[2] = 'x';
}

static void show_phdr(unsigned int idx)
{
	struct elf_phdr p;
	char ppc[4], spe[4], rsx[4];

	elf_read_phdr(arch64, elf + phdr_offset + (ehdr.e_phentsize * idx), &p);

	get_flags(p.p_flags, ppc);
	get_flags(p.p_flags >> 20, spe);
	get_flags(p.p_flags >> 24, rsx);

	if (arch64) {
			printf("    %5s %08x_%08x %08x_%08x %08x_%08x\n"
			       "          %08x_%08x %08x_%08x"
			       " %s  %s  %s  %08x_%08x\n",
			      id2name(p.p_type, t_phdr_type, "?????"),
			      (u32)(p.p_off >> 32) , (u32)p.p_off,
			      (u32)(p.p_vaddr >> 32) , (u32)p.p_vaddr,
			      (u32)(p.p_paddr >> 32) , (u32)p.p_paddr,
			      (u32)(p.p_memsz >> 32) , (u32)p.p_memsz,
			      (u32)(p.p_filesz >> 32) , (u32)p.p_filesz,
			      ppc, spe, rsx,
			      (u32)(p.p_align >> 32) , (u32)p.p_align
			      );
	} else {
		printf("    %5s %08x %08x %08x "
		       "%08x %08x  %s  %s  %s  %08x\n",
		       id2name(p.p_type, t_phdr_type, "?????"),
		       (u32)p.p_off, (u32)p.p_vaddr,
		       (u32)p.p_paddr, (u32)p.p_memsz, (u32)p.p_filesz,
		       ppc, spe, rsx, (u32)p.p_align);
	}
}

static void get_shdr_flags(u32 flags, char *ptr)
{
	memset(ptr, ' ', 3);
	ptr[3] = 0;

	if (flags & 4)
		ptr[0] = 'w';
	if (flags & 2)
		ptr[1] = 'a';
	if (flags & 1)
		ptr[2] = 'e';
}

static void show_shdr(unsigned int idx)
{
	struct elf_shdr s;
	char flags[4];

	elf_read_shdr(arch64, elf + shdr_offset + (ehdr.e_shentsize * idx), &s);
	get_shdr_flags(s.sh_flags, flags);

	if (arch64) {
			printf("  [%02d] %-15s %-9s %08x_%08x"
				" %02d %-3s %02d %03d %02d\n"
				"       %08x_%08x         %08x_%08x\n",
				idx, "<no-name>",
				id2name(s.sh_type, t_shdr_type, "????"),
				(u32)(s.sh_addr >> 32), (u32)s.sh_addr,
				s.sh_entsize, flags, s.sh_link, s.sh_info,
				s.sh_addralign,
				(u32)(s.sh_offset >> 32), (u32)s.sh_offset,
				0, (u32)s.sh_size
				);
	} else {
		printf("  [%02d] %-15s %-9s %08x"
			" %08x %08x   %02d %-3s %02d  %02d %02d\n",
			idx, "<no-name>",
			id2name(s.sh_type, t_shdr_type, "????"),
			(u32)s.sh_addr, (u32)s.sh_offset,
			s.sh_size, s.sh_entsize,
		       	flags, s.sh_link, s.sh_info, s.sh_addralign);

	}
}

static void show_phdrs(void)
{
	unsigned int i;

	printf("Program headers\n");

	if (ehdr.e_phnum == 0) {
		printf("No program headers in this file.\n");
	} else {
		if (arch64)
			printf("    type  offset            vaddr             "
			       "paddr\n          memsize           filesize"
			       "          PPU  SPE  RSX  align\n");
		else
			printf("    type  offset   vaddr    paddr    "
			       "memsize  filesize  PPU  SPE  RSX  align\n");
		for (i = 0; i < ehdr.e_phnum; i++)
			show_phdr(i);
	}

	printf("\n");
}

static void show_shdrs(void)
{
	unsigned int i;

	printf("Section headers\n");

	if (ehdr.e_shnum == 0) {
		printf("No section headers in this file.\n");
	} else {
		if (arch64)
			printf("  [Nr] Name            Type      Addr"
				"              ES Flg Lk Inf Al\n"
				"       Off                       Size\n");
		else
			printf("  [Nr] Name            Type      Addr"
		               "     Off      Size       ES Flg Lk Inf Al\n");
		for (i = 0; i < ehdr.e_shnum; i++)
			show_shdr(i);
	}

	printf("\n");
}

int main(int argc, char *argv[])
{
	if (argc != 2)
		fail("usage: readself file.self");

	self = mmap_file(argv[1]);

	parse_self();
	decrypt_header();

	show_self_header();
	show_ctrl();
	show_sinfo();
	show_meta();
	show_elf_header();
	show_phdrs();
	show_shdrs();

	return 0;
}
