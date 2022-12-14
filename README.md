# ECE 545 FALL 2022
The following repository contains homework or projects from F22 course. See the course website for further details : [https://people-ece.vse.gmu.edu/coursewebpages/ECE/ECE545/F22/](https://people-ece.vse.gmu.edu/coursewebpages/ECE/ECE545/F22/)

## Directory Structure
The repository contains three "modules." Each module will have the following structure:

```
|--- <module_name>
    +-- <cpp>
    +-- <docs>
    |   +-- PDF files
    |   +-- Block Diagrams
    +-- <src>
    |   +-- *.vhd
    +-- <tb>
    |   +-- *.vhd
    +-- <vsim>
    |   +-- *.sh
    |   +-- *.txt
    |   +-- *.do
    +-- <xilinx>
    |   +-- *.xpr
    |   +-- *.xdc
```

## Running Simulation (Modelsim compatible only)

Navigate to `*/vsim/` directory and run the following commands :

```
>> ./compile.sh
>> ./run_batch.sh
>> ./coverage.sh
>> ./clean.sh
```

## Contributions
Contributions are welcome. Feel free to open a pull request with changes.
