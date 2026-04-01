# Makefile para compilação de código para a arquitetura RISC-V

# Definição do compilador
CC=riscv64-unknown-elf-gcc
# Opções de compilação
CFLAGS=-march=rv32i -mabi=ilp32 -ffreestanding
# Opções de linkagem
LDFLAGS=-nostdlib -T emulsiv.ld
# Conversor para HEX
OBJCOPY=riscv64-unknown-elf-objcopy

# Nome do arquivo de saída sem a extensão
TARGET=jogo

# Por padrão, compila o arquivo .elf e depois converte para .hex
all: $(TARGET).elf hex

# Compilação dos arquivos .o necessários
startup.o: startup.s
	$(CC) $(CFLAGS) -c -o $@ $<

%.o: %.s
	$(CC) $(CFLAGS) -c -o $@ $<

# Linkagem para criar o executável .elf
$(TARGET).elf: startup.o $(TARGET).o
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

# Regra para converter o arquivo .elf para .hex
hex: $(TARGET).elf
	$(OBJCOPY) -O ihex $< $(TARGET).hex

# Limpeza dos arquivos gerados
clean:
	rm -f *.o *.elf *.hex
