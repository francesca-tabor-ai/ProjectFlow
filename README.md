<div align="center">
<img width="1200" height="475" alt="GHBanner" src="https://github.com/user-attachments/assets/0aa67016-6eaf-458a-adb2-6e31a0763ed6" />
</div>

# ProjectFlow

ProjectFlow is a world-class, high-performance project management platform designed to blend the flexible power of spreadsheets with the structured logic of enterprise-grade planning tools. Inspired by industry leaders like Smartsheet and Monday.com, it provides a "single source of truth" for teams managing complex lifecycles, with a specific focus on AI development and operations.

## Core Capabilities

**The Unified Data Engine:** A high-performance spreadsheet grid featuring inline editing, column resizing, and support for diverse data types (Text, Number, Date, Dropdowns, Checkboxes). It includes a built-in Formula Engine that handles real-time calculations and cross-row aggregates like SUM and COUNT.

**Multidimensional Visualization:**
- **Timeline (Gantt):** Interactive schedule management with drag-and-drop task resizing, dependency linking, and progress tracking.
- **Board (Kanban):** A visual workflow manager for tracking tasks through status lanes.
- **Calendar:** A date-centric view for monitoring deadlines and resource allocation.

**AI Architect & Reliability Core:** Powered by Google Gemini 3, the platform includes an intelligent assistant that can auto-generate complete project plans from natural language objectives. It features a sophisticated Reliability Dashboard that monitors AI latency, confidence levels, and "self-healing" routing to ensure consistent performance.

**Workspace Governance:** A robust CRUD system for managing Users and Roles. Administrators can define custom security profiles, assign granular permissions at the sheet or column level, and manage team offboarding through a centralized governance portal.

**Enterprise Features:**
- **Automations:** A rule-based trigger system (e.g., "If status becomes Blocked, notify Owner").
- **Integrations:** Native-style hooks for Google Drive file attachments, Slack webhooks, and a developer-ready API key registry.
- **Bulk Processing:** High-speed CSV import for transitioning legacy data into active project flows.
- **Real-time Collaboration:** Synchronized cursors and presence indicators allow multiple team members to edit the same sheet simultaneously without conflict.

## Technical Architecture

- **Frontend:** Built with React and Tailwind CSS, prioritizing a "glassmorphism" aesthetic with fluid animations and zero-latency state updates.
- **Intelligence:** Deep integration with the @google/genai SDK, utilizing multi-model consensus (Pro vs. Flash) for optimal cost and accuracy.
- **Persistence & Sync:** Utilizes local storage for zero-config persistence and the BroadcastChannel API to simulate a high-speed WebSocket environment for real-time collaboration.

ProjectFlow isn't just a task list; it's a comprehensive infrastructure designed for high-performance teams who require data-driven insights and absolute control over their operational governance.

---

# Run and deploy your AI Studio app

This contains everything you need to run your app locally.

View your app in AI Studio: https://ai.studio/apps/drive/1gbzUyqkM4dFZdRbnCjdLMlcN3--065Eo

## Run Locally

**Prerequisites:**  Node.js


1. Install dependencies:
   `npm install`
2. Configure API keys in [`.env.local`](.env.local) (click the link to open in Cursor)
   - **Priority order:** OPENAI_API_KEY → ANTHROPIC_API_KEY → GEMINI_API_KEY
   - The system will automatically use the first available API key in priority order
   - Replace the placeholder values with your actual API keys:
     - **OPENAI_API_KEY** (Priority 1): Get from [OpenAI Platform](https://platform.openai.com/api-keys)
     - **ANTHROPIC_API_KEY** (Priority 2 - Fallback): Get from [Anthropic Console](https://console.anthropic.com/settings/keys)
     - **GEMINI_API_KEY** (Priority 3 - Last Fallback): Get from [Google AI Studio](https://aistudio.google.com/apikey)
3. Run the app:
   `npm run dev`
