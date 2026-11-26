#!/usr/bin/env bash
# yangila.sh: Debian asosli tizimni yangilaydi va tozalaydi.
# yangila.sh: updates and cleans a Debian-based system.

set -u

# Xabar chiqarib, to'xtash / Print a message and stop
xato() {
    echo "XATO / ERROR: $1" >&2
    exit 1
}

# Yordam matni / Help text
yordam() {
    cat <<'MATN'
Ishlatish / Usage:
  ./yangila.sh             Tizimni yangilaydi va tozalaydi / Update and clean the system
  ./yangila.sh --dry-run   Hech narsani o'zgartirmay ko'rsatadi / Show only, change nothing
  ./yangila.sh --help      Shu yordam / This help
MATN
}

# Flagni o'qish / Read the flag
sinov=0
if [ "$#" -gt 1 ]; then
    xato "Faqat bitta flag mumkin. / Only one flag is allowed."
fi
case "${1:-}" in
    "")        ;;
    --dry-run) sinov=1 ;;
    --help)    yordam; exit 0 ;;
    *)         xato "Noma'lum flag / Unknown flag: $1 (--help)" ;;
esac

# Tizimni tekshirish / Check the system
if ! command -v apt-get >/dev/null 2>&1 || [ ! -f /etc/debian_version ]; then
    xato "Bu skript faqat Debian asosli tizimlar uchun. / This script is only for Debian-based systems."
fi
if ! command -v sudo >/dev/null 2>&1; then
    xato "sudo topilmadi. / sudo was not found."
fi
if [ "$(id -u)" -eq 0 ]; then
    xato "Oddiy foydalanuvchi sifatida, sudo'siz ishga tushiring. / Run as a normal user, without sudo."
fi

# Sinov rejimi: faqat ko'rsatadi / Dry run: only shows
if [ "$sinov" -eq 1 ]; then
    echo "=== SINOV REJIMI / DRY-RUN ==="
    echo "Paketlar ro'yxati yangilanmaydi, natija eskirgan bo'lishi mumkin. / Package lists are not refreshed, results may be outdated."

    echo
    echo "--- full-upgrade ---"
    apt-get -s full-upgrade || xato "apt xatosi, yuqoridagi matnni o'qing. / apt error, see the text above."

    echo
    echo "--- autoremove ---"
    apt-get -s autoremove || xato "apt xatosi, yuqoridagi matnni o'qing. / apt error, see the text above."

    echo
    echo "--- Yuklangan paketlar hajmi / Downloaded package cache size ---"
    du -sh /var/cache/apt/archives 2>/dev/null

    echo
    echo "Hech narsa o'zgartirilmadi. / Nothing was changed."
    exit 0
fi

# Bo'sh joyni baytlarda o'lchash / Measure free space in bytes
bosh_joy() {
    LC_ALL=C df --output=avail -B1 / | tail -n 1 | tr -d ' '
}

oldin=$(bosh_joy)

# Paketlar ro'yxatini yangilash / Refresh the package lists
# Error-Mode=any: internet bo'lmasa, apt xato qaytaradi / apt fails when there is no internet
echo "Ro'yxat yangilanmoqda... / Refreshing package lists..."
sudo apt -o APT::Update::Error-Mode=any update ||
    xato "Yangilab bo'lmadi. Internetni tekshiring yoki boshqa apt dasturi tugashini kuting. Sababi yuqorida. / Update failed. Check the internet or wait for other apt programs to finish. See the reason above."

# Paketlarni yangilash (apt o'zi so'raydi) / Upgrade packages (apt asks you)
echo "Yangilanmoqda... / Updating..."
sudo apt full-upgrade ||
    xato "Yangilash bekor qilindi yoki apt xato berdi. Sababi yuqorida. / Upgrade was cancelled or apt failed. See the reason above."

# Keraksiz paketlarni o'chirish (apt o'zi so'raydi) / Remove unneeded packages (apt asks you)
echo "Keraksiz paketlar tekshirilmoqda... / Checking unneeded packages..."
sudo apt autoremove ||
    echo "DIQQAT: autoremove bajarilmadi, davom etamiz. / WARNING: autoremove did not finish, continuing." >&2

# Yuklangan .deb fayllarni tozalash / Clean downloaded .deb files
echo "Kesh tozalanmoqda... / Cleaning the cache..."
sudo apt clean ||
    echo "DIQQAT: clean bajarilmadi. / WARNING: clean did not finish." >&2

# Bo'shagan joyni hisoblash / Calculate the freed space
keyin=$(bosh_joy)
boshagan=$(( (keyin - oldin) / 1048576 ))

# Qayta yoqish kerakmi? / Is a reboot needed?
qayta="yo'q / no"
yangi_yadro=$(printf '%s\n' /boot/vmlinuz-* | sed 's|^/boot/vmlinuz-||' | sort -V | tail -n 1)
if [ -f /var/run/reboot-required ]; then
    qayta="ha / yes"
elif [ "$yangi_yadro" != "*" ] && [ "$yangi_yadro" != "$(uname -r)" ]; then
    qayta="ha / yes"
fi

# Natijani ko'rsatish / Show the result
natija="Sana / Date: $(date '+%Y-%m-%d %H:%M')
Oldin bo'sh / Free before: $(( oldin / 1048576 )) MB
Keyin bo'sh / Free after: $(( keyin / 1048576 )) MB
Bo'shadi / Freed: $boshagan MB (manfiy = joy kamaydi / negative = space was used)
Qayta yoqish kerakmi? / Reboot needed? $qayta"

echo
echo "$natija"
if [ "$qayta" = "ha / yes" ]; then
    echo "Kompyuterni qayta yoqing. / Please reboot your computer."
fi

# Hisobotga qo'shib yozish / Append to the report
hisobot="${YANGILA_HISOBOT:-$HOME/yangilanish_hisobot/hisobot.txt}"
if mkdir -p "$(dirname "$hisobot")" && printf '%s\n\n' "$natija" >> "$hisobot"; then
    echo "Hisobot / Report: $hisobot"
else
    xato "Hisobotni yozib bo'lmadi. / Could not write the report: $hisobot"
fi
