uint32_t *pmen; // 1MB memory

extern "C" void pmem_read(bool re, uint32_t raddr, uint32_t *rword) {
    if (!re) return;
    uint32_t byte_addr = raddr;
    *rword = pmen[raddr];
    return;
}

// write physical memory with write enable we, write addr waddr, write size (1 << mask), write data wword
extern "C" void pmem_write(bool we, uint32_t waddr, uint32_t wword) {
    if (!we) return;
    pmen[waddr] = wword;
    return;
}

void pmen_load_text(const char *filename) {
    pmen = new uint32_t[1000000]; // Allocate 1MB of memory
    FILE *fp = fopen(filename, "r");
    if (fp == NULL) {
        printf("Error opening file %s\n", filename);
        return;
    }
    char line[256];
    int addr = 0;
    while (fgets(line, sizeof(line), fp) != NULL) {
        if (line[0] == '#') continue; // skip comments
        //printf("line: %s", line);
        if (sscanf(line, "%x", &pmen[addr]) != 1) break;
        //printf("addr: %08x, data: %08x\n", addr, pmen[addr]);
        addr++;
    }
    fclose(fp);
}

void pmen_load_bin (const char *filename) {
    pmen = new uint32_t[2 ^ 20]; // Allocate 1MB of memory
    FILE *fp = fopen(filename, "rb");
    if (fp == NULL) {
        printf("Error opening file %s\n", filename);
        return;
    }
    int addr = 0;
    while (1) {
        uint32_t word;
        size_t result = fread(&word, sizeof(uint32_t), 1, fp);
        if (result != 1) break; // End of file or read error
        pmen[addr++] = word;
    }
    fclose(fp);
}