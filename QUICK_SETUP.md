# Quick Setup Guide: Crawl4AI MCP Server Integration

## 🚀 Get Started in 5 Minutes

### 1. Deploy the MCP Server

Run the deployment script:
```bash
./deploy-mcp-server.sh
```

This will create a `crawl4ai-mcp-server` directory with everything you need.

### 2. Configure Environment Variables

```bash
cd crawl4ai-mcp-server
cp .env.example .env
```

Edit `.env` and add your Crawl4AI API key:
```env
CRAWL4AI_API_KEY=your_actual_api_key_here
```

### 3. Start the MCP Server

```bash
docker-compose up -d
```

### 4. Deploy the Supabase Function

```bash
# From your Flutter project root
supabase functions deploy crawl4ai-mcp-bridge
```

### 5. Set Supabase Environment Variables

```bash
supabase secrets set CRAWL4AI_MCP_SERVER_URL=http://localhost:3000
supabase secrets set CRAWL4AI_MCP_API_KEY=your_mcp_server_api_key
supabase secrets set GEMINI_API_KEY=your_gemini_api_key
```

### 6. Test the Integration

1. **Test MCP Server:**
   ```bash
   curl http://localhost:3000/health
   ```

2. **Test Supabase Function:**
   ```bash
   curl -X POST https://your-project.supabase.co/functions/v1/crawl4ai-mcp-bridge \
     -H "Authorization: Bearer your_anon_key" \
     -H "Content-Type: application/json" \
     -d '{"url": "https://example.com", "create_insights_task": true}'
   ```

3. **Test from Flutter App:**
   - Run your Flutter app
   - Navigate to the "Crawler" tab
   - Enter a URL and click "Start Crawl"

## 🔧 What's Been Added

### New Files:
- `supabase/functions/crawl4ai-mcp-bridge/` - Supabase Edge Function
- `lib/app/data/repositories/crawl4ai_repository.dart` - Flutter repository
- `lib/app/modules/home/views/web_crawler_view.dart` - Flutter UI
- `deploy-mcp-server.sh` - Deployment script
- `CRAWL4AI_SETUP.md` - Detailed documentation

### Updated Files:
- `pubspec.yaml` - Added http package
- `lib/main.dart` - Added crawler navigation
- `supabase/functions/generate-gemini-insights/index.ts` - Updated to use Gemini 1.5 Flash

## 🎯 Key Features

- **Puppeteer Integration**: Advanced web crawling with browser automation
- **Anti-Detection**: Stealth mode, random delays, user agent rotation
- **Social Media Platforms**: Twitter, Instagram, Facebook, LinkedIn, TikTok, YouTube
- **Nigerian Market RAG**: Context-aware insights for Nigerian SMEs
- **Gemini 1.5 Flash**: Latest AI model for enhanced insights
- **Health Monitoring**: Built-in health checks and feature detection
- **Rate Limiting**: Protection against abuse and detection
- **Docker Support**: Easy deployment and scaling

## 🚨 Important Notes

1. **API Keys**: Make sure you have valid Crawl4AI and Gemini API keys
2. **Network Access**: The MCP server needs internet access to crawl websites
3. **Rate Limits**: Respect website terms of service and implement appropriate delays
4. **Security**: Keep your API keys secure and never commit them to version control

## 🆘 Need Help?

- Check the detailed documentation in `CRAWL4AI_SETUP.md`
- Monitor logs: `docker-compose logs -f`
- Test individual components using the curl commands above
- Check Supabase function logs: `supabase functions logs crawl4ai-mcp-bridge`

## 🔄 Next Steps

1. **Production Deployment**: Consider deploying the MCP server to a cloud provider
2. **Database Schema**: Run the SQL commands in `CRAWL4AI_SETUP.md` to add source tracking
3. **Customization**: Modify the crawling logic and insight generation prompts
4. **Monitoring**: Set up alerts and monitoring for the MCP server

---

**Happy Crawling! 🕷️✨** 