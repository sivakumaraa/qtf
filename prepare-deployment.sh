#!/bin/bash
# QuarryForce Namecheap Stellar Deployment Script
# Run this BEFORE uploading to server

echo "=========================================="
echo "QuarryForce - Pre-Deployment Preparation"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Step 1: Check prerequisites
echo -e "${YELLOW}Step 1: Checking prerequisites...${NC}"
command -v node &> /dev/null && echo -e "${GREEN}✓ Node.js installed${NC}" || echo -e "${RED}✗ Node.js not found${NC}"
command -v npm &> /dev/null && echo -e "${GREEN}✓ NPM installed${NC}" || echo -e "${RED}✗ NPM not found${NC}"
echo ""

# Step 2: Clean old builds
echo -e "${YELLOW}Step 2: Cleaning old builds...${NC}"
rm -rf admin-dashboard/build
echo -e "${GREEN}✓ Cleaned build directory${NC}"
echo ""

# Step 3: Install backend dependencies
echo -e "${YELLOW}Step 3: Installing backend dependencies...${NC}"
cd "$(dirname "$0")"
npm install --production 2>/dev/null
echo -e "${GREEN}✓ Backend dependencies installed${NC}"
echo ""

# Step 4: Build admin dashboard
echo -e "${YELLOW}Step 4: Building admin dashboard...${NC}"
cd admin-dashboard
npm install 2>/dev/null
npm run build
if [ -d "build" ]; then
    echo -e "${GREEN}✓ Admin dashboard built successfully${NC}"
else
    echo -e "${RED}✗ Build failed${NC}"
    exit 1
fi
echo ""

# Step 5: Create deployment package
echo -e "${YELLOW}Step 5: Creating deployment package...${NC}"
cd ..
mkdir -p deployment
cp -r admin-dashboard/build deployment/admin
cp index.js deployment/
cp db.js deployment/
cp package.json deployment/
cp package-lock.json deployment/
cp -r uploads deployment/

# Copy environment template
cat > deployment/.env.template << 'EOF'
NODE_ENV=production
PORT=3000
DB_HOST=your-namecheap-db-host.namecheaphosting.com
DB_USER=your_db_username
DB_PASSWORD=your_db_password
DB_NAME=your_db_name
DB_PORT=3306
API_URL=https://api.yourdomain.com
FRONTEND_URL=https://admin.yourdomain.com
EOF

echo -e "${GREEN}✓ Deployment package created in ./deployment${NC}"
echo ""

# Step 6: Create .htaccess for admin dashboard
cat > deployment/admin/.htaccess << 'EOF'
<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteBase /
  RewriteRule ^index\.html$ - [L]
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  RewriteRule . /index.html [L]
</IfModule>
EOF

echo -e "${GREEN}✓ Created .htaccess for React routing${NC}"
echo ""

# Step 7: Display next steps
echo -e "${GREEN}=========================================="
echo "Preparation Complete! ✓"
echo "==========================================${NC}"
echo ""
echo "Next steps:"
echo "1. Create .env file (copy from .env.template)"
echo "2. Upload 'deployment' folder via FTP to /public_html/"
echo "3. Follow NAMECHEAP_STELLAR_DEPLOYMENT.md for server setup"
echo ""
echo "Deployment folder contents:"
ls -la deployment/
echo ""
