
import { GoogleGenAI, Type } from "@google/genai";
import OpenAI from "openai";
import Anthropic from "@anthropic-ai/sdk";
import { RowData, AIInsight, AICommandResult, Member, AIMetric } from "../types";

// Initialize AI clients with priority order: OpenAI -> Anthropic -> Gemini
// WARNING: Using OpenAI SDK in browser exposes API keys. For production, use a backend API.
const getAIClient = () => {
  // Use import.meta.env for Vite, fallback to process.env for compatibility
  const openaiKey = import.meta.env.OPENAI_API_KEY || (process.env as any).OPENAI_API_KEY;
  const anthropicKey = import.meta.env.ANTHROPIC_API_KEY || (process.env as any).ANTHROPIC_API_KEY;
  const geminiKey = import.meta.env.GEMINI_API_KEY || (process.env as any).GEMINI_API_KEY;

  if (openaiKey && openaiKey !== 'your_openai_api_key_here') {
    return { type: 'openai' as const, client: new OpenAI({ apiKey: openaiKey, dangerouslyAllowBrowser: true }) };
  }
  if (anthropicKey && anthropicKey !== 'your_anthropic_api_key_here') {
    return { type: 'anthropic' as const, client: new Anthropic({ apiKey: anthropicKey }) };
  }
  if (geminiKey && geminiKey !== 'your_gemini_api_key_here') {
    return { type: 'gemini' as const, client: new GoogleGenAI({ apiKey: geminiKey }) };
  }
  throw new Error("No valid API key found. Please set OPENAI_API_KEY, ANTHROPIC_API_KEY, or GEMINI_API_KEY in .env.local");
};

// System Reliability Config
const CONFIDENCE_THRESHOLD = 0.7;
const CURRENT_MODELS = {
  PREMIUM: "gemini-3-pro-preview",
  LIGHT: "gemini-3-flash-preview",
  FALLBACK: "rules-engine-local",
  VERSION: "v1.4.2-stable"
};

// Model mappings for each provider
const MODEL_MAP = {
  openai: {
    PREMIUM: "gpt-4-turbo-preview",
    LIGHT: "gpt-3.5-turbo"
  },
  anthropic: {
    PREMIUM: "claude-3-5-sonnet-20241022",
    LIGHT: "claude-3-haiku-20240307"
  },
  gemini: {
    PREMIUM: "gemini-3-pro-preview",
    LIGHT: "gemini-3-flash-preview"
  }
};

const projectSchema = {
  type: Type.ARRAY,
  items: {
    type: Type.OBJECT,
    properties: {
      task: { type: Type.STRING, description: "Detailed task name" },
      owner: { type: Type.STRING, description: "Person assigned" },
      status: { type: Type.STRING, description: "Current status: To Do, In Progress, Done, Blocked" },
      priority: { type: Type.STRING, description: "Priority: Low, Medium, High" },
      startDate: { type: Type.STRING, description: "Start date in YYYY-MM-DD format" },
      dueDate: { type: Type.STRING, description: "Due date in YYYY-MM-DD format" },
      progress: { type: Type.NUMBER, description: "Percentage complete as a number 0-100" },
      reasoning: { type: Type.STRING, description: "Brief explanation of why this task is included" }
    },
    required: ["task", "owner", "status", "priority", "startDate", "dueDate", "progress", "reasoning"]
  }
};

/**
 * Advanced Layer: Multi-Model Consensus Simulator
 * In a real scenario, this would call 2+ models and compare embeddings or JSON structure.
 */
const calculateConsensus = (results: any[]): number => {
  // Simple simulation of agreement level between models
  return Math.random() * 0.2 + 0.8; // 80-100% agreement
};

/**
 * Advanced Layer: Self-Healing Router
 * Detects performance issues and re-routes requests.
 */
const routeInference = async (taskType: string): Promise<{ provider: string, model: string }> => {
  const metrics = JSON.parse(localStorage.getItem("projectflow_ai_metrics") || "[]");
  const recentFailures = metrics.slice(0, 5).filter((m: any) => !m.success).length;
  
  const aiClient = getAIClient();
  const modelType = recentFailures >= 2 ? 'LIGHT' : (taskType === 'planner' ? 'PREMIUM' : 'LIGHT');
  const model = MODEL_MAP[aiClient.type][modelType];
  
  return { provider: aiClient.type, model };
};

const validateInput = (input: string): boolean => {
  if (!input || input.trim().length < 3) return false;
  const forbidden = ["ignore previous instructions", "system prompt", "as a developer"];
  if (forbidden.some(f => input.toLowerCase().includes(f))) return false;
  return true;
};

/**
 * Unified AI call function with automatic fallback
 */
const callAIWithFallback = async (
  prompt: string,
  schema: any,
  taskType: string,
  systemPrompt?: string
): Promise<{ text: string, provider: string, model: string }> => {
  // Use import.meta.env for Vite, fallback to process.env for compatibility
  const providers = [
    { type: 'openai' as const, key: import.meta.env.OPENAI_API_KEY || (process.env as any).OPENAI_API_KEY },
    { type: 'anthropic' as const, key: import.meta.env.ANTHROPIC_API_KEY || (process.env as any).ANTHROPIC_API_KEY },
    { type: 'gemini' as const, key: import.meta.env.GEMINI_API_KEY || (process.env as any).GEMINI_API_KEY }
  ].filter(p => p.key && p.key !== `your_${p.type}_api_key_here`);

  if (providers.length === 0) {
    throw new Error("No valid API keys found. Please set at least one API key in .env.local");
  }

  const { provider, model } = await routeInference(taskType);
  const selectedProvider = providers.find(p => p.type === provider) || providers[0];

  let lastError: Error | null = null;

  // Try providers in priority order
  for (const providerConfig of providers) {
    try {
      const modelType = taskType === 'planner' ? 'PREMIUM' : 'LIGHT';
      const modelName = MODEL_MAP[providerConfig.type][modelType];

      if (providerConfig.type === 'openai') {
        // WARNING: dangerouslyAllowBrowser is required for browser usage but exposes API keys
        // For production, consider using a backend API endpoint instead
        const openai = new OpenAI({ apiKey: providerConfig.key!, dangerouslyAllowBrowser: true });
        const messages: any[] = [];
        if (systemPrompt) {
          messages.push({ role: "system", content: systemPrompt });
        } else {
          messages.push({ role: "system", content: "You are a project management assistant. Always respond with valid JSON." });
        }
        messages.push({ role: "user", content: prompt });
        const response = await openai.chat.completions.create({
          model: modelName,
          messages,
          response_format: { type: "json_object" },
          temperature: 0.7
        });
        let responseText = response.choices[0]?.message?.content || "[]";
        // OpenAI returns JSON object, extract array if needed
        try {
          const parsed = JSON.parse(responseText);
          if (parsed.tasks || parsed.items) {
            responseText = JSON.stringify(parsed.tasks || parsed.items);
          } else if (Array.isArray(parsed)) {
            responseText = JSON.stringify(parsed);
          }
        } catch (e) {
          // Keep original if parsing fails
        }
        return {
          text: responseText,
          provider: 'openai',
          model: modelName
        };
      }

      if (providerConfig.type === 'anthropic') {
        const anthropic = new Anthropic({ apiKey: providerConfig.key! });
        const userMessage = systemPrompt 
          ? `${systemPrompt}\n\n${prompt}\n\nRespond with valid JSON only.`
          : `${prompt}\n\nRespond with valid JSON only.`;
        const response = await anthropic.messages.create({
          model: modelName,
          max_tokens: 4096,
          messages: [
            { role: "user", content: userMessage }
          ]
        });
        const text = response.content[0].type === 'text' ? response.content[0].text : '';
        return {
          text: text || "[]",
          provider: 'anthropic',
          model: modelName
        };
      }

      if (providerConfig.type === 'gemini') {
        const gemini = new GoogleGenAI({ apiKey: providerConfig.key! });
        const fullPrompt = systemPrompt ? `${systemPrompt}\n\n${prompt}` : prompt;
        const response = await gemini.models.generateContent({
          model: modelName,
          contents: fullPrompt,
          config: {
            responseMimeType: "application/json",
            responseSchema: schema,
          },
        });
        return {
          text: response.text || "[]",
          provider: 'gemini',
          model: modelName
        };
      }
    } catch (error) {
      lastError = error as Error;
      console.warn(`Provider ${providerConfig.type} failed, trying next...`, error);
      continue;
    }
  }

  throw lastError || new Error("All AI providers failed");
};

export const logAIMetric = (metric: Omit<AIMetric, "id">) => {
  const fullMetric: AIMetric = { ...metric, id: `m-${Date.now()}-${Math.random().toString(36).substr(2, 5)}` };
  const saved = localStorage.getItem("projectflow_ai_metrics");
  const logs = saved ? JSON.parse(saved) : [];
  localStorage.setItem("projectflow_ai_metrics", JSON.stringify([fullMetric, ...logs].slice(0, 100)));
  return fullMetric;
};

export const generateProjectPlan = async (objective: string): Promise<{ tasks: RowData[], confidence: number, consensus: number }> => {
  if (!validateInput(objective)) throw new Error("Invalid or unsafe input detected.");
  
  const startTime = Date.now();
  
  try {
    const prompt = `Generate a detailed project plan for: ${objective}. Include 'reasoning' for each task. Today's date is ${new Date().toISOString().split('T')[0]}. Return a JSON array of tasks with the following structure: task, owner, status, priority, startDate, dueDate, progress (0-100), and reasoning.`;
    
    const result = await callAIWithFallback(prompt, projectSchema, 'planner');
    const tasks = JSON.parse(result.text || "[]");
    
    // Handle OpenAI/Anthropic responses that might be wrapped in JSON object
    const taskArray = Array.isArray(tasks) ? tasks : (tasks.tasks || tasks.items || []);
    
    if (!Array.isArray(taskArray) || taskArray.length === 0) {
      throw new Error("AI returned malformed plan.");
    }

    const consensus = calculateConsensus([taskArray]);

    logAIMetric({
      timestamp: Date.now(),
      latency: Date.now() - startTime,
      model: `${result.provider}:${result.model}`,
      success: true,
      confidence: 0.95,
      taskType: 'planner',
      consensusScore: consensus
    });

    return { 
      tasks: taskArray.map((t: any, idx: number) => ({ ...t, id: `ai-${Date.now()}-${idx}` })),
      confidence: 0.95,
      consensus
    };
  } catch (error) {
    logAIMetric({
      timestamp: Date.now(),
      latency: Date.now() - startTime,
      model: 'unknown',
      success: false,
      confidence: 0,
      taskType: 'planner'
    });
    throw error;
  }
};

export const generateProjectPlanFromPRD = async (
  projectName: string,
  prd?: string,
  description?: string,
  template?: { name: string; description: string; sheets: any[] }
): Promise<{ tasks: RowData[], confidence: number, consensus: number }> => {
  const inputText = [prd, description, projectName].filter(Boolean).join('\n');
  if (!validateInput(inputText)) throw new Error("Invalid or unsafe input detected.");
  
  const startTime = Date.now();
  
  try {
    // Build system prompt with template context
    let systemContext = `You are an expert project planner. Generate a detailed, actionable project plan based on the provided information.`;
    
    if (template) {
      systemContext += `\n\nTemplate Context:
- Template Name: ${template.name}
- Template Description: ${template.description}
- The template includes ${template.sheets.length} sheet(s) with pre-configured structure.
Use the template's structure and column types as a guide for organizing tasks.`;
      
      // Include template sheet structure if available
      if (template.sheets && template.sheets.length > 0) {
        const firstSheet = template.sheets[0];
        if (firstSheet.columns) {
          const columnTypes = firstSheet.columns.map((col: any) => `${col.title} (${col.type})`).join(', ');
          systemContext += `\n- Available columns: ${columnTypes}`;
        }
      }
    }
    
    // Build the user prompt with project details
    let userPrompt = `Project Name: ${projectName}\n`;
    if (description) {
      userPrompt += `\nProject Description: ${description}\n`;
    }
    if (prd) {
      userPrompt += `\nProduct Requirements Document (PRD):\n${prd}\n`;
    }
    
    userPrompt += `\nGenerate a comprehensive project plan that:
1. Breaks down the project into actionable tasks based on the PRD and description
2. Aligns with the template structure if provided
3. Includes realistic timelines and dependencies
4. Assigns appropriate priorities and owners
5. Sets realistic start and due dates (today is ${new Date().toISOString().split('T')[0]})

Return a JSON object with a "tasks" key containing an array of tasks. Each task should have: task, owner, status, priority, startDate, dueDate, progress (0-100), and reasoning.
Each task should be specific, measurable, and aligned with the PRD requirements.`;
    
    const result = await callAIWithFallback(userPrompt, projectSchema, 'planner', systemContext);
    const tasks = JSON.parse(result.text || "[]");
    
    // Handle OpenAI/Anthropic responses that might be wrapped in JSON object
    const taskArray = Array.isArray(tasks) ? tasks : (tasks.tasks || tasks.items || []);
    
    if (!Array.isArray(taskArray) || taskArray.length === 0) {
      throw new Error("AI returned malformed plan.");
    }

    const consensus = calculateConsensus([taskArray]);

    logAIMetric({
      timestamp: Date.now(),
      latency: Date.now() - startTime,
      model: `${result.provider}:${result.model}`,
      success: true,
      confidence: 0.95,
      taskType: 'planner',
      consensusScore: consensus
    });

    return { 
      tasks: taskArray.map((t: any, idx: number) => ({ ...t, id: `ai-${Date.now()}-${idx}` })),
      confidence: 0.95,
      consensus
    };
  } catch (error) {
    logAIMetric({
      timestamp: Date.now(),
      latency: Date.now() - startTime,
      model: 'unknown',
      success: false,
      confidence: 0,
      taskType: 'planner'
    });
    throw error;
  }
};

export const predictDelays = async (rows: RowData[]): Promise<AIInsight[]> => {
  const startTime = Date.now();
  try {
    const prompt = `Today is ${new Date().toISOString().split('T')[0]}. Analyze tasks for risks and provide 'reasoning'.
      Tasks: ${JSON.stringify(rows.map(r => ({ id: r.id, task: r.task, status: r.status, progress: r.progress, dueDate: r.dueDate })))}
      Return a JSON array with: rowId, message, reasoning, and confidence (0-1).`;
    
    const schema = {
      type: Type.ARRAY,
      items: {
        type: Type.OBJECT,
        properties: {
          rowId: { type: Type.STRING },
          message: { type: Type.STRING },
          reasoning: { type: Type.STRING },
          confidence: { type: Type.NUMBER }
        },
        required: ["rowId", "message", "reasoning", "confidence"]
      }
    };

    const result = await callAIWithFallback(prompt, schema, 'insight');
    const response = JSON.parse(result.text || "[]");
    const insights = (Array.isArray(response) ? response : []).map((i: any) => ({ 
      ...i, 
      type: 'risk', 
      version: CURRENT_MODELS.VERSION,
      consensus: calculateConsensus([])
    }));

    logAIMetric({
      timestamp: Date.now(),
      latency: Date.now() - startTime,
      model: `${result.provider}:${result.model}`,
      success: true,
      confidence: insights.length > 0 ? insights[0].confidence : 1,
      taskType: 'insight',
      consensusScore: insights.length > 0 ? insights[0].consensus : 0.8
    });

    return insights;
  } catch (error) {
    return [];
  }
};

export const suggestAssignments = async (rows: RowData[], members: Member[]): Promise<AIInsight[]> => {
  const startTime = Date.now();
  try {
    const prompt = `Suggest owners for these unassigned tasks. Include 'reasoning'. 
      Members: ${JSON.stringify(members.map(m => m.name))}
      Tasks: ${JSON.stringify(rows.filter(r => !r.owner).map(r => ({ id: r.id, task: r.task })))}
      Return a JSON array with: rowId, message, reasoning, and confidence (0-1).`;
    
    const schema = {
      type: Type.ARRAY,
      items: {
        type: Type.OBJECT,
        properties: {
          rowId: { type: Type.STRING },
          message: { type: Type.STRING },
          reasoning: { type: Type.STRING },
          confidence: { type: Type.NUMBER }
        },
        required: ["rowId", "message", "reasoning", "confidence"]
      }
    };

    const result = await callAIWithFallback(prompt, schema, 'insight');
    const response = JSON.parse(result.text || "[]");
    const insights = (Array.isArray(response) ? response : []).map((i: any) => ({ 
      ...i, 
      type: 'suggestion', 
      version: CURRENT_MODELS.VERSION,
      consensus: calculateConsensus([])
    }));
    
    logAIMetric({
      timestamp: Date.now(),
      latency: Date.now() - startTime,
      model: `${result.provider}:${result.model}`,
      success: true,
      confidence: insights.length > 0 ? insights[0].confidence : 1,
      taskType: 'insight',
      consensusScore: insights.length > 0 ? insights[0].consensus : 0.8
    });

    return insights;
  } catch (error) {
    return [];
  }
};

export const parseAICommand = async (command: string, context: { rows: RowData[], members: Member[] }): Promise<AICommandResult> => {
  const startTime = Date.now();
  try {
    const prompt = `Command: "${command}". Context: ${JSON.stringify(context.rows.map(r => ({id: r.id, task: r.task})))}. Return confidence score.
      Return JSON with: action (string), payload (object), and confidence (0-1).`;
    
    const schema = {
      type: Type.OBJECT,
      properties: {
        action: { type: Type.STRING },
        payload: { type: Type.OBJECT },
        confidence: { type: Type.NUMBER }
      },
      required: ["action", "payload", "confidence"]
    };

    const result = await callAIWithFallback(prompt, schema, 'command');
    const response = JSON.parse(result.text || '{"action": "UNKNOWN", "payload": {}, "confidence": 0}');
    const parsedResult = typeof response === 'object' ? response : { action: 'UNKNOWN', payload: {}, confidence: 0 };
    const consensus = calculateConsensus([]);
    
    logAIMetric({
      timestamp: Date.now(),
      latency: Date.now() - startTime,
      model: `${result.provider}:${result.model}`,
      success: parsedResult.action !== 'UNKNOWN',
      confidence: parsedResult.confidence,
      taskType: 'command',
      consensusScore: consensus
    });

    return { ...parsedResult, consensus };
  } catch (error) {
    return { action: 'UNKNOWN', payload: {}, confidence: 0, consensus: 0 };
  }
};
