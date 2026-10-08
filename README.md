# pure-3x-ui

[![Build and Release](https://github.com/vermiliondevil-web/pure-3x-ui/actions/workflows/release.yml/badge.svg)](https://github.com/vermiliondevil-web/pure-3x-ui/actions/workflows/release.yml)
[![Sync Upstream](https://github.com/vermiliondevil-web/pure-3x-ui/actions/workflows/sync-upstream.yml/badge.svg)](https://github.com/vermiliondevil-web/pure-3x-ui/actions/workflows/sync-upstream.yml)
[![Release](https://img.shields.io/github/v/release/vermiliondevil-web/pure-3x-ui?label=release)](https://github.com/vermiliondevil-web/pure-3x-ui/releases/latest)
[![License](https://img.shields.io/github/license/vermiliondevil-web/pure-3x-ui)](LICENSE)

> **Это форк.** Проект является производной работой от [3x-ui](https://github.com/MHSanaei/3x-ui) (автор — [MHSanaei](https://github.com/MHSanaei)) и распространяется под лицензией **AGPL-3.0**. Все изменения, внесённые в этот форк, публикуются под той же лицензией.

Чистая сборка [3x-ui](https://github.com/MHSanaei/3x-ui) без рекламы и донат-блоков.

**Работает из России** — установка и обновление идут через [jsDelivr](https://www.jsdelivr.com/), потому что `raw.githubusercontent.com` блокируется РКН.

---

## О проекте

Это форк панели **3x-ui** от [MHSanaei](https://github.com/MHSanaei/3x-ui).

### Удалено из оригинала

- 🚫 Рекламные блоки в панели
- 🚫 Донат-ссылки и промо-материалы
- 🚫 Спонсорские слоты (`SponsorSlot`, `SponsorCard`, `SponsorsPage`)
- 🚫 Кнопка доната в сайдбаре (`DonateButton`)
- 🚫 Кнопка документации на сторонние ресурсы (`DocsButton`)
- 🚫 Пункт меню «Sponsors»
- 🚫 Страница `/sponsors`
- 🚫 Эндпоинт `/sponsors` в API-доках

### Изменено

- 🔄 Все ссылки `raw.githubusercontent.com` → `cdn.jsdelivr.net/gh/` (обход блокировки РКН)
- 🔄 `panel.go`, `install.sh`, `update.sh`, `README.md` — указывают на **этот** репозиторий
- 🔄 Автоматизация через GitHub Actions:
  - **`Sync Upstream`** — автосинхронизация с upstream (раз в день)
  - **`Build and Release`** — автосборка релизов по тегу
- 🔄 **Авто-версия из тега**: `release.yml` сам подставляет номер тега в `internal/config/version`
- 🔄 **Локали не трогаются** в `remove-ads.sh` — это уменьшает diff и упрощает merge

### Не изменено

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

Если основной способ не работает:

```bash
# 1. Через github.com/raw (редиректит на raw.githubusercontent — нужен VPN)
bash <(curl -Ls "https://github.com/vermiliondevil-web/pure-3x-ui/raw/main/install.sh")

# 2. Через jsDelivr с конкретным коммитом (обход кэша CDN)
bash <(curl -Ls https://cdn.jsdelivr.net/gh/vermiliondevil-web/pure-3x-ui@main/install.sh)

# 3. Через jsDelivr с тегом (стабильный релиз)
bash <(curl -Ls https://cdn.jsdelivr.net/gh/vermiliondevil-web/pure-3x-ui@v3.9.3/install.sh)
```

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

**Важно:** кнопка «Обновить» **активна только если версия тега выше** версии в файле `internal/config/version`.

**Схема:**

| Версия в файле | Тег на GitHub | Кнопка |
|---|---|---|
| `3.9.2` | `v3.9.2` | ❌ неактивна |
| `3.9.2` | `v3.9.3` | ✅ активна |
| `3.9.3` | `v3.9.3` | ❌ неактивна |

### Через `install.sh`

```bash
bash <(curl -Ls https://cdn.jsdelivr.net/gh/vermiliondevil-web/pure-3x-ui@main/install.sh)
```

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

**Работает ~17 секунд.** Раз в день (в 03:00 UTC) или вручную:

1. Подтягивает свежий код из [MHSanaei/3x-ui](https://github.com/MHSanaei/3x-ui).
2. **Берёт локали и `update.sh` из upstream напрямую** — чтобы избежать конфликтов.
3. Делает **коммит** этих файлов.
4. Мержит остальное с `-X theirs`.
5. Запускает `scripts/remove-ads.sh` — вырезает рекламу.
6. Коммитит изменения и пушит в `main`.

**Это значит:** когда Санаи выпускает обновление, реклама вырезается **автоматически**, а конфликтов **нет**.

### 2. `Build and Release` — сборка и публикация релизов

Запускается по тегу `v*` или вручную:

1. **`Set version from tag`** — извлекает версию из тега и записывает в `internal/config/version` и `scripts/remove-ads.sh`.
2. Вырезает рекламу (`scripts/remove-ads.sh`).
3. Собирает фронтенд (`npm run build`).
4. Собирает Go-бинарник.
5. Скачивает Xray core с XTLS.
6. Упаковывает всё в `x-ui-linux-amd64.tar.gz` + `.sha256`.
7. Публикует релиз.

**Это значит:** вам **не надо менять** `internal/config/version` вручную. `release.yml` **сам** подставит версию из тега.

### Как выпустить новую версию

1. **Создайте тег** с новым номером:

   ```bash
   cd /root/pure-3x-ui
   git pull
   git tag v3.9.4
   git push origin v3.9.4
   ```

   Или **через GitHub**: `Releases → Draft a new release → Choose a tag → v3.9.4 → Publish release`.

2. **GitHub Actions** сам соберёт релиз `v3.9.4` с **правильной версией** внутри.

3. **Кнопка «Обновить»** в панели станет **активной** (потому что `v3.9.4 > 3.9.3`).

4. **Нажмите** → панель обновится до `3.9.4`.

### Важное правило

**Тег = версия в архиве.** `release.yml` подставляет версию из тега **автоматически**. Вам **не надо**:
- менять `internal/config/version` вручную,
- менять `scripts/remove-ads.sh` вручную.

---

## Как это работает: синхронизация и релизы

### Что попадает в релиз, а что нет

| Что | Когда попадает в `main` | Когда попадает в релиз |
|---|---|---|
| **Коммиты Санаи** (багфиксы) | ✅ Автоматически (`Sync Upstream`) | ⏳ Только при **создании нового тега** |
| **Удаление рекламы** | ✅ Автоматически | ✅ Всегда |
| **jsDelivr-замены** | ✅ Автоматически | ✅ Всегда |
| **Брендирование** | ✅ Автоматически | ✅ Всегда |

**Пример:**

- Санаи **запушил 3 багфикса** в `main` — но **не выпустил релиз**.
- Ваш `Sync Upstream` **подтянул** эти багфиксы в `main`.
- **В `main`** — багфиксы **есть**.
- **В релизе `v3.9.3`** — багфиксов **нет** (потому что релиз **собран раньше**).
- Чтобы багфиксы **попали в релиз** — надо **создать новый тег** (`v3.9.4`).

### Когда стоит выпускать новый релиз

- ✅ Санаи выпустил **новый стабильный релиз** (например, `v3.10.0`).
- ✅ Накопились **важные багфиксы**, которые нужны **в бинарнике**.
- ✅ Вы **сами** внесли **значимые изменения**.
- ❌ **Не стоит** выпускать новый релиз **на каждый коммит** Санаи.

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
| Спонсорские слоты | Удалены |
| Отдельная страница `/sponsors` | Удалена |
| Кнопка документации (`DocsButton`) | Удалена |
| `raw.githubusercontent.com` | `cdn.jsdelivr.net/gh/` (работает из РФ) |
| `install.sh` указывает на MHSanaei | Свой `install.sh` |
| Кнопка «Обновить» тянет с MHSanaei | Тянет из **этого** репозитория |
| Версия в `internal/config/version` | **Авто-версия** из тега |
| Локали конфликтуют при merge | **Локали не трогаются** — merge гладкий |
| Ручное обновление | Автосинхронизация + автосборка |
| Релизы на MHSanaei/3x-ui | Релизы на vermiliondevil-web/pure-3x-ui |

---

## Происхождение и лицензия

### Это форк

`pure-3x-ui` — **производная работа** (форк) от оригинального проекта [3x-ui](https://github.com/MHSanaei/3x-ui), созданного [MHSanaei](https://github.com/MHSanaei).

**Что это значит:**

- Проект **не является** оригинальной разработкой.
- Основа — код [MHSanaei/3x-ui](https://github.com/MHSanaei/3x-ui).
- Все изменения (удаление рекламы, jsDelivr, брендирование) — **надстройка** над оригиналом.
- Оригинальный автор **не несёт ответственности** за этот форк.

### Лицензия AGPL-3.0

Проект распространяется под лицензией **GNU Affero General Public License v3.0** (AGPL-3.0) — **той же**, что и оригинальный 3x-ui.

**Что это значит:**

- ✅ Можно **использовать** бесплатно.
- ✅ Можно **изменять** и **распространять**.
- ✅ Можно **делать форки**.
- ⚠️ **Обязательно** сохранять **ту же лицензию** (AGPL-3.0).
- ⚠️ **Обязательно** указывать **автора оригинала**.
- ⚠️ Если вы **даёте доступ к панели по сети** — вы **обязаны** предоставить **исходный код** вашей модифицированной версии.
- ⚠️ **Нельзя** делать **закрытые** форки.

**Для этого форка:**

- ✅ Исходный код **открыт** на GitHub.
- ✅ Все изменения **публикуются**.
- ✅ Оригинальный автор **указан**.
- ✅ Лицензия **сохранена** (AGPL-3.0).

### Ссылки

- **Оригинал:** https://github.com/MHSanaei/3x-ui
- **Автор оригинала:** [MHSanaei](https://github.com/MHSanaei)
- **Этот форк:** https://github.com/vermiliondevil-web/pure-3x-ui
- **Автор форка:** [vermiliondevil-web](https://github.com/vermiliondevil-web)
- **Текст лицензии:** [LICENSE](LICENSE)

---

## ⚠️ Важно: российские VPS-провайдеры и блокировка VPN

Если вы используете **российский VPS-провайдер** (Timeweb, RocketCloud, Selectel, Beget, RUVDS и другие), **учтите**:

### Провайдеры обязаны блокировать VPN

Согласно поправкам **«Антифрод 3.0»** (Минцифры, 2026), российские хостинг-провайдеры **обязаны**:

- проверять клиентов по **реестру Роскомнадзора**;
- **отказывать** в обслуживании владельцам VPN/прокси;
- **прекращать** обслуживание по запросу силовых органов.

**На практике:** даже если ваш VPS работает, провайдер может **фильтровать трафик** через **ТСПУ** на **своём уровне**.

### Что это значит для вас

**Симптомы «сволочного» провайдера:**

- `raw.githubusercontent.com` **не открывается** (TLS-хендшейк рвётся после `Server hello`).
- VPN-подключения **работают**, но **скорость** падает.
- Отдельные **сайты** (Meduza, BBC, DW) **не открываются** даже через VPN.

### Что делать

**Вариант А: сменить провайдера** (рекомендую)

- **Зарубежный** хостер (Нидерланды, Германия, Финляндия).
- **Российский** без цензуры: **AezaNet**, **VDSina**, **Doubleservers**.

**Вариант Б: остаться на российском, но использовать jsDelivr**

Наш `install.sh` **уже** работает через **jsDelivr** — это **обход** блокировки `raw.githubusercontent.com`.

**Вариант В: обход на уровне сети**

- **IPv6** — часто **менее цензурирован**.
- **DoH/DoT** для DNS.
- **VPN/прокси** для исходящих запросов.

---

## 🖥️ Инженерный сервер из дешёвого VPS

Не обязательно иметь **мощный сервер** для сборки и отладки. Даже **VPS за 100–200₽/мес** подойдёт — если правильно его настроить.

### Минимальные требования

| Ресурс | Минимум | Рекомендую |
|---|---|---|
| **RAM** | 1 ГБ | **2 ГБ** (для `npm install` + `go build`) |
| **Swap** | 2 ГБ | 2 ГБ (обязательно!) |
| **Диск** | 10 ГБ | **20 ГБ** (node_modules ~500 МБ) |
| **CPU** | 1 ядро | 2 ядра (сборка быстрее) |
| **ОС** | Ubuntu 22.04 | Ubuntu 22.04 / 24.04 |

### Что установить

```bash
# 1. Swap (критично для слабого VPS)
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab

# 2. Базовые пакеты
apt-get update
apt-get install -y git curl wget unzip build-essential ca-certificates libsqlite3-dev

# 3. Go 1.27.1
cd /usr/local
wget -q https://go.dev/dl/go1.27.1.linux-amd64.tar.gz
tar -xzf go1.27.1.linux-amd64.tar.gz
rm go1.27.1.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
source ~/.bashrc

# 4. Node.js 26
curl -fsSL https://deb.nodesource.com/setup_26.x | bash -
apt-get install -y nodejs
```

### Проблемы и решения

| Проблема | Решение |
|---|---|
| `Could not resolve host` | Пересоздать `/etc/resolv.conf` с `1.1.1.1` + `chattr +i` |
| `raw.githubusercontent.com` timeout | Использовать **jsDelivr** |
| `npm install` зависает | Swap обязателен; `npm install --prefer-offline` |
| `tsc --noEmit` долго | **Отключено** в `remove-ads.sh` (запускается в GitHub Actions) |
| `go build` падает | `apt-get install -y libsqlite3-dev` |
| Утечка памяти | Ограничить через systemd или авто-рестарт |
| OOM Killer | Добавить swap или увеличить RAM |

---

## Скриншоты

<!-- Сюда можно вставить скриншоты панели без донатов -->

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
