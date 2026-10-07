#!/bin/bash
# scripts/remove-ads.sh
# Удаляет рекламу, донаты и спонсорскую инфраструктуру из pure-3x-ui.
# Идемпотентен: повторный запуск ничего не сломает.
# Запускать из корня репозитория: bash scripts/remove-ads.sh

set -e
cd "$(dirname "$0")/.."

REPO_ROOT="$(pwd)"
BACKUP_BRANCH=""
FAIL=0

echo "==> remove-ads.sh: старт в $REPO_ROOT"

# ---------- 0. Брендирование панели: обновления с нашего репозитория ----------
echo "[0/5] Брендируем панель (ссылки на наш репозиторий)..."

# 0.1. panel.go — ссылки на GitHub API и raw
PANEL_GO=internal/web/service/panel/panel.go
if [[ -f "$PANEL_GO" ]]; then
  sed -i 's|api.github.com/repos/MHSanaei/3x-ui|api.github.com/repos/vermiliondevil-web/pure-3x-ui|g' "$PANEL_GO" 2>/dev/null || true
  sed -i 's|raw.githubusercontent.com/MHSanaei/3x-ui|raw.githubusercontent.com/vermiliondevil-web/pure-3x-ui|g' "$PANEL_GO" 2>/dev/null || true
fi

# Брендирование версии: устанавливаем нашу версию (совпадает с последним тегом)
VERSION_FILE=internal/config/version
if [[ -f "$VERSION_FILE" ]]; then
  echo -n "3.9.1" > "$VERSION_FILE"
fi

# 0.2. update.sh — заменяем на нашу обёртку над install.sh
cat > update.sh <<'UPDEOF'
#!/bin/bash
# pure-3x-ui updater — вызывает install.sh из нашего репозитория.

set -e

REPO="vermiliondevil-web/pure-3x-ui"
BRANCH="main"
INSTALL_URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}/install.sh"

echo "==> pure-3x-ui updater"
echo "==> Скачиваем install.sh из ${REPO}..."

bash <(curl -Ls "${INSTALL_URL}")
UPDEOF
chmod +x update.sh

# ---------- 1. Удаляем файлы рекламы ----------
echo "[1/5] Удаляем файлы рекламы..."
rm -rf frontend/src/components/sponsor/ 2>/dev/null || true
rm -f  frontend/src/api/queries/useSponsorsQuery.ts 2>/dev/null || true
rm -f  frontend/src/lib/sponsors.ts 2>/dev/null || true
rm -f  frontend/src/test/sponsors.test.tsx 2>/dev/null || true
rm -rf frontend/src/pages/sponsors/ 2>/dev/null || true

# ---------- 2. Правим AppSidebar.tsx ----------
echo "[2/5] Правим AppSidebar.tsx..."
ASB=frontend/src/layouts/AppSidebar.tsx
if [[ -f "$ASB" ]]; then
  # Удаляем импорты
  sed -i '/^  CrownOutlined,$/d' "$ASB" 2>/dev/null || true
  sed -i '/^  HeartOutlined,$/d' "$ASB" 2>/dev/null || true
  sed -i '/^import SponsorSlot from/d' "$ASB" 2>/dev/null || true
  # Убираем DocsButton (кнопка документации)
  sed -i '/^  ReadOutlined,$/d' "$ASB" 2>/dev/null || true
  sed -i "/^const DOCS_URL = /d" "$ASB" 2>/dev/null || true
  sed -i '/<DocsButton /d' "$ASB" 2>/dev/null || true

  python3 - "$ASB" <<'PYEOF'
import re, sys
p = sys.argv[1]
s = open(p, encoding='utf-8').read()
s = re.sub(r"function DocsButton\([^)]*\)\s*\{[^{}]*\}\s*\n?", "", s, flags=re.DOTALL)
open(p, 'w', encoding='utf-8').write(s)
PYEOF

  # Удаляем DONATE_URL
  sed -i "/^const DONATE_URL = /d" "$ASB" 2>/dev/null || true

  # Удаляем sponsors: CrownOutlined
  sed -i '/^  sponsors: CrownOutlined,$/d' "$ASB" 2>/dev/null || true

  # Удаляем | 'sponsors' из union-типа
  sed -i "/^  | 'sponsors'$/d" "$ASB" 2>/dev/null || true

  # Удаляем функцию DonateButton — от "function DonateButton" до следующей "}"
  python3 - "$ASB" <<'PYEOF'
import re, sys
p = sys.argv[1]
s = open(p, encoding='utf-8').read()
# Удаляем function DonateButton(...) { ... } (простой случай без вложенных })
s = re.sub(r"function DonateButton\([^)]*\)\s*\{[^{}]*\}\s*\n?", "", s, flags=re.DOTALL)
open(p, 'w', encoding='utf-8').write(s)
PYEOF

  # Удаляем вызовы <DonateButton ... /> и <SponsorSlot ... />
  sed -i '/<DonateButton /d' "$ASB" 2>/dev/null || true
  sed -i '/<SponsorSlot /d' "$ASB" 2>/dev/null || true
fi

# ---------- 3. Правим LoginPage.tsx ----------
echo "[3/5] Правим LoginPage.tsx..."
LGP=frontend/src/pages/login/LoginPage.tsx
if [[ -f "$LGP" ]]; then
  sed -i '/<SponsorSlot /d' "$LGP" 2>/dev/null || true
  sed -i '/^import SponsorSlot from/d' "$LGP" 2>/dev/null || true
fi

# ---------- 4. Правим routes, usePageTitle, CommandPalette, endpoints ----------
echo "[4/5] Правим routes.tsx, usePageTitle.ts, CommandPalette.tsx, endpoints.ts..."

# 4.1 routes.tsx — удаляем маршрут и импорт SponsorsPage
RTS=frontend/src/routes.tsx
if [[ -f "$RTS" ]]; then
  python3 - "$RTS" <<'PYEOF'
import re, sys
p = sys.argv[1]
s = open(p, encoding='utf-8').read()
# Удаляем строку с маршрутом sponsors
s = re.sub(r"^\s*\{\s*path:\s*'sponsors'[^\n]*\}\s*,?\s*\n", "", s, flags=re.MULTILINE)
# Удаляем импорт SponsorsPage (если остался)
s = re.sub(r"^import[^\n]*SponsorsPage[^\n]*\n", "", s, flags=re.MULTILINE)
open(p, 'w', encoding='utf-8').write(s)
PYEOF
fi

# 4.2 usePageTitle.ts — удаляем ключ '/sponsors'
UPT=frontend/src/hooks/usePageTitle.ts
if [[ -f "$UPT" ]]; then
  sed -i "/'\/sponsors':/d" "$UPT" 2>/dev/null || true
fi

# 4.3 CommandPalette.tsx — удаляем объект { path: '/sponsors', ... } и импорт CrownOutlined
CP=frontend/src/components/command-palette/CommandPalette.tsx
if [[ -f "$CP" ]]; then
  python3 - "$CP" <<'PYEOF'
import re, sys
p = sys.argv[1]
s = open(p, encoding='utf-8').read()
# Удаляем блок { ... path: '/sponsors' ... },
s = re.sub(r"\{\s*[^{}]*?path:\s*'/sponsors'[^{}]*?\}\s*,?\s*\n", "", s, flags=re.DOTALL)
open(p, 'w', encoding='utf-8').write(s)
PYEOF
  sed -i '/^  CrownOutlined,$/d' "$CP" 2>/dev/null || true
fi

# 4.4 endpoints.ts — удаляем объект с '/sponsors'
EP=frontend/src/pages/api-docs/endpoints.ts
if [[ -f "$EP" ]]; then
  python3 - "$EP" <<'PYEOF'
import re, sys
p = sys.argv[1]
s = open(p, encoding='utf-8').read()
# Удаляем блок { method: '...', path: '/sponsors', ... },
s = re.sub(r"\{\s*[^{}]*?path:\s*'/sponsors'[^{}]*?\}\s*,?\s*\n", "", s, flags=re.DOTALL)
open(p, 'w', encoding='utf-8').write(s)
PYEOF
fi

# ---------- 5. Чистим локали через Python ----------
echo "[5/5] Чистим локали через Python..."
python3 <<'PYEOF'
import json, glob, os

for path in sorted(glob.glob('internal/web/translation/*.json')):
    try:
        with open(path, encoding='utf-8') as f:
            data = json.load(f)
    except json.JSONDecodeError as e:
        print(f"SKIP (bad JSON): {path} — {e}")
        continue

    def strip(obj):
        if isinstance(obj, dict):
            obj.pop('donate', None)
            obj.pop('sponsors', None)
            for v in obj.values():
                strip(v)
        elif isinstance(obj, list):
            for v in obj:
                strip(v)

    strip(data)

    with open(path, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=4, ensure_ascii=False)
        f.write('\n')
    print(f"OK: {path}")
PYEOF

# ---------- 6. Проверка синтаксиса ----------
echo "==> Проверяем TypeScript..."
cd frontend
if ! npx tsc --noEmit 2>&1 | tee /tmp/tsc.log; then
  echo ""
  echo "ОШИБКА: tsc --noEmit не прошёл. Лог: /tmp/tsc.log"
  echo "Откатите изменения: cd .. && git checkout -- . && git clean -fd frontend/src"
  exit 1
fi
cd ..

echo ""
echo "==> Готово. Проверьте:"
echo "    git status"
echo "    git diff --stat"
echo ""
echo "Если всё устраивает:"
echo "    git add -A"
echo "    git commit --no-verify -m 'chore: strip ads and donations'"
