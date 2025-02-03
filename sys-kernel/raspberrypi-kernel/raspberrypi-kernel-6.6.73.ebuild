# Copyright 2020-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
# Largely derived from gentoo-kernel-6.6.73.ebuild

EAPI=8

inherit pikernel-build

COMMIT=81d11968e656eea78f44f5fe02a8e7eec7677063
MY_P=linux-${PV}
GENPATCHES_P=genpatches-${PV%.*}-$(( ${PV##*.} + 9 ))
# https://koji.fedoraproject.org/koji/packageinfo?packageID=8
# forked to https://github.com/projg2/fedora-kernel-config-for-gentoo
CONFIG_VER=6.6.12-gentoo
GENTOO_CONFIG_VER=g15

DESCRIPTION="Raspberry Pi Foundation Linux kernel built with Gentoo patches"
HOMEPAGE="
	https://wiki.gentoo.org/wiki/Project:Distribution_Kernel
	https://www.kernel.org/
	https://github.com/raspberrypi/linux
"
SRC_URI+="
	https://github.com/raspberrypi/linux/archive/${COMMIT}.tar.gz -> ${MY_P}.tar.gz
	https://dev.gentoo.org/~alicef/dist/genpatches/${GENPATCHES_P}.base.tar.xz
	https://dev.gentoo.org/~alicef/dist/genpatches/${GENPATCHES_P}.extras.tar.xz
	https://github.com/projg2/gentoo-kernel-config/archive/${GENTOO_CONFIG_VER}.tar.gz
		-> gentoo-kernel-config-${GENTOO_CONFIG_VER}.tar.gz
	amd64? (
		https://raw.githubusercontent.com/projg2/fedora-kernel-config-for-gentoo/${CONFIG_VER}/kernel-x86_64-fedora.config
 			-> kernel-x86_64-fedora.config.${CONFIG_VER}
	)
	arm64? (
		https://raw.githubusercontent.com/projg2/fedora-kernel-config-for-gentoo/${CONFIG_VER}/kernel-aarch64-fedora.config
			-> kernel-aarch64-fedora.config.${CONFIG_VER}
	)
	ppc64? (
		https://raw.githubusercontent.com/projg2/fedora-kernel-config-for-gentoo/${CONFIG_VER}/kernel-ppc64le-fedora.config
			-> kernel-ppc64le-fedora.config.${CONFIG_VER}
	)
	x86? (
		https://raw.githubusercontent.com/projg2/fedora-kernel-config-for-gentoo/${CONFIG_VER}/kernel-i686-fedora.config
			-> kernel-i686-fedora.config.${CONFIG_VER}
	)
"
S=${WORKDIR}/linux-${COMMIT}

LICENSE="GPL-2"
KEYWORDS="~arm arm64"
IUSE="debug hardened"
REQUIRED_USE="
	arm? ( savedconfig )
	hppa? ( savedconfig )
	riscv? ( savedconfig )
	sparc? ( savedconfig )
"

RDEPEND="
	!sys-kernel/gentoo-kernel-bin:${SLOT}
"
BDEPEND="
	debug? ( dev-util/pahole )
"
PDEPEND="
	>=virtual/dist-kernel-${PV}
"

QA_FLAGS_IGNORED="
	usr/src/linux-.*/scripts/gcc-plugins/.*.so
	usr/src/linux-.*/vmlinux
	usr/src/linux-.*/arch/powerpc/kernel/vdso.*/vdso.*.so.dbg
"

src_prepare() {
	# Copied from raspberrypi-sources-6.6.47_p20240902.ebuild
	UNIPATCH_EXCLUDE="
		10*
		15*
		1700
                1730
		2000
                201*
                2700
                2800
		29*
		3000
		4567"

	# Copied from kernel-2.eclass

	# So now lets get rid of the patch numbers we want to exclude
	for i in ${UNIPATCH_EXCLUDE}; do
		ebegin "Excluding Patch #${i}"
		rm -f ${WORKDIR}/${i}* 2>/dev/null;
		eend $?
	done

	# Only set PATCHES if there are patches remaining...
	if compgen -G "${WORKDIR}/*.patch" > /dev/null; then
		local PATCHES=(
			# meh, genpatches have no directory
			"${WORKDIR}"/*.patch
		)
	else
		echo "No patches selected"
	fi

	default
}

# Override function from kernel-install eclass to skip checking of kernel.release file(s).
pkg_preinst() {
	debug-print-function ${FUNCNAME} "${@}"
}
