#!/bin/bash
# Project Validation & Setup Script
# Cross-platform: Linux, macOS, Docker
# 
# Usage:
#   ./validate-project.sh          # Run validation checks
#   ./validate-project.sh setup    # Install dependencies
#   ./validate-project.sh build    # Run full build

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
CHECKS_PASSED=0
CHECKS_FAILED=0

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  AWS Project Validation & Setup Script                 ║${NC}"
echo -e "${BLUE}║  Java 21 / Multi-Version Support                       ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Helper functions
check_command() {
    local cmd=$1
    local name=$2
    if command -v "$cmd" &> /dev/null; then
        local version=$($cmd --version 2>/dev/null | head -1 || echo "installed")
        echo -e "${GREEN}✓${NC} $name installed ($version)"
        ((CHECKS_PASSED++))
    else
        echo -e "${RED}✗${NC} $name NOT found - install to build"
        ((CHECKS_FAILED++))
    fi
}

check_file() {
    local file=$1
    local name=$2
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} $name exists"
        ((CHECKS_PASSED++))
    else
        echo -e "${RED}✗${NC} $name MISSING"
        ((CHECKS_FAILED++))
    fi
}

# Main command dispatcher
case "${1:-validate}" in
    validate)
        echo -e "${BLUE}[1/3] Checking Project Structure${NC}"
        echo ""
        check_file "pom.xml" "Parent pom.xml"
        check_file "Dockerfile" "Dockerfile"
        check_file "Jenkinsfile" "Jenkinsfile"
        check_file "server/pom.xml" "Server module"
        check_file "webapp/pom.xml" "Webapp module"
        check_file "README.md" "Documentation"
        
        echo ""
        echo -e "${BLUE}[2/3] Checking Build Tools${NC}"
        echo ""
        check_command "java" "Java"
        check_command "mvn" "Maven"
        check_command "docker" "Docker"
        check_command "git" "Git"
        
        echo ""
        echo -e "${BLUE}[3/3] Checking Configuration${NC}"
        echo ""
        
        if grep -q "java.version.*21" pom.xml 2>/dev/null; then
            echo -e "${GREEN}✓${NC} Java 21 configured"
            ((CHECKS_PASSED++))
        else
            echo -e "${RED}✗${NC} Java 21 not found in pom.xml"
            ((CHECKS_FAILED++))
        fi
        
        if grep -q "ARG JAVA_VERSION" Dockerfile 2>/dev/null; then
            echo -e "${GREEN}✓${NC} Dockerfile supports version arguments"
            ((CHECKS_PASSED++))
        else
            echo -e "${RED}✗${NC} Dockerfile missing version arguments"
            ((CHECKS_FAILED++))
        fi
        
        if grep -q "pipeline {" Jenkinsfile 2>/dev/null; then
            echo -e "${GREEN}✓${NC} Jenkinsfile is valid pipeline"
            ((CHECKS_PASSED++))
        else
            echo -e "${RED}✗${NC} Jenkinsfile invalid"
            ((CHECKS_FAILED++))
        fi
        
        echo ""
        echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
        echo -e "${GREEN}Passed:${NC} $CHECKS_PASSED | ${RED}Failed:${NC} $CHECKS_FAILED"
        echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
        echo ""
        
        if [ $CHECKS_FAILED -eq 0 ]; then
            echo -e "${GREEN}✓ Project is ready to build!${NC}"
            echo ""
            echo "Next steps:"
            echo "  1. mvn clean package          # Build locally"
            echo "  2. docker build -t aws-project:latest .  # Build Docker image"
            echo "  3. Create Jenkins job with Jenkinsfile"
            echo ""
            exit 0
        else
            echo -e "${RED}✗ Fix $CHECKS_FAILED issue(s) before building${NC}"
            echo ""
            exit 1
        fi
        ;;
    
    setup)
        echo -e "${BLUE}Setup Instructions${NC}"
        echo ""
        echo "Install required tools:"
        echo ""
        echo "  macOS (Homebrew):"
        echo "    brew install java maven docker"
        echo ""
        echo "  Ubuntu/Debian:"
        echo "    sudo apt-get install -y openjdk-21-jdk maven docker.io"
        echo ""
        echo "  Fedora/RHEL:"
        echo "    sudo dnf install java-21-openjdk maven docker"
        echo ""
        echo "  Then verify:"
        echo "    java -version"
        echo "    mvn -version"
        echo "    docker --version"
        echo ""
        exit 0
        ;;
    
    build)
        echo -e "${BLUE}Building Project...${NC}"
        echo ""
        
        # Run validation first
        if ! "$0" validate > /dev/null 2>&1; then
            echo -e "${RED}Validation failed. Fix issues and try again.${NC}"
            exit 1
        fi
        
        # Build with Maven
        echo -e "${BLUE}Running Maven build...${NC}"
        mvn clean package -DskipTests
        
        echo ""
        echo -e "${GREEN}✓ Build successful!${NC}"
        echo ""
        echo "Build artifacts:"
        echo "  server/target/server.jar"
        echo "  webapp/target/webapp.war"
        echo ""
        
        # Offer Docker build
        read -p "Build Docker image? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${BLUE}Building Docker image...${NC}"
            docker build -t aws-project:latest .
            echo -e "${GREEN}✓ Docker image built successfully!${NC}"
            echo ""
            echo "Run container:"
            echo "  docker run -p 8080:8080 aws-project:latest"
            echo ""
        fi
        exit 0
        ;;
    
    *)
        echo "Usage: $0 {validate|setup|build}"
        echo ""
        echo "Commands:"
        echo "  validate  - Check project configuration (default)"
        echo "  setup     - Show installation instructions"
        echo "  build     - Full Maven + Docker build"
        echo ""
        exit 1
        ;;
esac
