#!/bin/bash
# ═══════════════════════════════════════════════════════
# FULL SITE DEPLOY — arq.clinic
# Run: chmod +x deploy-full.sh && ./deploy-full.sh
# ═══════════════════════════════════════════════════════
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SERVER="root@68.183.85.236"
SSH_KEY="$HOME/.ssh/arq-deploy"
WEBROOT="/var/www/arq"

echo ""
echo "═══════════════════════════════════════"
echo "  Deploying arq.clinic — full site"
echo "═══════════════════════════════════════"
echo ""

# 1. Create directory structure on server
echo "→ Creating directory structure..."
ssh -i "$SSH_KEY" "$SERVER" "mkdir -p ${WEBROOT}/blog ${WEBROOT}/images"

# 2. Upload homepage as index.html
echo "→ Uploading homepage..."
scp -i "$SSH_KEY" "$SCRIPT_DIR/arq-v40.html" "$SERVER:${WEBROOT}/index.html"

# 3. Upload all condition pages (root level HTML)
echo "→ Uploading condition pages..."
for page in pcos thyroid diabetes weight-loss hair-loss testosterone vitamin-deficiency fatigue sleep skin focus blood-pressure panel hrv recovery iv-infusions; do
  if [ -f "$SCRIPT_DIR/${page}.html" ]; then
    scp -i "$SSH_KEY" "$SCRIPT_DIR/${page}.html" "$SERVER:${WEBROOT}/${page}.html"
  fi
done

# 4. Upload sports pages
echo "→ Uploading sports pages..."
for page in pickleball padel runners strength performance hyrox endurance; do
  if [ -f "$SCRIPT_DIR/${page}.html" ]; then
    scp -i "$SSH_KEY" "$SCRIPT_DIR/${page}.html" "$SERVER:${WEBROOT}/${page}.html"
  fi
done

# 5. Upload all blog posts
echo "→ Uploading blog posts..."
scp -i "$SSH_KEY" "$SCRIPT_DIR"/blog/*.html "$SERVER:${WEBROOT}/blog/"

# 6. Upload images
echo "→ Uploading images..."
scp -i "$SSH_KEY" "$SCRIPT_DIR"/images/*.svg "$SCRIPT_DIR"/images/*.jpg "$SCRIPT_DIR"/images/*.png "$SERVER:${WEBROOT}/images/" 2>/dev/null || true

# 7. Upload SEO files
echo "→ Uploading SEO files..."
scp -i "$SSH_KEY" "$SCRIPT_DIR/sitemap.xml" "$SERVER:${WEBROOT}/sitemap.xml"
scp -i "$SSH_KEY" "$SCRIPT_DIR/robots.txt" "$SERVER:${WEBROOT}/robots.txt"

# 8. Upload favicons
echo "→ Uploading favicons..."
scp -i "$SSH_KEY" "$SCRIPT_DIR/favicon.ico" "$SCRIPT_DIR/favicon.svg" "$SCRIPT_DIR/favicon-180.png" "$SERVER:${WEBROOT}/" 2>/dev/null || true

# 9. Update nginx config for clean URLs
echo "→ Updating nginx config..."
ssh -i "$SSH_KEY" "$SERVER" 'cat > /etc/nginx/sites-available/arq << "NGINX"
server {
    listen 80;
    server_name arq.clinic www.arq.clinic;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name arq.clinic www.arq.clinic;
    root /var/www/arq;
    index index.html;

    ssl_certificate /etc/letsencrypt/live/arq.clinic/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/arq.clinic/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    location / {
        try_files $uri $uri/index.html $uri.html $uri/ =404;
    }

    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml text/javascript image/svg+xml;
    gzip_vary on;
    gzip_min_length 1000;

    location ~* \.(jpg|jpeg|png|gif|ico|svg|css|js|woff|woff2|ttf|eot)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
}
NGINX'

# 10. Fix file permissions (nginx runs as www-data)
echo "→ Setting file permissions..."
ssh -i "$SSH_KEY" "$SERVER" "chown -R www-data:www-data ${WEBROOT} && find ${WEBROOT} -type d -exec chmod 755 {} \; && find ${WEBROOT} -type f -exec chmod 644 {} \;"

# 11. Enable site and reload nginx
echo "→ Reloading nginx..."
ssh -i "$SSH_KEY" "$SERVER" "ln -sf /etc/nginx/sites-available/arq /etc/nginx/sites-enabled/arq && nginx -t && systemctl reload nginx"

echo ""
echo "═══════════════════════════════════════"
echo "  ✓ Live at https://arq.clinic"
echo "═══════════════════════════════════════"
echo ""
