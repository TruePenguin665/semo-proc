
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00004117          	auipc	sp,0x4
    80000004:	cc013103          	ld	sp,-832(sp) # 80003cc0 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	006000ef          	jal	ra,8000001c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <start>:


// entry.S jumps here in machine mode on stack0.
void
start()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16

static inline uint64
r_mstatus()
{
  uint64 x;
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000022:	300027f3          	csrr	a5,mstatus
  // set M Previous Privilege mode to Supervisor, for mret.
  unsigned long x = r_mstatus();
  x &= ~MSTATUS_MPP_MASK;
    80000026:	7779                	lui	a4,0xffffe
    80000028:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffb4e27>
    8000002c:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000002e:	6705                	lui	a4,0x1
    80000030:	80070713          	addi	a4,a4,-2048 # 800 <_binary_user_init_size-0x1a8>
    80000034:	8fd9                	or	a5,a5,a4
}

static inline void 
w_mstatus(uint64 x)
{
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000036:	30079073          	csrw	mstatus,a5
// instruction address to which a return from
// exception will go.
static inline void 
w_mepc(uint64 x)
{
  asm volatile("csrw mepc, %0" : : "r" (x));
    8000003a:	00001797          	auipc	a5,0x1
    8000003e:	c9e78793          	addi	a5,a5,-866 # 80000cd8 <main>
    80000042:	34179073          	csrw	mepc,a5
// supervisor address translation and protection;
// holds the address of the page table.
static inline void 
w_satp(uint64 x)
{
  asm volatile("csrw satp, %0" : : "r" (x));
    80000046:	4781                	li	a5,0
    80000048:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    8000004c:	67c1                	lui	a5,0x10
    8000004e:	17fd                	addi	a5,a5,-1
    80000050:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    80000054:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    80000058:	104027f3          	csrr	a5,sie
  w_satp(0);

  // delegate all interrupts and exceptions to supervisor mode.
  w_medeleg(0xffff);
  w_mideleg(0xffff);
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    8000005c:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80000060:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    80000064:	57fd                	li	a5,-1
    80000066:	83a9                	srli	a5,a5,0xa
    80000068:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    8000006c:	47bd                	li	a5,15
    8000006e:	3a079073          	csrw	pmpcfg0,a5
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000072:	f14027f3          	csrr	a5,mhartid
  w_pmpaddr0(0x3fffffffffffffull);
  w_pmpcfg0(0xf);

  // keep each CPU's hartid in its tp register, for cpuid().
  int id = r_mhartid();
  w_tp(id);
    80000076:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    80000078:	823e                	mv	tp,a5

  // switch to supervisor mode and jump to main().
  asm volatile("mret");
    8000007a:	30200073          	mret
}
    8000007e:	6422                	ld	s0,8(sp)
    80000080:	0141                	addi	sp,sp,16
    80000082:	8082                	ret

0000000080000084 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80000084:	7179                	addi	sp,sp,-48
    80000086:	f406                	sd	ra,40(sp)
    80000088:	f022                	sd	s0,32(sp)
    8000008a:	ec26                	sd	s1,24(sp)
    8000008c:	e84a                	sd	s2,16(sp)
    8000008e:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    80000090:	c219                	beqz	a2,80000096 <printint+0x12>
    80000092:	08054663          	bltz	a0,8000011e <printint+0x9a>
    x = -xx;
  else
    x = xx;
    80000096:	2501                	sext.w	a0,a0
    80000098:	4881                	li	a7,0
    8000009a:	fd040693          	addi	a3,s0,-48

  i = 0;
    8000009e:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800000a0:	2581                	sext.w	a1,a1
    800000a2:	00003617          	auipc	a2,0x3
    800000a6:	f9e60613          	addi	a2,a2,-98 # 80003040 <digits>
    800000aa:	883a                	mv	a6,a4
    800000ac:	2705                	addiw	a4,a4,1
    800000ae:	02b577bb          	remuw	a5,a0,a1
    800000b2:	1782                	slli	a5,a5,0x20
    800000b4:	9381                	srli	a5,a5,0x20
    800000b6:	97b2                	add	a5,a5,a2
    800000b8:	0007c783          	lbu	a5,0(a5) # 10000 <_binary_user_init_size+0xf658>
    800000bc:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800000c0:	0005079b          	sext.w	a5,a0
    800000c4:	02b5553b          	divuw	a0,a0,a1
    800000c8:	0685                	addi	a3,a3,1
    800000ca:	feb7f0e3          	bgeu	a5,a1,800000aa <printint+0x26>

  if(sign)
    800000ce:	00088b63          	beqz	a7,800000e4 <printint+0x60>
    buf[i++] = '-';
    800000d2:	fe040793          	addi	a5,s0,-32
    800000d6:	973e                	add	a4,a4,a5
    800000d8:	02d00793          	li	a5,45
    800000dc:	fef70823          	sb	a5,-16(a4)
    800000e0:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800000e4:	02e05763          	blez	a4,80000112 <printint+0x8e>
    800000e8:	fd040793          	addi	a5,s0,-48
    800000ec:	00e784b3          	add	s1,a5,a4
    800000f0:	fff78913          	addi	s2,a5,-1
    800000f4:	993a                	add	s2,s2,a4
    800000f6:	377d                	addiw	a4,a4,-1
    800000f8:	1702                	slli	a4,a4,0x20
    800000fa:	9301                	srli	a4,a4,0x20
    800000fc:	40e90933          	sub	s2,s2,a4
    uartputc(buf[i]);
    80000100:	fff4c503          	lbu	a0,-1(s1)
    80000104:	00001097          	auipc	ra,0x1
    80000108:	d24080e7          	jalr	-732(ra) # 80000e28 <uartputc>
  while(--i >= 0)
    8000010c:	14fd                	addi	s1,s1,-1
    8000010e:	ff2499e3          	bne	s1,s2,80000100 <printint+0x7c>
}
    80000112:	70a2                	ld	ra,40(sp)
    80000114:	7402                	ld	s0,32(sp)
    80000116:	64e2                	ld	s1,24(sp)
    80000118:	6942                	ld	s2,16(sp)
    8000011a:	6145                	addi	sp,sp,48
    8000011c:	8082                	ret
    x = -xx;
    8000011e:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000122:	4885                	li	a7,1
    x = -xx;
    80000124:	bf9d                	j	8000009a <printint+0x16>

0000000080000126 <panic>:
  }
}

void
panic(char *s)
{
    80000126:	1101                	addi	sp,sp,-32
    80000128:	ec06                	sd	ra,24(sp)
    8000012a:	e822                	sd	s0,16(sp)
    8000012c:	e426                	sd	s1,8(sp)
    8000012e:	1000                	addi	s0,sp,32
    80000130:	84aa                	mv	s1,a0
  printf("panic: ");
    80000132:	00003517          	auipc	a0,0x3
    80000136:	ece50513          	addi	a0,a0,-306 # 80003000 <etext>
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	02e080e7          	jalr	46(ra) # 80000168 <printf>
  printf(s);
    80000142:	8526                	mv	a0,s1
    80000144:	00000097          	auipc	ra,0x0
    80000148:	024080e7          	jalr	36(ra) # 80000168 <printf>
  printf("\n");
    8000014c:	00003517          	auipc	a0,0x3
    80000150:	ebc50513          	addi	a0,a0,-324 # 80003008 <etext+0x8>
    80000154:	00000097          	auipc	ra,0x0
    80000158:	014080e7          	jalr	20(ra) # 80000168 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000015c:	4785                	li	a5,1
    8000015e:	00004717          	auipc	a4,0x4
    80000162:	b8f72123          	sw	a5,-1150(a4) # 80003ce0 <panicked>
  for(;;)
    80000166:	a001                	j	80000166 <panic+0x40>

0000000080000168 <printf>:
{
    80000168:	7131                	addi	sp,sp,-192
    8000016a:	fc86                	sd	ra,120(sp)
    8000016c:	f8a2                	sd	s0,112(sp)
    8000016e:	f4a6                	sd	s1,104(sp)
    80000170:	f0ca                	sd	s2,96(sp)
    80000172:	ecce                	sd	s3,88(sp)
    80000174:	e8d2                	sd	s4,80(sp)
    80000176:	e4d6                	sd	s5,72(sp)
    80000178:	e0da                	sd	s6,64(sp)
    8000017a:	fc5e                	sd	s7,56(sp)
    8000017c:	f862                	sd	s8,48(sp)
    8000017e:	f466                	sd	s9,40(sp)
    80000180:	f06a                	sd	s10,32(sp)
    80000182:	ec6e                	sd	s11,24(sp)
    80000184:	0100                	addi	s0,sp,128
    80000186:	e40c                	sd	a1,8(s0)
    80000188:	e810                	sd	a2,16(s0)
    8000018a:	ec14                	sd	a3,24(s0)
    8000018c:	f018                	sd	a4,32(s0)
    8000018e:	f41c                	sd	a5,40(s0)
    80000190:	03043823          	sd	a6,48(s0)
    80000194:	03143c23          	sd	a7,56(s0)
  if (fmt == 0)
    80000198:	c91d                	beqz	a0,800001ce <printf+0x66>
    8000019a:	8a2a                	mv	s4,a0
  va_start(ap, fmt);
    8000019c:	00840793          	addi	a5,s0,8
    800001a0:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800001a4:	00054503          	lbu	a0,0(a0)
    800001a8:	14050763          	beqz	a0,800002f6 <printf+0x18e>
    800001ac:	4981                	li	s3,0
    if(c != '%'){
    800001ae:	02500a93          	li	s5,37
    switch(c){
    800001b2:	07000b93          	li	s7,112
  uartputc('x');
    800001b6:	4d41                	li	s10,16
    uartputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800001b8:	00003b17          	auipc	s6,0x3
    800001bc:	e88b0b13          	addi	s6,s6,-376 # 80003040 <digits>
    switch(c){
    800001c0:	07300c93          	li	s9,115
      for(; *s; s++)
    800001c4:	02800d93          	li	s11,40
    switch(c){
    800001c8:	06400c13          	li	s8,100
    800001cc:	a025                	j	800001f4 <printf+0x8c>
    panic("null fmt");
    800001ce:	00003517          	auipc	a0,0x3
    800001d2:	e4a50513          	addi	a0,a0,-438 # 80003018 <etext+0x18>
    800001d6:	00000097          	auipc	ra,0x0
    800001da:	f50080e7          	jalr	-176(ra) # 80000126 <panic>
      uartputc_sync(c);
    800001de:	00001097          	auipc	ra,0x1
    800001e2:	bb8080e7          	jalr	-1096(ra) # 80000d96 <uartputc_sync>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800001e6:	2985                	addiw	s3,s3,1
    800001e8:	013a07b3          	add	a5,s4,s3
    800001ec:	0007c503          	lbu	a0,0(a5)
    800001f0:	10050363          	beqz	a0,800002f6 <printf+0x18e>
    if(c != '%'){
    800001f4:	ff5515e3          	bne	a0,s5,800001de <printf+0x76>
    c = fmt[++i] & 0xff;
    800001f8:	2985                	addiw	s3,s3,1
    800001fa:	013a07b3          	add	a5,s4,s3
    800001fe:	0007c783          	lbu	a5,0(a5)
    80000202:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000206:	cbe5                	beqz	a5,800002f6 <printf+0x18e>
    switch(c){
    80000208:	05778a63          	beq	a5,s7,8000025c <printf+0xf4>
    8000020c:	02fbf663          	bgeu	s7,a5,80000238 <printf+0xd0>
    80000210:	09978863          	beq	a5,s9,800002a0 <printf+0x138>
    80000214:	07800713          	li	a4,120
    80000218:	0ce79463          	bne	a5,a4,800002e0 <printf+0x178>
      printint(va_arg(ap, int), 16, 1);
    8000021c:	f8843783          	ld	a5,-120(s0)
    80000220:	00878713          	addi	a4,a5,8
    80000224:	f8e43423          	sd	a4,-120(s0)
    80000228:	4605                	li	a2,1
    8000022a:	85ea                	mv	a1,s10
    8000022c:	4388                	lw	a0,0(a5)
    8000022e:	00000097          	auipc	ra,0x0
    80000232:	e56080e7          	jalr	-426(ra) # 80000084 <printint>
      break;
    80000236:	bf45                	j	800001e6 <printf+0x7e>
    switch(c){
    80000238:	09578e63          	beq	a5,s5,800002d4 <printf+0x16c>
    8000023c:	0b879263          	bne	a5,s8,800002e0 <printf+0x178>
      printint(va_arg(ap, int), 10, 1);
    80000240:	f8843783          	ld	a5,-120(s0)
    80000244:	00878713          	addi	a4,a5,8
    80000248:	f8e43423          	sd	a4,-120(s0)
    8000024c:	4605                	li	a2,1
    8000024e:	45a9                	li	a1,10
    80000250:	4388                	lw	a0,0(a5)
    80000252:	00000097          	auipc	ra,0x0
    80000256:	e32080e7          	jalr	-462(ra) # 80000084 <printint>
      break;
    8000025a:	b771                	j	800001e6 <printf+0x7e>
      printptr(va_arg(ap, uint64));
    8000025c:	f8843783          	ld	a5,-120(s0)
    80000260:	00878713          	addi	a4,a5,8
    80000264:	f8e43423          	sd	a4,-120(s0)
    80000268:	0007b903          	ld	s2,0(a5)
  uartputc('0');
    8000026c:	03000513          	li	a0,48
    80000270:	00001097          	auipc	ra,0x1
    80000274:	bb8080e7          	jalr	-1096(ra) # 80000e28 <uartputc>
  uartputc('x');
    80000278:	07800513          	li	a0,120
    8000027c:	00001097          	auipc	ra,0x1
    80000280:	bac080e7          	jalr	-1108(ra) # 80000e28 <uartputc>
    80000284:	84ea                	mv	s1,s10
    uartputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000286:	03c95793          	srli	a5,s2,0x3c
    8000028a:	97da                	add	a5,a5,s6
    8000028c:	0007c503          	lbu	a0,0(a5)
    80000290:	00001097          	auipc	ra,0x1
    80000294:	b98080e7          	jalr	-1128(ra) # 80000e28 <uartputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80000298:	0912                	slli	s2,s2,0x4
    8000029a:	34fd                	addiw	s1,s1,-1
    8000029c:	f4ed                	bnez	s1,80000286 <printf+0x11e>
    8000029e:	b7a1                	j	800001e6 <printf+0x7e>
      if((s = va_arg(ap, char*)) == 0)
    800002a0:	f8843783          	ld	a5,-120(s0)
    800002a4:	00878713          	addi	a4,a5,8
    800002a8:	f8e43423          	sd	a4,-120(s0)
    800002ac:	6384                	ld	s1,0(a5)
    800002ae:	cc89                	beqz	s1,800002c8 <printf+0x160>
      for(; *s; s++)
    800002b0:	0004c503          	lbu	a0,0(s1)
    800002b4:	d90d                	beqz	a0,800001e6 <printf+0x7e>
        uartputc_sync(*s);
    800002b6:	00001097          	auipc	ra,0x1
    800002ba:	ae0080e7          	jalr	-1312(ra) # 80000d96 <uartputc_sync>
      for(; *s; s++)
    800002be:	0485                	addi	s1,s1,1
    800002c0:	0004c503          	lbu	a0,0(s1)
    800002c4:	f96d                	bnez	a0,800002b6 <printf+0x14e>
    800002c6:	b705                	j	800001e6 <printf+0x7e>
        s = "(null)";
    800002c8:	00003497          	auipc	s1,0x3
    800002cc:	d4848493          	addi	s1,s1,-696 # 80003010 <etext+0x10>
      for(; *s; s++)
    800002d0:	856e                	mv	a0,s11
    800002d2:	b7d5                	j	800002b6 <printf+0x14e>
      uartputc_sync('%');
    800002d4:	8556                	mv	a0,s5
    800002d6:	00001097          	auipc	ra,0x1
    800002da:	ac0080e7          	jalr	-1344(ra) # 80000d96 <uartputc_sync>
      break;
    800002de:	b721                	j	800001e6 <printf+0x7e>
      uartputc('%');
    800002e0:	8556                	mv	a0,s5
    800002e2:	00001097          	auipc	ra,0x1
    800002e6:	b46080e7          	jalr	-1210(ra) # 80000e28 <uartputc>
      uartputc(c);
    800002ea:	8526                	mv	a0,s1
    800002ec:	00001097          	auipc	ra,0x1
    800002f0:	b3c080e7          	jalr	-1220(ra) # 80000e28 <uartputc>
      break;
    800002f4:	bdcd                	j	800001e6 <printf+0x7e>
}
    800002f6:	70e6                	ld	ra,120(sp)
    800002f8:	7446                	ld	s0,112(sp)
    800002fa:	74a6                	ld	s1,104(sp)
    800002fc:	7906                	ld	s2,96(sp)
    800002fe:	69e6                	ld	s3,88(sp)
    80000300:	6a46                	ld	s4,80(sp)
    80000302:	6aa6                	ld	s5,72(sp)
    80000304:	6b06                	ld	s6,64(sp)
    80000306:	7be2                	ld	s7,56(sp)
    80000308:	7c42                	ld	s8,48(sp)
    8000030a:	7ca2                	ld	s9,40(sp)
    8000030c:	7d02                	ld	s10,32(sp)
    8000030e:	6de2                	ld	s11,24(sp)
    80000310:	6129                	addi	sp,sp,192
    80000312:	8082                	ret

0000000080000314 <print_pass>:


// handy debug function for unit tests
void
print_pass(int passed)
{
    80000314:	1141                	addi	sp,sp,-16
    80000316:	e406                	sd	ra,8(sp)
    80000318:	e022                	sd	s0,0(sp)
    8000031a:	0800                	addi	s0,sp,16
    printf("%s\n", passed ? "PASSED" : "FAILED");
    8000031c:	00003597          	auipc	a1,0x3
    80000320:	d0c58593          	addi	a1,a1,-756 # 80003028 <etext+0x28>
    80000324:	e509                	bnez	a0,8000032e <print_pass+0x1a>
    80000326:	00003597          	auipc	a1,0x3
    8000032a:	d0a58593          	addi	a1,a1,-758 # 80003030 <etext+0x30>
    8000032e:	00003517          	auipc	a0,0x3
    80000332:	d0a50513          	addi	a0,a0,-758 # 80003038 <etext+0x38>
    80000336:	00000097          	auipc	ra,0x0
    8000033a:	e32080e7          	jalr	-462(ra) # 80000168 <printf>
}
    8000033e:	60a2                	ld	ra,8(sp)
    80000340:	6402                	ld	s0,0(sp)
    80000342:	0141                	addi	sp,sp,16
    80000344:	8082                	ret

0000000080000346 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000346:	1141                	addi	sp,sp,-16
    80000348:	e422                	sd	s0,8(sp)
    8000034a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    8000034c:	ca19                	beqz	a2,80000362 <memset+0x1c>
    8000034e:	87aa                	mv	a5,a0
    80000350:	1602                	slli	a2,a2,0x20
    80000352:	9201                	srli	a2,a2,0x20
    80000354:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000358:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    8000035c:	0785                	addi	a5,a5,1
    8000035e:	fee79de3          	bne	a5,a4,80000358 <memset+0x12>
  }
  return dst;
}
    80000362:	6422                	ld	s0,8(sp)
    80000364:	0141                	addi	sp,sp,16
    80000366:	8082                	ret

0000000080000368 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000368:	1141                	addi	sp,sp,-16
    8000036a:	e422                	sd	s0,8(sp)
    8000036c:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    8000036e:	ca05                	beqz	a2,8000039e <memcmp+0x36>
    80000370:	fff6069b          	addiw	a3,a2,-1
    80000374:	1682                	slli	a3,a3,0x20
    80000376:	9281                	srli	a3,a3,0x20
    80000378:	0685                	addi	a3,a3,1
    8000037a:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    8000037c:	00054783          	lbu	a5,0(a0)
    80000380:	0005c703          	lbu	a4,0(a1)
    80000384:	00e79863          	bne	a5,a4,80000394 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000388:	0505                	addi	a0,a0,1
    8000038a:	0585                	addi	a1,a1,1
  while(n-- > 0){
    8000038c:	fed518e3          	bne	a0,a3,8000037c <memcmp+0x14>
  }

  return 0;
    80000390:	4501                	li	a0,0
    80000392:	a019                	j	80000398 <memcmp+0x30>
      return *s1 - *s2;
    80000394:	40e7853b          	subw	a0,a5,a4
}
    80000398:	6422                	ld	s0,8(sp)
    8000039a:	0141                	addi	sp,sp,16
    8000039c:	8082                	ret
  return 0;
    8000039e:	4501                	li	a0,0
    800003a0:	bfe5                	j	80000398 <memcmp+0x30>

00000000800003a2 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    800003a2:	1141                	addi	sp,sp,-16
    800003a4:	e422                	sd	s0,8(sp)
    800003a6:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    800003a8:	02a5e563          	bltu	a1,a0,800003d2 <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    800003ac:	fff6069b          	addiw	a3,a2,-1
    800003b0:	ce11                	beqz	a2,800003cc <memmove+0x2a>
    800003b2:	1682                	slli	a3,a3,0x20
    800003b4:	9281                	srli	a3,a3,0x20
    800003b6:	0685                	addi	a3,a3,1
    800003b8:	96ae                	add	a3,a3,a1
    800003ba:	87aa                	mv	a5,a0
      *d++ = *s++;
    800003bc:	0585                	addi	a1,a1,1
    800003be:	0785                	addi	a5,a5,1
    800003c0:	fff5c703          	lbu	a4,-1(a1)
    800003c4:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    800003c8:	fed59ae3          	bne	a1,a3,800003bc <memmove+0x1a>

  return dst;
}
    800003cc:	6422                	ld	s0,8(sp)
    800003ce:	0141                	addi	sp,sp,16
    800003d0:	8082                	ret
  if(s < d && s + n > d){
    800003d2:	02061713          	slli	a4,a2,0x20
    800003d6:	9301                	srli	a4,a4,0x20
    800003d8:	00e587b3          	add	a5,a1,a4
    800003dc:	fcf578e3          	bgeu	a0,a5,800003ac <memmove+0xa>
    d += n;
    800003e0:	972a                	add	a4,a4,a0
    while(n-- > 0)
    800003e2:	fff6069b          	addiw	a3,a2,-1
    800003e6:	d27d                	beqz	a2,800003cc <memmove+0x2a>
    800003e8:	02069613          	slli	a2,a3,0x20
    800003ec:	9201                	srli	a2,a2,0x20
    800003ee:	fff64613          	not	a2,a2
    800003f2:	963e                	add	a2,a2,a5
      *--d = *--s;
    800003f4:	17fd                	addi	a5,a5,-1
    800003f6:	177d                	addi	a4,a4,-1
    800003f8:	0007c683          	lbu	a3,0(a5)
    800003fc:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000400:	fef61ae3          	bne	a2,a5,800003f4 <memmove+0x52>
    80000404:	b7e1                	j	800003cc <memmove+0x2a>

0000000080000406 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000406:	1141                	addi	sp,sp,-16
    80000408:	e406                	sd	ra,8(sp)
    8000040a:	e022                	sd	s0,0(sp)
    8000040c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    8000040e:	00000097          	auipc	ra,0x0
    80000412:	f94080e7          	jalr	-108(ra) # 800003a2 <memmove>
}
    80000416:	60a2                	ld	ra,8(sp)
    80000418:	6402                	ld	s0,0(sp)
    8000041a:	0141                	addi	sp,sp,16
    8000041c:	8082                	ret

000000008000041e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    8000041e:	1141                	addi	sp,sp,-16
    80000420:	e422                	sd	s0,8(sp)
    80000422:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000424:	ce11                	beqz	a2,80000440 <strncmp+0x22>
    80000426:	00054783          	lbu	a5,0(a0)
    8000042a:	cf89                	beqz	a5,80000444 <strncmp+0x26>
    8000042c:	0005c703          	lbu	a4,0(a1)
    80000430:	00f71a63          	bne	a4,a5,80000444 <strncmp+0x26>
    n--, p++, q++;
    80000434:	367d                	addiw	a2,a2,-1
    80000436:	0505                	addi	a0,a0,1
    80000438:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    8000043a:	f675                	bnez	a2,80000426 <strncmp+0x8>
  if(n == 0)
    return 0;
    8000043c:	4501                	li	a0,0
    8000043e:	a809                	j	80000450 <strncmp+0x32>
    80000440:	4501                	li	a0,0
    80000442:	a039                	j	80000450 <strncmp+0x32>
  if(n == 0)
    80000444:	ca09                	beqz	a2,80000456 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000446:	00054503          	lbu	a0,0(a0)
    8000044a:	0005c783          	lbu	a5,0(a1)
    8000044e:	9d1d                	subw	a0,a0,a5
}
    80000450:	6422                	ld	s0,8(sp)
    80000452:	0141                	addi	sp,sp,16
    80000454:	8082                	ret
    return 0;
    80000456:	4501                	li	a0,0
    80000458:	bfe5                	j	80000450 <strncmp+0x32>

000000008000045a <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    8000045a:	1141                	addi	sp,sp,-16
    8000045c:	e422                	sd	s0,8(sp)
    8000045e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000460:	872a                	mv	a4,a0
    80000462:	8832                	mv	a6,a2
    80000464:	367d                	addiw	a2,a2,-1
    80000466:	01005963          	blez	a6,80000478 <strncpy+0x1e>
    8000046a:	0705                	addi	a4,a4,1
    8000046c:	0005c783          	lbu	a5,0(a1)
    80000470:	fef70fa3          	sb	a5,-1(a4)
    80000474:	0585                	addi	a1,a1,1
    80000476:	f7f5                	bnez	a5,80000462 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000478:	86ba                	mv	a3,a4
    8000047a:	00c05c63          	blez	a2,80000492 <strncpy+0x38>
    *s++ = 0;
    8000047e:	0685                	addi	a3,a3,1
    80000480:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000484:	fff6c793          	not	a5,a3
    80000488:	9fb9                	addw	a5,a5,a4
    8000048a:	010787bb          	addw	a5,a5,a6
    8000048e:	fef048e3          	bgtz	a5,8000047e <strncpy+0x24>
  return os;
}
    80000492:	6422                	ld	s0,8(sp)
    80000494:	0141                	addi	sp,sp,16
    80000496:	8082                	ret

0000000080000498 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000498:	1141                	addi	sp,sp,-16
    8000049a:	e422                	sd	s0,8(sp)
    8000049c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    8000049e:	02c05363          	blez	a2,800004c4 <safestrcpy+0x2c>
    800004a2:	fff6069b          	addiw	a3,a2,-1
    800004a6:	1682                	slli	a3,a3,0x20
    800004a8:	9281                	srli	a3,a3,0x20
    800004aa:	96ae                	add	a3,a3,a1
    800004ac:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    800004ae:	00d58963          	beq	a1,a3,800004c0 <safestrcpy+0x28>
    800004b2:	0585                	addi	a1,a1,1
    800004b4:	0785                	addi	a5,a5,1
    800004b6:	fff5c703          	lbu	a4,-1(a1)
    800004ba:	fee78fa3          	sb	a4,-1(a5)
    800004be:	fb65                	bnez	a4,800004ae <safestrcpy+0x16>
    ;
  *s = 0;
    800004c0:	00078023          	sb	zero,0(a5)
  return os;
}
    800004c4:	6422                	ld	s0,8(sp)
    800004c6:	0141                	addi	sp,sp,16
    800004c8:	8082                	ret

00000000800004ca <strlen>:

int
strlen(const char *s)
{
    800004ca:	1141                	addi	sp,sp,-16
    800004cc:	e422                	sd	s0,8(sp)
    800004ce:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    800004d0:	00054783          	lbu	a5,0(a0)
    800004d4:	cf91                	beqz	a5,800004f0 <strlen+0x26>
    800004d6:	0505                	addi	a0,a0,1
    800004d8:	87aa                	mv	a5,a0
    800004da:	4685                	li	a3,1
    800004dc:	9e89                	subw	a3,a3,a0
    800004de:	00f6853b          	addw	a0,a3,a5
    800004e2:	0785                	addi	a5,a5,1
    800004e4:	fff7c703          	lbu	a4,-1(a5)
    800004e8:	fb7d                	bnez	a4,800004de <strlen+0x14>
    ;
  return n;
}
    800004ea:	6422                	ld	s0,8(sp)
    800004ec:	0141                	addi	sp,sp,16
    800004ee:	8082                	ret
  for(n = 0; s[n]; n++)
    800004f0:	4501                	li	a0,0
    800004f2:	bfe5                	j	800004ea <strlen+0x20>

00000000800004f4 <trapinit>:


// set up to take exceptions and traps while in the kernel.
void
trapinit(void)
{
    800004f4:	1141                	addi	sp,sp,-16
    800004f6:	e422                	sd	s0,8(sp)
    800004f8:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800004fa:	00000797          	auipc	a5,0x0
    800004fe:	12678793          	addi	a5,a5,294 # 80000620 <kernelvec>
    80000502:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80000506:	6422                	ld	s0,8(sp)
    80000508:	0141                	addi	sp,sp,16
    8000050a:	8082                	ret

000000008000050c <kerneltrap>:

// interrupts and exceptions from kernel code go here via kernelvec,
// on whatever the current kernel stack is.
void 
kerneltrap()
{
    8000050c:	1141                	addi	sp,sp,-16
    8000050e:	e406                	sd	ra,8(sp)
    80000510:	e022                	sd	s0,0(sp)
    80000512:	0800                	addi	s0,sp,16
    panic("Unexpected kerneltrap");
    80000514:	00003517          	auipc	a0,0x3
    80000518:	b4450513          	addi	a0,a0,-1212 # 80003058 <digits+0x18>
    8000051c:	00000097          	auipc	ra,0x0
    80000520:	c0a080e7          	jalr	-1014(ra) # 80000126 <panic>

0000000080000524 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80000524:	1141                	addi	sp,sp,-16
    80000526:	e406                	sd	ra,8(sp)
    80000528:	e022                	sd	s0,0(sp)
    8000052a:	0800                	addi	s0,sp,16
  struct proc *p = cpu.proc;
    8000052c:	00006797          	auipc	a5,0x6
    80000530:	8147b783          	ld	a5,-2028(a5) # 80005d40 <cpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000534:	10002773          	csrr	a4,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000538:	9b75                	andi	a4,a4,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000053a:	10071073          	csrw	sstatus,a4
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    8000053e:	00002617          	auipc	a2,0x2
    80000542:	ac260613          	addi	a2,a2,-1342 # 80002000 <_trampoline>
    80000546:	00002697          	auipc	a3,0x2
    8000054a:	aba68693          	addi	a3,a3,-1350 # 80002000 <_trampoline>
    8000054e:	8e91                	sub	a3,a3,a2
    80000550:	04000737          	lui	a4,0x4000
    80000554:	177d                	addi	a4,a4,-1
    80000556:	0732                	slli	a4,a4,0xc
    80000558:	96ba                	add	a3,a3,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000055a:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000055e:	7794                	ld	a3,40(a5)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80000560:	180025f3          	csrr	a1,satp
    80000564:	e28c                	sd	a1,0(a3)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80000566:	778c                	ld	a1,40(a5)
    80000568:	6b94                	ld	a3,16(a5)
    8000056a:	6505                	lui	a0,0x1
    8000056c:	96aa                	add	a3,a3,a0
    8000056e:	e594                	sd	a3,8(a1)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80000570:	7794                	ld	a3,40(a5)
    80000572:	00000597          	auipc	a1,0x0
    80000576:	05058593          	addi	a1,a1,80 # 800005c2 <usertrap>
    8000057a:	ea8c                	sd	a1,16(a3)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000057c:	7794                	ld	a3,40(a5)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000057e:	8592                	mv	a1,tp
    80000580:	f28c                	sd	a1,32(a3)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000582:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80000586:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000058a:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000058e:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80000592:	7794                	ld	a3,40(a5)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80000594:	6e94                	ld	a3,24(a3)
    80000596:	14169073          	csrw	sepc,a3

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    8000059a:	738c                	ld	a1,32(a5)
    8000059c:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    8000059e:	00002797          	auipc	a5,0x2
    800005a2:	af278793          	addi	a5,a5,-1294 # 80002090 <userret>
    800005a6:	8f91                	sub	a5,a5,a2
    800005a8:	973e                	add	a4,a4,a5
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    800005aa:	57fd                	li	a5,-1
    800005ac:	17fe                	slli	a5,a5,0x3f
    800005ae:	8ddd                	or	a1,a1,a5
    800005b0:	02000537          	lui	a0,0x2000
    800005b4:	157d                	addi	a0,a0,-1
    800005b6:	0536                	slli	a0,a0,0xd
    800005b8:	9702                	jalr	a4
}
    800005ba:	60a2                	ld	ra,8(sp)
    800005bc:	6402                	ld	s0,0(sp)
    800005be:	0141                	addi	sp,sp,16
    800005c0:	8082                	ret

00000000800005c2 <usertrap>:
{
    800005c2:	1141                	addi	sp,sp,-16
    800005c4:	e406                	sd	ra,8(sp)
    800005c6:	e022                	sd	s0,0(sp)
    800005c8:	0800                	addi	s0,sp,16
    struct proc* p = cpu.proc;
    800005ca:	00005797          	auipc	a5,0x5
    800005ce:	7767b783          	ld	a5,1910(a5) # 80005d40 <cpu>
    p->trapframe->epc = r_sepc();
    800005d2:	7798                	ld	a4,40(a5)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800005d4:	141026f3          	csrr	a3,sepc
    800005d8:	ef14                	sd	a3,24(a4)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800005da:	142026f3          	csrr	a3,scause
    if(r_scause() == 8) {
    800005de:	4721                	li	a4,8
    800005e0:	00e68a63          	beq	a3,a4,800005f4 <usertrap+0x32>
    usertrapret();
    800005e4:	00000097          	auipc	ra,0x0
    800005e8:	f40080e7          	jalr	-192(ra) # 80000524 <usertrapret>
}
    800005ec:	60a2                	ld	ra,8(sp)
    800005ee:	6402                	ld	s0,0(sp)
    800005f0:	0141                	addi	sp,sp,16
    800005f2:	8082                	ret
        p->trapframe->epc += 4;
    800005f4:	7794                	ld	a3,40(a5)
    800005f6:	6e98                	ld	a4,24(a3)
    800005f8:	0711                	addi	a4,a4,4
    800005fa:	ee98                	sd	a4,24(a3)
        printf("System Call: %d\n", p->trapframe->a0);
    800005fc:	779c                	ld	a5,40(a5)
    800005fe:	7bac                	ld	a1,112(a5)
    80000600:	00003517          	auipc	a0,0x3
    80000604:	a7050513          	addi	a0,a0,-1424 # 80003070 <digits+0x30>
    80000608:	00000097          	auipc	ra,0x0
    8000060c:	b60080e7          	jalr	-1184(ra) # 80000168 <printf>
    80000610:	bfd1                	j	800005e4 <usertrap+0x22>
	...

0000000080000620 <kernelvec>:
    80000620:	7111                	addi	sp,sp,-256
    80000622:	e006                	sd	ra,0(sp)
    80000624:	e40a                	sd	sp,8(sp)
    80000626:	e80e                	sd	gp,16(sp)
    80000628:	ec12                	sd	tp,24(sp)
    8000062a:	f016                	sd	t0,32(sp)
    8000062c:	f41a                	sd	t1,40(sp)
    8000062e:	f81e                	sd	t2,48(sp)
    80000630:	fc22                	sd	s0,56(sp)
    80000632:	e0a6                	sd	s1,64(sp)
    80000634:	e4aa                	sd	a0,72(sp)
    80000636:	e8ae                	sd	a1,80(sp)
    80000638:	ecb2                	sd	a2,88(sp)
    8000063a:	f0b6                	sd	a3,96(sp)
    8000063c:	f4ba                	sd	a4,104(sp)
    8000063e:	f8be                	sd	a5,112(sp)
    80000640:	fcc2                	sd	a6,120(sp)
    80000642:	e146                	sd	a7,128(sp)
    80000644:	e54a                	sd	s2,136(sp)
    80000646:	e94e                	sd	s3,144(sp)
    80000648:	ed52                	sd	s4,152(sp)
    8000064a:	f156                	sd	s5,160(sp)
    8000064c:	f55a                	sd	s6,168(sp)
    8000064e:	f95e                	sd	s7,176(sp)
    80000650:	fd62                	sd	s8,184(sp)
    80000652:	e1e6                	sd	s9,192(sp)
    80000654:	e5ea                	sd	s10,200(sp)
    80000656:	e9ee                	sd	s11,208(sp)
    80000658:	edf2                	sd	t3,216(sp)
    8000065a:	f1f6                	sd	t4,224(sp)
    8000065c:	f5fa                	sd	t5,232(sp)
    8000065e:	f9fe                	sd	t6,240(sp)
    80000660:	eadff0ef          	jal	ra,8000050c <kerneltrap>
    80000664:	6082                	ld	ra,0(sp)
    80000666:	6122                	ld	sp,8(sp)
    80000668:	61c2                	ld	gp,16(sp)
    8000066a:	7282                	ld	t0,32(sp)
    8000066c:	7322                	ld	t1,40(sp)
    8000066e:	73c2                	ld	t2,48(sp)
    80000670:	7462                	ld	s0,56(sp)
    80000672:	6486                	ld	s1,64(sp)
    80000674:	6526                	ld	a0,72(sp)
    80000676:	65c6                	ld	a1,80(sp)
    80000678:	6666                	ld	a2,88(sp)
    8000067a:	7686                	ld	a3,96(sp)
    8000067c:	7726                	ld	a4,104(sp)
    8000067e:	77c6                	ld	a5,112(sp)
    80000680:	7866                	ld	a6,120(sp)
    80000682:	688a                	ld	a7,128(sp)
    80000684:	692a                	ld	s2,136(sp)
    80000686:	69ca                	ld	s3,144(sp)
    80000688:	6a6a                	ld	s4,152(sp)
    8000068a:	7a8a                	ld	s5,160(sp)
    8000068c:	7b2a                	ld	s6,168(sp)
    8000068e:	7bca                	ld	s7,176(sp)
    80000690:	7c6a                	ld	s8,184(sp)
    80000692:	6c8e                	ld	s9,192(sp)
    80000694:	6d2e                	ld	s10,200(sp)
    80000696:	6dce                	ld	s11,208(sp)
    80000698:	6e6e                	ld	t3,216(sp)
    8000069a:	7e8e                	ld	t4,224(sp)
    8000069c:	7f2e                	ld	t5,232(sp)
    8000069e:	7fce                	ld	t6,240(sp)
    800006a0:	6111                	addi	sp,sp,256
    800006a2:	10200073          	sret
    800006a6:	00000013          	nop
    800006aa:	00000013          	nop
    800006ae:	0001                	nop

00000000800006b0 <timervec>:
    800006b0:	34051573          	csrrw	a0,mscratch,a0
    800006b4:	e10c                	sd	a1,0(a0)
    800006b6:	e510                	sd	a2,8(a0)
    800006b8:	e914                	sd	a3,16(a0)
    800006ba:	6d0c                	ld	a1,24(a0)
    800006bc:	7110                	ld	a2,32(a0)
    800006be:	6194                	ld	a3,0(a1)
    800006c0:	96b2                	add	a3,a3,a2
    800006c2:	e194                	sd	a3,0(a1)
    800006c4:	4589                	li	a1,2
    800006c6:	14459073          	csrw	sip,a1
    800006ca:	6914                	ld	a3,16(a0)
    800006cc:	6510                	ld	a2,8(a0)
    800006ce:	610c                	ld	a1,0(a0)
    800006d0:	34051573          	csrrw	a0,mscratch,a0
    800006d4:	30200073          	mret
	...

00000000800006da <proc_freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
static void 
proc_freewalk(pagetable_t pagetable)
{
    800006da:	7179                	addi	sp,sp,-48
    800006dc:	f406                	sd	ra,40(sp)
    800006de:	f022                	sd	s0,32(sp)
    800006e0:	ec26                	sd	s1,24(sp)
    800006e2:	e84a                	sd	s2,16(sp)
    800006e4:	e44e                	sd	s3,8(sp)
    800006e6:	e052                	sd	s4,0(sp)
    800006e8:	1800                	addi	s0,sp,48
    800006ea:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800006ec:	84aa                	mv	s1,a0
    800006ee:	6905                	lui	s2,0x1
    800006f0:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800006f2:	4985                	li	s3,1
    800006f4:	a821                	j	8000070c <proc_freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800006f6:	8129                	srli	a0,a0,0xa
      proc_freewalk((pagetable_t)child);
    800006f8:	0532                	slli	a0,a0,0xc
    800006fa:	00000097          	auipc	ra,0x0
    800006fe:	fe0080e7          	jalr	-32(ra) # 800006da <proc_freewalk>
      pagetable[i] = 0;
    80000702:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80000706:	04a1                	addi	s1,s1,8
    80000708:	03248163          	beq	s1,s2,8000072a <proc_freewalk+0x50>
    pte_t pte = pagetable[i];
    8000070c:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000070e:	00f57793          	andi	a5,a0,15
    80000712:	ff3782e3          	beq	a5,s3,800006f6 <proc_freewalk+0x1c>
    } else if(pte & PTE_V){
    80000716:	8905                	andi	a0,a0,1
    80000718:	d57d                	beqz	a0,80000706 <proc_freewalk+0x2c>
      panic("freewalk: leaf");
    8000071a:	00003517          	auipc	a0,0x3
    8000071e:	96e50513          	addi	a0,a0,-1682 # 80003088 <digits+0x48>
    80000722:	00000097          	auipc	ra,0x0
    80000726:	a04080e7          	jalr	-1532(ra) # 80000126 <panic>
    }
  }
  vm_page_free((void*)pagetable);
    8000072a:	8552                	mv	a0,s4
    8000072c:	00001097          	auipc	ra,0x1
    80000730:	d82080e7          	jalr	-638(ra) # 800014ae <vm_page_free>
}
    80000734:	70a2                	ld	ra,40(sp)
    80000736:	7402                	ld	s0,32(sp)
    80000738:	64e2                	ld	s1,24(sp)
    8000073a:	6942                	ld	s2,16(sp)
    8000073c:	69a2                	ld	s3,8(sp)
    8000073e:	6a02                	ld	s4,0(sp)
    80000740:	6145                	addi	sp,sp,48
    80000742:	8082                	ret

0000000080000744 <proc_loadseg>:
// va must be page-aligned
// and the pages from va to va+sz must already be mapped.
// Returns 0 on success, -1 on failure.
static int
proc_loadseg(pagetable_t pagetable, uint64 va, void *bin, uint offset, uint sz)
{
    80000744:	715d                	addi	sp,sp,-80
    80000746:	e486                	sd	ra,72(sp)
    80000748:	e0a2                	sd	s0,64(sp)
    8000074a:	fc26                	sd	s1,56(sp)
    8000074c:	f84a                	sd	s2,48(sp)
    8000074e:	f44e                	sd	s3,40(sp)
    80000750:	f052                	sd	s4,32(sp)
    80000752:	ec56                	sd	s5,24(sp)
    80000754:	e85a                	sd	s6,16(sp)
    80000756:	e45e                	sd	s7,8(sp)
    80000758:	e062                	sd	s8,0(sp)
    8000075a:	0880                	addi	s0,sp,80
    8000075c:	8b2a                	mv	s6,a0
    8000075e:	8aae                	mv	s5,a1
    80000760:	89ba                	mv	s3,a4
  // have a line that uses memmove and the following expression:
  //   bin+offset+i
  // As an added hint, I have included my variable declarations 
  // above.
  // YOUR CODE HERE
    for (i = 0; i < sz; i += PGSIZE) {
    80000762:	4481                	li	s1,0
        pa = vm_lookup(kernel_pagetable, (uint64)bin + offset + i);
    80000764:	1682                	slli	a3,a3,0x20
    80000766:	9281                	srli	a3,a3,0x20
    80000768:	00d60a33          	add	s4,a2,a3
    8000076c:	00003b97          	auipc	s7,0x3
    80000770:	58cb8b93          	addi	s7,s7,1420 # 80003cf8 <kernel_pagetable>
        if (pa == 0) {
            return -1;
        }

        n = PGSIZE;
        if (i + n > sz) {
    80000774:	6c05                	lui	s8,0x1
    for (i = 0; i < sz; i += PGSIZE) {
    80000776:	0334fd63          	bgeu	s1,s3,800007b0 <proc_loadseg+0x6c>
        pa = vm_lookup(kernel_pagetable, (uint64)bin + offset + i);
    8000077a:	02049913          	slli	s2,s1,0x20
    8000077e:	02095913          	srli	s2,s2,0x20
    80000782:	012a05b3          	add	a1,s4,s2
    80000786:	000bb503          	ld	a0,0(s7)
    8000078a:	00001097          	auipc	ra,0x1
    8000078e:	ea6080e7          	jalr	-346(ra) # 80001630 <vm_lookup>
    80000792:	862a                	mv	a2,a0
        if (pa == 0) {
    80000794:	c91d                	beqz	a0,800007ca <proc_loadseg+0x86>
        if (i + n > sz) {
    80000796:	009c04bb          	addw	s1,s8,s1
            n = sz - i;
        }

        if (vm_page_insert(pagetable, va + i, pa, PTE_R | PTE_W) != 0) {
    8000079a:	4699                	li	a3,6
    8000079c:	015905b3          	add	a1,s2,s5
    800007a0:	855a                	mv	a0,s6
    800007a2:	00001097          	auipc	ra,0x1
    800007a6:	ec8080e7          	jalr	-312(ra) # 8000166a <vm_page_insert>
    800007aa:	d571                	beqz	a0,80000776 <proc_loadseg+0x32>
            return -1;
    800007ac:	557d                	li	a0,-1
    800007ae:	a011                	j	800007b2 <proc_loadseg+0x6e>
        }
    }

    return 0;
    800007b0:	4501                	li	a0,0

}
    800007b2:	60a6                	ld	ra,72(sp)
    800007b4:	6406                	ld	s0,64(sp)
    800007b6:	74e2                	ld	s1,56(sp)
    800007b8:	7942                	ld	s2,48(sp)
    800007ba:	79a2                	ld	s3,40(sp)
    800007bc:	7a02                	ld	s4,32(sp)
    800007be:	6ae2                	ld	s5,24(sp)
    800007c0:	6b42                	ld	s6,16(sp)
    800007c2:	6ba2                	ld	s7,8(sp)
    800007c4:	6c02                	ld	s8,0(sp)
    800007c6:	6161                	addi	sp,sp,80
    800007c8:	8082                	ret
            return -1;
    800007ca:	557d                	li	a0,-1
    800007cc:	b7dd                	j	800007b2 <proc_loadseg+0x6e>

00000000800007ce <proc_init>:
{
    800007ce:	7139                	addi	sp,sp,-64
    800007d0:	fc06                	sd	ra,56(sp)
    800007d2:	f822                	sd	s0,48(sp)
    800007d4:	f426                	sd	s1,40(sp)
    800007d6:	f04a                	sd	s2,32(sp)
    800007d8:	ec4e                	sd	s3,24(sp)
    800007da:	e852                	sd	s4,16(sp)
    800007dc:	e456                	sd	s5,8(sp)
    800007de:	0080                	addi	s0,sp,64
    for (int i = 0; i < NPROC; i++) {
    800007e0:	00005497          	auipc	s1,0x5
    800007e4:	5e848493          	addi	s1,s1,1512 # 80005dc8 <proc+0x10>
    800007e8:	00008a97          	auipc	s5,0x8
    800007ec:	de0a8a93          	addi	s5,s5,-544 # 800085c8 <uart_tx_buf+0x10>
{
    800007f0:	04000937          	lui	s2,0x4000
    800007f4:	1975                	addi	s2,s2,-3
    800007f6:	0932                	slli	s2,s2,0xc
        if (vm_page_insert(kernel_pagetable, proc[i].kstack, (uint64)stack_page, PTE_R | PTE_W) != 0)
    800007f8:	00003997          	auipc	s3,0x3
    800007fc:	50098993          	addi	s3,s3,1280 # 80003cf8 <kernel_pagetable>
    for (int i = 0; i < NPROC; i++) {
    80000800:	7a79                	lui	s4,0xffffe
        proc[i].kstack = KSTACK(i);
    80000802:	0124b023          	sd	s2,0(s1)
        void *stack_page = vm_page_alloc();
    80000806:	00001097          	auipc	ra,0x1
    8000080a:	b32080e7          	jalr	-1230(ra) # 80001338 <vm_page_alloc>
    8000080e:	862a                	mv	a2,a0
        if (stack_page == 0)
    80000810:	c905                	beqz	a0,80000840 <proc_init+0x72>
        if (vm_page_insert(kernel_pagetable, proc[i].kstack, (uint64)stack_page, PTE_R | PTE_W) != 0)
    80000812:	4699                	li	a3,6
    80000814:	608c                	ld	a1,0(s1)
    80000816:	0009b503          	ld	a0,0(s3)
    8000081a:	00001097          	auipc	ra,0x1
    8000081e:	e50080e7          	jalr	-432(ra) # 8000166a <vm_page_insert>
    80000822:	e51d                	bnez	a0,80000850 <proc_init+0x82>
    for (int i = 0; i < NPROC; i++) {
    80000824:	9952                	add	s2,s2,s4
    80000826:	0a048493          	addi	s1,s1,160
    8000082a:	fd549ce3          	bne	s1,s5,80000802 <proc_init+0x34>
}
    8000082e:	70e2                	ld	ra,56(sp)
    80000830:	7442                	ld	s0,48(sp)
    80000832:	74a2                	ld	s1,40(sp)
    80000834:	7902                	ld	s2,32(sp)
    80000836:	69e2                	ld	s3,24(sp)
    80000838:	6a42                	ld	s4,16(sp)
    8000083a:	6aa2                	ld	s5,8(sp)
    8000083c:	6121                	addi	sp,sp,64
    8000083e:	8082                	ret
            panic("proc_init: vm_page_alloc");
    80000840:	00003517          	auipc	a0,0x3
    80000844:	85850513          	addi	a0,a0,-1960 # 80003098 <digits+0x58>
    80000848:	00000097          	auipc	ra,0x0
    8000084c:	8de080e7          	jalr	-1826(ra) # 80000126 <panic>
            panic("proc_init: vm_page_insert");
    80000850:	00003517          	auipc	a0,0x3
    80000854:	86850513          	addi	a0,a0,-1944 # 800030b8 <digits+0x78>
    80000858:	00000097          	auipc	ra,0x0
    8000085c:	8ce080e7          	jalr	-1842(ra) # 80000126 <panic>

0000000080000860 <proc_free>:
{
    80000860:	7139                	addi	sp,sp,-64
    80000862:	fc06                	sd	ra,56(sp)
    80000864:	f822                	sd	s0,48(sp)
    80000866:	f426                	sd	s1,40(sp)
    80000868:	f04a                	sd	s2,32(sp)
    8000086a:	ec4e                	sd	s3,24(sp)
    8000086c:	e852                	sd	s4,16(sp)
    8000086e:	e456                	sd	s5,8(sp)
    80000870:	0080                	addi	s0,sp,64
     if (p == 0)
    80000872:	cd55                	beqz	a0,8000092e <proc_free+0xce>
    80000874:	892a                	mv	s2,a0
    if (p->trapframe)
    80000876:	7508                	ld	a0,40(a0)
    80000878:	c509                	beqz	a0,80000882 <proc_free+0x22>
        vm_page_free((void*)p->trapframe);
    8000087a:	00001097          	auipc	ra,0x1
    8000087e:	c34080e7          	jalr	-972(ra) # 800014ae <vm_page_free>
    proc_free_pagetable(p->pagetable, p->sz);
    80000882:	02093983          	ld	s3,32(s2) # 4000020 <_binary_user_init_size+0x3fff678>
    80000886:	01893a03          	ld	s4,24(s2)
      vm_page_remove(pagetable, TRAMPOLINE, 1, 1);
    8000088a:	4685                	li	a3,1
    8000088c:	4605                	li	a2,1
    8000088e:	040005b7          	lui	a1,0x4000
    80000892:	15fd                	addi	a1,a1,-1
    80000894:	05b2                	slli	a1,a1,0xc
    80000896:	854e                	mv	a0,s3
    80000898:	00001097          	auipc	ra,0x1
    8000089c:	e2a080e7          	jalr	-470(ra) # 800016c2 <vm_page_remove>
    vm_page_remove(pagetable, TRAPFRAME, 1, 1);
    800008a0:	4685                	li	a3,1
    800008a2:	4605                	li	a2,1
    800008a4:	020005b7          	lui	a1,0x2000
    800008a8:	15fd                	addi	a1,a1,-1
    800008aa:	05b6                	slli	a1,a1,0xd
    800008ac:	854e                	mv	a0,s3
    800008ae:	00001097          	auipc	ra,0x1
    800008b2:	e14080e7          	jalr	-492(ra) # 800016c2 <vm_page_remove>
    for (uint64 va = 0; va < sz; va += PGSIZE) {
    800008b6:	000a0f63          	beqz	s4,800008d4 <proc_free+0x74>
    800008ba:	4481                	li	s1,0
    800008bc:	6a85                	lui	s5,0x1
        vm_page_remove(pagetable, va, 1, 1);
    800008be:	4685                	li	a3,1
    800008c0:	4605                	li	a2,1
    800008c2:	85a6                	mv	a1,s1
    800008c4:	854e                	mv	a0,s3
    800008c6:	00001097          	auipc	ra,0x1
    800008ca:	dfc080e7          	jalr	-516(ra) # 800016c2 <vm_page_remove>
    for (uint64 va = 0; va < sz; va += PGSIZE) {
    800008ce:	94d6                	add	s1,s1,s5
    800008d0:	ff44e7e3          	bltu	s1,s4,800008be <proc_free+0x5e>
    proc_freewalk(pagetable);
    800008d4:	854e                	mv	a0,s3
    800008d6:	00000097          	auipc	ra,0x0
    800008da:	e04080e7          	jalr	-508(ra) # 800006da <proc_freewalk>
    p->state = UNUSED;
    800008de:	00092023          	sw	zero,0(s2)
    p->trapframe = 0;
    800008e2:	02093423          	sd	zero,40(s2)
    p->kstack = 0;
    800008e6:	00093823          	sd	zero,16(s2)
    p->pid = 0;
    800008ea:	00092623          	sw	zero,12(s2)
    p->sz = 0;
    800008ee:	00093c23          	sd	zero,24(s2)
    p->pagetable = 0;
    800008f2:	02093023          	sd	zero,32(s2)
    p->wait_read = 0;
    800008f6:	00092223          	sw	zero,4(s2)
    p->wait_write = 0;
    800008fa:	00092423          	sw	zero,8(s2)
    memset(&p->context, 0, sizeof(p->context));
    800008fe:	07000613          	li	a2,112
    80000902:	4581                	li	a1,0
    80000904:	03090513          	addi	a0,s2,48
    80000908:	00000097          	auipc	ra,0x0
    8000090c:	a3e080e7          	jalr	-1474(ra) # 80000346 <memset>
    if (p == cpu.proc)
    80000910:	00005797          	auipc	a5,0x5
    80000914:	4307b783          	ld	a5,1072(a5) # 80005d40 <cpu>
    80000918:	03278363          	beq	a5,s2,8000093e <proc_free+0xde>
}
    8000091c:	70e2                	ld	ra,56(sp)
    8000091e:	7442                	ld	s0,48(sp)
    80000920:	74a2                	ld	s1,40(sp)
    80000922:	7902                	ld	s2,32(sp)
    80000924:	69e2                	ld	s3,24(sp)
    80000926:	6a42                	ld	s4,16(sp)
    80000928:	6aa2                	ld	s5,8(sp)
    8000092a:	6121                	addi	sp,sp,64
    8000092c:	8082                	ret
        panic("proc_free: attempting to free a null process");
    8000092e:	00002517          	auipc	a0,0x2
    80000932:	7aa50513          	addi	a0,a0,1962 # 800030d8 <digits+0x98>
    80000936:	fffff097          	auipc	ra,0xfffff
    8000093a:	7f0080e7          	jalr	2032(ra) # 80000126 <panic>
        cpu.proc = 0;
    8000093e:	00005797          	auipc	a5,0x5
    80000942:	4007b123          	sd	zero,1026(a5) # 80005d40 <cpu>
}
    80000946:	bfd9                	j	8000091c <proc_free+0xbc>

0000000080000948 <proc_alloc>:
{
    80000948:	7179                	addi	sp,sp,-48
    8000094a:	f406                	sd	ra,40(sp)
    8000094c:	f022                	sd	s0,32(sp)
    8000094e:	ec26                	sd	s1,24(sp)
    80000950:	e84a                	sd	s2,16(sp)
    80000952:	e44e                	sd	s3,8(sp)
    80000954:	1800                	addi	s0,sp,48
    for (int i = 0; i < NPROC; i++) {
    80000956:	00005797          	auipc	a5,0x5
    8000095a:	46278793          	addi	a5,a5,1122 # 80005db8 <proc>
    8000095e:	4481                	li	s1,0
    80000960:	04000693          	li	a3,64
        if (proc[i].state == UNUSED) {
    80000964:	4398                	lw	a4,0(a5)
    80000966:	cb01                	beqz	a4,80000976 <proc_alloc+0x2e>
    for (int i = 0; i < NPROC; i++) {
    80000968:	2485                	addiw	s1,s1,1
    8000096a:	0a078793          	addi	a5,a5,160
    8000096e:	fed49be3          	bne	s1,a3,80000964 <proc_alloc+0x1c>
        return 0;
    80000972:	4901                	li	s2,0
    80000974:	a0f9                	j	80000a42 <proc_alloc+0xfa>
            p = &proc[i];
    80000976:	00249913          	slli	s2,s1,0x2
    8000097a:	9926                	add	s2,s2,s1
    8000097c:	0916                	slli	s2,s2,0x5
    8000097e:	00005797          	auipc	a5,0x5
    80000982:	43a78793          	addi	a5,a5,1082 # 80005db8 <proc>
    80000986:	993e                	add	s2,s2,a5
    p->pid = nextpid++;
    80000988:	00003717          	auipc	a4,0x3
    8000098c:	97870713          	addi	a4,a4,-1672 # 80003300 <nextpid>
    80000990:	431c                	lw	a5,0(a4)
    80000992:	0017869b          	addiw	a3,a5,1
    80000996:	c314                	sw	a3,0(a4)
    80000998:	00f92623          	sw	a5,12(s2)
    p->trapframe = (struct trapframe*)vm_page_alloc();
    8000099c:	00001097          	auipc	ra,0x1
    800009a0:	99c080e7          	jalr	-1636(ra) # 80001338 <vm_page_alloc>
    800009a4:	89aa                	mv	s3,a0
    800009a6:	02a93423          	sd	a0,40(s2)
    if (p->trapframe == 0) {
    800009aa:	c545                	beqz	a0,80000a52 <proc_alloc+0x10a>
    memset(p->trapframe, 0, PGSIZE);
    800009ac:	6605                	lui	a2,0x1
    800009ae:	4581                	li	a1,0
    800009b0:	00000097          	auipc	ra,0x0
    800009b4:	996080e7          	jalr	-1642(ra) # 80000346 <memset>
    pagetable_t pagetable = vm_create_pagetable();
    800009b8:	00001097          	auipc	ra,0x1
    800009bc:	c4a080e7          	jalr	-950(ra) # 80001602 <vm_create_pagetable>
    800009c0:	89aa                	mv	s3,a0
    if (pagetable == 0)
    800009c2:	c545                	beqz	a0,80000a6a <proc_alloc+0x122>
    if (vm_page_insert(pagetable, TRAMPOLINE, (uint64)trampoline, PTE_R | PTE_X) == -1) {
    800009c4:	46a9                	li	a3,10
    800009c6:	00001617          	auipc	a2,0x1
    800009ca:	63a60613          	addi	a2,a2,1594 # 80002000 <_trampoline>
    800009ce:	040005b7          	lui	a1,0x4000
    800009d2:	15fd                	addi	a1,a1,-1
    800009d4:	05b2                	slli	a1,a1,0xc
    800009d6:	00001097          	auipc	ra,0x1
    800009da:	c94080e7          	jalr	-876(ra) # 8000166a <vm_page_insert>
    800009de:	57fd                	li	a5,-1
    800009e0:	08f50063          	beq	a0,a5,80000a60 <proc_alloc+0x118>
    if (vm_page_insert(pagetable, TRAPFRAME, (uint64)p->trapframe, PTE_R | PTE_W) == -1) {
    800009e4:	00249793          	slli	a5,s1,0x2
    800009e8:	97a6                	add	a5,a5,s1
    800009ea:	0796                	slli	a5,a5,0x5
    800009ec:	00005717          	auipc	a4,0x5
    800009f0:	3cc70713          	addi	a4,a4,972 # 80005db8 <proc>
    800009f4:	97ba                	add	a5,a5,a4
    800009f6:	4699                	li	a3,6
    800009f8:	7790                	ld	a2,40(a5)
    800009fa:	020005b7          	lui	a1,0x2000
    800009fe:	15fd                	addi	a1,a1,-1
    80000a00:	05b6                	slli	a1,a1,0xd
    80000a02:	854e                	mv	a0,s3
    80000a04:	00001097          	auipc	ra,0x1
    80000a08:	c66080e7          	jalr	-922(ra) # 8000166a <vm_page_insert>
    80000a0c:	57fd                	li	a5,-1
    80000a0e:	08f50063          	beq	a0,a5,80000a8e <proc_alloc+0x146>
    p->pagetable = proc_pagetable(p);
    80000a12:	00005697          	auipc	a3,0x5
    80000a16:	3a668693          	addi	a3,a3,934 # 80005db8 <proc>
    80000a1a:	00249713          	slli	a4,s1,0x2
    80000a1e:	009707b3          	add	a5,a4,s1
    80000a22:	0796                	slli	a5,a5,0x5
    80000a24:	97b6                	add	a5,a5,a3
    80000a26:	0337b023          	sd	s3,32(a5)
    p->context.ra = (uint64)usertrapret;
    80000a2a:	00000617          	auipc	a2,0x0
    80000a2e:	afa60613          	addi	a2,a2,-1286 # 80000524 <usertrapret>
    80000a32:	fb90                	sd	a2,48(a5)
    p->context.sp = p->kstack + PGSIZE;
    80000a34:	6b90                	ld	a2,16(a5)
    80000a36:	6585                	lui	a1,0x1
    80000a38:	962e                	add	a2,a2,a1
    80000a3a:	ff90                	sd	a2,56(a5)
    p->state = USED;
    80000a3c:	873e                	mv	a4,a5
    80000a3e:	4785                	li	a5,1
    80000a40:	c31c                	sw	a5,0(a4)
}
    80000a42:	854a                	mv	a0,s2
    80000a44:	70a2                	ld	ra,40(sp)
    80000a46:	7402                	ld	s0,32(sp)
    80000a48:	64e2                	ld	s1,24(sp)
    80000a4a:	6942                	ld	s2,16(sp)
    80000a4c:	69a2                	ld	s3,8(sp)
    80000a4e:	6145                	addi	sp,sp,48
    80000a50:	8082                	ret
        proc_free(p);
    80000a52:	854a                	mv	a0,s2
    80000a54:	00000097          	auipc	ra,0x0
    80000a58:	e0c080e7          	jalr	-500(ra) # 80000860 <proc_free>
        return 0;
    80000a5c:	894e                	mv	s2,s3
    80000a5e:	b7d5                	j	80000a42 <proc_alloc+0xfa>
        vm_page_free(pagetable);
    80000a60:	854e                	mv	a0,s3
    80000a62:	00001097          	auipc	ra,0x1
    80000a66:	a4c080e7          	jalr	-1460(ra) # 800014ae <vm_page_free>
    p->pagetable = proc_pagetable(p);
    80000a6a:	00249793          	slli	a5,s1,0x2
    80000a6e:	97a6                	add	a5,a5,s1
    80000a70:	0796                	slli	a5,a5,0x5
    80000a72:	00005717          	auipc	a4,0x5
    80000a76:	34670713          	addi	a4,a4,838 # 80005db8 <proc>
    80000a7a:	97ba                	add	a5,a5,a4
    80000a7c:	0207b023          	sd	zero,32(a5)
        proc_free(p);
    80000a80:	854a                	mv	a0,s2
    80000a82:	00000097          	auipc	ra,0x0
    80000a86:	dde080e7          	jalr	-546(ra) # 80000860 <proc_free>
        return 0;
    80000a8a:	4901                	li	s2,0
    80000a8c:	bf5d                	j	80000a42 <proc_alloc+0xfa>
        vm_page_remove(pagetable, TRAMPOLINE, 1, 1);
    80000a8e:	4685                	li	a3,1
    80000a90:	4605                	li	a2,1
    80000a92:	040005b7          	lui	a1,0x4000
    80000a96:	15fd                	addi	a1,a1,-1
    80000a98:	05b2                	slli	a1,a1,0xc
    80000a9a:	854e                	mv	a0,s3
    80000a9c:	00001097          	auipc	ra,0x1
    80000aa0:	c26080e7          	jalr	-986(ra) # 800016c2 <vm_page_remove>
        vm_page_free(pagetable);
    80000aa4:	854e                	mv	a0,s3
    80000aa6:	00001097          	auipc	ra,0x1
    80000aaa:	a08080e7          	jalr	-1528(ra) # 800014ae <vm_page_free>
        return 0;
    80000aae:	bf75                	j	80000a6a <proc_alloc+0x122>

0000000080000ab0 <proc_resize>:
{
    80000ab0:	1101                	addi	sp,sp,-32
    80000ab2:	ec06                	sd	ra,24(sp)
    80000ab4:	e822                	sd	s0,16(sp)
    80000ab6:	e426                	sd	s1,8(sp)
    80000ab8:	1000                	addi	s0,sp,32
    80000aba:	84b2                	mv	s1,a2
     if (newsz > oldsz) {
    80000abc:	00c5ea63          	bltu	a1,a2,80000ad0 <proc_resize+0x20>
    } else if (newsz < oldsz) {
    80000ac0:	02b66663          	bltu	a2,a1,80000aec <proc_resize+0x3c>
}
    80000ac4:	8526                	mv	a0,s1
    80000ac6:	60e2                	ld	ra,24(sp)
    80000ac8:	6442                	ld	s0,16(sp)
    80000aca:	64a2                	ld	s1,8(sp)
    80000acc:	6105                	addi	sp,sp,32
    80000ace:	8082                	ret
        if (proc_loadseg(pagetable, oldsz, 0, 0, newsz - oldsz) != 0) {
    80000ad0:	40b6073b          	subw	a4,a2,a1
    80000ad4:	4681                	li	a3,0
    80000ad6:	4601                	li	a2,0
    80000ad8:	00000097          	auipc	ra,0x0
    80000adc:	c6c080e7          	jalr	-916(ra) # 80000744 <proc_loadseg>
            return 0;
    80000ae0:	00153513          	seqz	a0,a0
    80000ae4:	40a00533          	neg	a0,a0
    80000ae8:	8ce9                	and	s1,s1,a0
    80000aea:	bfe9                	j	80000ac4 <proc_resize+0x14>
  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80000aec:	6785                	lui	a5,0x1
    80000aee:	17fd                	addi	a5,a5,-1
    80000af0:	00f60733          	add	a4,a2,a5
    80000af4:	76fd                	lui	a3,0xfffff
    80000af6:	8f75                	and	a4,a4,a3
    80000af8:	97ae                	add	a5,a5,a1
    80000afa:	8ff5                	and	a5,a5,a3
    80000afc:	fcf774e3          	bgeu	a4,a5,80000ac4 <proc_resize+0x14>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80000b00:	8f99                	sub	a5,a5,a4
    80000b02:	00c7d613          	srli	a2,a5,0xc
    vm_page_remove(pagetable, PGROUNDUP(newsz), npages, 1);
    80000b06:	4685                	li	a3,1
    80000b08:	2601                	sext.w	a2,a2
    80000b0a:	85ba                	mv	a1,a4
    80000b0c:	00001097          	auipc	ra,0x1
    80000b10:	bb6080e7          	jalr	-1098(ra) # 800016c2 <vm_page_remove>
        if (new_sz == 0) {
    80000b14:	bf45                	j	80000ac4 <proc_resize+0x14>

0000000080000b16 <proc_load_elf>:
{
    80000b16:	7175                	addi	sp,sp,-144
    80000b18:	e506                	sd	ra,136(sp)
    80000b1a:	e122                	sd	s0,128(sp)
    80000b1c:	fca6                	sd	s1,120(sp)
    80000b1e:	f8ca                	sd	s2,112(sp)
    80000b20:	f4ce                	sd	s3,104(sp)
    80000b22:	f0d2                	sd	s4,96(sp)
    80000b24:	ecd6                	sd	s5,88(sp)
    80000b26:	e8da                	sd	s6,80(sp)
    80000b28:	e4de                	sd	s7,72(sp)
    80000b2a:	e0e2                	sd	s8,64(sp)
    80000b2c:	0900                	addi	s0,sp,144
    elf = *(struct elfhdr*) bin;
    80000b2e:	0205b903          	ld	s2,32(a1) # 4000020 <_binary_user_init_size+0x3fff678>
    80000b32:	0385d483          	lhu	s1,56(a1)
    if(elf.magic != ELF_MAGIC)
    80000b36:	4198                	lw	a4,0(a1)
    80000b38:	464c47b7          	lui	a5,0x464c4
    80000b3c:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_user_init_size+0x464c3bd7>
    80000b40:	0af71863          	bne	a4,a5,80000bf0 <proc_load_elf+0xda>
    80000b44:	8c2a                	mv	s8,a0
    80000b46:	8a2e                	mv	s4,a1
     pagetable = vm_create_pagetable();
    80000b48:	00001097          	auipc	ra,0x1
    80000b4c:	aba080e7          	jalr	-1350(ra) # 80001602 <vm_create_pagetable>
    80000b50:	8aaa                	mv	s5,a0
    if (pagetable == 0)
    80000b52:	c14d                	beqz	a0,80000bf4 <proc_load_elf+0xde>
    for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80000b54:	2901                	sext.w	s2,s2
    80000b56:	00048b9b          	sext.w	s7,s1
    80000b5a:	c8c9                	beqz	s1,80000bec <proc_load_elf+0xd6>
    uint64 sz=0, sp=0;
    80000b5c:	4481                	li	s1,0
    for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80000b5e:	4981                	li	s3,0
        if (ph.type != ELF_PROG_LOAD)
    80000b60:	4b05                	li	s6,1
        if (memmove(bin + off, &ph, sizeof(ph)) != 0)
    80000b62:	03800613          	li	a2,56
    80000b66:	f7840593          	addi	a1,s0,-136
    80000b6a:	012a0533          	add	a0,s4,s2
    80000b6e:	00000097          	auipc	ra,0x0
    80000b72:	834080e7          	jalr	-1996(ra) # 800003a2 <memmove>
    80000b76:	e149                	bnez	a0,80000bf8 <proc_load_elf+0xe2>
        if (ph.type != ELF_PROG_LOAD)
    80000b78:	f7842783          	lw	a5,-136(s0)
    80000b7c:	07679e63          	bne	a5,s6,80000bf8 <proc_load_elf+0xe2>
        sz = proc_resize(pagetable, sz, ph.vaddr + ph.memsz);
    80000b80:	f8843603          	ld	a2,-120(s0)
    80000b84:	fa043783          	ld	a5,-96(s0)
    80000b88:	963e                	add	a2,a2,a5
    80000b8a:	85a6                	mv	a1,s1
    80000b8c:	8556                	mv	a0,s5
    80000b8e:	00000097          	auipc	ra,0x0
    80000b92:	f22080e7          	jalr	-222(ra) # 80000ab0 <proc_resize>
    80000b96:	84aa                	mv	s1,a0
        if (proc_loadseg(pagetable, ph.vaddr, bin, ph.off, ph.filesz) != 0)
    80000b98:	f9842703          	lw	a4,-104(s0)
    80000b9c:	f8042683          	lw	a3,-128(s0)
    80000ba0:	8652                	mv	a2,s4
    80000ba2:	f8843583          	ld	a1,-120(s0)
    80000ba6:	8556                	mv	a0,s5
    80000ba8:	00000097          	auipc	ra,0x0
    80000bac:	b9c080e7          	jalr	-1124(ra) # 80000744 <proc_loadseg>
    80000bb0:	e521                	bnez	a0,80000bf8 <proc_load_elf+0xe2>
    for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80000bb2:	2985                	addiw	s3,s3,1
    80000bb4:	0389091b          	addiw	s2,s2,56
    80000bb8:	fb7995e3          	bne	s3,s7,80000b62 <proc_load_elf+0x4c>
    sz = proc_resize(pagetable, sz, sz + PGSIZE);
    80000bbc:	6605                	lui	a2,0x1
    80000bbe:	9626                	add	a2,a2,s1
    80000bc0:	85a6                	mv	a1,s1
    80000bc2:	8556                	mv	a0,s5
    80000bc4:	00000097          	auipc	ra,0x0
    80000bc8:	eec080e7          	jalr	-276(ra) # 80000ab0 <proc_resize>
    80000bcc:	84aa                	mv	s1,a0
    proc_freewalk(p->pagetable);
    80000bce:	020c3503          	ld	a0,32(s8) # 1020 <_binary_user_init_size+0x678>
    80000bd2:	00000097          	auipc	ra,0x0
    80000bd6:	b08080e7          	jalr	-1272(ra) # 800006da <proc_freewalk>
    p->pagetable = pagetable;
    80000bda:	035c3023          	sd	s5,32(s8)
    p->sz = sz;
    80000bde:	009c3c23          	sd	s1,24(s8)
    p->state = RUNNABLE;
    80000be2:	478d                	li	a5,3
    80000be4:	00fc2023          	sw	a5,0(s8)
    return 0;
    80000be8:	4501                	li	a0,0
    80000bea:	a829                	j	80000c04 <proc_load_elf+0xee>
    uint64 sz=0, sp=0;
    80000bec:	4481                	li	s1,0
    80000bee:	b7f9                	j	80000bbc <proc_load_elf+0xa6>
    return -1;
    80000bf0:	557d                	li	a0,-1
    80000bf2:	a809                	j	80000c04 <proc_load_elf+0xee>
    80000bf4:	557d                	li	a0,-1
    80000bf6:	a039                	j	80000c04 <proc_load_elf+0xee>
        vm_page_free(pagetable);
    80000bf8:	8556                	mv	a0,s5
    80000bfa:	00001097          	auipc	ra,0x1
    80000bfe:	8b4080e7          	jalr	-1868(ra) # 800014ae <vm_page_free>
    return -1;
    80000c02:	557d                	li	a0,-1
}
    80000c04:	60aa                	ld	ra,136(sp)
    80000c06:	640a                	ld	s0,128(sp)
    80000c08:	74e6                	ld	s1,120(sp)
    80000c0a:	7946                	ld	s2,112(sp)
    80000c0c:	79a6                	ld	s3,104(sp)
    80000c0e:	7a06                	ld	s4,96(sp)
    80000c10:	6ae6                	ld	s5,88(sp)
    80000c12:	6b46                	ld	s6,80(sp)
    80000c14:	6ba6                	ld	s7,72(sp)
    80000c16:	6c06                	ld	s8,64(sp)
    80000c18:	6149                	addi	sp,sp,144
    80000c1a:	8082                	ret

0000000080000c1c <proc_load_user_init>:
{
    80000c1c:	1101                	addi	sp,sp,-32
    80000c1e:	ec06                	sd	ra,24(sp)
    80000c20:	e822                	sd	s0,16(sp)
    80000c22:	e426                	sd	s1,8(sp)
    80000c24:	1000                	addi	s0,sp,32
    p = proc_alloc();
    80000c26:	00000097          	auipc	ra,0x0
    80000c2a:	d22080e7          	jalr	-734(ra) # 80000948 <proc_alloc>
    if (p == 0)
    80000c2e:	c10d                	beqz	a0,80000c50 <proc_load_user_init+0x34>
    80000c30:	84aa                	mv	s1,a0
    if (proc_load_elf(p, bin) != 0) {
    80000c32:	00002597          	auipc	a1,0x2
    80000c36:	6de58593          	addi	a1,a1,1758 # 80003310 <_binary_user_init_start>
    80000c3a:	00000097          	auipc	ra,0x0
    80000c3e:	edc080e7          	jalr	-292(ra) # 80000b16 <proc_load_elf>
    80000c42:	ed19                	bnez	a0,80000c60 <proc_load_user_init+0x44>
}
    80000c44:	8526                	mv	a0,s1
    80000c46:	60e2                	ld	ra,24(sp)
    80000c48:	6442                	ld	s0,16(sp)
    80000c4a:	64a2                	ld	s1,8(sp)
    80000c4c:	6105                	addi	sp,sp,32
    80000c4e:	8082                	ret
        panic("proc_load_user_init: no available processes");
    80000c50:	00002517          	auipc	a0,0x2
    80000c54:	4b850513          	addi	a0,a0,1208 # 80003108 <digits+0xc8>
    80000c58:	fffff097          	auipc	ra,0xfffff
    80000c5c:	4ce080e7          	jalr	1230(ra) # 80000126 <panic>
        proc_free(p);
    80000c60:	8526                	mv	a0,s1
    80000c62:	00000097          	auipc	ra,0x0
    80000c66:	bfe080e7          	jalr	-1026(ra) # 80000860 <proc_free>
        return 0;
    80000c6a:	4481                	li	s1,0
    80000c6c:	bfe1                	j	80000c44 <proc_load_user_init+0x28>

0000000080000c6e <swtch>:
    80000c6e:	00153023          	sd	ra,0(a0)
    80000c72:	00253423          	sd	sp,8(a0)
    80000c76:	e900                	sd	s0,16(a0)
    80000c78:	ed04                	sd	s1,24(a0)
    80000c7a:	03253023          	sd	s2,32(a0)
    80000c7e:	03353423          	sd	s3,40(a0)
    80000c82:	03453823          	sd	s4,48(a0)
    80000c86:	03553c23          	sd	s5,56(a0)
    80000c8a:	05653023          	sd	s6,64(a0)
    80000c8e:	05753423          	sd	s7,72(a0)
    80000c92:	05853823          	sd	s8,80(a0)
    80000c96:	05953c23          	sd	s9,88(a0)
    80000c9a:	07a53023          	sd	s10,96(a0)
    80000c9e:	07b53423          	sd	s11,104(a0)
    80000ca2:	0005b083          	ld	ra,0(a1)
    80000ca6:	0085b103          	ld	sp,8(a1)
    80000caa:	6980                	ld	s0,16(a1)
    80000cac:	6d84                	ld	s1,24(a1)
    80000cae:	0205b903          	ld	s2,32(a1)
    80000cb2:	0285b983          	ld	s3,40(a1)
    80000cb6:	0305ba03          	ld	s4,48(a1)
    80000cba:	0385ba83          	ld	s5,56(a1)
    80000cbe:	0405bb03          	ld	s6,64(a1)
    80000cc2:	0485bb83          	ld	s7,72(a1)
    80000cc6:	0505bc03          	ld	s8,80(a1)
    80000cca:	0585bc83          	ld	s9,88(a1)
    80000cce:	0605bd03          	ld	s10,96(a1)
    80000cd2:	0685bd83          	ld	s11,104(a1)
    80000cd6:	8082                	ret

0000000080000cd8 <main>:
void swtch(struct context *old, struct context *new);

// start() jumps here in supervisor mode
void
main()
{
    80000cd8:	1141                	addi	sp,sp,-16
    80000cda:	e406                	sd	ra,8(sp)
    80000cdc:	e022                	sd	s0,0(sp)
    80000cde:	0800                	addi	s0,sp,16
  // initialize uart
  uartinit();
    80000ce0:	00000097          	auipc	ra,0x0
    80000ce4:	082080e7          	jalr	130(ra) # 80000d62 <uartinit>
  printf("\n");
    80000ce8:	00002517          	auipc	a0,0x2
    80000cec:	32050513          	addi	a0,a0,800 # 80003008 <etext+0x8>
    80000cf0:	fffff097          	auipc	ra,0xfffff
    80000cf4:	478080e7          	jalr	1144(ra) # 80000168 <printf>
  printf("SEMOS kernel is booting\n");
    80000cf8:	00002517          	auipc	a0,0x2
    80000cfc:	44050513          	addi	a0,a0,1088 # 80003138 <digits+0xf8>
    80000d00:	fffff097          	auipc	ra,0xfffff
    80000d04:	468080e7          	jalr	1128(ra) # 80000168 <printf>
  printf("\n");
    80000d08:	00002517          	auipc	a0,0x2
    80000d0c:	30050513          	addi	a0,a0,768 # 80003008 <etext+0x8>
    80000d10:	fffff097          	auipc	ra,0xfffff
    80000d14:	458080e7          	jalr	1112(ra) # 80000168 <printf>

  // initialize traps
  trapinit();
    80000d18:	fffff097          	auipc	ra,0xfffff
    80000d1c:	7dc080e7          	jalr	2012(ra) # 800004f4 <trapinit>

  //initialize virtual memory
  vm_init();
    80000d20:	00000097          	auipc	ra,0x0
    80000d24:	7d0080e7          	jalr	2000(ra) # 800014f0 <vm_init>

  // initialize other kernel subsystems
  port_init();
    80000d28:	00000097          	auipc	ra,0x0
    80000d2c:	1a6080e7          	jalr	422(ra) # 80000ece <port_init>
  proc_init();
    80000d30:	00000097          	auipc	ra,0x0
    80000d34:	a9e080e7          	jalr	-1378(ra) # 800007ce <proc_init>

  // load up the user space
  struct proc* init = proc_load_user_init();
    80000d38:	00000097          	auipc	ra,0x0
    80000d3c:	ee4080e7          	jalr	-284(ra) # 80000c1c <proc_load_user_init>
  cpu.proc = init;
    80000d40:	00005797          	auipc	a5,0x5
    80000d44:	00a7b023          	sd	a0,0(a5) # 80005d40 <cpu>
  init->state = RUNNING;
    80000d48:	4791                	li	a5,4
    80000d4a:	c11c                	sw	a5,0(a0)
  swtch(&cpu.context, &init->context);
    80000d4c:	03050593          	addi	a1,a0,48
    80000d50:	00005517          	auipc	a0,0x5
    80000d54:	ff850513          	addi	a0,a0,-8 # 80005d48 <cpu+0x8>
    80000d58:	00000097          	auipc	ra,0x0
    80000d5c:	f16080e7          	jalr	-234(ra) # 80000c6e <swtch>
  while(1);
    80000d60:	a001                	j	80000d60 <main+0x88>

0000000080000d62 <uartinit>:
    80000d62:	1141                	addi	sp,sp,-16
    80000d64:	e422                	sd	s0,8(sp)
    80000d66:	0800                	addi	s0,sp,16
    80000d68:	100007b7          	lui	a5,0x10000
    80000d6c:	000780a3          	sb	zero,1(a5) # 10000001 <_binary_user_init_size+0xffff659>
    80000d70:	f8000713          	li	a4,-128
    80000d74:	00e781a3          	sb	a4,3(a5)
    80000d78:	470d                	li	a4,3
    80000d7a:	00e78023          	sb	a4,0(a5)
    80000d7e:	000780a3          	sb	zero,1(a5)
    80000d82:	00e781a3          	sb	a4,3(a5)
    80000d86:	469d                	li	a3,7
    80000d88:	00d78123          	sb	a3,2(a5)
    80000d8c:	00e780a3          	sb	a4,1(a5)
    80000d90:	6422                	ld	s0,8(sp)
    80000d92:	0141                	addi	sp,sp,16
    80000d94:	8082                	ret

0000000080000d96 <uartputc_sync>:
    80000d96:	1141                	addi	sp,sp,-16
    80000d98:	e422                	sd	s0,8(sp)
    80000d9a:	0800                	addi	s0,sp,16
    80000d9c:	00003797          	auipc	a5,0x3
    80000da0:	f447a783          	lw	a5,-188(a5) # 80003ce0 <panicked>
    80000da4:	10000737          	lui	a4,0x10000
    80000da8:	c391                	beqz	a5,80000dac <uartputc_sync+0x16>
    80000daa:	a001                	j	80000daa <uartputc_sync+0x14>
    80000dac:	00574783          	lbu	a5,5(a4) # 10000005 <_binary_user_init_size+0xffff65d>
    80000db0:	0207f793          	andi	a5,a5,32
    80000db4:	dfe5                	beqz	a5,80000dac <uartputc_sync+0x16>
    80000db6:	0ff57513          	andi	a0,a0,255
    80000dba:	100007b7          	lui	a5,0x10000
    80000dbe:	00a78023          	sb	a0,0(a5) # 10000000 <_binary_user_init_size+0xffff658>
    80000dc2:	6422                	ld	s0,8(sp)
    80000dc4:	0141                	addi	sp,sp,16
    80000dc6:	8082                	ret

0000000080000dc8 <uartstart>:
    80000dc8:	1141                	addi	sp,sp,-16
    80000dca:	e422                	sd	s0,8(sp)
    80000dcc:	0800                	addi	s0,sp,16
    80000dce:	00003797          	auipc	a5,0x3
    80000dd2:	f1a7b783          	ld	a5,-230(a5) # 80003ce8 <uart_tx_r>
    80000dd6:	00003717          	auipc	a4,0x3
    80000dda:	f1a73703          	ld	a4,-230(a4) # 80003cf0 <uart_tx_w>
    80000dde:	04f70263          	beq	a4,a5,80000e22 <uartstart+0x5a>
    80000de2:	100006b7          	lui	a3,0x10000
    80000de6:	00007517          	auipc	a0,0x7
    80000dea:	7d250513          	addi	a0,a0,2002 # 800085b8 <uart_tx_buf>
    80000dee:	00003617          	auipc	a2,0x3
    80000df2:	efa60613          	addi	a2,a2,-262 # 80003ce8 <uart_tx_r>
    80000df6:	00003597          	auipc	a1,0x3
    80000dfa:	efa58593          	addi	a1,a1,-262 # 80003cf0 <uart_tx_w>
    80000dfe:	0056c703          	lbu	a4,5(a3) # 10000005 <_binary_user_init_size+0xffff65d>
    80000e02:	02077713          	andi	a4,a4,32
    80000e06:	cf11                	beqz	a4,80000e22 <uartstart+0x5a>
    80000e08:	01f7f713          	andi	a4,a5,31
    80000e0c:	972a                	add	a4,a4,a0
    80000e0e:	00074703          	lbu	a4,0(a4)
    80000e12:	0785                	addi	a5,a5,1
    80000e14:	e21c                	sd	a5,0(a2)
    80000e16:	00e68023          	sb	a4,0(a3)
    80000e1a:	621c                	ld	a5,0(a2)
    80000e1c:	6198                	ld	a4,0(a1)
    80000e1e:	fef710e3          	bne	a4,a5,80000dfe <uartstart+0x36>
    80000e22:	6422                	ld	s0,8(sp)
    80000e24:	0141                	addi	sp,sp,16
    80000e26:	8082                	ret

0000000080000e28 <uartputc>:
    80000e28:	00003797          	auipc	a5,0x3
    80000e2c:	eb87a783          	lw	a5,-328(a5) # 80003ce0 <panicked>
    80000e30:	c391                	beqz	a5,80000e34 <uartputc+0xc>
    80000e32:	a001                	j	80000e32 <uartputc+0xa>
    80000e34:	1141                	addi	sp,sp,-16
    80000e36:	e406                	sd	ra,8(sp)
    80000e38:	e022                	sd	s0,0(sp)
    80000e3a:	0800                	addi	s0,sp,16
    80000e3c:	00003717          	auipc	a4,0x3
    80000e40:	eac73703          	ld	a4,-340(a4) # 80003ce8 <uart_tx_r>
    80000e44:	02070713          	addi	a4,a4,32
    80000e48:	00003797          	auipc	a5,0x3
    80000e4c:	ea87b783          	ld	a5,-344(a5) # 80003cf0 <uart_tx_w>
    80000e50:	00f70063          	beq	a4,a5,80000e50 <uartputc+0x28>
    80000e54:	01f7f693          	andi	a3,a5,31
    80000e58:	00007717          	auipc	a4,0x7
    80000e5c:	76070713          	addi	a4,a4,1888 # 800085b8 <uart_tx_buf>
    80000e60:	9736                	add	a4,a4,a3
    80000e62:	00a70023          	sb	a0,0(a4)
    80000e66:	0785                	addi	a5,a5,1
    80000e68:	00003717          	auipc	a4,0x3
    80000e6c:	e8f73423          	sd	a5,-376(a4) # 80003cf0 <uart_tx_w>
    80000e70:	00000097          	auipc	ra,0x0
    80000e74:	f58080e7          	jalr	-168(ra) # 80000dc8 <uartstart>
    80000e78:	60a2                	ld	ra,8(sp)
    80000e7a:	6402                	ld	s0,0(sp)
    80000e7c:	0141                	addi	sp,sp,16
    80000e7e:	8082                	ret

0000000080000e80 <uartgetc>:
    80000e80:	1141                	addi	sp,sp,-16
    80000e82:	e422                	sd	s0,8(sp)
    80000e84:	0800                	addi	s0,sp,16
    80000e86:	100007b7          	lui	a5,0x10000
    80000e8a:	0057c783          	lbu	a5,5(a5) # 10000005 <_binary_user_init_size+0xffff65d>
    80000e8e:	8b85                	andi	a5,a5,1
    80000e90:	cb81                	beqz	a5,80000ea0 <uartgetc+0x20>
    80000e92:	100007b7          	lui	a5,0x10000
    80000e96:	0007c503          	lbu	a0,0(a5) # 10000000 <_binary_user_init_size+0xffff658>
    80000e9a:	6422                	ld	s0,8(sp)
    80000e9c:	0141                	addi	sp,sp,16
    80000e9e:	8082                	ret
    80000ea0:	557d                	li	a0,-1
    80000ea2:	bfe5                	j	80000e9a <uartgetc+0x1a>

0000000080000ea4 <uartintr>:
    80000ea4:	1101                	addi	sp,sp,-32
    80000ea6:	ec06                	sd	ra,24(sp)
    80000ea8:	e822                	sd	s0,16(sp)
    80000eaa:	e426                	sd	s1,8(sp)
    80000eac:	1000                	addi	s0,sp,32
    80000eae:	54fd                	li	s1,-1
    80000eb0:	00000097          	auipc	ra,0x0
    80000eb4:	fd0080e7          	jalr	-48(ra) # 80000e80 <uartgetc>
    80000eb8:	fe951ce3          	bne	a0,s1,80000eb0 <uartintr+0xc>
    80000ebc:	00000097          	auipc	ra,0x0
    80000ec0:	f0c080e7          	jalr	-244(ra) # 80000dc8 <uartstart>
    80000ec4:	60e2                	ld	ra,24(sp)
    80000ec6:	6442                	ld	s0,16(sp)
    80000ec8:	64a2                	ld	s1,8(sp)
    80000eca:	6105                	addi	sp,sp,32
    80000ecc:	8082                	ret

0000000080000ece <port_init>:
    80000ece:	1141                	addi	sp,sp,-16
    80000ed0:	e422                	sd	s0,8(sp)
    80000ed2:	0800                	addi	s0,sp,16
    80000ed4:	00008797          	auipc	a5,0x8
    80000ed8:	b0478793          	addi	a5,a5,-1276 # 800089d8 <ports+0x400>
    80000edc:	4701                	li	a4,0
    80000ede:	4589                	li	a1,2
    80000ee0:	10000613          	li	a2,256
    80000ee4:	00e5a6b3          	slt	a3,a1,a4
    80000ee8:	c394                	sw	a3,0(a5)
    80000eea:	0007a223          	sw	zero,4(a5)
    80000eee:	0007a423          	sw	zero,8(a5)
    80000ef2:	0007a623          	sw	zero,12(a5)
    80000ef6:	0007a823          	sw	zero,16(a5)
    80000efa:	2705                	addiw	a4,a4,1
    80000efc:	41478793          	addi	a5,a5,1044
    80000f00:	fec712e3          	bne	a4,a2,80000ee4 <port_init+0x16>
    80000f04:	6422                	ld	s0,8(sp)
    80000f06:	0141                	addi	sp,sp,16
    80000f08:	8082                	ret

0000000080000f0a <port_close>:
    80000f0a:	1141                	addi	sp,sp,-16
    80000f0c:	e422                	sd	s0,8(sp)
    80000f0e:	0800                	addi	s0,sp,16
    80000f10:	41400793          	li	a5,1044
    80000f14:	02f50533          	mul	a0,a0,a5
    80000f18:	00007797          	auipc	a5,0x7
    80000f1c:	6c078793          	addi	a5,a5,1728 # 800085d8 <ports>
    80000f20:	97aa                	add	a5,a5,a0
    80000f22:	4705                	li	a4,1
    80000f24:	40e7a023          	sw	a4,1024(a5)
    80000f28:	4007a223          	sw	zero,1028(a5)
    80000f2c:	4007a423          	sw	zero,1032(a5)
    80000f30:	4007a623          	sw	zero,1036(a5)
    80000f34:	4007a823          	sw	zero,1040(a5)
    80000f38:	6422                	ld	s0,8(sp)
    80000f3a:	0141                	addi	sp,sp,16
    80000f3c:	8082                	ret

0000000080000f3e <port_acquire>:
    80000f3e:	1141                	addi	sp,sp,-16
    80000f40:	e422                	sd	s0,8(sp)
    80000f42:	0800                	addi	s0,sp,16
    80000f44:	57fd                	li	a5,-1
    80000f46:	02f50e63          	beq	a0,a5,80000f82 <port_acquire+0x44>
    80000f4a:	41400713          	li	a4,1044
    80000f4e:	02e50733          	mul	a4,a0,a4
    80000f52:	00007797          	auipc	a5,0x7
    80000f56:	68678793          	addi	a5,a5,1670 # 800085d8 <ports>
    80000f5a:	97ba                	add	a5,a5,a4
    80000f5c:	4007a783          	lw	a5,1024(a5)
    80000f60:	c3a1                	beqz	a5,80000fa0 <port_acquire+0x62>
    80000f62:	41400713          	li	a4,1044
    80000f66:	02e50733          	mul	a4,a0,a4
    80000f6a:	00007797          	auipc	a5,0x7
    80000f6e:	66e78793          	addi	a5,a5,1646 # 800085d8 <ports>
    80000f72:	97ba                	add	a5,a5,a4
    80000f74:	4007a023          	sw	zero,1024(a5)
    80000f78:	40b7a823          	sw	a1,1040(a5)
    80000f7c:	6422                	ld	s0,8(sp)
    80000f7e:	0141                	addi	sp,sp,16
    80000f80:	8082                	ret
    80000f82:	00008797          	auipc	a5,0x8
    80000f86:	a5678793          	addi	a5,a5,-1450 # 800089d8 <ports+0x400>
    80000f8a:	4501                	li	a0,0
    80000f8c:	10000693          	li	a3,256
    80000f90:	4398                	lw	a4,0(a5)
    80000f92:	fb61                	bnez	a4,80000f62 <port_acquire+0x24>
    80000f94:	2505                	addiw	a0,a0,1
    80000f96:	41478793          	addi	a5,a5,1044
    80000f9a:	fed51be3          	bne	a0,a3,80000f90 <port_acquire+0x52>
    80000f9e:	b775                	j	80000f4a <port_acquire+0xc>
    80000fa0:	557d                	li	a0,-1
    80000fa2:	bfe9                	j	80000f7c <port_acquire+0x3e>

0000000080000fa4 <port_write>:
    80000fa4:	1141                	addi	sp,sp,-16
    80000fa6:	e422                	sd	s0,8(sp)
    80000fa8:	0800                	addi	s0,sp,16
    80000faa:	41400693          	li	a3,1044
    80000fae:	02d506b3          	mul	a3,a0,a3
    80000fb2:	00007717          	auipc	a4,0x7
    80000fb6:	62670713          	addi	a4,a4,1574 # 800085d8 <ports>
    80000fba:	9736                	add	a4,a4,a3
    80000fbc:	40072503          	lw	a0,1024(a4)
    80000fc0:	ed31                	bnez	a0,8000101c <port_write+0x78>
    80000fc2:	04c05a63          	blez	a2,80001016 <port_write+0x72>
    80000fc6:	00007717          	auipc	a4,0x7
    80000fca:	61270713          	addi	a4,a4,1554 # 800085d8 <ports>
    80000fce:	9736                	add	a4,a4,a3
    80000fd0:	3ff00313          	li	t1,1023
    80000fd4:	40c72683          	lw	a3,1036(a4)
    80000fd8:	02d34f63          	blt	t1,a3,80001016 <port_write+0x72>
    80000fdc:	2505                	addiw	a0,a0,1
    80000fde:	40872783          	lw	a5,1032(a4)
    80000fe2:	0005c883          	lbu	a7,0(a1)
    80000fe6:	00f70833          	add	a6,a4,a5
    80000fea:	01180023          	sb	a7,0(a6)
    80000fee:	2785                	addiw	a5,a5,1
    80000ff0:	41f7d81b          	sraiw	a6,a5,0x1f
    80000ff4:	0168581b          	srliw	a6,a6,0x16
    80000ff8:	010787bb          	addw	a5,a5,a6
    80000ffc:	3ff7f793          	andi	a5,a5,1023
    80001000:	410787bb          	subw	a5,a5,a6
    80001004:	40f72423          	sw	a5,1032(a4)
    80001008:	2685                	addiw	a3,a3,1
    8000100a:	40d72623          	sw	a3,1036(a4)
    8000100e:	0585                	addi	a1,a1,1
    80001010:	fca612e3          	bne	a2,a0,80000fd4 <port_write+0x30>
    80001014:	8532                	mv	a0,a2
    80001016:	6422                	ld	s0,8(sp)
    80001018:	0141                	addi	sp,sp,16
    8000101a:	8082                	ret
    8000101c:	557d                	li	a0,-1
    8000101e:	bfe5                	j	80001016 <port_write+0x72>

0000000080001020 <port_read>:
    80001020:	1141                	addi	sp,sp,-16
    80001022:	e422                	sd	s0,8(sp)
    80001024:	0800                	addi	s0,sp,16
    80001026:	41400693          	li	a3,1044
    8000102a:	02d506b3          	mul	a3,a0,a3
    8000102e:	00007717          	auipc	a4,0x7
    80001032:	5aa70713          	addi	a4,a4,1450 # 800085d8 <ports>
    80001036:	9736                	add	a4,a4,a3
    80001038:	40072503          	lw	a0,1024(a4)
    8000103c:	ed29                	bnez	a0,80001096 <port_read+0x76>
    8000103e:	04c05963          	blez	a2,80001090 <port_read+0x70>
    80001042:	00007717          	auipc	a4,0x7
    80001046:	59670713          	addi	a4,a4,1430 # 800085d8 <ports>
    8000104a:	9736                	add	a4,a4,a3
    8000104c:	40c72783          	lw	a5,1036(a4)
    80001050:	04f05063          	blez	a5,80001090 <port_read+0x70>
    80001054:	2505                	addiw	a0,a0,1
    80001056:	40472783          	lw	a5,1028(a4)
    8000105a:	97ba                	add	a5,a5,a4
    8000105c:	0007c783          	lbu	a5,0(a5)
    80001060:	00f58023          	sb	a5,0(a1)
    80001064:	40472783          	lw	a5,1028(a4)
    80001068:	2785                	addiw	a5,a5,1
    8000106a:	41f7d69b          	sraiw	a3,a5,0x1f
    8000106e:	0166d69b          	srliw	a3,a3,0x16
    80001072:	9fb5                	addw	a5,a5,a3
    80001074:	3ff7f793          	andi	a5,a5,1023
    80001078:	9f95                	subw	a5,a5,a3
    8000107a:	40f72223          	sw	a5,1028(a4)
    8000107e:	40c72783          	lw	a5,1036(a4)
    80001082:	37fd                	addiw	a5,a5,-1
    80001084:	40f72623          	sw	a5,1036(a4)
    80001088:	0585                	addi	a1,a1,1
    8000108a:	fca611e3          	bne	a2,a0,8000104c <port_read+0x2c>
    8000108e:	8532                	mv	a0,a2
    80001090:	6422                	ld	s0,8(sp)
    80001092:	0141                	addi	sp,sp,16
    80001094:	8082                	ret
    80001096:	557d                	li	a0,-1
    80001098:	bfe5                	j	80001090 <port_read+0x70>

000000008000109a <port_test>:
    8000109a:	7139                	addi	sp,sp,-64
    8000109c:	fc06                	sd	ra,56(sp)
    8000109e:	f822                	sd	s0,48(sp)
    800010a0:	f426                	sd	s1,40(sp)
    800010a2:	f04a                	sd	s2,32(sp)
    800010a4:	ec4e                	sd	s3,24(sp)
    800010a6:	e852                	sd	s4,16(sp)
    800010a8:	0080                	addi	s0,sp,64
    800010aa:	00002517          	auipc	a0,0x2
    800010ae:	0ae50513          	addi	a0,a0,174 # 80003158 <digits+0x118>
    800010b2:	fffff097          	auipc	ra,0xfffff
    800010b6:	0b6080e7          	jalr	182(ra) # 80000168 <printf>
    800010ba:	00007717          	auipc	a4,0x7
    800010be:	51e70713          	addi	a4,a4,1310 # 800085d8 <ports>
    800010c2:	41072783          	lw	a5,1040(a4)
    800010c6:	40072703          	lw	a4,1024(a4)
    800010ca:	8fd9                	or	a5,a5,a4
    800010cc:	4501                	li	a0,0
    800010ce:	eb95                	bnez	a5,80001102 <port_test+0x68>
    800010d0:	00008517          	auipc	a0,0x8
    800010d4:	d1c52503          	lw	a0,-740(a0) # 80008dec <ports+0x814>
    800010d8:	e945                	bnez	a0,80001188 <port_test+0xee>
    800010da:	00008797          	auipc	a5,0x8
    800010de:	d227a783          	lw	a5,-734(a5) # 80008dfc <ports+0x824>
    800010e2:	e385                	bnez	a5,80001102 <port_test+0x68>
    800010e4:	00008797          	auipc	a5,0x8
    800010e8:	53078793          	addi	a5,a5,1328 # 80009614 <ports+0x103c>
    800010ec:	00049717          	auipc	a4,0x49
    800010f0:	cec70713          	addi	a4,a4,-788 # 80049dd8 <end+0x400>
    800010f4:	a029                	j	800010fe <port_test+0x64>
    800010f6:	41478793          	addi	a5,a5,1044
    800010fa:	06e78463          	beq	a5,a4,80001162 <port_test+0xc8>
    800010fe:	4388                	lw	a0,0(a5)
    80001100:	f97d                	bnez	a0,800010f6 <port_test+0x5c>
    80001102:	fffff097          	auipc	ra,0xfffff
    80001106:	212080e7          	jalr	530(ra) # 80000314 <print_pass>
    8000110a:	00002517          	auipc	a0,0x2
    8000110e:	06650513          	addi	a0,a0,102 # 80003170 <digits+0x130>
    80001112:	fffff097          	auipc	ra,0xfffff
    80001116:	056080e7          	jalr	86(ra) # 80000168 <printf>
    8000111a:	460d                	li	a2,3
    8000111c:	00002597          	auipc	a1,0x2
    80001120:	06c58593          	addi	a1,a1,108 # 80003188 <digits+0x148>
    80001124:	4501                	li	a0,0
    80001126:	00000097          	auipc	ra,0x0
    8000112a:	e7e080e7          	jalr	-386(ra) # 80000fa4 <port_write>
    8000112e:	8a2a                	mv	s4,a0
    80001130:	460d                	li	a2,3
    80001132:	00002597          	auipc	a1,0x2
    80001136:	05658593          	addi	a1,a1,86 # 80003188 <digits+0x148>
    8000113a:	453d                	li	a0,15
    8000113c:	00000097          	auipc	ra,0x0
    80001140:	e68080e7          	jalr	-408(ra) # 80000fa4 <port_write>
    80001144:	57fd                	li	a5,-1
    80001146:	4481                	li	s1,0
    80001148:	06f51163          	bne	a0,a5,800011aa <port_test+0x110>
    8000114c:	478d                	li	a5,3
    8000114e:	40000913          	li	s2,1024
    80001152:	00002997          	auipc	s3,0x2
    80001156:	03e98993          	addi	s3,s3,62 # 80003190 <digits+0x150>
    8000115a:	4481                	li	s1,0
    8000115c:	02fa0b63          	beq	s4,a5,80001192 <port_test+0xf8>
    80001160:	a0a9                	j	800011aa <port_test+0x110>
    80001162:	00008797          	auipc	a5,0x8
    80001166:	87a78793          	addi	a5,a5,-1926 # 800089dc <ports+0x404>
    8000116a:	00007717          	auipc	a4,0x7
    8000116e:	46e70713          	addi	a4,a4,1134 # 800085d8 <ports>
    80001172:	000426b7          	lui	a3,0x42
    80001176:	80468693          	addi	a3,a3,-2044 # 41804 <_binary_user_init_size+0x40e5c>
    8000117a:	9736                	add	a4,a4,a3
    8000117c:	41478793          	addi	a5,a5,1044
    80001180:	fef71ee3          	bne	a4,a5,8000117c <port_test+0xe2>
    80001184:	4505                	li	a0,1
    80001186:	bfb5                	j	80001102 <port_test+0x68>
    80001188:	4501                	li	a0,0
    8000118a:	bfa5                	j	80001102 <port_test+0x68>
    8000118c:	397d                	addiw	s2,s2,-1
    8000118e:	00090e63          	beqz	s2,800011aa <port_test+0x110>
    80001192:	4605                	li	a2,1
    80001194:	85ce                	mv	a1,s3
    80001196:	4505                	li	a0,1
    80001198:	00000097          	auipc	ra,0x0
    8000119c:	e0c080e7          	jalr	-500(ra) # 80000fa4 <port_write>
    800011a0:	84aa                	mv	s1,a0
    800011a2:	4785                	li	a5,1
    800011a4:	fef504e3          	beq	a0,a5,8000118c <port_test+0xf2>
    800011a8:	4481                	li	s1,0
    800011aa:	4605                	li	a2,1
    800011ac:	00002597          	auipc	a1,0x2
    800011b0:	fe458593          	addi	a1,a1,-28 # 80003190 <digits+0x150>
    800011b4:	4505                	li	a0,1
    800011b6:	00000097          	auipc	ra,0x0
    800011ba:	dee080e7          	jalr	-530(ra) # 80000fa4 <port_write>
    800011be:	00153513          	seqz	a0,a0
    800011c2:	40a00533          	neg	a0,a0
    800011c6:	8d65                	and	a0,a0,s1
    800011c8:	fffff097          	auipc	ra,0xfffff
    800011cc:	14c080e7          	jalr	332(ra) # 80000314 <print_pass>
    800011d0:	00002517          	auipc	a0,0x2
    800011d4:	fc850513          	addi	a0,a0,-56 # 80003198 <digits+0x158>
    800011d8:	fffff097          	auipc	ra,0xfffff
    800011dc:	f90080e7          	jalr	-112(ra) # 80000168 <printf>
    800011e0:	460d                	li	a2,3
    800011e2:	fc040593          	addi	a1,s0,-64
    800011e6:	4501                	li	a0,0
    800011e8:	00000097          	auipc	ra,0x0
    800011ec:	e38080e7          	jalr	-456(ra) # 80001020 <port_read>
    800011f0:	fc044703          	lbu	a4,-64(s0)
    800011f4:	06100793          	li	a5,97
    800011f8:	4481                	li	s1,0
    800011fa:	0ef70c63          	beq	a4,a5,800012f2 <port_test+0x258>
    800011fe:	460d                	li	a2,3
    80001200:	fc040593          	addi	a1,s0,-64
    80001204:	4501                	li	a0,0
    80001206:	00000097          	auipc	ra,0x0
    8000120a:	e1a080e7          	jalr	-486(ra) # 80001020 <port_read>
    8000120e:	00153513          	seqz	a0,a0
    80001212:	40a00533          	neg	a0,a0
    80001216:	8ce9                	and	s1,s1,a0
    80001218:	460d                	li	a2,3
    8000121a:	00002597          	auipc	a1,0x2
    8000121e:	f6e58593          	addi	a1,a1,-146 # 80003188 <digits+0x148>
    80001222:	453d                	li	a0,15
    80001224:	00000097          	auipc	ra,0x0
    80001228:	dfc080e7          	jalr	-516(ra) # 80001020 <port_read>
    8000122c:	57fd                	li	a5,-1
    8000122e:	00f50363          	beq	a0,a5,80001234 <port_test+0x19a>
    80001232:	4481                	li	s1,0
    80001234:	8526                	mv	a0,s1
    80001236:	fffff097          	auipc	ra,0xfffff
    8000123a:	0de080e7          	jalr	222(ra) # 80000314 <print_pass>
    8000123e:	00002517          	auipc	a0,0x2
    80001242:	f7250513          	addi	a0,a0,-142 # 800031b0 <digits+0x170>
    80001246:	fffff097          	auipc	ra,0xfffff
    8000124a:	f22080e7          	jalr	-222(ra) # 80000168 <printf>
    8000124e:	02a00593          	li	a1,42
    80001252:	557d                	li	a0,-1
    80001254:	00000097          	auipc	ra,0x0
    80001258:	cea080e7          	jalr	-790(ra) # 80000f3e <port_acquire>
    8000125c:	00008717          	auipc	a4,0x8
    80001260:	3c872703          	lw	a4,968(a4) # 80009624 <ports+0x104c>
    80001264:	02a00793          	li	a5,42
    80001268:	4481                	li	s1,0
    8000126a:	0af70463          	beq	a4,a5,80001312 <port_test+0x278>
    8000126e:	4581                	li	a1,0
    80001270:	4505                	li	a0,1
    80001272:	00000097          	auipc	ra,0x0
    80001276:	ccc080e7          	jalr	-820(ra) # 80000f3e <port_acquire>
    8000127a:	57fd                	li	a5,-1
    8000127c:	00f50363          	beq	a0,a5,80001282 <port_test+0x1e8>
    80001280:	4481                	li	s1,0
    80001282:	45bd                	li	a1,15
    80001284:	0ff00513          	li	a0,255
    80001288:	00000097          	auipc	ra,0x0
    8000128c:	cb6080e7          	jalr	-842(ra) # 80000f3e <port_acquire>
    80001290:	0ff00793          	li	a5,255
    80001294:	00f50363          	beq	a0,a5,8000129a <port_test+0x200>
    80001298:	4481                	li	s1,0
    8000129a:	00048717          	auipc	a4,0x48
    8000129e:	73a72703          	lw	a4,1850(a4) # 800499d4 <ports+0x413fc>
    800012a2:	47bd                	li	a5,15
    800012a4:	08f70063          	beq	a4,a5,80001324 <port_test+0x28a>
    800012a8:	4481                	li	s1,0
    800012aa:	450d                	li	a0,3
    800012ac:	00000097          	auipc	ra,0x0
    800012b0:	c5e080e7          	jalr	-930(ra) # 80000f0a <port_close>
    800012b4:	00008517          	auipc	a0,0x8
    800012b8:	36052503          	lw	a0,864(a0) # 80009614 <ports+0x103c>
    800012bc:	cd19                	beqz	a0,800012da <port_test+0x240>
    800012be:	00008797          	auipc	a5,0x8
    800012c2:	31a78793          	addi	a5,a5,794 # 800095d8 <ports+0x1000>
    800012c6:	43a8                	lw	a0,64(a5)
    800012c8:	47b8                	lw	a4,72(a5)
    800012ca:	8d59                	or	a0,a0,a4
    800012cc:	47fc                	lw	a5,76(a5)
    800012ce:	8d5d                	or	a0,a0,a5
    800012d0:	00153513          	seqz	a0,a0
    800012d4:	40a00533          	neg	a0,a0
    800012d8:	8d65                	and	a0,a0,s1
    800012da:	fffff097          	auipc	ra,0xfffff
    800012de:	03a080e7          	jalr	58(ra) # 80000314 <print_pass>
    800012e2:	70e2                	ld	ra,56(sp)
    800012e4:	7442                	ld	s0,48(sp)
    800012e6:	74a2                	ld	s1,40(sp)
    800012e8:	7902                	ld	s2,32(sp)
    800012ea:	69e2                	ld	s3,24(sp)
    800012ec:	6a42                	ld	s4,16(sp)
    800012ee:	6121                	addi	sp,sp,64
    800012f0:	8082                	ret
    800012f2:	fc144703          	lbu	a4,-63(s0)
    800012f6:	06200793          	li	a5,98
    800012fa:	f0f712e3          	bne	a4,a5,800011fe <port_test+0x164>
    800012fe:	fc244703          	lbu	a4,-62(s0)
    80001302:	06300793          	li	a5,99
    80001306:	eef71ce3          	bne	a4,a5,800011fe <port_test+0x164>
    8000130a:	1575                	addi	a0,a0,-3
    8000130c:	00153493          	seqz	s1,a0
    80001310:	b5fd                	j	800011fe <port_test+0x164>
    80001312:	00008797          	auipc	a5,0x8
    80001316:	3027a783          	lw	a5,770(a5) # 80009614 <ports+0x103c>
    8000131a:	fbb1                	bnez	a5,8000126e <port_test+0x1d4>
    8000131c:	1575                	addi	a0,a0,-3
    8000131e:	00153493          	seqz	s1,a0
    80001322:	b7b1                	j	8000126e <port_test+0x1d4>
    80001324:	00048797          	auipc	a5,0x48
    80001328:	6a07a783          	lw	a5,1696(a5) # 800499c4 <ports+0x413ec>
    8000132c:	0017b793          	seqz	a5,a5
    80001330:	40f007b3          	neg	a5,a5
    80001334:	8cfd                	and	s1,s1,a5
    80001336:	bf95                	j	800012aa <port_test+0x210>

0000000080001338 <vm_page_alloc>:
    80001338:	1101                	addi	sp,sp,-32
    8000133a:	ec06                	sd	ra,24(sp)
    8000133c:	e822                	sd	s0,16(sp)
    8000133e:	e426                	sd	s1,8(sp)
    80001340:	1000                	addi	s0,sp,32
    80001342:	00003497          	auipc	s1,0x3
    80001346:	9be4b483          	ld	s1,-1602(s1) # 80003d00 <frame_table>
    8000134a:	cc89                	beqz	s1,80001364 <vm_page_alloc+0x2c>
    8000134c:	609c                	ld	a5,0(s1)
    8000134e:	00003717          	auipc	a4,0x3
    80001352:	9af73923          	sd	a5,-1614(a4) # 80003d00 <frame_table>
    80001356:	6605                	lui	a2,0x1
    80001358:	4595                	li	a1,5
    8000135a:	8526                	mv	a0,s1
    8000135c:	fffff097          	auipc	ra,0xfffff
    80001360:	fea080e7          	jalr	-22(ra) # 80000346 <memset>
    80001364:	8526                	mv	a0,s1
    80001366:	60e2                	ld	ra,24(sp)
    80001368:	6442                	ld	s0,16(sp)
    8000136a:	64a2                	ld	s1,8(sp)
    8000136c:	6105                	addi	sp,sp,32
    8000136e:	8082                	ret

0000000080001370 <walk_pgtable>:
    80001370:	7139                	addi	sp,sp,-64
    80001372:	fc06                	sd	ra,56(sp)
    80001374:	f822                	sd	s0,48(sp)
    80001376:	f426                	sd	s1,40(sp)
    80001378:	f04a                	sd	s2,32(sp)
    8000137a:	ec4e                	sd	s3,24(sp)
    8000137c:	e852                	sd	s4,16(sp)
    8000137e:	e456                	sd	s5,8(sp)
    80001380:	e05a                	sd	s6,0(sp)
    80001382:	0080                	addi	s0,sp,64
    80001384:	84aa                	mv	s1,a0
    80001386:	89ae                	mv	s3,a1
    80001388:	8ab2                	mv	s5,a2
    8000138a:	57fd                	li	a5,-1
    8000138c:	83e9                	srli	a5,a5,0x1a
    8000138e:	4a79                	li	s4,30
    80001390:	4b31                	li	s6,12
    80001392:	04b7f263          	bgeu	a5,a1,800013d6 <walk_pgtable+0x66>
    80001396:	00002517          	auipc	a0,0x2
    8000139a:	e9a50513          	addi	a0,a0,-358 # 80003230 <digits+0x1f0>
    8000139e:	fffff097          	auipc	ra,0xfffff
    800013a2:	d88080e7          	jalr	-632(ra) # 80000126 <panic>
    800013a6:	060a8663          	beqz	s5,80001412 <walk_pgtable+0xa2>
    800013aa:	00000097          	auipc	ra,0x0
    800013ae:	f8e080e7          	jalr	-114(ra) # 80001338 <vm_page_alloc>
    800013b2:	84aa                	mv	s1,a0
    800013b4:	c529                	beqz	a0,800013fe <walk_pgtable+0x8e>
    800013b6:	6605                	lui	a2,0x1
    800013b8:	4581                	li	a1,0
    800013ba:	fffff097          	auipc	ra,0xfffff
    800013be:	f8c080e7          	jalr	-116(ra) # 80000346 <memset>
    800013c2:	00c4d793          	srli	a5,s1,0xc
    800013c6:	07aa                	slli	a5,a5,0xa
    800013c8:	0017e793          	ori	a5,a5,1
    800013cc:	00f93023          	sd	a5,0(s2)
    800013d0:	3a5d                	addiw	s4,s4,-9
    800013d2:	036a0063          	beq	s4,s6,800013f2 <walk_pgtable+0x82>
    800013d6:	0149d933          	srl	s2,s3,s4
    800013da:	1ff97913          	andi	s2,s2,511
    800013de:	090e                	slli	s2,s2,0x3
    800013e0:	9926                	add	s2,s2,s1
    800013e2:	00093483          	ld	s1,0(s2)
    800013e6:	0014f793          	andi	a5,s1,1
    800013ea:	dfd5                	beqz	a5,800013a6 <walk_pgtable+0x36>
    800013ec:	80a9                	srli	s1,s1,0xa
    800013ee:	04b2                	slli	s1,s1,0xc
    800013f0:	b7c5                	j	800013d0 <walk_pgtable+0x60>
    800013f2:	00c9d513          	srli	a0,s3,0xc
    800013f6:	1ff57513          	andi	a0,a0,511
    800013fa:	050e                	slli	a0,a0,0x3
    800013fc:	9526                	add	a0,a0,s1
    800013fe:	70e2                	ld	ra,56(sp)
    80001400:	7442                	ld	s0,48(sp)
    80001402:	74a2                	ld	s1,40(sp)
    80001404:	7902                	ld	s2,32(sp)
    80001406:	69e2                	ld	s3,24(sp)
    80001408:	6a42                	ld	s4,16(sp)
    8000140a:	6aa2                	ld	s5,8(sp)
    8000140c:	6b02                	ld	s6,0(sp)
    8000140e:	6121                	addi	sp,sp,64
    80001410:	8082                	ret
    80001412:	4501                	li	a0,0
    80001414:	b7ed                	j	800013fe <walk_pgtable+0x8e>

0000000080001416 <kernel_map_pages>:
    80001416:	715d                	addi	sp,sp,-80
    80001418:	e486                	sd	ra,72(sp)
    8000141a:	e0a2                	sd	s0,64(sp)
    8000141c:	fc26                	sd	s1,56(sp)
    8000141e:	f84a                	sd	s2,48(sp)
    80001420:	f44e                	sd	s3,40(sp)
    80001422:	f052                	sd	s4,32(sp)
    80001424:	ec56                	sd	s5,24(sp)
    80001426:	e85a                	sd	s6,16(sp)
    80001428:	e45e                	sd	s7,8(sp)
    8000142a:	0880                	addi	s0,sp,80
    8000142c:	8aaa                	mv	s5,a0
    8000142e:	8b3a                	mv	s6,a4
    80001430:	777d                	lui	a4,0xfffff
    80001432:	00e5f7b3          	and	a5,a1,a4
    80001436:	fff68993          	addi	s3,a3,-1
    8000143a:	99ae                	add	s3,s3,a1
    8000143c:	00e9f9b3          	and	s3,s3,a4
    80001440:	893e                	mv	s2,a5
    80001442:	40f60a33          	sub	s4,a2,a5
    80001446:	6b85                	lui	s7,0x1
    80001448:	a811                	j	8000145c <kernel_map_pages+0x46>
    8000144a:	00002517          	auipc	a0,0x2
    8000144e:	d8650513          	addi	a0,a0,-634 # 800031d0 <digits+0x190>
    80001452:	fffff097          	auipc	ra,0xfffff
    80001456:	cd4080e7          	jalr	-812(ra) # 80000126 <panic>
    8000145a:	995e                	add	s2,s2,s7
    8000145c:	012a04b3          	add	s1,s4,s2
    80001460:	4605                	li	a2,1
    80001462:	85ca                	mv	a1,s2
    80001464:	8556                	mv	a0,s5
    80001466:	00000097          	auipc	ra,0x0
    8000146a:	f0a080e7          	jalr	-246(ra) # 80001370 <walk_pgtable>
    8000146e:	c905                	beqz	a0,8000149e <kernel_map_pages+0x88>
    80001470:	611c                	ld	a5,0(a0)
    80001472:	8b85                	andi	a5,a5,1
    80001474:	fbf9                	bnez	a5,8000144a <kernel_map_pages+0x34>
    80001476:	80b1                	srli	s1,s1,0xc
    80001478:	04aa                	slli	s1,s1,0xa
    8000147a:	0164e4b3          	or	s1,s1,s6
    8000147e:	0014e493          	ori	s1,s1,1
    80001482:	e104                	sd	s1,0(a0)
    80001484:	fd299be3          	bne	s3,s2,8000145a <kernel_map_pages+0x44>
    80001488:	60a6                	ld	ra,72(sp)
    8000148a:	6406                	ld	s0,64(sp)
    8000148c:	74e2                	ld	s1,56(sp)
    8000148e:	7942                	ld	s2,48(sp)
    80001490:	79a2                	ld	s3,40(sp)
    80001492:	7a02                	ld	s4,32(sp)
    80001494:	6ae2                	ld	s5,24(sp)
    80001496:	6b42                	ld	s6,16(sp)
    80001498:	6ba2                	ld	s7,8(sp)
    8000149a:	6161                	addi	sp,sp,80
    8000149c:	8082                	ret
    8000149e:	00002517          	auipc	a0,0x2
    800014a2:	d3a50513          	addi	a0,a0,-710 # 800031d8 <digits+0x198>
    800014a6:	fffff097          	auipc	ra,0xfffff
    800014aa:	c80080e7          	jalr	-896(ra) # 80000126 <panic>

00000000800014ae <vm_page_free>:
    800014ae:	03451793          	slli	a5,a0,0x34
    800014b2:	e39d                	bnez	a5,800014d8 <vm_page_free+0x2a>
    800014b4:	00048797          	auipc	a5,0x48
    800014b8:	52478793          	addi	a5,a5,1316 # 800499d8 <end>
    800014bc:	00f56e63          	bltu	a0,a5,800014d8 <vm_page_free+0x2a>
    800014c0:	47c5                	li	a5,17
    800014c2:	07ee                	slli	a5,a5,0x1b
    800014c4:	00f57a63          	bgeu	a0,a5,800014d8 <vm_page_free+0x2a>
    800014c8:	00003797          	auipc	a5,0x3
    800014cc:	83878793          	addi	a5,a5,-1992 # 80003d00 <frame_table>
    800014d0:	6398                	ld	a4,0(a5)
    800014d2:	e118                	sd	a4,0(a0)
    800014d4:	e388                	sd	a0,0(a5)
    800014d6:	8082                	ret
    800014d8:	1141                	addi	sp,sp,-16
    800014da:	e406                	sd	ra,8(sp)
    800014dc:	e022                	sd	s0,0(sp)
    800014de:	0800                	addi	s0,sp,16
    800014e0:	00002517          	auipc	a0,0x2
    800014e4:	d1050513          	addi	a0,a0,-752 # 800031f0 <digits+0x1b0>
    800014e8:	fffff097          	auipc	ra,0xfffff
    800014ec:	c3e080e7          	jalr	-962(ra) # 80000126 <panic>

00000000800014f0 <vm_init>:
    800014f0:	7179                	addi	sp,sp,-48
    800014f2:	f406                	sd	ra,40(sp)
    800014f4:	f022                	sd	s0,32(sp)
    800014f6:	ec26                	sd	s1,24(sp)
    800014f8:	e84a                	sd	s2,16(sp)
    800014fa:	e44e                	sd	s3,8(sp)
    800014fc:	1800                	addi	s0,sp,48
    800014fe:	00049497          	auipc	s1,0x49
    80001502:	4d948493          	addi	s1,s1,1241 # 8004a9d7 <end+0xfff>
    80001506:	77fd                	lui	a5,0xfffff
    80001508:	8cfd                	and	s1,s1,a5
    8000150a:	6705                	lui	a4,0x1
    8000150c:	9726                	add	a4,a4,s1
    8000150e:	47c5                	li	a5,17
    80001510:	07ee                	slli	a5,a5,0x1b
    80001512:	00e7ec63          	bltu	a5,a4,8000152a <vm_init+0x3a>
    80001516:	6985                	lui	s3,0x1
    80001518:	893e                	mv	s2,a5
    8000151a:	8526                	mv	a0,s1
    8000151c:	00000097          	auipc	ra,0x0
    80001520:	f92080e7          	jalr	-110(ra) # 800014ae <vm_page_free>
    80001524:	94ce                	add	s1,s1,s3
    80001526:	ff249ae3          	bne	s1,s2,8000151a <vm_init+0x2a>
    8000152a:	00000097          	auipc	ra,0x0
    8000152e:	e0e080e7          	jalr	-498(ra) # 80001338 <vm_page_alloc>
    80001532:	84aa                	mv	s1,a0
    80001534:	6605                	lui	a2,0x1
    80001536:	4581                	li	a1,0
    80001538:	fffff097          	auipc	ra,0xfffff
    8000153c:	e0e080e7          	jalr	-498(ra) # 80000346 <memset>
    80001540:	4719                	li	a4,6
    80001542:	6685                	lui	a3,0x1
    80001544:	10000637          	lui	a2,0x10000
    80001548:	100005b7          	lui	a1,0x10000
    8000154c:	8526                	mv	a0,s1
    8000154e:	00000097          	auipc	ra,0x0
    80001552:	ec8080e7          	jalr	-312(ra) # 80001416 <kernel_map_pages>
    80001556:	4719                	li	a4,6
    80001558:	6685                	lui	a3,0x1
    8000155a:	10001637          	lui	a2,0x10001
    8000155e:	100015b7          	lui	a1,0x10001
    80001562:	8526                	mv	a0,s1
    80001564:	00000097          	auipc	ra,0x0
    80001568:	eb2080e7          	jalr	-334(ra) # 80001416 <kernel_map_pages>
    8000156c:	4719                	li	a4,6
    8000156e:	004006b7          	lui	a3,0x400
    80001572:	0c000637          	lui	a2,0xc000
    80001576:	0c0005b7          	lui	a1,0xc000
    8000157a:	8526                	mv	a0,s1
    8000157c:	00000097          	auipc	ra,0x0
    80001580:	e9a080e7          	jalr	-358(ra) # 80001416 <kernel_map_pages>
    80001584:	4729                	li	a4,10
    80001586:	80002697          	auipc	a3,0x80002
    8000158a:	a7a68693          	addi	a3,a3,-1414 # 3000 <_binary_user_init_size+0x2658>
    8000158e:	4605                	li	a2,1
    80001590:	067e                	slli	a2,a2,0x1f
    80001592:	85b2                	mv	a1,a2
    80001594:	8526                	mv	a0,s1
    80001596:	00000097          	auipc	ra,0x0
    8000159a:	e80080e7          	jalr	-384(ra) # 80001416 <kernel_map_pages>
    8000159e:	00003597          	auipc	a1,0x3
    800015a2:	a6158593          	addi	a1,a1,-1439 # 80003fff <stack0+0x2bf>
    800015a6:	77fd                	lui	a5,0xfffff
    800015a8:	8dfd                	and	a1,a1,a5
    800015aa:	4719                	li	a4,6
    800015ac:	46c5                	li	a3,17
    800015ae:	06ee                	slli	a3,a3,0x1b
    800015b0:	8e8d                	sub	a3,a3,a1
    800015b2:	862e                	mv	a2,a1
    800015b4:	8526                	mv	a0,s1
    800015b6:	00000097          	auipc	ra,0x0
    800015ba:	e60080e7          	jalr	-416(ra) # 80001416 <kernel_map_pages>
    800015be:	4729                	li	a4,10
    800015c0:	6685                	lui	a3,0x1
    800015c2:	00001617          	auipc	a2,0x1
    800015c6:	a3e60613          	addi	a2,a2,-1474 # 80002000 <_trampoline>
    800015ca:	040005b7          	lui	a1,0x4000
    800015ce:	15fd                	addi	a1,a1,-1
    800015d0:	05b2                	slli	a1,a1,0xc
    800015d2:	8526                	mv	a0,s1
    800015d4:	00000097          	auipc	ra,0x0
    800015d8:	e42080e7          	jalr	-446(ra) # 80001416 <kernel_map_pages>
    800015dc:	00002797          	auipc	a5,0x2
    800015e0:	7097be23          	sd	s1,1820(a5) # 80003cf8 <kernel_pagetable>
    800015e4:	80b1                	srli	s1,s1,0xc
    800015e6:	57fd                	li	a5,-1
    800015e8:	17fe                	slli	a5,a5,0x3f
    800015ea:	8cdd                	or	s1,s1,a5
    800015ec:	18049073          	csrw	satp,s1
    800015f0:	12000073          	sfence.vma
    800015f4:	70a2                	ld	ra,40(sp)
    800015f6:	7402                	ld	s0,32(sp)
    800015f8:	64e2                	ld	s1,24(sp)
    800015fa:	6942                	ld	s2,16(sp)
    800015fc:	69a2                	ld	s3,8(sp)
    800015fe:	6145                	addi	sp,sp,48
    80001600:	8082                	ret

0000000080001602 <vm_create_pagetable>:
    80001602:	1101                	addi	sp,sp,-32
    80001604:	ec06                	sd	ra,24(sp)
    80001606:	e822                	sd	s0,16(sp)
    80001608:	e426                	sd	s1,8(sp)
    8000160a:	1000                	addi	s0,sp,32
    8000160c:	00000097          	auipc	ra,0x0
    80001610:	d2c080e7          	jalr	-724(ra) # 80001338 <vm_page_alloc>
    80001614:	84aa                	mv	s1,a0
    80001616:	c519                	beqz	a0,80001624 <vm_create_pagetable+0x22>
    80001618:	6605                	lui	a2,0x1
    8000161a:	4581                	li	a1,0
    8000161c:	fffff097          	auipc	ra,0xfffff
    80001620:	d2a080e7          	jalr	-726(ra) # 80000346 <memset>
    80001624:	8526                	mv	a0,s1
    80001626:	60e2                	ld	ra,24(sp)
    80001628:	6442                	ld	s0,16(sp)
    8000162a:	64a2                	ld	s1,8(sp)
    8000162c:	6105                	addi	sp,sp,32
    8000162e:	8082                	ret

0000000080001630 <vm_lookup>:
    80001630:	57fd                	li	a5,-1
    80001632:	83e9                	srli	a5,a5,0x1a
    80001634:	00b7f463          	bgeu	a5,a1,8000163c <vm_lookup+0xc>
    80001638:	4501                	li	a0,0
    8000163a:	8082                	ret
    8000163c:	1141                	addi	sp,sp,-16
    8000163e:	e406                	sd	ra,8(sp)
    80001640:	e022                	sd	s0,0(sp)
    80001642:	0800                	addi	s0,sp,16
    80001644:	4601                	li	a2,0
    80001646:	00000097          	auipc	ra,0x0
    8000164a:	d2a080e7          	jalr	-726(ra) # 80001370 <walk_pgtable>
    8000164e:	cd01                	beqz	a0,80001666 <vm_lookup+0x36>
    80001650:	611c                	ld	a5,0(a0)
    80001652:	0017f513          	andi	a0,a5,1
    80001656:	c501                	beqz	a0,8000165e <vm_lookup+0x2e>
    80001658:	83a9                	srli	a5,a5,0xa
    8000165a:	00c79513          	slli	a0,a5,0xc
    8000165e:	60a2                	ld	ra,8(sp)
    80001660:	6402                	ld	s0,0(sp)
    80001662:	0141                	addi	sp,sp,16
    80001664:	8082                	ret
    80001666:	4501                	li	a0,0
    80001668:	bfdd                	j	8000165e <vm_lookup+0x2e>

000000008000166a <vm_page_insert>:
    8000166a:	1101                	addi	sp,sp,-32
    8000166c:	ec06                	sd	ra,24(sp)
    8000166e:	e822                	sd	s0,16(sp)
    80001670:	e426                	sd	s1,8(sp)
    80001672:	e04a                	sd	s2,0(sp)
    80001674:	1000                	addi	s0,sp,32
    80001676:	84b2                	mv	s1,a2
    80001678:	8936                	mv	s2,a3
    8000167a:	4605                	li	a2,1
    8000167c:	77fd                	lui	a5,0xfffff
    8000167e:	8dfd                	and	a1,a1,a5
    80001680:	00000097          	auipc	ra,0x0
    80001684:	cf0080e7          	jalr	-784(ra) # 80001370 <walk_pgtable>
    80001688:	c91d                	beqz	a0,800016be <vm_page_insert+0x54>
    8000168a:	611c                	ld	a5,0(a0)
    8000168c:	8b85                	andi	a5,a5,1
    8000168e:	e385                	bnez	a5,800016ae <vm_page_insert+0x44>
    80001690:	00c4d613          	srli	a2,s1,0xc
    80001694:	062a                	slli	a2,a2,0xa
    80001696:	01266633          	or	a2,a2,s2
    8000169a:	00166613          	ori	a2,a2,1
    8000169e:	e110                	sd	a2,0(a0)
    800016a0:	4501                	li	a0,0
    800016a2:	60e2                	ld	ra,24(sp)
    800016a4:	6442                	ld	s0,16(sp)
    800016a6:	64a2                	ld	s1,8(sp)
    800016a8:	6902                	ld	s2,0(sp)
    800016aa:	6105                	addi	sp,sp,32
    800016ac:	8082                	ret
    800016ae:	00002517          	auipc	a0,0x2
    800016b2:	b2250513          	addi	a0,a0,-1246 # 800031d0 <digits+0x190>
    800016b6:	fffff097          	auipc	ra,0xfffff
    800016ba:	a70080e7          	jalr	-1424(ra) # 80000126 <panic>
    800016be:	557d                	li	a0,-1
    800016c0:	b7cd                	j	800016a2 <vm_page_insert+0x38>

00000000800016c2 <vm_page_remove>:
    800016c2:	715d                	addi	sp,sp,-80
    800016c4:	e486                	sd	ra,72(sp)
    800016c6:	e0a2                	sd	s0,64(sp)
    800016c8:	fc26                	sd	s1,56(sp)
    800016ca:	f84a                	sd	s2,48(sp)
    800016cc:	f44e                	sd	s3,40(sp)
    800016ce:	f052                	sd	s4,32(sp)
    800016d0:	ec56                	sd	s5,24(sp)
    800016d2:	e85a                	sd	s6,16(sp)
    800016d4:	e45e                	sd	s7,8(sp)
    800016d6:	0880                	addi	s0,sp,80
    800016d8:	03459793          	slli	a5,a1,0x34
    800016dc:	e795                	bnez	a5,80001708 <vm_page_remove+0x46>
    800016de:	8a2a                	mv	s4,a0
    800016e0:	892e                	mv	s2,a1
    800016e2:	8ab6                	mv	s5,a3
    800016e4:	0632                	slli	a2,a2,0xc
    800016e6:	00b609b3          	add	s3,a2,a1
    800016ea:	4b85                	li	s7,1
    800016ec:	6b05                	lui	s6,0x1
    800016ee:	0735e263          	bltu	a1,s3,80001752 <vm_page_remove+0x90>
    800016f2:	60a6                	ld	ra,72(sp)
    800016f4:	6406                	ld	s0,64(sp)
    800016f6:	74e2                	ld	s1,56(sp)
    800016f8:	7942                	ld	s2,48(sp)
    800016fa:	79a2                	ld	s3,40(sp)
    800016fc:	7a02                	ld	s4,32(sp)
    800016fe:	6ae2                	ld	s5,24(sp)
    80001700:	6b42                	ld	s6,16(sp)
    80001702:	6ba2                	ld	s7,8(sp)
    80001704:	6161                	addi	sp,sp,80
    80001706:	8082                	ret
    80001708:	00002517          	auipc	a0,0x2
    8000170c:	af850513          	addi	a0,a0,-1288 # 80003200 <digits+0x1c0>
    80001710:	fffff097          	auipc	ra,0xfffff
    80001714:	a16080e7          	jalr	-1514(ra) # 80000126 <panic>
    80001718:	00002517          	auipc	a0,0x2
    8000171c:	b0850513          	addi	a0,a0,-1272 # 80003220 <digits+0x1e0>
    80001720:	fffff097          	auipc	ra,0xfffff
    80001724:	a06080e7          	jalr	-1530(ra) # 80000126 <panic>
    80001728:	00002517          	auipc	a0,0x2
    8000172c:	b1850513          	addi	a0,a0,-1256 # 80003240 <digits+0x200>
    80001730:	fffff097          	auipc	ra,0xfffff
    80001734:	9f6080e7          	jalr	-1546(ra) # 80000126 <panic>
    80001738:	00002517          	auipc	a0,0x2
    8000173c:	b2850513          	addi	a0,a0,-1240 # 80003260 <digits+0x220>
    80001740:	fffff097          	auipc	ra,0xfffff
    80001744:	9e6080e7          	jalr	-1562(ra) # 80000126 <panic>
    80001748:	0004b023          	sd	zero,0(s1)
    8000174c:	995a                	add	s2,s2,s6
    8000174e:	fb3972e3          	bgeu	s2,s3,800016f2 <vm_page_remove+0x30>
    80001752:	4601                	li	a2,0
    80001754:	85ca                	mv	a1,s2
    80001756:	8552                	mv	a0,s4
    80001758:	00000097          	auipc	ra,0x0
    8000175c:	c18080e7          	jalr	-1000(ra) # 80001370 <walk_pgtable>
    80001760:	84aa                	mv	s1,a0
    80001762:	d95d                	beqz	a0,80001718 <vm_page_remove+0x56>
    80001764:	6108                	ld	a0,0(a0)
    80001766:	00157793          	andi	a5,a0,1
    8000176a:	dfdd                	beqz	a5,80001728 <vm_page_remove+0x66>
    8000176c:	3ff57793          	andi	a5,a0,1023
    80001770:	fd7784e3          	beq	a5,s7,80001738 <vm_page_remove+0x76>
    80001774:	fc0a8ae3          	beqz	s5,80001748 <vm_page_remove+0x86>
    80001778:	8129                	srli	a0,a0,0xa
    8000177a:	0532                	slli	a0,a0,0xc
    8000177c:	00000097          	auipc	ra,0x0
    80001780:	d32080e7          	jalr	-718(ra) # 800014ae <vm_page_free>
    80001784:	b7d1                	j	80001748 <vm_page_remove+0x86>

0000000080001786 <vm_map_range>:
    80001786:	7139                	addi	sp,sp,-64
    80001788:	fc06                	sd	ra,56(sp)
    8000178a:	f822                	sd	s0,48(sp)
    8000178c:	f426                	sd	s1,40(sp)
    8000178e:	f04a                	sd	s2,32(sp)
    80001790:	ec4e                	sd	s3,24(sp)
    80001792:	e852                	sd	s4,16(sp)
    80001794:	e456                	sd	s5,8(sp)
    80001796:	0080                	addi	s0,sp,64
    80001798:	77fd                	lui	a5,0xfffff
    8000179a:	00f5f4b3          	and	s1,a1,a5
    8000179e:	fff60913          	addi	s2,a2,-1 # fff <_binary_user_init_size+0x657>
    800017a2:	992e                	add	s2,s2,a1
    800017a4:	00f97933          	and	s2,s2,a5
    800017a8:	02996463          	bltu	s2,s1,800017d0 <vm_map_range+0x4a>
    800017ac:	89aa                	mv	s3,a0
    800017ae:	8a36                	mv	s4,a3
    800017b0:	6a85                	lui	s5,0x1
    800017b2:	00000097          	auipc	ra,0x0
    800017b6:	b86080e7          	jalr	-1146(ra) # 80001338 <vm_page_alloc>
    800017ba:	862a                	mv	a2,a0
    800017bc:	86d2                	mv	a3,s4
    800017be:	85a6                	mv	a1,s1
    800017c0:	854e                	mv	a0,s3
    800017c2:	00000097          	auipc	ra,0x0
    800017c6:	ea8080e7          	jalr	-344(ra) # 8000166a <vm_page_insert>
    800017ca:	94d6                	add	s1,s1,s5
    800017cc:	fe9973e3          	bgeu	s2,s1,800017b2 <vm_map_range+0x2c>
    800017d0:	4501                	li	a0,0
    800017d2:	70e2                	ld	ra,56(sp)
    800017d4:	7442                	ld	s0,48(sp)
    800017d6:	74a2                	ld	s1,40(sp)
    800017d8:	7902                	ld	s2,32(sp)
    800017da:	69e2                	ld	s3,24(sp)
    800017dc:	6a42                	ld	s4,16(sp)
    800017de:	6aa2                	ld	s5,8(sp)
    800017e0:	6121                	addi	sp,sp,64
    800017e2:	8082                	ret

00000000800017e4 <vm_test>:
    800017e4:	7139                	addi	sp,sp,-64
    800017e6:	fc06                	sd	ra,56(sp)
    800017e8:	f822                	sd	s0,48(sp)
    800017ea:	f426                	sd	s1,40(sp)
    800017ec:	f04a                	sd	s2,32(sp)
    800017ee:	ec4e                	sd	s3,24(sp)
    800017f0:	e852                	sd	s4,16(sp)
    800017f2:	e456                	sd	s5,8(sp)
    800017f4:	e05a                	sd	s6,0(sp)
    800017f6:	0080                	addi	s0,sp,64
    800017f8:	00002517          	auipc	a0,0x2
    800017fc:	a8850513          	addi	a0,a0,-1400 # 80003280 <digits+0x240>
    80001800:	fffff097          	auipc	ra,0xfffff
    80001804:	968080e7          	jalr	-1688(ra) # 80000168 <printf>
    80001808:	00000097          	auipc	ra,0x0
    8000180c:	b30080e7          	jalr	-1232(ra) # 80001338 <vm_page_alloc>
    80001810:	84aa                	mv	s1,a0
    80001812:	00000097          	auipc	ra,0x0
    80001816:	b26080e7          	jalr	-1242(ra) # 80001338 <vm_page_alloc>
    8000181a:	892a                	mv	s2,a0
    8000181c:	00000097          	auipc	ra,0x0
    80001820:	b1c080e7          	jalr	-1252(ra) # 80001338 <vm_page_alloc>
    80001824:	89aa                	mv	s3,a0
    80001826:	4a01                	li	s4,0
    80001828:	c489                	beqz	s1,80001832 <vm_test+0x4e>
    8000182a:	00090463          	beqz	s2,80001832 <vm_test+0x4e>
    8000182e:	00a03a33          	snez	s4,a0
    80001832:	00002797          	auipc	a5,0x2
    80001836:	4ce78793          	addi	a5,a5,1230 # 80003d00 <frame_table>
    8000183a:	0007ba83          	ld	s5,0(a5)
    8000183e:	0007b023          	sd	zero,0(a5)
    80001842:	00000097          	auipc	ra,0x0
    80001846:	af6080e7          	jalr	-1290(ra) # 80001338 <vm_page_alloc>
    8000184a:	00153793          	seqz	a5,a0
    8000184e:	40f007b3          	neg	a5,a5
    80001852:	00fa7533          	and	a0,s4,a5
    80001856:	fffff097          	auipc	ra,0xfffff
    8000185a:	abe080e7          	jalr	-1346(ra) # 80000314 <print_pass>
    8000185e:	00002a17          	auipc	s4,0x2
    80001862:	4a2a0a13          	addi	s4,s4,1186 # 80003d00 <frame_table>
    80001866:	015a3023          	sd	s5,0(s4)
    8000186a:	00002517          	auipc	a0,0x2
    8000186e:	a2e50513          	addi	a0,a0,-1490 # 80003298 <digits+0x258>
    80001872:	fffff097          	auipc	ra,0xfffff
    80001876:	8f6080e7          	jalr	-1802(ra) # 80000168 <printf>
    8000187a:	854e                	mv	a0,s3
    8000187c:	00000097          	auipc	ra,0x0
    80001880:	c32080e7          	jalr	-974(ra) # 800014ae <vm_page_free>
    80001884:	000a3a83          	ld	s5,0(s4)
    80001888:	8526                	mv	a0,s1
    8000188a:	00000097          	auipc	ra,0x0
    8000188e:	c24080e7          	jalr	-988(ra) # 800014ae <vm_page_free>
    80001892:	000a3783          	ld	a5,0(s4)
    80001896:	4a01                	li	s4,0
    80001898:	0e978b63          	beq	a5,s1,8000198e <vm_test+0x1aa>
    8000189c:	854a                	mv	a0,s2
    8000189e:	00000097          	auipc	ra,0x0
    800018a2:	c10080e7          	jalr	-1008(ra) # 800014ae <vm_page_free>
    800018a6:	00002797          	auipc	a5,0x2
    800018aa:	45a7b783          	ld	a5,1114(a5) # 80003d00 <frame_table>
    800018ae:	01278363          	beq	a5,s2,800018b4 <vm_test+0xd0>
    800018b2:	4a01                	li	s4,0
    800018b4:	8552                	mv	a0,s4
    800018b6:	fffff097          	auipc	ra,0xfffff
    800018ba:	a5e080e7          	jalr	-1442(ra) # 80000314 <print_pass>
    800018be:	00002517          	auipc	a0,0x2
    800018c2:	9f250513          	addi	a0,a0,-1550 # 800032b0 <digits+0x270>
    800018c6:	fffff097          	auipc	ra,0xfffff
    800018ca:	8a2080e7          	jalr	-1886(ra) # 80000168 <printf>
    800018ce:	00002997          	auipc	s3,0x2
    800018d2:	42a98993          	addi	s3,s3,1066 # 80003cf8 <kernel_pagetable>
    800018d6:	85a6                	mv	a1,s1
    800018d8:	0009b503          	ld	a0,0(s3)
    800018dc:	00000097          	auipc	ra,0x0
    800018e0:	d54080e7          	jalr	-684(ra) # 80001630 <vm_lookup>
    800018e4:	892a                	mv	s2,a0
    800018e6:	45a5                	li	a1,9
    800018e8:	05f2                	slli	a1,a1,0x1c
    800018ea:	0009b503          	ld	a0,0(s3)
    800018ee:	00000097          	auipc	ra,0x0
    800018f2:	d42080e7          	jalr	-702(ra) # 80001630 <vm_lookup>
    800018f6:	4781                	li	a5,0
    800018f8:	e509                	bnez	a0,80001902 <vm_test+0x11e>
    800018fa:	41248533          	sub	a0,s1,s2
    800018fe:	00153793          	seqz	a5,a0
    80001902:	853e                	mv	a0,a5
    80001904:	fffff097          	auipc	ra,0xfffff
    80001908:	a10080e7          	jalr	-1520(ra) # 80000314 <print_pass>
    8000190c:	00002517          	auipc	a0,0x2
    80001910:	9bc50513          	addi	a0,a0,-1604 # 800032c8 <digits+0x288>
    80001914:	fffff097          	auipc	ra,0xfffff
    80001918:	854080e7          	jalr	-1964(ra) # 80000168 <printf>
    8000191c:	00000097          	auipc	ra,0x0
    80001920:	a1c080e7          	jalr	-1508(ra) # 80001338 <vm_page_alloc>
    80001924:	892a                	mv	s2,a0
    80001926:	00002997          	auipc	s3,0x2
    8000192a:	3da98993          	addi	s3,s3,986 # 80003d00 <frame_table>
    8000192e:	0009bb03          	ld	s6,0(s3)
    80001932:	0009b023          	sd	zero,0(s3)
    80001936:	00002a17          	auipc	s4,0x2
    8000193a:	3c2a0a13          	addi	s4,s4,962 # 80003cf8 <kernel_pagetable>
    8000193e:	4699                	li	a3,6
    80001940:	862a                	mv	a2,a0
    80001942:	4aa5                	li	s5,9
    80001944:	01ca9593          	slli	a1,s5,0x1c
    80001948:	000a3503          	ld	a0,0(s4)
    8000194c:	00000097          	auipc	ra,0x0
    80001950:	d1e080e7          	jalr	-738(ra) # 8000166a <vm_page_insert>
    80001954:	84aa                	mv	s1,a0
    80001956:	0169b023          	sd	s6,0(s3)
    8000195a:	4699                	li	a3,6
    8000195c:	864a                	mv	a2,s2
    8000195e:	01ca9593          	slli	a1,s5,0x1c
    80001962:	000a3503          	ld	a0,0(s4)
    80001966:	00000097          	auipc	ra,0x0
    8000196a:	d04080e7          	jalr	-764(ra) # 8000166a <vm_page_insert>
    8000196e:	e50d                	bnez	a0,80001998 <vm_test+0x1b4>
    80001970:	45a5                	li	a1,9
    80001972:	05f2                	slli	a1,a1,0x1c
    80001974:	00002517          	auipc	a0,0x2
    80001978:	38453503          	ld	a0,900(a0) # 80003cf8 <kernel_pagetable>
    8000197c:	00000097          	auipc	ra,0x0
    80001980:	cb4080e7          	jalr	-844(ra) # 80001630 <vm_lookup>
    80001984:	c911                	beqz	a0,80001998 <vm_test+0x1b4>
    80001986:	0485                	addi	s1,s1,1
    80001988:	0014b513          	seqz	a0,s1
    8000198c:	a839                	j	800019aa <vm_test+0x1c6>
    8000198e:	413a8ab3          	sub	s5,s5,s3
    80001992:	001aba13          	seqz	s4,s5
    80001996:	b719                	j	8000189c <vm_test+0xb8>
    80001998:	00002517          	auipc	a0,0x2
    8000199c:	94850513          	addi	a0,a0,-1720 # 800032e0 <digits+0x2a0>
    800019a0:	ffffe097          	auipc	ra,0xffffe
    800019a4:	7c8080e7          	jalr	1992(ra) # 80000168 <printf>
    800019a8:	4501                	li	a0,0
    800019aa:	44a5                	li	s1,9
    800019ac:	04f2                	slli	s1,s1,0x1c
    800019ae:	02a00793          	li	a5,42
    800019b2:	c09c                	sw	a5,0(s1)
    800019b4:	fffff097          	auipc	ra,0xfffff
    800019b8:	960080e7          	jalr	-1696(ra) # 80000314 <print_pass>
    800019bc:	00002517          	auipc	a0,0x2
    800019c0:	92c50513          	addi	a0,a0,-1748 # 800032e8 <digits+0x2a8>
    800019c4:	ffffe097          	auipc	ra,0xffffe
    800019c8:	7a4080e7          	jalr	1956(ra) # 80000168 <printf>
    800019cc:	00002997          	auipc	s3,0x2
    800019d0:	32c98993          	addi	s3,s3,812 # 80003cf8 <kernel_pagetable>
    800019d4:	4685                	li	a3,1
    800019d6:	4605                	li	a2,1
    800019d8:	85a6                	mv	a1,s1
    800019da:	0009b503          	ld	a0,0(s3)
    800019de:	00000097          	auipc	ra,0x0
    800019e2:	ce4080e7          	jalr	-796(ra) # 800016c2 <vm_page_remove>
    800019e6:	00002a97          	auipc	s5,0x2
    800019ea:	31aaba83          	ld	s5,794(s5) # 80003d00 <frame_table>
    800019ee:	85a6                	mv	a1,s1
    800019f0:	0009b503          	ld	a0,0(s3)
    800019f4:	00000097          	auipc	ra,0x0
    800019f8:	c3c080e7          	jalr	-964(ra) # 80001630 <vm_lookup>
    800019fc:	4a01                	li	s4,0
    800019fe:	e509                	bnez	a0,80001a08 <vm_test+0x224>
    80001a00:	412a8ab3          	sub	s5,s5,s2
    80001a04:	001aba13          	seqz	s4,s5
    80001a08:	00000097          	auipc	ra,0x0
    80001a0c:	930080e7          	jalr	-1744(ra) # 80001338 <vm_page_alloc>
    80001a10:	84aa                	mv	s1,a0
    80001a12:	00002917          	auipc	s2,0x2
    80001a16:	2e690913          	addi	s2,s2,742 # 80003cf8 <kernel_pagetable>
    80001a1a:	4699                	li	a3,6
    80001a1c:	862a                	mv	a2,a0
    80001a1e:	49a5                	li	s3,9
    80001a20:	01c99593          	slli	a1,s3,0x1c
    80001a24:	00093503          	ld	a0,0(s2)
    80001a28:	00000097          	auipc	ra,0x0
    80001a2c:	c42080e7          	jalr	-958(ra) # 8000166a <vm_page_insert>
    80001a30:	4681                	li	a3,0
    80001a32:	4605                	li	a2,1
    80001a34:	01c99593          	slli	a1,s3,0x1c
    80001a38:	00093503          	ld	a0,0(s2)
    80001a3c:	00000097          	auipc	ra,0x0
    80001a40:	c86080e7          	jalr	-890(ra) # 800016c2 <vm_page_remove>
    80001a44:	00002797          	auipc	a5,0x2
    80001a48:	2bc7b783          	ld	a5,700(a5) # 80003d00 <frame_table>
    80001a4c:	04978063          	beq	a5,s1,80001a8c <vm_test+0x2a8>
    80001a50:	45a5                	li	a1,9
    80001a52:	05f2                	slli	a1,a1,0x1c
    80001a54:	00002517          	auipc	a0,0x2
    80001a58:	2a453503          	ld	a0,676(a0) # 80003cf8 <kernel_pagetable>
    80001a5c:	00000097          	auipc	ra,0x0
    80001a60:	bd4080e7          	jalr	-1068(ra) # 80001630 <vm_lookup>
    80001a64:	00153513          	seqz	a0,a0
    80001a68:	40a00533          	neg	a0,a0
    80001a6c:	00aa7533          	and	a0,s4,a0
    80001a70:	fffff097          	auipc	ra,0xfffff
    80001a74:	8a4080e7          	jalr	-1884(ra) # 80000314 <print_pass>
    80001a78:	70e2                	ld	ra,56(sp)
    80001a7a:	7442                	ld	s0,48(sp)
    80001a7c:	74a2                	ld	s1,40(sp)
    80001a7e:	7902                	ld	s2,32(sp)
    80001a80:	69e2                	ld	s3,24(sp)
    80001a82:	6a42                	ld	s4,16(sp)
    80001a84:	6aa2                	ld	s5,8(sp)
    80001a86:	6b02                	ld	s6,0(sp)
    80001a88:	6121                	addi	sp,sp,64
    80001a8a:	8082                	ret
    80001a8c:	4a01                	li	s4,0
    80001a8e:	b7c9                	j	80001a50 <vm_test+0x26c>
	...

0000000080002000 <_trampoline>:
    80002000:	14051573          	csrrw	a0,sscratch,a0
    80002004:	02153423          	sd	ra,40(a0)
    80002008:	02253823          	sd	sp,48(a0)
    8000200c:	02353c23          	sd	gp,56(a0)
    80002010:	04453023          	sd	tp,64(a0)
    80002014:	04553423          	sd	t0,72(a0)
    80002018:	04653823          	sd	t1,80(a0)
    8000201c:	04753c23          	sd	t2,88(a0)
    80002020:	f120                	sd	s0,96(a0)
    80002022:	f524                	sd	s1,104(a0)
    80002024:	fd2c                	sd	a1,120(a0)
    80002026:	e150                	sd	a2,128(a0)
    80002028:	e554                	sd	a3,136(a0)
    8000202a:	e958                	sd	a4,144(a0)
    8000202c:	ed5c                	sd	a5,152(a0)
    8000202e:	0b053023          	sd	a6,160(a0)
    80002032:	0b153423          	sd	a7,168(a0)
    80002036:	0b253823          	sd	s2,176(a0)
    8000203a:	0b353c23          	sd	s3,184(a0)
    8000203e:	0d453023          	sd	s4,192(a0)
    80002042:	0d553423          	sd	s5,200(a0)
    80002046:	0d653823          	sd	s6,208(a0)
    8000204a:	0d753c23          	sd	s7,216(a0)
    8000204e:	0f853023          	sd	s8,224(a0)
    80002052:	0f953423          	sd	s9,232(a0)
    80002056:	0fa53823          	sd	s10,240(a0)
    8000205a:	0fb53c23          	sd	s11,248(a0)
    8000205e:	11c53023          	sd	t3,256(a0)
    80002062:	11d53423          	sd	t4,264(a0)
    80002066:	11e53823          	sd	t5,272(a0)
    8000206a:	11f53c23          	sd	t6,280(a0)
    8000206e:	140022f3          	csrr	t0,sscratch
    80002072:	06553823          	sd	t0,112(a0)
    80002076:	00853103          	ld	sp,8(a0)
    8000207a:	02053203          	ld	tp,32(a0)
    8000207e:	01053283          	ld	t0,16(a0)
    80002082:	00053303          	ld	t1,0(a0)
    80002086:	18031073          	csrw	satp,t1
    8000208a:	12000073          	sfence.vma
    8000208e:	8282                	jr	t0

0000000080002090 <userret>:
    80002090:	18059073          	csrw	satp,a1
    80002094:	12000073          	sfence.vma
    80002098:	07053283          	ld	t0,112(a0)
    8000209c:	14029073          	csrw	sscratch,t0
    800020a0:	02853083          	ld	ra,40(a0)
    800020a4:	03053103          	ld	sp,48(a0)
    800020a8:	03853183          	ld	gp,56(a0)
    800020ac:	04053203          	ld	tp,64(a0)
    800020b0:	04853283          	ld	t0,72(a0)
    800020b4:	05053303          	ld	t1,80(a0)
    800020b8:	05853383          	ld	t2,88(a0)
    800020bc:	7120                	ld	s0,96(a0)
    800020be:	7524                	ld	s1,104(a0)
    800020c0:	7d2c                	ld	a1,120(a0)
    800020c2:	6150                	ld	a2,128(a0)
    800020c4:	6554                	ld	a3,136(a0)
    800020c6:	6958                	ld	a4,144(a0)
    800020c8:	6d5c                	ld	a5,152(a0)
    800020ca:	0a053803          	ld	a6,160(a0)
    800020ce:	0a853883          	ld	a7,168(a0)
    800020d2:	0b053903          	ld	s2,176(a0)
    800020d6:	0b853983          	ld	s3,184(a0)
    800020da:	0c053a03          	ld	s4,192(a0)
    800020de:	0c853a83          	ld	s5,200(a0)
    800020e2:	0d053b03          	ld	s6,208(a0)
    800020e6:	0d853b83          	ld	s7,216(a0)
    800020ea:	0e053c03          	ld	s8,224(a0)
    800020ee:	0e853c83          	ld	s9,232(a0)
    800020f2:	0f053d03          	ld	s10,240(a0)
    800020f6:	0f853d83          	ld	s11,248(a0)
    800020fa:	10053e03          	ld	t3,256(a0)
    800020fe:	10853e83          	ld	t4,264(a0)
    80002102:	11053f03          	ld	t5,272(a0)
    80002106:	11853f83          	ld	t6,280(a0)
    8000210a:	14051573          	csrrw	a0,sscratch,a0
    8000210e:	10200073          	sret
	...
