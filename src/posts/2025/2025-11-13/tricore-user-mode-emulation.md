---
layout: post
title:  "User-mode emulation for TriCore with TSIM and the GNU toolchain"
date:   2025-11-13 00:00:00 +0100
categories: tricore
---



QEMU User-mode Emulation is a practical solution for testing algorithms
directly without having to set up a microcontroller system and boot it every
time you test. Unfortunately, [QEMU](https://www.qemu.org/) only supports full
system emulation of Aurix microcontrollers with TriCore instruction set.
User-mode emulation is not available for TriCore.

Since Infineon's Tricore instruction set simulator
[TSIM](https://softwaretools.infineon.com/tools/com.ifx.tb.tool.tsimtricoreinstructionsetsimulator)
has a virtual I/O feature that can be used for user-mode emulation.



Compile for Tricore and TSIM
----------------------------

Download and install the [Tricore GNU toolchain](https://nomore201.github.io/tricore-gcc-toolchain/)
(including GCC, binutils, GDB and newlib) with

    git clone --recursive https://github.com/NoMore201/tricore-gcc-toolchain
    cd tricore-gcc-toolchain
    mkdir build
    cd build
    ../configure --prefix=~/.local/share/tricore-gcc
    make -j$(nproc) stamps/build-gcc-stage

or directly use the less experimental upstream repository from
[EEESlab](https://github.com/EEESlab)

    git clone --recursive git@github.com:EEESlab/tricore-gcc-toolchain-11.3.0.git
    ./build-toolchain --all

Compile `foo.c` to `foo.elf` with

    tricore-elf-gcc -mcpu=tc39xx -g -nostartfiles -T tsim.ld tsim_startup.c \
        -o foo.elf" foo.c

Two additional files cannot be avoided: the internal linker script of gcc does
not define memory regions and the internal startup code does access an invalid
memory mapped register which causes an exception.



Minimal Linker Script
---------------------

The linker script starts with the declaration of the target architecture:

    OUTPUT_FORMAT("elf32-tricore")
    OUTPUT_ARCH(tricore)

TSIM comes with config scripts for the Aurix TC39xx family of microcontrollers.
We use two memory regions: 240 KiByte data scratchpad RAM at 0x70000000 and
4MiByte program flash ROM at 0x80000000:

    MEMORY {
        data_scratchpad_ram (w!xp): org = 0x70000000, len = 240k
        program_flash_rom   (rx!p): org = 0x80000000, len = 4M
    }

Most sections are automatically assigned by the linker. Only the `.heap` section
must be defined, because newlib expects the symbols `__HEAP` and `__HEAP_END` to
point at the start and the end of the heap memory area.

    HEAP_SIZE  = 64k;
    SECTIONS {
        .heap  : FLAGS(aw) {
            . = ALIGN(4);
            __HEAP = .;
            . += HEAP_SIZE;
            __HEAP_END = .;
        } > data_scratchpad_ram
    }

Complete file: [tsim.ld](https://github.com/bobbl/sammelsurium/blob/master/tsim/tsim.ld)



Minimal Startup Code
--------------------


Program entry is at the `_start` function. At this point the stack is not
initialised yet. Therefore the function is of pure assembly and only sets the
stack pointer a10 to 0x7003A000 and jumps to the C code in `__startup`.

    void _start( void ) __attribute__((used,noinline)) ;
    void _start(void)
    {
        asm("movh.a   %a10, hi:(0x7003A000)           \n\t" \
            "lea      %a10, [%a10]lo:(0x7003A000)     \n\t" \
            "dsync                                    \n\t" \
            "movh.a   %a15,  hi:(__startup)           \n\t" \
            "lea      %a15, [%a15]lo:(__startup)      \n\t" \
            "ji %a15");
    }

Main task of `__startup` is to create the singly linked list of CSAs. Each CSA
is 64 bytes long and the first 4 byte word points to the next entry. Core
register FCX points to the first free entry in the CSA list. LCX points to one
of the last entries, but not the last. When FCX reaches LCX a trap is taken and
there should be some CSA remaining for the execution of the trap. The pointers
in FCX, LCX and the next field are not direct addresses, but compressed ones
that can only address the first 4 MiByte of each segment.

    void __startup() __attribute__((used,noinline,noreturn)) ;
    void __startup()
    {
        /* Setup the context save area linked list. */
        unsigned int csa_addr  = 0x7003A000;
        unsigned int csa_end   = 0x7003C000;
        unsigned int next_pcxi = ((csa_addr & 0xF0000000) >> 12) | /* segment */
                                 ((csa_addr & 0X003FFFC0) >> 6);   /* offset */

        _mtcr(0xFE38/*FCX*/, next_pcxi); /* store 1st PCXI value in FCX */

        while (csa_addr < csa_end) {
            next_pcxi++;
            *(unsigned int *)csa_addr = next_pcxi;
            csa_addr += 64;
        }
        *(unsigned int *)(csa_end - 64) = 0; /* mark end of CSA list */

        _mtcr(0xFE3C/*LCX*/, next_pcxi - 3);
        _dsync();

        exit(main());
    }

Complete file: [tsim_startup.c](https://github.com/bobbl/sammelsurium/blob/master/tsim/tsim_startup.c)



Run with TSIM
-------------

After registration, TSIM can be downloaded from the 
[Infineon website](https://softwaretools.infineon.com/tools/com.ifx.tb.tool.tsimtricoreinstructionsetsimulator).
Install with

    sudo apt install ./tsim_1.18.196_linux_x64.deb

TSIM will be installed to a fixed path under `/opt/Tools/...`. 
Emulate `foo.elf` with

    tsim_path=/opt/Tools/TSIM-Tricore-instruction-set-simulator/1.18.196
    ${tsim_path}/bin/tsim16p_e -e -h -s -H -z \
        -MConfig ${tsim_path}/config/tc162/tc39xx/MConfig \
        -OConfig ${tsim_path}/config/tc162/tc39xx/OConfig \
        -o foo.elf -trace-instr-file foo.tsim



Appendix: TSIM Virtual I/O Interface
------------------------------------

A system call to the virtual I/O is done by the `debug` instruction. The
parameters are passed in registers according to the Tricore calling convention.
The syscall number is passed in register `D12`. After the syscall, `D11` is set
to the return value and `D12` to `errno` if an error occured. The following
syscall numbers are supported:

| no | function                                         |
| --:| ------------------------------------------------ |
|  1 | `int open(char *filename, int flags, int mode)`  |
|  2 | `close(int fd)`                                  |
|  3 | `int lseek(int fd, int offset, int whence)`      |
|  4 | `int read(int fd, void *buf, int len)`           |
|  5 | `int write(int fd, void *buf, int len)`          |
|  6 | `int creat(char *filename, int mode)`            |
|  7 | `int unlink(char *filename)`                     |
|  8 | `int stat(char *filename, void *statbuf)`        |
|  9 | `int fstat(int fd, void *statbuf)`               |
| 10 | *gettimeofday()* ?                               |
| 11 | `int ftruncate(int fd, int len)`                 |
| 13 | `int rename(char *oldname, char *newname)`       |


