# pure-3x-ui

[![Build and Release](https://github.com/vermiliondevil-web/pure-3x-ui/actions/workflows/release.yml/badge.svg)](https://github.com/vermiliondevil-web/pure-3x-ui/actions/workflows/release.yml)
[![Sync Upstream](https://github.com/vermiliondevil-web/pure-3x-ui/actions/workflows/sync-upstream.yml/badge.svg)](https://github.com/vermiliondevil-web/pure-3x-ui/actions/workflows/sync-upstream.yml)
[![Release](https://img.shields.io/github/v/release/vermiliondevil-web/pure-3x-ui?label=release)](https://github.com/vermiliondevil-web/pure-3x-ui/releases/latest)
[![License](https://img.shields.io/github/license/vermiliondevil-web/pure-3x-ui)](LICENSE)

Чистая сборка [3x-ui](https://github.com/MHSanaei/3x-ui) без рекламы и донат-блоков.

---

## О проекте

Это форк панели **3x-ui** от [MHSanaei](https://github.com/MHSanaei/3x-ui).

Из оригинального проекта удалены:

- 🚫 Рекламные блоки в панели
- 🚫 Донат-ссылки и промо-материалы
- 🚫 Спонсорские слоты (`SponsorSlot`, `SponsorCard`, `SponsorsPage`)
- 🚫 Кнопка доната в сайдбаре (`DonateButton`)
- 🚫 Кнопка документации, ведущая на сторонние ресурсы (`DocsButton`)
- 🚫 Ключи `donate` и `sponsors` из всех 13 языковых файлов

Всё остальное — функциональность, Xray core, интерфейс, API, все протоколы — сохранено без изменений.

---

## Возможности

- Поддержка протоколов: **VLESS, VMess, Trojan, Shadowsocks, WireGuard, TUIC, AmneziaWG** и другие
- Мультипротокольные inbound/outbound
- Управление клиентами и лимитами трафика
- Статистика по пользователям и нодам
- Telegram-бот для управления
- Discord-уведомления
- Поддержка **PostgreSQL** и **SQLite**
- REST API + OpenAPI-спецификация
- Тёмная и светлая темы
- Поддержка **Let's Encrypt** (домен и IP)
- Fail2ban-интеграция
- Мастер-нода архитектура

---

## Установка

Запустите от имени **root**:

```bash
bash <(curl -Ls https://raw.githubusercontent.com/vermiliondevil-web/pure-3x-ui/main/install.sh)
