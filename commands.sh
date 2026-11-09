#!/bin/bash
# Скрипт выполнения практикума Модуля 7 (CouchDB)
# Внимание: перед запуском убедитесь, что CouchDB запущена, а переменные окружения заданы.

export COUCH_URL='http://127.0.0.1:5984'
export COUCH_USER='admin'
export COUCH_PASS='admin'

# 1. Создание базы
curl -i -X PUT --user "$COUCH_USER:$COUCH_PASS" "$COUCH_URL/ai_demo_m7"

# 2. Создание документа req-001
curl -i -X PUT --user "$COUCH_USER:$COUCH_PASS" \
  -H 'Content-Type: application/json' \
  "$COUCH_URL/ai_demo_m7/req-001" \
  --data-binary '{
    "model": {"name": "pet-classifier", "version": "1.0"},
    "input": {"text": "На диване сидит кошка", "language": "ru"},
    "predictions": [{"label": "cat", "score": 0.97}, {"label": "dog", "score": 0.02}],
    "processing_ms": 18,
    "status": "completed"
  }'

# 3. Создание документов через bulk_docs
curl -sS -X POST --user "$COUCH_USER:$COUCH_PASS" \
  -H 'Content-Type: application/json' \
  "$COUCH_URL/ai_demo_m7/_bulk_docs" \
  --data-binary '{"docs":[
    {"_id":"req-002","model":{"name":"pet-classifier","version":"1.0"},"processing_ms":45,"status":"completed"},
    {"_id":"req-003","model":{"name":"pet-classifier","version":"1.1"},"processing_ms":120,"status":"failed"}
  ]}'

# 4. Mango-запрос и индексы
curl -sS -X POST --user "$COUCH_USER:$COUCH_PASS" \
  -H 'Content-Type: application/json' \
  "$COUCH_URL/ai_demo_m7/_index" \
  --data-binary '{"index":{"fields":["status","processing_ms"]},"name":"idx_status_processing","type":"json"}'

curl -sS -X POST --user "$COUCH_USER:$COUCH_PASS" \
  -H 'Content-Type: application/json' \
  "$COUCH_URL/ai_demo_m7/_find" \
  --data-binary '{"selector":{"status":"completed", "processing_ms":{"$gt":30}}}'
