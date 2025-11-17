void _start() {
    const char *message = "Hello from my kernel!";
    char *vidmem = (char *)0xB8000;     // Video memory address

    for (int i = 0; message[i] != '\0'; i++) {
        vidmem[i * 2] = message[i];     // Print char
        vidmem[i * 2 + 1] = 0x07;       // Print on white over black
    }

    while (1) {}
}
