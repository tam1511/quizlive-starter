# QuizLive

Ứng dụng quiz trực tiếp. Host nhập chủ đề, AI sinh 5 câu hỏi, người chơi
vào bằng mã phòng hoặc quét QR, bảng xếp hạng cập nhật sau mỗi câu.

@planning/CONTRACT.md

Mô tả sản phẩm đầy đủ nằm trong `planning/SPEC.md` — đọc phần liên quan
khi cần, không cần đọc hết. Dự án đang ở đâu thì xem `planning/STATE.md`.

## Môi trường

Python venv + pip. `requirements.txt` là nơi duy nhất khai báo dependency.
Không dùng uv, poetry hay conda.

## Kiến trúc

Một Docker image. Frontend là HTML/CSS/JS tĩnh do FastAPI phục vụ, không
có build step, không Node. Chỉ `backend/generator.py` được gọi LLM.

## Quy ước

Đơn giản trước. File ngắn, đọc được trong một màn hình. Không emoji.

Không bao giờ sửa `tests/invariants/`. Nếu test đỏ, sửa code.
