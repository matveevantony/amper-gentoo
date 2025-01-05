# Copyright 2020-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

EGIT_REPO_URI="https://github.com/veyon/veyon.git"
# tags/v4.9.1
EGIT_COMMIT=1f5407f1eab3574235f486d1a75d4cc41531638b

EGIT_BRANCH="4.9"
EGIT_CHECKOUT_DIR=${WORKDIR}/${P}
EGIT_SUBMODULES=( '*' )

inherit desktop xdg unpacker toolchain-funcs git-r3 cmake

DESCRIPTION="Cross-platform computer control and classroom management"
HOMEPAGE="https://veyon.io/"

MY_PN=${PN/-bin}

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
RESTRICT="bindist strip mirror"

RDEPEND="
	!net-misc/veyon-bin
	app-crypt/qca[qt6(+)]

	dev-qt/qtbase:6
	dev-libs/cyrus-sasl
	dev-libs/lzo
	dev-libs/openssl
	dev-qt/qtbase
	dev-qt/qtcore
	dev-qt/qtdbus
	dev-qt/qtdeclarative
	dev-qt/qtgui
	dev-qt/qthttpserver
	dev-qt/qtnetwork
	dev-qt/qtwidgets
	dev-qt/qttools

	net-nds/openldap
	>=sys-libs/glibc-2.34
	sys-libs/pam
	sys-libs/zlib
	sys-process/procps
	|| ( media-libs/libjpeg-turbo media-libs/libjpeg8 )

	>=x11-libs/libfakekey-0.1
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXi
	x11-libs/libXinerama
	x11-libs/libXrandr
	x11-libs/libXtst
	x11-base/xorg-server

"

BDEPEND="
	dev-build/make
	dev-build/cmake
	dev-build/ninja
	dev-vcs/git
	dev-qt/qttools:6
	llvm-core/clang
	sys-devel/gcc
"

src_prepare() {

	local mycmakeargs=(
		-DWITH_QT6=ON -DVEYON_DEBUG=ON \
		-Wno-dev
	)
	cmake_src_prepare
	default

}

src_configure() {

	cmake_src_configure

}

src_compile() {

	cmake_src_compile
	cmake_build

}

src_install() {

	cmake_src_install

	if which rc-update	>/dev/null 2>&1; then
		mkdir -p "${D}/etc/init.d/" || die
		echo '#!/sbin/openrc-run

name="Veyon Service"
description="Veyon Service"
supervisor="supervise-daemon"
command="/usr/bin/veyon-service"
command_args=""

depend() {
	after display-manager dbus
	need net
}' > "${D}/etc/init.d/${MY_PN}" || die

	# Исправление прав на запуск службы
	chmod +x "${D}/etc/init.d/${MY_PN}" || die
	fi

	chmod +x "${D}/lib/systemd/system/${MY_PN}.service" || die

	sed -i '/Name=/a Name[ru]=Конфигуратор Veyon' "${D}/usr/share/applications/veyon-configurator.desktop" || die
	sed -i '/Comment=/a Comment[ru]=Конфигуратор программы Veyon (Virtual Eye On Networks)' "${D}/usr/share/applications/veyon-configurator.desktop" || die

	sed -i '/Name=/a Name[ru]=Veyon Мастер' "${D}/usr/share/applications/veyon-master.desktop" || die
	sed -i '/Comment=/a Comment[ru]=Наблюдение за удалёнными компьютерами и управление ими' "${D}/usr/share/applications/veyon-master.desktop" || die
}

pkg_postinst() {

	if which systemctl >/dev/null 2>&1; then
		systemctl reset-failed
		systemctl stop veyon
		elog "Служба ${PN} установлена"
	elif which update-rc.d >/dev/null 2>&1; then
		update-rc.d veyon defaults 90 10 >/dev/null 2>&1 \
		&& elog "Служба ${PN} установлена"
	elif which rc-update	>/dev/null 2>&1; then
		rc-update add veyon default \
		&& elog "Служба ${PN} установлена"
	fi

}

pkg_prerm() {

	if [ "${REPLACED_BY_VERSION}" = "" ]; then
		elog "Пакет окончательно удаляется"

		# Удаляем службы
		if which systemctl >/dev/null 2>&1; then
			systemctl disable veyon >/dev/null 2>&1
		elif which update-rc.d >/dev/null 2>&1; then
			update-rc.d -f veyon remove >/dev/null 2>&1
		elif which rc-update >/dev/null 2>&1; then
			rc-update del veyon >/dev/null 2>&1
		fi
	fi

}

pkg_postrm() {

	xdg_desktop_database_update
	xdg_icon_cache_update

}
