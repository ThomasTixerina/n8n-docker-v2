#!/bin/bash

# ===========================================
# Validation Test Script
# ===========================================
# Este script verifica que todos los archivos
# necesarios existen y son válidos
# ===========================================

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASSED=0
FAILED=0

echo "=========================================="
echo "   Repository Validation Tests"
echo "=========================================="
echo ""

# Función de test
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo -n "Testing $test_name... "
    if eval "$test_command" > /dev/null 2>&1; then
        echo -e "${GREEN}PASS${NC}"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        ((FAILED++))
        return 1
    fi
}

# Test 1: Archivos esenciales existen
echo "1. Essential Files:"
run_test "README.md" "test -f README.md"
run_test "SETUP_GUIDE.md" "test -f SETUP_GUIDE.md"
run_test "docker-compose.yml" "test -f docker-compose.yml"
run_test ".env.example" "test -f .env.example"
run_test ".gitignore" "test -f .gitignore"

echo ""
echo "2. Documentation Files:"
run_test "CONTRIBUTING.md" "test -f CONTRIBUTING.md"
run_test "SECURITY.md" "test -f SECURITY.md"
run_test "HOW_TO_CREATE_THIS.md" "test -f HOW_TO_CREATE_THIS.md"

echo ""
echo "3. Utility Scripts:"
run_test "health_check.sh" "test -f health_check.sh"
run_test "backup.sh" "test -f backup.sh"
run_test "restore_backup.sh" "test -f restore_backup.sh"

echo ""
echo "4. Script Permissions:"
run_test "health_check.sh is executable" "test -x health_check.sh"
run_test "backup.sh is executable" "test -x backup.sh"
run_test "restore_backup.sh is executable" "test -x restore_backup.sh"

echo ""
echo "5. Configuration Validation:"
run_test "docker-compose.yml is valid" "docker compose config > /dev/null 2>&1"

echo ""
echo "6. .env.example completeness:"
run_test "POSTGRES_PASSWORD in .env.example" "grep -q 'POSTGRES_PASSWORD' .env.example"
run_test "N8N_ENCRYPTION_KEY in .env.example" "grep -q 'N8N_ENCRYPTION_KEY' .env.example"
run_test "TUNNEL_TOKEN in .env.example" "grep -q 'TUNNEL_TOKEN' .env.example"
run_test "N8N_HOST in .env.example" "grep -q 'N8N_HOST' .env.example"

echo ""
echo "7. .gitignore security:"
run_test ".env in .gitignore" "grep -q '^\\.env$' .gitignore"
run_test "*.log in .gitignore" "grep -q '\\.log' .gitignore"
run_test "backups in .gitignore" "grep -q 'backups' .gitignore"

echo ""
echo "8. Documentation quality:"
run_test "README has description" "grep -q 'Descripción' README.md"
run_test "README has quick start" "grep -q 'Inicio Rápido' README.md"
run_test "SETUP_GUIDE has TOC" "grep -q 'Tabla de Contenidos' SETUP_GUIDE.md"
run_test "SETUP_GUIDE has troubleshooting" "grep -q 'Solución de Problemas' SETUP_GUIDE.md"

echo ""
echo "9. Security checks:"
run_test "No .env file committed" "! test -f .env"
run_test "No hardcoded passwords in docker-compose" "! grep -i 'password.*=' docker-compose.yml | grep -v '\${'"

echo ""
echo "=========================================="
echo "   Test Summary"
echo "=========================================="
echo -e "Passed: ${GREEN}${PASSED}${NC}"
echo -e "Failed: ${RED}${FAILED}${NC}"
echo "=========================================="

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed! ✓${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed! ✗${NC}"
    exit 1
fi
