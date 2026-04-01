# Compilação para Emulsiv

Para compilar o seu código assembly para o Emulsiv, você precisará de um compilador RISC-V. Para este trabalho utilizaremos o `riscv64-unknown-elf-gcc`.


### 1. Instale o compilador no Linux


```bash
sudo apt install gcc-riscv64-unknown-elf
```

### 2. Escreva o seu código assembly

O seu código deve estar no arquivo `jogo.s`  sob o rótulo `main`. 

Use um editor de texto de sua preferência para editar o arquivo `jogo.s` (como o VS Code).

### 3. Compile o código assembly para o formato HEX

Para gerar o código HEX para o Emulsiv basta digitar o comando abaixo no terminal e dentro do diretório onde está o arquivo `jogo.s`:  

```bash
make 
```

👉 O arquivo `jogo.s` deve estar no mesmo diretório que os arquivos  `Makefile`, `emulsiv.ld` e `startup.s`.

### 4. Como executar o código

O arquivo gerado será `jogo.hex`. Você pode carregá-lo no Emulsiv para testar e executar o seu código.

---

O que é o formato HEX?

É um formato de arquivo de texto que representa dados binários em uma forma legível para humanos. Cada linha do arquivo contém um número de 32 bits em hexadecimal.