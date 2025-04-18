/* SPDX-License-Identifier: GPL-2.0-or-later */
/*
 * Access to the shared data page by the vDSO & syscall map
 *
 * Copyright (C) 2004 Benjamin Herrenschmuidt (benh@kernel.crashing.org), IBM Corp.
 */

#include <asm/processor.h>
#include <asm/ppc_asm.h>
#include <asm/asm-offsets.h>
#include <asm/unistd.h>
#include <asm/vdso.h>
#include <asm/vdso_datapage.h>

	.text

/*
 * void *__kernel_get_syscall_map(unsigned int *syscall_count) ;
 *
 * returns a pointer to the syscall map. the map is agnostic to the
 * size of "long", unlike kernel bitops, it stores bits from top to
 * bottom so that memory actually contains a linear bitmap
 * check for syscall N by testing bit (0x80000000 >> (N & 0x1f)) of
 * 32 bits int at N >> 5.
 */
V_FUNCTION_BEGIN(__kernel_get_syscall_map)
  .cfi_startproc
	mflr	r12
  .cfi_register lr,r12
	mr.	r4,r3
	get_datapage	r3 vdso_u_arch_data
	mtlr	r12
#ifdef __powerpc64__
	addi	r3,r3,CFG_SYSCALL_MAP64
#else
	addi	r3,r3,CFG_SYSCALL_MAP32
#endif
	crclr	cr0*4+so
	beqlr
	li	r0,NR_syscalls
	stw	r0,0(r4)
	blr
  .cfi_endproc
V_FUNCTION_END(__kernel_get_syscall_map)

/*
 * void unsigned long long  __kernel_get_tbfreq(void);
 *
 * returns the timebase frequency in HZ
 */
V_FUNCTION_BEGIN(__kernel_get_tbfreq)
  .cfi_startproc
	mflr	r12
  .cfi_register lr,r12
	get_datapage	r3 vdso_u_arch_data
#ifndef __powerpc64__
	lwz	r4,(CFG_TB_TICKS_PER_SEC + 4)(r3)
#endif
	PPC_LL	r3,CFG_TB_TICKS_PER_SEC(r3)
	mtlr	r12
	crclr	cr0*4+so
	blr
  .cfi_endproc
V_FUNCTION_END(__kernel_get_tbfreq)
