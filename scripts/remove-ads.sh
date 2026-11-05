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
echo "[0/8] Брендируем панель (ссылки на наш репозиторий)..."

# 0.1. Заменяем MHSanaei/3x-ui → vermiliondevil-web/pure-3x-ui в коде панели.
# README.md НЕ трогаем: там ссылки на upstream (MHSanaei/3x-ui) должны
# остаться — AGPL требует указания авторства оригинала.
for f in install.sh update.sh x-ui.sh internal/web/service/panel/panel.go; do
  if [[ -f "$f" ]]; then
    sed -i 's|MHSanaei/3x-ui|vermiliondevil-web/pure-3x-ui|g' "$f" 2>/dev/null || true
  fi
done

# 0.2. Заменяем jsDelivr → raw.githubusercontent.com
# README.md НЕ трогаем по той же причине.
for f in install.sh update.sh x-ui.sh internal/web/service/panel/panel.go; do
  if [[ -f "$f" ]]; then
    sed -i 's|https://cdn\.jsdelivr\.net/gh/vermiliondevil-web/pure-3x-ui@main/|https://raw.githubusercontent.com/vermiliondevil-web/pure-3x-ui/main/|g' "$f" 2>/dev/null || true
  fi
done

# Fallback для dev-архива больше не нужен.
sed -i '/# Восстанавливаем fallback для dev-архива/d' install.sh 2>/dev/null || true
sed -i '/# jsDelivr не отдаёт >20 МБ/d' install.sh 2>/dev/null || true

# Версию НЕ трогаем — она устанавливается через release.yml (Set version from tag).

# ---------- 1. Удаляем файлы рекламы ----------
echo "[1/8] Удаляем файлы рекламы..."
rm -rf frontend/src/components/sponsor/ 2>/dev/null || true
rm -f  frontend/src/api/queries/useSponsorsQuery.ts 2>/dev/null || true
rm -f  frontend/src/lib/sponsors.ts 2>/dev/null || true
rm -f  frontend/src/test/sponsors.test.tsx 2>/dev/null || true
rm -rf frontend/src/pages/sponsors/ 2>/dev/null || true
rm -f  internal/web/service/panel/sponsor_test.go 2>/dev/null || true

# Заменяем sponsor.go на пустышку (убирает утечку sponsors.sanaei.dev)
cat > internal/web/service/panel/sponsor.go << 'SPONSOR_EOF'
package panel

// Sponsor is a stub. The upstream sponsor feature is disabled in this fork.
type Sponsor struct {
	ID     string   `json:"id"`
	Name   string   `json:"name"`
	Enable *bool    `json:"enable,omitempty"`
	Slots  []string `json:"slots"`
}

// SponsorList is a stub.
type SponsorList struct {
	Sponsors []Sponsor `json:"sponsors"`
}

// GetSponsors is a stub that returns an empty list without any network request.
func (s *PanelService) GetSponsors() (*SponsorList, error) {
	return &SponsorList{Sponsors: []Sponsor{}}, nil
}

// GetSponsorLogo is a stub that returns an empty image without any network request.
func (s *PanelService) GetSponsorLogo(name string) ([]byte, string, error) {
	return []byte{}, "image/png", nil
}
SPONSOR_EOF

# ---------- 2. Правим AppSidebar.tsx ----------
echo "[2/8] Правим AppSidebar.tsx..."
ASB=frontend/src/layouts/AppSidebar.tsx
if [[ -f "$ASB" ]]; then
  sed -i '/^  CrownOutlined,$/d' "$ASB" 2>/dev/null || true
  sed -i '/^  HeartOutlined,$/d' "$ASB" 2>/dev/null || true
  sed -i '/^import SponsorSlot from/d' "$ASB" 2>/dev/null || true
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

  sed -i "/^const DONATE_URL = /d" "$ASB" 2>/dev/null || true
  sed -i '/^  sponsors: CrownOutlined,$/d' "$ASB" 2>/dev/null || true
  sed -i "/^  | 'sponsors'$/d" "$ASB" 2>/dev/null || true

  python3 - "$ASB" <<'PYEOF'
import re, sys
p = sys.argv[1]
s = open(p, encoding='utf-8').read()
s = re.sub(r"function DonateButton\([^)]*\)\s*\{[^{}]*\}\s*\n?", "", s, flags=re.DOTALL)
open(p, 'w', encoding='utf-8').write(s)
PYEOF

  sed -i '/<DonateButton /d' "$ASB" 2>/dev/null || true
  sed -i '/<SponsorSlot /d' "$ASB" 2>/dev/null || true
fi

# ---------- 3. Правим LoginPage.tsx ----------
echo "[3/8] Правим LoginPage.tsx..."
LGP=frontend/src/pages/login/LoginPage.tsx
if [[ -f "$LGP" ]]; then
  sed -i '/<SponsorSlot /d' "$LGP" 2>/dev/null || true
  sed -i '/^import SponsorSlot from/d' "$LGP" 2>/dev/null || true
fi

# ---------- 4. Правим routes, usePageTitle, CommandPalette, endpoints ----------
echo "[4/8] Правим routes.tsx, usePageTitle.ts, CommandPalette.tsx, endpoints.ts..."

# 4.1 routes.tsx
RTS=frontend/src/routes.tsx
if [[ -f "$RTS" ]]; then
  python3 - "$RTS" <<'PYEOF'
import re, sys
p = sys.argv[1]
s = open(p, encoding='utf-8').read()
s = re.sub(r"^\s*\{\s*path:\s*'sponsors'[^\n]*\}\s*,?\s*\n", "", s, flags=re.MULTILINE)
s = re.sub(r"^import[^\n]*SponsorsPage[^\n]*\n", "", s, flags=re.MULTILINE)
open(p, 'w', encoding='utf-8').write(s)
PYEOF
fi

# 4.1b panelRoutes.tsx — remove the SponsorsPage import and route
PRT=frontend/src/routes/panelRoutes.tsx
if [[ -f "$PRT" ]]; then
  python3 - "$PRT" <<'PYEOF'
import re, sys
p = sys.argv[1]
s = open(p, encoding="utf-8").read()
s = re.sub(
    r"^[ \t]*const\s+SponsorsPage\s*=\s*lazy\([^\n]*\n",
    "",
    s,
    flags=re.MULTILINE,
)
s = re.sub(
    r"^[ \t]*\{[^\n]*\bSponsorsPage\b[^\n]*\}[ \t]*,?[ \t]*\n",
    "",
    s,
    flags=re.MULTILINE,
)
open(p, "w", encoding="utf-8").write(s)
PYEOF
fi

# 4.2 usePageTitle.ts
UPT=frontend/src/hooks/usePageTitle.ts
if [[ -f "$UPT" ]]; then
  sed -i "/'\/sponsors':/d" "$UPT" 2>/dev/null || true
fi

# 4.3 CommandPalette.tsx
CP=frontend/src/components/command-palette/CommandPalette.tsx
if [[ -f "$CP" ]]; then
  python3 - "$CP" <<'PYEOF'
import re, sys
p = sys.argv[1]
s = open(p, encoding='utf-8').read()
s = re.sub(r"\{\s*[^{}]*?path:\s*'/sponsors'[^{}]*?\}\s*,?\s*\n", "", s, flags=re.DOTALL)
open(p, 'w', encoding='utf-8').write(s)
PYEOF
  sed -i '/^  CrownOutlined,$/d' "$CP" 2>/dev/null || true
fi

# 4.4 endpoints.ts
EP=frontend/src/pages/api-docs/endpoints.ts
if [[ -f "$EP" ]]; then
  python3 - "$EP" <<'PYEOF'
import re, sys
p = sys.argv[1]
s = open(p, encoding='utf-8').read()
s = re.sub(r"\{\s*[^{}]*?path:\s*'/sponsors'[^{}]*?\}\s*,?\s*\n", "", s, flags=re.DOTALL)
open(p, 'w', encoding='utf-8').write(s)
PYEOF
fi

# ---------- 5. Локали НЕ трогаем ----------
echo "[5/8] Локали не трогаем (реклама в UI удалена через фронтенд)"

# ---------- 6. Проверка синтаксиса ----------
echo "==> Проверка TypeScript пропущена (см. release.yml)"

# ---------- 7. Патч update.sh: НЕ удалять существующее ядро ----------
echo "[7/8] Патчим update.sh: не удалять существующее ядро Xray..."
if [[ -f "update.sh" ]]; then
  if grep -q 'if \[\[ ! -f.*xray-linux' update.sh; then
    echo "SKIP: update.sh уже пропатчен (не удалять ядро)"
  else
    python3 - <<'PYEOF'
import re
p = 'update.sh'
s = open(p, encoding='utf-8').read()
pattern = r'( *)rm \$\{xui_folder\}/bin/xray-linux-\$\(arch\) -f > /dev/null 2>&1'
replacement = (
    r'\1if [[ ! -f "${xui_folder}/bin/xray-linux-$(arch)" ]]; then\n'
    r'\1    rm ${xui_folder}/bin/xray-linux-$(arch) -f > /dev/null 2>&1\n'
    r'\1fi'
)
s2, count = re.subn(pattern, replacement, s)
if count > 0:
    open(p, 'w', encoding='utf-8').write(s2)
    print(f"OK: update.sh пропатчен ({count} совпад.) — ядро не удаляется, если уже есть")
else:
    print("SKIP: паттерн не найден (возможно, уже пропатчен)")
PYEOF
  fi
fi

# ---------- 8. Патч update.sh: сохранить выбранное ядро при распаковке ----------
echo "[8/8] Патчим update.sh: сохраняем ядро при распаковке архива..."
if [[ -f "update.sh" ]]; then
  if grep -q 'xray-linux-\$(arch)\.saved' update.sh; then
    echo "SKIP: update.sh уже пропатчен (сохранение ядра при распаковке)"
  else
    python3 - <<'PYEOF'
p = 'update.sh'
with open(p, encoding='utf-8') as f:
    lines = f.readlines()

out = []
patched = False
i = 0
while i < len(lines):
    line = lines[i]
    if 'tar zxvf x-ui-linux-$(arch).tar.gz' in line and not patched:
        indent = line[:len(line) - len(line.lstrip())]
        # 1. Сохранение — ПЕРЕД tar
        out.append(f'{indent}# Сохраняем текущее ядро (чтобы архив не перезаписал выбранное)\n')
        out.append(f'{indent}if [[ -f "${{xui_folder}}/bin/xray-linux-$(arch)" ]]; then\n')
        out.append(f'{indent}    cp "${{xui_folder}}/bin/xray-linux-$(arch)" "/tmp/xray-linux-$(arch).saved"\n')
        out.append(f'{indent}fi\n')
        # 2. Сам tar
        out.append(line)
        # 3. Пропускаем блок проверки $? — он идёт следом в оригинале:
        #    if [[ $? -ne 0 ]]; then ... fi
        #    Находим его и копируем как есть.
        i += 1
        # Копируем строки до закрывающего fi проверки $?
        check_indent = None
        while i < len(lines):
            cur = lines[i]
            out.append(cur)
            if cur.strip().startswith('if [[ $? -ne 0 ]]; then'):
                check_indent = cur[:len(cur) - len(cur.lstrip())]
            if check_indent is not None and cur.strip() == 'fi':
                # Нашли конец блока проверки $? — выходим
                i += 1
                break
            i += 1
        # 4. Восстановление — ПОСЛЕ проверки $?
        out.append(f'{indent}# Восстанавливаем сохранённое ядро (архив мог его перезаписать)\n')
        out.append(f'{indent}if [[ -f "/tmp/xray-linux-$(arch).saved" ]]; then\n')
        out.append(f'{indent}    cp "/tmp/xray-linux-$(arch).saved" "${{xui_folder}}/bin/xray-linux-$(arch)"\n')
        out.append(f'{indent}    chmod +x "${{xui_folder}}/bin/xray-linux-$(arch)"\n')
        out.append(f'{indent}    rm -f "/tmp/xray-linux-$(arch).saved"\n')
        out.append(f'{indent}fi\n')
        patched = True
        continue
    out.append(line)
    i += 1

if patched:
    with open(p, 'w', encoding='utf-8') as f:
        f.writelines(out)
    print("OK: update.sh пропатчен — ядро сохраняется при распаковке (правильный порядок)")
else:
    print("WARN: строка tar zxvf не найдена")
PYEOF
  fi
fi

echo ""
echo "==> Готово. Проверьте:"
echo "    git status"
echo "    git diff --stat"
echo ""
echo "Если всё устраивает:"
echo "    git add -A"
echo "    git commit --no-verify -m 'chore: strip ads and donations'"
