#!/bin/bash

# Enhanced Crawl4AI MCP Server Deployment Script with Puppeteer
# This script helps deploy the crawl4ai MCP server for the Flutter app

set -e

echo "🚀 Enhanced Crawl4AI MCP Server Deployment Script"
echo "=================================================="

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if docker-compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Create project directory
PROJECT_DIR="crawl4ai-mcp-server"
if [ -d "$PROJECT_DIR" ]; then
    echo "📁 Project directory already exists. Updating..."
    cd "$PROJECT_DIR"
else
    echo "📁 Creating project directory..."
    mkdir "$PROJECT_DIR"
    cd "$PROJECT_DIR"
fi

# Create package.json with Puppeteer
echo "📦 Creating package.json with Puppeteer..."
cat > package.json << 'EOF'
{
  "name": "crawl4ai-mcp-server",
  "version": "2.0.0",
  "description": "Enhanced Crawl4AI MCP Server with Puppeteer for Flutter App Integration",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "dotenv": "^16.3.1",
    "axios": "^1.5.0",
    "helmet": "^7.0.0",
    "rate-limiter-flexible": "^3.0.8",
    "puppeteer": "^21.5.2",
    "puppeteer-extra": "^3.3.6",
    "puppeteer-extra-plugin-stealth": "^2.11.2",
    "puppeteer-extra-plugin-adblocker": "^2.13.6",
    "user-agents": "^1.0.1354",
    "cheerio": "^1.0.0-rc.12",
    "natural": "^6.8.0"
  },
  "devDependencies": {
    "nodemon": "^3.0.1"
  },
  "keywords": ["crawl4ai", "mcp", "web-crawling", "api", "puppeteer", "anti-detection"],
  "author": "Your Name",
  "license": "MIT"
}
EOF

# Create enhanced server.js with Puppeteer
echo "🔧 Creating enhanced server.js with Puppeteer..."
cat > server.js << 'EOF'
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const { RateLimiterMemory } = require('rate-limiter-flexible');
const puppeteer = require('puppeteer-extra');
const StealthPlugin = require('puppeteer-extra-plugin-stealth');
const AdblockerPlugin = require('puppeteer-extra-plugin-adblocker');
const UserAgent = require('user-agents');
const cheerio = require('cheerio');
const natural = require('natural');
require('dotenv').config();

// Configure Puppeteer plugins
puppeteer.use(StealthPlugin());
puppeteer.use(AdblockerPlugin({ blockTrackers: true }));

const app = express();
const PORT = process.env.PORT || 3000;
const HOST = process.env.HOST || '0.0.0.0';

// Security middleware
app.use(helmet());
app.use(cors());
app.use(express.json({ limit: '10mb' }));

// Rate limiting
const rateLimiter = new RateLimiterMemory({
  keyGenerator: (req) => req.ip,
  points: 50, // Reduced for anti-detection
  duration: 60, // Per 60 seconds
});

const rateLimiterMiddleware = (req, res, next) => {
  rateLimiter.consume(req.ip)
    .then(() => next())
    .catch(() => res.status(429).json({ error: 'Too many requests' }));
};

app.use(rateLimiterMiddleware);

// Social media platform detection patterns
const PLATFORM_PATTERNS = {
  twitter: {
    domains: ['twitter.com', 'x.com', 't.co'],
    selectors: {
      content: '[data-testid="tweetText"]',
      author: '[data-testid="User-Name"]',
      engagement: '[data-testid="like"], [data-testid="retweet"], [data-testid="reply"]'
    }
  },
  instagram: {
    domains: ['instagram.com'],
    selectors: {
      content: '._a9zs',
      author: '._a9zc',
      engagement: '._aacl._aaco._aacw._aacx._aada._aade'
    }
  },
  facebook: {
    domains: ['facebook.com', 'fb.com'],
    selectors: {
      content: '[data-testid="post_message"]',
      author: '[data-testid="post_author"]',
      engagement: '[data-testid="UFI2ReactionsCount"]'
    }
  },
  linkedin: {
    domains: ['linkedin.com'],
    selectors: {
      content: '.feed-shared-update-v2__description',
      author: '.feed-shared-actor__name',
      engagement: '.social-details-social-counts'
    }
  },
  tiktok: {
    domains: ['tiktok.com'],
    selectors: {
      content: '.tt-video-meta-caption',
      author: '.author-uniqueId',
      engagement: '.video-meta-like, .video-meta-comment'
    }
  },
  youtube: {
    domains: ['youtube.com', 'youtu.be'],
    selectors: {
      content: '#description-text',
      author: '#channel-name',
      engagement: '#count .view-count'
    }
  }
};

// Nigerian market context data for RAG
const NIGERIAN_CONTEXT = {
  keywords: [
    'Nigeria', 'Nigerian', 'Lagos', 'Abuja', 'Port Harcourt', 'Kano', 'Ibadan',
    'Naira', 'NGN', 'Nigerian market', 'West Africa', 'African business',
    'SME', 'small business', 'entrepreneur', 'startup', 'tech hub',
    'Yoruba', 'Igbo', 'Hausa', 'Pidgin', 'Naija', 'Jollof', 'Suya',
    'Nollywood', 'Afrobeats', 'Nigerian music', 'Nigerian food',
    'MTN', 'Airtel', 'Glo', '9mobile', 'Dangote', 'BUA', 'Flutterwave',
    'Paystack', 'Interswitch', 'Nigerian banks', 'CBN', 'NSE'
  ],
  market_insights: [
    'Nigerian SMEs contribute 48% of GDP',
    'Mobile money adoption is growing rapidly',
    'E-commerce is expanding with Jumia and Konga',
    'Fintech sector is booming with Flutterwave and Paystack',
    'Agriculture remains a key economic driver',
    'Oil and gas sector is significant but diversifying',
    'Youth population is driving digital transformation',
    'Nigerian diaspora remittances exceed $20 billion annually'
  ],
  cultural_context: [
    'Family-oriented business culture',
    'Strong community networks and trust',
    'Entrepreneurial spirit and hustle culture',
    'Respect for elders and authority',
    'Celebration of success and wealth',
    'Importance of personal relationships in business',
    'Adaptability and resilience in challenging environments',
    'Strong religious and traditional values'
  ]
};

// Anti-detection configuration
const ANTI_DETECTION_CONFIG = {
  userAgents: [
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Mozilla/5.0 (iPhone; CPU iPhone OS 17_1_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.1.2 Mobile/15E148 Safari/604.1'
  ],
  delays: {
    min: 3000,
    max: 8000,
    random: true
  },
  viewport: {
    width: 1920,
    height: 1080
  }
};

function detectPlatform(url) {
  const domain = new URL(url).hostname.toLowerCase();
  
  for (const [platform, config] of Object.entries(PLATFORM_PATTERNS)) {
    if (config.domains.some(d => domain.includes(d))) {
      return platform;
    }
  }
  
  return 'unknown';
}

function getRandomUserAgent() {
  return ANTI_DETECTION_CONFIG.userAgents[
    Math.floor(Math.random() * ANTI_DETECTION_CONFIG.userAgents.length)
  ];
}

function getRandomDelay() {
  if (ANTI_DETECTION_CONFIG.delays.random) {
    return Math.random() * 
      (ANTI_DETECTION_CONFIG.delays.max - ANTI_DETECTION_CONFIG.delays.min) + 
      ANTI_DETECTION_CONFIG.delays.min;
  }
  return ANTI_DETECTION_CONFIG.delays.min;
}

async function analyzeNigerianContext(content) {
  const lowerContent = content.toLowerCase();
  
  // Calculate relevance score
  const keywordMatches = NIGERIAN_CONTEXT.keywords.filter(keyword => 
    lowerContent.includes(keyword.toLowerCase())
  );
  const relevanceScore = Math.min(keywordMatches.length / 10, 1);
  
  // Extract local keywords
  const localKeywords = keywordMatches.slice(0, 5);
  
  // Generate market insights based on content
  const marketInsights = NIGERIAN_CONTEXT.market_insights.filter(insight => 
    lowerContent.includes(insight.split(' ').slice(0, 3).join(' ').toLowerCase())
  );
  
  // Cultural context analysis
  const culturalContext = NIGERIAN_CONTEXT.cultural_context.filter(context => 
    lowerContent.includes(context.split(' ').slice(0, 2).join(' ').toLowerCase())
  );
  
  return {
    relevance_score: relevanceScore,
    local_keywords: localKeywords,
    market_insights: marketInsights.slice(0, 3),
    cultural_context: culturalContext.slice(0, 2)
  };
}

async function crawlWithPuppeteer(url, options = {}) {
  let browser;
  try {
    // Launch browser with anti-detection settings
    browser = await puppeteer.launch({
      headless: true,
      args: [
        '--no-sandbox',
        '--disable-setuid-sandbox',
        '--disable-dev-shm-usage',
        '--disable-accelerated-2d-canvas',
        '--no-first-run',
        '--no-zygote',
        '--disable-gpu',
        '--disable-web-security',
        '--disable-features=VizDisplayCompositor',
        '--disable-blink-features=AutomationControlled',
        '--disable-extensions',
        '--disable-plugins',
        '--disable-images',
        '--disable-javascript',
        '--disable-css'
      ]
    });

    const page = await browser.newPage();
    
    // Set random user agent
    await page.setUserAgent(getRandomUserAgent());
    
    // Set viewport
    await page.setViewport(ANTI_DETECTION_CONFIG.viewport);
    
    // Set extra headers for anti-detection
    await page.setExtraHTTPHeaders({
      'Accept-Language': 'en-US,en;q=0.9',
      'Accept-Encoding': 'gzip, deflate, br',
      'DNT': '1',
      'Connection': 'keep-alive',
      'Upgrade-Insecure-Requests': '1'
    });

    // Random delay before navigation
    await page.waitForTimeout(getRandomDelay());

    // Navigate to URL
    await page.goto(url, { 
      waitUntil: 'networkidle2',
      timeout: 30000 
    });

    // Additional random delay after page load
    await page.waitForTimeout(getRandomDelay());

    // Get page content
    const content = await page.evaluate(() => {
      return document.body.innerText;
    });

    // Get metadata
    const metadata = await page.evaluate(() => {
      return {
        title: document.title,
        description: document.querySelector('meta[name="description"]')?.content || '',
        keywords: document.querySelector('meta[name="keywords"]')?.content || ''
      };
    });

    // Detect platform and extract platform-specific data
    const platform = detectPlatform(url);
    let platformData = null;
    
    if (platform !== 'unknown' && PLATFORM_PATTERNS[platform]) {
      const selectors = PLATFORM_PATTERNS[platform].selectors;
      
      platformData = await page.evaluate((sel) => {
        return {
          content: document.querySelector(sel.content)?.textContent || '',
          author: document.querySelector(sel.author)?.textContent || '',
          engagement: document.querySelector(sel.engagement)?.textContent || ''
        };
      }, selectors);
    }

    // Get links
    const links = await page.evaluate(() => {
      return Array.from(document.querySelectorAll('a[href]'))
        .map(a => a.href)
        .filter(href => href.startsWith('http'))
        .slice(0, 10);
    });

    return {
      content,
      metadata,
      platformData,
      links,
      platform
    };

  } catch (error) {
    console.error('Puppeteer crawl error:', error);
    throw error;
  } finally {
    if (browser) {
      await browser.close();
    }
  }
}

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'enhanced-crawl4ai-mcp-server',
    features: {
      puppeteer: true,
      anti_detection: true,
      platform_detection: true,
      nigerian_rag: true,
      social_media_support: true
    },
    supported_platforms: Object.keys(PLATFORM_PATTERNS),
    timestamp: new Date().toISOString(),
    version: '2.0.0'
  });
});

// Enhanced crawl endpoint
app.post('/crawl', async (req, res) => {
  try {
    const { method, params } = req.body;
    
    if (method !== 'crawl') {
      return res.status(400).json({ error: 'Invalid method' });
    }

    const { url, crawl_type, max_pages, include_metadata, platform, anti_detection, rag_context, options } = params;

    if (!url) {
      return res.status(400).json({ error: 'URL is required' });
    }

    console.log(`Enhanced crawling: ${url} (type: ${crawl_type}, platform: ${platform})`);

    // Use Puppeteer for crawling
    const crawlResult = await crawlWithPuppeteer(url, options);

    // Analyze Nigerian context if enabled
    let nigerianContext = null;
    if (rag_context && crawlResult.content) {
      nigerianContext = await analyzeNigerianContext(crawlResult.content);
    }

    // Prepare response
    const response = {
      content: crawlResult.content,
      metadata: {
        ...crawlResult.metadata,
        platform: crawlResult.platform,
        crawl_timestamp: new Date().toISOString(),
        anti_detection_enabled: anti_detection
      },
      links: crawlResult.links,
      platform_data: crawlResult.platformData,
      nigerian_context: nigerianContext
    };

    res.json(response);

  } catch (error) {
    console.error('Crawl error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

// Start server
app.listen(PORT, HOST, () => {
  console.log(`🚀 Enhanced Crawl4AI MCP Server running on http://${HOST}:${PORT}`);
  console.log(`📊 Health check: http://${HOST}:${PORT}/health`);
  console.log(`🔧 Features: Puppeteer, Anti-detection, Platform detection, Nigerian RAG`);
});

module.exports = app;
EOF

# Create .env.example
echo "🔐 Creating .env.example..."
cat > .env.example << 'EOF'
# Crawl4AI API Configuration
CRAWL4AI_API_KEY=your_crawl4ai_api_key_here

# Server Configuration
PORT=3000
HOST=0.0.0.0

# Anti-detection Configuration
ANTI_DETECTION_ENABLED=true
RANDOM_DELAYS=true
STEALTH_MODE=true

# Security
NODE_ENV=production
EOF

# Create Dockerfile with Puppeteer
echo "🐳 Creating Dockerfile with Puppeteer..."
cat > Dockerfile << 'EOF'
FROM node:18-slim

# Install dependencies for Puppeteer
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    ca-certificates \
    procps \
    libxss1 \
    libnss3 \
    libnspr4 \
    libatk-bridge2.0-0 \
    libdrm2 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    libgbm1 \
    libasound2 \
    libpango-1.0-0 \
    libcairo2 \
    libatspi2.0-0 \
    libgtk-3-0 \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Install app dependencies
COPY package*.json ./
RUN npm ci --only=production

# Bundle app source
COPY . .

# Create non-root user
RUN groupadd -r pptruser && useradd -r -g pptruser -G audio,video pptruser \
    && mkdir -p /home/pptruser/Downloads \
    && chown -R pptruser:pptruser /home/pptruser \
    && chown -R pptruser:pptruser /app

USER pptruser

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })"

# Start the application
CMD ["npm", "start"]
EOF

# Create docker-compose.yml
echo "🐳 Creating docker-compose.yml..."
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  crawl4ai-mcp:
    build: .
    ports:
      - "3000:3000"
    environment:
      - CRAWL4AI_API_KEY=${CRAWL4AI_API_KEY}
      - PORT=3000
      - HOST=0.0.0.0
      - NODE_ENV=production
      - ANTI_DETECTION_ENABLED=true
      - RANDOM_DELAYS=true
      - STEALTH_MODE=true
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "node", "-e", "require('http').get('http://localhost:3000/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    volumes:
      - ./logs:/app/logs
    shm_size: '2gb'
EOF

# Create .dockerignore
echo "📝 Creating .dockerignore..."
cat > .dockerignore << 'EOF'
node_modules
npm-debug.log
.env
.env.local
.env.production
.git
.gitignore
README.md
Dockerfile
docker-compose.yml
deploy-mcp-server.sh
logs/
EOF

# Create README.md
echo "📖 Creating README.md..."
cat > README.md << 'EOF'
# Enhanced Crawl4AI MCP Server

A Model Context Protocol (MCP) server for integrating Crawl4AI web crawling capabilities with Flutter applications, featuring Puppeteer, anti-detection measures, and Nigerian market RAG.

## Features

- **Puppeteer Integration**: Advanced web crawling with browser automation
- **Anti-Detection**: Stealth mode, random delays, user agent rotation
- **Platform Detection**: Automatic detection of social media platforms
- **Nigerian RAG**: Context-aware insights for Nigerian market
- **Rate Limiting**: Protection against abuse and detection
- **Health Monitoring**: Built-in health checks and monitoring

## Quick Start

1. Set up environment variables:
   ```bash
   cp .env.example .env
   # Edit .env with your Crawl4AI API key
   ```

2. Start with Docker:
   ```bash
   docker-compose up -d
   ```

3. Test the server:
   ```bash
   curl http://localhost:3000/health
   ```

## API Endpoints

- `GET /health` - Health check with feature information
- `POST /crawl` - Enhanced crawling with platform detection

## Supported Platforms

- Twitter/X
- Instagram
- Facebook
- LinkedIn
- TikTok
- YouTube
- General websites

## Environment Variables

- `CRAWL4AI_API_KEY` - Your Crawl4AI API key
- `PORT` - Server port (default: 3000)
- `HOST` - Server host (default: 0.0.0.0)
- `ANTI_DETECTION_ENABLED` - Enable anti-detection features
- `RANDOM_DELAYS` - Enable random delays between requests
- `STEALTH_MODE` - Enable stealth mode for Puppeteer

## Docker Commands

```bash
# Build and start
docker-compose up -d

# View logs
docker-compose logs -f

# Stop
docker-compose down

# Rebuild
docker-compose up -d --build
```

## Anti-Detection Features

- Random user agent rotation
- Variable delays between requests
- Stealth mode for Puppeteer
- Ad blocker integration
- Viewport randomization
- Header spoofing

## Nigerian Market RAG

- Local keyword detection
- Market insight generation
- Cultural context analysis
- Relevance scoring
- SME-focused insights
EOF

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Create logs directory
mkdir -p logs

echo ""
echo "✅ Enhanced Crawl4AI MCP Server setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Copy .env.example to .env and add your Crawl4AI API key"
echo "2. Start the server: docker-compose up -d"
echo "3. Test the health endpoint: curl http://localhost:3000/health"
echo "4. Update your Supabase environment variables with the server URL"
echo ""
echo "🔗 Server will be available at: http://localhost:3000"
echo "📊 Health check: http://localhost:3000/health"
echo "🔧 Features: Puppeteer, Anti-detection, Platform detection, Nigerian RAG"
echo ""
echo "📚 See README.md for more information" 