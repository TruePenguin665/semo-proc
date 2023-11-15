
user/init:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
extern void syscall(int,...);

int main()
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
    syscall(1);
   8:	4505                	li	a0,1
   a:	00000097          	auipc	ra,0x0
   e:	024080e7          	jalr	36(ra) # 2e <syscall>
    syscall(2,3,4);
  12:	4611                	li	a2,4
  14:	458d                	li	a1,3
  16:	4509                	li	a0,2
  18:	00000097          	auipc	ra,0x0
  1c:	016080e7          	jalr	22(ra) # 2e <syscall>
    syscall(42);
  20:	02a00513          	li	a0,42
  24:	00000097          	auipc	ra,0x0
  28:	00a080e7          	jalr	10(ra) # 2e <syscall>
    while(1);
  2c:	a001                	j	2c <main+0x2c>

000000000000002e <syscall>:
  2e:	00000073          	ecall
  32:	8082                	ret
