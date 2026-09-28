# Trạng thái hiện tại

Đang ở: Bước 1 — khởi tạo
Đã xong: chưa có gì
Đang làm: chưa có gì
Quyết định vừa chốt: chưa có

---

## Ai được sửa file này

Khi làm một mình với một Claude: Claude cập nhật file này sau mỗi mảng việc.

Khi chạy agent team: **chỉ lead** sửa file này. Teammate xong việc thì báo
cho lead, lead ghi lại. Nhiều agent cùng sửa một file sẽ ghi đè lên nhau.

## Các sóng

| Sóng | Ai | Nội dung | Xong khi |
|---|---|---|---|
| 0 | Lead, một mình | Database, bảng, app tối thiểu, file trống cho mọi module | `/api/health` trả 200 |
| 1 | Người 1, 2, 3 cùng lúc | Luật chơi và điểm; trạng thái và bảng xếp hạng; sinh câu hỏi | Ba test invariant hết skip và xanh |
| 2 | Người 4, 5 cùng lúc | Màn hình host; màn hình người chơi | Chơi trọn một ván trên máy |
| 3 | Người 6 | Test chơi trọn ván qua API | `tests/game/` xanh |

## Nhật ký

<!-- Mục mới thêm lên trên cùng. Viết ngắn, không dán code.

### <ngày> — <ai> — <việc gì>
Đã làm:
Quyết định:
Người tiếp theo cần biết:
-->
