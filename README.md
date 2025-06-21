# Floating Point Arithmetic

📚 Available in: [English](README.md) | [Portuguese](README.pt-br.md)

**Author:** Rodrigo Machado Gonçalves - [@GncRodrigo](https://github.com/GncRodrigo)

SystemVerilog implementation of floating-point number operations, using a **custom IEEE 754 format**, including a main module and testbench for simulation.

---

## 💡 Custom IEEE 754

The IEEE 754 standard was adapted for this project according to the assignment guidelines, where each student had to use a unique format for mantissa and exponent. The calculation followed the formula:

> X = 8 (+/- ∑b mod 4)

- `∑b`: Sum of all digits of the student ID (in base 10).
- `mod 4`: Remainder of integer division by 4.
- The **+** or **−** sign is determined by the **check digit** of the student ID:
  - **+** if odd
  - **−** if even

### Application in my case:
- Student ID: 241079474  
- Sum of digits: 2 + 4 + 1 + 0 + 7 + 9 + 4 + 7 + 4 = **38**  
- 38 % 4 = **2**  
- Check digit: **9** → odd → negative sign  
- Final calculation: **8 - 2 = 6**

Therefore:
- **Exponent:** 6 bits  
- **Mantissa:** 31 - 6 = **25 bits**

---

## 🧠 Overview

This project implements a SystemVerilog module named `PontosFlutuantes`, which performs **addition and subtraction operations** between numbers represented in a **custom floating-point format**.  
A testbench (`tb_Pontos.sv`) is included to validate the implementation through simulation in ModelSim.

---

## 🧱 Technologies & Files

- **SystemVerilog**:
  - `PontosFlutuantes.sv`: Main module (FSM)
  - `tb_Pontos.sv`: Functional verification testbench
- **ModelSim Scripts**:
  - `sim.do`, `wave.do` (simulation and waveform visualization scripts)

---

## 🛠️ Development Details

- The system clock operates at **100 kHz**.
- The **reset** is **asynchronous and active-low**.
- The project uses a **finite state machine (FSM)** with 6 states:
  - `READ`, `EQUALIZING`, `OPERATION`, `POS_OPERATION`, `FINALIZE`, `CHECK`
- The inputs `op_A_in` and `op_B_in` are decomposed into sign, exponent, and mantissa using combinational logic.
- Several **test scenarios** were implemented in the testbench to ensure robust validation of the system.

---

## 🔢 Numeric Spectrum (Custom IEEE 754)

![image](https://github.com/user-attachments/assets/6b341bac-8a0b-420c-b44a-cf0f588973b9)


---

## 🌊 Waveform Results:

![image](https://github.com/user-attachments/assets/1326533a-4272-4b31-8cd4-b1e59011196b)

---

## 🚀 How to Compile and Simulate

**Step-by-step**:

```bash
# 1. Clone the repository
git clone https://github.com/GncRodrigo/Aritim-tica_de_Pontos_Flutuantes.git
cd Aritim-tica_de_Pontos_Flutuantes

# 2. Launch ModelSim and run the simulation
vsim -do sim.do
