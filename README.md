# yangila.sh

![Claude Code](https://img.shields.io/badge/Claude_Code-yordamida_%2F_created_with-blue)

> **O'zbekcha:** Bu skript Claude Code yordamida yaratilgan va muallif tomonidan tekshirilgan. Muallif kodni o'qib chiqqan, tushunadi va o'z kompyuterida sinab ko'rgan.
>
> **English:** This script was created with Claude Code and reviewed by the author. The author has read the code, understands it and has tested it on their own computer.

## O'zbekcha

Debian asosli tizimlarni (Debian, Ubuntu, Linux Mint va shunga o'xshash) bitta buyruq bilan yangilaydi va tozalaydi. Yangi boshlovchilar uchun. Fedora, Arch va boshqa Debian bo'lmagan tizimlarda **ishlamaydi**.

### Ishlatish

```bash
chmod +x yangila.sh
./yangila.sh --dry-run   # faqat ko'rsatadi, hech narsani o'zgartirmaydi
./yangila.sh             # yangilaydi va tozalaydi
./yangila.sh --help
```

Skriptni `sudo`siz ishga tushiring: u kerak joyda `sudo`ni o'zi chaqiradi. `apt` `Y/n` deb so'rasa, avval ro'yxatni o'qing.

Skript ro'yxatni yangilaydi (`apt update`), paketlarni yangilaydi (`full-upgrade`), tozalaydi, bo'shagan joyni hisoblaydi va qayta yoqish kerakligini aytadi. Hisobot `~/yangilanish_hisobot/hisobot.txt` fayliga qo'shib yoziladi (boshqa joy uchun `YANGILA_HISOBOT` o'zgaruvchisi). Yangilanish ko'p joy olsa, "bo'shadi" soni manfiy chiqadi.

### Nima o'chadi?

- `autoremove`: keraksiz paketlar va eski yadrolar. Odatda ishlayotgan yadro va bitta zaxira yadro qoladi (buni `apt` o'zi hal qiladi).
- `clean`: yuklab olingan `.deb` fayllar keshi.
- `full-upgrade` ham yangilash uchun ba'zi paketlarni o'chirishi mumkin.

**O'chmaydi:** shaxsiy fayllar, loglar, sozlamalar (`--purge` ishlatilmaydi).

⚠️ **O'z javobgarligingizda ishlating.** Muhim fayllaringizning zaxira nusxasini saqlang.

## English

Updates and cleans Debian-based systems (Debian, Ubuntu, Linux Mint and similar) with one command. Made for beginners. It does **not** work on Fedora, Arch or other non-Debian systems.

### Usage

```bash
chmod +x yangila.sh
./yangila.sh --dry-run   # show only, change nothing
./yangila.sh             # update and clean
./yangila.sh --help
```

Run it without `sudo`: it calls `sudo` itself when needed. When `apt` asks `Y/n`, read the list first.

The script refreshes the package lists (`apt update`), upgrades packages (`full-upgrade`), cleans up, calculates the freed space and tells you if a reboot is needed. A report is appended to `~/yangilanish_hisobot/hisobot.txt` (set `YANGILA_HISOBOT` to change the path). If the upgrade takes up space, the "freed" number is negative.

### What gets removed?

- `autoremove`: unneeded packages and old kernels. Usually the running kernel and one backup kernel remain (`apt` decides this).
- `clean`: the cache of downloaded `.deb` files.
- `full-upgrade` may also remove some packages in order to upgrade.

**Not removed:** personal files, logs, settings (`--purge` is not used).

⚠️ **Use at your own risk.** Keep a backup of important files.

## Namuna / Example

Haqiqiy `--dry-run` chiqishidan qisqartirib olingan. `apt`ning `NOTE: This is only a simulation!` xabari normal holat.
Shortened from real `--dry-run` output. The `apt` message `NOTE: This is only a simulation!` is normal.

```text
=== SINOV REJIMI / DRY-RUN ===
...
--- full-upgrade ---
...
0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.

--- autoremove ---
...
0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.

--- Yuklangan paketlar hajmi / Downloaded package cache size ---
282M	/var/cache/apt/archives

Hech narsa o'zgartirilmadi. / Nothing was changed.
```

## Litsenziya / License

[MIT](LICENSE)
