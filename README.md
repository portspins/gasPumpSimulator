# gaspumpsimulator
ARM program to simulate the functionality of a gas pump.
Use these command to assemble, link, run and debug this program:
    as -o GPhise.o GPhise.s
    gcc -o GPhise GPhise.o
    ./GPhise ;echo $?
    gdb --args ./GPhise
