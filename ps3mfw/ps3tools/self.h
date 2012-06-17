/*
 * This software is distributed under the terms of the GNU General Public
 * License ("GPL") version 2, as published by the Free Software Foundation.
 */

#ifndef SELF_H__
#define SELF_H__

#include <stdint.h>
#include <stdio.h>

#define SCE_MAGIC 0x53434500

typedef struct {
  uint32_t magic;
  uint32_t version;
  uint16_t flags;
  uint16_t type;
  uint32_t metadata_offset;
  uint64_t header_len;
  uint64_t elf_filesize;
  uint64_t unknown;
  uint64_t appinfo_offset;
  uint64_t elf_offset;
  uint64_t phdr_offset;
  uint64_t shdr_offset;
  uint64_t section_info_offset;
  uint64_t sceversion_offset;
  uint64_t controlinfo_offset;
  uint64_t controlinfo_size;
  uint64_t padding;
} __attribute__((packed)) SELF;

typedef struct {
  uint64_t authid;
  uint32_t vendor_id;
  uint32_t self_type;
  uint32_t version;
  uint8_t padding[12];
} __attribute__((packed)) APP_INFO;

typedef struct {
  uint8_t ident[16];
  uint16_t type;
  uint16_t machine;
  uint32_t version;
  uint64_t entry_point;
  uint64_t phdr_offset;
  uint64_t shdr_offset;
  uint16_t flags;
  uint32_t header_size;
  uint16_t phent_size;
  uint16_t phnum;
  uint16_t shent_size;
  uint16_t shnum;
  uint16_t shstrndx;
} __attribute__((packed)) ELF;

typedef struct {
  uint32_t type;
  uint32_t flags;
  uint64_t offset_in_file;
  uint64_t vitual_addr;
  uint64_t phys_addr;
  uint64_t segment_size;
  uint64_t segment_mem_size;
  uint64_t alignment;
} __attribute__((packed)) ELF_PHDR;

typedef struct {
  uint32_t name_idx;
  uint32_t type;
  uint64_t flags;
  uint64_t virtual_addr;
  uint64_t offset_in_file;
  uint64_t segment_size;
  uint32_t link;
  uint32_t info;
  uint64_t addr_align;
  uint64_t entry_size;
} __attribute__((packed)) ELF_SHDR;

typedef struct {
  uint64_t offset;
  uint64_t size;
  uint32_t compressed; // 2=compressed
  uint32_t unknown1;
  uint32_t unknown2;
  uint32_t encrypted; // 1=encrypted
} __attribute__((packed)) SECTION_INFO;

typedef struct {
  uint32_t unknown1;
  uint32_t unknown2;
  uint32_t unknown3;
  uint32_t unknown4;
} __attribute__((packed)) SCEVERSION_INFO;

typedef struct {
  uint32_t type; // 1==control flags; 2==file digest
  uint32_t size;
  union {
    // type 1
    struct {
      uint64_t control_flags;
      uint8_t padding[32];
    } control_flags;

    // type 2
    struct {
      uint64_t unknown;
      uint8_t digest1[20];
      uint8_t digest2[20];
      uint8_t padding[8];
    } file_digest;

    struct {
        uint32_t unknown1;
        uint32_t unknown2;
        uint32_t magic;
        uint32_t unknown3;
        uint32_t license_type;
        uint32_t type;
        uint8_t content_id[0x30];
        uint8_t hash[0x10];
        uint8_t hash_iv[0x10];
        uint8_t hash_xor[0x10];
        uint8_t padding[0x10];
    } npdrm;
  };
} __attribute__((packed)) CONTROL_INFO;


typedef struct {
  //uint8_t ignore[32];
  uint8_t key[16];
  uint8_t key_pad[16];
  uint8_t iv[16];
  uint8_t iv_pad[16];
} __attribute__((packed)) METADATA_INFO;

typedef struct {
  uint64_t signature_input_length;
  uint32_t unknown1;
  uint32_t section_count;
  uint32_t key_count;
  uint32_t signature_info_size;
  uint64_t unknown2;
} __attribute__((packed)) METADATA_HEADER;

typedef struct {
  uint64_t data_offset;
  uint64_t data_size;
  uint32_t type; // 1 = shdr, 2 == phdr
  uint32_t program_idx;
  uint32_t unknown;
  uint32_t sha1_idx;
  uint32_t encrypted; // 3=yes; 1=no
  uint32_t key_idx;
  uint32_t iv_idx;
  uint32_t compressed; // 2=yes; 1=no
} __attribute__((packed)) METADATA_SECTION_HEADER;

typedef struct {
  uint8_t sha1[20];
  uint8_t padding[12];
  uint8_t hmac_key[64];
} __attribute__((packed)) SECTION_HASH;

typedef struct {
  uint32_t unknown1;
  uint32_t signature_size;
  uint64_t unknown2;
  uint64_t unknown3;
  uint64_t unknown4;
  uint64_t unknown5;
  uint32_t unknown6;
  uint32_t unknown7;
} __attribute__((packed)) SIGNATURE_INFO;

typedef struct {
  uint8_t r[21];
  uint8_t s[21];
  uint8_t padding[6];
} __attribute__((packed)) SIGNATURE;


typedef struct {
  uint8_t *data;
  uint64_t size;
  uint64_t offset;
} SELF_SECTION;



void self_read_headers(FILE *in, SELF *self, APP_INFO *app_info, ELF *elf,
    ELF_PHDR **phdr, ELF_SHDR **shdr, SECTION_INFO **section_info,
    SCEVERSION_INFO *sceversion_info, CONTROL_INFO **control_info);

void self_read_metadata (FILE *in, SELF *self, APP_INFO *app_info,
    METADATA_INFO *metadata_info, METADATA_HEADER *metadata_header,
    METADATA_SECTION_HEADER **section_headers, uint8_t **keys,
    SIGNATURE_INFO *signature_info, SIGNATURE *signature, CONTROL_INFO *control_info);

int self_load_sections (FILE *in, SELF *self, ELF *elf, ELF_PHDR **phdr,
    METADATA_HEADER *metadata_header, METADATA_SECTION_HEADER **section_headers,
    uint8_t **keys, SELF_SECTION **sections);

void self_free_sections (SELF_SECTION **sections, uint32_t num_sections);

#endif /* SELF_H__ */
