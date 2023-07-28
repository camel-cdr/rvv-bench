# rvv-rollback.S -- A minimal benchmarking library
# Olaf Bernstein <camel-cdr@protonmail.com>
# Distributed under the MIT license, see license at the end of the file.
# New versions available at https://gist.github.com/camel-cdr/cfd9ba2b8754b521edf4892fe19c7031
# Conversions taken from https://github.com/RISCVtestbed/rvv-rollback

.macro vle32.v a:vararg
	vlw.v \a
.endm
.macro vle16.v a:vararg
	vlh.v \a
.endm
.macro vle8.v a:vararg
	vlb.v \a
.endm
.macro vle32ff.v a:vararg
	vlwff.v \a
.endm
.macro vle16ff.v a:vararg
	vlhff.v \a
.endm
.macro vle8ff.v a:vararg
	vlbff.v \a
.endm
.macro vse32.v a:vararg
	vsw.v \a
.endm
.macro vse16.v a:vararg
	vsh.v \a
.endm
.macro vse8.v a:vararg
	vsb.v \a
.endm
.macro vluxei32.v a:vararg
	vlxw.v \a
.endm
.macro vluxei16.v a:vararg
	vlxh.v \a
.endm
.macro vluxei8.v a:vararg
	vlxb.v \a
.endm
.macro vsuxei32.v a:vararg
	vsuxw.v \a
.endm
.macro vsuxei16.v a:vararg
	vsuxh.v \a
.endm
.macro vsuxei8.v a:vararg
	vsuxb.v \a
.endm
.macro vlse32.v a:vararg
	vlsw.v \a
.endm
.macro vlse16.v a:vararg
	vlsh.v \a
.endm
.macro vlse8.v a:vararg
	vlsb.v \a
.endm
.macro vsse32.v a:vararg
	vssw.v \a
.endm
.macro vsse16.v a:vararg
	vssh.v \a
.endm
.macro vsse8.v a:vararg
	vssb.v \a
.endm
.macro vloxei32.v a:vararg
	vlxw.v \a
.endm
.macro vloxei16.v a:vararg
	vlxh.v \a
.endm
.macro vloxei8.v a:vararg
	vlxb.v \a
.endm
.macro vsoxei32.v a:vararg
	vsxw.v \a
.endm
.macro vsoxei16.v a:vararg
	vsxh.v \a
.endm
.macro vsoxei8.v a:vararg
	vsxb.v \a
.endm
.macro vloxseg1e8.v a:vararg
	vlxseg1b.v \a
.endm
.macro vluxseg1e8.v a:vararg
	vlxseg1b.v \a
.endm
.macro vsoxseg1e8.v a:vararg
	vsxseg1b.v \a
.endm
.macro vsuxseg1e8.v a:vararg
	vsxseg1b.v \a
.endm
.macro vfncvt.xu.f.w a:vararg
	vfncvt.xu.f.v \a
.endm
.macro vfncvt.x.f.w a:vararg
	vfncvt.x.f.v \a
.endm
.macro vfncvt.f.xu.w a:vararg
	vfncvt.f.xu.v \a
.endm
.macro vfncvt.f.x.w a:vararg
	vfncvt.f.x.v \a
.endm
.macro vfncvt.f.f.w a:vararg
	vfncvt.f.f.v \a
.endm
.macro vfredusum a:vararg
	vfredsum \a
.endm
.macro vfwredusum.vs a:vararg
	vfwredsum.vs \a
.endm
.macro vnclip.wv a:vararg
	vnclip.vv \a
.endm
.macro vnclip.wx a:vararg
	vnclip.vx \a
.endm
.macro vnclip.wi a:vararg
	vnclip.vi \a
.endm
.macro vnclipu.wv a:vararg
	vnclipu.vv \a
.endm
.macro vnclipu.wx a:vararg
	vnclipu.vx \a
.endm
.macro vnclipu.wi a:vararg
	vnclipu.vi \a
.endm
.macro vnsra.wv a:vararg
	vnsra.vv \a
.endm
.macro vnsra.wx a:vararg
	vnsra.vx \a
.endm
.macro vnsra.wi a:vararg
	vnsra.vi \a
.endm
.macro vnsrl.wv a:vararg
	vnsrl.vv \a
.endm
.macro vnsrl.wx a:vararg
	vnsrl.vx \a
.endm
.macro vnsrl.wi a:vararg
	vnsrl.vi \a
.endm
.macro vmandn.mm a:vararg
	vmandnot.mm \a
.endm
.macro vmorn.mm a:vararg
	vmornot.mm \a
.endm
.macro vmmv.m a:vararg
	vmcpy.m \a
.endm
.macro vcpop.m a:vararg
	vmpopc.m \a
.endm
.macro vpop.m a:vararg
	vmpopc.m \a
.endm
.macro vfirst.m a:vararg
	vmfirst.m \a
.endm

.macro vsetvl0p7 rd, rs1, rs2, T=1, M=1
	vsetvl \rd, \rs1, \rs2
.endm
.macro vsetvli0p7 rd, rs1, e=e8, m=m1, T=1, M=1
	.ifc \m, mf2
	NOT SUPPORTED IN rvv0.7
	.endif
	.ifc \m, mf4
	NOT SUPPORTED IN rvv0.7
	.endif
	.ifc \m, mf8
	NOT SUPPORTED IN rvv0.7
	.endif
	vsetvli \rd, \rs1, \e, \m
.endm

#define vsetvl vsetvl0p7
#define vsetvli vsetvli0p7


.macro vzext.vf2 vd, vs, vm
.ifb \vm
	vwaddu.vx \vd, \vs, x0
.else
	vwaddu.vx \vd, \vs, x0, \vm
.endif
.endm

.macro vzext.vf4 vd, vs, vm
.ifb \vm
	vwaddu.vx \vd, \vs, x0
	vwaddu.vx \vd, \vd, x0
.else
	vwaddu.vx \vd, \vs, x0, \vm
	vwaddu.vx \vd, \vd, x0, \vm
.endif
.endm

.macro vzext.vf8 vd, vs, vm
.ifb \vm
	vwaddu.vx \vd, \vs, x0
	vwaddu.vx \vd, \vd, x0
	vwaddu.vx \vd, \vd, x0
.else
	vwaddu.vx \vd, \vs, x0, \vm
	vwaddu.vx \vd, \vd, x0, \vm
	vwaddu.vx \vd, \vd, x0, \vm
.endif
.endm


.macro vsext.vf2 vd, vs, vm
.ifb \vm
	vwaddu.vx \vd, \vs, x0
.else
	vwaddu.vx \vd, \vs, x0, \vm
.endif
.endm

.macro vsext.vf4 vd, vs, vm
.ifb \vm
	vwaddu.vx \vd, \vs, x0
	vwaddu.vx \vd, \vd, x0
.else
	vwaddu.vx \vd, \vs, x0, \vm
	vwaddu.vx \vd, \vd, x0, \vm
.endif
.endm

.macro vsext.vf8 vd, vs, vm
.ifb \vm
	vwaddu.vx \vd, \vs, x0
	vwaddu.vx \vd, \vd, x0
	vwaddu.vx \vd, \vd, x0
.else
	vwaddu.vx \vd, \vs, x0, \vm
	vwaddu.vx \vd, \vd, x0, \vm
	vwaddu.vx \vd, \vd, x0, \vm
.endif
.endm


# Copyright (c) 2023 Olaf Berstein
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

