# Aritmética de Pontos Flutuantes

**Autor:** Rodrigo Machado Gonçalves - [@GncRodrigo](https://github.com/GncRodrigo)
Implementação em SystemVerilog de operações com números de ponto flutuante, utilizando um padrão IEEE 754 personalizado, com módulo principal e testbench para simulação.

---

## 💡 IEEE 754 Personalizado

O padrão IEEE 754 foi adaptado para este projeto, conforme a proposta do trabalho, em que cada aluno deveria utilizar um formato exclusivo de mantissa e expoente. O cálculo seguiu a fórmula:
  X = 8 (+/- ∑b mod 4)
  
- `∑b`: Soma de todos os dígitos da matrícula (em base 10).
- `mod 4`: Resto da divisão inteira por 4.
- O sinal **+** ou **-** é determinado pelo **dígito verificador da matrícula**:
  - **+** se for ímpar
  - **−** se for par

### Aplicação no meu caso:
- Matrícula: 241079474  
- Soma dos dígitos: 2 + 4 + 1 + 0 + 7 + 9 + 4 + 7 + 4 = **38**  
- 38 % 4 = **2**  
- Dígito verificador: **9** → ímpar → sinal negativo  
- Cálculo final: **8 - 2 = 6**

Portanto:
- **Expoente:** 6 bits  
- **Mantissa:** 31 - 6 = **25 bits**

---

## 🧠 Visão Geral

Este projeto implementa um módulo chamado `PontosFlutuantes` em SystemVerilog, que realiza **operações de adição e subtração** entre números representados em um formato de ponto flutuante personalizado.  
Um testbench (`tb_Pontos.sv`) acompanha o projeto para verificação funcional por meio de simulação no ModelSim.

---

## 🧱 Tecnologias & Arquivos

- **SystemVerilog**:
  - `PontosFlutuantes.sv`: Módulo principal (FSM)
  - `tb_Pontos.sv`: Testbench de verificação funcional
- **Scripts para ModelSim**:
  - `sim.do`, `wave.do` (scipts de execução e forma da onda)

---

## 🛠️ Como foi desenvolvido

- O clock do sistema opera a **100 kHz**.
- O **reset** é **assíncrono e ativo em nível baixo**.
- O projeto utiliza uma **máquina de estados finitos (FSM)** com 6 estados:
  - `READ`, `EQUALIZING`, `OPERATION`, `POS_OPERATION`, `FINALIZE`, `CHECK`
- As entradas `op_A_in` e `op_B_in` são decompostas em sinal, expoente e mantissa usando lógica combinacional.
- Diversos **testes foram realizados** no testbench, cobrindo diferentes cenários de operação para validação robusta do sistema.
---
## 🔢Espectro numérico (IEEE 754 personalizado)

![image](https://github.com/user-attachments/assets/c9051eef-3163-4204-805d-68b1b8c6ceee)

---
## 🌊 Resultados da Waveform:
![image](https://github.com/user-attachments/assets/1326533a-4272-4b31-8cd4-b1e59011196b)

---
## 🚀 Como compilar e simular

**Passo a passo**:

```bash
# 1. Clone o repositório
git clone https://github.com/GncRodrigo/Aritim-tica_de_Pontos_Flutuantes.git
cd Aritim-tica_de_Pontos_Flutuantes

# 2. Inicie o ModelSim no terminal e execute o projeto
vsim -do sim.do




