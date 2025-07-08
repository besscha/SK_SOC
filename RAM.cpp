uint32_t *pmen; // 1MB memory

extern "C" int pmem_read(svBit re, int raddr)
{
    if (!re) return 0x13;
    if (raddr >= 1000000)
    {
        return 0;
    }
    uint32_t byte_addr = raddr;
    return pmen[raddr];
}

// write physical memory with write enable we, write addr waddr, write size (1 << mask), write data wword
extern "C" void pmem_write(int we, int waddr, int wword)
{
    if (we == 0) return; // no write
    if (waddr >= 1000000 && we != 0)
    {
        printf("Error: write address out of range: %08x\n", waddr);
        return;
    }
    int mask = (we & 0b1 ? 1 : 0) * 0xff +
               (we & 0b10 ? 1 : 0) * 0xff00 +
               (we & 0b100 ? 1 : 0)  * 0xff0000 +
               (we & 0b1000 ? 1 : 0) * 0xff000000; 
    pmen[waddr] = wword & mask | pmen[waddr] & ~mask;
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
    pmen = new uint32_t[1000000]; // Allocate 1MB of memory
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
        //printf("addr: %08x, data: %08x\n", addr, word);
        pmen[addr++] = word;
    }
    fclose(fp);
}