# Crawl4AI MCP Server Integration Setup

This document explains how to set up and manage the crawl4ai MCP server integration with your Flutter application.

## Architecture Overview

```
Flutter App → Supabase Edge Function → Crawl4AI MCP Server → Gemini 1.5 Flash → Insights
```

## 1. Crawl4AI MCP Server Setup

### Option A: Self-Hosted MCP Server

1. **Install the Crawl4AI MCP Server**:
   ```bash
   # Clone the crawl4ai MCP server repository
   git clone https://github.com/crawl4ai/crawl4ai-mcp-server.git
   cd crawl4ai-mcp-server
   
   # Install dependencies
   npm install
   
   # Set up environment variables
   cp .env.example .env
   ```

2. **Configure Environment Variables**:
   ```env
   # .env file
   CRAWL4AI_API_KEY=your_crawl4ai_api_key
   PORT=3000
   HOST=0.0.0.0
   ```

3. **Start the MCP Server**:
   ```bash
   npm start
   # or for production
   npm run start:prod
   ```

### Option B: Docker Deployment

1. **Create Dockerfile**:
   ```dockerfile
   FROM node:18-alpine
   
   WORKDIR /app
   COPY package*.json ./
   RUN npm ci --only=production
   
   COPY . .
   EXPOSE 3000
   
   CMD ["npm", "start"]
   ```

2. **Create docker-compose.yml**:
   ```yaml
   version: '3.8'
   services:
     crawl4ai-mcp:
       build: .
       ports:
         - "3000:3000"
       environment:
         - CRAWL4AI_API_KEY=${CRAWL4AI_API_KEY}
       restart: unless-stopped
   ```

3. **Deploy with Docker**:
   ```bash
   docker-compose up -d
   ```

### Option C: Cloud Deployment (Recommended)

#### Deploy to Railway:
```bash
# Install Railway CLI
npm install -g @railway/cli

# Login to Railway
railway login

# Initialize project
railway init

# Deploy
railway up
```

#### Deploy to Render:
1. Connect your GitHub repository to Render
2. Create a new Web Service
3. Set environment variables:
   - `CRAWL4AI_API_KEY`
   - `PORT=3000`
4. Deploy

## 2. Supabase Edge Function Deployment

### Deploy the Crawl4AI MCP Bridge Function:

```bash
# Navigate to your project directory
cd flutter_application_1

# Deploy the function
supabase functions deploy crawl4ai-mcp-bridge
```

### Set Environment Variables in Supabase:

```bash
# Set the MCP server URL and API key
supabase secrets set CRAWL4AI_MCP_SERVER_URL=http://your-mcp-server-url:3000
supabase secrets set CRAWL4AI_MCP_API_KEY=your_mcp_server_api_key

# Update Gemini API key for 1.5 Flash
supabase secrets set GEMINI_API_KEY=your_gemini_api_key
```

## 3. Flutter App Configuration

### Update pubspec.yaml:
The `http` package has been added to handle API calls to the MCP bridge.

### Environment Variables:
Create a `.env` file in your Flutter project root:
```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

## 4. Database Schema Updates

### Add to your Supabase database:

```sql
-- Add source tracking to actionable_insights table
ALTER TABLE actionable_insights 
ADD COLUMN source_url TEXT,
ADD COLUMN source_type TEXT DEFAULT 'manual';

-- Create index for better performance
CREATE INDEX idx_actionable_insights_source ON actionable_insights(source_url, created_at);
```

## 5. Testing the Integration

### 1. Test MCP Server Health:
```bash
curl http://your-mcp-server-url:3000/health
```

### 2. Test Supabase Function:
```bash
curl -X POST https://your-project.supabase.co/functions/v1/crawl4ai-mcp-bridge \
  -H "Authorization: Bearer your_anon_key" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://example.com",
    "crawl_type": "single_page",
    "create_insights_task": true
  }'
```

### 3. Test from Flutter App:
1. Open the app
2. Navigate to the "Crawler" tab
3. Enter a URL and click "Start Crawl"
4. Check the insights tab for generated content

## 6. Monitoring and Management

### Health Monitoring:
- The Flutter app includes a health check button
- Monitor MCP server logs for errors
- Set up alerts for failed crawls

### Performance Optimization:
- Adjust `max_pages` based on your needs
- Use `single_page` for quick insights
- Use `sitemap` for comprehensive analysis

### Cost Management:
- Monitor Crawl4AI API usage
- Set rate limits in the MCP server
- Use caching for repeated requests

## 7. Security Considerations

### API Key Management:
- Store API keys in environment variables
- Rotate keys regularly
- Use least privilege access

### Rate Limiting:
- Implement rate limiting in the MCP server
- Respect website robots.txt files
- Add delays between requests

### Data Privacy:
- Only crawl publicly accessible content
- Respect website terms of service
- Implement data retention policies

## 8. Troubleshooting

### Common Issues:

1. **MCP Server Connection Failed**:
   - Check if the server is running
   - Verify the URL and port
   - Check firewall settings

2. **Crawl4AI API Errors**:
   - Verify API key is valid
   - Check API usage limits
   - Ensure URL is accessible

3. **Gemini API Errors**:
   - Verify Gemini API key
   - Check API quota limits
   - Ensure prompt format is correct

### Debug Commands:
```bash
# Check MCP server logs
docker logs crawl4ai-mcp

# Check Supabase function logs
supabase functions logs crawl4ai-mcp-bridge

# Test individual components
curl -X GET https://your-project.supabase.co/functions/v1/crawl4ai-mcp-bridge
```

## 9. Scaling Considerations

### Horizontal Scaling:
- Deploy multiple MCP server instances
- Use load balancer for distribution
- Implement connection pooling

### Vertical Scaling:
- Increase server resources
- Optimize database queries
- Implement caching layers

### Cost Optimization:
- Use spot instances for non-critical workloads
- Implement request batching
- Cache frequently accessed data

## 10. Future Enhancements

### Planned Features:
- Batch crawling capabilities
- Advanced filtering options
- Custom insight templates
- Integration with other AI models
- Real-time crawling notifications

### API Extensions:
- Support for more crawl types
- Custom metadata extraction
- Advanced content processing
- Multi-language support 