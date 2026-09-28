#!/usr/bin/env bash
# Dung ban cu (neu co), build lai, chay. Chay nhieu lan khong loi.
docker rm -f quizlive >/dev/null 2>&1
docker build -t quizlive . || exit 1
docker run -d --name quizlive -p 8000:8000 \
  --env-file .env \
  -v quizlive-data:/app/db \
  quizlive >/dev/null || exit 1
echo "QuizLive dang chay: http://localhost:8000"
