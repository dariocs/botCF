#!/bin/bash
export MCP_SERVER_CONFIG=/Home/DCS/mcp/.env
npx -y @ibm/ibmi-mcp-server@latest \
   --transport http \
   
