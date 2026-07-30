import os
import json
import asyncio
import hashlib
from pathlib import Path
from typing import Optional, List, Dict, Any
from datetime import datetime

import uvicorn
from fastapi import FastAPI, HTTPException, UploadFile, File
from fastapi.responses import JSONResponse
from pydantic import BaseModel

from llama_index.core import VectorStoreIndex, Document, Settings
from llama_index.core.node_parser import SentenceSplitter
from llama_index.vector_stores.postgres import PGVectorStore
from llama_index.core import StorageContext
from llama_index.embeddings.ollama import OllamaEmbedding
from llama_index.llms.openai import OpenAI

import fitz
import ebooklib
from ebooklib import epub
from bs4 import BeautifulSoup
import markdown

app = FastAPI(title="Brain Service PKB", description="Local Knowledge Base with PDF/EPUB/HTML/MD ingestion")

# CORS — allow bookmarklets and browser extensions to call the API
from fastapi.middleware.cors import CORSMiddleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

DB_NAME = os.getenv("DB_NAME", "vectordb")
DB_USER = os.getenv("DB_USER", "postgres")
DB_PASS = os.getenv("DB_PASS", "")
DB_HOST = os.getenv("DB_HOST", "127.0.0.1")
DB_PORT = os.getenv("DB_PORT", "5432")
LLM_API_KEY = os.getenv("LLM_API_KEY", "dummy")
LLM_API_BASE = os.getenv("LLM_API_BASE", "https://openrouter.ai/api/v1")
LLM_MODEL = os.getenv("LLM_MODEL", "gpt-4o-mini")
OLLAMA_URL = os.getenv("OLLAMA_URL", "http://127.0.0.1:11434")
EMBED_MODEL = os.getenv("EMBED_MODEL", "nomic-embed-text")
EMBED_DIM = int(os.getenv("EMBED_DIM", "768"))
BOOKS_DIR = os.getenv("BOOKS_DIR", "")
MANIFEST_PATH = os.getenv("MANIFEST_PATH", "/var/lib/brain-service/manifest.json")

Settings.embed_model = OllamaEmbedding(model_name=EMBED_MODEL, base_url=OLLAMA_URL)
Settings.llm = OpenAI(api_key=LLM_API_KEY, api_base=LLM_API_BASE, model=LLM_MODEL)
Settings.text_splitter = SentenceSplitter(chunk_size=1024, chunk_overlap=200)


def get_vector_store():
    return PGVectorStore.from_params(
        database=DB_NAME, host=DB_HOST, password=DB_PASS,
        port=DB_PORT, user=DB_USER, table_name="pkb_documents", embed_dim=EMBED_DIM,
    )


def get_index():
    vs = get_vector_store()
    ctx = StorageContext.from_defaults(vector_store=vs)
    return VectorStoreIndex.from_vector_store(vs, storage_context=ctx)


def load_manifest() -> dict:
    if os.path.exists(MANIFEST_PATH):
        with open(MANIFEST_PATH) as f:
            return json.load(f)
    return {"files": {}}


def save_manifest(manifest: dict):
    os.makedirs(os.path.dirname(MANIFEST_PATH), exist_ok=True)
    with open(MANIFEST_PATH, "w") as f:
        json.dump(manifest, f, indent=2)


def file_hash(path: str) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            h.update(chunk)
    return h.hexdigest()[:16]


def parse_pdf(path: str) -> List[Document]:
    docs = []
    pdf = fitz.open(path)
    title = os.path.basename(path)
    for i, page in enumerate(pdf):
        text = page.get_text()
        if text.strip():
            docs.append(Document(text=text, metadata={"source": title, "page": i + 1, "format": "pdf", "path": path}))
    pdf.close()
    return docs


def parse_epub(path: str) -> List[Document]:
    import re
    docs = []
    book = epub.read_epub(path)
    title = book.get_metadata("DC", "title")[0][0] if book.get_metadata("DC", "title") else os.path.basename(path)
    for item in book.get_items_of_type(ebooklib.ITEM_DOCUMENT):
        content = item.get_content().decode("utf-8", errors="ignore")
        text = re.sub(r"<[^>]+>", " ", content)
        text = re.sub(r"\s+", " ", text).strip()
        if text and len(text) > 50:
            docs.append(Document(text=text, metadata={"source": title, "chapter": item.get_name(), "format": "epub", "path": path}))
    return docs


def parse_html(path: str) -> List[Document]:
    with open(path) as f:
        html = f.read()
    soup = BeautifulSoup(html, "lxml")
    for tag in soup(["script", "style", "nav", "footer", "header"]):
        tag.decompose()
    title = soup.title.string if soup.title else os.path.basename(path)
    text = soup.get_text(separator="\n", strip=True)
    text = "\n".join(line.strip() for line in text.splitlines() if line.strip())
    if text and len(text) > 50:
        return [Document(text=text, metadata={"source": title, "format": "html", "path": path})]
    return []


def parse_markdown(path: str) -> List[Document]:
    import re
    with open(path) as f:
        md_text = f.read()
    if not md_text.strip():
        return []
    html = markdown.markdown(md_text, extensions=["tables", "fenced_code"])
    soup = BeautifulSoup(html, "lxml")
    docs = []
    current_text = []
    current_title = os.path.basename(path)
    for elem in soup.children:
        if elem.name in ("h1", "h2"):
            if current_text:
                section_text = "\n".join(current_text)
                if len(section_text.strip()) > 50:
                    docs.append(Document(text=section_text, metadata={"source": current_title, "format": "markdown", "path": path}))
            current_title = elem.get_text(strip=True)
            current_text = []
        else:
            current_text.append(elem.get_text(strip=True))
    if current_text:
        section_text = "\n".join(current_text)
        if len(section_text.strip()) > 50:
            docs.append(Document(text=section_text, metadata={"source": current_title, "format": "markdown", "path": path}))
    if not docs:
        docs.append(Document(text=md_text, metadata={"source": os.path.basename(path), "format": "markdown", "path": path}))
    return docs


def parse_text(path: str) -> List[Document]:
    with open(path) as f:
        text = f.read()
    if text.strip():
        return [Document(text=text, metadata={"source": os.path.basename(path), "format": "text", "path": path})]
    return []


def ingest_file(path: str) -> dict:
    ext = Path(path).suffix.lower()
    if ext == ".pdf":
        docs = parse_pdf(path)
    elif ext == ".epub":
        docs = parse_epub(path)
    elif ext in (".html", ".htm"):
        docs = parse_html(path)
    elif ext == ".md":
        docs = parse_markdown(path)
    elif ext in (".txt", ".rst"):
        docs = parse_text(path)
    else:
        return {"error": f"Unsupported format: {ext}", "count": 0}
    if not docs:
        return {"error": "No content extracted", "count": 0}
    index = get_index()
    for doc in docs:
        index.insert(doc)
    manifest = load_manifest()
    manifest["files"][path] = {"hash": file_hash(path), "docs": len(docs), "format": ext.lstrip(".")}
    save_manifest(manifest)
    return {"count": len(docs), "format": ext.lstrip(".")}


class RememberRequest(BaseModel):
    text: str
    source: Optional[str] = None
    user: Optional[str] = None
    project: Optional[str] = None
    tags: Optional[List[str]] = None


class QueryRequest(BaseModel):
    question: str
    scope: Optional[str] = None
    user: Optional[str] = None


@app.post("/remember")
async def remember(req: RememberRequest):
    try:
        metadata = {"source": req.source or "unknown", "user": req.user or "system", "project": req.project or "general", "tags": ",".join(req.tags) if req.tags else ""}
        doc = Document(text=req.text, metadata=metadata)
        index = get_index()
        index.insert(doc)
        return {"status": "success", "message": "Ingested into Brain."}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/ingest")
async def ingest_upload(file: UploadFile = File(...)):
    try:
        tmp_path = f"/tmp/brain-upload-{file.filename}"
        with open(tmp_path, "wb") as f:
            content = await file.read()
            f.write(content)
        result = ingest_file(tmp_path)
        os.remove(tmp_path)
        if "error" in result:
            raise HTTPException(status_code=400, detail=result["error"])
        return {"status": "success", **result}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/ingest/path")
async def ingest_from_path(path: str):
    if not os.path.exists(path):
        raise HTTPException(status_code=404, detail=f"File not found: {path}")
    result = ingest_file(path)
    if "error" in result:
        raise HTTPException(status_code=400, detail=result["error"])
    return {"status": "success", **result}


@app.post("/ingest/directory")
async def ingest_directory(directory: str):
    if not os.path.isdir(directory):
        raise HTTPException(status_code=404, detail=f"Directory not found: {directory}")
    manifest = load_manifest()
    results = []
    supported = (".pdf", ".epub", ".html", ".htm", ".md", ".txt", ".rst")
    for root, dirs, files in os.walk(directory):
        for fname in sorted(files):
            fpath = os.path.join(root, fname)
            ext = Path(fname).suffix.lower()
            if ext not in supported:
                continue
            fhash = file_hash(fpath)
            if fpath in manifest["files"] and manifest["files"][fpath]["hash"] == fhash:
                results.append({"file": fname, "status": "skipped", "reason": "already ingested"})
                continue
            result = ingest_file(fpath)
            status = "success" if "count" in result else "error"
            results.append({"file": fname, "status": status, **result})
    return {"status": "success", "files": len(results), "results": results}


@app.get("/manifest")
async def get_manifest():
    return load_manifest()


@app.post("/query")
async def query(req: QueryRequest):
    try:
        index = get_index()
        query_engine = index.as_query_engine()
        response = query_engine.query(req.question)
        sources = []
        for node in response.source_nodes:
            sources.append({"text": node.text[:500], "score": node.score, "metadata": node.metadata})

        manifest = load_manifest()
        if "queries" not in manifest:
            manifest["queries"] = {}
        query_key = hashlib.sha256(req.question.lower().strip().encode()).hexdigest()[:16]
        if query_key not in manifest["queries"]:
            manifest["queries"][query_key] = {"question": req.question, "count": 0, "sources_accessed": [], "first_asked": datetime.now().isoformat()}
        manifest["queries"][query_key]["count"] += 1
        manifest["queries"][query_key]["last_asked"] = datetime.now().isoformat()
        for src in sources:
            source_name = src["metadata"].get("source", "unknown")
            if source_name not in manifest["queries"][query_key]["sources_accessed"]:
                manifest["queries"][query_key]["sources_accessed"].append(source_name)
        save_manifest(manifest)

        return {"answer": str(response), "sources": sources, "query_id": query_key}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/frequent-queries")
async def frequent_queries(limit: int = 10):
    manifest = load_manifest()
    queries = manifest.get("queries", {})
    sorted_queries = sorted(queries.items(), key=lambda x: x[1].get("count", 0), reverse=True)[:limit]
    return {"frequent_queries": [{"query_id": k, "question": v["question"], "count": v["count"], "last_asked": v.get("last_asked"), "top_sources": v.get("sources_accessed", [])[:3]} for k, v in sorted_queries]}


@app.post("/auto-remember")
async def auto_remember(query_id: str):
    manifest = load_manifest()
    queries = manifest.get("queries", {})
    if query_id not in queries:
        raise HTTPException(status_code=404, detail="Query ID not found")
    query_info = queries[query_id]
    question = query_info["question"]
    index = get_index()
    query_engine = index.as_query_engine()
    response = query_engine.query(f"Provide a comprehensive summary about: {question}. Include key points, definitions, and practical information.")
    summary_text = f"# Auto-Generated Summary: {question}\n\nGenerated: {datetime.now().isoformat()}\nQuery Frequency: Asked {query_info['count']} times\n\n## Summary\n\n{response}\n\n## Sources\n\n"
    for node in response.source_nodes:
        source = node.metadata.get("source", "unknown")
        summary_text += f"- {source} (relevance: {node.score:.2f})\n"
    doc = Document(text=summary_text, metadata={"source": f"auto-summary-{query_id}", "format": "auto-generated"})
    index.insert(doc)
    if "auto_summaries" not in manifest:
        manifest["auto_summaries"] = []
    manifest["auto_summaries"].append({"query_id": query_id, "question": question, "generated_at": datetime.now().isoformat()})
    save_manifest(manifest)
    return {"status": "success", "message": f"Auto-generated summary for: {question}", "summary_preview": summary_text[:500]}


@app.get("/health")
async def health():
    return {"status": "healthy", "embed_model": EMBED_MODEL, "embed_dim": EMBED_DIM}


def run_mcp():
    from mcp.server import Server
    from mcp.server.stdio import stdio_server
    from mcp.types import Tool, TextContent

    server = Server("brain-service")

    @server.list_tools()
    async def list_tools():
        return [
            Tool(name="brain_query", description="Query the personal knowledge base for information from ingested books and documents", inputSchema={"type": "object", "properties": {"question": {"type": "string"}}, "required": ["question"]}),
            Tool(name="brain_remember", description="Store a piece of information in the knowledge base", inputSchema={"type": "object", "properties": {"text": {"type": "string"}, "source": {"type": "string"}, "tags": {"type": "array", "items": {"type": "string"}}}, "required": ["text"]}),
            Tool(name="brain_ingest_book", description="Ingest a document (PDF, EPUB, HTML, MD, TXT) into the knowledge base", inputSchema={"type": "object", "properties": {"path": {"type": "string"}}, "required": ["path"]}),
            Tool(name="brain_ingest_directory", description="Ingest all documents in a directory (recursive)", inputSchema={"type": "object", "properties": {"directory": {"type": "string"}}, "required": ["directory"]}),
            Tool(name="brain_list_books", description="List all ingested books and documents", inputSchema={"type": "object", "properties": {}}),
            Tool(name="brain_frequent_queries", description="Get most frequently asked questions", inputSchema={"type": "object", "properties": {"limit": {"type": "integer"}}}),
            Tool(name="brain_auto_remember", description="Auto-generate a summary for a frequently asked topic", inputSchema={"type": "object", "properties": {"query_id": {"type": "string"}}, "required": ["query_id"]}),
        ]

    @server.call_tool()
    async def call_tool(name: str, arguments: dict):
        if name == "brain_query":
            index = get_index()
            query_engine = index.as_query_engine()
            response = query_engine.query(arguments["question"])
            sources = [f"- {n.metadata.get('source', 'unknown')} (score: {n.score:.2f})" for n in response.source_nodes]
            return [TextContent(type="text", text=f"{response}\n\nSources:\n" + "\n".join(sources) if sources else str(response))]
        elif name == "brain_remember":
            metadata = {"source": arguments.get("source", "manual"), "tags": ",".join(arguments.get("tags", []))}
            doc = Document(text=arguments["text"], metadata=metadata)
            get_index().insert(doc)
            return [TextContent(type="text", text="Stored in knowledge base.")]
        elif name == "brain_ingest_book":
            path = arguments["path"]
            if not os.path.exists(path):
                return [TextContent(type="text", text=f"Error: File not found: {path}")]
            result = ingest_file(path)
            if "error" in result:
                return [TextContent(type="text", text=f"Error: {result['error']}")]
            return [TextContent(type="text", text=f"Ingested {result['count']} sections from {os.path.basename(path)}")]
        elif name == "brain_ingest_directory":
            directory = arguments["directory"]
            if not os.path.isdir(directory):
                return [TextContent(type="text", text=f"Error: Directory not found: {directory}")]
            manifest = load_manifest()
            count = 0
            for root, dirs, files in os.walk(directory):
                for fname in files:
                    fpath = os.path.join(root, fname)
                    ext = Path(fname).suffix.lower()
                    if ext not in (".pdf", ".epub", ".html", ".htm", ".md", ".txt"):
                        continue
                    fhash = file_hash(fpath)
                    if fpath in manifest["files"] and manifest["files"][fpath]["hash"] == fhash:
                        continue
                    result = ingest_file(fpath)
                    if "count" in result:
                        count += result["count"]
            return [TextContent(type="text", text=f"Ingested {count} new sections from {directory}")]
        elif name == "brain_list_books":
            manifest = load_manifest()
            if not manifest["files"]:
                return [TextContent(type="text", text="No books ingested yet.")]
            lines = ["Ingested books:"] + [f"- {os.path.basename(p)} ({i['format']}, {i['docs']} sections)" for p, i in manifest["files"].items()]
            return [TextContent(type="text", text="\n".join(lines))]
        elif name == "brain_frequent_queries":
            manifest = load_manifest()
            queries = manifest.get("queries", {})
            limit = arguments.get("limit", 10)
            sorted_q = sorted(queries.items(), key=lambda x: x[1].get("count", 0), reverse=True)[:limit]
            if not sorted_q:
                return [TextContent(type="text", text="No queries tracked yet.")]
            lines = ["Most frequently asked questions:"] + [f"- [{k}] {v['question']} (asked {v['count']}x)" for k, v in sorted_q]
            return [TextContent(type="text", text="\n".join(lines))]
        elif name == "brain_auto_remember":
            query_id = arguments.get("query_id", "")
            manifest = load_manifest()
            queries = manifest.get("queries", {})
            if query_id not in queries:
                return [TextContent(type="text", text=f"Query ID not found: {query_id}")]
            q = queries[query_id]
            question = q["question"]
            index = get_index()
            response = index.as_query_engine().query(f"Provide a comprehensive summary about: {question}")
            summary = f"# Auto-Generated Summary: {question}\n\n{response}\n"
            doc = Document(text=summary, metadata={"source": f"auto-summary-{query_id}", "format": "auto-generated"})
            index.insert(doc)
            return [TextContent(type="text", text=f"Auto-generated summary for: {question}")]
        return [TextContent(type="text", text=f"Unknown tool: {name}")]

    async def main():
        async with stdio_server() as (read_stream, write_stream):
            await server.run(read_stream, write_stream, server.create_initialization_options())
    asyncio.run(main())


def run_watcher():
    if not BOOKS_DIR:
        print("No BOOKS_DIR set, watcher disabled")
        return
    from watchdog.observers import Observer
    from watchdog.events import FileSystemEventHandler

    class BookHandler(FileSystemEventHandler):
        def on_created(self, event):
            if event.is_directory:
                return
            ext = Path(event.src_path).suffix.lower()
            if ext in (".pdf", ".epub", ".html", ".htm", ".md", ".txt", ".rst"):
                print(f"New file detected: {event.src_path}")
                try:
                    result = ingest_file(event.src_path)
                    print(f"Ingested: {result}")
                except Exception as e:
                    print(f"Error ingesting {event.src_path}: {e}")

    observer = Observer()
    observer.schedule(BookHandler(), BOOKS_DIR, recursive=True)
    observer.start()
    print(f"Watching {BOOKS_DIR} for new books...")
    try:
        while True:
            import time
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
    observer.join()


if __name__ == "__main__":
    mode = os.getenv("BRAIN_MODE", "api")
    if mode == "mcp":
        run_mcp()
    elif mode == "watcher":
        run_watcher()
    else:
        port = int(os.getenv("PORT", "8010"))
        host = os.getenv("HOST", "127.0.0.1")
        uvicorn.run(app, host=host, port=port)
