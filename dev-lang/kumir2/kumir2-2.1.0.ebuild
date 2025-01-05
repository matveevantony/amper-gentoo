# Copyright 2020-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit rpm

DESCRIPTION="Implementation of Kumir programming language, designed by academician Ershov."
HOMEPAGE="https://www.niisi.ru/kumir/"
SRC_URI="amd64? ( https://mirror.yandex.ru/rosa/rosa2021.1/repository/x86_64/contrib/release/kumir-all-${PV}-7-rosa2021.1.x86_64.rpm )"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="mirror strip"

RDEPEND="
    dev-qt/qtcore:5
    dev-qt/qtgui:5
    dev-qt/qtprintsupport:5
    dev-qt/qtscript:5
    dev-qt/qtsvg:5
    dev-qt/qtx11extras:5
"

DEPEND="${RDEPEND}"

S="${WORKDIR}"

src_unpack() {
    rpm_unpack kumir-all-${PV}-7-rosa2021.1.x86_64.rpm
}

src_install() {
    cp -R "${WORKDIR}/usr" "${D}" || die "install failed!"
}
