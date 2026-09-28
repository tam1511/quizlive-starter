# Dung ban cu (neu co), build lai, chay. Chay nhieu lan khong loi.
docker rm -f quizlive 2>$null | Out-Null
docker build -t quizlive .
if ($LASTEXITCODE -ne 0) { exit 1 }
docker run -d --name quizlive -p 8000:8000 --env-file .env -v quizlive-data:/app/db quizlive | Out-Null
if ($LASTEXITCODE -ne 0) { exit 1 }
Write-Host "QuizLive dang chay: http://localhost:8000"
