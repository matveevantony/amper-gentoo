# Copyright 1999-2024 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="8"

PYTHON_COMPAT=( python3_{10..13} )
inherit cmake xdg-utils python-any-r1

# Замена нижнего подчёркивания на "-"
MY_P=${P/_/-}
MY_PV=${PV/_/-}

DESCRIPTION="Kumir is a simple programming language and IDE"

HOMEPAGE="https://www.niisi.ru/kumir/"
SRC_URI="https://github.com/a-a-maly/${PN}/archive/refs/tags/${MY_PV}.tar.gz -> ${P}.tar.gz"

RESTRICT="bindist strip mirror"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+qt5"

S="${WORKDIR}/${MY_P}"

DEPEND="
	qt5? (
		dev-qt/qtcore:5=
		dev-qt/qtscript:5=
		dev-qt/qtsvg:5=
		dev-qt/qtgui:5=
		dev-qt/linguist-tools:5=
	)

	>=dev-lang/python-3.2
"

BDEPEND="
	${DEPEND} >=dev-build/cmake-3.2
	qt5? (
		dev-qt/qtx11extras
	)
"

src_prepare() {

	# Исправляем предупреждение cmake
	sed -i '1 s/project(Kumir2)/cmake_minimum_required(VERSION 3.0)/' "${S}/CMakeLists.txt" || die
	sed -i '2 s/cmake_minimum_required(VERSION 3.0)/project(Kumir2)/' "${S}/CMakeLists.txt" || die

	# Исправляем ошибку нахождения lrelease
	sed -i -E -e 's/\$\{_qt5Core_install_prefix\}/\/usr\/lib64\/qt5/' "${S}/cmake/kumir2/kumir2_common.cmake" || die

	eapply "${FILESDIR}/kumir2-2.1.0-r11_port-to-python3.patch"
	eapply "${FILESDIR}/gen_actor_source.py.patch"

	eapply_user

	cmake_src_prepare

}

src_configure() {

	if use qt5; then
		local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX=/usr \
		-DUSE_QT=5 \
		-DLIB_BASENAME=/usr/lib64/ \
		-DPROVIDED_VERSION_INFO=TRUE \
		-DGIT_TIMESTAMP=20220414 \
		-DGIT_TAG=${MY_PV} \
		-DCMAKE_BUILD_TYPE=Release \
		-DGIT_BRANCH=master
		)
	else
		local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX=/usr
		-DLIB_BASENAME=/usr/lib64/ \
		-DPROVIDED_VERSION_INFO=TRUE \
		-DGIT_TIMESTAMP=20220414 \
		-DGIT_TAG=${MY_PV} \
		-DCMAKE_BUILD_TYPE=Release \
		-DGIT_BRANCH=master
		)
	fi

	cmake_src_configure

}

src_compile () {

	cmake_src_compile

}

src_install() {

	cmake_src_install

}

pkg_postinst() {

	xdg_desktop_database_update
	xdg_icon_cache_update
	xdg_mimeinfo_database_update

}
