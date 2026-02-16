# Dummy Data Guide

Guide for loading sample data into ProjectFlow for testing and development.

## Table of Contents

1. [Overview](#1-overview)
2. [Prerequisites](#2-prerequisites)
3. [Loading Dummy Data](#3-loading-dummy-data)
4. [Data Structure](#4-data-structure)
5. [Customizing Data](#5-customizing-data)

---

## 1. Overview

We have two dummy data migrations available:

### Migration 1: ML Observability Platform (`003_dummy_data.sql`)

Creates sample data for an ML Observability Platform project, including:

- ✅ **1 User** (AI Product Manager)
- ✅ **1 Workspace** (2021.ai Observability Workspace)
- ✅ **1 Project** (ML Observability Platform)
- ✅ **3 Sheets** (Roadmap, Architecture, Metrics)
- ✅ **15 Columns** (5 per sheet)
- ✅ **15 Rows** (5 per sheet with JSONB data)

### Data Hierarchy

```
Profile (AI Product Manager)
  └── Workspace (2021.ai Observability Workspace)
      └── Project (ML Observability Platform)
          ├── Sheet 1: Observability Roadmap
          │   ├── 5 Columns (Phase, Feature, Priority, Status, Owner)
          │   └── 5 Rows (Phases 1-5 with task data)
          ├── Sheet 2: Platform Architecture
          │   ├── 5 Columns (Layer Name, Function, Component Type, Criticality, Implemented)
          │   └── 5 Rows (Architecture layers)
          └── Sheet 3: Product Success Metrics
              ├── 5 Columns (Metric Name, Category, Target Value, Status, Owner)
              └── 5 Rows (Success metrics)

### Migration 2: North Denmark Region AI Transformation (`004_dummy_data_nordjylland.sql`)

Creates sample data for a Generative AI Platform Deployment project, including:

- ✅ **1 User** (AI Product Owner - owner@nordjylland.dk)
- ✅ **1 Workspace** (North Denmark Region AI Transformation)
- ✅ **1 Project** (Generative AI Platform Deployment)
- ✅ **4 Sheets** (Ownership, Trade-Offs, Challenges, KPIs)
- ✅ **20 Columns** (5 per sheet)
- ✅ **18 Rows** (5, 4, 4, 5 rows respectively)

### Data Hierarchy (Migration 2)

```
Profile (AI Product Owner)
  └── Workspace (North Denmark Region AI Transformation)
      └── Project (Generative AI Platform Deployment)
          ├── Sheet 1: Ownership and Responsibilities
          │   ├── 5 Columns (Area, Ownership Type, Description, Stakeholders, Impact Level)
          │   └── 5 Rows (Ownership areas)
          ├── Sheet 2: Architecture Trade-Offs
          │   ├── 5 Columns (Trade-Off Name, Option Chosen, Benefit, Cost/Risk, Outcome)
          │   └── 4 Rows (Architecture decisions)
          ├── Sheet 3: Challenges and Solutions
          │   ├── 5 Columns (Challenge, Root Cause, Solution, Result, Resolution Status)
          │   └── 4 Rows (Challenges faced)
          └── Sheet 4: KPIs and Outcomes
              ├── 5 Columns (Metric Name, Category, Baseline, Result, Impact Level)
              └── 5 Rows (Success metrics)

### Migration 3: Tal om Diabetes (`005_dummy_data_talomdiabetes.sql`)

Creates sample data for a Healthcare AI Conversational Platform project, including:

- ✅ **1 User** (Tal om Diabetes Product Owner - owner@talomdiabetes.ai)
- ✅ **1 Workspace** (GRACE AI Platform - Healthcare AI)
- ✅ **1 Project** (Tal om Diabetes Conversational Health Data Platform)
- ✅ **4 Sheets** (Product Ownership, Engineering Tasks, Challenges, KPIs)
- ✅ **20 Columns** (5 per sheet)
- ✅ **19 Rows** (5, 5, 4, 5 rows respectively)

### Data Hierarchy (Migration 3)

```
Profile (Tal om Diabetes Product Owner)
  └── Workspace (GRACE AI Platform - Healthcare AI)
      └── Project (Tal om Diabetes Conversational Health Data Platform)
          ├── Sheet 1: Core Product Ownership
          │   ├── 5 Columns (Task Name, Category, Priority, Status, Impact)
          │   └── 5 Rows (Product ownership tasks)
          ├── Sheet 2: Architecture and Engineering Tasks
          │   ├── 5 Columns (Task Name, Team, Complexity, Status, Risk Level)
          │   └── 5 Rows (Engineering tasks)
          ├── Sheet 3: Challenges and Solutions
          │   ├── 5 Columns (Challenge, Solution Approach, Severity, Status, Impact Area)
          │   └── 4 Rows (Challenges faced)
          └── Sheet 4: KPIs and Outcomes
              ├── 5 Columns (Metric Name, Category, Value, Impact Level, Status)
              └── 5 Rows (Success metrics)

### Migration 4: LIF2.0 Real-Time COVID Intelligence (`006_dummy_data_lif2.sql`)

Creates sample data for a Real-Time COVID Intelligence Platform project, including:

- ✅ **1 User** (Eureka Project Owner - eureka.owner@example.com)
- ✅ **1 Workspace** (LIF2.0 Real-Time Intelligence Workspace)
- ✅ **1 Project** (LIF2.0 Real-Time COVID Intelligence Platform)
- ✅ **4 Sheets** (Core Responsibilities, Challenges, Achievements, Trade-Offs)
- ✅ **20 Columns** (5 per sheet)
- ✅ **15 Rows** (4, 4, 4, 3 rows respectively)

### Data Hierarchy (Migration 4)

```
Profile (Eureka Project Owner)
  └── Workspace (LIF2.0 Real-Time Intelligence Workspace)
      └── Project (LIF2.0 Real-Time COVID Intelligence Platform)
          ├── Sheet 1: Core Responsibilities
          │   ├── 5 Columns (Responsibility Name, Category, Owner, Impact Level, Status)
          │   └── 4 Rows (Core responsibilities)
          ├── Sheet 2: Challenges and Solutions
          │   ├── 5 Columns (Challenge Name, Category, Solution, Severity, Resolution Status)
          │   └── 4 Rows (Challenges faced)
          ├── Sheet 3: Achievements and KPIs
          │   ├── 5 Columns (KPI Name, Category, Metric Value, Impact Level, Validated)
          │   └── 4 Rows (Success metrics)
          └── Sheet 4: Strategic Trade-Offs
              ├── 5 Columns (Trade-Off Name, Option Prioritized, Option Sacrificed, Reason, Outcome)
              └── 3 Rows (Strategic decisions)

### Migration 5: Stockholm County Social Services AI (`007_dummy_data_stockholm.sql`)

Creates sample data for an AI-Assisted Case Prioritization project, including:

- ✅ **1 User** (AI Governance Lead - owner@stockholm-ai-project.com)
- ✅ **1 Workspace** (Stockholm County Social Services AI Workspace)
- ✅ **1 Project** (AI-Assisted Case Prioritization)
- ✅ **3 Sheets** (Project Responsibilities, Challenges, KPIs)
- ✅ **15 Columns** (5 per sheet)
- ✅ **15 Rows** (5, 5, 5 rows respectively)

### Data Hierarchy (Migration 5)

```
Profile (AI Governance Lead)
  └── Workspace (Stockholm County Social Services AI Workspace)
      └── Project (AI-Assisted Case Prioritization)
          ├── Sheet 1: Project Responsibilities
          │   ├── 5 Columns (Responsibility Area, Owner, Category, Description, Priority)
          │   └── 5 Rows (Project responsibilities)
          ├── Sheet 2: Challenges and Solutions
          │   ├── 5 Columns (Challenge, Impact Level, Solution, Category, Resolved)
          │   └── 5 Rows (Challenges faced)
          └── Sheet 3: KPIs and Outcomes
              ├── 5 Columns (KPI Name, Category, Metric Value, Measurement Period, Status)
              └── 5 Rows (Success metrics)

### Migration 6: LinkGRC AI Compliance (`008_dummy_data_linkgrc.sql`)

Creates sample data for an AI-Powered Regulatory Monitoring Pipeline project, including:

- ✅ **1 User** (Product Owner - Regulatory Monitoring - product.owner@linkgrc.com)
- ✅ **1 Workspace** (LinkGRC AI Compliance Workspace)
- ✅ **1 Project** (AI-Powered Regulatory Monitoring Pipeline)
- ✅ **4 Sheets** (Challenges, Trade-Offs, KPIs, Team Responsibilities)
- ✅ **20 Columns** (5 per sheet)
- ✅ **16 Rows** (4, 3, 5, 4 rows respectively)

### Data Hierarchy (Migration 6)

```
Profile (Product Owner - Regulatory Monitoring)
  └── Workspace (LinkGRC AI Compliance Workspace)
      └── Project (AI-Powered Regulatory Monitoring Pipeline)
          ├── Sheet 1: Challenges and Solutions
          │   ├── 5 Columns (Challenge Name, Description, Solution Approach, Impact Level, Resolved)
          │   └── 4 Rows (Challenges faced)
          ├── Sheet 2: Key Trade-Off Decisions
          │   ├── 5 Columns (Trade-Off Title, Decision Made, Benefit, Sacrifice, Priority)
          │   └── 3 Rows (Strategic decisions)
          ├── Sheet 3: KPIs and Outcomes
          │   ├── 5 Columns (Metric Name, Category, Result, Improvement Percentage, Status)
          │   └── 5 Rows (Success metrics)
          └── Sheet 4: Team Responsibilities
              ├── 5 Columns (Team Name, Responsibility, Area Type, Criticality, Owned by Product)
              └── 4 Rows (Team ownership)

### Migration 7: Nuvve Energy Optimization (`009_dummy_data_nuvve.sql`)

Creates sample data for an AI Forecasting and Market Optimization Platform project, including:

- ✅ **1 User** (Energy AI Product Owner - owner@nuvve.com)
- ✅ **1 Workspace** (Nuvve Energy Optimization Workspace)
- ✅ **1 Project** (AI Forecasting and Market Optimization Platform)
- ✅ **4 Sheets** (Strategy Ownership, Challenges, KPIs, Trade-Offs)
- ✅ **16 Columns** (4 per sheet)
- ✅ **17 Rows** (5, 4, 5, 3 rows respectively)

### Data Hierarchy (Migration 7)

```
Profile (Energy AI Product Owner)
  └── Workspace (Nuvve Energy Optimization Workspace)
      └── Project (AI Forecasting and Market Optimization Platform)
          ├── Sheet 1: Strategy Ownership
          │   ├── 4 Columns (Strategy Area, Description, Impact Level, Ownership Type)
          │   └── 5 Rows (Strategy areas)
          ├── Sheet 2: Challenges and Solutions
          │   ├── 4 Columns (Challenge Name, Root Cause, Solution Implemented, Outcome Effectiveness)
          │   └── 4 Rows (Challenges faced)
          ├── Sheet 3: Achievements and KPIs
          │   ├── 4 Columns (KPI Category, Metric Name, Improvement Percentage, Business Impact Description)
          │   └── 5 Rows (Success metrics)
          └── Sheet 4: Trade-Off Decisions
              ├── 4 Columns (Trade-Off Decision, Option Chosen, Benefit Gained, Cost or Sacrifice)
              └── 3 Rows (Strategic decisions)

### Migration 8: Rigshospitalet AI Virtual Assistant (`010_dummy_data_rigshospitalet.sql`)

Creates sample data for a Healthcare AI Virtual Assistant project, including:

- ✅ **1 User** (Senior AI Engineer - ai.engineer@example.com)
- ✅ **1 Workspace** (Healthcare AI Projects Workspace)
- ✅ **1 Project** (Rigshospitalet AI Virtual Assistant)
- ✅ **3 Sheets** (Project Objectives, Challenges, KPIs)
- ✅ **15 Columns** (5 per sheet)
- ✅ **15 Rows** (5, 5, 5 rows respectively)

### Data Hierarchy (Migration 8)

```
Profile (Senior AI Engineer)
  └── Workspace (Healthcare AI Projects Workspace)
      └── Project (Rigshospitalet AI Virtual Assistant)
          ├── Sheet 1: Project Objectives
          │   ├── 5 Columns (Objective Name, Description, Category, Priority, Owner)
          │   └── 5 Rows (Project objectives)
          ├── Sheet 2: Challenges and Solutions
          │   ├── 5 Columns (Challenge Name, Description, Solution, Impact Level, Status)
          │   └── 5 Rows (Challenges faced)
          └── Sheet 3: KPIs and Outcomes
              ├── 5 Columns (KPI Name, Metric Description, Category, Result, Status)
              └── 5 Rows (Success metrics)

### Migration 9: Prometric AI (`011_dummy_data_prometric.sql`)

Creates sample data for an AI-Powered Proctoring and Responsible AI Monitoring project, including:

- ✅ **1 User** (AI Product Owner - owner@prometric-ai.com)
- ✅ **1 Workspace** (Prometric Responsible AI Workspace)
- ✅ **1 Project** (AI-Powered Proctoring and Responsible AI Monitoring)
- ✅ **3 Sheets** (Core Responsibilities, Challenges, KPIs)
- ✅ **15 Columns** (5 per sheet)
- ✅ **14 Rows** (5, 4, 5 rows respectively)

### Data Hierarchy (Migration 9)

```
Profile (AI Product Owner)
  └── Workspace (Prometric Responsible AI Workspace)
      └── Project (AI-Powered Proctoring and Responsible AI Monitoring)
          ├── Sheet 1: Core Responsibilities
          │   ├── 5 Columns (Area, Responsibility, Owner, Impact, Priority)
          │   └── 5 Rows (Core responsibilities)
          ├── Sheet 2: Challenges and Solutions
          │   ├── 5 Columns (Challenge, Description, Solution, Impact, Status)
          │   └── 4 Rows (Challenges faced)
          └── Sheet 3: Achievements and KPIs
              ├── 5 Columns (Category, Metric, Improvement, Business Impact, Success Level)
              └── 5 Rows (Success metrics)

### Migration 10: Plesner Enterprise AI (`012_dummy_data_plesner.sql`)

Creates sample data for an Enterprise LLM Assistant and Responsible AI Platform Rollout project, including:

- ✅ **1 User** (Enterprise AI Lead - ai.lead@plesner.com)
- ✅ **1 Workspace** (Plesner Enterprise AI Transformation)
- ✅ **1 Project** (Enterprise LLM Assistant and Responsible AI Platform Rollout)
- ✅ **4 Sheets** (Strategic Objectives, Trade-Offs, Challenges, KPIs)
- ✅ **20 Columns** (5 per sheet)
- ✅ **16 Rows** (5, 3, 4, 4 rows respectively)

### Data Hierarchy (Migration 10)

```
Profile (Enterprise AI Lead)
  └── Workspace (Plesner Enterprise AI Transformation)
      └── Project (Enterprise LLM Assistant and Responsible AI Platform Rollout)
          ├── Sheet 1: Strategic Objectives
          │   ├── 5 Columns (Objective Name, Category, Priority, Status, Impact Description)
          │   └── 5 Rows (Strategic objectives)
          ├── Sheet 2: Trade-Off Decisions
          │   ├── 5 Columns (Decision Title, Option Chosen, Benefit, Sacrifice, Decision Impact)
          │   └── 3 Rows (Trade-off decisions)
          ├── Sheet 3: Challenges and Solutions
          │   ├── 5 Columns (Challenge Name, Risk Level, Solution, Outcome, Status)
          │   └── 4 Rows (Challenges faced)
          └── Sheet 4: Achievements and KPIs
              ├── 5 Columns (Metric Name, Category, Result, Impact Level, Measured Outcome)
              └── 4 Rows (Success metrics)

### Migration 11: AI Credit Risk Platform (`013_dummy_data_credit_risk.sql`)

Creates sample data for a Real-Time AI Credit Risk Prediction project, including:

- ✅ **1 User** (AI Risk Product Owner - risk.ai.owner@example.com)
- ✅ **1 Workspace** (AI Credit Risk Platform Workspace)
- ✅ **1 Project** (Real-Time AI Credit Risk Prediction)
- ✅ **3 Sheets** (Objectives and KPIs, Challenges, Trade-offs)
- ✅ **15 Columns** (5 per sheet)
- ✅ **15 Rows** (5, 5, 5 rows respectively)

### Data Hierarchy (Migration 11)

```
Profile (AI Risk Product Owner)
  └── Workspace (AI Credit Risk Platform Workspace)
      └── Project (Real-Time AI Credit Risk Prediction)
          ├── Sheet 1: Objectives and KPIs
          │   ├── 5 Columns (Objective, Category, Metric, Result, Status)
          │   └── 5 Rows (Project objectives)
          ├── Sheet 2: Challenges and Solutions
          │   ├── 5 Columns (Challenge, Impact Level, Solution, Owner, Status)
          │   └── 5 Rows (Challenges faced)
          └── Sheet 3: Trade-offs and Decisions
              ├── 5 Columns (Decision Area, Option Chosen, Benefit, Trade-Off Cost, Status)
              └── 5 Rows (Architecture decisions)

### Migration 12: BetterNow AI Fundraising (`014_dummy_data_betternow.sql`)

Creates sample data for an AI Personalization and Recommendation Engine project, including:

- ✅ **1 User** (AI Product Manager - pm@betternow.ai)
- ✅ **1 Workspace** (BetterNow AI Fundraising Workspace)
- ✅ **1 Project** (AI Personalization and Recommendation Engine)
- ✅ **4 Sheets** (Project Overview, Trade-Offs, Challenges, KPIs)
- ✅ **16 Columns** (4, 5, 4, 4 columns respectively)
- ✅ **17 Rows** (5, 3, 4, 5 rows respectively)

### Data Hierarchy (Migration 12)

```
Profile (AI Product Manager)
  └── Workspace (BetterNow AI Fundraising Workspace)
      └── Project (AI Personalization and Recommendation Engine)
          ├── Sheet 1: Project Overview
          │   ├── 4 Columns (Category, Topic, Description, Impact Level)
          │   └── 5 Rows (Project context and goals)
          ├── Sheet 2: Trade-Off Decisions
          │   ├── 5 Columns (Trade-Off, Option A, Option B, Decision, Priority)
          │   └── 3 Rows (Strategic trade-offs)
          ├── Sheet 3: Challenges and Solutions
          │   ├── 4 Columns (Challenge, Root Cause, Solution, Status)
          │   └── 4 Rows (Challenges faced)
          └── Sheet 4: KPIs and Achievements
              ├── 4 Columns (Metric Category, Metric Name, Result, Trend)
              └── 5 Rows (Success metrics)

### Migration 13: Freight Market Forecasting (`015_dummy_data_freight_forecasting.sql`)

Creates sample data for a Freight Market Price Forecasting and Fleet Positioning Optimization project, including:

- ✅ **1 User** (Senior Data Engineer - engineer@example.com)
- ✅ **1 Workspace** (Freight Market Forecasting Workspace)
- ✅ **1 Project** (Freight Market Price Forecasting and Fleet Positioning Optimization)
- ✅ **4 Sheets** (Ownership Areas, Challenges, KPIs, Future Improvements)
- ✅ **16 Columns** (4 per sheet)
- ✅ **17 Rows** (5, 4, 5, 3 rows respectively)

### Data Hierarchy (Migration 13)

```
Profile (Senior Data Engineer)
  └── Workspace (Freight Market Forecasting Workspace)
      └── Project (Freight Market Price Forecasting and Fleet Positioning Optimization)
          ├── Sheet 1: Ownership Areas
          │   ├── 4 Columns (Ownership Area, Category, Description, Impact Level)
          │   └── 5 Rows (Ownership responsibilities)
          ├── Sheet 2: Challenges and Solutions
          │   ├── 4 Columns (Challenge, Solution, Priority, Status)
          │   └── 4 Rows (Challenges faced)
          ├── Sheet 3: Achievements and KPIs
          │   ├── 4 Columns (KPI Name, Category, Result, Impact Level)
          │   └── 5 Rows (Success metrics)
          └── Sheet 4: Future Improvements
              ├── 4 Columns (Improvement Area, Description, Priority, Status)
              └── 3 Rows (Future enhancements)

### Migration 14: Blockshipping AI Terminal Optimization (`016_dummy_data_blockshipping.sql`)

Creates sample data for an AI Import Dwell-Time Prediction for Container Terminal Optimization project, including:

- ✅ **1 User** (Blockshipping Project Owner - owner@blockshipping.ai)
- ✅ **1 Workspace** (AI Terminal Optimization Workspace)
- ✅ **1 Project** (AI Import Dwell-Time Prediction for Container Terminal Optimization)
- ✅ **3 Sheets** (Challenges, Trade-Offs, KPIs)
- ✅ **15 Columns** (5 per sheet)
- ✅ **12 Rows** (4, 3, 5 rows respectively)

### Data Hierarchy (Migration 14)

```
Profile (Blockshipping Project Owner)
  └── Workspace (AI Terminal Optimization Workspace)
      └── Project (AI Import Dwell-Time Prediction for Container Terminal Optimization)
          ├── Sheet 1: Challenges and Solutions
          │   ├── 5 Columns (Challenge, Solution, Impact Area, Status, Priority)
          │   └── 4 Rows (Challenges faced)
          ├── Sheet 2: Trade-Off Decisions
          │   ├── 5 Columns (Trade-Off, Decision, Reason, Outcome, Scalability Impact)
          │   └── 3 Rows (Strategic trade-offs)
          └── Sheet 3: Achievements and KPIs
              ├── 5 Columns (KPI Name, Metric Value, Category, Measurement Type, Status)
              └── 5 Rows (Success metrics)

### Migration 15: Blockshipping AI Optimization Multi-Project (`017_dummy_data_blockshipping_multi_project.sql`)

Creates sample data for a multi-project Blockshipping AI Optimization workspace, including:

- ✅ **1 User** (AI Product Lead - candidate@blockshipping.ai)
- ✅ **1 Workspace** (Blockshipping AI Optimization Workspace)
- ✅ **4 Projects**:
  - AI Import Dwell-Time Prediction
  - Operational Integration and Value Modeling
  - Platform Deployment and Scaling
  - Future Improvements and Strategic Enhancements
- ✅ **4 Sheets** (one per project)
- ✅ **20 Columns** (5 per sheet)
- ✅ **20 Rows** (5 rows per sheet)

### Data Hierarchy (Migration 15)

```
Profile (AI Product Lead)
  └── Workspace (Blockshipping AI Optimization Workspace)
      ├── Project 1: AI Import Dwell-Time Prediction
      │   └── Sheet: Project Goals and Success Metrics
      │       ├── 5 Columns (Goal, Description, Impact Area, Priority, Status)
      │       └── 5 Rows (Project goals)
      ├── Project 2: Operational Integration and Value Modeling
      │   └── Sheet: Key Challenges and Solutions
      │       ├── 5 Columns (Challenge, Root Cause, Solution, Category, Status)
      │       └── 5 Rows (Challenges faced)
      ├── Project 3: Platform Deployment and Scaling
      │   └── Sheet: Achievements and KPIs
      │       ├── 5 Columns (Metric, Description, Value, Impact Area, Achieved)
      │       └── 5 Rows (Success metrics)
          └── Project 4: Future Improvements and Strategic Enhancements
              └── Sheet: Future Improvements Roadmap
                  ├── 5 Columns (Improvement, Description, Expected Benefit, Priority, Status)
                  └── 5 Rows (Future enhancements)

### Migration 16: Regulatory Authority AI Transformation (`018_dummy_data_regulatory_authority.sql`)

Creates sample data for an AI Email Routing and Workflow Automation project, including:

- ✅ **1 User** (AI Workflow Project Owner - regulatory.ai.lead@example.com)
- ✅ **1 Workspace** (Regulatory Authority AI Transformation)
- ✅ **1 Project** (AI Email Routing and Workflow Automation)
- ✅ **3 Sheets** (Project Tasks, Challenges, KPIs)
- ✅ **15 Columns** (5 per sheet)
- ✅ **15 Rows** (5 rows per sheet)

### Data Hierarchy (Migration 16)

```
Profile (AI Workflow Project Owner)
  └── Workspace (Regulatory Authority AI Transformation)
      └── Project (AI Email Routing and Workflow Automation)
          ├── Sheet 1: Project Tasks
          │   ├── 5 Columns (Task Name, Category, Owner, Status, Impact Level)
          │   └── 5 Rows (Project tasks)
          ├── Sheet 2: Challenges and Solutions
          │   ├── 5 Columns (Challenge, Solution, Severity, Resolution Status, Owner)
          │   └── 5 Rows (Challenges faced)
          └── Sheet 3: KPIs and Outcomes
              ├── 5 Columns (Metric Name, Category, Value, Trend, Impact Level)
              └── 5 Rows (Success metrics)

### Migration 17: Rail Transport AI Intelligence (`019_dummy_data_rail_transport.sql`)

Creates sample data for a Customer Churn Prediction and Retention Intelligence project, including:

- ✅ **1 User** (AI Retention Lead - rail.ai.lead@example.com)
- ✅ **1 Workspace** (Rail Transport AI Intelligence Workspace)
- ✅ **1 Project** (Customer Churn Prediction and Retention Intelligence)
- ✅ **4 Sheets** (Project Objectives, Team Responsibilities, Challenges, KPIs)
- ✅ **20 Columns** (5 per sheet)
- ✅ **19 Rows** (5, 5, 4, 5 rows respectively)

### Data Hierarchy (Migration 17)

```
Profile (AI Retention Lead)
  └── Workspace (Rail Transport AI Intelligence Workspace)
      └── Project (Customer Churn Prediction and Retention Intelligence)
          ├── Sheet 1: Project Objectives
          │   ├── 5 Columns (Objective Name, Category, Business Impact, Priority, Status)
          │   └── 5 Rows (Project objectives)
          ├── Sheet 2: Team Responsibilities
          │   ├── 5 Columns (Team, Responsibility, Outcome, Impact Level, Completed)
          │   └── 5 Rows (Team responsibilities)
          ├── Sheet 3: Challenges and Solutions
          │   ├── 5 Columns (Challenge, Solution, Category, Difficulty, Resolved)
          │   └── 4 Rows (Challenges faced)
          └── Sheet 4: Achievements and KPIs
              ├── 5 Columns (Achievement, Impact Area, Business Value, Strategic Importance, Completed)
              └── 5 Rows (Success metrics)

### Migration 18: Global Bakery AI Transformation (`020_dummy_data_global_bakery.sql`)

Creates sample data for a Real-Time AI Sales Prediction and Recommendation Engine project, including:

- ✅ **1 User** (AI Sales Platform Owner - sales.ai.owner@example.com)
- ✅ **1 Workspace** (Global Bakery AI Transformation Workspace)
- ✅ **1 Project** (Real-Time AI Sales Prediction and Recommendation Engine)
- ✅ **4 Sheets** (Project Objectives, Challenges, KPIs, Trade-Offs)
- ✅ **20 Columns** (5 per sheet)
- ✅ **17 Rows** (5, 4, 5, 3 rows respectively)

### Data Hierarchy (Migration 18)

```
Profile (AI Sales Platform Owner)
  └── Workspace (Global Bakery AI Transformation Workspace)
      └── Project (Real-Time AI Sales Prediction and Recommendation Engine)
          ├── Sheet 1: Project Objectives and Strategy
          │   ├── 5 Columns (Objective, Description, Category, Priority, Status)
          │   └── 5 Rows (Project objectives)
          ├── Sheet 2: Challenges and Solutions
          │   ├── 5 Columns (Challenge, Solution, Impact Area, Complexity, Resolved)
          │   └── 4 Rows (Challenges faced)
          ├── Sheet 3: Achievements and KPIs
          │   ├── 5 Columns (Achievement, Category, Impact Level, Region, Verified)
          │   └── 5 Rows (Success metrics)
          └── Sheet 4: Trade-Off Decisions
              ├── 5 Columns (Decision, Chosen Approach, Benefit, Sacrifice, Strategic Impact)
              └── 3 Rows (Strategic trade-offs)
```

---

## 2. Prerequisites

### Before Loading Dummy Data

1. ✅ **Run initial schema migration**
   - Execute `001_initial_schema.sql` first
   - Execute `002_storage_and_functions.sql` if needed

2. ✅ **Create user in Supabase Auth**
   - Email: `pm@2021.ai`
   - Password: (your choice)
   - This user will own the workspace and project

3. ✅ **Get user UUID**
   - After creating the user, get their UUID from Supabase Dashboard
   - Or use Supabase SQL Editor: `SELECT id FROM auth.users WHERE email = 'pm@2021.ai';`

---

## 3. Loading Dummy Data

### Step 1: Update User UUID

**Important**: The migration uses a placeholder UUID. You must update it with your actual user ID.

1. **Get your user UUID:**
   ```sql
   SELECT id FROM auth.users WHERE email = 'pm@2021.ai';
   ```

2. **Update the migration file:**
   - Open `supabase/migrations/003_dummy_data.sql`
   - Replace all instances of `'00000000-0000-0000-0000-000000000001'::UUID` with your actual user UUID
   - Or use a variable at the top of the file

### Step 2: Choose Migration

**Available Migrations:**
- `003_dummy_data.sql` - ML Observability Platform (2021.ai)
- `004_dummy_data_nordjylland.sql` - North Denmark Region AI Transformation
- `005_dummy_data_talomdiabetes.sql` - Tal om Diabetes Healthcare AI Platform
- `006_dummy_data_lif2.sql` - LIF2.0 Real-Time COVID Intelligence Platform
- `007_dummy_data_stockholm.sql` - Stockholm County Social Services AI
- `008_dummy_data_linkgrc.sql` - LinkGRC AI Compliance
- `009_dummy_data_nuvve.sql` - Nuvve Energy Optimization
- `010_dummy_data_rigshospitalet.sql` - Rigshospitalet AI Virtual Assistant
- `011_dummy_data_prometric.sql` - Prometric AI Proctoring
- `012_dummy_data_plesner.sql` - Plesner Enterprise AI
- `013_dummy_data_credit_risk.sql` - AI Credit Risk Platform
- `014_dummy_data_betternow.sql` - BetterNow AI Fundraising
- `015_dummy_data_freight_forecasting.sql` - Freight Market Forecasting
- `016_dummy_data_blockshipping.sql` - Blockshipping AI Terminal Optimization
- `017_dummy_data_blockshipping_multi_project.sql` - Blockshipping AI Optimization (Multi-Project)
- `018_dummy_data_regulatory_authority.sql` - Regulatory Authority AI Transformation
- `019_dummy_data_rail_transport.sql` - Rail Transport AI Intelligence
- `020_dummy_data_global_bakery.sql` - Global Bakery AI Transformation

### Step 3: Run Migration

**Option A: Via Supabase Dashboard**

1. Go to Supabase Dashboard → **SQL Editor**
2. Open the migration file you want to use:
   - `supabase/migrations/003_dummy_data.sql` OR
   - `supabase/migrations/004_dummy_data_nordjylland.sql` OR
   - `supabase/migrations/005_dummy_data_talomdiabetes.sql` OR
   - `supabase/migrations/006_dummy_data_lif2.sql` OR
   - `supabase/migrations/007_dummy_data_stockholm.sql` OR
   - `supabase/migrations/008_dummy_data_linkgrc.sql` OR
   - `supabase/migrations/009_dummy_data_nuvve.sql` OR
   - `supabase/migrations/010_dummy_data_rigshospitalet.sql` OR
   - `supabase/migrations/011_dummy_data_prometric.sql` OR
   - `supabase/migrations/012_dummy_data_plesner.sql` OR
   - `supabase/migrations/013_dummy_data_credit_risk.sql` OR
   - `supabase/migrations/014_dummy_data_betternow.sql` OR
   - `supabase/migrations/015_dummy_data_freight_forecasting.sql` OR
   - `supabase/migrations/016_dummy_data_blockshipping.sql` OR
   - `supabase/migrations/017_dummy_data_blockshipping_multi_project.sql` OR
   - `supabase/migrations/018_dummy_data_regulatory_authority.sql` OR
   - `supabase/migrations/019_dummy_data_rail_transport.sql` OR
   - `supabase/migrations/020_dummy_data_global_bakery.sql`
3. Update the user UUID (see Step 1)
4. Click **Run** to execute

**Option B: Via Supabase CLI**

```bash
# Make sure you're linked to your project
supabase link --project-ref woigtfojjixtmwaoamap

# Run specific migration
supabase db push

# Or run individual migration file
supabase db execute -f supabase/migrations/003_dummy_data.sql
```

### Step 4: Verify Data

```sql
-- Check profile
SELECT * FROM profiles WHERE email = 'pm@2021.ai';

-- Check workspace
SELECT * FROM workspaces;

-- Check project
SELECT * FROM projects;

-- Check sheets
SELECT * FROM sheets;

-- Check columns
SELECT * FROM columns;

-- Check rows
SELECT id, sheet_id, row_data FROM rows LIMIT 5;
```

---

## 4. Data Structure

### 4.1 Row Data Format

**Our implementation uses JSONB** (not a cells table):

```json
{
  "Phase": "Phase 1",
  "Feature": "Prediction Logging and Performance Metrics",
  "Priority": "High",
  "Status": "Completed",
  "Owner": "AI Product Manager"
}
```

**Column mapping:**
- Column title → JSONB key
- Column value → JSONB value
- All cell data stored in `row_data` JSONB field

### 4.2 Dependencies

Rows can have dependencies (for task management):

```sql
dependencies: ARRAY['00000000-0000-0000-0000-000000000070'::TEXT]
```

This indicates the row depends on another row (task dependencies).

### 4.3 Sample Data

#### Sheet 1: Observability Roadmap

| Phase | Feature | Priority | Status | Owner |
|-------|---------|----------|--------|-------|
| Phase 1 | Prediction Logging and Performance Metrics | High | Completed | AI Product Manager |
| Phase 2 | Feature and Prediction Drift Detection | High | In Progress | ML Engineering Team |
| Phase 3 | Model Explainability and Feature Attribution | High | Planned | ML Research Team |
| Phase 4 | Audit Logs and Compliance Reporting | Medium | Planned | Compliance Team |
| Phase 5 | Automated Retraining Triggers and Alerts | Medium | Planned | Platform Engineering |

#### Sheet 2: Platform Architecture

| Layer Name | Function | Component Type | Criticality | Implemented |
|------------|----------|----------------|-------------|-------------|
| Data Ingestion Layer | Collect model inputs, outputs, metadata, and ground truth | Data | High | ✅ |
| Monitoring Layer | Compute statistical drift, performance, and data quality metrics | Monitoring | High | ✅ |
| Explainability Layer | Provide feature attribution and model interpretability | Explainability | High | ❌ |
| Storage Layer | Store historical observability and monitoring data | Storage | High | ✅ |
| Visualization Layer | Provide dashboards, alerts, and reporting | Visualization | Medium | ❌ |

#### Sheet 3: Product Success Metrics

| Metric Name | Metric Category | Target Value | Current Status | Owner |
|-------------|-----------------|--------------|----------------|-------|
| Model Drift Detection Latency | Technical | < 5 minutes | On Track | Engineering Team |
| Dashboard Usage Frequency | User | Daily Active Usage | On Track | Product Team |
| Customer Retention Rate | Business | > 90% | At Risk | Customer Success Team |
| Compliance Readiness Score | Governance | 100% Auditability | On Track | Compliance Team |
| Platform Adoption Rate | Business | > 75% Enterprise Adoption | Behind | Executive Team |

---

## 5. Customizing Data

### 5.1 Add More Users

```sql
-- Create user in Supabase Auth first, then:
INSERT INTO profiles (id, name, email, color)
VALUES (
  'your-user-uuid'::UUID,
  'User Name',
  'user@example.com',
  '#a855f7'
);
```

### 5.2 Add More Workspaces

```sql
INSERT INTO workspaces (id, name, owner_id) VALUES
('new-workspace-uuid'::UUID, 'New Workspace', 'user-uuid'::UUID);

INSERT INTO workspace_members (workspace_id, user_id, role)
VALUES ('new-workspace-uuid'::UUID, 'user-uuid'::UUID, 'Owner');
```

### 5.3 Add More Rows

```sql
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  'new-row-uuid'::UUID,
  'sheet-uuid'::UUID,
  '{
    "Column1": "Value1",
    "Column2": "Value2",
    "Status": "In Progress"
  }'::jsonb,
  ARRAY[]::TEXT[]
);
```

### 5.4 Update Row Data

```sql
UPDATE rows
SET row_data = jsonb_set(
  row_data,
  '{Status}',
  '"Completed"'
)
WHERE id = 'row-uuid'::UUID;
```

---

## 6. Troubleshooting

### Error: Foreign Key Violation

**Problem**: User doesn't exist in `auth.users`

**Solution**:
1. Create user in Supabase Auth first
2. Get the user UUID
3. Update the migration with correct UUID

### Error: Duplicate Key

**Problem**: Data already exists

**Solution**:
- The migration uses `ON CONFLICT DO NOTHING` - safe to run multiple times
- Or delete existing data first:
  ```sql
  DELETE FROM rows;
  DELETE FROM columns;
  DELETE FROM sheets;
  DELETE FROM projects;
  DELETE FROM workspace_members;
  DELETE FROM workspaces;
  DELETE FROM profiles WHERE email = 'pm@2021.ai';
  ```

### Error: JSONB Format

**Problem**: Invalid JSONB syntax

**Solution**:
- Ensure JSON is valid
- Use `'{"key": "value"}'::jsonb` format
- Check for proper escaping of quotes

---

## 7. Querying Dummy Data

### Get All Rows with Data

```sql
SELECT 
  s.name as sheet_name,
  r.id,
  r.row_data
FROM rows r
JOIN sheets s ON r.sheet_id = s.id
ORDER BY s.name, r.created_at;
```

### Get Rows by Status

```sql
SELECT *
FROM rows
WHERE row_data->>'Status' = 'In Progress';
```

### Get Rows with Dependencies

```sql
SELECT 
  id,
  row_data->>'Feature' as feature,
  dependencies
FROM rows
WHERE array_length(dependencies, 1) > 0;
```

### Get Project Summary

```sql
SELECT 
  p.name as project_name,
  COUNT(DISTINCT s.id) as sheet_count,
  COUNT(DISTINCT c.id) as column_count,
  COUNT(DISTINCT r.id) as row_count
FROM projects p
LEFT JOIN sheets s ON s.project_id = p.id
LEFT JOIN columns c ON c.sheet_id = s.id
LEFT JOIN rows r ON r.sheet_id = s.id
GROUP BY p.id, p.name;
```

---

## 8. Summary

### Key Points

1. ✅ **Update user UUID** before running migration
2. ✅ **Uses JSONB** (not cells table) - matches our implementation
3. ✅ **Safe to run multiple times** - uses `ON CONFLICT DO NOTHING`
4. ✅ **Includes dependencies** - for task management features

### Quick Start

```bash
# 1. Create user in Supabase Auth (pm@2021.ai)
# 2. Get user UUID
# 3. Update migration file with user UUID
# 4. Run migration in Supabase SQL Editor
# 5. Verify data loaded correctly
```

---

**Dummy data is ready to use for testing and development!** 🚀
