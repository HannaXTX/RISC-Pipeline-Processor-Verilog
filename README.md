# Pipelined-RISC32-Verilog

A complete implementation of a **5-stage pipelined RISC32 processor** in **Verilog**. This project was developed as part of the Computer Architecture course (ENCS4370) at Birzeit University. It supports a custom 32-bit ISA, data and control hazards, stalling, forwarding, and simulation-based verification using Icarus Verilog and GTKWave.

---

## 📌 Project Features

- Fully pipelined 32-bit RISC processor
- ISA with 15 instructions (arithmetic, logic, memory, and control flow)
- Hazard detection:
  - **Data hazards**
  - **Control hazards**
  - **Structural hazards**
- **Stalling** and **kill** mechanisms
- **Data forwarding** logic
- Modular design with separate pipeline stages
- Verified using multiple test programs and waveform analysis

---

## ⚙️ ISA Format

### 🧾 Instruction Format (32-bit)

| Field     | Opcode | Rd  | Rs  | Rt  | Imm       |
|-----------|--------|-----|-----|-----|------------|
| Size      | 6 bits | 4 bits | 4 bits | 4 bits | 14 bits |

- 32-bit word size
- Word-addressable memory
- R15 is PC, R14 is return address

---

## 🧠 Pipeline Stages

1. **Fetch (IF):** Fetch instruction from memory using PC
2. **Decode (ID):** Parse instruction, read registers, generate control signals
3. **Execute (EX):** Perform ALU operations or address calculations
4. **Memory (MEM):** Load or store data to memory
5. **Write-Back (WB):** Write result back to destination register

---

## 🧩 Datapath Components

- **Instruction Memory / Data Memory**
- **Program Counter & PC Control Unit**
- **ALU (Arithmetic Logic Unit)**
- **Register File** – 16 general-purpose 32-bit registers
- **Control Unit** – generates control signals from opcode
- **Pipeline Buffers** – IF/ID, ID/EX, EX/MEM, MEM/WB
- **Stall, Kill, and Forwarding Units** – resolve hazards and maintain pipeline correctness

---

## 🖼️ Datapath Diagram
![image](https://github.com/user-attachments/assets/fd43479d-2112-458d-b7e2-4a5aab939221)

- More Details in report
---

## 🧪 Simulation Tests

We used **Icarus Verilog** for simulation and **GTKWave** to view waveforms.

### ✅ Included Test Programs:
1. **Integer Division (Loop & Branching)**
2. **General Arithmetic/Logic + BZ + Stalls**
3. **LDW & SDW Handling with Consecutive Memory Access**

All test results are validated by waveform outputs and register/memory snapshots.

---

## 🧰 Setup & Tools

### 🛠 Required Software

| Tool            | Purpose                        | Link                                             |
|-----------------|--------------------------------|--------------------------------------------------|
| Icarus Verilog  | Compilation and Simulation     | http://iverilog.icarus.com/                      |

### 💡 VS Code Extensions (Recommended)
- **Code Runner** – run Verilog scripts directly
- **Verilog-HDL/SystemVerilog** – syntax highlighting

---

## ▶️ Compilation & Execution

### 🔹 Manual Run

```bash
# Compile all .v files and link opcodes.v
iverilog -o sim.vvp opcodes.v *.v

# Run the simulation
vvp sim.vvp
```
### 🔹 Waveform Viewing
Ensure your testbench includes:
```bash
$dumpfile("dump.vcd");
$dumpvars;
```
Then view Using:
```bash
gtkwave dump.vcd
```

### 🔹 VS Code Integration (Code Runner)

To enable one-click simulation in Visual Studio Code using **Code Runner**, add the following to your `settings.json`:

```json
"code-runner.executorMapByFileExtension": {
  ".v": "iverilog -o sim.vvp opcodes.v *.v && vvp sim.vvp"
}
