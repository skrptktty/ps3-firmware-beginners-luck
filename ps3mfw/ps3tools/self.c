/*
 * This software is distributed under the terms of the GNU General Public
 * License ("GPL") version 2, as published by the Free Software Foundation.
 */

#include "tools.h"
#include "self.h"
#include "common.h"

#include <string.h>
#include <stdlib.h>

static struct keylist *load_keys(APP_INFO *app_info);
static int decrypt_metadata(uint8_t *metadata, uint32_t metadata_size,
    struct keylist *klist);
static int remove_npdrm(SELF *self, CONTROL_INFO *control_info, uint8_t *metadata,
    struct keylist *klist);
static void decrypt_npdrm(uint8_t *metadata, struct keylist *klist,
    struct key *klicensee);




void
self_read_headers(FILE *in, SELF *self, APP_INFO *app_info, ELF *elf,
    ELF_PHDR **phdr, ELF_SHDR **shdr, SECTION_INFO **section_info,
    SCEVERSION_INFO *sceversion_info, CONTROL_INFO **control_info)
{

  // SELF
  if (fread (self, sizeof(SELF), 1, in) != 1) {
    ERROR (-3, "Couldn't read SELF header");
  }

  self->magic = swap32 (self->magic);
  self->version = swap32 (self->version);
  self->flags = swap16 (self->flags);
  self->type = swap16 (self->type);
  self->metadata_offset = swap32 (self->metadata_offset);
  self->header_len = swap64 (self->header_len);
  self->elf_filesize = swap64 (self->elf_filesize);
  self->appinfo_offset = swap64 (self->appinfo_offset);
  self->elf_offset = swap64 (self->elf_offset);
  self->phdr_offset = swap64 (self->phdr_offset);
  self->shdr_offset = swap64 (self->shdr_offset);
  self->section_info_offset = swap64 (self->section_info_offset);
  self->sceversion_offset = swap64 (self->sceversion_offset);
  self->controlinfo_offset = swap64 (self->controlinfo_offset);
  self->controlinfo_size = swap64 (self->controlinfo_size);

  if (self->magic != SCE_MAGIC) {
    ERROR (-3, "not a SELF\n");
  }

  // APP INFO
  if (app_info) {
    fseek (in, self->appinfo_offset, SEEK_SET);
    if (fread (app_info, sizeof(APP_INFO), 1, in) != 1) {
      ERROR (-3, "Couldn't read APP INFO header");
    }
    app_info->authid = swap64 (app_info->authid);
    app_info->vendor_id = swap32 (app_info->vendor_id);
    app_info->self_type = swap32 (app_info->self_type);
    app_info->version = swap32 (app_info->version);
  }

  // ELF
  if (elf) {
    fseek (in, self->elf_offset, SEEK_SET);
    if (fread (elf, sizeof(ELF), 1, in) != 1) {
      ERROR (-3, "Couldn't read APP INFO header");
    }
    elf->type = swap16 (elf->type);
    elf->machine = swap16 (elf->machine);
    elf->version = swap32 (elf->version);
    elf->entry_point = swap64 (elf->entry_point);
    elf->phdr_offset = swap64 (elf->phdr_offset);
    elf->shdr_offset = swap64 (elf->shdr_offset);
    elf->flags = swap16 (elf->flags);
    elf->header_size = swap32 (elf->header_size);
    elf->phent_size = swap16 (elf->phent_size);
    elf->phnum = swap16 (elf->phnum);
    elf->shent_size = swap16 (elf->shent_size);
    elf->shnum = swap16 (elf->shnum);
    elf->shstrndx = swap16 (elf->shstrndx);
  }

  // PHDR and SECTION INFO
  if (phdr || section_info) {
    uint16_t phnum = 0;
    uint16_t i;

    if (elf) {
      phnum = elf->phnum;
    } else {
      fseek (in, self->elf_offset + 52, SEEK_SET);
      fread (&phnum, sizeof(uint16_t), 1, in);
    }

    if (phdr) {
      ELF_PHDR *elf_phdr = NULL;

      elf_phdr = malloc (sizeof(ELF_PHDR) * phnum);

      fseek (in, self->phdr_offset, SEEK_SET);
      if (fread (elf_phdr, sizeof(ELF_PHDR), phnum, in) != phnum) {
        ERROR (-3, "Couldn't read ELF PHDR header");
      }

      for (i = 0; i < phnum; i++) {
        elf_phdr[i].type = swap32 (elf_phdr[i].type);
        elf_phdr[i].flags = swap32 (elf_phdr[i].flags);
        elf_phdr[i].offset_in_file = swap64 (elf_phdr[i].offset_in_file);
        elf_phdr[i].vitual_addr = swap64 (elf_phdr[i].vitual_addr);
        elf_phdr[i].phys_addr = swap64 (elf_phdr[i].phys_addr);
        elf_phdr[i].segment_size = swap64 (elf_phdr[i].segment_size);
        elf_phdr[i].segment_mem_size = swap64 (elf_phdr[i].segment_mem_size);
        elf_phdr[i].alignment = swap64 (elf_phdr[i].alignment);
      }

      *phdr = elf_phdr;
    }

    // SECTION INFO
    if (section_info) {
      SECTION_INFO *sections = NULL;

      sections = malloc (sizeof(SECTION_INFO) * phnum);

      fseek (in, self->section_info_offset, SEEK_SET);
      if (fread (sections, sizeof(SECTION_INFO), phnum, in) != phnum) {
        ERROR (-3, "Couldn't read SECTION INFO header");
      }

      for (i = 0; i < phnum; i++) {
        sections[i].offset = swap64 (sections[i].offset);
        sections[i].size = swap64 (sections[i].size);
        sections[i].compressed = swap32 (sections[i].compressed);
        sections[i].encrypted = swap32 (sections[i].encrypted);
      }

      *section_info = sections;
    }
  }

  // SCE VERSION INFO
  if (sceversion_info) {
    fseek (in, self->sceversion_offset, SEEK_SET);
    if (fread (sceversion_info, sizeof(SCEVERSION_INFO), 1, in) != 1) {
      ERROR (-3, "Couldn't read SCE VERSION INFO header");
    }
  }

  // CONTROL INFO
  if (control_info) {
    uint32_t offset = 0;
    uint32_t index = 0;
    CONTROL_INFO *info = NULL;

    while (offset < self->controlinfo_size) {

      info = realloc (info, sizeof(CONTROL_INFO) * (index + 1));

      fseek (in, self->controlinfo_offset + offset, SEEK_SET);

      if (fread (info + index, sizeof(CONTROL_INFO), 1, in) != 1) {
        ERROR (-3, "Couldn't read CONTROL INFO header");
      }

      info[index].type = swap32 (info[index].type);
      info[index].size = swap32 (info[index].size);
      if (info[index].type == 1)
        info[index].control_flags.control_flags =
            swap64 (info[index].control_flags.control_flags);
      if (info[index].type == 3)
        info[index].npdrm.license_type =
            swap32 (info[index].npdrm.license_type);

      offset += info[index].size;
      index++;
    }
    *control_info = info;
  }


  // SHDR
  if (shdr) {
    uint16_t shnum = 0;
    uint16_t i;
    ELF_SHDR *elf_shdr = NULL;

    if (elf) {
      shnum = elf->shnum;
    } else {
      fseek (in, self->elf_offset + 56, SEEK_SET);
      fread (&shnum, sizeof(uint16_t), 1, in);
    }

    if (shnum > 0 && self->shdr_offset != 0) {
      elf_shdr = malloc (sizeof(ELF_SHDR) * shnum);

      fseek (in, self->shdr_offset, SEEK_SET);
      if (fread (elf_shdr, sizeof(ELF_SHDR), shnum, in) != shnum) {
        ERROR (-3, "Couldn't read ELF SHDR header");
      }

      for (i = 0; i < shnum; i++) {
        elf_shdr[i].name_idx = swap32 (elf_shdr[i].name_idx);
        elf_shdr[i].type = swap32 (elf_shdr[i].type);
        elf_shdr[i].flags = swap64 (elf_shdr[i].flags);
        elf_shdr[i].virtual_addr = swap64 (elf_shdr[i].virtual_addr);
        elf_shdr[i].offset_in_file = swap64 (elf_shdr[i].offset_in_file);
        elf_shdr[i].segment_size = swap64 (elf_shdr[i].segment_size);
        elf_shdr[i].link = swap32 (elf_shdr[i].link);
        elf_shdr[i].info = swap32 (elf_shdr[i].info);
        elf_shdr[i].addr_align = swap64 (elf_shdr[i].addr_align);
        elf_shdr[i].entry_size = swap64 (elf_shdr[i].entry_size);
      }

      *shdr = elf_shdr;
    }
  }

}


void
self_read_metadata (FILE *in, SELF *self, APP_INFO *app_info,
    METADATA_INFO *metadata_info, METADATA_HEADER *metadata_header,
    METADATA_SECTION_HEADER **section_headers, uint8_t **keys,
    SIGNATURE_INFO *signature_info, SIGNATURE *signature, CONTROL_INFO *control_info)
{
  uint8_t *metadata = NULL;
  uint32_t metadata_size = self->header_len - self->metadata_offset - 0x20;
  uint8_t *ptr = NULL;
  uint32_t i;

  metadata = malloc (metadata_size);
  fseek (in, self->metadata_offset + 0x20, SEEK_SET);

  if (fread (metadata, 1, metadata_size, in) != metadata_size) {
    ERROR (-3, "Couldn't read METADATA");
  }

  if (self->flags != 0x800) {
    struct keylist *klist;

    klist = load_keys(app_info);
    if (klist == NULL)
      ERROR(-5, "no key found");

    if (remove_npdrm (self, control_info, metadata, klist) < 0)
      ERROR (-5, "Error removing NPDRM");

    if (decrypt_metadata (metadata, metadata_size, klist) < 0)
      ERROR (-5, "Error decrypting metadata");
  }

  ptr = metadata;
  *metadata_info = *((METADATA_INFO *)ptr);
  ptr += sizeof(METADATA_INFO);
  if (metadata_header) {
    *metadata_header = *((METADATA_HEADER *)ptr);
    metadata_header->signature_input_length =
        swap64 (metadata_header->signature_input_length);
    metadata_header->section_count = swap32 (metadata_header->section_count);
    metadata_header->key_count = swap32 (metadata_header->key_count);
    metadata_header->signature_info_size =
        swap32 (metadata_header->signature_info_size);
  }
  ptr += sizeof(METADATA_HEADER);
  if (section_headers) {
    *section_headers = malloc (sizeof(METADATA_SECTION_HEADER) *
        metadata_header->section_count);
    for (i = 0; i < metadata_header->section_count; i++) {
      (*section_headers)[i] = *((METADATA_SECTION_HEADER *)ptr);
      ptr += sizeof(METADATA_SECTION_HEADER);
      (*section_headers)[i].data_offset = swap64 ((*section_headers)[i].data_offset);
      (*section_headers)[i].data_size = swap64 ((*section_headers)[i].data_size);
      (*section_headers)[i].type = swap32 ((*section_headers)[i].type);
      (*section_headers)[i].program_idx = swap32 ((*section_headers)[i].program_idx);
      (*section_headers)[i].sha1_idx = swap32 ((*section_headers)[i].sha1_idx);
      (*section_headers)[i].encrypted = swap32 ((*section_headers)[i].encrypted);
      (*section_headers)[i].key_idx = swap32 ((*section_headers)[i].key_idx);
      (*section_headers)[i].iv_idx = swap32 ((*section_headers)[i].iv_idx);
      (*section_headers)[i].compressed = swap32 ((*section_headers)[i].compressed);
    };
  } else {
    ptr += sizeof(METADATA_SECTION_HEADER) * metadata_header->section_count;
  }
  *keys = malloc (metadata_header->key_count * 0x10);
  memcpy (*keys, ptr, metadata_header->key_count * 0x10);
  ptr += metadata_header->key_count * 0x10;
  if (signature_info) {
    *signature_info = *((SIGNATURE_INFO *)ptr);
    signature_info->signature_size = swap32 (signature_info->signature_size);
  }
  ptr += sizeof(SIGNATURE_INFO);
  if (signature) {
    *signature = *((SIGNATURE *)ptr);
  }
  ptr += sizeof(SIGNATURE);
  free (metadata);
}

int
self_load_sections (FILE *in, SELF *self, ELF *elf, ELF_PHDR **phdr,
    METADATA_HEADER *metadata_header, METADATA_SECTION_HEADER **section_headers,
    uint8_t **keys, SELF_SECTION **sections)
{
  uint32_t num_sections = 0;
  uint32_t i;

  num_sections = metadata_header->section_count + 1;

  *sections = malloc (sizeof(SELF_SECTION) * num_sections);
  // ELF header
  for (i = 0; i < num_sections; i++) {
    uint32_t size;
    METADATA_SECTION_HEADER *hdr;

    if (i == 0) {
      uint32_t elf_size;

      hdr = (*section_headers);
      elf_size = elf->header_size + (elf->phent_size * elf->phnum);
      size = hdr->data_offset - self->header_len;
      if (size < elf_size)
        size = elf_size;
      (*sections)[i].offset = 0;
      (*sections)[i].size = size;
      (*sections)[i].data = malloc (size);

      fseek (in, self->header_len, SEEK_SET);
      if (fread ((*sections)[0].data, 1, size, in) != size) {
        ERROR (-6, "Couldn't read section");
      }

      fseek (in, self->elf_offset, SEEK_SET);
      if (fread ((*sections)[0].data, 1, size, in) != size) {
        ERROR (-6, "Couldn't read section");
      }
    } else {
      uint8_t *temp_data = NULL;

      hdr = (*section_headers) + i - 1;
      if (hdr->type == 2) {
        // phdr
        size = (*phdr)[hdr->program_idx].segment_size;
        (*sections)[i].offset = (*phdr)[hdr->program_idx].offset_in_file;
      } else if (hdr->type == 1) {
        // shdr
        size = (*section_headers)[i-1].data_size;
        (*sections)[i].offset = elf->shdr_offset;
      } else {
        (*sections)[i].offset = UINT64_MAX;
        printf("Section %d unkown type: %d. Skipping!\n", i, hdr->type);
      }

      (*sections)[i].size = size;
      (*sections)[i].data = malloc (size);

      temp_data = malloc (hdr->data_size);
      fseek (in, hdr->data_offset, SEEK_SET);
      if (fread (temp_data, 1, hdr->data_size, in) != hdr->data_size) {
        ERROR (-6, "Couldn't read section");
      }

      if (hdr->encrypted == 3)
	aes128ctr(*keys + 0x10 * hdr->key_idx, *keys + 0x10 * hdr->iv_idx,
            temp_data, hdr->data_size, temp_data);

      if (hdr->compressed == 2)
        decompress(temp_data, hdr->data_size, (*sections)[i].data, size);
      else
        memcpy ((*sections)[i].data, temp_data, size);

      free (temp_data);
    }
  }

  return num_sections;
}

void
self_free_sections (SELF_SECTION **sections, uint32_t num_sections)
{
  uint32_t i;

  for (i = 0; i < num_sections; i++) {
    free ((*sections)[i].data);
  }
  free (*sections);
  *sections = NULL;
}

static struct keylist *
load_keys(APP_INFO *app_info)
{
  enum sce_key id;

  switch (app_info->self_type) {
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
      fprintf (stderr, "SELF type is invalid : 0x%08X\n", app_info->self_type);
      exit (-4);
  }

  return keys_get(id);
}

static int
remove_npdrm(SELF *self, CONTROL_INFO *control_info, uint8_t *metadata, struct keylist *klist)
{
    CONTROL_INFO *info;
    u32 license_type;
    char content_id[0x31] = {'\0'};
    struct rif *rif;
    struct actdat *actdat;
    u8 enc_const[0x10];
    u8 dec_actdat[0x10];
    struct key klicensee;
    int i;
    u64 off;

    for (i = off = 0; off < self->controlinfo_size; i++) {
        info = &control_info[i];
        if (info->type == 3) {
            license_type = info->npdrm.license_type;
            switch (license_type) {
                case 1:
                    // cant decrypt network stuff
                    return -1;
                case 2:
                    memcpy(content_id, info->npdrm.content_id, 0x30);
                    rif = rif_get(content_id);
                    if (rif == NULL) {
                        return -1;
                    }
                    aes128(klist->rif->key, rif->padding, rif->padding);
                    aes128_enc(klist->idps->key, klist->npdrm_const->key, enc_const);
                    actdat = actdat_get();
                    if (actdat == NULL) {
                        return -1;
                    }
                    aes128(enc_const, &actdat->keyTable[swap32(rif->actDatIndex)*0x10], dec_actdat);
                    aes128(dec_actdat, rif->key, klicensee.key);
                    decrypt_npdrm(metadata, klist, &klicensee);
                    return 1;
                case 3:
                    decrypt_npdrm(metadata, klist, klist->free_klicensee);
                    return 1;
            }
        }

        off += info->size;
    }
    return 0;
}

static void
decrypt_npdrm(uint8_t *metadata, struct keylist *klist, struct key *klicensee)
{
    struct key d_klic;

    // iv is 0
    memset(&d_klic, 0, sizeof(struct key));
    aes128(klist->klic->key, klicensee->key, d_klic.key);

    aes128cbc(d_klic.key, d_klic.iv, metadata, 0x40, metadata);
}

static int
decrypt_metadata(uint8_t *metadata, uint32_t metadata_size,
    struct keylist *klist)
{
  uint32_t i;
  METADATA_INFO metadata_info;
  uint8_t zero[16] = {0};

  for (i = 0; i < klist->n; i++) {
    aes256cbc(klist->keys[i].key,  klist->keys[i].iv,
        metadata, sizeof(METADATA_INFO), (uint8_t *) &metadata_info);

    if (memcmp (metadata_info.key_pad, zero, 16) == 0 &&
        memcmp (metadata_info.iv_pad, zero, 16) == 0) {
      memcpy(metadata, &metadata_info, sizeof(METADATA_INFO));
      break;
    }
  }

  if (i >= klist->n)
    return -1;

  aes128ctr(metadata_info.key, metadata_info.iv,
      metadata + sizeof(METADATA_INFO),
      metadata_size - sizeof(METADATA_INFO),
      metadata + sizeof(METADATA_INFO));

  return i;
}
