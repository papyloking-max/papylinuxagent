#!/data/data/com.termux/files/usr/bin/bash
# PapylinuxAgent helper - Fix Next.js in Termux + Network access

echo "=== PapylinuxAgent / Next.js Termux Fix ==="
echo ""

cd "$(dirname "$0")" 2>/dev/null || cd ~/nationagent 2>/dev/null || cd .

echo "Applying SWC fallback + network binding..."

# Best working command for Termux
NEXT_SWc_FORCE_FALLBACK=1 npm run dev -- -H 0.0.0.0
