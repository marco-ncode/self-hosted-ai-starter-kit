# Self-hosted AI starter kit

**Self-hosted AI Starter Kit** is an open-source Docker Compose template designed to swiftly initialize a comprehensive local AI and low-code development environment.

![n8n.io - Screenshot](https://raw.githubusercontent.com/n8n-io/self-hosted-ai-starter-kit/main/assets/n8n-demo.gif)

Curated by <https://github.com/n8n-io>, it combines the self-hosted n8n
platform with a curated list of compatible AI products and components to
quickly get started with building self-hosted AI workflows.

> [!TIP]
> [Read the announcement](https://blog.n8n.io/self-hosted-ai/)

### What’s included

✅ [**Self-hosted n8n**](https://n8n.io/) - Low-code platform with over 400
integrations and advanced AI components

✅ [**Ollama**](https://ollama.com/) - Cross-platform LLM platform to install
and run the latest local LLMs

✅ [**Qdrant**](https://qdrant.tech/) - Open-source, high performance vector
store with an comprehensive API

✅ [**PostgreSQL**](https://www.postgresql.org/) -  Workhorse of the Data
Engineering world, handles large amounts of data safely.

✅ [**Caddy**](https://caddyserver.com/) - Reverse proxy with automatic HTTPS
support for exposing n8n and Qdrant on public domains.

✅ [**Supabase (self-hosted)**](https://supabase.com/docs/guides/hosting/docker) - Open-source backend stack (Postgres, Auth, REST, Realtime, Storage, Studio).

### What you can build

⭐️ **AI Agents** for scheduling appointments

⭐️ **Summarize Company PDFs** securely without data leaks

⭐️ **Smarter Slack Bots** for enhanced company communications and IT operations

⭐️ **Private Financial Document Analysis** at minimal cost

## Installation

### Cloning the Repository

```bash
git clone https://github.com/marco-ncode/self-hosted-ai-starter-kit.git
cd self-hosted-ai-starter-kit
cp .env.example .env # you should update secrets and passwords inside
```

### Optional: expose n8n and Qdrant via Caddy

If you want to expose n8n and Qdrant on public domains, configure these values
in your `.env` file:

- `N8N_DOMAIN`
- `QDRANT_DOMAIN`

To generate the password hash for Qdrant basic auth with Caddy:

```bash
docker run --rm caddy:2 caddy hash-password --plaintext 'YOUR_PASSWORD'
```

Then edit the `basicauth` block in `Caddyfile` directly:

```caddy
{$QDRANT_DOMAIN} {
	basicauth {
		admin $2a$14$INSERISCI_QUI_L_HASH
	}
}
```

### Optional: enable Supabase stack (with Caddy protection)

This repo includes [`docker-compose.supabase.yml`](docker-compose.supabase.yml) with a Supabase core stack:

- `supabase-db`
- `supabase-auth`
- `supabase-rest`
- `supabase-realtime`
- `supabase-storage`
- `supabase-meta`
- `supabase-studio`
- `supabase-kong`
- `supabase-imgproxy`

Set these values in `.env` before starting:

- `SUPABASE_DOMAIN`
- `SUPABASE_PUBLIC_URL`
- `SUPABASE_SITE_URL`
- `SUPABASE_POSTGRES_PASSWORD`
- `SUPABASE_JWT_SECRET`
- `SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_ROLE_KEY`
- `SUPABASE_SECRET_KEY_BASE`

You can generate base secrets quickly:

```bash
openssl rand -base64 48   # SUPABASE_JWT_SECRET
openssl rand -base64 48   # SUPABASE_SECRET_KEY_BASE
```

Then set `SUPABASE_ANON_KEY` and `SUPABASE_SERVICE_ROLE_KEY` with JWT tokens signed using `SUPABASE_JWT_SECRET`.

Start the main stack + Supabase (CPU example):

```bash
docker compose -f docker-compose.yml -f docker-compose.supabase.yml --profile cpu --profile supabase up -d
```

Supabase API gateway will be available on `:8000` and protected through Caddy on `SUPABASE_DOMAIN`.
Edit the `{$SUPABASE_DOMAIN}` `basicauth` block in [Caddyfile](Caddyfile) to set your own user/password hash.

### Running n8n using Docker Compose

#### For Nvidia GPU users

```bash
git clone https://github.com/marco-ncode/self-hosted-ai-starter-kit.git
cd self-hosted-ai-starter-kit
cp .env.example .env # you should update secrets and passwords inside
docker compose --profile gpu-nvidia up
```

> [!NOTE]
> If you have not used your Nvidia GPU with Docker before, please follow the
> [Ollama Docker instructions](https://github.com/ollama/ollama/blob/main/docs/docker.md).

### For AMD GPU users on Linux

```bash
git clone https://github.com/marco-ncode/self-hosted-ai-starter-kit.git
cd self-hosted-ai-starter-kit
cp .env.example .env # you should update secrets and passwords inside
docker compose --profile gpu-amd up
```

#### For Mac / Apple Silicon users

If you’re using a Mac with an M1 or newer processor, you can't expose your GPU
to the Docker instance, unfortunately. There are two options in this case:

1. Run the starter kit fully on CPU, like in the section "For everyone else"
   below
2. Run Ollama on your Mac for faster inference, and connect to that from the
   n8n instance

If you want to run Ollama on your mac, check the
[Ollama homepage](https://ollama.com/)
for installation instructions, and run the starter kit as follows:

```bash
git clone https://github.com/marco-ncode/self-hosted-ai-starter-kit.git
cd self-hosted-ai-starter-kit
cp .env.example .env # you should update secrets and passwords inside
docker compose up
```

##### For Mac users running OLLAMA locally

If you're running OLLAMA locally on your Mac (not in Docker), you need to modify the OLLAMA_HOST environment variable

1. Set OLLAMA_HOST to `host.docker.internal:11434` in your .env file. 
2. Additionally, after you see "Editor is now accessible via: <http://localhost:5678/>":

    1. Head to <http://localhost:5678/home/credentials>
    2. Click on "Local Ollama service"
    3. Change the base URL to "http://host.docker.internal:11434/"

#### For everyone else

```bash
git clone https://github.com/marco-ncode/self-hosted-ai-starter-kit.git
cd self-hosted-ai-starter-kit
cp .env.example .env # you should update secrets and passwords inside
docker compose --profile cpu up
```

## ⚡️ Quick start and usage

The core of the Self-hosted AI Starter Kit is a Docker Compose file, pre-configured with network and storage settings, minimizing the need for additional installations.
After completing the installation steps above, simply follow the steps below to get started.

1. Open <http://localhost:5678/> in your browser to set up n8n. You’ll only
   have to do this once.
2. Open the included workflow:
   <http://localhost:5678/workflow/srOnR8PAY3u4RSwb>
3. Click the **Chat** button at the bottom of the canvas, to start running the workflow.
4. If this is the first time you’re running the workflow, you may need to wait
   until Ollama finishes downloading Llama3.2. You can inspect the docker
   console logs to check on the progress.

To open n8n at any time, visit <http://localhost:5678/> in your browser.

With your n8n instance, you’ll have access to over 400 integrations and a
suite of basic and advanced AI nodes such as
[AI Agent](https://docs.n8n.io/integrations/builtin/cluster-nodes/root-nodes/n8n-nodes-langchain.agent/),
[Text classifier](https://docs.n8n.io/integrations/builtin/cluster-nodes/root-nodes/n8n-nodes-langchain.text-classifier/),
and [Information Extractor](https://docs.n8n.io/integrations/builtin/cluster-nodes/root-nodes/n8n-nodes-langchain.information-extractor/)
nodes. To keep everything local, just remember to use the Ollama node for your
language model and Qdrant as your vector store.

> [!NOTE]
> This starter kit is designed to help you get started with self-hosted AI
> workflows. While it’s not fully optimized for production environments, it
> combines robust components that work well together for proof-of-concept
> projects. You can customize it to meet your specific needs

## Upgrading

* ### For Nvidia GPU setups:

```bash
docker compose --profile gpu-nvidia pull
docker compose create && docker compose --profile gpu-nvidia up
```

* ### For Mac / Apple Silicon users

```bash
docker compose pull
docker compose create && docker compose up
```

* ### For Non-GPU setups:

```bash
docker compose --profile cpu pull
docker compose create && docker compose --profile cpu up
```

## 👓 Recommended reading

n8n is full of useful content for getting started quickly with its AI concepts
and nodes. If you run into an issue, go to [support](#support).

- [AI agents for developers: from theory to practice with n8n](https://blog.n8n.io/ai-agents/)
- [Tutorial: Build an AI workflow in n8n](https://docs.n8n.io/advanced-ai/intro-tutorial/)
- [Langchain Concepts in n8n](https://docs.n8n.io/advanced-ai/langchain/langchain-n8n/)
- [Demonstration of key differences between agents and chains](https://docs.n8n.io/advanced-ai/examples/agent-chain-comparison/)
- [What are vector databases?](https://docs.n8n.io/advanced-ai/examples/understand-vector-databases/)

## 🎥 Video walkthrough

- [Installing and using Local AI for n8n](https://www.youtube.com/watch?v=xz_X2N-hPg0)

## 🛍️ More AI templates

For more AI workflow ideas, visit the [**official n8n AI template
gallery**](https://n8n.io/workflows/categories/ai/). From each workflow,
select the **Use workflow** button to automatically import the workflow into
your local n8n instance.

### Learn AI key concepts

- [AI Agent Chat](https://n8n.io/workflows/1954-ai-agent-chat/)
- [AI chat with any data source (using the n8n workflow too)](https://n8n.io/workflows/2026-ai-chat-with-any-data-source-using-the-n8n-workflow-tool/)
- [Chat with OpenAI Assistant (by adding a memory)](https://n8n.io/workflows/2098-chat-with-openai-assistant-by-adding-a-memory/)
- [Use an open-source LLM (via Hugging Face)](https://n8n.io/workflows/1980-use-an-open-source-llm-via-huggingface/)
- [Chat with PDF docs using AI (quoting sources)](https://n8n.io/workflows/2165-chat-with-pdf-docs-using-ai-quoting-sources/)
- [AI agent that can scrape webpages](https://n8n.io/workflows/2006-ai-agent-that-can-scrape-webpages/)

### Local AI templates

- [Tax Code Assistant](https://n8n.io/workflows/2341-build-a-tax-code-assistant-with-qdrant-mistralai-and-openai/)
- [Breakdown Documents into Study Notes with MistralAI and Qdrant](https://n8n.io/workflows/2339-breakdown-documents-into-study-notes-using-templating-mistralai-and-qdrant/)
- [Financial Documents Assistant using Qdrant and](https://n8n.io/workflows/2335-build-a-financial-documents-assistant-using-qdrant-and-mistralai/) [Mistral.ai](http://mistral.ai/)
- [Recipe Recommendations with Qdrant and Mistral](https://n8n.io/workflows/2333-recipe-recommendations-with-qdrant-and-mistral/)

## Tips & tricks

### Accessing local files

The self-hosted AI starter kit will create a shared folder (by default,
located in the same directory) which is mounted to the n8n container and
allows n8n to access files on disk. This folder within the n8n container is
located at `/data/shared` -- this is the path you’ll need to use in nodes that
interact with the local filesystem.

**Nodes that interact with the local filesystem**

- [Read/Write Files from Disk](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.filesreadwrite/)
- [Local File Trigger](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.localfiletrigger/)
- [Execute Command](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.executecommand/)

### Ollama Docker quick commands

Open a shell inside the running Ollama container:

```bash
docker exec -it ollama bash
```

Then run these commands inside that shell:

```bash
# List installed models
ollama list

# Pull/install a model
ollama pull llama3.2

# Run a quick prompt
ollama run llama3.2 "Hello from Docker"

# Show model details
ollama show llama3.2

# Remove a model
ollama rm llama3.2
```

## 📜 License

This project is licensed under the Apache License 2.0 - see the
[LICENSE](LICENSE) file for details.

## 💬 Support

Join the conversation in the [n8n Forum](https://community.n8n.io/), where you
can:

- **Share Your Work**: Show off what you’ve built with n8n and inspire others
  in the community.
- **Ask Questions**: Whether you’re just getting started or you’re a seasoned
  pro, the community and our team are ready to support with any challenges.
- **Propose Ideas**: Have an idea for a feature or improvement? Let us know!
  We’re always eager to hear what you’d like to see next.
