````markdown
# FastAPI API

This API receives banking transaction events through the `/transactions` route.

## 1. Install Requirements

From the project root:

```powershell
py -m pip install -r requirements.txt
````

If FastAPI or Uvicorn is missing, install them:

```powershell
py -m pip install fastapi uvicorn requests pydantic
```

---

## 2. Start the FastAPI Server

Open **Terminal 1** and run:

```powershell
py -m uvicorn api.main:app --reload
```

You should see:

```text
Uvicorn running on http://127.0.0.1:8000
Application startup complete.
```

The API is now running.

You can also open the API documentation:

```text
http://127.0.0.1:8000/docs
```

---

## 3. Test the API

Keep **Terminal 1** running.

Open **Terminal 2** from the project root and run:

```powershell
py -m api.test_client
```

If the API is working, you should receive a response similar to:

```text
{
    'message': 'Transaction received',
    'transaction_id': '...'
}
```

Terminal 1 should also show:

```text
POST /transactions HTTP/1.1" 200 OK
```

This confirms that:

```text
test_client
     ↓
HTTP POST
     ↓
FastAPI
     ↓
/transactions
     ↓
200 OK
```

---

## 4. If It Does Not Work

First make sure **Terminal 1 is still running the FastAPI server**.

If you see:

```text
Connection refused
```

the server is probably not running.

Start it again:

```powershell
py -m uvicorn api.main:app --reload
```

If you see:

```text
ModuleNotFoundError
```

install the project requirements:

```powershell
py -m pip install -r requirements.txt
```

Or install the main dependencies:

```powershell
py -m pip install fastapi uvicorn requests pydantic
```

You can verify the important packages with:

```powershell
py -m pip show fastapi
py -m pip show uvicorn
py -m pip show requests
py -m pip show pydantic
```

---

## Quick Test

### Terminal 1

```powershell
py -m uvicorn api.main:app --reload
```

### Terminal 2

```powershell
py -m api.test_client
```

### Expected result

```text
Terminal 1:
POST /transactions HTTP/1.1" 200 OK

Terminal 2:
{'message': 'Transaction received', 'transaction_id': '...'}
```

If both appear, **the FastAPI endpoint is working correctly.**

```
```
