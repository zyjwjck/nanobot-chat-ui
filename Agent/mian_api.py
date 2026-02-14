#!/usr/bin/env python3
"""
nanobot-chat-ui main.py

This script creates a FastAPI application that exposes OpenAI-compatible LLM API
to interact with nanobot's core functionality.
"""

import asyncio
import json
from pathlib import Path
from typing import List, Optional, Dict, Any, Union

from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
import uvicorn
from loguru import logger

# Import nanobot modules
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from nanobot.bus.queue import MessageBus
from nanobot.config.loader import load_config
from nanobot.providers.litellm_provider import LiteLLMProvider
from nanobot.agent.loop import AgentLoop

# Create FastAPI app
app = FastAPI(
    title="nanobot-chat-ui API",
    description="OpenAI-compatible  API for nanobot",
    version="1.0.0"
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins for development
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Load nanobot config
config = load_config()

# Create message bus
bus = MessageBus()

# Create LLM provider
provider = None
if config.get_provider() and config.get_provider().api_key:
    provider = LiteLLMProvider(
        api_key=config.get_provider().api_key,
        api_base=config.get_api_base(),
        default_model=config.agents.defaults.model,
        extra_headers=config.get_provider().extra_headers if config.get_provider() else None,
    )
else:
    # Fallback to default provider if no API key configured
    provider = LiteLLMProvider(
        default_model=config.agents.defaults.model,
    )

# Create agent loop
agent = AgentLoop(
    bus=bus,
    provider=provider,
    workspace=config.workspace_path,
    model=config.agents.defaults.model,
    max_iterations=config.agents.defaults.max_tool_iterations,
    brave_api_key=config.tools.web.search.api_key or None,
    exec_config=config.tools.exec,
    restrict_to_workspace=config.tools.restrict_to_workspace,
)

# Start agent loop in background
async def start_agent():
    """Start the agent loop in background."""
    task = asyncio.create_task(agent.run())
    return task

agent_task = None

# OpenAI API models
class Message(BaseModel):
    """Message model for OpenAI API."""
    role: str
    content: str
    name: Optional[str] = None

class ChatCompletionRequest(BaseModel):
    """Chat completion request model for OpenAI API."""
    model: str
    messages: List[Message]
    temperature: Optional[float] = Field(default=1.0, ge=0, le=2)
    top_p: Optional[float] = Field(default=1.0, ge=0, le=1)
    n: Optional[int] = Field(default=1, ge=1)
    stream: Optional[bool] = Field(default=False)
    stop: Optional[Union[str, List[str]]] = None
    max_tokens: Optional[int] = Field(default=None, ge=1)
    presence_penalty: Optional[float] = Field(default=0, ge=-2, le=2)
    frequency_penalty: Optional[float] = Field(default=0, ge=-2, le=2)
    logit_bias: Optional[Dict[int, float]] = None
    user: Optional[str] = None

class Choice(BaseModel):
    """Choice model for OpenAI API response."""
    index: int
    message: Message
    finish_reason: str

class Usage(BaseModel):
    """Usage model for OpenAI API response."""
    prompt_tokens: int
    completion_tokens: int
    total_tokens: int

class ChatCompletionResponse(BaseModel):
    """Chat completion response model for OpenAI API."""
    id: str
    object: str
    created: int
    model: str
    choices: List[Choice]
    usage: Usage

# API endpoints
@app.on_event("startup")
async def startup_event():
    """Start the agent loop when the application starts."""
    global agent_task
    agent_task = await start_agent()

@app.on_event("shutdown")
async def shutdown_event():
    """Stop the agent loop when the application shuts down."""
    global agent_task
    agent.stop()
    if agent_task:
        agent_task.cancel()

@app.get("/v1/models")
async def list_models():
    """List available models (OpenAI-compatible endpoint)."""
    return {
        "object": "list",
        "data": [
            {
                "id": config.agents.defaults.model,
                "object": "model",
                "created": 1686935002,
                "owned_by": "nanobot",
                "permission": [
                    {
                        "id": "modelperm-49FUp5v084tBB49tC4z6ByT1",
                        "object": "model_permission",
                        "created": 1686935002,
                        "allow_create_engine": False,
                        "allow_sampling": True,
                        "allow_logprobs": True,
                        "allow_search_indices": False,
                        "allow_view": True,
                        "allow_fine_tuning": False,
                        "organization": "*",
                        "group": None,
                        "is_blocking": False
                    }
                ],
                "root": config.agents.defaults.model,
                "parent": None
            }
        ]
    }

@app.post("/v1/chat/completions", response_model=ChatCompletionResponse)
async def create_chat_completion(request: ChatCompletionRequest):
    """Create chat completion (OpenAI-compatible endpoint)."""
    import time
    start_time = time.time()
    request_id = f"req-{int(time.time() * 1000)}"
    
    try:
        # Log request start
        logger.info(f"[{request_id}] Received chat completion request: model={request.model}, messages_count={len(request.messages)}")
        
        # Build conversation history from request
        # Format messages as a single prompt for nanobot agent
        conversation = []
        for msg in request.messages:
            if msg.role == "system":
                conversation.append(f"System: {msg.content}")
            elif msg.role == "user":
                conversation.append(f"User: {msg.content}")
            elif msg.role == "assistant":
                conversation.append(f"Assistant: {msg.content}")
        
        # Combine messages into a single prompt
        prompt = "\n".join(conversation)
        logger.debug(f"[{request_id}] Built prompt: {prompt[:200]}..." if len(prompt) > 200 else f"[{request_id}] Built prompt: {prompt}")
        
        # Process message with nanobot agent
        # This will use nanobot's full agent capabilities, including tools and memory
        logger.info(f"[{request_id}] Processing message with nanobot agent...")
        response_content = await agent.process_direct(
            content=prompt,
            session_key="openai:default",
            channel="api",
            chat_id="default"
        )
        logger.info(f"[{request_id}] Received response from nanobot agent")
        logger.debug(f"[{request_id}] Agent response: {response_content[:200]}..." if len(response_content) > 200 else f"[{request_id}] Agent response: {response_content}")
        
        # Create response in OpenAI-compatible format
        response = ChatCompletionResponse(
            id=f"chatcmpl-{int(time.time() * 1000)}",
            object="chat.completion",
            created=int(time.time()),
            model=request.model,
            choices=[
                Choice(
                    index=0,
                    message=Message(
                        role="assistant",
                        content=response_content
                    ),
                    finish_reason="stop"
                )
            ],
            usage=Usage(
                prompt_tokens=len(prompt.split()),
                completion_tokens=len(response_content.split()),
                total_tokens=len(prompt.split()) + len(response_content.split())
            )
        )
        
        # Calculate processing time
        processing_time = time.time() - start_time
        logger.info(f"[{request_id}] Request processed successfully in {processing_time:.2f} seconds")
        
        return response
        
    except Exception as e:
        # Calculate processing time
        processing_time = time.time() - start_time
        logger.error(f"[{request_id}] Error processing request in {processing_time:.2f} seconds: {str(e)}")
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Error processing request: {str(e)}")

@app.get("/")
async def root():
    """Root endpoint."""
    return {
        "message": "Welcome to nanobot-chat-ui API",
        "version": "1.0.0",
        "endpoints": {
            "/v1/models": "List available models",
            "/v1/chat/completions": "Create chat completions"
        }
    }

if __name__ == "__main__":
    """Run the application."""
    uvicorn.run(
        "mian_api:app",
        host="0.0.0.0",
        port=5678,
        reload=True,
        app_dir=os.path.dirname(os.path.abspath(__file__))
    )
