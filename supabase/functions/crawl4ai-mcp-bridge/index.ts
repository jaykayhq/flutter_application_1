// File: supabase/functions/crawl4ai-mcp-bridge/index.ts

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

interface CrawlRequest {
  url: string;
  crawl_type: 'single_page' | 'sitemap' | 'recursive' | 'social_media';
  max_pages?: number;
  include_metadata?: boolean;
  platform?: 'twitter' | 'instagram' | 'facebook' | 'linkedin' | 'tiktok' | 'youtube' | 'auto';
  anti_detection?: boolean;
  rag_context?: boolean;
}

interface CrawlResponse {
  success: boolean;
  data?: {
    content: string;
    metadata?: {
      title?: string;
      description?: string;
      keywords?: string[];
      platform?: string;
      author?: string;
      engagement?: {
        likes?: number;
        shares?: number;
        comments?: number;
        views?: number;
      };
      sentiment?: 'positive' | 'negative' | 'neutral';
      trending_score?: number;
    };
    links?: string[];
    platform_data?: {
      platform: string;
      post_type: string;
      hashtags: string[];
      mentions: string[];
      urls: string[];
    };
    nigerian_context?: {
      relevance_score: number;
      local_keywords: string[];
      market_insights: string[];
      cultural_context: string[];
    };
  };
  error?: string;
}

// Social media platform detection patterns
const PLATFORM_PATTERNS = {
  twitter: {
    domains: ['twitter.com', 'x.com', 't.co'],
    patterns: [/twitter\.com/, /x\.com/, /t\.co/],
    selectors: {
      content: '[data-testid="tweetText"]',
      author: '[data-testid="User-Name"]',
      engagement: '[data-testid="like"], [data-testid="retweet"], [data-testid="reply"]'
    }
  },
  instagram: {
    domains: ['instagram.com'],
    patterns: [/instagram\.com/],
    selectors: {
      content: '._a9zs',
      author: '._a9zc',
      engagement: '._aacl._aaco._aacw._aacx._aada._aade'
    }
  },
  facebook: {
    domains: ['facebook.com', 'fb.com'],
    patterns: [/facebook\.com/, /fb\.com/],
    selectors: {
      content: '[data-testid="post_message"]',
      author: '[data-testid="post_author"]',
      engagement: '[data-testid="UFI2ReactionsCount"]'
    }
  },
  linkedin: {
    domains: ['linkedin.com'],
    patterns: [/linkedin\.com/],
    selectors: {
      content: '.feed-shared-update-v2__description',
      author: '.feed-shared-actor__name',
      engagement: '.social-details-social-counts'
    }
  },
  tiktok: {
    domains: ['tiktok.com'],
    patterns: [/tiktok\.com/],
    selectors: {
      content: '.tt-video-meta-caption',
      author: '.author-uniqueId',
      engagement: '.video-meta-like, .video-meta-comment'
    }
  },
  youtube: {
    domains: ['youtube.com', 'youtu.be'],
    patterns: [/youtube\.com/, /youtu\.be/],
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

// Anti-detection measures
const ANTI_DETECTION_CONFIG = {
  userAgents: [
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Mozilla/5.0 (iPhone; CPU iPhone OS 17_1_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.1.2 Mobile/15E148 Safari/604.1'
  ],
  headers: {
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
    'Accept-Language': 'en-US,en;q=0.5',
    'Accept-Encoding': 'gzip, deflate, br',
    'DNT': '1',
    'Connection': 'keep-alive',
    'Upgrade-Insecure-Requests': '1',
    'Sec-Fetch-Dest': 'document',
    'Sec-Fetch-Mode': 'navigate',
    'Sec-Fetch-Site': 'none',
    'Cache-Control': 'max-age=0'
  },
  delays: {
    min: 2000,
    max: 5000,
    random: true
  },
  proxyRotation: false, // Enable if you have proxy list
  sessionManagement: true
};

function detectPlatform(url: string): string {
  const domain = new URL(url).hostname.toLowerCase();
  
  for (const [platform, config] of Object.entries(PLATFORM_PATTERNS)) {
    if (config.domains.some(d => domain.includes(d)) || 
        config.patterns.some(p => p.test(url))) {
      return platform;
    }
  }
  
  return 'unknown';
}

function getRandomUserAgent(): string {
  return ANTI_DETECTION_CONFIG.userAgents[
    Math.floor(Math.random() * ANTI_DETECTION_CONFIG.userAgents.length)
  ];
}

function getRandomDelay(): number {
  if (ANTI_DETECTION_CONFIG.delays.random) {
    return Math.random() * 
      (ANTI_DETECTION_CONFIG.delays.max - ANTI_DETECTION_CONFIG.delays.min) + 
      ANTI_DETECTION_CONFIG.delays.min;
  }
  return ANTI_DETECTION_CONFIG.delays.min;
}

async function analyzeNigerianContext(content: string): Promise<any> {
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

serve(async (req) => {
  console.log("Enhanced Crawl4AI MCP Bridge invoked.");

  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      status: 200,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      },
    });
  }

  try {
    // Get MCP server configuration
    const mcpServerUrl = Deno.env.get("CRAWL4AI_MCP_SERVER_URL");
    const mcpApiKey = Deno.env.get("CRAWL4AI_MCP_API_KEY");
    
    if (!mcpServerUrl || !mcpApiKey) {
      throw new Error("Missing Crawl4AI MCP server configuration.");
    }

    if (req.method === 'POST') {
      const body = await req.json();
      const { 
        url, 
        crawl_type = 'single_page', 
        max_pages = 1, 
        include_metadata = true,
        platform = 'auto',
        anti_detection = true,
        rag_context = true
      }: CrawlRequest = body;

      if (!url) {
        throw new Error("URL is required for crawling.");
      }

      console.log(`Initiating enhanced crawl for: ${url} (type: ${crawl_type}, platform: ${platform})`);

      // Detect platform if auto
      const detectedPlatform = platform === 'auto' ? detectPlatform(url) : platform;
      console.log(`Detected platform: ${detectedPlatform}`);

      // Prepare enhanced request for the MCP server
      const mcpRequest = {
        method: 'crawl',
        params: {
          url: url,
          crawl_type: crawl_type,
          max_pages: max_pages,
          include_metadata: include_metadata,
          platform: detectedPlatform,
          anti_detection: anti_detection,
          rag_context: rag_context,
          options: {
            wait_for: getRandomDelay(),
            screenshot: false,
            pdf: false,
            include_links: true,
            user_agent: getRandomUserAgent(),
            headers: ANTI_DETECTION_CONFIG.headers,
            puppeteer_options: {
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
                '--disable-features=VizDisplayCompositor'
              ]
            }
          }
        }
      };

      // Call the enhanced Crawl4AI MCP server
      const mcpResponse = await fetch(`${mcpServerUrl}/crawl`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${mcpApiKey}`,
        },
        body: JSON.stringify(mcpRequest),
      });

      if (!mcpResponse.ok) {
        const errorText = await mcpResponse.text();
        throw new Error(`MCP Server Error: ${mcpResponse.status} - ${errorText}`);
      }

      const mcpData = await mcpResponse.json();
      
      // Process and enhance the response
      let enhancedData: any = {
        content: mcpData.content || '',
        metadata: {
          ...mcpData.metadata,
          platform: detectedPlatform,
          crawl_timestamp: new Date().toISOString(),
          anti_detection_enabled: anti_detection
        },
        links: mcpData.links || [],
        platform_data: mcpData.platform_data || null
      };

      // Add Nigerian context analysis if enabled
      if (rag_context && enhancedData.content) {
        const nigerianContext = await analyzeNigerianContext(enhancedData.content);
        enhancedData.nigerian_context = nigerianContext;
      }

      const crawlResponse: CrawlResponse = {
        success: true,
        data: enhancedData
      };

      // If this is part of a task workflow, create a follow-up task for Gemini insights
      if (body.create_insights_task) {
        const supabaseUrl = Deno.env.get("SUPABASE_URL");
        const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
        
        if (supabaseUrl && supabaseServiceRoleKey) {
          const supabase = createClient(supabaseUrl, supabaseServiceRoleKey);
          
          // Enhanced prompt with Nigerian context
          const contextInfo = enhancedData.nigerian_context ? 
            `Nigerian Market Relevance: ${enhancedData.nigerian_context.relevance_score * 100}%. 
             Local Keywords: ${enhancedData.nigerian_context.local_keywords.join(', ')}. 
             Market Insights: ${enhancedData.nigerian_context.market_insights.join('; ')}.` : '';
          
          const prompt = `Based on the following web content from ${detectedPlatform} (${url}): 
            "${enhancedData.content.substring(0, 1000)}..."
            
            ${contextInfo}
            
            Generate three actionable marketing insights specifically for Nigerian small businesses. 
            Each insight should be culturally relevant, practical, and consider the Nigerian market context. 
            Format the response as a simple JSON array of strings.`;
          
          await supabase.from('agent_tasks').insert({
            task_type: 'GENERATE_INSIGHTS',
            status: 'pending',
            payload: { 
              prompt: prompt,
              source: 'enhanced_crawl4ai',
              original_url: url,
              platform: detectedPlatform,
              nigerian_context: enhancedData.nigerian_context
            }
          });
          
          console.log("Created enhanced follow-up task for Gemini insights generation.");
        }
      }

      return new Response(JSON.stringify(crawlResponse), {
        status: 200,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      });

    } else if (req.method === 'GET') {
      // Enhanced health check endpoint
      return new Response(JSON.stringify({ 
        status: 'healthy', 
        service: 'enhanced-crawl4ai-mcp-bridge',
        features: {
          puppeteer: true,
          anti_detection: true,
          platform_detection: true,
          nigerian_rag: true,
          social_media_support: true
        },
        supported_platforms: Object.keys(PLATFORM_PATTERNS),
        timestamp: new Date().toISOString()
      }), {
        status: 200,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      });
    } else {
      return new Response(JSON.stringify({ error: 'Method not allowed' }), {
        status: 405,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      });
    }

  } catch (error) {
    console.error("Error in enhanced crawl4ai-mcp-bridge:", error);
    
    const errorResponse: CrawlResponse = {
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error occurred'
    };

    return new Response(JSON.stringify(errorResponse), {
      status: 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
    });
  }
}); 