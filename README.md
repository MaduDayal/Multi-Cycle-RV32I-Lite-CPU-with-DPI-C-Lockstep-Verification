# Multi-Cycle RV32I-Lite CPU with DPI-C Lockstep Verification

**Author:** Madhavenshu Dayal

## Overview

This project implements and verifies a 32-bit, non-pipelined, multi-cycle CPU supporting an intentionally limited eight-instruction subset of the RISC-V RV32I base integer instruction set.

The project emphasizes both RTL design and processor-level verification. Completed instructions are observed through a retirement interface and checked instruction-by-instruction against an independent C++ architectural reference model connected through SystemVerilog DPI-C.

The verification environment also includes SystemVerilog Assertions, directed positive and negative tests, and retirement-level functional coverage.

> **Scope:** This is an educational RV32I subset implementation. It is not a full RV32I implementation, a pipelined processor, or a production-ready CPU.

## Supported Instructions

- `ADD`
- `SUB`
- `AND`
- `OR`
- `ADDI`
- `LW`
- `SW`
- `BEQ`

## Multi-Cycle Architecture

Only one instruction is active at a time. Instructions progress through the following controller states:

```text
FETCH -> DECODE -> EXECUTE -> [MEMORY] -> [WRITEBACK] -> FETCH
```

Typical execution paths are:

- Register and immediate arithmetic: `FETCH -> DECODE -> EXECUTE -> WRITEBACK`
- Load: `FETCH -> DECODE -> EXECUTE -> MEMORY -> WRITEBACK`
- Store: `FETCH -> DECODE -> EXECUTE -> MEMORY -> FETCH`
- Branch: `FETCH -> DECODE -> EXECUTE -> FETCH`
- Illegal or faulting operation: transition to `HALT`

The processor contains:

- 32-bit program counter
- 32 x 32-bit register file with x0 hardwired to zero
- 64 x 32-bit instruction memory
- 64 x 32-bit data memory
- ALU supporting addition, subtraction, AND, OR, and equality comparison
- Immediate generator for I-type, S-type, and B-type formats
- Instruction decoder
- Multi-cycle controller
- Retirement interface
- Illegal-instruction, address-alignment, and address-range error handling

## Retirement Interface

Every completed legal instruction produces one retirement event containing:

- Retired instruction PC
- Raw retired instruction
- Register-write indication, destination register, and value
- Memory-write indication, address, and data

Legal instructions retire exactly once. Illegal and faulting instructions enter `HALT` without retiring or creating unintended architectural side effects.

## Verification Architecture

```text
Program Builder
      |
Instruction Memory -> RV32I-Lite DUT
                         |
                  Retirement Monitor
                    /           \
           DPI-C Scoreboard   Functional Coverage
                    |
          C++ Reference Model

SystemVerilog Assertions observe reset, FSM, PC, branch,
register, memory, retirement, error, and HALT behavior.
```

### DPI-C Architectural Reference Model

The independent C++ model maintains its own:

- 32 architectural registers
- 64-word data memory
- Expected program counter
- Executed-instruction count

At every retirement event, the SystemVerilog scoreboard calls the model through DPI-C. The model independently decodes the retired instruction, calculates the expected architectural effects, updates its own state, and returns the expected register and memory results for comparison with the DUT.

This creates instruction-by-instruction retirement lockstep checking without reproducing the DUT's internal multi-cycle FSM in the reference model.

### SystemVerilog Assertions

The SVA checker verifies major temporal and safety requirements, including:

- Reset initialization and side-effect suppression
- Known and word-aligned program counter
- Legal controller states and required state transitions
- x0 remaining zero after attempted writes
- Known register-write information
- Arithmetic execution progressing to writeback
- Correct store retirement behavior
- Valid, misaligned, and out-of-range BEQ target behavior
- Illegal instructions entering `HALT`
- Misaligned and out-of-range memory accesses entering `HALT`
- `HALT` persistence and side-effect suppression
- Known retirement information

The default testbench directly instantiates the assertion modules defined in `sva/rv32i_assertions.sv`.

An optional `sva/rv32i_assertion_bind.sv` file is included as an alternative assertion-integration example. It is not used by the default simulation flow. The direct-instantiation and bind approaches should not be enabled simultaneously because doing so would create duplicate assertion instances.

### Functional Coverage

Retirement-level functional coverage includes:

- Individual bins for all eight supported instructions
- Lower and upper destination-register ranges
- Lower and upper data-memory address ranges
- Lower and upper retired-PC ranges
- Instruction and destination-register cross coverage

## Directed Test Plan

The completed test programs include:

1. ALU operations
2. Immediate and sign-extension cases
3. Store and load round trip
4. BEQ taken with a skipped instruction
5. BEQ not taken with sequential execution
6. x0 write suppression and illegal-instruction handling
7. Misaligned memory access
8. Mixed DPI-C lockstep program

All tests passed the retirement-level scoreboard and completed without unexpected assertion failures.

## Final Mixed-Program Result

The final mixed program exercised:

- All eight supported instructions
- Positive and negative immediates
- Register dependencies
- Lower and upper destination-register ranges
- Multiple aligned data-memory regions
- Store and subsequent load behavior
- Taken and not-taken branches
- Instructions skipped by taken branches
- Illegal termination without retirement

```text
ACTUAL Total Instructions: 29
Number of Instructions Passed: 29
Number of Instructions Failed: 0
REFERENCE Total Instructions: 29
FINAL RESULT: PASS
Functional Coverage: 85.00%
```

## AI-Assistance Disclosure

The final 29-retirement mixed instruction sequence was generated with AI assistance. It was subsequently integrated into the program builder, compiled, executed, debugged, and validated using the DPI-C reference model, SystemVerilog Assertions, the retirement scoreboard, and functional coverage.

## Repository Structure

```text
Multi-Cycle-RV32I-Lite-CPU/
├── dpi/
│   ├── rv32i_dpi_package.sv
│   └── rv32i_ref_model.cpp
├── rtl/
│   ├── data_memory.sv
│   ├── instruction_memory.sv
│   ├── rv32i_alu.sv
│   ├── rv32i_decoder.sv
│   ├── rv32i_imm_gen.sv
│   ├── rv32i_lite_core.sv
│   ├── rv32i_package.sv
│   └── rv32i_regfile.sv
├── sim/
│   ├── design.sv
│   └── testbench.sv
├── sva/
│   ├── rv32i_assertion_bind.sv
│   └── rv32i_assertions.sv
├── tb/
│   ├── instruction_generator_package.sv
│   ├── retire_monitor.sv
│   ├── retire_scoreboard.sv
│   ├── retire_transaction.sv
│   ├── riscvInf.sv
│   ├── rv32i_env.sv
│   ├── rv32i_functional_coverage.sv
│   └── rv32i_program_builder.sv
├── LICENSE
└── README.md
```

## Running with Synopsys VCS

Run the following commands from the `sim/` directory after confirming that the relative include paths in `design.sv` match the repository structure:

```bash
vcs -full64 -licqueue \
  -timescale=1ns/1ns \
  +vcs+flush+all \
  +warn=all \
  -sverilog \
  ../dpi/rv32i_ref_model.cpp \
  design.sv \
  testbench.sv

./simv +vcs+lic+wait
```

The simulator must support:

- SystemVerilog classes and parameterized mailboxes
- SystemVerilog concurrent assertions
- Functional coverage
- DPI-C and C++ compilation

## Key Learning Outcomes

- Designed a multi-cycle processor datapath and controller
- Implemented an eight-instruction RV32I subset
- Defined a retirement interface as a stable verification boundary
- Built an independent C++ architectural reference model
- Performed instruction-by-instruction DPI-C lockstep checking
- Created temporal SVA checks for control flow, side effects, and fault handling
- Developed retirement-level functional coverage
- Debugged a BEQ operand-selection defect through retirement-PC lockstep checking

## Limitations

The following are intentionally outside the project scope:

- Full RV32I compliance
- Pipelining, forwarding, and hazard handling
- Interrupts, traps, CSRs, and privilege modes
- Caches and branch prediction
- Multiply/divide, floating-point, atomics, and compressed instructions
- Operating-system or compiler-toolchain support
- Formal verification

## License

This project is released under the MIT License. See LICENSE for details.
