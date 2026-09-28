# Hợp đồng chung

File này luôn nằm trong context của mọi agent. Nó chỉ chứa những gì các phần
của hệ thống phải thống nhất với nhau. Khi code và file này mâu thuẫn, file
này đúng.

## Ba ràng buộc bất biến

**INV-1.** Không bảng nào có cột lưu điểm cộng dồn. Điểm của một người chơi
luôn bằng `SUM(answers.points)` của người đó. Bảng xếp hạng tính từ `answers`.

**INV-2.** `UNIQUE(question_id, player_id)` trên bảng `answers`. Lần gửi thứ
hai cho cùng một câu trả `409` và không làm đổi điểm.

**INV-3.** Khi `status` là `lobby` hoặc `question`, phản hồi của mọi endpoint,
cho cả host lẫn người chơi, không được chứa khoá `correct_index` hay
`explanation` ở bất kỳ độ sâu nào.

## Dữ liệu

```
rooms      code PK, host_token, topic, status, current_index (bắt đầu -1), created_at
questions  id PK, room_code, idx, text, choices (JSON 4 chuỗi), correct_index,
           explanation, opened_at, closed_at        UNIQUE(room_code, idx)
players    id PK, room_code, nickname, token, joined_at
                                                    UNIQUE(room_code, nickname)
answers    id PK, room_code, question_id, player_id, choice_index, points,
           answered_at                              UNIQUE(question_id, player_id)
```

`status` là một trong: `lobby`, `question`, `reveal`, `finished`.
Mã phòng: 6 ký tự từ `ABCDEFGHJKLMNPQRSTUVWXYZ23456789`.
Đường dẫn database lấy từ biến `QUIZLIVE_DB`, mặc định `db/quizlive.db`.

## API

| Method | Path | Header | Body | Trả về |
|---|---|---|---|---|
| POST | `/api/rooms` | | `{topic}` | `201 {code, host_token}` |
| GET | `/api/rooms/{code}/qr.png` | | | ảnh PNG |
| POST | `/api/rooms/{code}/players` | | `{nickname}` | `201 {player_id, player_token}` |
| POST | `/api/rooms/{code}/start` | `X-Host-Token` | | `200` |
| POST | `/api/rooms/{code}/next` | `X-Host-Token` | | `200` |
| POST | `/api/rooms/{code}/answers` | `X-Player-Token` | `{question_id, choice_index}` | `200 {accepted: true}` |
| GET | `/api/rooms/{code}/state?role=host` | `X-Host-Token` | | xem dưới |
| GET | `/api/rooms/{code}/state?role=player` | `X-Player-Token` | | xem dưới |
| GET | `/api/health` | | | `200 {ok: true}` |

Lỗi: `404 {"detail": "room_not_found"}`, `403` sai token, `409` trả lời lần
hai hoặc trả lời khi câu đã đóng hoặc nickname trùng, `422` sai dữ liệu,
`503` thiếu khoá khi `QUESTIONS_SOURCE=llm`.

## Phản hồi của `/state`

```json
{
  "status": "question",
  "question": {
    "id": "...", "index": 0, "total": 5,
    "text": "...", "choices": ["...", "...", "...", "..."],
    "seconds_left": 14
  },
  "reveal": null,
  "leaderboard": [{"nickname": "...", "score": 1000, "rank": 1}]
}
```

- `question` là `null` khi `status` là `lobby` hoặc `finished`.
- `reveal` chỉ có giá trị khi `status` là `reveal` hoặc `finished`:
  `{"correct_index": 2, "explanation": "..."}`.
- `leaderboard`: tối đa 10 người, tính từ `answers`.
- Thêm cho `role=host`: `"players": ["Nam", "Lan"]`, `"answered": 3`.
- Thêm cho `role=player`: `"you": {"score": 0, "rank": 1, "answered_current": false}`.

Câu đang mở chuyển sang `reveal` khi server nhận bất kỳ request nào mà thấy
`seconds_left` bằng 0 hoặc mọi người chơi đã trả lời. Không có tiến trình
chạy nền.

## Hàm dùng chung giữa các module

```python
generator.generate(topic: str) -> list[dict]   # mỗi dict: text, choices, correct_index, explanation
scoring.points_for(correct: bool, seconds: int) -> int
views.leaderboard(room_code: str) -> list[dict]
```

## Quy tắc cho test trong `tests/invariants/`

- Mỗi test dùng database tạm: đặt `QUIZLIVE_DB` trỏ vào thư mục tạm của pytest.
  Không bao giờ đụng `db/quizlive.db`.
- Đặt `QUESTIONS_SOURCE=mock`.
- Nếu `backend.app` chưa import được, test tự skip.
- Nếu một endpoint cần dùng chưa được viết — FastAPI trả `404` với
  `{"detail": "Not Found"}` mặc định, khác với `room_not_found` — test tự skip.
- Test không được phụ thuộc thứ tự chạy hay kết quả của test khác.
