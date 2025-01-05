# Copyright 2020-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit rpm

DESCRIPTION="PascalABC.NET is a Pascal programming language that implements classic Pascal, most Delphi language features, as well as a number of their own extensions"
HOMEPAGE="http://pascalabc.net/"
SRC_URI="amd64? ( http://mirror.rosalinux.ru/rosa/rosa2021.1/repository/x86_64/contrib/release/${P}-1.gitf309df.3-rosa2021.1.x86_64.rpm )"

LICENSE="LGPL-3.0"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="mirror strip"

IUSE="+chm gtk2"

RDEPEND="
    chm? ( app-text/kchmviewer )
    dev-dotnet/libgdiplus
    dev-lang/mono
    gtk2? ( media-libs/libcanberra[gtk2] )
    gtk2? ( x11-misc/appmenu-gtk-module[gtk2] )
"

DEPEND="${RDEPEND}"

S="${WORKDIR}"

src_unpack() {

    rpm_unpack ${P}-1.gitf309df.3-rosa2021.1.x86_64.rpm

}

src_install() {

    cp -R "${WORKDIR}/usr" "${D}" || die "install failed!"

}

pkg_postinst() {

    if !(use gtk2) ; then
        elog "Если будет докучать ошибка-предупреждение об отсутствующей библиотеке 'appmenu-gtk-module' или 'canberra-gtk-module', то поступите следующим образом:"
        elog ""
        elog "Задайте USE-флаги командой: echo 'dev-lang/pascalabcnet gtk2' >> /etc/portage/package.use/custom && echo 'x11-misc/appmenu-gtk-module gtk2' >> /etc/portage/package.use/custom && echo 'media-libs/libcanberra gtk2' >> /etc/portage/package.use/custom"
        elog ""
        elog "и переустановите программу 'PascalABCNETLinux' следующей командой: emerge -av dev-lang/pascalabcnet"
        elog ""
    fi

}
