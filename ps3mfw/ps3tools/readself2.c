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
#include <inttypes.h>
#include "tools.h"

static u8 *self;
static u8 *elf;

static struct elf_hdr ehdr;

static int arch64;

static u32 magic;
static u32 hdr_version;
static u16 sdk_type;
static u16 hdr_type;
static u32 meta_offset;
static u64 header_len;
static u64 filesize;
static u64 unknown1;
static u64 info_offset;
static u64 elf_offset;
static u64 phdr_offset;
static u64 shdr_offset;
static u64 sec_offset;
static u64 ver_info;
static u64 ctrl_offset;
static u64 ctrl_size;
static u64 unknown2;

static u64 authid;
static u32 vendorid;
static u32 app_type;
static u64 app_version;
static u64 unknown3;

static u64 elf_ident;
static u64 elf_ident2;

static int decrypted = -1;

struct id2name_tbl t_sdk_type[] = 
{
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

struct id2name_tbl t_hdr_type[] = 
{
  {1, "SELF"},
  {2, "UNK "},
  {3, "PKG "},
  {0, NULL}
};

struct id2name_tbl t_app_type[] = 
{
	{1, "level 0"},
	{2, "level 1"},
	{3, "level 2"},
	{4, "application"},
	{5, "isolated SPU module"},
	{6, "secure loader"},
	{7, "unknown app type"},
	{8, "NP-DRM application"},
	{0, NULL}
};

static struct id2name_tbl t_shdr_type[] = 
{
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

static struct id2name_tbl t_elf_type[] = 
{
	{ET_NONE, "None"},
	{ET_REL, "Relocatable file"},
	{ET_EXEC, "Executable file"},
	{ET_DYN, "Shared object file"},
	{ET_CORE, "Core file"},
	{0, NULL}
};

static struct id2name_tbl t_elf_machine[] = 
{
	{20, "PowerPC"},
	{21, "PowerPC64"},
	{22, "UnknownArch"},
	{23, "SPE"},
	{0, NULL}
};


static struct id2name_tbl t_phdr_type[] = 
{
	{0, "NULL"},
	{1, "LOAD"},
	{2, "DYN"},
	{3, "INTPR"},
	{4, "NOTE"},
	{5, "SHLIB"},
	{6, "PHDR"},
	{7, "TLS"},
	{8, "UNK8"},
	{9, "UNK9"},
	{0x60000001, "LOOS1"},
	{0x60000002, "LOOS2"},
	{0, NULL}
};

static struct id2name_tbl t_compressed[] = 
{
	{1, "[NO ]"},
	{2, "[YES]"},
	{0, NULL}
};

static struct id2name_tbl t_encrypted[] = 
{
	{0, "[N/A]"},
	{1, "[YES]"},
	{2, "[NO ]"},
	{0, NULL}
};

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
		case 7:
			return NULL;
			break;
		case 8:
			id = KEY_NPDRM;
			break;
		default:
			fail("invalid type: %08x", app_type);	
	}

	return keys_get(id);
}

static const char *get_auth_type(void)
{
	return "UnknownAuthIdType";
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

static void parse_self(void)
{
	magic =       be32(self + 0x00);
	hdr_version = be32(self + 0x04);
	sdk_type =    be16(self + 0x08);
	hdr_type =    be16(self + 0x0a);
	meta_offset = be32(self + 0x0c);
	header_len =  be64(self + 0x10);
	filesize =    be64(self + 0x18);
	unknown1 =    be64(self + 0x20);
	info_offset = be64(self + 0x28);
	elf_offset =  be64(self + 0x30);
	phdr_offset = be64(self + 0x38) - elf_offset;
	shdr_offset = be64(self + 0x40) - elf_offset;
	sec_offset =  be64(self + 0x48);
	ver_info =    be64(self + 0x50);
	ctrl_offset = be64(self + 0x58);
	ctrl_size =   be64(self + 0x60);
	unknown2 =    be64(self + 0x68);

	authid =      be64(self + info_offset + 0x00);
	vendorid =    be32(self + info_offset + 0x08);
	app_type =    be32(self + info_offset + 0x0c);
	app_version = be64(self + info_offset + 0x10);
	unknown3 =    be64(self + info_offset + 0x18);

  elf_ident =   be64(self + elf_offset + 0x00);
  elf_ident2 =  be64(self + elf_offset + 0x08);
	elf = self + elf_offset;
	arch64 = elf_read_hdr(elf, &ehdr);
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

static void show_self_header(void)
{
	printf("%s Info\n\n", 
	        id2name(hdr_type, t_hdr_type, "unknown")
	      );
	printf("  header type:     %s\n",
                id2name(hdr_type, t_hdr_type, "unknown")
        );
	printf("  SDK type:        %s\n",
	        id2name(sdk_type, t_sdk_type, "unknown")
	      );
	printf("  app type:        %s\n",
	        id2name(app_type, t_app_type, "unknown")
	      );
	printf("  arch type:       %s\n",
	        id2name(ehdr.e_machine, t_elf_machine, "unknown")
	      );
	printf("  ELF type:        %s\n",
	        id2name(ehdr.e_type, t_elf_type, "unknown")
	      );
	printf("  app version:     %x.%x.%x\n",
	        (u16)(app_version >> 48),
	        (u16)(app_version >> 32),
	        (u32)app_version
	      );
  printf("  auth id type:    %s\n\n",
          get_auth_type()
        );
	
	printf("%s Header        file\n",
	        id2name(hdr_type, t_hdr_type, "unknown")
	      );
  printf("                  offset  data\n");
  printf("  magic:           %04x = %08x\n",
          (u16)(0x0), (u32)magic
        );
  printf("  header version:  %04x = %08x\n",
          (u16)(0x4), (u32)hdr_version
        );
  printf("  sdk type:        %04x =     %04x\n",
          (u16)(0x8), (u16)sdk_type
        );
  printf("  header type:     %04x =     %04x\n",
          (u16)(0xa), (u16)hdr_type
        );
	printf("  meta offset:     %04x = %08x\n",
	        (u16)(0x0c), (u32)meta_offset
	      );
  printf("  header length    %04x = %08x_%08x bytes\n",
          (u16)(0x10),
          (u32)(header_len>>32),
          (u32)header_len
        );
	printf("  file length:     %04x = %08x_%08x bytes\n",
	        (u16)(0x18),
	        (u32)(filesize>>32
	      ),
	        (u32)filesize);
  printf("  unknown:         %04x = %08x_%08x\n",
          (u16)(0x20), (u32)(unknown1>>32),
  	      (u32)unknown1
  	    );
	printf("  info offset:     %04x = %08x_%08x\n",
	        (u16)(0x28), (u32)(info_offset >> 32),
		      (u32)info_offset
		    );
	printf("  elf #1 offset:   %04x = %08x_%08x\n",
	        (u16)(0x30),
		      (u32)(elf_offset>>32),
		      (u32)elf_offset
		    );
	printf("  phdr offset:     %04x = %08x_%08x\n",
	        (u16)(0x38),
		      (u32)((phdr_offset + elf_offset) >>32),
		      (u32)(phdr_offset + elf_offset)
		    );
	printf("  shdr offset:     %04x = %08x_%08x\n",
	        (u16)(0x40),
			    (u32)((shdr_offset + elf_offset) >>32),
			    (u32)(shdr_offset + elf_offset)
			  );
	printf("  sinfo offset:    %04x = %08x_%08x\n",
	        (u16)(0x48),
			    (u32)(sec_offset >> 32),
			    (u32)sec_offset
			  );	
	printf("  version offset:  %04x = %08x_%08x\n",
	        (u16)(0x50),
		      (u32)(ver_info >> 32),
			    (u32)ver_info
			  );
	printf("  control offset:  %04x = %08x_%08x\n",
	        (u16)(0x58),
			    (u32)(ctrl_offset >> 32),
			    (u32)ctrl_offset
			  );
  printf("  control length:  %04x = %08x_%08x bytes\n",
          (u16)(0x60),
 		      (u32)(ctrl_size >> 32),
 		      (u32)ctrl_size
 		    );
  printf("  unknown:         %04x = %08x_%08x\n\n",
          (u16)(0x68),
 		      (u32)(unknown2 >> 32),
 		      (u32)unknown2
 		    );

	printf("App Info Header    file\n");
  printf("                  offset  data\n");
	printf("  auth id:         %04x = %08x_%08x (%s)\n",
	        (u16)(info_offset + 0x00),
		      (u32)(authid>>32),
			    (u32)authid, get_auth_type()
			  );
	printf("  vendor id:       %04x = %08x\n",
	        (u16)(info_offset + 0x08),
			    (u32)vendorid
			  );
	printf("  app type:        %04x = %08x\n",
	        (u16)(info_offset + 0x0c),
			    (u32)app_type
			  );
	printf("  app version:     %04x = %08x_%08x\n",
	        (u16)(info_offset + 0x10),
			    (u32)(app_version >> 32),
	 		    (u32)(app_version)
	 		  );
  printf("  unknown:         %04x = %08x_%08x\n",
          (u16)(info_offset + 0x18),
  		    (u32)(unknown3 >> 32),
 		      (u32)unknown3
 		    );
  printf("\n\n");
}

/*
e_type     :0x%04x
e_machine  :0x%04x
e_version  :0x%08x
e_entry    :0x%lx
e_phoff    :0x%lx
e_shoff    :0x%lx
e_flags    :0x%08x
e_ehsize   :0x%04x
e_phentsize:0x%04x
e_phnum    :0x%04x
e_shentsize:0x%04x
e_shnum    :0x%04x
e_shstrndx :0x%04x
*/
static void show_elf_header(void)
{
	int counter = 0;
	
	printf("ELF Header         file\n");
	printf("                  Offset  data\n");

  printf("  ident:           %04x = %08x_%08x %08x_%08x\n",
          (u16)(elf_offset + counter),
          (u32)(elf_ident >> 32),
          (u32)(elf_ident),
          (u32)(elf_ident2 >> 32),
          (u32)(elf_ident2)
          //ehdr.e_ident
        );
  counter += 16;
	printf("  type:            %04x = %04x (%s)\n",
	        (u16)(elf_offset + counter),
	        (u32)(ehdr.e_type),
	        id2name(ehdr.e_type, t_elf_type, "unknown")
	      );
	counter += 2;
	printf("  machine:         %04x = %04x (%s)\n",
	        (u16)(elf_offset + counter),
	        (u16)(ehdr.e_machine),
	        id2name(ehdr.e_machine, t_elf_machine, "unknown")
	      );
  counter += 2;
	printf("  version:         %04x = %08x\n",
	        (u16)(elf_offset + counter),
	        ehdr.e_version
	      );
	counter += 4;

	if (arch64) {
		printf("  entry:           %04x = %08x_%08x\n",
		        (u16)(elf_offset + counter),
				    (u32)(ehdr.e_entry>>32),
				    (u32)ehdr.e_entry
				  );  
		printf("  phdr offset:     %04x = %08x_%08x\n",
		        (u16)(elf_offset + counter + 8),
				    (u32)(ehdr.e_phoff>>32),
				    (u32)ehdr.e_phoff
				  );  
		printf("  shdr offset:     %04x = %08x_%08x\n",
		        (u16)(elf_offset + counter + 16),
				    (u32)(ehdr.e_phoff>>32),
				    (u32)ehdr.e_shoff
				  );  
	  counter += 24;
	}
	else
  {
		printf("  entry:           %04x = %08x\n",
		        (u16)(elf_offset + counter),
				    (u32)ehdr.e_entry
				  );  
		printf("  phdr offset:     %04x = %08x\n",
		        (u16)(elf_offset + counter + 4),
				    (u32)ehdr.e_phoff
				  );  
		printf("  shdr offset:     %04x = %08x\n",
		        (u16)(elf_offset + counter + 8),
				    (u32)ehdr.e_shoff
				  );  
	  counter += 12;
	}

	printf("  flags:           %04x = %08x\n",
	        (u16)(elf_offset + counter),
	        ehdr.e_flags
	      );
	counter += 4;
	printf("  header size:     %04x = %04x bytes\n",
	        (u16)(elf_offset + counter),
	        ehdr.e_ehsize
	      );
	counter += 2;
	printf("  pheader size:    %04x = %04x bytes\n",
	        (u16)(elf_offset + counter),
			    ehdr.e_phentsize
			  );
	counter += 2;
	printf("  pheaders num:    %04x = %04x\n",
	        (u16)(elf_offset + counter),
	        ehdr.e_phnum
	      );
	counter += 2;
	printf("  sheader size:    %04x = %04x bytes\n",
	        (u16)(elf_offset + counter),
			    ehdr.e_shentsize
			  );
	counter += 2;
	printf("  sheaders num:    %04x = %04x\n",
	        (u16)(elf_offset + counter),
	        ehdr.e_shnum
	      );
	counter += 2;
	printf("  sheader str idx: %04x = %04x\n",
	        (u16)(elf_offset + counter),
	        ehdr.e_shtrndx
	      );

	printf("\n\n");
}

static void show_phdr(unsigned int idx)
{
	struct elf_phdr p;
	char ppc[4], spe[4], rsx[4];

	elf_read_phdr(arch64, elf + phdr_offset + (ehdr.e_phentsize * idx), &p);

	get_flags(p.p_flags, ppc);
	get_flags(p.p_flags >> 20, spe);
	get_flags(p.p_flags >> 24, rsx);

	printf("  pheader %02x:\n",
	        idx
			  );
/*
p_type     :0x%08x
p_flags    :0x%08x
p_offset   :0x%lx
p_vaddr    :0x%lx
p_paddr    :0x%lx
p_filesz   :0x%lx
p_memsz    :0x%lx
p_align    :0x%lx
*/
	if (arch64)
	{
		printf("    type:          %04x = %08x (%s)\n",
			      (u16)(phdr_offset + elf_offset + (ehdr.e_phentsize * idx) + 0x00),
			      (u32)p.p_type,
			      id2name(p.p_type, t_phdr_type, "?????")
			    );
		printf("    flags:         %04x = %08x  PPU:%s  SPE:%s  RSX:%s\n",
			      (u16)(phdr_offset + elf_offset + (ehdr.e_phentsize * idx) + 0x04),
			      (u32)p.p_flags,
			      ppc, spe, rsx
			    );
		printf("    offset:        %04x = %08x_%08x\n",
			      (u16)(phdr_offset + elf_offset + (ehdr.e_phentsize * idx) + 0x08),
			      (u32)(p.p_off >> 32) , (u32)p.p_off
			    );
		printf("    vaddr:         %04x = %08x_%08x\n",
			      (u16)(phdr_offset + elf_offset + (ehdr.e_phentsize * idx) + 0x10),
			      (u32)(p.p_vaddr >> 32) , (u32)p.p_vaddr
			    );
		printf("    paddr:         %04x = %08x_%08x\n",
			      (u16)(phdr_offset + elf_offset + (ehdr.e_phentsize * idx) + 0x18),
			      (u32)(p.p_paddr >> 32) , (u32)p.p_paddr
			    );
		printf("    filesize:      %04x = %08x_%08x bytes\n",
			      (u16)(phdr_offset + elf_offset + (ehdr.e_phentsize * idx) + 0x20),
			      (u32)(p.p_filesz >> 32) , (u32)p.p_filesz
			    );
		printf("    memsize:       %04x = %08x_%08x bytes\n",
			      (u16)(phdr_offset + elf_offset + (ehdr.e_phentsize * idx) + 0x28),
			      (u32)(p.p_memsz >> 32) , (u32)p.p_memsz
			    );
		printf("    align:         %04x = %08x_%08x\n",
			      (u16)(phdr_offset + elf_offset + (ehdr.e_phentsize * idx) + 0x30),
			      (u32)(p.p_align >> 32) , (u32)p.p_align
			    );
	}
// TODO: fix offsets below for 32-bit
	else
	{
		printf("    type:          %04x = %s\n",
			      (u16)(phdr_offset + elf_offset + (ehdr.e_phentsize * idx) + 0x00),
			      id2name(p.p_type, t_phdr_type, "?????")
			    );
		printf("    flags:         %04x = %08x  PPU:%s  SPE:%s  RSX:%s\n",
			      (u16)(phdr_offset + elf_offset + (ehdr.e_phentsize * idx) + 0x04),
			      (u32)p.p_flags,
			      ppc, spe, rsx
			    );
		printf("    offset:        %04x = %08x\n",
			      (u16)(phdr_offset + elf_offset + (ehdr.e_phentsize * idx) + 0x04),
			      (u32)p.p_off
			    );
		printf("    vaddr:         %04x = %08x\n",
			      (u16)(phdr_offset + elf_offset + (ehdr.e_phentsize * idx) + 0x08),
			      (u32)p.p_vaddr
			    );
		printf("    paddr:         %04x = %08x\n",
			      (u16)(phdr_offset + elf_offset + (ehdr.e_phentsize * idx) + 0x0c),
			      (u32)p.p_paddr
			    );
		printf("    filesize:      %04x = %08x bytes\n",
			      (u16)(phdr_offset + elf_offset + (ehdr.e_phentsize * idx) + 0x10),
			      (u32)p.p_filesz
			    );
		printf("    memsize:       %04x = %08x bytes\n",
			      (u16)(phdr_offset + elf_offset + (ehdr.e_phentsize * idx) + 0x14),
			      (u32)p.p_memsz
			    );
		printf("    align:         %04x = %08x\n",
			      (u16)(phdr_offset + elf_offset + (ehdr.e_phentsize * idx) + 0x18),
			      (u32)p.p_align
			    );
	}
}

static void show_phdrs(void)
{
	unsigned int i;

	printf("ELF PHDR           file\n");

	if (ehdr.e_phnum == 0)
	{
		printf("No program headers in this file.\n");
	}
	else
	{
	  printf("                  offset  data\n");
		for (i = 0; i < ehdr.e_phnum; i++)
		{
			show_phdr(i);
		}
	}

	printf("\n\n");
}

static void show_sinfo(void)
{
	u32 i;
	u64 offset, size;
	u32 compressed, encrypted;
	u32 unk1, unk2;

  printf("Section Info       file\n");
  printf("                  offset  data\n");

	for (i = 0; i < ehdr.e_phnum; i++)
	{
		offset = be64(self + sec_offset + i*0x20 + 0x00);
		size = be64(self + sec_offset + i*0x20 + 0x08);
		compressed = be32(self + sec_offset + i*0x20 + 0x10);
		unk1 = be32(self + sec_offset + i*0x20 + 0x14);
		unk2 = be32(self + sec_offset + i*0x20 + 0x18);
		encrypted = be32(self + sec_offset + i*0x20 + 0x1c);

		printf("  section %02d:\n",
		        i
		      );
		printf("    start offset:  %04x = %08x_%08x\n",
				    (u16)(sec_offset + i*0x20 + 0x00),
				    (u32)(offset >> 32), (u32)offset
				  );
		printf("    section size:  %04x = %08x_%08x bytes\n",
				    (u16)(sec_offset + i*0x20 + 0x08),
				    (u32)(size >> 32), (u32)size
				  );
		printf("    compression:   %04x = %s\n",
				    (u16)(sec_offset + i*0x20 + 0x10),
				    id2name(compressed, t_compressed, "[???]")
				  );
		printf("    unknown:       %04x = %08x\n",
				    (u16)(sec_offset + i*0x20 + 0x14),
				    unk1
				  );
		printf("    unknown:       %04x = %08x\n",
				    (u16)(sec_offset + i*0x20 + 0x18),
				    unk2
				  );
		printf("    encryption:    %04x = %s\n",
				    (u16)(sec_offset + i*0x20 + 0x1c),
				    id2name(encrypted, t_encrypted, "[???]")
				  );
	}

	printf("\n\n");
}

static void show_sce_vinfo(void)
{
	u32 unk1, unk2, unk3, unk4;
	
	unk1 = be32(self + ver_info + 0x00);
	unk2 = be32(self + ver_info + 0x04);
	unk3 = be32(self + ver_info + 0x08);
	unk4 = be32(self + ver_info + 0x0c);

	printf("SCE Version Info   file\n");
	printf("                  offset  data\n");
	printf("  unknown:         %04x = %08x\n",
	        (u16)(ver_info + 0x00),
			    (u32)unk1
			  );
	printf("  unknown:         %04x = %08x\n",
	        (u16)(ver_info + 0x04),
			    unk2
			  );
	printf("  unknown:         %04x = %08x\n",
	        (u16)(ver_info + 0x08),
			    unk3
			  );
	printf("  unknown:         %04x = %08x\n",
	        (u16)(ver_info + 0x0c),
			    unk4
			  );
  printf("\n\n");
}

static void show_ctrl(void)
{
	u32 i, j;
	u32 type, length;

	printf("Control Info       file\n");
  printf("                  offset  data\n");
  
	for (i = 0; i < ctrl_size; )
	{
		type = be32(self + ctrl_offset + i);
		length = be32(self + ctrl_offset + i + 0x04);
		switch (type)
		{
			case 1:
				if (length == 0x30)
				{
					printf("  control type:    %04x = %04x\n",
					        (u16)(ctrl_offset + i),
					        (u32)type
					      );
					printf("  control length:  %04x = %04x\n",
					        (u16)(ctrl_offset + i + 0x04),
					        (u32)length
					      );
					printf("  unknown:         %04x = %08x_%08x\n",
					        (u16)(ctrl_offset + i + 0x08),
					        be32(self + ctrl_offset + i + 0x08),
					        be32(self + ctrl_offset + i + 0x0c)
					      );
					printf("  control flags:   %04x =",
					        (u16)(ctrl_offset + i + 0x10)
					      );
					print_hash(self + ctrl_offset + i + 0x10, 0x10);
					printf("\n");
					printf("  unknown:         %04x = %08x_%08x\n",
					        (u16)(ctrl_offset + i + 0x20),
					        be32(self + ctrl_offset + i + 0x20),
					        be32(self + ctrl_offset + i + 0x24)
					      );
					printf("  unknown:         %04x = %08x_%08x\n",
					        (u16)(ctrl_offset + i + 0x28),
					        be32(self + ctrl_offset + i + 0x28),
					        be32(self + ctrl_offset + i + 0x2c)
					      );
          printf("\n");
					break;
				}
			case 2:
				if (length == 0x40)
				{
					printf("  control type:    %04x = %04x\n",
					        (u16)(ctrl_offset + i),
					        (u32)type
					      );
					printf("  control length:  %04x = %04x\n",
					        (u16)(ctrl_offset + i + 0x04),
					        (u32)length
					      );
					printf("  unknown:         %04x = %08x_%08x\n",
					        (u16)(ctrl_offset + i + 0x08),
					        be32(self + ctrl_offset + i + 0x08),
					        be32(self + ctrl_offset + i + 0x0c)
					      );
					printf("  file digest:     %04x =",
					        (u16)(ctrl_offset + i + 0x10)
					      );
					print_hash(self + ctrl_offset + i + 0x10, 0x14);
					printf("\n");
					printf("  file digest:     %04x =",
					        (u16)(ctrl_offset + i + 0x24)
					      );
					print_hash(self + ctrl_offset + i + 0x24, 0x14);
					printf("\n");
					printf("  unknown:         %04x = %08x_%08x\n",
					        (u16)(ctrl_offset + i + 0x38),
					        be32(self + ctrl_offset + i + 0x38),
					        be32(self + ctrl_offset + i + 0x3c)
					      );
					break;
				}
				if (length == 0x30)
				{
					printf("  control type:    %04x = %04x\n",
					        (u16)(ctrl_offset + i),
					        (u32)type
					      );
					printf("  control length:  %04x = %04x\n",
					        (u16)(ctrl_offset + i + 0x04),
					        (u32)length
					      );
					printf("  file digest:     %04x =",
					        (u16)(ctrl_offset + i + 0x10)
					      );
					print_hash(self + ctrl_offset + i + 0x10, 0x14);
					printf("\n");
					printf("  unknown:         %04x = %08x_%08x\n",
					        (u16)(ctrl_offset + i + 0x24),
					        be32(self + ctrl_offset + i + 0x24),
					        be32(self + ctrl_offset + i + 0x28)
					      );
//					printf("  unknown:         %04x = %08x_%08x\n", (u16)(ctrl_offset + i + 0x2c), be32(self + ctrl_offset + i + 0x2c), be32(self + ctrl_offset + i + 0x30));
					break;
				}
			case 3:
				if (length == 0x90)
				{

					char id[0x31];
					memset(id, 0, 0x31);
					memcpy(id, self + ctrl_offset + i + 0x20, 0x30);

					printf("  NPDRM Info:\n");
					printf("    magic:         %04x = %08x\n",
					        (u16)(ctrl_offset + i + 0x10),
					        be32(self + ctrl_offset + i + 0x10)
					      );
					printf("    unk0 :         %04x = %08x\n",
                  (u16)(ctrl_offset + i + 0x14),
				          be32(self + ctrl_offset + i + 0x14)
				        );
					printf("    unk1 :         %04x = %08x\n",
					        (u16)(ctrl_offset + i + 0x18),
					        be32(self + ctrl_offset + i + 0x18)
					      );
					printf("    unk2 :         %04x = %08x\n",
					        (u16)(ctrl_offset + i + 0x1c),
					        be32(self + ctrl_offset + i + 0x1c)
					      );
					printf("    content_id:    %04x = %s\n",
					        (u16)(ctrl_offset + i + 0x20),
					        id);
					printf("    digest:        %04x =",
					        (u16)(ctrl_offset + i + 0x50)
					      );
					print_hash(self + ctrl_offset + i + 0x50, 0x10);
					printf("\n");
					printf("    invdigest:     %04x =",
					        (u16)(ctrl_offset + i + 0x60)
					      );
					print_hash(self + ctrl_offset + i + 0x60, 0x10);
					printf("\n");
					printf("    xordigest:     %04x =",
					       (u16)(ctrl_offset + i + 0x70)
					     );
					print_hash(self + ctrl_offset + i + 0x70, 0x10);
					printf("\n");
					printf("    unknown:       %04x = %08x_%08x\n",
					        (u16)(ctrl_offset + i + 0x80),
					        be32(self + ctrl_offset + i + 0x80),
					        be32(self + ctrl_offset + i + 0x88)
					      );
					break;
				}
			default:
				printf("  unknown:\n");
				for(j = 0; j < length; j++)
				{
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
	printf("\n\n");
}

static void show_meta(void)
{
	u32 meta_len;
	u32 meta_n_hdr;
	u32 meta_n_keys;
	u32 i;
	u64 offset, size;
	u8 *tmp;

	printf("Metadata Info      file\n");
	printf("                  offset  data\n");

	if (sdk_type == 0x8000) {
		printf("  no encrypted metadata in debug selfs.\n\n");
		return;
	}

	if (decrypted < 0) {
		printf("  unable to decrypt metadata\n\n");
		return;
	}

	meta_len = be32(self + meta_offset + 0x60 + 0x4);
	meta_n_hdr = be32(self + meta_offset + 0x60 + 0xc);
	meta_n_keys = be32(self + meta_offset + 0x60 + 0x10);

	printf("  Key:             %04x =",
	        (u16)(meta_offset + 0x20)
	      );
	print_hash(self + meta_offset + 0x20, 0x10);
	printf("\n");
	printf("  IV :             %04x =",
	        (u16)(meta_offset + 0x40)
	      );
	print_hash(self + meta_offset + 0x40, 0x10);
	printf("\n\n");

	printf("Metadata Header    file\n");
	printf("                  offset  data\n");
	printf("  Signature end:   %04x = %08x\n",
	        (u16)(meta_offset + 0x60 + 0x04),
	        meta_len
	      );
	printf("  Sections:        %04x = %d\n",
	        (u16)(meta_offset + 0x60 + 0x0c),
	        meta_n_hdr
	      );
	printf("  Keys:            %04x = %d\n",
	        (u16)(meta_offset + 0x60 + 0x10),
	        meta_n_keys
	      );
	printf("\n");
/*
	printf("  Sections         file                      file                      file        file        file\n");
	printf("                  offset       Offset       offset       Length       offset  Key offset  IV  offset  SHA1\n");
*/
	printf("  Metadata Sections  file\n");
	printf("                    offset  Data\n");
	for (i = 0; i < meta_n_hdr; i++)
	{
		tmp = self + meta_offset + 0x80 + 0x30*i;
		offset = be64(tmp);
		size = be64(tmp + 0x08);
		printf("    section %02d:\n", i);
		printf("      Offset:      %04x = %08x_%08x\n",
		        (u16)(meta_offset + 0x80 + 0x30*i),
		        (u32)(offset >> 32), (u32)offset
		      );
		printf("      Length:      %04x = %08x_%08x bytes\n",
		        (u16)((meta_offset + 0x80 + 0x30*i) + 0x08),
		        (u32)(size >> 32), (u32)size
		      );
		printf("      Key:         %04x = %04x\n",
		        (u16)((meta_offset + 0x80 + 0x30*i) + 0x24),
		        be32(tmp + 0x24)
		      );
		printf("      IV:          %04x = %04x\n",
		        (u16)((meta_offset + 0x80 + 0x30*i) + 0x28),
		        be32(tmp + 0x28)
		      );
		printf("      SHA1:        %04x = %04x\n",
		        (u16)((meta_offset + 0x80 + 0x30*i) + 0x1c),
		        be32(tmp + 0x1c)
		      );
        printf("      Type:        %04x = %04x\n",
                (u16)((meta_offset + 0x80 + 0x30*i) + 0x10),
                be32(tmp + 0x10)
              );
	}
	printf("\n");

	printf("  Metadata Keys    file\n");
	printf("                  offset  Data\n");
	tmp = self + meta_offset + 0x80 + 0x30*meta_n_hdr;
	for (i = 0; i < meta_n_keys; i++)
	{
		printf("    key idx %04x:  %04x =",
		        i,
		        (u16)((meta_offset + 0x80 + 0x30*meta_n_hdr) + i*0x10)
		      );
		print_hash(tmp + i*0x10, 0x10);
		printf("\n");
	}
	printf("\n\n");
}

static void show_shdr(unsigned int idx)
{
	struct elf_shdr s;
	char flags[4];

	elf_read_shdr(arch64, elf + shdr_offset + (ehdr.e_shentsize * idx), &s);
	get_shdr_flags(s.sh_flags, flags);

	if (arch64)
	{
/*
		printf("  section %02d:  %04x  %-9s  %04x  %-9s %04x   %-3s   %04x  %08x_%08x  %04x  %08x_%08x  %04x  %08x_%08x  %04x  %04x  %04x  %04x  %04x  %04llx  %04x  %04llx\n",
			      idx,
			      (u16)(shdr_offset + elf_offset + (ehdr.e_shentsize * idx) + 0*4),
			      "<no-name>",
			      (u16)(shdr_offset + elf_offset + (ehdr.e_shentsize * idx) + 1*4),
			      id2name(s.sh_type, t_shdr_type, "????"),
			      (u16)(shdr_offset + elf_offset + (ehdr.e_shentsize * idx) + 2*4),
			      flags,
			      (u16)(shdr_offset + elf_offset + (ehdr.e_shentsize * idx) + 2*4 + 1*8),
			      (u32)(s.sh_addr >> 32), (u32)s.sh_addr,
			      (u16)(shdr_offset + elf_offset + (ehdr.e_shentsize * idx) + 2*4 + 2*8),
			      (u32)(s.sh_offset >> 32), (u32)s.sh_offset,
			      (u16)(shdr_offset + elf_offset + (ehdr.e_shentsize * idx) + 2*4 + 3*8),
			      0, (u32)s.sh_size,
			      (u16)(shdr_offset + elf_offset + (ehdr.e_shentsize * idx) + 2*4 + 4*8),
			      (u32)s.sh_link,
			      (u16)(shdr_offset + elf_offset + (ehdr.e_shentsize * idx) + 3*4 + 4*8),
			      (u32)s.sh_info,
			      (u16)(shdr_offset + elf_offset + (ehdr.e_shentsize * idx) + 4*4 + 4*8),
			      (u64)s.sh_addralign,
			      (u16)(shdr_offset + elf_offset + (ehdr.e_shentsize * idx) + 4*4 + 5*8),
			      (u64)s.sh_entsize
			    );
*/
		printf("  section %02d:\n",
					      idx
					);
	  printf("    name:          %04x = %s\n",
			      (u16)(shdr_offset + elf_offset + (ehdr.e_shentsize * idx) + 0*4),
			      "<no-name>"
			    );
		printf("    type:          %04x = %s\n",
			  	  (u16)(shdr_offset + elf_offset + (ehdr.e_shentsize * idx) + 1*4),
			      id2name(s.sh_type, t_shdr_type, "????")
			    );
		printf("    flags:         %04x = %s\n",
			      (u16)(shdr_offset + elf_offset + (ehdr.e_shentsize * idx) + 2*4),
			      flags
			    );
		printf("    address:       %04x = %08x_%08x\n",
			      (u16)(shdr_offset + elf_offset + (ehdr.e_shentsize * idx) + 2*4 + 1*8),
			      (u32)(s.sh_addr >> 32), (u32)s.sh_addr
			    );
		printf("    offset:        %04x = %08x_%08x\n",
			      (u16)(shdr_offset + elf_offset + (ehdr.e_shentsize * idx) + 2*4 + 2*8),
			      (u32)(s.sh_offset >> 32), (u32)s.sh_offset
			    );
		printf("    length:        %04x = %08x_%08x bytes\n",
			      (u16)(shdr_offset + elf_offset + (ehdr.e_shentsize * idx) + 2*4 + 3*8),
			      0, (u32)s.sh_size
			    );
		printf("    link:          %04x = %04x\n",
			      (u16)(shdr_offset + elf_offset + (ehdr.e_shentsize * idx) + 2*4 + 4*8),
			      (u32)s.sh_link
			    );
		printf("    info:          %04x = %04x\n",
			      (u16)(shdr_offset + elf_offset + (ehdr.e_shentsize * idx) + 3*4 + 4*8),
			      (u32)s.sh_info
			    );
		printf("    addr align:    %04x = %04" PRIx64 "\n",
			      (u16)(shdr_offset + elf_offset + (ehdr.e_shentsize * idx) + 4*4 + 4*8),
			      (u64)s.sh_addralign
			    );
		printf("    ent size:      %04x = %04" PRIx64 "\n",
			      (u16)(shdr_offset + elf_offset + (ehdr.e_shentsize * idx) + 4*4 + 5*8),
			      (u64)s.sh_entsize
			    );
	}
	else 
	{
/*
		printf("  [%02d]  %04x  %-9s  %04x  %-9s  %04x  %-3s  %04x  %08x  %04x  %08x  %04x  %08x  %04x  %02x  %04x  %02x  %04x  %03x  %04x  %02x\n",
			      idx,
			      (u16)(shdr_offset + elf_offset + (ehdr.e_shentsize * idx) + 0*4),
			      "<no-name>",
			      (u16)(shdr_offset + elf_offset + (ehdr.e_shentsize * idx) + 1*4),
			      id2name(s.sh_type, t_shdr_type, "????"),
			      (u16)(shdr_offset + elf_offset + (ehdr.e_shentsize * idx) + 2*4),
			      flags,
			      (u16)(shdr_offset + elf_offset + (ehdr.e_shentsize * idx) + 3*4),
			      (u32)s.sh_addr,
			      (u16)(shdr_offset + elf_offset + (ehdr.e_shentsize * idx) + 4*4),
			      (u32)s.sh_offset,
			      (u16)(shdr_offset + elf_offset + (ehdr.e_shentsize * idx) + 5*4),
			      s.sh_size,
			      (u16)(shdr_offset + elf_offset + (ehdr.e_shentsize * idx) + 6*4),
			      s.sh_link,
			      (u16)(shdr_offset + elf_offset + (ehdr.e_shentsize * idx) + 7*4),
			      s.sh_info,
			      (u16)(shdr_offset + elf_offset + (ehdr.e_shentsize * idx) + 8*4),
		        s.sh_addralign,
		        (u16)(shdr_offset + elf_offset + (ehdr.e_shentsize * idx) + 9*4),
			      s.sh_entsize
		      );
*/
		printf("  section %02d:\n",
					      idx
					);
	  printf("    name:          %04x = %s\n",
			      (u16)(shdr_offset + elf_offset + (ehdr.e_shentsize * idx) + 0*4),
			      "<no-name>"
			    );
		printf("    type:          %04x = %s\n",
			  	  (u16)(shdr_offset + elf_offset + (ehdr.e_shentsize * idx) + 1*4),
			      id2name(s.sh_type, t_shdr_type, "????")
			    );
		printf("    flags:         %04x = %s\n",
			      (u16)(shdr_offset + elf_offset + (ehdr.e_shentsize * idx) + 2*4),
			      flags
			    );
		printf("    address:       %04x = %08x\n",
			      (u16)(shdr_offset + elf_offset + (ehdr.e_shentsize * idx) + 3*4),
			      (u32)s.sh_addr
			    );
		printf("    offset:        %04x = %08x\n",
			      (u16)(shdr_offset + elf_offset + (ehdr.e_shentsize * idx) + 4*4),
			      (u32)s.sh_offset
			    );
		printf("    length:        %04x = %08x bytes\n",
			      (u16)(shdr_offset + elf_offset + (ehdr.e_shentsize * idx) + 5*4),
			      (u32)s.sh_size
			    );
		printf("    link:          %04x = %04x\n",
			      (u16)(shdr_offset + elf_offset + (ehdr.e_shentsize * idx) + 6*4),
			      (u32)s.sh_link
			    );
		printf("    info:          %04x = %04x\n",
			      (u16)(shdr_offset + elf_offset + (ehdr.e_shentsize * idx) + 7*4),
			      (u32)s.sh_info
			    );
		printf("    addr align:    %04x = %04x\n",
			      (u16)(shdr_offset + elf_offset + (ehdr.e_shentsize * idx) + 8*4),
			      (u32)s.sh_addralign
			    );
		printf("    ent size:      %04x = %04x\n",
			      (u16)(shdr_offset + elf_offset + (ehdr.e_shentsize * idx) + 9*4),
			      (u32)s.sh_entsize
			    );
	}
}

static void show_shdrs(void)
{
	unsigned int i;

	printf("ELF SHDRs\n");

	if (ehdr.e_shnum == 0)
	{
		printf("No ELF Section Headers in this file.\n");
	}
	else
	{
		if (arch64)
	  {
/*
			printf("               file             file            file         file                     file                     file                     file        file        file        file\n");
			printf("              offset  Name     Offset Type     Offset Flags Offset Address           Offset Offset            Offset Size              Offset Link Offset Info Offset Aln  Offset ES\n");
*/
      printf("                   file\n");
      printf("                  Offset  data\n");
		}
		else
			printf("  [Nr]  Name             Type     Flags  Address   Offset    Size      Link  Info  Align ES\n");
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
	show_elf_header();
	show_phdrs();
	show_sinfo();
	show_sce_vinfo();
	show_ctrl();
	show_meta();
	show_shdrs();

	return 0;
}
