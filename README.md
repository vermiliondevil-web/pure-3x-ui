# pure-3x-ui

[![Build and Release](https://github.com/vermiliondevil-web/pure-3x-ui/actions/workflows/release.yml/badge.svg)](https://github.com/vermiliondevil-web/pure-3x-ui/actions/workflows/release.yml)
[![Sync Upstream](https://github.com/vermiliondevil-web/pure-3x-ui/actions/workflows/sync-upstream.yml/badge.svg)](https://github.com/vermiliondevil-web/pure-3x-ui/actions/workflows/sync-upstream.yml)
[![Release](https://img.shields.io/github/v/release/vermiliondevil-web/pure-3x-ui?label=release)](https://github.com/vermiliondevil-web/pure-3x-ui/releases/latest)
[![License](https://img.shields.io/github/license/vermiliondevil-web/pure-3x-ui)](LICENSE)

Чистая сборка [3x-ui](https://github.com/MHSanaei/3x-ui) без рекламы и донат-блоков.

**Работает из России** — установка и обновление идут через [jsDelivr](https://www.jsdelivr.com/), потому что `raw.githubusercontent.com` блокируется РКН.

---

## О проекте

Это форк панели **3x-ui** от [MHSanaei](https://github.com/MHSanaei/3x-ui).

**Удалено из оригинала:**

- 🚫 Рекламные блоки в панели
- 🚫 Донат-ссылки и промо-материалы
- 🚫 Спонсорские слоты (`SponsorSlot`, `SponsorCard`, `SponsorsPage`)
- 🚫 Кнопка доната в сайдбаре (`DonateButton`)
- 🚫 Кнопка документации на сторонние ресурсы (`DocsButton`)
- 🚫 Ключи `donate` и `sponsors` из всех 13 языковых файлов

**Изменено:**

- 🔄 Все ссылки `raw.githubusercontent.com` → `cdn.jsdelivr.net/gh/` (обход блокировки РКН)
- 🔄 `panel.go`, `install.sh`, `update.sh`, `README.md` — указывают на **этот** репозиторий
- 🔄 Автоматизация через GitHub Actions: автосинхронизация с upstream, автоудаление рекламы

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

### Основной способ (рекомендуется)

Запустите от имени **root**:

```bash
bash <(curl -Ls https://cdn.jsdelivr.net/gh/vermiliondevil-web/pure-3x-ui@main/install.sh)
```

Этот способ **работает из России** — скрипт скачивается через CDN jsDelivr, который не блокируется РКН.

### Альтернативные способы

Если основной способ не работает — попробуйте один из этих:

```bash
# 1. Через github.com/raw (редиректит на raw.githubusercontent — нужен VPN)
bash <(curl -Ls "https://github.com/vermiliondevil-web/pure-3x-ui/raw/main/install.sh")

# 2. Через jsDelivr с конкретным коммитом (обход кэша CDN — всегда свежая версия)
bash <(curl -Ls https://cdn.jsdelivr.net/gh/vermiliondevil-web/pure-3x-ui@1ac852e1/install.sh)

# 3. Через jsDelivr с тегом (стабильный релиз)
bash <(curl -Ls https://cdn.jsdelivr.net/gh/vermiliondevil-web/pure-3x-ui@v3.9.2/install.sh)
```

**Особенности способов:**

| № | Способ | Особенность |
|---|---|---|
| **1** | `github.com/raw` | Редирект на `raw.githubusercontent.com` → нужен VPN/прокси |
| **2** | `jsDelivr @<коммит>` | Ссылка на конкретный коммит → **не кэшируется**, всегда свежая |
| **3** | `jsDelivr @<тег>` | Ссылка на стабильный релиз → кэшируется 12ч, но тег неизменен |

### Что делает скрипт

1. Определяет ОС и архитектуру.
2. Устанавливает зависимости.
3. Скачивает последний релиз из **этого** репозитория.
4. Проверяет `.sha256`.
5. Настраивает сервис, базу данных, SSL.
6. Выводит **логин, пароль, порт, webBasePath** и **URL** панели.

---

## Управление

```bash
x-ui              # Меню управления
x-ui start        # Запустить
x-ui stop         # Остановить
x-ui restart      # Перезапустить
x-ui status       # Статус
x-ui settings     # Текущие настройки
x-ui enable       # Включить автозапуск
x-ui disable      # Отключить автозапуск
x-ui log          # Логи
x-ui banlog       # Логи банов Fail2ban
x-ui update       # Обновить
x-ui install      # Установить
x-ui uninstall    # Удалить
```

---

## Обновление

### Через UI (кнопка «Обновить»)

Панель **сама проверяет** последний релиз на GitHub через `api.github.com/repos/vermiliondevil-web/pure-3x-ui/releases/latest` и **скачивает** `update.sh` через jsDelivr.

**Как работает:**

1. Панель запрашивает последний тег.
2. Скачивает `update.sh` через jsDelivr.
3. `update.sh` вызывает `install.sh` (тоже через jsDelivr).
4. `install.sh` скачивает архив и обновляет панель.

**Важно:** кнопка «Обновить» **активна только если версия на GitHub выше** версии в файле `internal/config/version`.

### Через `install.sh`

```bash
bash <(curl -Ls https://cdn.jsdelivr.net/gh/vermiliondevil-web/pure-3x-ui@main/install.sh)
```

Скрипт подтянет последний релиз, сохранит базу и настройки.

### Xray core

Кнопка обновления Xray в панели **безопасна** — она тянет ядро напрямую с [XTLS/Xray-core](https://github.com/XTLS/Xray-core), где **нет** рекламы.

---

## Сборка из исходников

```bash
git clone https://github.com/vermiliondevil-web/pure-3x-ui.git
cd pure-3x-ui/frontend
npm install
npm run build
cd ..
CGO_ENABLED=1 GOOS=linux GOARCH=amd64 go build -ldflags "-w -s" -o x-ui-main main.go
```

Бинарник появится как `./x-ui-main`.

---

## Автоматизация

В репозитории настроены **два GitHub Actions workflow**:

### 1. `Sync Upstream` — автосинхронизация с оригиналом

Раз в день (в 03:00 UTC) или вручную:

- подтягивает свежий код из [MHSanaei/3x-ui](https://github.com/MHSanaei/3x-ui);
- вызывает `scripts/remove-ads.sh` для удаления рекламы и донатов;
- заменяет `raw.githubusercontent.com` на `cdn.jsdelivr.net`;
- брендирует `panel.go` и `update.sh`;
- коммитит изменения и пушит в `main`.

**Это значит:** когда Санаи выпускает обновление, реклама вырезается **автоматически**, а ссылки переключаются на jsDelivr.

### 2. `Build and Release` — сборка и публикация релизов

Запускается по тегу `v*` или вручную:

- вырезает рекламу (`scripts/remove-ads.sh`) — страховка;
- собирает фронтенд (`npm run build`);
- собирает Go-бинарник;
- скачивает Xray core с XTLS;
- упаковывает всё в `x-ui-linux-amd64.tar.gz` + `.sha256`;
- публикует релиз.

### Как выпустить новую версию

1. **Поменяйте версию** в `internal/config/version` на **новую** (например, `3.9.3`).
2. **Поменяйте версию** в `scripts/remove-ads.sh` (там же, строка с `echo -n "3.9.2"`).
3. Коммит и push.
4. Создайте тег с **тем же номером**:

   ```bash
   git tag v3.9.3
   git push origin v3.9.3
   ```

5. Через 10–15 минут — релиз готов.

> **Правило:** версия в файле `internal/config/version` **должна совпадать** с тегом. Тогда кнопка «Обновить» **неактивна** после обновления.

---

## Структура репозитория

| Путь | Назначение |
|---|---|
| `install.sh` | Установочный скрипт (jsDelivr) |
| `update.sh` | Обёртка над `install.sh` для кнопки «Обновить» |
| `scripts/remove-ads.sh` | Удаление рекламы, донатов, брендирование, jsDelivr |
| `.github/workflows/sync-upstream.yml` | Автосинхронизация с upstream |
| `.github/workflows/release.yml` | Сборка и публикация релизов |
| `internal/config/version` | Версия панели (встраивается через `//go:embed`) |
| `internal/web/service/panel/panel.go` | Логика проверки обновлений |
| `frontend/` | Фронтенд (Vite + TypeScript + React) |
| `internal/` | Go-код бэкенда |
| `main.go` | Точка входа Go |
| `x-ui.sh` | Скрипт управления панелью |

---

## Отличия от оригинала

| Оригинал (MHSanaei) | pure-3x-ui |
|---|---|
| Рекламные блоки в панели | Удалены |
| Донат-ссылки и промо | Удалены |
| Спонсорские слоты (`SponsorSlot`, `SponsorCard`) | Удалены |
| Отдельная страница `/sponsors` | Удалена |
| Ключи `donate`/`sponsors` в локалях | Удалены из 13 файлов |
| Кнопка документации (`DocsButton`) | Удалена |
| `raw.githubusercontent.com` | `cdn.jsdelivr.net/gh/` (работает из РФ) |
| `install.sh` указывает на MHSanaei | Свой `install.sh` |
| Кнопка «Обновить» тянет с MHSanaei | Тянет из **этого** репозитория |
| Релизы на MHSanaei/3x-ui | Релизы на vermiliondevil-web/pure-3x-ui |
| Ручное обновление | Автосинхронизация + автосборка |

---

## Скриншоты

<!-- Сюда можно вставить скриншоты панели без донатов -->

---

## Лицензия

Проект распространяется под лицензией **AGPL-3.0** — как и оригинальный 3x-ui.

- Оригинальный автор: [MHSanaei](https://github.com/MHSanaei/3x-ui)
- Форк и поддержка: [vermiliondevil-web](https://github.com/vermiliondevil-web)

Файл лицензии — в корне репозитория: [`LICENSE`](LICENSE).

Поскольку проект под **AGPL-3.0**, все изменения публикуются под той же лицензией. Исходный код доступен на GitHub.

---

## Благодарности

- [MHSanaei](https://github.com/MHSanaei) — за оригинальный 3x-ui
- [XTLS/Xray-core](https://github.com/XTLS/Xray-core) — за ядро Xray
- [Acme.sh](https://github.com/acmesh-official/acme.sh) — за SSL-сертификаты
- [jsDelivr](https://www.jsdelivr.com/) — за CDN, работающий из РФ
- Всем контрибьюторам оригинального проекта

---

## Обратная связь

- Issues: https://github.com/vermiliondevil-web/pure-3x-ui/issues
- Pull Requests: приветствуются

---

## Дисклеймер

Это **неофициальный форк**. Проект не связан с MHSanaei или XTLS.
Панель предоставляется как есть, для личного и некоммерческого использования.
